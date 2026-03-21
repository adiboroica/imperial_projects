import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { RootState } from "../store";
import { generateInitialStoryThunk } from "./initialInput/thunks";


export interface InitialInputState {
  values: { attribute: string, content: string }[]
}

const initialState: InitialInputState = {
  values: [
    { attribute: "themes", content: "" },
    { attribute: "characters", content: "" },
    { attribute: "items", content: "" }
  ],
};


export const generateInitialStory = generateInitialStoryThunk;


export const initialInputSlice = createSlice({
  name: "initialInput",
  initialState,
  reducers: {
    setAttribute: (state, action: PayloadAction<{ position: number, data: string }>) => {
      state.values[action.payload.position] = {
        attribute: action.payload.data,
        content: state.values[action.payload.position].content
      }
    },
    setContent: (state, action: PayloadAction<{ position: number, data: string }>) => {
      state.values[action.payload.position] = {
        attribute: state.values[action.payload.position].attribute,
        content: action.payload.data
      }
    },
    removeEntry: (state, action: PayloadAction<{ position: number }>) => {
      state.values.splice(action.payload.position, 1)
    },
    addEntry: (state) => {
      state.values.push({ attribute: "", content: "" })
    },
  }
});

export const {
  setAttribute,
  setContent,
  removeEntry,
  addEntry
} = initialInputSlice.actions;


export const selectInitialInputValues = (state: RootState) => state.initialInput.values;


export default initialInputSlice.reducer;