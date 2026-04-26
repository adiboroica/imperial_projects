# Backend Tests

Unit and integration tests for the FastAPI service, running under `pytest` and `pytest-asyncio`.

## 📋 Overview

Three layers:

- **Unit tests** — services, repositories, `ai/` primitives, and domain models in isolation. No network, no real MongoDB; dependencies are mocked or supplied with test doubles.
- **Integration tests** — HTTP and WebSocket flows end-to-end through the router layer. Real MongoDB (a disposable test database spun up per run); OpenAI is mocked.
- **Architecture tests** — `import-linter` contracts that enforce the layering rules in [`src/README.md`](../src/README.md). A pytest wrapper invokes `lint-imports`, so violations show up in the same test run as any other failure.

## ▶️ Running

    pytest                          # unit + integration + architecture
    pytest tests/unit               # unit only
    pytest tests/integration        # integration only
    pytest tests/architecture       # architecture only
    pytest tests/unit/services      # single layer
    pytest --cov=src                # with coverage

Integration tests need a MongoDB instance. `docker compose -f docker-compose.yml -f docker-compose.dev.yml up mongodb` is the simplest fixture outside Docker; inside Docker, `docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm backend pytest` pulls it in automatically.

## 🏗️ Tree

    tests/
    ├── conftest.py               ─ shared fixtures (event loop, mocked OpenAI, TestClient)
    ├── unit/
    │   ├── services/             ─ per-service unit tests
    │   ├── repositories/         ─ per-repository unit tests
    │   ├── ai/                   ─ LLMClient, Analyser, TextGenerator
    │   └── models/               ─ graph domain + request/response validators
    ├── integration/
    │   ├── auth/                 ─ signup, login, logout, session lookup
    │   ├── stories/              ─ REST story CRUD + graph save
    │   ├── api_key/              ─ GET/PUT /api-key
    │   └── ws/                   ─ WebSocket message flows
    └── architecture/
        ├── .importlinter         ─ contract definitions
        ├── dependency_test.py    ─ pytest wrapper that invokes lint-imports
        └── README.md             ─ catalogue of contracts

## 📐 Conventions

- **Framework** — `pytest` for discovery, `pytest-asyncio` for async test functions (`@pytest.mark.asyncio`).
- **Fixtures live in `conftest.py`** — at the tree root for cross-layer fixtures; at each sub-folder for layer-specific ones (e.g., integration `TestClient` with a fresh DB).
- **One test file per code unit** — `tests/unit/services/test_story.py` covers `services/story.py`. The test tree mirrors `src/`.
- **Integration tests use a disposable database** — each run gets a fresh Mongo database named with a UUID; the database is dropped on teardown. No cross-test state.
- **OpenAI is always mocked** — real OpenAI calls cost money and are flaky. The `mocked_openai` fixture replaces `LLMClient`'s OpenAI handle with a recorder that returns scripted responses.
- **Async-first** — every test that exercises an async code path is itself async. No `asyncio.run()` inside test bodies.

## 📂 Sub-Module Documentation

- [`unit/README.md`](unit/README.md) — per-layer unit-test coverage with `Core Functionality` and `Edge Cases` tables.
- [`integration/README.md`](integration/README.md) — per-flow integration-test workflow tables.
- [`architecture/README.md`](architecture/README.md) — `import-linter` contracts that enforce the `src/` layering.
