import { createAsyncThunk } from "@reduxjs/toolkit";
import { InitialInputState } from "../initialInputSlice";
import { generateInitialStoryAdvanced } from "../storySlice";


export const generateInitialStoryThunk = createAsyncThunk(
  "initialInput/generateInitialStory",
  async (_, { getState, dispatch }) => {
    const state = getState() as { initialInput: InitialInputState };
    
    dispatch(generateInitialStoryAdvanced({ values: state.initialInput.values }));
  }
);