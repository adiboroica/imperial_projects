/**
 * Dagre-based layout for the ReactFlow graph.
 *
 * Pure: takes nodes and edges, returns nodes with computed positions.
 * Caller dispatches the layout result back into ReactFlow's `nodes` state.
 */

import type { Edge, Node } from "@xyflow/react";
import dagre from "dagre";

const NODE_WIDTH = 240;
const NODE_HEIGHT = 110;

export const dagreLayout = (
  nodes: Node[],
  edges: Edge[],
  direction: "TB" | "LR" = "TB",
): Node[] => {
  const g = new dagre.graphlib.Graph();
  g.setDefaultEdgeLabel(() => ({}));
  g.setGraph({ rankdir: direction, nodesep: 30, ranksep: 60 });

  for (const node of nodes) {
    g.setNode(node.id, { width: NODE_WIDTH, height: NODE_HEIGHT });
  }
  for (const edge of edges) {
    g.setEdge(edge.source, edge.target);
  }

  dagre.layout(g);

  return nodes.map((node) => {
    const positioned = g.node(node.id);
    return {
      ...node,
      position: {
        x: positioned.x - NODE_WIDTH / 2,
        y: positioned.y - NODE_HEIGHT / 2,
      },
    };
  });
};
