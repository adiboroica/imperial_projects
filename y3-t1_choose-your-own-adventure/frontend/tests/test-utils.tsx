/**
 * Shared rendering helper for component / page tests.
 *
 * Wraps the rendered tree in `<Provider>`, `<MantineProvider>`, and
 * `<MemoryRouter>` so any consumer hook works in isolation.
 */

import "@mantine/core/styles.css";

import { MantineProvider } from "@mantine/core";
import { configureStore } from "@reduxjs/toolkit";
import { render, type RenderOptions } from "@testing-library/react";
import type { ReactElement } from "react";
import { Provider } from "react-redux";
import { MemoryRouter, type MemoryRouterProps } from "react-router-dom";

import { rootReducer } from "../src/store/rootReducer";

export type RootState = ReturnType<typeof rootReducer>;

type Options = Omit<RenderOptions, "wrapper"> & {
  preloadedState?: Partial<RootState>;
  routerProps?: MemoryRouterProps;
};

export const renderWithProviders = (
  ui: ReactElement,
  { preloadedState, routerProps, ...renderOptions }: Options = {},
) => {
  const store = configureStore({
    reducer: rootReducer,
    preloadedState,
  });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <Provider store={store}>
      <MantineProvider>
        <MemoryRouter {...routerProps}>{children}</MemoryRouter>
      </MantineProvider>
    </Provider>
  );
  return { store, ...render(ui, { wrapper: Wrapper, ...renderOptions }) };
};
