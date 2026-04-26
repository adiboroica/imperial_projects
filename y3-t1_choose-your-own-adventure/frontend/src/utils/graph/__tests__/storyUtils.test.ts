import { describe, it, expect } from 'vitest';
import { getStoryNodes } from '../storyUtils';
import { Graph, NodeType, NarrativeNode, ActionNode } from '../../../types';

function makeStoryGraph(): Graph {
  return {
    nodeLookup: {
      0: { nodeId: 0, data: "Once upon a time...", childrenIds: [1, 2], type: NodeType.Narrative, isEnding: false } as NarrativeNode,
      1: { nodeId: 1, data: "Go left", childrenIds: [3], type: NodeType.Action } as ActionNode,
      2: { nodeId: 2, data: "Go right", childrenIds: [4], type: NodeType.Action } as ActionNode,
      3: { nodeId: 3, data: "You went left.", childrenIds: [], type: NodeType.Narrative, isEnding: true } as NarrativeNode,
      4: { nodeId: 4, data: "You went right.", childrenIds: [], type: NodeType.Narrative, isEnding: false } as NarrativeNode,
    },
  };
}

describe('getStoryNodes', () => {
  it('returns empty for empty graph', () => {
    expect(getStoryNodes({ nodeLookup: {} }, true)).toEqual([]);
  });

  it('produces correct section count', () => {
    const story = getStoryNodes(makeStoryGraph(), false);
    // 3 narrative nodes = 3 sections
    expect(story).toHaveLength(3);
  });

  it('assigns sequential section IDs', () => {
    const story = getStoryNodes(makeStoryGraph(), false);
    expect(story[0].sectionId).toBe(1);
    expect(story[1].sectionId).toBe(2);
    expect(story[2].sectionId).toBe(3);
  });

  it('extracts actions for narrative nodes', () => {
    const story = getStoryNodes(makeStoryGraph(), false);
    // Root node has 2 action children
    expect(story[0].actions).toEqual(["Go left", "Go right"]);
  });

  it('marks ending nodes', () => {
    const story = getStoryNodes(makeStoryGraph(), false);
    const endingNode = story.find(n => n.paragraph === "You went left.");
    expect(endingNode?.isEnding).toBe(true);
  });

  it('resolves children section IDs', () => {
    const story = getStoryNodes(makeStoryGraph(), false);
    // Root's childrenSectionIds should point to sections 2 and 3
    expect(story[0].childrenSectionIds).toEqual([2, 3]);
  });
});
