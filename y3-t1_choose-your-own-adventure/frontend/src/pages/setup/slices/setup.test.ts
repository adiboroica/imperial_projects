import { configureStore } from "@reduxjs/toolkit";
import { describe, expect, it, vi } from "vitest";

import setupReducer, {
  addEntry,
  removeEntry,
  selectSetupGenre,
  selectSetupValues,
  setAttribute,
  setContent,
  setGenre,
  startStory,
} from "./setup";

vi.mock("../../../api", () => ({
  stories: {
    create: vi.fn(),
    saveGraph: vi.fn(),
  },
  generation: {
    generateInitial: vi.fn(),
  },
}));

import { generation, stories } from "../../../api";

const makeStore = () => configureStore({ reducer: { setup: setupReducer } });

describe("setup slice", () => {
  it("setGenre updates genre", () => {
    const store = makeStore();
    store.dispatch(setGenre("fantasy"));
    expect(selectSetupGenre(store.getState() as any)).toBe("fantasy");
  });

  it("setAttribute and setContent update the matching row", () => {
    const store = makeStore();
    store.dispatch(setAttribute({ position: 0, data: "hero" }));
    store.dispatch(setContent({ position: 0, data: "elf" }));
    const rows = selectSetupValues(store.getState() as any);
    expect(rows[0]).toEqual({ attribute: "hero", content: "elf" });
  });

  it("addEntry appends a blank row", () => {
    const store = makeStore();
    const before = selectSetupValues(store.getState() as any).length;
    store.dispatch(addEntry());
    const after = selectSetupValues(store.getState() as any).length;
    expect(after).toBe(before + 1);
  });

  it("removeEntry deletes by index", () => {
    const store = makeStore();
    const before = selectSetupValues(store.getState() as any).length;
    store.dispatch(removeEntry({ position: 0 }));
    expect(selectSetupValues(store.getState() as any).length).toBe(before - 1);
  });

  it("startStory.fulfilled returns storyId and graph and resets form", async () => {
    const store = makeStore();
    store.dispatch(setGenre("fantasy"));
    (stories.create as any).mockResolvedValueOnce({ id: "s1", name: "Story" });
    (generation.generateInitial as any).mockResolvedValueOnce({
      nodeLookup: {},
    });
    (stories.saveGraph as any).mockResolvedValueOnce(undefined);
    const result = await store.dispatch(startStory());
    expect(startStory.fulfilled.match(result)).toBe(true);
    if (startStory.fulfilled.match(result)) {
      expect(result.payload.storyId).toBe("s1");
    }
    // Form is reset.
    expect(selectSetupGenre(store.getState() as any)).toBe("");
  });
});
