# Components

Shared UI building blocks. Two kinds: generic widgets used many times, and layout chrome mounted once per app.

## 📋 Overview

Two subfolders, one role each:

- **`shared/`** — generic, reusable widgets that more than one page consumes. Currently empty: every widget that *could* live here only has one consumer today, so it stays page-local. The folder is the documented destination for widgets that graduate from a page's `components/` once a second consumer appears.
- **`layout/`** — the app shell: `AppHeader`, `AppFooter`, `AppMenu`. Singletons, mounted by `App.tsx` exactly once.

The bare `components/` directory holds no loose `.tsx` files; every component lives in one of the two subfolders so the kind is obvious from the path.

## 🏗️ Structure

    components/
    ├── shared/                  ─ destination for widgets with ≥ 2 page consumers (empty today)
    └── layout/
        ├── AppHeader.tsx
        ├── AppFooter.tsx
        └── AppMenu.tsx

## 📐 Design

- **Presentational only** — every file in this folder reads from props (and local component state) and renders. Nothing here calls `useAppSelector`, `useAppDispatch`, `fetch`, or `WebSocket`. A component that needs state or network belongs inside a page's `components/` subfolder.
- **`App.tsx` wires layout components from the store** — `AppHeader` needs the current user, but it doesn't read the store itself. `App.tsx` reads `state.auth.user` via the typed hooks and passes it down as a prop. Same for "log out" callbacks, story counts, anything else from state. Layout components stay pure; the wiring file knows the store.
- **Widgets are generic; layout components are singletons** — adding a second `AppHeader` would be a smell. Adding a tenth shared widget once a second page needs it is fine. The two halves of `components/` serve different needs but share the "no store, no network" rule.
- **Built on Mantine** — every visible primitive (`Button`, `TextInput`, `Paper`, `Modal`, …) wraps a Mantine equivalent rather than a raw HTML element. Consistent styling without hand-rolled CSS.
- **Promotion-only entry** — a component lands in `shared/` only when a *second* page actually needs it. New widgets start life as page-local components inside `pages/<X>/components/` and graduate to `shared/` once there is a concrete second consumer.

## 🔗 Dependencies

Imports from [`../types`](../types) and [`../utils`](../utils). Never imports from `api/`, `pages/`, or `store/`.
