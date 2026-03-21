import dagre from "dagre";
import { Graph } from "../../../utils/graph/types";
import { Node, Edge, Position, } from "reactflow";
import { flowNode } from "./graphVizNodes";
import { flowEdge } from "./graphVizEdges";

enum Layout {
  LR = "LR",
  TB = "TB"
}


export const getGraphNodesAndEdges = (layout: Layout, graph: Graph) => {

  const isHorizontal = layout === Layout.LR;

  const dagreGraph = new dagre.graphlib.Graph();
  dagreGraph.setDefaultEdgeLabel(() => ({}));

  const nodes: Node[] = [];
  const edges: Edge[] = [];

  const visited = new Set();

  const dfsBuildNodesAndEdges = (nodeId: number) => {
    if (visited.has(nodeId)) return;
    visited.add(nodeId);

    const node = graph.nodeLookup[nodeId];

    if (node.data) {
      nodes.push(flowNode({
        node: node,
        position: { x: 0, y: 0 },
        targetPosition: isHorizontal ? Position.Left : Position.Top,
        sourcePosition: isHorizontal ? Position.Right : Position.Bottom
      }));

      for (const childId of node.childrenIds) {
        edges.push(flowEdge({
          nodeId: nodeId,
          childId: childId,
        }));
        dfsBuildNodesAndEdges(childId);
      }
    }
  };

  dfsBuildNodesAndEdges(0);

  const nodeWidth = 172;
  const nodeHeight = 36;

  dagreGraph.setGraph({ rankdir: layout });

  nodes.forEach((node) => {
    dagreGraph.setNode(node.id, { width: node.width || nodeWidth, height: node.height || nodeHeight });
  });

  edges.forEach((edge) => {
    dagreGraph.setEdge(edge.source, edge.target);
  });

  dagre.layout(dagreGraph);

  nodes.forEach((node) => {
    const nodeWithPosition = dagreGraph.node(node.id);

    node.position = {
      x: nodeWithPosition.x - (node.width || nodeWidth) / 2,
      y: nodeWithPosition.y - (node.height || nodeHeight) / 2,
    };

    return node;
  });

  return { nodes, edges };
}

