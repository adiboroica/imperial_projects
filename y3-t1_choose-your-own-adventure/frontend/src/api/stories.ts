/**
 * Stories domain wrappers — `/stories/*` REST surface plus the export URL builder.
 *
 * The wire format carries `graph: {nodes: [...]}`; this layer converts to/from
 * the in-memory `Graph = {nodeLookup}` shape that slices use.
 */

import type {
  CreateStoryRequest,
  ExportFormat,
  Graph,
  GraphMessage,
  Story,
  StoryListItem,
  UpdateStoryNameRequest,
} from "../types";
import { graphMessageToGraph, graphToGraphMessage } from "../types";
import { ApiClient } from "./clients/http";
import { InvalidGraph, NotFound, StoryNotFound, ValidationError } from "./errors";

type CreateStoryResponse = { id: string; name: string };

type StoryWireResponse = {
  id: string;
  name: string;
  graph: GraphMessage;
  createdAt: string;
  updatedAt: string;
};

const wireToStory = (wire: StoryWireResponse): Story => ({
  id: wire.id,
  name: wire.name,
  graph: graphMessageToGraph(wire.graph),
  createdAt: wire.createdAt,
  updatedAt: wire.updatedAt,
});

export const stories = {
  /** `POST /stories` — returns the new story id. */
  create: async (body: CreateStoryRequest = {}): Promise<CreateStoryResponse> => {
    return await ApiClient.post<CreateStoryResponse>("/stories", body);
  },

  /** `GET /stories` — list view (no graph). */
  list: async (): Promise<StoryListItem[]> => {
    return await ApiClient.get<StoryListItem[]>("/stories");
  },

  /** `GET /stories/{id}` — full view, narrows 404 → `StoryNotFound`. */
  getById: async (storyId: string): Promise<Story> => {
    try {
      const wire = await ApiClient.get<StoryWireResponse>(`/stories/${storyId}`);
      return wireToStory(wire);
    } catch (err) {
      if (err instanceof NotFound) throw new StoryNotFound();
      throw err;
    }
  },

  /** `PATCH /stories/{id}` — rename. Narrows 404 → `StoryNotFound`. */
  updateName: async (
    storyId: string,
    body: UpdateStoryNameRequest,
  ): Promise<CreateStoryResponse> => {
    try {
      return await ApiClient.patch<CreateStoryResponse>(`/stories/${storyId}`, body);
    } catch (err) {
      if (err instanceof NotFound) throw new StoryNotFound();
      throw err;
    }
  },

  /** `PUT /stories/{id}/graph` — narrows 422 → `InvalidGraph`. */
  saveGraph: async (storyId: string, graph: Graph): Promise<void> => {
    try {
      await ApiClient.put<void>(`/stories/${storyId}/graph`, {
        graph: graphToGraphMessage(graph),
      });
    } catch (err) {
      if (err instanceof ValidationError) throw new InvalidGraph(err.details);
      if (err instanceof NotFound) throw new StoryNotFound();
      throw err;
    }
  },

  /** `DELETE /stories/{id}`. */
  delete: async (storyId: string): Promise<void> => {
    try {
      await ApiClient.delete<void>(`/stories/${storyId}`);
    } catch (err) {
      if (err instanceof NotFound) throw new StoryNotFound();
      throw err;
    }
  },

  /**
   * Export URL — call with `<a href={stories.exportUrl(id, "docx")} download>`.
   * The browser handles the download; no client-side blob construction.
   */
  exportUrl: (storyId: string, format: ExportFormat): string =>
    ApiClient.url(`/stories/${storyId}/export`, { format }),
};
