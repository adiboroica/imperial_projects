# Services

The orchestration layer — business rules, domain flows, and the seam between HTTP/WS handlers and persistence.

## 📋 Overview

Five services, each owning one bounded context:

- **`AuthService`** — signup, login, logout, session validation.
- **`StoryService`** — story CRUD (create, list, fetch, rename, delete, save graph).
- **`ApiKeyService`** — fetch and rotate the current user's OpenAI API key, encrypted at rest.
- **`GenerationService`** — orchestrates LLM and duplicate-detection calls to expand the story graph.
- **`ExportService`** — render a `Story` into DOCX or TXT bytes for download.

Services are classes constructed at start-up with their dependencies injected. Methods take and return Pydantic domain models from `models/`; HTTP and WebSocket envelopes are shaped by routers, not by services.

## 🏗️ Service Map

| Service             | Repository dependencies               | `ai/` dependencies                       |
| ------------------- | ------------------------------------- | ---------------------------------------- |
| `AuthService`       | `UserRepository`, `SessionRepository` | —                                        |
| `StoryService`      | `StoryRepository`                     | —                                        |
| `ApiKeyService`     | `UserRepository`                      | —                                        |
| `GenerationService` | —                                     | `LLMClient`, `TextGenerator`, `Analyser` |
| `ExportService`     | `StoryRepository`                     | —                                        |

`AuthService` uses `bcrypt` for password hashing internally; `ApiKeyService` uses `cryptography.Fernet` for symmetric encryption of stored API keys; `ExportService` uses `python-docx` for DOCX rendering and plain string assembly for TXT. None of these are shared helpers — each lives inside the service that needs it.

## 📐 Design

- **One service per bounded context** — a service owns one area. Cross-service flows (e.g., "signup also seeds a demo story") are composed in routers, not by having one service call another.
- **Services do not import other services** — if shared logic emerges, extract a helper; service-to-service imports are a sign the boundary is wrong.
- **Domain errors, not HTTP errors** — services raise `InvalidCredentials`, `StoryNotFound`, `OpenAIUnavailable`, etc. Routers translate those into `HTTPException` with the right status code.
- **No I/O on the HTTP/WS boundary** — services never touch FastAPI `Request` / `Response`, never send WebSocket frames, never read cookies. They return values; routers do the I/O.
- **Generation is stateless with respect to storage** — `GenerationService` operates on graphs passed in by the caller; it never reads from or writes to `StoryRepository`. The client holds authoritative state between WS messages and persists via the `PUT /stories/{id}/graph` endpoint.
- **Single-document atomicity only** — services do not coordinate multi-document transactions. If multi-document consistency becomes necessary, `repositories/` provides a `UnitOfWork` helper that a service accepts as a parameter.

## 🔗 Dependencies

Imports from `models/`, `repositories/`, and `ai/`. Never imports from `routers/`, `db.py`, `motor`, or `dependencies.py`.
