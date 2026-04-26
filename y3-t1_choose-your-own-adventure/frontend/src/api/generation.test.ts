import { describe, expect, it, vi } from "vitest";

import { generation } from "./generation";

vi.mock("./clients/ws", () => ({
  WSClient: {
    send: vi.fn(),
    onProgress: vi.fn(),
    connect: vi.fn(),
    close: vi.fn(),
  },
}));

import { WSClient } from "./clients/ws";

describe("api.generation", () => {
  it("generateInitial sends initialStory envelope and returns the unwrapped graph", async () => {
    (WSClient.send as any).mockResolvedValueOnce({
      graph: {
        nodes: [
          {
            nodeId: 0,
            data: "root",
            childrenIds: [],
            type: "narrative",
            isEnding: false,
          },
        ],
      },
    });
    const g = await generation.generateInitial("fantasy", { hero: "elf" }, 0.5);
    expect(g.nodeLookup[0].data).toBe("root");
    expect((WSClient.send as any).mock.calls[0][0]).toBe("initialStory");
  });

  it("generateActions sends generateActions envelope", async () => {
    (WSClient.send as any).mockResolvedValueOnce({ graph: { nodes: [] } });
    await generation.generateActions({ nodeLookup: {} }, 0, 2, 0.5);
    expect((WSClient.send as any).mock.calls[0][0]).toBe("generateActions");
  });

  it("connectNodes sends connectNode envelope (singular)", async () => {
    (WSClient.send as any).mockResolvedValueOnce({ graph: { nodes: [] } });
    await generation.connectNodes({ nodeLookup: {} }, 0, 1, 0.5);
    expect((WSClient.send as any).mock.calls[0][0]).toBe("connectNode");
  });

  it("onProgress proxies to WSClient", () => {
    const cb = vi.fn();
    generation.onProgress(cb);
    expect((WSClient.onProgress as any).mock.calls[0][0]).toBe(cb);
  });
});
