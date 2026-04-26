# Choose Your Own Adventure — Frontend

A React SPA that visualises an AI-generated story as an editable graph, served by Nginx and talking to the FastAPI backend over REST and WebSocket.

## 📋 Overview

A React 18 + TypeScript application built with Vite (the build tool and dev server). UI composition uses Mantine; graph visualisation uses ReactFlow; state lives in Redux Toolkit slices, with a WebSocket middleware bridging Redux actions to the backend's `/ws` channel. Stories are loaded from REST, expanded live through WS messages, and saved back via REST.

## 💻 Local Development

Two paths — Docker for parity with the production stack, host-native for the fastest hot-reload loop with Vite.

### With Docker

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up frontend --build
```

The dev override builds the frontend image's `dev` stage — Node 18 with the full Vite toolchain — and runs `vite dev --host 0.0.0.0` so changes hot-reload. The bare `docker compose up frontend` builds the `prod` stage instead, which produces the static bundle and serves it via Nginx (no hot reload).

### Without Docker

```bash
cd frontend
npm ci
npm run dev
```

The Vite dev server defaults to port `3000` and proxies `/api/*` and `/ws` to the backend. The simplest way to run the backend alongside it is `docker compose -f docker-compose.yml -f docker-compose.dev.yml up backend mongodb`.

## 🧪 Running Tests

`vitest` covers unit, slice, and architecture layers. Pick the Docker path for parity with CI, or the host path for the fastest feedback loop.

### With Docker

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm frontend npm test
```

### Without Docker

```bash
cd frontend
npm test              # vitest run
npm run test:watch    # vitest watch mode
```

## 📊 Test Coverage

```bash
npm run test:coverage
```

See [`tests/README.md`](tests/README.md) for the test strategy; each module's `README.tests.md` documents the contract for its own tests.

## 🔍 Dependency Audit

```bash
npm audit
```

## 🧹 Formatting & Lint

```bash
npm run format       # prettier --write
npm run lint         # eslint --max-warnings=0
npm run typecheck    # tsc --noEmit
```

## 📱 User Flows

New user:

1. Sign up on the landing page.
2. Provide a theme and attributes on the setup form.
3. Watch the root narrative and its first actions render live in the graph editor.
4. Expand nodes manually or run bulk expansion to a chosen depth.
5. Edit narrative text or action descriptions in place.
6. Save the story from the dashboard; export as DOCX or TXT.

Returning user:

1. Log in on the landing page.
2. Open an existing story from the dashboard.
3. Continue editing or generating new branches.
4. Save and export.

## 🔧 Configuration

Vite inlines build-time environment variables from `frontend/.env` into the JavaScript bundle. Only variables prefixed `VITE_` are exposed to client code. The relative defaults work in production because Nginx proxies `/api` and `/ws` to the backend on the same origin; override them only when running the dev server against a backend on a different host or port.

| Variable       | Required | Default | Description              |
| -------------- | -------- | ------- | ------------------------ |
| `VITE_API_URL` | no       | `/api`  | Backend REST base URL.   |
| `VITE_WS_URL`  | no       | `/ws`   | Backend WebSocket URL.   |

Project-wide variables (OpenAI key, encryption key, cookie secret) live at the root; see the [configuration table](../README.md#-configuration) in the root README.

## 📂 Sub-Module Documentation

- [`src/README.md`](src/README.md) — source layering: `api`, `components`, `features`, `pages`, `store`, `styles`, `types`, `utils`.
- [`tests/README.md`](tests/README.md) — test strategy (co-located unit tests, separate architecture tests).
