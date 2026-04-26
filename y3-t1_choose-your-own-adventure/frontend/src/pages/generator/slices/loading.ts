/**
 * Generator loading slice — tracks in-flight WS-driven thunks by `requestId`.
 *
 * State shape:
 *
 *     inflight: Record<requestId, LoadingType>
 *
 * Each graph thunk's `pending` action automatically populates an entry under
 * RTK's auto-generated `meta.requestId`; the matching `fulfilled` or
 * `rejected` action removes it. The exposed actions (`wsRequestStarted`,
 * `wsRequestSettled`) let middleware and tests dispatch entries manually.
 *
 * `selectIsLoading(type)` returns `true` when any entry matches the queried
 * type — wire that into a button's `disabled` prop, a global spinner, etc.
 */

import { createSlice, type PayloadAction } from "@reduxjs/toolkit";

import { LoadingType } from "../../../types";

export type LoadingState = {
  inflight: Record<string, LoadingType>;
};

const initialState: LoadingState = {
  inflight: {},
};

/** Maps each thunk's pending action type → the user-facing LoadingType. */
const PENDING_TO_LOADING: Record<string, LoadingType> = {
  "graph/getStory/pending": LoadingType.SaveStory,
  "graph/saveGraph/pending": LoadingType.SaveStory,
  "graph/updateStoryName/pending": LoadingType.SaveName,
  "graph/generateInitial/pending": LoadingType.InitialStory,
  "graph/generateActions/pending": LoadingType.GenerateActions,
  "graph/addAction/pending": LoadingType.GenerateNewAction,
  "graph/generateNarrative/pending": LoadingType.GenerateParagraph,
  "graph/connectNodesWithBridge/pending": LoadingType.ConnectingNodes,
  "graph/generateMany/pending": LoadingType.GenerateMany,
};

const TERMINAL_SUFFIXES = ["/fulfilled", "/rejected"];

const slice = createSlice({
  name: "loading",
  initialState,
  reducers: {
    /** Mark a request as in flight. */
    wsRequestStarted(
      state,
      action: PayloadAction<{ requestId: string; type: LoadingType }>,
    ) {
      state.inflight[action.payload.requestId] = action.payload.type;
    },
    /** Remove a request from the in-flight set. Idempotent. */
    wsRequestSettled(
      state,
      action: PayloadAction<{ requestId: string }>,
    ) {
      delete state.inflight[action.payload.requestId];
    },
    /** Clear every in-flight entry. */
    clearLoading(state) {
      state.inflight = {};
    },
  },
  extraReducers: (builder) => {
    // Auto-track all graph thunks via RTK's `meta.requestId`.
    builder.addMatcher(
      (action): action is { type: string; meta: { requestId: string } } => {
        const a = action as { type?: unknown; meta?: { requestId?: unknown } };
        return (
          typeof a.type === "string" &&
          a.type in PENDING_TO_LOADING &&
          typeof a.meta?.requestId === "string"
        );
      },
      (state, action) => {
        state.inflight[action.meta.requestId] = PENDING_TO_LOADING[action.type];
      },
    );
    builder.addMatcher(
      (action): action is { type: string; meta: { requestId: string } } => {
        const a = action as { type?: unknown; meta?: { requestId?: unknown } };
        const t = a.type;
        if (typeof t !== "string") return false;
        if (typeof a.meta?.requestId !== "string") return false;
        return TERMINAL_SUFFIXES.some((suffix) => {
          if (!t.endsWith(suffix)) return false;
          const pendingKey = `${t.slice(0, -suffix.length)}/pending`;
          return pendingKey in PENDING_TO_LOADING;
        });
      },
      (state, action) => {
        delete state.inflight[action.meta.requestId];
      },
    );
  },
});

export const { wsRequestStarted, wsRequestSettled, clearLoading } = slice.actions;
export default slice.reducer;

// ---------- Selectors ----------

import type { RootState } from "../../../store/store";

/** Map of in-flight requestId → LoadingType. */
export const selectInflight = (s: RootState) => s.loading.inflight;

/** True when any request is in flight. */
export const selectIsLoading = (s: RootState) =>
  Object.keys(s.loading.inflight).length > 0;

/** True when any request of the queried type is in flight. */
export const selectIsLoadingType =
  (type: LoadingType) =>
  (s: RootState): boolean =>
    Object.values(s.loading.inflight).includes(type);

/** Convenience selector for the FIRST in-flight type (UI label uses this). */
export const selectLoadingType = (s: RootState): LoadingType | null => {
  const values = Object.values(s.loading.inflight);
  return values.length > 0 ? values[0] : null;
};
