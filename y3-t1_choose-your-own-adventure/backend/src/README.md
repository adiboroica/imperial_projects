# Backend Source

The FastAPI source tree, organised as strict top-down layers from the HTTP boundary down to persistence and the OpenAI client.

## 📋 Overview

The backend source is organised as five top-down layers plus a small set of wiring modules.

**Layers** (each with its own README):

- **`routers/`** — HTTP and WebSocket surface.
- **`services/`** — business rules and orchestration.
- **`repositories/`** — the only layer that touches MongoDB.
- **`ai/`** — OpenAI client, prompt templates, and the duplicate analyser.
- **`models/`** — Pydantic shapes shared across every layer.

**Wiring** (single-file modules at the tree root):

- **`main.py`** — FastAPI app entrypoint; lifespan hooks, middleware, router mounting.
- **`db.py`** — Motor client singleton.
- **`config.py`** — environment-variable accessors.
- **`dependencies.py`** — FastAPI `Depends` helpers for auth and session lookup.

## 🏗️ Dependency Hierarchy

    models/         ← no internal dependencies
    ai/             ← imports models/, config.py
    repositories/   ← imports models/, db.py
    services/       ← imports models/, repositories/, ai/
    routers/        ← imports models/, services/, dependencies.py

## 📐 Dependency Rules

- **`models/` is the leaf** — imports from `pydantic` and the standard library; never imports from any other `src/` module.
- **`ai/` is self-contained** — imports from `models/` and `config.py`; never imports from `routers/`, `services/`, or `repositories/`.
- **`repositories/` is the only MongoDB caller** — imports from `models/` and `db.py`; never imports from `services/`, `routers/`, or `ai/`.
- **`services/` is the orchestration layer** — imports from `models/`, `repositories/`, and `ai/`; never imports from `routers/`, `db.py`, or `motor` directly. Persistence flows through `repositories/` only.
- **`routers/` stays thin** — imports from `models/`, `services/`, and `dependencies.py`; never touches `motor`, OpenAI clients, or other third-party I/O directly.
- **No circular imports between layers** — the hierarchy is strict; any cycle means a layer is misplaced.

## 📂 Sub-Module Documentation

- [`routers/`](routers/README.md) — REST and WebSocket endpoint surface.
- [`services/`](services/README.md) — business rules and orchestration.
- [`repositories/`](repositories/README.md) — MongoDB I/O contract.
- [`ai/`](ai/README.md) — LLM client, prompt templates, duplicate analyser.
- [`models/`](models/README.md) — request, response, and domain shapes.
