import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { connectNodesOnGraph, deleteEdgeOnGraph, deleteNodeFromGraph, findParent, isGraphEmpty, isNarrative } from '../../utils/graph/graphUtils';
import { Graph, LoadingType, NarrativeNode } from '../../utils/graph/types';
import { RootState } from '../store';
import { handleGetGraphFulfilled, handleInitStoryFulfilled, handleSaveGraphFulfilled, handleSaveGraphPending, handleSaveNameFulfilled, handleSaveNamePending } from './story/thunkHandlers';
import { displayErrorUpdate, displayGenerateManyLoadingNotification, displayGenerateManyUpdate, displayLoadedNotification, displayLoadingNotification, LoadingUpdate } from './story/Notifications';
import { getGraphThunk, initStoryThunk, regenerateActionsThunk, regenerateEndingThunk, regenerateManyThunk, regenerateParagraphThunk, saveGraphThunk, saveNameThunk } from './story/thunks';


export interface StoryState {
  id: string;
  title: string;
  graph: Graph;
  graphWasLoaded: boolean;
  activeNodeId: number;

  generateManyDepth: number,
  numActionsToAdd: number,
  temperature: number;
  descriptor: string;
  details: string;
  style: string;

  loadingType: LoadingType | null;
  numOfEdits: number,

  goToGenerator: boolean;
};

const initialState: StoryState = {
  id: "",
  title: "",
  graph: { nodeLookup: {} },
  graphWasLoaded: false,
  activeNodeId: 0,

  generateManyDepth: 2,
  numActionsToAdd: 2,
  temperature: 0.6,
  descriptor: "",
  details: "",
  style: "",

  loadingType: null,
  numOfEdits: 0,

  goToGenerator: false,
};


export const regenerateParagraph = regenerateParagraphThunk;
export const regenerateActions = regenerateActionsThunk;
export const regenerateEnding = regenerateEndingThunk;
export const regenerateMany = regenerateManyThunk;
export const getGraph = getGraphThunk;
export const initStory = initStoryThunk;
export const saveGraph = saveGraphThunk;
export const saveName = saveNameThunk;


export const storySlice = createSlice({
  name: 'story',
  initialState,
  reducers: {
    reset: () => initialState,
    setName: (state, action: PayloadAction<string>) => {
      state.title = action.payload;
    },
    setGraph: (state, action: PayloadAction<Graph>) => {
      state.graph = action.payload;
    },
    deleteNode: (state, action: PayloadAction<number>) => {
      state.activeNodeId = findParent(state.graph, action.payload) || 0;
      state.graph = deleteNodeFromGraph(state.graph, action.payload, true);
    },
    deleteChildNodes: (state, action: PayloadAction<number>) => {
      state.graph = deleteNodeFromGraph(state.graph, action.payload, false);
    },
    setNodeData: (state, action: PayloadAction<{ nodeId: number, data: string }>) => {
      state.graph.nodeLookup[action.payload.nodeId].data = action.payload.data;
    },
    setEnding: (state, action: PayloadAction<{ nodeId: number, isEnding: boolean }>) => {
      (state.graph.nodeLookup[action.payload.nodeId] as NarrativeNode).isEnding
        = action.payload.isEnding;
    },
    setId: (state, action: PayloadAction<{ storyId: string }>) => {
      state.id = action.payload.storyId;
    },
    setGoToGenerator: (state, action: PayloadAction<boolean>) => {
      state.goToGenerator = action.payload;
    },
    setNumActionsToAdd: (state, action: PayloadAction<number>) => {
      state.numActionsToAdd = action.payload;
    },
    setGenerateManyDepth: (state, action: PayloadAction<number>) => {
      state.generateManyDepth = action.payload;
    },
    setTemperature: (state, action: PayloadAction<number>) => {
      state.temperature = action.payload;
    },
    setDescriptor: (state, action: PayloadAction<string>) => {
      state.descriptor = action.payload;
    },
    setDetails: (state, action: PayloadAction<string>) => {
      state.details = action.payload;
    },
    setStyle: (state, action: PayloadAction<string>) => {
      state.style = action.payload;
    },
    setActiveNodeId: (state, action: PayloadAction<number>) => {
      state.activeNodeId = action.payload;
    },
    connectNodes: (state, action: PayloadAction<{ fromNode: number, toNode: number }>) => {
      const fromData = state.graph.nodeLookup[action.payload.fromNode];
      if (isNarrative(fromData) && (fromData as NarrativeNode).isEnding)
        return; // can't connect ending
      state.graph = connectNodesOnGraph(state.graph, action.payload.fromNode, action.payload.toNode);
    },
    deleteEdge: (state, action: PayloadAction<{ fromNode: number, toNode: number }>) => {
      state.graph = deleteEdgeOnGraph(state.graph, action.payload.fromNode, action.payload.toNode);
    },
    incrementNumOfEdits: (state) => {
      state.numOfEdits += 1;
    },
    decrementNumOfEdits: (state) => {
      state.numOfEdits -= 1;
    },
    resetNumOfEdits: (state) => {
      state.numOfEdits = 0;
    },


    /****************************************************************
    **** Reducers for the WS middleware.
    ****************************************************************/

    requestComplete: (state) => {
      if (state.loadingType !== null) {
        displayLoadedNotification(state.loadingType);
        state.loadingType = null;
      }
    },
    progressUpdate: (state, action: PayloadAction<LoadingUpdate>) => {
      if (state.loadingType !== null) {
        displayGenerateManyUpdate(action.payload);
      };
    },
    openAIError: (state) => {
      if (state.loadingType !== null) {
        displayErrorUpdate("Open AI Unavailable Error");
        state.loadingType = null;
      }
    },
    rateLimitError: (state) => {
      if (state.loadingType !== null) {
        displayErrorUpdate(
          "Open AI Rate Limit Error",
          "Please wait for a few seconds and try again..."
        );
        state.loadingType = null;
      }
    },
    nlpParseError: (state) => {
      if (state.loadingType !== null) {
        displayErrorUpdate(
          "Failed to Generate",
          "Try changing the previous text or creativity and generating again..."
        );
        state.loadingType = null;
      }
    },
    disconnectedError: (state) => {
      if (state.loadingType !== null) {
        displayErrorUpdate("Server Disconnection Error");
        state.loadingType = null;
      }
    },


    /****************************************************************
    **** Story Generation.
    ****************************************************************/

    generateInitialStoryBasic: (state, _action: PayloadAction<{ prompt: string }>) => {
      state.loadingType = LoadingType.InitialStory;
      displayLoadingNotification(LoadingType.InitialStory);
    },
    generateInitialStoryAdvanced: (state, _action: PayloadAction<{
      values: { attribute: string, content: string }[]
    }>) => {
      state.loadingType = LoadingType.InitialStory;
    },
    generateParagraph: (state, _action: PayloadAction<{ nodeToExpand: number }>) => {
      state.loadingType = LoadingType.GenerateParagraph;
      displayLoadingNotification(LoadingType.GenerateParagraph);
    },
    generateActions: (state, _action: PayloadAction<{ nodeToExpand: number }>) => {
      state.loadingType = LoadingType.GenerateActions;
      displayLoadingNotification(LoadingType.GenerateActions);
    },
    generateNewAction: (state, _action: PayloadAction<{ nodeToExpand: number }>) => {
      state.loadingType = LoadingType.GenerateNewAction;
      displayLoadingNotification(LoadingType.GenerateNewAction);
    },
    generateEnding: (state, _action: PayloadAction<{ nodeToEnd: number }>) => {
      state.loadingType = LoadingType.GenerateEnding;
      displayLoadingNotification(LoadingType.GenerateEnding);
    },
    connectNodesWithMiddle: (state, _action: PayloadAction<{ fromNode: number, toNode: number }>) => {
      const fromData = state.graph.nodeLookup[_action.payload.fromNode];
      if (isNarrative(fromData) && (fromData as NarrativeNode).isEnding) return; // can't connect ending

      state.loadingType = LoadingType.ConnectingNodes;
      displayLoadingNotification(LoadingType.ConnectingNodes);
    },
    generateMany: (state, _action: PayloadAction<{ fromNode: number }>) => {
      state.loadingType = LoadingType.GenerateMany;
      displayGenerateManyLoadingNotification();
    },
  },
  extraReducers: (builder) => {
    builder.addCase(getGraph.fulfilled, handleGetGraphFulfilled);

    builder.addCase(initStory.fulfilled, handleInitStoryFulfilled);

    builder.addCase(saveGraph.pending, handleSaveGraphPending);
    builder.addCase(saveGraph.fulfilled, handleSaveGraphFulfilled);

    builder.addCase(saveName.pending, handleSaveNamePending);
    builder.addCase(saveName.fulfilled, handleSaveNameFulfilled);
  },
});

export const {
  reset,
  setGraph,
  setName,
  deleteNode,
  deleteChildNodes,
  setNodeData,
  setEnding,
  setId,
  setGoToGenerator,
  setNumActionsToAdd,
  setGenerateManyDepth,
  setTemperature,
  setDescriptor,
  setDetails,
  setStyle,
  setActiveNodeId,
  incrementNumOfEdits,
  decrementNumOfEdits,
  resetNumOfEdits,

  requestComplete,
  progressUpdate,
  openAIError,
  rateLimitError,
  nlpParseError,
  disconnectedError,

  generateInitialStoryBasic,
  generateInitialStoryAdvanced,
  generateParagraph,
  generateActions,
  generateNewAction,
  generateEnding,
  connectNodes,
  deleteEdge,
  connectNodesWithMiddle,
  generateMany,
} = storySlice.actions;


export const selectGoToGenerator = (state: RootState) => state.story.goToGenerator;
export const selectStoryGraph = (state: RootState) => state.story.graph;
export const selectStoryGraphWasLoaded = (state: RootState) => state.story.graphWasLoaded;
export const selectStoryIsEmpty = (state: RootState) => isGraphEmpty(state.story.graph);
export const selectStoryId = (state: RootState) => state.story.id;
export const selectStoryTitle = (state: RootState) => state.story.title;
export const selectLoadingType = (state: RootState) => state.story.loadingType;
export const selectGraphIsLoading = (state: RootState) => state.story.loadingType !== null;
export const selectGraphIsBeingEdited = (state: RootState) => state.story.numOfEdits !== 0;
export const selectActiveNodeId = (state: RootState) => state.story.activeNodeId;
export const selectNumActionsToAdd = (state: RootState) => state.story.numActionsToAdd;
export const selectGenerateManyDepth = (state: RootState) => state.story.generateManyDepth;


export default storySlice.reducer;
