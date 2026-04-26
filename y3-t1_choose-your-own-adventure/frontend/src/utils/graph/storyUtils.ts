import { Queue } from "queue-typescript";

import {
  Graph,
  NarrativeNode,
  NodeData,
  NodeId,
  SectionIdOrNull,
  StoryNode,
} from "../../types";
import { isAction } from "./graphUtils";

export const getStoryNodes = (
  storyGraph: Graph,
  graphEmpty: boolean,
): StoryNode[] => {
  if (graphEmpty) return [];

  const nodeLookup = storyGraph.nodeLookup;
  const story: StoryNode[] = [];
  const queue = new Queue<NodeData>(nodeLookup[0]);
  const visited = new Set<NodeId>();
  let narrativeNodeCount = 0;

  while (queue.length !== 0) {
    const currNode = queue.dequeue();
    if (currNode === undefined || visited.has(currNode.nodeId)) continue;
    visited.add(currNode.nodeId);

    if (isAction(currNode)) {
      for (const childId of currNode.childrenIds) {
        const child = nodeLookup[childId];
        if (child) queue.enqueue(child);
      }
    } else {
      narrativeNodeCount += 1;
      const narrativeNode = currNode as NarrativeNode;
      const actions: string[] = [];
      const childrenSectionIds: SectionIdOrNull[] = [];

      for (const childId of narrativeNode.childrenIds) {
        const child = nodeLookup[childId];
        if (!child) continue;
        queue.enqueue(child);

        if (isAction(child)) {
          actions.push(child.data);
          if (child.childrenIds.length > 0) {
            const childOfAction = nodeLookup[child.childrenIds[0]];
            if (childOfAction && !isAction(childOfAction)) {
              const childParagraph = childOfAction as NarrativeNode;
              childrenSectionIds.push(childParagraph.nodeId);
            }
          } else {
            childrenSectionIds.push(null);
          }
        }
      }

      if (narrativeNode.data !== null) {
        story.push({
          paragraph: narrativeNode.data,
          actions,
          nodeId: narrativeNode.nodeId,
          sectionId: narrativeNodeCount,
          childrenIds: narrativeNode.childrenIds,
          childrenSectionIds,
          isEnding: narrativeNode.isEnding,
        });
      }
    }
  }

  // Re-map node ids to section ids.
  for (const paragraphNode of story) {
    const updateIds: SectionIdOrNull[] = [];
    for (const id of paragraphNode.childrenSectionIds) {
      if (id === null || id === undefined) {
        updateIds.push(null);
      } else {
        const paragraphChildNode = story.find((node) => node.nodeId === id);
        updateIds.push(paragraphChildNode?.sectionId ?? null);
      }
    }
    paragraphNode.childrenSectionIds = updateIds;
  }

  return story;
};
