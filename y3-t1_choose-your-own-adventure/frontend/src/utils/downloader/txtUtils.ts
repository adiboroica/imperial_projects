import { StoryNode } from "../graph/types";

// Max chars per line
const MAX_CHARS = 80

/*
  boxString("Hello world!")
  return:
+------------------------------------------------------------------------------+
| Hello world!                                                                 |
+------------------------------------------------------------------------------+
*/
export function boxString(str: String): string {
  let box = "+".padEnd(MAX_CHARS - 1, "-") + "+\n";
  box += `| ${str}`.padEnd(MAX_CHARS - 1, " ") + "|\n";
  box += "+".padEnd(MAX_CHARS - 1, "-") + "+";
  return box;
}

export function getShuffledId(id: number, indexCache: number[]): number {
  // Translating between 1-index and 0-index
  return indexCache[id - 1] + 1;
}

export const parseStoryToText
  = (story: StoryNode[], indexCache: number[]): string[] => {
  const text: string[] = [];

  for (const node of story) {
    let textSection: string = "";

    // Section title
    textSection += `${boxString(`Section ${getShuffledId(node.sectionId, indexCache)}`)}\n\n`;

    // Section paragraph
    textSection += `${node.paragraph}\n\n`;

    // Section actions
    const numChoices = node.actions.length;

    if (numChoices) {
      textSection += `You have ${numChoices} choices:\n`;
      for (let i = 0; i < numChoices; i++) {
        textSection += `  - ${node.actions[i]}\n`;

        const sectionId = node.childrenSectionIds[i];

        if (sectionId !== null) {
          textSection += `    [Go to Section ${getShuffledId(sectionId, indexCache)}]\n`;
        }
      }

      textSection += "\n\n";
    } else if (node.childrenIds.length > 0) {
      // Narrative node connected to narrative node
      // assert node.childrenIds.length === 1

      const sectionId = story.find((storyNode) => storyNode.nodeId === node.childrenIds[0])!.sectionId;
      textSection += `    [Go to Section ${getShuffledId(sectionId, indexCache)}]\n`;
    }

    text.push(textSection);
  }

  return text;
};
