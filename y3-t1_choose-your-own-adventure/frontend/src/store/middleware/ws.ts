/**
 * `wsMiddleware` — bridges WS events into Redux.
 *
 * The WS connection itself lives inside `api/clients/ws.ts`; this middleware
 * subscribes to two channels:
 *
 *   1. `progressUpdate` frames — dispatches the graph-slice action so the
 *      canvas re-renders mid-`generateMany`.
 *   2. Disconnect events (auth failure, origin mismatch, retries exhausted) —
 *      surfaces a Mantine toast so the user notices the connection drop.
 *
 * Client-initiated request/response WS calls are handled by Promise-based
 * thunks in `pages/generator/slices/graph.ts` — they don't pass through here.
 */

import type { Middleware, MiddlewareAPI } from "@reduxjs/toolkit";
import { notifications } from "@mantine/notifications";

import { generation } from "../../api";
import type { DisconnectedReason } from "../../api/clients/ws";
import { WSClient } from "../../api/clients/ws";
import { progressUpdate } from "../../pages/generator/slices/graph";
import { graphMessageToGraph } from "../../types";

const DISCONNECT_TOAST_TITLE: Record<DisconnectedReason, string> = {
  "auth-failed": "Session expired",
  "origin-mismatch": "Origin rejected",
  "validation-failed": "Protocol error",
  "max-retries-exhausted": "WebSocket disconnected",
  intentional: "",
};

const DISCONNECT_TOAST_BODY: Record<DisconnectedReason, string> = {
  "auth-failed": "Please sign in again to continue editing.",
  "origin-mismatch": "WebSocket origin check failed.",
  "validation-failed": "Server rejected a malformed frame.",
  "max-retries-exhausted":
    "Lost connection to the generation server. Refresh to reconnect.",
  intentional: "",
};

// Module-level refs so HMR / test re-runs don't accumulate listeners on the
// shared `WSClient` and `generation` singletons. The most-recent store wins —
// each new `wsMiddleware(store)` call rebinds `activeStore` while the
// listeners stay registered exactly once for the lifetime of the bundle.
let activeStore: MiddlewareAPI | null = null;
let listenersRegistered = false;
let unsubProgress: (() => void) | null = null;
let unsubDisconnected: (() => void) | null = null;

const registerListeners = () => {
  if (listenersRegistered) return;
  listenersRegistered = true;
  unsubProgress = generation.onProgress((payload) => {
    if (!activeStore) return;
    const graph = graphMessageToGraph(payload.graph);
    activeStore.dispatch(progressUpdate(graph));
  });
  unsubDisconnected = WSClient.onDisconnected((reason) => {
    if (reason === "intentional") return;
    notifications.show({
      color: "red",
      title: DISCONNECT_TOAST_TITLE[reason],
      message: DISCONNECT_TOAST_BODY[reason],
    });
  });
};

const wsMiddleware: Middleware = (store) => {
  activeStore = store;
  registerListeners();
  return (next) => (action) => next(action);
};

/** Test-only helper — drop the registered listeners and reset module state. */
export const __resetWsMiddlewareForTests = (): void => {
  unsubProgress?.();
  unsubDisconnected?.();
  unsubProgress = null;
  unsubDisconnected = null;
  listenersRegistered = false;
  activeStore = null;
};

export default wsMiddleware;
