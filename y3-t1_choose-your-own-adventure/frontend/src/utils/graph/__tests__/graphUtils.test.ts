import { describe, it, expect } from 'vitest';
import {
  isValidConnectNodes,
  isValidDeleteEdge,
  deleteNodeFromGraph,
  graphMessageToGraphLookup,
  graphToGraphMessage,
  isGraphEmpty,
  findParent,
} from '../graphUtils';
import { Graph, NodeType, NarrativeNode, ActionNode } from '../../../types';

function makeGraph(): Graph {
  return {
    nodeLookup: {
      0: { nodeId: 0, data: "N0", childrenIds: [1, 2], type: NodeType.Narrative, isEnding: false } as NarrativeNode,
      1: { nodeId: 1, data: "A1", childrenIds: [3], type: NodeType.Action } as ActionNode,
      2: { nodeId: 2, data: "A2", childrenIds: [4], type: NodeType.Action } as ActionNode,
      3: { nodeId: 3, data: "N3", childrenIds: [], type: NodeType.Narrative, isEnding: true } as NarrativeNode,
      4: { nodeId: 4, data: "N4", childrenIds: [], type: NodeType.Narrative, isEnding: false } as NarrativeNode,
    },
  };
}

describe('isGraphEmpty', () => {
  it('returns true for empty graph', () => {
    expect(isGraphEmpty({ nodeLookup: {} })).toBe(true);
  });

  it('returns false for non-empty graph', () => {
    expect(isGraphEmpty(makeGraph())).toBe(false);
  });
});

describe('findParent', () => {
  it('finds parent of a child node', () => {
    expect(findParent(makeGraph(), 1)).toBe(0);
    expect(findParent(makeGraph(), 3)).toBe(1);
  });

  it('returns null for root node', () => {
    expect(findParent(makeGraph(), 0)).toBeNull();
  });
});

describe('isValidConnectNodes', () => {
  it('rejects action-to-action connections', () => {
    expect(isValidConnectNodes(makeGraph(), 1, 2)).toBe(false);
  });

  it('rejects self-connections', () => {
    expect(isValidConnectNodes(makeGraph(), 0, 0)).toBe(false);
  });

  it('rejects cycles', () => {
    // Connecting 3 -> 0 would create a cycle: 0 -> 1 -> 3 -> 0
    expect(isValidConnectNodes(makeGraph(), 3, 0)).toBe(false);
  });

  it('allows valid connections', () => {
    // N3 has no children, connecting to an orphan action node would be valid
    const graph = makeGraph();
    graph.nodeLookup[5] = { nodeId: 5, data: "A5", childrenIds: [], type: NodeType.Action } as ActionNode;
    expect(isValidConnectNodes(graph, 4, 5)).toBe(true);
  });
});

describe('isValidDeleteEdge', () => {
  it('rejects deletion that would disconnect graph', () => {
    // Deleting 0->1 would disconnect node 1 and 3
    expect(isValidDeleteEdge(makeGraph(), 0, 1)).toBe(false);
  });
});

describe('deleteNodeFromGraph', () => {
  it('removes node and its descendants', () => {
    const result = deleteNodeFromGraph(makeGraph(), 1, true);
    expect(result.nodeLookup[1]).toBeUndefined();
    expect(result.nodeLookup[3]).toBeUndefined();
    expect(result.nodeLookup[0]).toBeDefined();
  });

  it('removes only children when deleteThisNode=false', () => {
    const result = deleteNodeFromGraph(makeGraph(), 0, false);
    expect(result.nodeLookup[0]).toBeDefined();
    expect(Object.keys(result.nodeLookup)).toEqual(['0']);
  });
});

describe('graphMessageToGraphLookup / graphToGraphMessage', () => {
  it('round-trips correctly', () => {
    const graph = makeGraph();
    const message = graphToGraphMessage(graph);
    const restored = graphMessageToGraphLookup(message);
    expect(Object.keys(restored.nodeLookup).length).toBe(5);
    expect(restored.nodeLookup[0].data).toBe("N0");
  });
});
