# Graph Model Tests

Unit-test coverage for `GamebookGraph`, `NarrativeNode`, and `ActionNode` in `src/models/graph/`.

## 📋 Overview

`GamebookGraph` holds the only stateful logic in `src/models/` — node creation, parent tracking, cycle detection, and traversal. Tests verify both the Pydantic shape of the node models and the graph's structural operations.

## ▶️ Running

See [`../README.md`](../README.md#-running) for the test commands.

## 🧪 Core Functionality

| Area                     | Description                                                                 |
| ------------------------ | --------------------------------------------------------------------------- |
| `NarrativeNode`          | `nodeId`, `data`, `childrenIds`, `isEnding`, `type="narrative"`.            |
| `ActionNode`             | `nodeId`, `data`, `childrenIds`, `type="action"`.                           |
| Serialisation round-trip | `from_graph_dict(to_graph_dict(g))` produces an equal graph.                |
| `make_narrative_node`    | Appends a narrative child, bumps `next_node_id`, registers the parent edge. |
| `make_action_node`       | Same as narrative but with `type="action"`.                                 |
| `connect_nodes`          | Adds an edge from parent to child when no cycle results.                    |
| `get_paragraph_list`     | Walks `parent_lookup` from a node back to the root.                         |
| Type guards              | `is_narrative`, `is_action`, `is_ending` dispatch on `type`.                |

## 🧪 Edge Cases

| Case                                                  | Expected Behaviour                                     |
| ----------------------------------------------------- | ------------------------------------------------------ |
| `connect_nodes` that would create a cycle             | Raises `CycleError`; graph is unchanged.               |
| `make_narrative_node` on an unknown parent            | Raises `NodeNotFound`.                                 |
| `from_graph_dict` with duplicate node ids             | Raises `ValidationError`.                              |
| `from_graph_dict` with an orphan child reference      | Raises `ValidationError`.                              |
| `from_graph_dict` with a structural cycle             | Raises `ValidationError` (caught at construction).     |
| `from_graph_dict` with > `MAX_NODES` (1024) nodes     | Raises `ValidationError`.                              |
| `from_graph_dict` with `data` over 4096 chars         | Raises `ValidationError`.                              |
| Action node with a non-narrative child                | Raises `ValidationError` at construction.              |
| `validate_persisted` on graph without root id `0`     | Raises `ValueError("Persisted graph has no root…")`.   |
| `validate_persisted` on graph whose root is an action | Raises `ValueError("Root node (node_id=0) must be narrative")`. |
| `validate_persisted` on graph with unreachable nodes  | Raises `ValueError("Persisted graph has unreachable…")`. |
| `get_paragraph_list` on a disconnected node           | Returns a list containing only that node.              |
| Empty graph                                           | `to_graph_dict` returns `{"nodes": []}` without error. |
