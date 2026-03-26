import {
  createAsyncThunk
} from '@reduxjs/toolkit';
import {
  reqGetStory,
  reqInitStory,
  reqSaveGraph,
  reqSaveName
} from '../../../api/story/storyRequests';
import { GraphMessage } from '../../../utils/graph/types';
import { loadStories } from '../accountSlice';
import {
  deleteChildNodes,
  generateActions,
  generateEnding,
  generateMany,
  generateParagraph,
  setGoToGenerator,
  setId,
  StoryState
} from '../storySlice';



export const regenerateParagraphThunk = createAsyncThunk(
  'story/regenerateParagraph',
  async (nodeToRegenerate: number, { dispatch }) => {
    dispatch(deleteChildNodes(nodeToRegenerate));
    dispatch(generateParagraph({ nodeToExpand: nodeToRegenerate }));
  }
);


export const regenerateActionsThunk = createAsyncThunk(
  'story/regenerateActions',
  async (nodeToRegenerate: number, { dispatch }) => {
    dispatch(deleteChildNodes(nodeToRegenerate));
    dispatch(generateActions({ nodeToExpand: nodeToRegenerate }));
  }
);


export const regenerateEndingThunk = createAsyncThunk(
  'story/regenerateParagraph',
  async (nodeToEnd: number, { dispatch }) => {
    dispatch(deleteChildNodes(nodeToEnd));
    dispatch(generateEnding({ nodeToEnd: nodeToEnd }));
  }
);


type regenerateManyThunkProps = {
  fromNode: number,
};
export const regenerateManyThunk = createAsyncThunk(
  'story/regenerateMany',
  async (props: regenerateManyThunkProps, { dispatch }) => {
    dispatch(deleteChildNodes(props.fromNode));
    dispatch(generateMany({ ...props }));
  }
);


export const saveNameThunk = createAsyncThunk(
  'story/saveName',
  async (_, { getState }) => {
    const state = getState() as { story: StoryState };
    await reqSaveName(state.story.id, state.story.title);
  }
);


export const saveGraphThunk = createAsyncThunk(
  'story/saveGraph',
  async (_, { getState }) => {
    const state = getState() as { story: StoryState };
    await reqSaveGraph(state.story.id, state.story.graph);
  }
);


type getGraphThunkProps = {
  storyId: string,
};
export const getGraphThunk = createAsyncThunk(
  'story/getGraph',
  async (props: getGraphThunkProps) => {
    const response = await reqGetStory(props.storyId);
    const json = await response.json() as { story: GraphMessage, name: string };

    // TODO should refactor backend to use graph consistently
    return { 
      graph: json.story, 
      name: json.name,
      storyId: props.storyId,
    };
  }
);


export const initStoryThunk = createAsyncThunk(
  'account/initStory',
  async (_, { dispatch }) => {
    const response = await reqInitStory();
    const json = await response.json() as { storyId: string };

    dispatch(loadStories());

    dispatch(setId({ storyId: json.storyId }));

    dispatch(setGoToGenerator(true));

    return { 
      storyId: json.storyId 
    };
  }
);
