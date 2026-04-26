/**
 * Generation domain wrappers — WS-based story-graph expansion.
 *
 * Each function sends one envelope and resolves with the updated `Graph`
 * (in-memory lookup shape) from the matching `requestComplete` frame. Wire
 * frames carry `graph: {nodes: []}`; converted at this boundary.
 */

import type { Graph, GraphMessage } from "../types";
import { graphMessageToGraph, graphToGraphMessage } from "../types";
import { WSClient } from "./clients/ws";
import type { ProgressUpdateListener } from "./clients/ws";

type RequestCompleteResponse = { graph: GraphMessage };

const sendAndUnwrap = async (
  type: Parameters<typeof WSClient.send>[0],
  payload: Record<string, unknown>,
): Promise<Graph> => {
  const result = await WSClient.send<RequestCompleteResponse>(type, payload);
  return graphMessageToGraph(result.graph);
};

const wireGraph = (graph: Graph): GraphMessage => graphToGraphMessage(graph);

export const generation = {
  generateInitial: (
    genre: string,
    attributes: Record<string, unknown>,
    temperature: number,
  ): Promise<Graph> =>
    sendAndUnwrap("initialStory", { genre, attributes, temperature }),

  generateActions: (
    graph: Graph,
    nodeId: number,
    numActions: number,
    temperature: number,
  ): Promise<Graph> =>
    sendAndUnwrap("generateActions", {
      graph: wireGraph(graph),
      nodeId,
      numActions,
      temperature,
    }),

  addAction: (
    graph: Graph,
    nodeId: number,
    numActions: number,
    temperature: number,
  ): Promise<Graph> =>
    sendAndUnwrap("addAction", {
      graph: wireGraph(graph),
      nodeId,
      numActions,
      temperature,
    }),

  generateNarrative: (
    graph: Graph,
    nodeId: number,
    options: {
      isEnding?: boolean;
      descriptor?: string | null;
      details?: string | null;
      style?: string | null;
      temperature: number;
    },
  ): Promise<Graph> =>
    sendAndUnwrap("generateNarrative", {
      graph: wireGraph(graph),
      nodeId,
      isEnding: options.isEnding ?? false,
      descriptor: options.descriptor ?? null,
      details: options.details ?? null,
      style: options.style ?? null,
      temperature: options.temperature,
    }),

  connectNodes: (
    graph: Graph,
    sourceId: number,
    targetId: number,
    temperature: number,
  ): Promise<Graph> =>
    sendAndUnwrap("connectNode", {
      graph: wireGraph(graph),
      sourceId,
      targetId,
      temperature,
    }),

  generateMany: (
    graph: Graph,
    nodeId: number,
    depth: number,
    numActions: number,
    temperature: number,
  ): Promise<Graph> =>
    sendAndUnwrap("generateMany", {
      graph: wireGraph(graph),
      nodeId,
      depth,
      numActions,
      temperature,
    }),

  /** Subscribe to `progressUpdate` frames pushed by `generateMany`. */
  onProgress: (listener: ProgressUpdateListener): (() => void) =>
    WSClient.onProgress(listener),

  /** Open the WebSocket connection. Idempotent. */
  connect: (): Promise<void> => WSClient.connect(),

  /** Close the connection (cleanup). */
  close: (): void => WSClient.close(),
};
