/**
 * `Graph` → ReactFlow `Node[]` adapter.
 *
 * Each node carries the original `NodeData` in `data.node` so the custom
 * renderers (`FlowNodeNarrative`, `FlowNodeAction`) can read it without an
 * extra Redux subscription.
 */

import type { Node } from "@xyflow/react";

import type { Graph } from "../../../../types";
import { isNarrativeNode } from "../../../../types";

export const graphToFlowNodes = (graph: Graph): Node[] => {
  const result: Node[] = [];
  for (const node of Object.values(graph.nodeLookup)) {
    result.push({
      id: String(node.nodeId),
      type: isNarrativeNode(node) ? "narrative" : "action",
      data: { node } as unknown as Record<string, unknown>,
      position: { x: 0, y: 0 }, // overwritten by `dagreLayout`
    });
  }
  return result;
};
