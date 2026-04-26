# Utils

Pure helpers for graph manipulation. Zero UI, zero network, zero state.

## 📋 Overview

One area, purely functional: operations on the in-memory `Graph` type from [`../types/graph.ts`](../types/graph.ts). Cycle detection, traversal, parent lookup, type guards, edge mutations, and Graph-to-prose conversion. File export (DOCX, TXT) is a backend responsibility — the frontend triggers it with a download URL.

## 🏗️ Structure

    utils/
    └── graph/
        ├── graphUtils.ts        ─ traversal, mutation, validation, type guards
        └── storyUtils.ts        ─ Graph → readable prose conversion

## 📐 Design

- **Functions, not classes** — every export is a pure function; no module-level mutable state, no factories.
- **Operate on `types/` shapes** — graph helpers take `Graph` / `NodeData` / `NarrativeNode` / `ActionNode` from [`../types/`](../types). They never construct or accept ad-hoc shapes.
- **Validation returns booleans, not exceptions** — `isValidConnectNodes(graph, parent, child)` returns `true` / `false`; the caller decides what to do with a `false`. Mutations refuse silently on invalid input or are gated behind an `isValid*` check; they do not throw.
- **Graph mutations are immutable** — `deleteNodeFromGraph(graph, nodeId)` returns a new `Graph` and leaves the input untouched. Slices that hold these graphs in Redux state can swap one for another with no aliasing concerns.
- **No side effects** — nothing in `utils/` touches the DOM, the network, the store, or browser storage.

## 🔗 Dependencies

Imports from [`../types`](../types) and the standard library only. Never imports from `components/`, `api/`, `pages/`, or `store/`.
