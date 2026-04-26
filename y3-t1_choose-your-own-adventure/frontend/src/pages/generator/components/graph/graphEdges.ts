/**
 * `Graph` → ReactFlow `Edge[]` adapter.
 *
 * One ReactFlow edge per parent → child relationship. Edge id is composite
 * so it stays stable across re-layouts.
 */

import type { Edge } from "@xyflow/react";

import type { Graph } from "../../../../types";

export const graphToFlowEdges = (graph: Graph): Edge[] => {
  const result: Edge[] = [];
  for (const node of Object.values(graph.nodeLookup)) {
    for (const childId of node.childrenIds) {
      result.push({
        id: `e-${node.nodeId}-${childId}`,
        source: String(node.nodeId),
        target: String(childId),
        type: "smoothstep",
      });
    }
  }
  return result;
};
