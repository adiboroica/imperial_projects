/**
 * WSClient tests — uses the deterministic `MockWebSocket` from `tests/setup.ts`.
 *
 * The mock records every instance on `globalThis.__wsInstances`; tests grab
 * the latest one and call `triggerOpen` / `triggerClose` to drive lifecycle
 * events without timer races.
 */

import { afterEach, describe, expect, it, vi } from "vitest";

import type { MockWebSocket } from "../../../tests/setup";
import { WSClient } from "./ws";

const latestSocket = (): MockWebSocket | undefined => {
  const instances =
    (globalThis as unknown as { __wsInstances?: MockWebSocket[] }).__wsInstances ??
    [];
  return instances[instances.length - 1];
};

afterEach(() => {
  WSClient.close();
});

describe("WSClient", () => {
  it("connect resolves once the underlying socket fires onopen", async () => {
    const promise = WSClient.connect();
    const sock = latestSocket();
    expect(sock).toBeDefined();
    sock!.triggerOpen();
    await expect(promise).resolves.toBeUndefined();
  });

  it("send delivers a JSON envelope after connect", async () => {
    const promise = WSClient.connect();
    const sock = latestSocket()!;
    sock.triggerOpen();
    await promise;

    void WSClient.send("initialStory", { genre: "fantasy" });
    expect(sock.send).toHaveBeenCalledTimes(1);
    const sent = JSON.parse((sock.send as any).mock.calls[0][0]);
    expect(sent.type).toBe("initialStory");
    expect(sent.payload).toEqual({ genre: "fantasy" });
    expect(typeof sent.requestId).toBe("string");
  });

  it("rejects in-flight Promises when the socket closes", async () => {
    const connectPromise = WSClient.connect();
    const sock = latestSocket()!;
    sock.triggerOpen();
    await connectPromise;

    const sendPromise = WSClient.send("initialStory", { genre: "fantasy" });
    sock.triggerClose(1006); // abnormal closure
    await expect(sendPromise).rejects.toBeTruthy();
  });

  it("notifies disconnected listeners on auth failure (4001)", async () => {
    const connectPromise = WSClient.connect();
    const sock = latestSocket()!;
    sock.triggerOpen();
    await connectPromise;

    const cb = vi.fn();
    WSClient.onDisconnected(cb);
    sock.triggerClose(4001);
    expect(cb).toHaveBeenCalledWith("auth-failed");
  });

  it("onProgress registers a listener and returns an unsubscribe", () => {
    const cb = vi.fn();
    const unsub = WSClient.onProgress(cb);
    expect(typeof unsub).toBe("function");
    unsub();
  });
});
