import { Position } from "reactflow";
import { NodeData, NodeType } from "../../../utils/graph/types";


interface flowNodeArgs {
  node: NodeData,
  position: { x: number, y: number },
  targetPosition: Position,
  sourcePosition: Position,
}

export const flowNode = (args: flowNodeArgs) => {

  const {
    node,
    position,
    targetPosition,
    sourcePosition,
  } = args;

  switch (node.type) {
    case NodeType.Narrative: {
      return {
        id: node.nodeId.toString(),
        type: 'narrative',
        data: {
          narrativeNode: node
        },
        position,
        targetPosition: targetPosition,
        sourcePosition: sourcePosition,
      };
    }
    case NodeType.Action: {
      return {
        id: node.nodeId.toString(),
        type: 'action',
        data: {
          actionNode: node,
        },
        position: position,
        targetPosition: targetPosition,
        sourcePosition: sourcePosition,
      };
    }
  }
}

