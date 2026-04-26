/**
 * Dashboard slice — story-list state and the `listStories` / `deleteStory` thunks.
 */

import {
  createAsyncThunk,
  createSlice,
} from "@reduxjs/toolkit";

import { stories } from "../../../api";
import type { StoryListItem } from "../../../types";

export type DashboardState = {
  stories: StoryListItem[];
  loading: boolean;
  error: string | null;
};

const initialState: DashboardState = {
  stories: [],
  loading: false,
  error: null,
};

// ---------- Thunks ----------

export const listStories = createAsyncThunk(
  "dashboard/listStories",
  async () => stories.list(),
);

/** Pessimistic delete: only remove from state on `fulfilled`. */
export const deleteStory = createAsyncThunk(
  "dashboard/deleteStory",
  async (storyId: string) => {
    await stories.delete(storyId);
    return storyId;
  },
);

// ---------- Slice ----------

const slice = createSlice({
  name: "dashboard",
  initialState,
  reducers: {
    clearDashboardError(state) {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(listStories.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(listStories.fulfilled, (state, action) => {
        state.loading = false;
        state.stories = action.payload;
      })
      .addCase(listStories.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message ?? "Failed to load stories";
      })
      .addCase(deleteStory.fulfilled, (state, action) => {
        state.stories = state.stories.filter((s) => s.id !== action.payload);
      })
      .addCase(deleteStory.rejected, (state, action) => {
        state.error = action.error.message ?? "Failed to delete story";
      });
  },
});

export const { clearDashboardError } = slice.actions;
export default slice.reducer;

// ---------- Selectors ----------

import type { RootState } from "../../../store/store";

export const selectDashboardStories = (s: RootState) => s.dashboard.stories;
export const selectDashboardLoading = (s: RootState) => s.dashboard.loading;
export const selectDashboardError = (s: RootState) => s.dashboard.error;
