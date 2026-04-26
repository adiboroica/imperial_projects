/**
 * Typed `useAppSelector` and `useAppDispatch` hooks.
 *
 * Pages and components import THESE instead of the raw `react-redux` hooks so
 * the state shape is checked at compile time.
 */

import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";

import type { AppDispatch, RootState } from "./store";

export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
