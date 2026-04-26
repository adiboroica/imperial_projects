/**
 * Store composition. Calls `configureStore` over the combined `rootReducer`
 * and registers cross-cutting middleware.
 */

import { configureStore } from "@reduxjs/toolkit";

import notificationMiddleware from "./middleware/notification";
import wsMiddleware from "./middleware/ws";
import { rootReducer } from "./rootReducer";

export const store = configureStore({
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(wsMiddleware, notificationMiddleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
