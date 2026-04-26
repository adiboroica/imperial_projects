# Repositories

The backend's MongoDB I/O layer — the only code allowed to call Motor, the async Python driver for MongoDB.

## 📋 Overview

Three repositories, one per collection:

- **`StoryRepository`** — the `stories` collection. CRUD on a user's stories plus their graph.
- **`UserRepository`** — the `users` collection. Accounts, password hashes, encrypted API keys.
- **`SessionRepository`** — the `sessions` collection. Session cookies with TTL-indexed expiry.

Each repository is a class. An instance is built once on app start-up by `dependencies.py` and provided to services via FastAPI `Depends`. Methods take and return Pydantic models from `models/`; Motor cursors and raw `dict` objects never cross the repository boundary.

## 🏗️ Collections

| Collection  | Fields                                                        | Indexes                                              |
| ----------- | ------------------------------------------------------------- | ---------------------------------------------------- |
| `users`     | `email`, `passwordHash`, `apiKey` (encrypted, nullable)       | unique on `email`                                    |
| `sessions`  | `_id` (session UUID), `userEmail`, `createdAt`, `expiresAt`   | TTL on `expiresAt`, index on `userEmail`             |
| `stories`   | `_id`, `userEmail`, `name`, `graph`, `createdAt`, `updatedAt` | index on `userEmail`                                 |

All field names are camelCase on disk so they match the wire format directly; no alias conversion layer is needed between Pydantic and Motor.

## 📐 Design

- **Narrow domain methods, not generic CRUD** — repositories expose operations like `StoryRepository.save_graph(story_id, graph)` rather than raw `update_one`. Services never compose Mongo filters.
- **Domain models in, domain models out** — every method takes and returns Pydantic models from `models/`. Motor types do not cross the repository boundary.
- **Repositories are singletons** — constructed once per process with an injected `AsyncIOMotorDatabase`. FastAPI `Depends` re-uses the instance; a new one is not created per request.
- **Typed errors, not Motor exceptions** — repositories translate `DuplicateKeyError`, `PyMongoError`, etc. into domain errors like `EmailAlreadyExists` or `RepositoryError`. Callers never see `pymongo.errors`.
- **Indexes are declared in code** — each repository exposes an `ensure_indexes()` coroutine invoked once on app start-up by `main.py`'s lifespan. Indexes are never created implicitly.
- **No transactions** — single-document atomicity is the contract. Multi-document atomicity, if needed, is expressed as a `UnitOfWork` helper in this layer — never by services opening their own sessions.

## 🔗 Dependencies

Imports from `models/`, `db.py`, `motor`, and `pymongo`. Never imports from `services/`, `routers/`, `ai/`, or `dependencies.py`.
