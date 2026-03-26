import { graphToGraphMessage } from "../../utils/graph/graphUtils";
import { Graph } from "../../utils/graph/types";


export const generateNarrativeMsg = (
  temperature: number,
  graph: Graph,
  nodeToExpand: number,
  isEnding: boolean,
  descriptor: string | null,
  details: string | null,
  style: string | null
) => {
  if (descriptor === "") {
    descriptor = null;
  }
  if (details === "") {
    details = null;
  }
  if (style === "") {
    style = null;
  }
  return JSON.stringify({
    type: "generateNarrative",
    temperature,
    data: {
      nodeToExpand,
      graph: graphToGraphMessage(graph),
      isEnding,
      descriptor,
      details,
      style
    },
  });
}


export const generateInitialStoryMsg = (
  temperature: number,
  values: { attribute: string, content: string }[]
) => {
  return JSON.stringify({
    type: "initialStory",
    temperature,
    data: {
      prompt: values,
    },
  });
};


export const generateActionsMsg = (
  temperature: number,
  graph: Graph,
  nodeToExpand: number
) => {
  return JSON.stringify({
    type: "generateActions",
    temperature,
    data: {
      nodeToExpand,
      graph: graphToGraphMessage(graph),
    },
  });
};


export const addActionMsg = (
  temperature: number,
  graph: Graph,
  nodeToExpand: number,
  numNewActions: number,
) => {
  return JSON.stringify({
    type: "addAction",
    temperature,
    data: {
      nodeToExpand,
      graph: graphToGraphMessage(graph),
      numNewActions,
    },
  });
};


export const connectNodesMsg = (
  temperature: number,
  graph: Graph,
  fromNode: number,
  toNode: number
) => {
  return JSON.stringify({
    type: "connectNode",
    temperature,
    data: {
      fromNode,
      toNode,
      graph: graphToGraphMessage(graph),
    },
  });
};

export const generateManyMsg = (
  temperature: number,
  graph: Graph,
  fromNode: number,
  maxDepth: number,
  saveToId: string,
) => {
  return JSON.stringify({
    type: "generateMany",
    temperature,
    data: {
      graph: graphToGraphMessage(graph),
      fromNode,
      maxDepth,
      saveToId,
    },
  });
};
