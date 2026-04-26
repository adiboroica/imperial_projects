# Generator Tests

Test contract for the interactive graph editor — the richest page in the app.

## 📋 Overview

Eleven units: three slices, the page, three component groups (with `GraphCanvas` and `GraphContextMenu` covered by their own direct tests within the graph group), a combined section for page-level controls, and the two page-local widgets (`EditableField`, `SplitButton`) that the controls wrap. Test files co-located alongside source.

## ▶️ Running

    npm test -- src/pages/generator

See [`../../../tests/README.md`](../../../tests/README.md) for the full test runner commands.

## 🧪 graph slice

Holds the `Graph` state and the WS-driven mutation reducers.

### Core Functionality

| Area                            | Description                                                                |
| ------------------------------- | -------------------------------------------------------------------------- |
| Sync mutations                  | `deleteNode`, `connectNodes`, `disconnectEdge` apply via `utils/graph` helpers. |
| `generateInitial.fulfilled`     | Replaces the graph with the server's response.                             |
| `generateActions.fulfilled`     | Merges new action children into the parent narrative node.                 |
| `generateNarrative.fulfilled`   | Merges a narrative continuation under the source action.                    |
| `progressUpdate` reducer        | Replaces the graph with the snapshot from a server-pushed `progressUpdate`. |

### Edge Cases

| Case                                | Expected Behaviour                                              |
| ----------------------------------- | --------------------------------------------------------------- |
| `connectNodes` would create a cycle | Reducer rejects the mutation; state unchanged.                  |
| `deleteNode` on root                | Reducer rejects; root cannot be deleted.                        |
| Thunk rejected with `OpenAIRateLimit` | State unchanged; `error` populated.                            |

## 🧪 params slice

Holds generation knobs: temperature, descriptor, details, style, depth, action count.

### Core Functionality

| Area                  | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| Field setters         | One reducer per field, each immutably updates that field.    |
| Reset                 | `resetParams` returns to defaults.                           |

### Edge Cases

| Case                  | Expected Behaviour                                           |
| --------------------- | ------------------------------------------------------------ |
| Out-of-range temperature | Setter clamps to `[0, 1]`.                                |
| Negative depth        | Setter clamps to `0`.                                        |

## 🧪 loading slice

Tracks in-flight WS requests by `requestId`.

### Core Functionality

| Area                  | Description                                                            |
| --------------------- | ---------------------------------------------------------------------- |
| `wsRequestStarted`    | Adds the `requestId` to the in-flight set with the message type.       |
| `wsRequestSettled`    | Removes the `requestId` from the in-flight set.                        |
| Selector `isLoading`  | Returns `true` if any request of the queried type is in flight.        |

### Edge Cases

| Case                  | Expected Behaviour                                              |
| --------------------- | --------------------------------------------------------------- |
| Settled with unknown id | No-op; the in-flight set is unchanged.                        |

## 🧪 GeneratorPage

The orchestrator. Selects the active node, renders the canvas, options panel, and section views.

### Core Functionality

| Area                | Description                                                          |
| ------------------- | -------------------------------------------------------------------- |
| Mount fetch         | Dispatches `getStory(id)` on mount via `useEffect` on the URL param. |
| Selected node       | Clicking a node sets `state.graph.selectedId`; options panel updates. |
| Save dispatch       | `SaveButton` dispatches `saveGraph(id, graph)`.                      |

### Edge Cases

| Case                  | Expected Behaviour                                              |
| --------------------- | --------------------------------------------------------------- |
| Story id unknown      | Page redirects to `/dashboard`; toast surfaces 404.             |
| Story owned by another user | Same as above (backend returns 404; no leak).             |

## 🧪 GraphCanvas (`graph/`)

ReactFlow + dagre integration. Reads the `Graph` from the slice, lays it out, and dispatches selection / context-menu intents.

### Core Functionality

| Area                | Description                                                            |
| ------------------- | ---------------------------------------------------------------------- |
| Empty-graph fallback | Renders a "No content yet" message when `state.graph.graph.nodeLookup` is empty. |
| Populated render    | When the graph has nodes, renders `<ReactFlow>` with one node per `NodeData`. |
| ReactFlow mock      | Tests mock `@xyflow/react` and `./graphLayout` so jsdom does not need to handle canvas APIs. |

### Edge Cases

| Case                       | Expected Behaviour                                              |
| -------------------------- | --------------------------------------------------------------- |
| Active node id changes     | The `useEffect` re-applies the layout and marks the matching node `selected`. |

## 🧪 GraphContextMenu (`graph/`)

Right-click menu rendered at an absolute screen position. Conditionally shows `Expand`, `Disconnect`, and `Delete` based on which callbacks the caller supplies.

### Core Functionality

| Area                | Description                                                            |
| ------------------- | ---------------------------------------------------------------------- |
| Hidden when no position | When `position` is `null`, nothing is rendered.                    |
| Conditional items   | Only items whose callbacks are supplied appear in the dropdown.        |
| Item click          | Clicking an item fires its callback and then `onClose`.                |
| Click-outside       | A `mousedown` outside the menu fires `onClose`.                        |

### Edge Cases

| Case                | Expected Behaviour                                              |
| ------------------- | --------------------------------------------------------------- |
| All callbacks omitted | Menu opens but the dropdown body is empty.                    |

## 🧪 Other graph/ components

`GraphToolbar`, `FlowNodeNarrative`, `FlowNodeAction`, plus the `graphNodes` / `graphEdges` / `graphLayout` helpers — exercised through the `GeneratorPage` integration test rather than directly. See [`../../../tests/README.md#-what-we-test-and-what-we-dont`](../../../tests/README.md) for the rule.

### Core Functionality

| Area                 | Description                                                            |
| -------------------- | ---------------------------------------------------------------------- |
| `graphNodes` mapping | `Graph` → ReactFlow nodes, one entry per `NodeData`.                   |
| `graphEdges` mapping | `Graph` → ReactFlow edges, one entry per parent → child relationship.  |
| `graphLayout` dagre  | Returns deterministic positions for a given graph structure.           |
| Custom node render   | `FlowNodeNarrative` and `FlowNodeAction` render their respective sections. |

### Edge Cases

| Case                       | Expected Behaviour                                              |
| -------------------------- | --------------------------------------------------------------- |
| Empty graph                | `graphNodes` and `graphEdges` return empty arrays.              |
| Drag attempt on canvas     | ReactFlow's pan/zoom works; node drag is disabled.              |

## 🧪 options/ components

`NarrativeOptions`, `ActionOptions`, `NodeOptions`, `AdvancedOptionArea`. The right-panel UI for the selected node.

### Core Functionality

| Area                       | Description                                                            |
| -------------------------- | ---------------------------------------------------------------------- |
| Type-aware render          | Selecting a narrative shows `NarrativeOptions`; an action shows `ActionOptions`. |
| Generate-actions dispatch  | Button dispatches `generateActions` with the active node + count.       |
| Generate-narrative dispatch | Button dispatches `generateNarrative` with the active node + style flags. |
| Advanced toggle            | `AdvancedOptionArea` shows / hides the descriptor / details / style fields. |

### Edge Cases

| Case                  | Expected Behaviour                                              |
| --------------------- | --------------------------------------------------------------- |
| No node selected      | Panel renders an empty placeholder.                             |
| Generation in flight  | All "generate" buttons are disabled until the response arrives. |

## 🧪 section/ components

`NarrativeSection`, `ActionSection`. The inline read-only text rendered inside each node on the canvas.

### Core Functionality

| Area              | Description                                          |
| ----------------- | ---------------------------------------------------- |
| Render text       | Renders the node's `data` field as paragraph text.   |
| Ending badge      | `NarrativeSection` shows an "ending" badge when `isEnding === true`. |

### Edge Cases

| Case              | Expected Behaviour                                   |
| ----------------- | ---------------------------------------------------- |
| Empty `data`      | Renders a placeholder "No content yet".              |

## 🧪 Page-level controls

`SaveButton`, `DownloadButton`, `StoryTitle`, `LoadingInitialParagraph`.

### Core Functionality

| Area                       | Description                                                                |
| -------------------------- | -------------------------------------------------------------------------- |
| `SaveButton`               | Dispatches `saveGraph(id, graph)` on click; shows spinner while in flight. |
| `DownloadButton`           | Wraps `SplitButton`; primary navigates to the DOCX export URL, dropdown holds the TXT fallback. |
| `StoryTitle` edit          | Wraps `EditableField`; on commit, dispatches `updateStoryName`.            |
| `LoadingInitialParagraph`  | Renders a skeleton while `state.graph` is empty after `getStory.pending`.  |

### Edge Cases

| Case                       | Expected Behaviour                                              |
| -------------------------- | --------------------------------------------------------------- |
| `saveGraph.rejected`       | Toast surfaces error; local graph stays edited.                 |
| `updateStoryName` empty    | Save is blocked; inline error shows; previous title restored.   |

## 🧪 EditableField

Click-to-edit text wrapper used by `StoryTitle`. Page-local until a second consumer graduates it.

### Core Functionality

| Area                | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| Render value        | Renders the prop value as static text plus an edit icon.     |
| Click to edit       | Edit icon swaps the row to a `Textarea` seeded with the value. |
| Commit on icon click | Done icon fires `onCommit` with the new value when it differs from the prop. |

### Edge Cases

| Case               | Expected Behaviour                                          |
| ------------------ | ----------------------------------------------------------- |
| `disabled` prop    | Edit icon is disabled; row stays static text.               |
| Prop value changes | Internal draft re-syncs to the new prop and exits edit mode. |
| Commit equal value | `onCommit` is not fired when the draft matches the prop.    |

## 🧪 SplitButton

Primary button + chevron dropdown holding arbitrary children. Used by `DownloadButton`. Page-local until a second consumer graduates it.

### Core Functionality

| Area              | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| Render primary    | Renders the `text` prop as the primary `Button`.                  |
| Click primary     | Click fires `onClick` (unless `confirmation` is true).            |
| Open dropdown     | Click on the chevron opens a `Popover` containing `children`.     |
| Confirmation flow | When `confirmation` is true, the primary instead opens a confirm popover whose button fires `onClick`. |

### Edge Cases

| Case               | Expected Behaviour                                          |
| ------------------ | ----------------------------------------------------------- |
| `disabled` prop    | Both primary and chevron are non-interactive.               |
| Empty children     | Dropdown opens but renders an empty popover (caller's job). |
