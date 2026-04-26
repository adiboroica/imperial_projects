# Frontend Source

The React source tree, organised domain-first: per-page folders for single routes, per-feature folders for cross-page state, plus a flat set of shared directories and thin Redux composition.

## 📋 Overview

Eight top-level directories plus a pair of wiring files.

**Business directories:**

- **`pages/`** — one folder per URL route (account, dashboard, generator, login, signup, setup, welcome). Every page that has any slices carries a `slices/` subfolder; every page that has any components carries a `components/` subfolder. Pages with neither (welcome, login, signup) are just their route screen.
- **`features/`** — cross-page domains. A feature owns state and helpers shared by multiple pages. Today: `features/auth/` holds the slice that login, signup, and the account page all read from.
- **`components/`** — split into `components/shared/` (multi-page widgets — empty today; populated once a widget graduates from a page-local home) and `components/layout/` (app chrome: `AppHeader`, `AppFooter`, `AppMenu`).
- **`api/`** — the only layer that talks to the backend. Per-domain call modules (`auth.ts`, `stories.ts`, `generation.ts`, `api_key.ts`) over shared `clients/` infrastructure (typed HTTP + typed WS).
- **`types/`** — cross-cutting type definitions shared between layers (`Graph`, `Story`, `User`, request/response shapes). Zero runtime code.
- **`utils/`** — pure helpers (graph ops). Zero UI, zero network.
- **`styles/`** — global CSS and Mantine theme overrides. Two files: `global.css` and `theme.ts`. Imported once at app start; not consumed by individual pages or components.

**Composition (sits above every business layer):**

- **`main.tsx`** — React entry point; mounts the app onto `#root`.
- **`App.tsx`** — top-level router, Mantine provider, and Redux store provider.
- **`store/`** — `configureStore`, `rootReducer` that combines page and feature slices, typed `useAppSelector` / `useAppDispatch` hooks, and Redux middleware (WS bridge, notifications). No business logic, no slices of its own.

## 🏗️ Dependency Hierarchy

The business layers, top-down — each line imports only from lines below it:

    types/        ← leaf (pure type declarations, zero runtime)
    utils/        ← leaf (pure functions)
    styles/       ← leaf (CSS + Mantine theme, no internal imports)
    components/   ← imports types/, utils/
    api/          ← imports types/
    features/     ← imports types/, utils/, api/
    pages/        ← imports types/, utils/, components/, api/, features/, and store/ typed hooks

Composition (`main.tsx`, `App.tsx`, `store/`) sits above every business layer and is expected to know about everything below. `App.tsx` imports page components to route to them; `store/rootReducer.ts` imports slice reducers from both pages and features to combine them.

## 📐 Dependency Rules

- **`types/` and `utils/` are leaves** — neither imports from any other `src/` directory. `types/` is zero-runtime type declarations; `utils/` is pure functions with no UI, no network, no state.
- **`api/` is the only network boundary** — the typed `ApiClient` in `api/clients/http.ts` and the typed WS client in `api/clients/ws.ts` are the only callers of `fetch` and `WebSocket`. Per-domain modules call those bases.
- **`components/` stay presentational** — can read from props and local component state; never talk to the store or the network. A component that needs state or network belongs inside a page's `components/` subfolder or a feature's `components/`.
- **`features/` own cross-page state** — a feature's slice is read by more than one page. Features import from types, utils, and api but never from pages, components, store, or another feature.
- **Each page is self-contained** — `pages/<name>/` holds the route screen plus a `slices/` and `components/` subfolder if needed. Pages do not import each other; pages may import from features.
- **Page-local components live inside the page** — `pages/generator/components/graph/GraphCanvas.tsx` is not visible to other pages. If a second page needs it, it's promoted to `components/shared/` as an explicit move.
- **`store/` is composition, not a layer** — `rootReducer.ts` imports slice reducers from pages and features; `store.ts` calls `configureStore` on the combined reducer; `hooks.ts` exports typed hooks. Pages and features import the typed hooks only (never `rootReducer`, never the root `store`).

## 📂 Sub-Module Documentation

- [`api/`](api/README.md) — HTTP and WebSocket surface consumed from the backend.
- [`components/`](components/README.md) — shared UI widgets and app layout chrome.
- [`features/`](features/README.md) — cross-page domain state and helpers.
- [`pages/`](pages/README.md) — page index and per-page READMEs.
- [`store/`](store/README.md) — root store wiring, typed hooks, and Redux middleware.
- [`styles/`](styles/README.md) — global CSS and Mantine theme.
- [`types/`](types/README.md) — shared type definitions.
- [`utils/`](utils/README.md) — pure helpers (graph ops).
