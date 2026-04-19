# API Client

HTTP client layer for communicating with the Keep Playing backend.

## 📋 Overview

A base `ApiClient` handles token management, JSON encoding, and error checking. Domain-specific classes (`ApiCoach`, `ApiOrganiser`, `ApiUsers`) wrap it with typed methods that return deserialized models. The base URL is configured at compile time via `--dart-define=API_BASE_URL`.

## 🏗️ Design

- **Dependency injection** — `ApiClient` accepts an optional `http.Client`, defaulting to `http.Client()`. Domain classes accept an `ApiClient`. This makes everything testable with mock clients.
- **Token management** — `setToken(token)` stores the auth token. When set, all requests include `Authorization: Token <token>` automatically. `setToken(null)` clears it.
- **`_checkResponse` throws on 4xx/5xx** — all methods except `postForm` pass through `_checkResponse`, which throws `ApiException` on error status codes.
- **`postForm` skips error checking** — used for login, where the caller inspects the response status directly (login returns 400 on invalid credentials, not an exception).
- **`getList` / `getOne` typed deserialization** — generic helpers that call `get()` and deserialize via a `fromJson` callback, eliminating boilerplate in domain classes.
- **Coach sign-up uses `MultipartRequest`** — `signUpAsCoach` sends a multipart form (not JSON) to support the optional qualification image upload. Organiser sign-up uses standard JSON.

## 🔗 Dependencies

Imports from `models/` and the `http` package. Implements the repository interfaces defined in `repositories/`. Never imported directly by `state/` or `pages/` — the wiring happens at the app root via dependency injection.

See [lib/README.md](../README.md) for the full dependency hierarchy.
