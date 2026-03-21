import { Graph, NodeData } from "./types";

export const nodeDataToGraph = (nodeDataList: NodeData[]): Graph => {
    const nodeLookup: Record<number, NodeData> = {};
    for (const nodeData of nodeDataList) {
        nodeLookup[nodeData.nodeId] = nodeData;
    }

    return { nodeLookup };
}

export const graphToNodeData = (graph: Graph): NodeData[] => {
    return Object.values(graph.nodeLookup);
}