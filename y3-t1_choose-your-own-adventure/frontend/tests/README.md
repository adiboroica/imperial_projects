# Frontend Tests

Vitest-based unit and component tests for the React app, plus architecture rule enforcement via `dependency-cruiser` and content scans.

## 📋 Overview

Two categories:

- **Unit and component tests** — co-located with source as `*.test.ts(x)` files alongside the file they test. Vitest discovers them automatically. Covers slices, thunks, utils, components, and pages.
- **Architecture tests** — module-level layering via `dependency-cruiser` and statement-level rules via regex scans. Live in `tests/architecture/` because they're cross-cutting and have no single source-file owner.

## 📐 What we test (and what we don't)

A unit gets its own test file when it:

- **holds state** — every Redux slice has a test for its reducers and async thunks;
- **crosses the network** — the typed `ApiClient` and `WSClient`, plus every per-domain api module under `src/api/`;
- **runs pure logic** — `utils/graph/*` and any `types/*` adapters;
- **orchestrates a page** — one `<Page>.test.tsx` per route, mounting through `renderWithProviders` so the full slice / api / component graph is exercised end-to-end;
- **is shared chrome** — `components/layout/{AppHeader, AppFooter, AppMenu}` and anything in `components/shared/`.

A unit does NOT get its own test when it is a thin presentational wrapper inside a page — these are exercised through their parent page's test. Examples that intentionally lack a sibling `.test.tsx`:

- `pages/<X>/components/{SaveButton, DeleteStoryButton, LoadingInitialParagraph}.tsx` — render plus dispatch one thunk;
- `pages/setup/components/{GenreDropdown, GenreOptions, InputTextForm, GenerateButton}.tsx` — pure prop-driven Mantine form widgets;
- `pages/generator/components/{section,options}/*.tsx` — render text or a small option panel from props.

The exception is page-local components that carry **non-trivial logic** — dynamic state, layout machinery, conditional dispatch trees, integrations with third-party libraries like ReactFlow. Those get their own test even when only one consumer exists. The current direct-test backfill list: `AppMenu`, `AttributeTable`, `GenreHandler`, `GraphCanvas`, `GraphContextMenu`.

## ▶️ Running

    npm test                              # everything (unit + component + architecture)
    npm test -- src/pages/account         # tests under one folder
    npm test -- tests/architecture        # architecture only
    npm run test:watch                    # vitest watch mode
    npm run test:coverage                 # with coverage

## 🏗️ Tree

    frontend/
    ├── src/
    │   └── ...                           ─ co-located *.test.ts(x) next to source files
    └── tests/
        └── architecture/                 ─ dependency-cruiser + purity scans

## 📐 Conventions

- **Co-location for unit tests** — `AccountPage.test.tsx` lives next to `AccountPage.tsx`; `account.test.ts` lives next to `account.ts`. Modern React convention; vitest picks them up via glob.
- **Mock at the seam** — slice tests mock `api/*` (the network layer); component tests mock the Redux store with a per-test fixture; api tests mock `fetch` and `WebSocket` at the global level. Each test pins the contract at the layer's outer boundary.
- **`@testing-library/react` for components** — interact via accessible roles and labels, not implementation details. No shallow rendering.
- **No real network in any test** — the `fetch` global and `WebSocket` constructor are stubbed at test setup so a stray production-pointing call fails fast rather than silently hitting localhost.
- **Architecture tests are cross-cutting** — they live in `tests/architecture/` (sibling of `src/`) because no single source file owns them. See [`architecture/README.md`](architecture/README.md) for the rule catalogue.

## 📂 Sub-Module Documentation

- [`architecture/README.md`](architecture/README.md) — `dependency-cruiser` boundaries plus `purity.test.ts` content scans.
