/**
 * Graph types — shared between in-memory Redux state, the wire format, and the React components.
 *
 * The wire format (`GraphMessage`) is a node array; this is what the backend sends and receives.
 * The in-memory Redux representation (`Graph`) keeps a `nodeLookup` map for O(1) access by id.
 * `graphMessageToGraph` and `graphToGraphMessage` are the two converters used at the api boundary.
 */

export type NodeId = number;
export type SectionId = number;
export type SectionIdOrNull = SectionId | null;

export enum NodeType {
  Narrative = "narrative",
  Action = "action",
}

export type NodeBase = {
  nodeId: NodeId;
  data: string;
  childrenIds: NodeId[];
  type: NodeType;
};

export type NarrativeNode = NodeBase & {
  type: NodeType.Narrative;
  isEnding: boolean;
};

export type ActionNode = NodeBase & {
  type: NodeType.Action;
};

export type NodeData = NarrativeNode | ActionNode;

/**
 * Wire shape — the backend's `GamebookGraph.to_graph_dict()` output.
 */
export type GraphMessage = {
  nodes: NodeData[];
};

/**
 * In-memory shape used by Redux state and graph helpers.
 */
export type Graph = {
  nodeLookup: Record<NodeId, NodeData>;
};

export type StoryNode = {
  nodeId: NodeId;
  sectionId: SectionId;
  paragraph: string;
  actions: string[];
  childrenIds: NodeId[];
  childrenSectionIds: SectionIdOrNull[];
  isEnding: boolean;
};

/**
 * UX state describing what kind of generation is currently in flight.
 */
export enum LoadingType {
  GenerateParagraph = "paragraph",
  GenerateActions = "actions",
  GenerateNewAction = "new action",
  GenerateEnding = "ending",
  ConnectingNodes = "connecting nodes",
  InitialStory = "initial story",
  GenerateMany = "many paragraphs and actions",
  SaveStory = "save story",
  SaveName = "save name",
}

// ---------- Converters ----------

export const graphMessageToGraph = (msg: GraphMessage): Graph => {
  const nodeLookup: Record<NodeId, NodeData> = {};
  for (const node of msg.nodes) {
    nodeLookup[node.nodeId] = node;
  }
  return { nodeLookup };
};

export const graphToGraphMessage = (graph: Graph): GraphMessage => ({
  nodes: Object.values(graph.nodeLookup),
});

export const isNarrativeNode = (n: NodeData): n is NarrativeNode =>
  n.type === NodeType.Narrative;

export const isActionNode = (n: NodeData): n is ActionNode =>
  n.type === NodeType.Action;
