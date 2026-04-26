/**
 * ApiClient unit tests — `fetch` mocked at the global level.
 */

import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import {
  Conflict,
  NetworkError,
  NotFound,
  ParseError,
  ServerError,
  Unauthenticated,
  ValidationError,
} from "../errors";
import { ApiClient } from "./http";

const makeResponse = (status: number, body?: string): Response =>
  new Response(body ?? "", {
    status,
    headers: { "Content-Type": "application/json" },
  });

describe("ApiClient", () => {
  beforeEach(() => {
    vi.stubGlobal("fetch", vi.fn());
  });
  afterEach(() => vi.restoreAllMocks());

  it("includes credentials on every request", async () => {
    (fetch as any).mockResolvedValueOnce(makeResponse(200, '{"ok":1}'));
    await ApiClient.get<{ ok: number }>("/anything");
    const init = (fetch as any).mock.calls[0][1];
    expect(init.credentials).toBe("include");
  });

  it("returns parsed JSON on 200", async () => {
    (fetch as any).mockResolvedValueOnce(makeResponse(200, '{"a":1}'));
    const result = await ApiClient.get<{ a: number }>("/x");
    expect(result).toEqual({ a: 1 });
  });

  it("returns undefined on 204", async () => {
    (fetch as any).mockResolvedValueOnce(new Response(null, { status: 204 }));
    const result = await ApiClient.delete("/x");
    expect(result).toBeUndefined();
  });

  it("translates 401 to Unauthenticated", async () => {
    (fetch as any).mockResolvedValueOnce(makeResponse(401));
    await expect(ApiClient.get("/x")).rejects.toBeInstanceOf(Unauthenticated);
  });

  it("translates 404 to NotFound", async () => {
    (fetch as any).mockResolvedValueOnce(makeResponse(404));
    await expect(ApiClient.get("/x")).rejects.toBeInstanceOf(NotFound);
  });

  it("translates 409 to Conflict", async () => {
    (fetch as any).mockResolvedValueOnce(makeResponse(409));
    await expect(ApiClient.post("/x")).rejects.toBeInstanceOf(Conflict);
  });

  it("translates 422 to ValidationError carrying details", async () => {
    (fetch as any).mockResolvedValueOnce(
      makeResponse(422, '{"detail":"bad"}'),
    );
    await expect(ApiClient.post("/x")).rejects.toBeInstanceOf(ValidationError);
  });

  it("translates 5xx to ServerError", async () => {
    (fetch as any).mockResolvedValueOnce(makeResponse(503));
    await expect(ApiClient.get("/x")).rejects.toBeInstanceOf(ServerError);
  });

  it("throws NetworkError when fetch rejects", async () => {
    (fetch as any).mockRejectedValueOnce(new Error("boom"));
    await expect(ApiClient.get("/x")).rejects.toBeInstanceOf(NetworkError);
  });

  it("throws ParseError on invalid JSON", async () => {
    (fetch as any).mockResolvedValueOnce(
      new Response("<html>not json</html>", {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }),
    );
    await expect(ApiClient.get("/x")).rejects.toBeInstanceOf(ParseError);
  });

  it("encodes query string parameters", async () => {
    (fetch as any).mockResolvedValueOnce(makeResponse(200, "{}"));
    await ApiClient.get("/x", { format: "docx", id: 12 });
    const url = (fetch as any).mock.calls[0][0];
    expect(url).toContain("format=docx");
    expect(url).toContain("id=12");
  });
});
