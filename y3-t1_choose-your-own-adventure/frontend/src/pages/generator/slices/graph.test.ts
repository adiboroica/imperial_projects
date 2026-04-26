import { configureStore } from "@reduxjs/toolkit";
import { describe, expect, it, vi } from "vitest";

import { NodeType } from "../../../types";
import graphReducer, {
  connectEdge,
  deleteNode,
  progressUpdate,
  selectActiveNodeId,
  selectGraph,
  setActiveNodeId,
  setEnding,
  setGraph,
  setNodeData,
} from "./graph";

vi.mock("../../../api", () => ({
  generation: {},
  stories: {},
}));

const makeStore = () =>
  configureStore({ reducer: { graph: graphReducer } });

const SEED_GRAPH = {
  nodeLookup: {
    0: {
      nodeId: 0,
      data: "root",
      childrenIds: [1],
      type: NodeType.Narrative,
      isEnding: false,
    } as any,
    1: {
      nodeId: 1,
      data: "act",
      childrenIds: [],
      type: NodeType.Action,
    } as any,
  },
};

describe("graph slice", () => {
  it("setGraph replaces the graph", () => {
    const store = makeStore();
    store.dispatch(setGraph(SEED_GRAPH));
    expect(Object.keys(selectGraph(store.getState() as any).nodeLookup).length).toBe(
      2,
    );
  });

  it("setActiveNodeId updates the selected node", () => {
    const store = makeStore();
    store.dispatch(setActiveNodeId(7));
    expect(selectActiveNodeId(store.getState() as any)).toBe(7);
  });

  it("setNodeData updates node text", () => {
    const store = makeStore();
    store.dispatch(setGraph(SEED_GRAPH));
    store.dispatch(setNodeData({ nodeId: 0, data: "new root" }));
    expect(selectGraph(store.getState() as any).nodeLookup[0].data).toBe("new root");
  });

  it("setEnding toggles isEnding on narrative nodes", () => {
    const store = makeStore();
    store.dispatch(setGraph(SEED_GRAPH));
    store.dispatch(setEnding({ nodeId: 0, isEnding: true }));
    expect(
      (selectGraph(store.getState() as any).nodeLookup[0] as any).isEnding,
    ).toBe(true);
  });

  it("deleteNode removes the node and resets active to its parent", () => {
    const store = makeStore();
    store.dispatch(setGraph(SEED_GRAPH));
    store.dispatch(setActiveNodeId(1));
    store.dispatch(deleteNode(1));
    expect(selectGraph(store.getState() as any).nodeLookup[1]).toBeUndefined();
    expect(selectActiveNodeId(store.getState() as any)).toBe(0);
  });

  it("connectEdge does nothing on ending narrative", () => {
    const ending = {
      nodeLookup: {
        0: { ...SEED_GRAPH.nodeLookup[0], isEnding: true },
        1: SEED_GRAPH.nodeLookup[1],
      },
    };
    const store = makeStore();
    store.dispatch(setGraph(ending));
    const before = selectGraph(store.getState() as any).nodeLookup[0].childrenIds.length;
    store.dispatch(connectEdge({ fromNode: 0, toNode: 99 }));
    const after = selectGraph(store.getState() as any).nodeLookup[0].childrenIds.length;
    expect(after).toBe(before);
  });

  it("progressUpdate replaces the graph with the snapshot", () => {
    const store = makeStore();
    store.dispatch(progressUpdate(SEED_GRAPH));
    expect(selectGraph(store.getState() as any)).toEqual(SEED_GRAPH);
  });
});
