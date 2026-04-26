import { configureStore } from "@reduxjs/toolkit";
import { describe, expect, it } from "vitest";

import paramsReducer, {
  resetParams,
  selectGenerateManyDepth,
  selectNumActionsToAdd,
  selectTemperature,
  setDescriptor,
  setDetails,
  setGenerateManyDepth,
  setNumActionsToAdd,
  setStyle,
  setTemperature,
} from "./params";

const makeStore = () =>
  configureStore({ reducer: { params: paramsReducer } });

describe("params slice", () => {
  it("setTemperature clamps to [0, 1]", () => {
    const store = makeStore();
    store.dispatch(setTemperature(2));
    expect(selectTemperature(store.getState() as any)).toBe(1);
    store.dispatch(setTemperature(-1));
    expect(selectTemperature(store.getState() as any)).toBe(0);
    store.dispatch(setTemperature(0.7));
    expect(selectTemperature(store.getState() as any)).toBe(0.7);
  });

  it("setNumActionsToAdd enforces minimum of 1", () => {
    const store = makeStore();
    store.dispatch(setNumActionsToAdd(0));
    expect(selectNumActionsToAdd(store.getState() as any)).toBe(1);
    store.dispatch(setNumActionsToAdd(5));
    expect(selectNumActionsToAdd(store.getState() as any)).toBe(5);
  });

  it("setGenerateManyDepth clamps to non-negative", () => {
    const store = makeStore();
    store.dispatch(setGenerateManyDepth(-3));
    expect(selectGenerateManyDepth(store.getState() as any)).toBe(0);
    store.dispatch(setGenerateManyDepth(3));
    expect(selectGenerateManyDepth(store.getState() as any)).toBe(3);
  });

  it("setDescriptor / setDetails / setStyle update fields", () => {
    const store = makeStore();
    store.dispatch(setDescriptor("dark"));
    store.dispatch(setDetails("rainy"));
    store.dispatch(setStyle("terse"));
    const state: any = store.getState();
    expect(state.params.descriptor).toBe("dark");
    expect(state.params.details).toBe("rainy");
    expect(state.params.style).toBe("terse");
  });

  it("resetParams returns to defaults", () => {
    const store = makeStore();
    store.dispatch(setTemperature(1));
    store.dispatch(setDescriptor("dark"));
    store.dispatch(resetParams());
    expect(selectTemperature(store.getState() as any)).toBe(0.6);
    expect((store.getState() as any).params.descriptor).toBe("");
  });
});
