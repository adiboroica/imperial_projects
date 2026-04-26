import { configureStore } from "@reduxjs/toolkit";
import { describe, expect, it } from "vitest";

import { LoadingType } from "../../../types";
import loadingReducer, {
  clearLoading,
  selectInflight,
  selectIsLoading,
  selectIsLoadingType,
  wsRequestSettled,
  wsRequestStarted,
} from "./loading";

const makeStore = () =>
  configureStore({ reducer: { loading: loadingReducer } });

describe("loading slice", () => {
  it("wsRequestStarted adds an entry", () => {
    const store = makeStore();
    store.dispatch(
      wsRequestStarted({ requestId: "r1", type: LoadingType.GenerateActions }),
    );
    expect(selectInflight(store.getState() as any)["r1"]).toBe(
      LoadingType.GenerateActions,
    );
    expect(selectIsLoading(store.getState() as any)).toBe(true);
  });

  it("wsRequestSettled removes the entry", () => {
    const store = makeStore();
    store.dispatch(
      wsRequestStarted({ requestId: "r1", type: LoadingType.InitialStory }),
    );
    store.dispatch(wsRequestSettled({ requestId: "r1" }));
    expect(selectIsLoading(store.getState() as any)).toBe(false);
  });

  it("clearLoading wipes all entries", () => {
    const store = makeStore();
    store.dispatch(
      wsRequestStarted({ requestId: "r1", type: LoadingType.InitialStory }),
    );
    store.dispatch(
      wsRequestStarted({ requestId: "r2", type: LoadingType.GenerateActions }),
    );
    store.dispatch(clearLoading());
    expect(Object.keys(selectInflight(store.getState() as any))).toHaveLength(0);
  });

  it("selectIsLoadingType matches exact type", () => {
    const store = makeStore();
    store.dispatch(
      wsRequestStarted({ requestId: "r1", type: LoadingType.GenerateActions }),
    );
    const isActions = selectIsLoadingType(LoadingType.GenerateActions);
    const isInitial = selectIsLoadingType(LoadingType.InitialStory);
    expect(isActions(store.getState() as any)).toBe(true);
    expect(isInitial(store.getState() as any)).toBe(false);
  });
});
