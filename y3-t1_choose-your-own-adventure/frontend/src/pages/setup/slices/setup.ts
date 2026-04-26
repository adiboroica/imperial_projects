/**
 * Setup slice — form state for the new-story page plus the `startStory` thunk.
 */

import {
  createAsyncThunk,
  createSlice,
  type PayloadAction,
} from "@reduxjs/toolkit";

import { generation, stories } from "../../../api";
import type { Graph } from "../../../types";

export type AttributeRow = { attribute: string; content: string };

export type SetupState = {
  genre: string;
  values: AttributeRow[];
  submitting: boolean;
  error: string | null;
};

const initialState: SetupState = {
  genre: "",
  values: [
    { attribute: "themes", content: "" },
    { attribute: "characters", content: "" },
    { attribute: "items", content: "" },
  ],
  submitting: false,
  error: null,
};

// ---------- Thunks ----------

export type StartStoryResult = {
  storyId: string;
  graph: Graph;
};

export const startStory = createAsyncThunk<StartStoryResult, void>(
  "setup/startStory",
  async (_, { getState, rejectWithValue }) => {
    const state = (getState() as { setup: SetupState }).setup;
    try {
      const created = await stories.create();
      const attributes: Record<string, string> = {};
      for (const row of state.values) {
        if (row.attribute && row.content) attributes[row.attribute] = row.content;
      }
      // Default temperature for the initial seed; the generator page owns its own.
      const graph = await generation.generateInitial(
        state.genre || "adventure",
        attributes,
        0.6,
      );
      // Persist immediately so a refresh doesn't lose the seed.
      await stories.saveGraph(created.id, graph);
      return { storyId: created.id, graph };
    } catch (err) {
      return rejectWithValue(err instanceof Error ? err.message : "Failed");
    }
  },
);

// ---------- Slice ----------

const slice = createSlice({
  name: "setup",
  initialState,
  reducers: {
    setGenre(state, action: PayloadAction<string>) {
      state.genre = action.payload;
    },
    setAttribute(
      state,
      action: PayloadAction<{ position: number; data: string }>,
    ) {
      const row = state.values[action.payload.position];
      if (row) row.attribute = action.payload.data;
    },
    setContent(
      state,
      action: PayloadAction<{ position: number; data: string }>,
    ) {
      const row = state.values[action.payload.position];
      if (row) row.content = action.payload.data;
    },
    addEntry(state) {
      state.values.push({ attribute: "", content: "" });
    },
    removeEntry(state, action: PayloadAction<{ position: number }>) {
      state.values.splice(action.payload.position, 1);
    },
    resetForm: () => initialState,
  },
  extraReducers: (builder) => {
    builder
      .addCase(startStory.pending, (state) => {
        state.submitting = true;
        state.error = null;
      })
      .addCase(startStory.fulfilled, () => initialState)
      .addCase(startStory.rejected, (state, action) => {
        state.submitting = false;
        state.error = (action.payload as string) ?? "Failed to start story";
      });
  },
});

export const {
  setGenre,
  setAttribute,
  setContent,
  addEntry,
  removeEntry,
  resetForm,
} = slice.actions;
export default slice.reducer;

// ---------- Selectors ----------

import type { RootState } from "../../../store/store";

export const selectSetupGenre = (s: RootState) => s.setup.genre;
export const selectSetupValues = (s: RootState) => s.setup.values;
export const selectSetupSubmitting = (s: RootState) => s.setup.submitting;
export const selectSetupError = (s: RootState) => s.setup.error;
