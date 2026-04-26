# Model Unit Tests

Unit-test coverage for the Pydantic shapes in `src/models/` and the stateful `GamebookGraph` helper in `src/models/graph/`. Tests verify field validation, default values, serialisation round-trips, and — for the graph — structural integrity of node operations.

## 📋 Overview

Five test areas, one per subfolder in `src/models/`. Each sub-README carries `Core Functionality` and `Edge Cases` tables for its area. Tests for `errors.py` are omitted — the exception classes have no behaviour beyond inheritance.

- **[`auth/`](auth/README.md)** — User, Session, auth requests and responses.
- **[`stories/`](stories/README.md)** — Story domain, CRUD requests, list and full-fetch responses.
- **[`api_key/`](api_key/README.md)** — API-key request and response validation.
- **[`graph/`](graph/README.md)** — GamebookGraph, NarrativeNode, ActionNode.
- **[`ws/`](ws/README.md)** — WSEnvelope and per-message payload shapes.

## ▶️ Running

    pytest tests/unit/models                  # all model tests
    pytest tests/unit/models/auth             # auth only
    pytest tests/unit/models/stories          # stories only
    pytest tests/unit/models/api_key          # api_key only
    pytest tests/unit/models/graph            # graph only
    pytest tests/unit/models/ws               # ws only

## 📂 Sub-Module Documentation

- [`auth/README.md`](auth/README.md) — auth model tests.
- [`stories/README.md`](stories/README.md) — story model tests.
- [`api_key/README.md`](api_key/README.md) — API-key model tests.
- [`graph/README.md`](graph/README.md) — graph model tests.
- [`ws/README.md`](ws/README.md) — WebSocket model tests.
