# Generator

Interactive graph editor — visualises a story as a node-and-edge diagram, mutates it via Redux, and streams expansions over the WebSocket channel.

## 📋 Overview

The richest page in the app. Three slices and components grouped into three subfolders.

**Three slices:**

- **`slices/graph.ts`** — the `Graph` state itself, mutation reducers (delete node, connect, disconnect), and thunks that send WS messages and apply the resulting frame.
- **`slices/params.ts`** — generation knobs: temperature, descriptor, details, style, depth, action count.
- **`slices/loading.ts`** — in-flight tracking keyed by WS `requestId`.

**Component groups:**

- **`components/graph/`** — the ReactFlow canvas, custom node renderers, layout machinery.
- **`components/options/`** — the right-hand panel for tweaking the selected node's expansion options.
- **`components/section/`** — the read-only narrative and action text views inside each node.
- Plus page-level controls: `SaveButton`, `DownloadButton`, `StoryTitle`, `LoadingInitialParagraph`, and the page-local widgets `EditableField` (click-to-edit text wrapped by `StoryTitle`) and `SplitButton` (primary action plus dropdown wrapped by `DownloadButton`).

## 🏗️ Structure

    generator/
    ├── GeneratorPage.tsx
    ├── slices/
    │   ├── graph.ts
    │   ├── params.ts
    │   └── loading.ts
    └── components/
        ├── graph/                ─ ReactFlow canvas, custom nodes, layout
        ├── options/              ─ side panel for the selected node
        ├── section/              ─ inline narrative + action text on each node
        ├── EditableField.tsx     ─ click-to-edit text widget (used by StoryTitle)
        ├── SplitButton.tsx       ─ primary + dropdown widget (used by DownloadButton)
        └── *.tsx                 ─ page-level controls (Save, Download, Title, …)

## 📐 Design

- **Three slices, three concerns** — graph state changes constantly as the user edits; params change rarely; loading toggles on every WS roundtrip. Splitting them keeps each slice's reducer surface small and avoids re-rendering the canvas every time an unrelated checkbox flips.
- **Client-initiated generation goes through thunks** — `generateInitial`, `generateActions`, `addAction`, `generateNarrative`, `connectNodes`, `generateMany` are `createAsyncThunk` wrappers around `api/clients/ws.ts` that resolve when the matching `requestComplete` frame arrives.
- **`generateMany` uses server-pushed updates** — bulk expansion produces multiple `progressUpdate` frames before the final `requestComplete`. The WS middleware in `store/middleware/ws.ts` dispatches a partial-update action for each `progressUpdate`; the graph slice's `extraReducers` apply it to state.
- **Exports run server-side** — `GET /stories/{id}/export?format=...` returns the file with `Content-Disposition: attachment`; `DownloadButton` is a `SplitButton` whose primary action navigates to the DOCX URL and whose dropdown holds the TXT fallback. No client-side blob construction.
- **Page-local widgets stay page-local** — `EditableField` and `SplitButton` are generic enough to graduate to `components/shared/` once a second page consumes them, but until that happens they live next to their only consumer here. The promotion contract is documented in [`../../components/README.md`](../../components/README.md).
- **Component subgroups reflect the panel layout** — `graph/` is the canvas (centre), `options/` is the right panel (when a node is selected), `section/` is the inline text rendered inside each node on the canvas.

## 🔗 Dependencies

Imports from [`../../types`](../../types) (`graph`, `story`), [`../../api`](../../api) (`stories`, `generation`), [`../../utils`](../../utils) (`graph`), [`../../components`](../../components), and [`../../store/hooks.ts`](../../store/hooks.ts). Never imports from another page.
