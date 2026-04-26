# Routers

The HTTP and WebSocket boundary. Routers validate request shape, authenticate via FastAPI `Depends`, call services, and translate domain errors into HTTP responses or WebSocket error frames.

## 📋 Overview

Four router modules, one per domain:

- **`auth.py`** — signup, login, logout, session lookup.
- **`stories.py`** — story CRUD and graph persistence.
- **`api_key.py`** — read and write the user's OpenAI API key.
- **`ws.py`** — the `/ws` WebSocket endpoint for story generation.

Endpoint tables for the REST surface are in [`backend/README.md`](../../README.md). This README fills in the WebSocket protocol detail and the cross-cutting design rules that apply to every router.

## 🌐 WebSocket Protocol

`WS /ws` — full-duplex channel. The `cyoa_session` cookie authenticates the handshake **and is re-validated before every message** so a logout (which deletes the session record server-side) closes the existing socket on its next frame with code `4001`. The server closes with `4001` if the cookie is missing or invalid at any point, and with `4003` if the `Origin` header does not match `APP_URL`.

Every frame is a JSON envelope:

```json
{
  "requestId": "uuid-v4",
  "type": "<message type>",
  "payload": { }
}
```

The server echoes the client's `requestId` on every response so concurrent in-flight messages can be correlated. Malformed frames — missing `requestId`, unknown `type`, or a payload that fails Pydantic validation — close the connection with code `1003`.

### Client-to-server messages

`numActions` and `depth` are bounded server-side at `1..4` — the worst-case branching of `generateMany` would otherwise cost an unbounded number of LLM calls. `services/generation.py` enforces an additional `MAX_GENERATE_MANY_NODES = 64` budget that short-circuits the BFS when reached.

| `type`              | Purpose                                                        | Payload fields                                                              |
| ------------------- | -------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `initialStory`      | Generate the root narrative and its first actions.             | `genre`, `attributes`, `temperature`                                        |
| `generateActions`   | Expand a narrative node with `numActions` action children.     | `graph`, `nodeId`, `numActions` (1-4), `temperature`                        |
| `addAction`         | Add more action children to a narrative that already has some. | `graph`, `nodeId`, `numActions` (1-4), `temperature`                        |
| `generateNarrative` | Expand an action node with a narrative continuation.           | `graph`, `nodeId`, `temperature`, optional `descriptor`, `details`, `style` |
| `connectNode`       | Generate bridging narrative between two existing nodes.        | `graph`, `sourceId`, `targetId`, `temperature`                              |
| `generateMany`      | Bulk-expand a subtree to a given depth.                        | `graph`, `nodeId`, `depth` (1-4), `numActions` (1-4), `temperature`         |

### Server-to-client messages

| `type`            | Purpose                                                                               |
| ----------------- | ------------------------------------------------------------------------------------- |
| `requestComplete` | Operation finished; payload carries the full updated graph.                           |
| `progressUpdate`  | Partial update during `generateMany`; payload carries the current graph snapshot.     |
| `error`           | Unexpected server-side error; payload carries a human-readable message.               |
| `rateLimitError`  | OpenAI returned 429; the client may retry after backoff.                              |
| `openaiError`     | OpenAI unavailable (503) or connection failed.                                        |
| `nlpParseError`   | Generated response could not be parsed as the expected format after internal retries. |

## 📐 Design

- **Routers are thin** — each handler is a few lines: parse the request, call a service, shape the response. Business logic lives in `services/`, never in a router.
- **Auth via FastAPI `Depends`** — every protected endpoint takes `current_user: User = Depends(get_current_user)`. Public endpoints (signup, login) declare no auth dependency.
- **Domain errors map to HTTP status** — routers catch typed errors from services (`InvalidCredentials` → 401, `StoryNotFound` → 404, `EmailAlreadyExists` → 409, `OpenAIUnavailable` → 503) and raise the corresponding `HTTPException`. Services never raise `HTTPException` themselves.
- **Response bodies use Pydantic response models** — no raw `dict` returns; every endpoint declares `response_model=...` so OpenAPI docs stay accurate.
- **Rate limiting via `slowapi`** — login and signup carry per-IP limits (10/min and 5/min respectively); the limiter is configured in `main.py` and applied with a decorator.
- **CORS is locked to `APP_URL`** — configured in `main.py`, not in individual routers.
- **WebSocket messages validate with Pydantic** — each client `type` has a Pydantic envelope; the connection closes with code `1003` on validation failure.
- **`requestId` is required on every WebSocket frame** — messages without it are rejected; responses always echo the incoming `requestId`.

## 🔗 Dependencies

Imports from `models/`, `services/`, and `dependencies.py`. Never imports from `repositories/`, `ai/`, `db.py`, or `motor` directly.
