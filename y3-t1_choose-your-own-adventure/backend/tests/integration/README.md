# Integration Tests

End-to-end tests of the HTTP and WebSocket surface. Each test drives a real FastAPI application through `httpx.AsyncClient` (for REST) or `websockets` (for WS), backed by a disposable MongoDB instance and a mocked OpenAI client.

## 📋 Overview

Four workflow areas, one per domain. Each sub-README documents that area's end-to-end cases as a single table, covering happy path and expected errors together.

- **[`auth/`](auth/README.md)** — signup, login, logout, session validation.
- **[`stories/`](stories/README.md)** — story CRUD and graph persistence.
- **[`api_key/`](api_key/README.md)** — fetch and rotate the user's OpenAI key.
- **[`ws/`](ws/README.md)** — WebSocket message flows and close-code behaviour.

## ▶️ Running

    pytest tests/integration                   # all integration tests
    pytest tests/integration/auth              # auth workflows
    pytest tests/integration/stories           # story CRUD
    pytest tests/integration/api_key           # API-key endpoints
    pytest tests/integration/ws                # WebSocket flows

## 📐 Conventions

- **Real MongoDB, mocked OpenAI** — each test run spins up a disposable database; the `mocked_openai` fixture scripts OpenAI responses before each test.
- **Tests assert on side-effects, not just responses** — after a `POST /stories` the test verifies the document exists; after a `DELETE` it verifies absence. A 200 response alone is not enough.
- **One fresh session per test** — fixtures open a fresh login for each test and tear the session down afterwards; no shared auth state between tests.
- **WS tests script the LLM in advance** — the canned OpenAI response is set on the `mocked_openai` fixture before the socket opens; tests do not race network and mock setup.

## 📂 Sub-Module Documentation

- [`auth/README.md`](auth/README.md) — auth workflow table.
- [`stories/README.md`](stories/README.md) — story CRUD and graph workflow table.
- [`api_key/README.md`](api_key/README.md) — API-key workflow table.
- [`ws/README.md`](ws/README.md) — WebSocket workflow table.
