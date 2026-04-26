import { describe, expect, it, vi } from "vitest";

import {
  InvalidGraph,
  NotFound,
  StoryNotFound,
  ValidationError,
} from "./errors";
import { stories } from "./stories";

vi.mock("./clients/http", () => ({
  ApiClient: {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    patch: vi.fn(),
    delete: vi.fn(),
    url: vi.fn((path: string, query?: Record<string, unknown>) => {
      const qs = query
        ? "?" + new URLSearchParams(query as any).toString()
        : "";
      return `/api${path}${qs}`;
    }),
  },
}));

import { ApiClient } from "./clients/http";

describe("api.stories", () => {
  it("create posts to /stories", async () => {
    (ApiClient.post as any).mockResolvedValueOnce({ id: "s1", name: "X" });
    const r = await stories.create({});
    expect(r.id).toBe("s1");
    expect((ApiClient.post as any).mock.calls[0][0]).toBe("/stories");
  });

  it("list returns the list", async () => {
    (ApiClient.get as any).mockResolvedValueOnce([]);
    const r = await stories.list();
    expect(r).toEqual([]);
  });

  it("getById converts wire graph to nodeLookup", async () => {
    (ApiClient.get as any).mockResolvedValueOnce({
      id: "s1",
      name: "S",
      graph: {
        nodes: [
          { nodeId: 0, data: "root", childrenIds: [], type: "narrative", isEnding: false },
        ],
      },
      createdAt: "2026-01-01",
      updatedAt: "2026-01-02",
    });
    const story = await stories.getById("s1");
    expect(story.graph.nodeLookup[0].data).toBe("root");
  });

  it("getById narrows 404 to StoryNotFound", async () => {
    (ApiClient.get as any).mockRejectedValueOnce(new NotFound());
    await expect(stories.getById("missing")).rejects.toBeInstanceOf(
      StoryNotFound,
    );
  });

  it("saveGraph narrows 422 to InvalidGraph", async () => {
    (ApiClient.put as any).mockRejectedValueOnce(new ValidationError());
    await expect(
      stories.saveGraph("s1", { nodeLookup: {} }),
    ).rejects.toBeInstanceOf(InvalidGraph);
  });

  it("delete narrows 404 to StoryNotFound", async () => {
    (ApiClient.delete as any).mockRejectedValueOnce(new NotFound());
    await expect(stories.delete("missing")).rejects.toBeInstanceOf(
      StoryNotFound,
    );
  });

  it("exportUrl returns the path with the format query parameter", () => {
    const url = stories.exportUrl("s1", "docx");
    expect(url).toContain("/stories/s1/export");
    expect(url).toContain("format=docx");
  });
});
