import { PayloadAction } from "@reduxjs/toolkit";
import { graphMessageToGraphLookup } from "../../../utils/graph/graphUtils";
import { GraphMessage, LoadingType } from "../../../utils/graph/types";
import { StoryState } from "../storySlice";
import { displayLoadedNotification, displayLoadingNotification } from "./Notifications";


export const handleGetGraphFulfilled = (
  state: StoryState,
  action: PayloadAction<{ graph: GraphMessage, name: string, storyId: string }>
) => {
  state.graph = graphMessageToGraphLookup(action.payload.graph);
  state.graphWasLoaded = true;
  state.title = action.payload.name;
  state.id = action.payload.storyId;

  state.loadingType = null;
};


export const handleInitStoryFulfilled = (
  state: StoryState,
  action: PayloadAction<{ storyId: string }>
) => {
  state.graphWasLoaded = true;
  state.id = action.payload.storyId;
};


export const handleSaveGraphPending = (state: StoryState) => {
  state.loadingType = LoadingType.SaveStory;
  displayLoadingNotification(state.loadingType);
}
export const handleSaveGraphFulfilled = (state: StoryState) => {
  state.loadingType = null;
  displayLoadedNotification(LoadingType.SaveStory);
}


export const handleSaveNamePending = (state: StoryState) => {
  state.loadingType = LoadingType.SaveName;
  displayLoadingNotification(state.loadingType);
}
export const handleSaveNameFulfilled = (state: StoryState) => {
  state.loadingType = null;
  displayLoadedNotification(LoadingType.SaveName);
}