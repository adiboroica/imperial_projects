/**
 * Typed WebSocket client. The only caller of `WebSocket` in the entire frontend.
 *
 * Owns the connection, the `requestId`-keyed envelope, and the in-flight
 * Promise map that resolves on matching `requestComplete` frames.
 */

import type { GraphMessage } from "../../types";
import {
  NlpParseError,
  OpenAIRateLimit,
  OpenAIUnavailable,
  Unauthenticated,
  WSClosedError,
} from "../errors";

const WS_URL: string =
  (import.meta.env.VITE_WS_URL as string | undefined) ??
  `${window.location.protocol === "https:" ? "wss:" : "ws:"}//${
    window.location.host
  }/ws`;

const CODE_NORMAL_CLOSURE = 1000;
const CODE_GOING_AWAY = 1001;
const CODE_VALIDATION_FAILED = 1003;
const CODE_AUTH_FAILED = 4001;
const CODE_ORIGIN_MISMATCH = 4003;

export type ClientMessageType =
  | "initialStory"
  | "generateActions"
  | "addAction"
  | "generateNarrative"
  | "connectNode"
  | "generateMany";

export type ServerMessageType =
  | "requestComplete"
  | "progressUpdate"
  | "error"
  | "rateLimitError"
  | "openaiError"
  | "nlpParseError";

export type Envelope = {
  requestId: string;
  type: ClientMessageType | ServerMessageType;
  payload: Record<string, unknown>;
};

export type ProgressUpdatePayload = {
  graph: GraphMessage;
  nodesGenerated: number;
  percentage: number;
};

export type ProgressUpdateListener = (payload: ProgressUpdatePayload) => void;

export type DisconnectedReason =
  | "auth-failed"
  | "origin-mismatch"
  | "validation-failed"
  | "max-retries-exhausted"
  | "intentional";

export type DisconnectedListener = (reason: DisconnectedReason) => void;

type Pending = {
  resolve: (value: unknown) => void;
  reject: (reason: unknown) => void;
};

const newRequestId = (): string => {
  if (typeof crypto !== "undefined" && "randomUUID" in crypto) {
    return crypto.randomUUID();
  }
  // Fallback (no UUID v4 guarantee but acceptable in legacy environments).
  return `${Date.now().toString(16)}-${Math.floor(Math.random() * 1e16).toString(16)}`;
};

/** Close codes after which the client should NOT auto-reconnect. */
const TERMINAL_CLOSE_CODES = new Set<number>([
  CODE_NORMAL_CLOSURE,
  CODE_VALIDATION_FAILED,
  CODE_AUTH_FAILED,
  CODE_ORIGIN_MISMATCH,
]);

const RECONNECT_BACKOFF_MS = 3_000;
const MAX_RECONNECT_ATTEMPTS = 5;

class WSClientImpl {
  private socket: WebSocket | null = null;
  private connecting: Promise<void> | null = null;
  private inflight = new Map<string, Pending>();
  private progressListeners = new Set<ProgressUpdateListener>();
  private disconnectedListeners = new Set<DisconnectedListener>();
  private reconnectAttempts = 0;
  private intentionallyClosed = false;

  /** Lazily open the connection (idempotent). */
  async connect(): Promise<void> {
    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      this.reconnectAttempts = 0;
      return;
    }
    if (this.connecting) return this.connecting;
    this.intentionallyClosed = false;
    this.connecting = new Promise<void>((resolve, reject) => {
      const ws = new WebSocket(WS_URL);
      this.socket = ws;
      ws.onopen = () => {
        this.connecting = null;
        resolve();
      };
      ws.onerror = () => {
        // `onclose` will fire next; we let that handle pending Promises.
      };
      ws.onclose = (event) => {
        this.handleClose(event.code);
        if (this.connecting) {
          this.connecting = null;
          reject(this.errorForCloseCode(event.code));
        }
      };
      ws.onmessage = (event) => this.handleFrame(event.data);
    });
    return this.connecting;
  }

  /** Send a typed message and wait for the matching `requestComplete`.
   *
   *  Fast path: if the socket is already OPEN, the envelope is pushed onto the
   *  wire inside the new-Promise executor — synchronously, no microtask hop.
   *  Slow path: open / await the in-flight connect, re-check, then proceed. */
  async send<T>(type: ClientMessageType, payload: Record<string, unknown>): Promise<T> {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      await this.connect();
      if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
        throw new WSClosedError(CODE_GOING_AWAY, "WebSocket is not open");
      }
    }
    const requestId = newRequestId();
    const envelope: Envelope = { requestId, type, payload };
    return new Promise<T>((resolve, reject) => {
      this.inflight.set(requestId, {
        resolve: resolve as (value: unknown) => void,
        reject,
      });
      this.socket!.send(JSON.stringify(envelope));
    });
  }

  /** Subscribe to server-pushed `progressUpdate` frames. Returns unsubscribe. */
  onProgress(listener: ProgressUpdateListener): () => void {
    this.progressListeners.add(listener);
    return () => this.progressListeners.delete(listener);
  }

  /** Subscribe to disconnect events (auth failure, origin mismatch, retries exhausted). */
  onDisconnected(listener: DisconnectedListener): () => void {
    this.disconnectedListeners.add(listener);
    return () => this.disconnectedListeners.delete(listener);
  }

  /** Close the connection (used in tests / cleanup). Disables auto-reconnect. */
  close(): void {
    this.intentionallyClosed = true;
    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      this.socket.close(CODE_NORMAL_CLOSURE);
    }
    this.socket = null;
    this.connecting = null;
    this.reconnectAttempts = 0;
  }

  // ---------- Internals ----------

  private handleFrame(raw: unknown): void {
    if (typeof raw !== "string") return;
    let envelope: Envelope;
    try {
      envelope = JSON.parse(raw) as Envelope;
    } catch {
      return;
    }
    if (!envelope || typeof envelope !== "object") return;

    if (envelope.type === "progressUpdate") {
      const payload = envelope.payload as unknown as ProgressUpdatePayload;
      this.progressListeners.forEach((cb) => cb(payload));
      return;
    }

    const pending = this.inflight.get(envelope.requestId);
    if (!pending) return;
    this.inflight.delete(envelope.requestId);

    switch (envelope.type) {
      case "requestComplete":
        pending.resolve(envelope.payload);
        return;
      case "rateLimitError":
        pending.reject(new OpenAIRateLimit(messageOrUndefined(envelope.payload)));
        return;
      case "openaiError":
        pending.reject(new OpenAIUnavailable(messageOrUndefined(envelope.payload)));
        return;
      case "nlpParseError":
        pending.reject(new NlpParseError(messageOrUndefined(envelope.payload)));
        return;
      case "error":
      default:
        pending.reject(new Error(messageOrUndefined(envelope.payload) ?? "WS error"));
    }
  }

  private handleClose(code: number): void {
    const error = this.errorForCloseCode(code);
    for (const pending of this.inflight.values()) {
      pending.reject(error);
    }
    this.inflight.clear();
    this.socket = null;
    this.maybeReconnect(code);
  }

  private maybeReconnect(code: number): void {
    if (this.intentionallyClosed) {
      this.notifyDisconnected("intentional");
      return;
    }
    if (code === CODE_AUTH_FAILED) {
      this.notifyDisconnected("auth-failed");
      return;
    }
    if (code === CODE_ORIGIN_MISMATCH) {
      this.notifyDisconnected("origin-mismatch");
      return;
    }
    if (code === CODE_VALIDATION_FAILED) {
      this.notifyDisconnected("validation-failed");
      return;
    }
    if (TERMINAL_CLOSE_CODES.has(code)) return;
    if (this.reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      this.notifyDisconnected("max-retries-exhausted");
      return;
    }
    this.reconnectAttempts += 1;
    setTimeout(() => {
      // `connect()` is idempotent if a socket is already open.
      void this.connect().catch(() => {
        /* errors surface via subsequent send() calls */
      });
    }, RECONNECT_BACKOFF_MS);
  }

  private notifyDisconnected(reason: DisconnectedReason): void {
    this.disconnectedListeners.forEach((cb) => cb(reason));
  }

  private errorForCloseCode(code: number): Error {
    if (code === CODE_AUTH_FAILED) return new Unauthenticated("WebSocket auth failed");
    if (code === CODE_ORIGIN_MISMATCH)
      return new WSClosedError(code, "Origin mismatch");
    if (code === CODE_VALIDATION_FAILED)
      return new WSClosedError(code, "Validation failed");
    return new WSClosedError(code, "WebSocket closed");
  }
}

const messageOrUndefined = (
  payload: Record<string, unknown> | undefined,
): string | undefined => {
  if (!payload) return undefined;
  const m = payload["message"];
  return typeof m === "string" ? m : undefined;
};

/** Process-wide singleton — pages dispatch through `WSClient`. */
export const WSClient = new WSClientImpl();
