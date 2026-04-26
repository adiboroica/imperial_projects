# Choose Your Own Adventure — Backend

The FastAPI service that authenticates users, persists stories in MongoDB, and calls OpenAI to generate branching narratives.

## 📋 Overview

A Python 3.10 FastAPI application. It exposes a REST surface for auth, story CRUD, and API-key management, plus a WebSocket channel for streamed narrative generation. Persistence is MongoDB via `motor` (async). Generation uses OpenAI's Responses API with `sentence-transformers` embeddings to detect duplicate branches. All HTTP and WebSocket traffic arrives via the Nginx reverse proxy; the FastAPI port is never exposed publicly.

## 💻 Local Development

Two paths — Docker for parity with the production stack, host-native for fast iteration with hot reload.

### With Docker

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up backend --build
```

The dev override builds the backend image's `dev` stage (which includes `pytest`, `ruff`, `mypy`) and supplies the dev defaults for `ENCRYPTION_KEY`, `DEV=true`, and the demo MongoDB seed mount. The bare `docker compose up` form ships the slimmer `prod` stage and requires every secret env var to be supplied explicitly.

### Without Docker

```bash
cd backend
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

Runtime dependencies are pinned in `pyproject.toml` under `[project.dependencies]`; test, lint, and audit tooling lives in `[project.optional-dependencies.dev]`.

A MongoDB instance must be reachable at `DB_URL` (default `mongodb://localhost:27017`). Run one with:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up mongodb
```

## 🧪 Running Tests

`pytest` covers unit, integration, and architecture layers in a single invocation. Pick the Docker path for the same image the CI pipeline uses, or the host path for the fastest feedback loop.

### With Docker

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm backend pytest                      # all tests
docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm backend pytest tests/unit           # unit only
docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm backend pytest tests/integration    # integration only
```

### Without Docker

```bash
cd backend
pytest                      # all tests
pytest tests/unit           # unit only
pytest tests/integration    # integration only
```

Integration tests require a MongoDB instance; `docker compose -f docker-compose.yml -f docker-compose.dev.yml up mongodb` is the simplest fixture.

## 📊 Test Coverage

```bash
pytest --cov=src --cov-report=term-missing
```

See [`tests/README.md`](tests/README.md) for what each test layer covers.

## 🔍 Dependency Audit

```bash
pip-audit
```

Reads installed packages from the current environment, which in turn reflects the pinned set in `pyproject.toml`.

## 🧹 Formatting & Lint

```bash
ruff format src tests    # format
ruff check src tests     # lint
mypy src                 # type check
```

## 📡 REST API

All requests and responses are JSON with camelCase field names. The session cookie `cyoa_session` authenticates every request except `POST /auth/signup` and `POST /auth/login`.

### Auth

| Method | Path            | Description                             |
| ------ | --------------- | --------------------------------------- |
| POST   | `/auth/signup`  | Create an account and open a session.   |
| POST   | `/auth/login`   | Open a session for an existing account. |
| POST   | `/auth/logout`  | Close the current session.              |
| GET    | `/auth/session` | Return the current session's user info. |

### Stories

| Method | Path                                | Description                                                  |
| ------ | ----------------------------------- | ------------------------------------------------------------ |
| POST   | `/stories`                          | Create a new empty story.                                    |
| GET    | `/stories`                          | List the current user's stories.                             |
| GET    | `/stories/{id}`                     | Fetch a single story with its full graph.                    |
| PATCH  | `/stories/{id}`                     | Update the story's name.                                     |
| PUT    | `/stories/{id}/graph`               | Replace the story's graph.                                   |
| DELETE | `/stories/{id}`                     | Delete the story.                                            |
| GET    | `/stories/{id}/export?format=docx`  | Download the story as a DOCX file (`Content-Disposition: attachment`). |
| GET    | `/stories/{id}/export?format=txt`   | Download the story as a plain-text file.                     |

### API Key

| Method | Path       | Description                                           |
| ------ | ---------- | ----------------------------------------------------- |
| GET    | `/api-key` | Return the current user's decrypted OpenAI API key.   |
| PUT    | `/api-key` | Store or rotate the user's OpenAI API key (encrypted). |

## 🌐 WebSocket API

`WS /ws` — full-duplex channel for story generation. Authenticated by the same `cyoa_session` cookie; the server closes with code `4001` if the cookie is missing or invalid, and with `4003` if the `Origin` header does not match `APP_URL`.

Every client frame is a JSON envelope:

```json
{
  "requestId": "uuid-v4",
  "type": "initialStory | generateActions | addAction | generateNarrative | connectNode | generateMany",
  "payload": { }
}
```

The server echoes `requestId` on every response so the client can correlate in-flight requests. Response `type` values: `requestComplete`, `progressUpdate`, `error`, `rateLimitError`, `openaiError`, `nlpParseError`.

The per-message schema is documented in [`src/routers/README.md`](src/routers/README.md).

## 🔧 Configuration

Environment variables are defined at the project root; see the [configuration table](../README.md#-configuration) in the root README.

## 📂 Sub-Module Documentation

- [`src/README.md`](src/README.md) — source layering: `routers`, `services`, `repositories`, `ai`, `models`.
- [`tests/README.md`](tests/README.md) — test tree, running, coverage.
