import { Queue } from "queue-typescript";
import { isAction } from "./graphUtils";
import {
  Graph,
  NarrativeNode,
  NodeData,
  NodeId,
  SectionIdOrNull,
  StoryNode
} from "./types";


export const getStoryNodes = (storyGraph: Graph, graphEmpty: boolean): StoryNode[] => {

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
      // Just recurse since we already added the action text.
      for (const childId of currNode.childrenIds) {
        const child = nodeLookup[childId];
        queue.enqueue(child);
      }
    } else {
      narrativeNodeCount++;

      const narrativeNode = (currNode as NarrativeNode)

      const actions: string[] = [];
      const childrenSectionIds: SectionIdOrNull[] = [];

      // Note: For loops are much faster than functional programming in Node.js
      for (const childId of narrativeNode.childrenIds) {
        const child = nodeLookup[childId];
        queue.enqueue(child);

        if (isAction(child)) {
          actions.push(child.data);

          // Find section that action points to
          if (child.childrenIds.length > 0) {
            // Each action will correspond to 1 child only
            const childOfAction = nodeLookup[child.childrenIds[0]];

            // Verify that action points to a paragraph.
            if (!isAction(childOfAction)) {
              const childParagraph = childOfAction as NarrativeNode;
              // Temporarily assign nodeId instead of sectionId, since
              // sectionId has not been assigned to all sections.
              childrenSectionIds.push(childParagraph.nodeId);
            }
          } else {
            // Section has not been generated yet.
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
          childrenSectionIds: childrenSectionIds,
          isEnding: narrativeNode.isEnding,
        });
      }
    }
  }

  // Update the node ids to be section ids.
  for (const paragraphNode of story) {
    const updateIds: SectionIdOrNull[] = [];

    for (const id of paragraphNode.childrenSectionIds) {
      if (id == null) {
        updateIds.push(null);
      } else {
        const paragraphChildNode = story.find((node) => {
          return node.nodeId === id;
        });

        if (paragraphChildNode) {
          updateIds.push(paragraphChildNode.sectionId);
        }
      }
    }

    paragraphNode.childrenSectionIds = updateIds;
  }

  return story;
}