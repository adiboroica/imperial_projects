# API

The only layer that talks to the backend. Typed HTTP and WebSocket clients underneath, per-domain call modules on top.

## 📋 Overview

Two kinds of files:

- **`clients/`** — typed `ApiClient` (HTTP) and typed WS client. The only callers of `fetch` and `WebSocket` in the entire frontend.
- **Domain modules** (`auth.ts`, `stories.ts`, `generation.ts`, `api_key.ts`) — per-domain wrappers that call the clients and return values typed against `types/`.

A page's slice imports from a domain module via `createAsyncThunk`; the domain module calls the underlying client; the client makes the network call.

## 🏗️ Structure

    api/
    ├── clients/                   ─ typed HTTP and WS clients (the only fetch / WebSocket callers)
    │   ├── http.ts
    │   └── ws.ts
    ├── auth.ts
    ├── stories.ts
    ├── generation.ts
    └── api_key.ts

## 📐 Design

- **`clients/` is the only network boundary** — no other file in `src/` calls `fetch` or `WebSocket`. Domain modules import from `clients/` exclusively.
- **Domain modules return typed values** — `stories.list()` returns `Promise<StoryListItem[]>`, not `Promise<unknown>`. The `ApiClient` does the JSON parse; domain functions narrow the result into the type from `types/`.
- **Errors are typed** — `ApiClient` translates HTTP statuses into generic typed errors (401 → `Unauthenticated`, 404 → `NotFound`, 409 → `Conflict`, 5xx → `ServerError`). Per-domain modules narrow these to specific names (`InvalidCredentials`, `StoryNotFound`, `EmailAlreadyExists`, `OpenAIUnavailable`) before they reach slices. Slices catch tagged objects, not raw `Response` instances.
- **Cookie credentials always included** — every HTTP call sets `credentials: "include"` so the `cyoa_session` cookie travels. The `ApiClient` enforces this at one point of configuration; per-domain modules never repeat it.
- **WS uses `requestId` correlation** — every client frame carries a UUID v4; the server echoes it on the response. The WS client maintains an in-flight map keyed by `requestId` and resolves the right Promise (or dispatches the right Redux action) when the matching response arrives.
- **WS payload types come from `types/`** — same shapes the backend Pydantic models declare. Compile-time validation catches protocol drift.
- **Export is a URL builder, not a fetch** — `stories.exportUrl(id, format)` returns a string suitable for `<a href={url} download>`. The browser handles the download natively; no Blob construction client-side.

## 🔗 Dependencies

Imports from [`../types`](../types). Never imports from `components/`, `pages/`, `store/`, or `utils/`.
