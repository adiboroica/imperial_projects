import { describe, expect, it, vi } from "vitest";

import { apiKey } from "./api_key";

vi.mock("./clients/http", () => ({
  ApiClient: {
    get: vi.fn(),
    put: vi.fn(),
  },
}));

import { ApiClient } from "./clients/http";

describe("api.apiKey", () => {
  it("get returns the apiKey field", async () => {
    (ApiClient.get as any).mockResolvedValueOnce({ apiKey: "sk-test" });
    const r = await apiKey.get();
    expect(r).toBe("sk-test");
  });

  it("get returns null when unset", async () => {
    (ApiClient.get as any).mockResolvedValueOnce({ apiKey: null });
    expect(await apiKey.get()).toBeNull();
  });

  it("put sends the apiKey body and returns the new value", async () => {
    (ApiClient.put as any).mockResolvedValueOnce({ apiKey: "sk-rotated" });
    const r = await apiKey.put("sk-rotated");
    expect(r).toBe("sk-rotated");
    expect((ApiClient.put as any).mock.calls[0][1]).toEqual({
      apiKey: "sk-rotated",
    });
  });
});
