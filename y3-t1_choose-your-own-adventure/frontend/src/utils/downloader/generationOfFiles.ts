import { Packer } from "docx";
import saveAs from "file-saver";
import { StoryNode } from "../graph/types";
import { ShuffledList, shuffleList } from "../shuffledLists";
import { createDocx } from "./docxUtils";
import { parseStoryToText } from "./txtUtils";


export const generateTxtFile = (
  story: StoryNode[],
  storyTitle: string,
  shuffle = false
): void => {
  let indexCache = [0];

  if (shuffle && story.length > 0) {
    story = shuffleStory(story).list;
    const shuffledStory = shuffleStory(story);
    story = shuffledStory.list;
    indexCache = shuffledStory.indexCache;
  }

  const text: string[] = parseStoryToText(story, indexCache);

  const element = document.createElement("a");
  const file = new Blob(text, { type: 'text/plain' });
  element.href = URL.createObjectURL(file);
  element.download = `${storyTitle}.txt`;
  document.body.appendChild(element);
  element.click();
  document.body.removeChild(element);
};


export const generateDocxFile = (
  story: StoryNode[],
  storyTitle: string,
  shuffle = false
): void => {
  let indexCache = [0];

  if (shuffle && story.length > 0) {
    const shuffledStory = shuffleStory(story);
    story = shuffledStory.list;
    indexCache = shuffledStory.indexCache;
  }

  const doc = createDocx(story, indexCache);

  Packer
    .toBlob(doc)
    .then((blob: Blob) => {
      saveAs(blob, `${storyTitle}.docx`);
    });
}


const shuffleStory = (story: StoryNode[]): ShuffledList<StoryNode> => {
  if (story.length <= 1) {
    return {
      list: story,
      // Index cache will not be used for story length <= 1
      indexCache: [],
    };
  }

  const head = story[0];
  const tail = story.slice(1, story.length);

  const shuffledList = shuffleList(tail);

  const newTail = shuffledList.list;
  // + 1 to make space for Head
  const cache = shuffledList.indexCache.map(i => i + 1);

  return {
    list: [head].concat(newTail),
    // Head is not shuffled
    indexCache: [0].concat(cache),
  };
};