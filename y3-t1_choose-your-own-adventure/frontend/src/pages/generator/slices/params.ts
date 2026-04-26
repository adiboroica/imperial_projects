/**
 * Generator params slice — generation knobs (temperature, depth, action count, …).
 */

import { createSlice, type PayloadAction } from "@reduxjs/toolkit";

export type ParamsState = {
  temperature: number;
  descriptor: string;
  details: string;
  style: string;
  generateManyDepth: number;
  numActionsToAdd: number;
};

const initialState: ParamsState = {
  temperature: 0.6,
  descriptor: "",
  details: "",
  style: "",
  generateManyDepth: 2,
  numActionsToAdd: 2,
};

const slice = createSlice({
  name: "params",
  initialState,
  reducers: {
    setTemperature(state, action: PayloadAction<number>) {
      state.temperature = Math.max(0, Math.min(1, action.payload));
    },
    setDescriptor(state, action: PayloadAction<string>) {
      state.descriptor = action.payload;
    },
    setDetails(state, action: PayloadAction<string>) {
      state.details = action.payload;
    },
    setStyle(state, action: PayloadAction<string>) {
      state.style = action.payload;
    },
    setGenerateManyDepth(state, action: PayloadAction<number>) {
      state.generateManyDepth = Math.max(0, action.payload);
    },
    setNumActionsToAdd(state, action: PayloadAction<number>) {
      state.numActionsToAdd = Math.max(1, action.payload);
    },
    resetParams: () => initialState,
  },
});

export const {
  setTemperature,
  setDescriptor,
  setDetails,
  setStyle,
  setGenerateManyDepth,
  setNumActionsToAdd,
  resetParams,
} = slice.actions;

export default slice.reducer;

// ---------- Selectors ----------

import type { RootState } from "../../../store/store";

export const selectParams = (s: RootState) => s.params;
export const selectTemperature = (s: RootState) => s.params.temperature;
export const selectDescriptor = (s: RootState) => s.params.descriptor;
export const selectDetails = (s: RootState) => s.params.details;
export const selectStyle = (s: RootState) => s.params.style;
export const selectGenerateManyDepth = (s: RootState) =>
  s.params.generateManyDepth;
export const selectNumActionsToAdd = (s: RootState) =>
  s.params.numActionsToAdd;
