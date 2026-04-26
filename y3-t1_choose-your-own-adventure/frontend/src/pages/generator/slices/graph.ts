/**
 * Generator graph slice — owns the in-memory `Graph` plus the WS-driven thunks
 * that mutate it.
 */

import {
  createAsyncThunk,
  createSlice,
  type PayloadAction,
} from "@reduxjs/toolkit";

import { generation, stories } from "../../../api";
import type { Graph, NarrativeNode } from "../../../types";
import { isNarrativeNode, NodeType } from "../../../types";
import {
  connectNodesOnGraph,
  deleteEdgeOnGraph,
  deleteNodeFromGraph,
  findParent,
} from "../../../utils/graph/graphUtils";

export type GraphState = {
  storyId: string;
  name: string;
  graph: Graph;
  graphLoaded: boolean;
  activeNodeId: number;
  numOfEdits: number;
  /** Set on `getStory.rejected` so the page can render an error fallback
   *  instead of stale graph contents from a previous load. */
  loadError: string | null;
};

const emptyGraph = (): Graph => ({ nodeLookup: {} });

const initialState: GraphState = {
  storyId: "",
  name: "",
  graph: emptyGraph(),
  graphLoaded: false,
  activeNodeId: 0,
  numOfEdits: 0,
  loadError: null,
};

// ---------- Thunks ----------

export const getStory = createAsyncThunk(
  "graph/getStory",
  async (storyId: string) => stories.getById(storyId),
);

export const saveGraph = createAsyncThunk(
  "graph/saveGraph",
  async (_: void, { getState }) => {
    const state = getState() as { graph: GraphState };
    await stories.saveGraph(state.graph.storyId, state.graph.graph);
  },
);

export const updateStoryName = createAsyncThunk(
  "graph/updateStoryName",
  async (name: string, { getState }) => {
    const state = getState() as { graph: GraphState };
    return await stories.updateName(state.graph.storyId, { name });
  },
);

type ParamsLike = {
  temperature: number;
  descriptor: string;
  details: string;
  style: string;
  generateManyDepth: number;
  numActionsToAdd: number;
};

const getParams = (getState: () => unknown): ParamsLike => {
  return (getState() as { params: ParamsLike }).params;
};

export const generateInitial = createAsyncThunk(
  "graph/generateInitial",
  async (
    input: { genre: string; attributes: Record<string, unknown> },
    { getState },
  ) => {
    const params = getParams(getState);
    return generation.generateInitial(
      input.genre,
      input.attributes,
      params.temperature,
    );
  },
);

export const generateActions = createAsyncThunk(
  "graph/generateActions",
  async (nodeId: number, { getState }) => {
    const state = getState() as { graph: GraphState };
    const params = getParams(getState);
    return generation.generateActions(
      state.graph.graph,
      nodeId,
      params.numActionsToAdd,
      params.temperature,
    );
  },
);

export const addAction = createAsyncThunk(
  "graph/addAction",
  async (nodeId: number, { getState }) => {
    const state = getState() as { graph: GraphState };
    const params = getParams(getState);
    return generation.addAction(
      state.graph.graph,
      nodeId,
      params.numActionsToAdd,
      params.temperature,
    );
  },
);

export const generateNarrative = createAsyncThunk(
  "graph/generateNarrative",
  async (
    input: { nodeId: number; isEnding?: boolean },
    { getState },
  ) => {
    const state = getState() as { graph: GraphState };
    const params = getParams(getState);
    return generation.generateNarrative(state.graph.graph, input.nodeId, {
      isEnding: input.isEnding ?? false,
      descriptor: params.descriptor || null,
      details: params.details || null,
      style: params.style || null,
      temperature: params.temperature,
    });
  },
);

export const connectNodesWithBridge = createAsyncThunk(
  "graph/connectNodesWithBridge",
  async (input: { sourceId: number; targetId: number }, { getState }) => {
    const state = getState() as { graph: GraphState };
    const params = getParams(getState);
    return generation.connectNodes(
      state.graph.graph,
      input.sourceId,
      input.targetId,
      params.temperature,
    );
  },
);

export const generateMany = createAsyncThunk(
  "graph/generateMany",
  async (nodeId: number, { getState }) => {
    const state = getState() as { graph: GraphState };
    const params = getParams(getState);
    return generation.generateMany(
      state.graph.graph,
      nodeId,
      params.generateManyDepth,
      params.numActionsToAdd,
      params.temperature,
    );
  },
);

// ---------- Slice ----------

const slice = createSlice({
  name: "graph",
  initialState,
  reducers: {
    reset: () => initialState,
    setStoryId(state, action: PayloadAction<string>) {
      state.storyId = action.payload;
    },
    setName(state, action: PayloadAction<string>) {
      state.name = action.payload;
    },
    setGraph(state, action: PayloadAction<Graph>) {
      state.graph = action.payload;
    },
    setActiveNodeId(state, action: PayloadAction<number>) {
      state.activeNodeId = action.payload;
    },
    deleteNode(state, action: PayloadAction<number>) {
      state.activeNodeId = findParent(state.graph, action.payload) ?? 0;
      state.graph = deleteNodeFromGraph(state.graph, action.payload, true);
    },
    deleteChildNodes(state, action: PayloadAction<number>) {
      const next = deleteNodeFromGraph(state.graph, action.payload, false);
      if (!(state.activeNodeId in next.nodeLookup)) {
        state.activeNodeId = action.payload;
      }
      state.graph = next;
    },
    setNodeData(
      state,
      action: PayloadAction<{ nodeId: number; data: string }>,
    ) {
      const node = state.graph.nodeLookup[action.payload.nodeId];
      if (node) node.data = action.payload.data;
    },
    setEnding(
      state,
      action: PayloadAction<{ nodeId: number; isEnding: boolean }>,
    ) {
      const node = state.graph.nodeLookup[action.payload.nodeId];
      if (node && node.type === NodeType.Narrative) {
        (node as NarrativeNode).isEnding = action.payload.isEnding;
      }
    },
    /** Sync edge addition (no LLM bridge). Refused on ending narratives. */
    connectEdge(
      state,
      action: PayloadAction<{ fromNode: number; toNode: number }>,
    ) {
      const fromData = state.graph.nodeLookup[action.payload.fromNode];
      if (fromData && isNarrativeNode(fromData) && fromData.isEnding) return;
      state.graph = connectNodesOnGraph(
        state.graph,
        action.payload.fromNode,
        action.payload.toNode,
      );
    },
    disconnectEdge(
      state,
      action: PayloadAction<{ fromNode: number; toNode: number }>,
    ) {
      state.graph = deleteEdgeOnGraph(
        state.graph,
        action.payload.fromNode,
        action.payload.toNode,
      );
    },
    incrementEdits(state) {
      state.numOfEdits += 1;
    },
    decrementEdits(state) {
      state.numOfEdits -= 1;
    },
    resetEdits(state) {
      state.numOfEdits = 0;
    },
    /** Dispatched by `wsMiddleware` when a server-pushed `progressUpdate` arrives. */
    progressUpdate(state, action: PayloadAction<Graph>) {
      state.graph = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder.addCase(getStory.fulfilled, (state, action) => {
      state.storyId = action.payload.id;
      state.name = action.payload.name;
      state.graph = action.payload.graph;
      state.graphLoaded = true;
      state.activeNodeId = 0;
      state.loadError = null;
    });
    builder.addCase(getStory.rejected, (state, action) => {
      // A failed load must not leak the previously-loaded story's content.
      state.storyId = action.meta.arg;
      state.name = "";
      state.graph = emptyGraph();
      state.activeNodeId = 0;
      state.numOfEdits = 0;
      state.graphLoaded = true;
      state.loadError = action.error.message ?? "Failed to load story";
    });
    builder.addCase(updateStoryName.fulfilled, (state, action) => {
      state.name = action.payload.name;
    });

    // Thunks return the in-memory `Graph` (lookup form) — `api/generation.ts`
    // converts the wire `{nodes: [...]}` shape on the way in.
    const replaceGraph = (state: GraphState, action: { payload: Graph }) => {
      state.graph = action.payload;
    };

    builder.addCase(generateInitial.fulfilled, replaceGraph);
    builder.addCase(generateActions.fulfilled, replaceGraph);
    builder.addCase(addAction.fulfilled, replaceGraph);
    builder.addCase(generateNarrative.fulfilled, replaceGraph);
    builder.addCase(connectNodesWithBridge.fulfilled, replaceGraph);
    builder.addCase(generateMany.fulfilled, replaceGraph);
  },
});

export const {
  reset,
  setStoryId,
  setName,
  setGraph,
  setActiveNodeId,
  deleteNode,
  deleteChildNodes,
  setNodeData,
  setEnding,
  connectEdge,
  disconnectEdge,
  incrementEdits,
  decrementEdits,
  resetEdits,
  progressUpdate,
} = slice.actions;

export default slice.reducer;

// ---------- Selectors ----------

import type { RootState } from "../../../store/store";

export const selectGraph = (s: RootState) => s.graph.graph;
export const selectStoryId = (s: RootState) => s.graph.storyId;
export const selectStoryName = (s: RootState) => s.graph.name;
export const selectGraphLoaded = (s: RootState) => s.graph.graphLoaded;
export const selectActiveNodeId = (s: RootState) => s.graph.activeNodeId;
export const selectNumOfEdits = (s: RootState) => s.graph.numOfEdits;
export const selectGraphIsBeingEdited = (s: RootState) =>
  s.graph.numOfEdits !== 0;
export const selectGraphIsEmpty = (s: RootState) =>
  Object.keys(s.graph.graph.nodeLookup).length === 0;
export const selectLoadError = (s: RootState) => s.graph.loadError;
