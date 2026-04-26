import {
  ActionNode,
  Graph,
  GraphMessage,
  NarrativeNode,
  NodeData,
  NodeId,
  NodeType,
  graphMessageToGraph as messageToGraph,
  graphToGraphMessage as graphToMessage,
} from "../../types";

export const isGraphEmpty = (graph: Graph): boolean => {
  return Object.keys(graph.nodeLookup).length === 0;
};

export const makeNarrativeNode = (
  params: Omit<NarrativeNode, "type">,
): NarrativeNode => ({
  type: NodeType.Narrative,
  ...params,
});

export const makeActionNode = (params: Omit<ActionNode, "type">): ActionNode => ({
  type: NodeType.Action,
  ...params,
});

export const isNarrative = (node: NodeData): boolean =>
  node.type === NodeType.Narrative;

export const isAction = (node: NodeData): boolean => node.type === NodeType.Action;

export const graphMessageToGraphLookup = (msg: GraphMessage): Graph =>
  messageToGraph(msg);

export const graphLookupToGraphMessage = (graph: Graph): GraphMessage =>
  graphToMessage(graph);

// Re-export the canonical converters for callers that prefer the shorter names.
export { messageToGraph as graphMessageToGraph, graphToMessage as graphToGraphMessage };

export const findParent = (graph: Graph, nodeId: number): number | null => {
  const visited = new Set<NodeId>();
  const dfs = (currId: number): number | null => {
    if (visited.has(currId)) return null;
    visited.add(currId);
    const node = graph.nodeLookup[currId];
    if (!node) return null;
    for (const childId of node.childrenIds) {
      if (childId === nodeId) return currId;
      const result = dfs(childId);
      if (result !== null) return result;
    }
    return null;
  };
  return dfs(0);
};

export const deleteNodeFromGraph = (
  graph: Graph,
  nodeId: number,
  deleteThisNode = false,
): Graph => {
  const toKeep = new Set<NodeId>();
  const dfs = (currId: number) => {
    const node = graph.nodeLookup[currId];
    if (!node) return;
    if (currId === nodeId) {
      if (!deleteThisNode) toKeep.add(currId);
      return;
    }
    if (toKeep.has(currId)) return;
    toKeep.add(currId);
    for (const childId of node.childrenIds) dfs(childId);
  };
  dfs(0);

  return {
    nodeLookup: Object.fromEntries(
      Object.entries(graph.nodeLookup)
        .filter(([id]) => toKeep.has(parseInt(id, 10)))
        .map(([id, v]) => {
          if (deleteThisNode && v.childrenIds.includes(nodeId)) {
            return [
              id,
              { ...v, childrenIds: v.childrenIds.filter((i) => i !== nodeId) },
            ];
          }
          return parseInt(id, 10) === nodeId
            ? [id, { ...v, childrenIds: [] }]
            : [id, v];
        }),
    ),
  };
};

export const isValidConnectNodes = (
  graph: Graph,
  fromNode: number,
  toNode: number,
): boolean => {
  const fromData = graph.nodeLookup[fromNode];
  const toData = graph.nodeLookup[toNode];
  if (!fromData || !toData) return false;

  if (fromData.type === NodeType.Action && toData.type === NodeType.Action) {
    return false;
  }

  const children = fromData.childrenIds;
  if (children.length !== 0) {
    const firstChild = graph.nodeLookup[children[0]];
    if (
      firstChild &&
      (firstChild.type !== toData.type ||
        firstChild.type === NodeType.Narrative)
    ) {
      return false;
    }
  }

  if (fromNode === toNode) return false;

  // Cycle detection.
  const visited = new Set<NodeId>();
  const isReachable = (currId: number): boolean => {
    if (currId === fromNode) return true;
    if (visited.has(currId)) return false;
    visited.add(currId);
    for (const childId of graph.nodeLookup[currId]?.childrenIds ?? []) {
      if (isReachable(childId)) return true;
    }
    return false;
  };
  return !isReachable(toNode);
};

export const connectNodesOnGraph = (
  graph: Graph,
  fromNode: number,
  toNode: number,
): Graph => {
  if (isValidConnectNodes(graph, fromNode, toNode)) {
    graph.nodeLookup[fromNode].childrenIds.push(toNode);
  }
  return graph;
};

export const isValidDeleteEdge = (
  graph: Graph,
  fromNode: number,
  toNode: number,
): boolean => {
  const existsPath = (() => {
    const visited = new Set<NodeId>();
    const dfs = (currId: number): boolean => {
      if (currId === fromNode) return true;
      if (visited.has(currId)) return false;
      visited.add(currId);
      for (const childId of graph.nodeLookup[currId]?.childrenIds ?? []) {
        if (dfs(childId)) return true;
      }
      return false;
    };
    return dfs(toNode);
  })();

  if (existsPath) return true;

  let toNodeParentCount = 0;
  const visited = new Set<NodeId>();
  const dfs = (currId: number) => {
    if (visited.has(currId)) return;
    visited.add(currId);
    for (const childId of graph.nodeLookup[currId]?.childrenIds ?? []) {
      if (childId === toNode) toNodeParentCount += 1;
      else dfs(childId);
    }
  };
  dfs(0);

  if (toNodeParentCount <= 1 && toNode !== 0) return false;
  return true;
};

export const deleteEdgeOnGraph = (
  graph: Graph,
  fromNode: number,
  toNode: number,
): Graph => {
  if (isValidDeleteEdge(graph, fromNode, toNode)) {
    const node = graph.nodeLookup[fromNode];
    if (node) {
      node.childrenIds = node.childrenIds.filter((c) => c !== toNode);
    }
  }
  return graph;
};
