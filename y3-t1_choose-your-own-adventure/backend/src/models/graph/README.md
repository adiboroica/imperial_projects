# Graph Models

`GamebookGraph`, `NarrativeNode`, and `ActionNode` — the single shape shared across domain, storage, and wire.

## 📋 Overview

Graph models are identical whether the reader is a service, a Mongo document, or a WebSocket payload. The Pydantic classes live here; no separate wire or storage representation is needed.

## 🏗️ Structure

    graph/
    └── domain.py       ─ GamebookGraph, NarrativeNode, ActionNode

## 📐 Design

- **`GamebookGraph` is the only stateful model** — it owns `node_lookup`, `parent_lookup`, and `next_node_id`. All other models in `src/models/` are pure data.
- **Node type is a discriminator** — `NarrativeNode` and `ActionNode` share a `type` literal (`"narrative"` / `"action"`) so Pydantic picks the right class when deserialising a heterogeneous node list.
- **Construction-time invariants** — every `model_validate` (FastAPI request bodies, WS payloads) runs `_validate_structure`, which rejects duplicate node ids, missing child references, action nodes with non-narrative children, cycles, graphs over `MAX_NODES = 1024`, and node `data` over `MAX_NODE_DATA_LENGTH = 4096` chars. Narrative→narrative edges are allowed because `bridge_node` splices a generated narrative bridge between two narratives.
- **Persisted-graph invariants** — `validate_persisted()` adds the stricter checks called only at trust boundaries (`PUT /stories/{id}/graph`): node id `0` exists and is narrative, every node is reachable from the root via BFS. Service-layer code that builds graphs incrementally must not call this until the build is complete.
- **DAG enforced on mutation too** — `connect_nodes` runs a cycle check before adding an edge; `make_narrative_node` and `make_action_node` check the parent exists.
- **Node ids are monotonic integers** — `next_node_id` starts at `max(existing_ids) + 1` and advances on every create. Ids are never reused.
- **Only `NarrativeNode` can be an ending** — `isEnding` is a field on narrative nodes only; action nodes are never leaves.

## 🔗 Dependencies

Imports from `pydantic` and the standard library only. Never imports from any other `src/` module.
