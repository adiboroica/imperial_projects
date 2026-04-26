/**
 * The single place that knows about every slice in the app.
 *
 * `combineReducers` wires each slice's reducer under the matching state key.
 * `App.tsx`-style components import their typed hooks from `store/hooks.ts`;
 * they never reach into `rootReducer` directly.
 */

import { combineReducers } from "@reduxjs/toolkit";

import authReducer from "../features/auth/slices/auth";
import dashboardReducer from "../pages/dashboard/slices/dashboard";
import graphReducer from "../pages/generator/slices/graph";
import loadingReducer from "../pages/generator/slices/loading";
import paramsReducer from "../pages/generator/slices/params";
import setupReducer from "../pages/setup/slices/setup";

export const rootReducer = combineReducers({
  auth: authReducer,
  dashboard: dashboardReducer,
  setup: setupReducer,
  graph: graphReducer,
  params: paramsReducer,
  loading: loadingReducer,
});

export type RootState = ReturnType<typeof rootReducer>;
