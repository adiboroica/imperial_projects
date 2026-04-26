# Utils Tests

Test contract for the pure graph helpers in `utils/graph/`.

## 📋 Overview

Two units. Test files co-located alongside source. Every function in `utils/` is pure — tests pass `Graph` literals in and assert on the returned value; no mocks needed.

## ▶️ Running

    npm test -- src/utils

See [`../../tests/README.md`](../../tests/README.md) for the full test runner commands.

## 🧪 graphUtils

Traversal, mutation, validation, and type-guard helpers operating on the in-memory `Graph`.

### Core Functionality

| Area                       | Description                                                                |
| -------------------------- | -------------------------------------------------------------------------- |
| `findParent`               | Walks the graph from root and returns the parent of the given node id.     |
| `deleteNodeFromGraph`      | Returns a new graph with the node and its descendants removed.             |
| `connectNodesOnGraph`      | Returns a new graph with the new edge added.                               |
| `disconnectEdgeOnGraph`    | Returns a new graph with the edge removed.                                 |
| `isValidConnectNodes`      | Returns `true` when the proposed edge does not create a cycle.             |
| `isValidDeleteEdge`        | Returns `true` when removing the edge does not orphan a needed branch.     |
| `isNarrative` / `isAction` | Type guards on `NodeData.type`.                                            |
| `isGraphEmpty`             | `true` when the graph has zero nodes.                                      |

### Edge Cases

| Case                                 | Expected Behaviour                                              |
| ------------------------------------ | --------------------------------------------------------------- |
| `findParent` on root                 | Returns `null`.                                                 |
| `findParent` on disconnected node    | Returns `null`.                                                 |
| `deleteNodeFromGraph` on root        | Returns the original graph unchanged.                           |
| `connectNodesOnGraph` creating cycle | Returns the original graph unchanged.                           |
| Mutation on empty graph              | All mutation helpers return the empty graph unchanged.          |
| Immutability                         | None of the helpers mutate the input graph; the returned value is a new object. |

## 🧪 storyUtils

Graph-to-prose conversion for export and previews.

### Core Functionality

| Area                         | Description                                                                |
| ---------------------------- | -------------------------------------------------------------------------- |
| `storyToExportableText`      | Walks the graph in traversal order, returns a string of narrative paragraphs separated by action lines. |
| First-paragraph extraction   | Returns the root narrative's text for use in `StoryListItem` previews.     |

### Edge Cases

| Case                              | Expected Behaviour                                          |
| --------------------------------- | ----------------------------------------------------------- |
| Empty graph                       | Returns an empty string; no errors.                         |
| Branching paths                   | Visits each branch in deterministic depth-first order.       |
| Multiple endings                  | Each ending is rendered with a sentinel marker (e.g., "[End]"). |
