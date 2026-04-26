# Choose Your Own Adventure

An AI-powered gamebook generator that turns a theme and a handful of attributes into a branching, explorable story graph. Built as an Imperial College London group project.

> See [screenshots](README.screenshots.md) for a visual overview of the app.

## 📋 Overview

Choose Your Own Adventure (CYOA) is a web application for authoring interactive gamebook-style narratives with large-language-model assistance. The user supplies a genre and a set of attributes (characters, items, setting); the system generates a rooted branching story tree that can be explored, edited node-by-node, and exported. A React SPA, a FastAPI backend, and MongoDB sit behind a single Nginx entry point; OpenAI handles generation and `sentence-transformers` catches duplicate branches.

## ✨ Features

- **AI story generation** — turns a theme plus attributes into a rooted branching narrative.
- **Interactive graph editor** — renders the story as a flow diagram; nodes can be inspected, edited, or removed.
- **Node-by-node expansion** — generate a single action, a narrative continuation, or an ending from any leaf.
- **Bulk expansion** — auto-expand an entire subtree to a chosen depth.
- **Story management** — save, load, rename, and delete stories from a personal dashboard.
- **Export** — download a finished story as DOCX or TXT.
- **Duplicate detection** — embeddings collapse semantically similar branches into endings instead of redundant forks.

## 🚀 Getting Started

**Prerequisites**: [Docker](https://docs.docker.com/get-docker/) and an [OpenAI API key](https://platform.openai.com/api-keys).

```bash
git clone https://github.com/<your-username>/choose-your-own-adventure.git
cd choose-your-own-adventure
cp .env.example .env
# edit .env — set OPENAI_API_KEY
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

Open [http://localhost:3000](http://localhost:3000) and sign in with the demo account below.

To stop:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml down
```

## 🔑 Demo Account

`docker-compose.dev.yml` mounts `backend/mongo-init/seed.js` into MongoDB, which seeds a single demo user the first time the database starts. Use it to skip the signup form and land on a dashboard that already has two sample stories:

| Field        | Value                |
| ------------ | -------------------- |
| **Email**    | `demo@example.com`   |
| **Password** | `password`           |

Sample stories on the demo dashboard:

- **The Crystal Caverns** — fantasy, 5 sections.
- **Station Omega** — sci-fi, 1 section.

> The demo account exists in dev mode only. Production (`docker compose up`) ships without the seed mount and refuses to start unless every secret env var is set explicitly.

## 💻 Development

The development command above layers `docker-compose.dev.yml` over the production `docker-compose.yml`. The override supplies dev defaults for `ENCRYPTION_KEY`, mounts the demo seed into MongoDB, sets `DEV=true`, and builds the backend image's `dev` stage so `pytest`, `ruff`, and `mypy` are available inside the container. Production (`docker compose up`) requires every secret env var to be supplied explicitly and ships the slimmer `prod` stage with no dev tooling.

For live reload and non-Docker setups, see the component READMEs:

- [`backend/README.md`](backend/README.md) — FastAPI dev server, test harness, API surface.
- [`frontend/README.md`](frontend/README.md) — Vite dev server, Vitest harness, user flows.

## 🧪 Running Tests

Backend:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm backend pytest
```

Frontend:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm frontend npm test
```

Non-Docker invocations and coverage reports are in the component READMEs.

## 🔧 Configuration

| Variable         | Required (prod) | Dev default                         | Description                                                                  |
| ---------------- | --------------- | ----------------------------------- | ---------------------------------------------------------------------------- |
| `OPENAI_API_KEY` | yes             | empty                               | OpenAI API key. Comma-separated values rotate per request.                   |
| `OPENAI_MODEL`   | no              | `gpt-5.4`                           | OpenAI model used for generation.                                            |
| `ENCRYPTION_KEY` | yes             | `dev-only-not-secure-change-me-now` | Symmetric key used to encrypt user-stored API keys in MongoDB.               |
| `APP_URL`        | yes             | `http://localhost:3000`             | Canonical SPA origin — the WS handler closes 4003 if `Origin` does not match. |
| `DEV`            | no              | `true` (in `docker-compose.dev.yml`) | When true, bypasses the production env-var fail-fast.                        |

## 🛠️ Tech Stack

| Layer              | Technologies                                                     |
| ------------------ | ---------------------------------------------------------------- |
| **Frontend**       | React 18, TypeScript, Vite (build tool and dev server), Redux Toolkit, ReactFlow, Mantine UI |
| **Backend**        | Python 3.10, FastAPI, Uvicorn, Motor (async MongoDB driver)      |
| **AI / ML**        | OpenAI Responses API, `sentence-transformers`, PyTorch           |
| **Infrastructure** | Docker Compose, Nginx, MongoDB 6                                 |

Unfamiliar with any of these? [`README.tech-stack.md`](README.tech-stack.md) is a short primer on every library in the stack, plus two end-to-end flows showing how they interact.

## 🏗️ Architecture

All browser traffic terminates at a single Nginx entry point on port `3000`. Static assets are served directly; `/api/*` and `/ws` are reverse-proxied to the FastAPI backend on the internal Docker network. The backend is never exposed to the public network.

```
    Browser
       │
       ▼
    Nginx :3000                       ← static React SPA + reverse proxy
       │
       ├── /api/* ──▶ FastAPI :8000 ──┬──▶ MongoDB       ← users, sessions, stories
       │                               └──▶ OpenAI API   ← generation
       │
       └── /ws ────▶ FastAPI WS ─────▶ (same dependencies)
```

For the internal layering inside each service, see [`backend/src/README.md`](backend/src/README.md) and [`frontend/src/README.md`](frontend/src/README.md).

## 📂 Sub-Module Documentation

- [`backend/README.md`](backend/README.md) — FastAPI service: local dev, tests, REST and WebSocket surface.
- [`frontend/README.md`](frontend/README.md) — React SPA: local dev, tests, user flows.
- [`README.tech-stack.md`](README.tech-stack.md) — primer on every library, framework, and piece of infrastructure in the stack (read this if anything in the architecture READMEs is unfamiliar).
- [`README.screenshots.md`](README.screenshots.md) — captioned screenshots and GIFs.

## ⚠️ Known Limitations

- **Backend image size** — PyTorch and `sentence-transformers` push the image to ~2–3 GB; the first build downloads model weights.
- **OpenAI as single point of failure** — generation has no fallback provider if the OpenAI API is unavailable.
- **Free-tier rate limits** — free-tier OpenAI keys trip the per-minute limit before the generator's retries exhaust.

## 📝 Docs Drift

Module READMEs describe the state of the code at their last update. When responsibilities shift, run `git log -- <path>/` to see what has changed recently — the README may be behind.
