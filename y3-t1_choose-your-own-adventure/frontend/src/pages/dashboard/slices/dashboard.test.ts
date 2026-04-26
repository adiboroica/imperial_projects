import { configureStore } from "@reduxjs/toolkit";
import { describe, expect, it, vi } from "vitest";

import dashboardReducer, {
  deleteStory,
  listStories,
  selectDashboardLoading,
  selectDashboardStories,
} from "./dashboard";

vi.mock("../../../api", () => ({
  stories: {
    list: vi.fn(),
    delete: vi.fn(),
  },
}));

import { stories } from "../../../api";

const makeStore = () =>
  configureStore({ reducer: { dashboard: dashboardReducer } });

const FIXTURE = [
  { id: "s1", name: "A", firstParagraph: "...", totalSections: 1 },
  { id: "s2", name: "B", firstParagraph: "...", totalSections: 0 },
];

describe("dashboard slice", () => {
  it("listStories.fulfilled replaces the list", async () => {
    const store = makeStore();
    (stories.list as any).mockResolvedValueOnce(FIXTURE);
    await store.dispatch(listStories());
    expect(selectDashboardStories(store.getState() as any)).toEqual(FIXTURE);
  });

  it("listStories.pending sets loading", () => {
    const store = makeStore();
    (stories.list as any).mockReturnValue(new Promise(() => {})); // never resolves
    void store.dispatch(listStories());
    expect(selectDashboardLoading(store.getState() as any)).toBe(true);
  });

  it("deleteStory.fulfilled removes by id", async () => {
    const store = makeStore();
    (stories.list as any).mockResolvedValueOnce(FIXTURE);
    await store.dispatch(listStories());
    (stories.delete as any).mockResolvedValueOnce(undefined);
    await store.dispatch(deleteStory("s1"));
    expect(selectDashboardStories(store.getState() as any)).toEqual([
      FIXTURE[1],
    ]);
  });
});
