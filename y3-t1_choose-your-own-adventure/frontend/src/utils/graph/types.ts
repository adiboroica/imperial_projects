export type NodeId = number;
export type SectionId = number;

export enum NodeType {
    Narrative = "narrative",
    Action = "action"
}

export type NodeBase = {
    nodeId: NodeId,
    data: string,
    childrenIds: NodeId[],
    type: NodeType
};

export type NarrativeNode = NodeBase & {
    isEnding: boolean,
};

export type ActionNode = NodeBase;

export type NodeData = NarrativeNode | ActionNode;

export type GraphMessage = {
    nodes: NodeData[]
};

export type SectionIdOrNull = SectionId | null;

export type StoryNode = {
    nodeId: NodeId,
    sectionId: SectionId,

    paragraph: string,
    actions: string[],

    childrenIds: NodeId[],
    childrenSectionIds: SectionIdOrNull[],
    isEnding: boolean,
};

export type Graph = {
    nodeLookup: Record<NodeId, NodeData>
};

export enum LoadingType {
    GenerateParagraph = "paragraph",
    GenerateActions = "actions",
    GenerateNewAction = "new action",
    GenerateEnding = "ending",
    ConnectingNodes = "connecting nodes",
    InitialStory = "initial story",
    GenerateMany = "many paragraphs and actions",
    SaveStory = "save story",
    SaveName = "save name"
};

export type StoryEntry = {
    title: string,
    content: string,
    graph: Graph
};
