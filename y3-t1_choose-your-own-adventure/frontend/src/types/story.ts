/**
 * Story types — mirror the backend's `models/stories` package.
 */

import type { Graph } from "./graph";

/**
 * Lean projection returned by `GET /stories`.
 */
export type StoryListItem = {
  id: string;
  name: string;
  firstParagraph: string;
  totalSections: number;
};

/**
 * Full story (in-memory shape with `Graph.nodeLookup`).
 *
 * The wire format uses `nodes: NodeData[]`; api/stories.ts converts on the
 * way in/out via `graphMessageToGraph` / `graphToGraphMessage`.
 */
export type Story = {
  id: string;
  name: string;
  graph: Graph;
  createdAt: string;
  updatedAt: string;
};

/**
 * `POST /stories` body — every field optional.
 */
export type CreateStoryRequest = {
  name?: string;
  genre?: string;
  attributes?: Record<string, unknown>;
};

/**
 * `PATCH /stories/{id}` body.
 */
export type UpdateStoryNameRequest = {
  name: string;
};

/**
 * Available story export formats.
 */
export type ExportFormat = "docx" | "txt";
