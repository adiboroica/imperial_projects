# API Tests

Test contract for the API layer: typed HTTP and WS clients plus the per-domain call modules.

## 📋 Overview

Six units. Test files co-located alongside source. The HTTP and WS clients mock at the global `fetch` / `WebSocket` level; per-domain modules mock the underlying client.

## ▶️ Running

    npm test -- src/api

See [`../../tests/README.md`](../../tests/README.md) for the full test runner commands.

## 🧪 ApiClient (`clients/http.ts`)

Typed HTTP wrapper around `fetch`. Owns credentials, JSON parsing, and error mapping.

### Core Functionality

| Area               | Description                                                                              |
| ------------------ | ---------------------------------------------------------------------------------------- |
| Cookie credentials | Every request sets `credentials: "include"`.                                             |
| JSON parse         | Successful responses are parsed and returned typed.                                      |
| Error translation  | 401 → `Unauthenticated`; 404 → `NotFound`; 409 → `Conflict`; 5xx → `ServerError`.        |

### Edge Cases

| Case                   | Expected Behaviour                                               |
| ---------------------- | ---------------------------------------------------------------- |
| Network failure        | Throws `NetworkError`; no JSON parse attempted.                  |
| Non-JSON response body | Throws `ParseError`.                                             |
| 422 validation         | Throws `ValidationError` with the backend's field-level details. |

## 🧪 WSClient (`clients/ws.ts`)

Typed WebSocket wrapper. Owns the connection, the envelope, and `requestId` correlation.

### Core Functionality

| Area                   | Description                                                                         |
| ---------------------- | ----------------------------------------------------------------------------------- |
| Connect                | Opens a WS to `VITE_WS_URL` with the session cookie.                                |
| Send + correlate       | `send(envelope)` returns a Promise that resolves on the matching `requestComplete`. |
| Server-pushed dispatch | `progressUpdate` frames trigger registered callbacks (used by `wsMiddleware`).      |
| Close codes surfaced   | `4001` (auth), `4003` (origin), `1003` (validation) are translated to typed errors. |

### Edge Cases

| Case                                     | Expected Behaviour                                  |
| ---------------------------------------- | --------------------------------------------------- |
| Server response with unknown `requestId` | Frame is ignored; no Promise resolution.            |
| Connection closes mid-request            | All in-flight Promises reject with `WSClosedError`. |
| `nlpParseError` frame                    | Matching Promise rejects with `NlpParseError`.      |

## 🧪 auth.ts

Domain wrappers for `/auth/*`.

### Core Functionality

| Area      | Description                                                            |
| --------- | ---------------------------------------------------------------------- |
| `login`   | Calls `POST /auth/login`; returns `User`.                              |
| `signup`  | Calls `POST /auth/signup`; returns `User`.                             |
| `logout`  | Calls `POST /auth/logout`; returns void.                               |
| `session` | Calls `GET /auth/session`; returns `User` or throws `Unauthenticated`. |

### Edge Cases

| Case                             | Expected Behaviour                                          |
| -------------------------------- | ----------------------------------------------------------- |
| `login` returns 401              | Narrows generic `Unauthenticated` to `InvalidCredentials`.  |
| `signup` returns 409             | Narrows generic `Conflict` to `EmailAlreadyExists`.         |
| Backend returns 401 on `session` | Throws `Unauthenticated` typed error.                       |

## 🧪 stories.ts

Domain wrappers for `/stories/*`.

### Core Functionality

| Area         | Description                                                  |
| ------------ | ------------------------------------------------------------ |
| `create`     | Calls `POST /stories`; returns the new story id.             |
| `list`       | Calls `GET /stories`; returns `StoryListItem[]`.             |
| `getById`    | Calls `GET /stories/{id}`; returns the full `Story`.         |
| `updateName` | Calls `PATCH /stories/{id}`.                                 |
| `saveGraph`  | Calls `PUT /stories/{id}/graph`.                             |
| `delete`     | Calls `DELETE /stories/{id}`.                                |
| `exportUrl`  | Returns the export URL string for `<a href={url} download>`. |

### Edge Cases

| Case            | Expected Behaviour                        |
| --------------- | ----------------------------------------- |
| `getById` 404   | Throws `StoryNotFound`.                   |
| `saveGraph` 422 | Throws `InvalidGraph` with field details. |

## 🧪 generation.ts

Domain wrappers for WS-based generation flows.

### Core Functionality

| Area                | Description                                                               |
| ------------------- | ------------------------------------------------------------------------- |
| `generateInitial`   | Sends an `initialStory` envelope; awaits `requestComplete`.               |
| `generateActions`   | Sends a `generateActions` envelope; awaits `requestComplete`.             |
| `generateNarrative` | Sends a `generateNarrative` envelope; awaits `requestComplete`.           |
| `connectNodes`      | Sends a `connectNode` envelope.                                           |
| `addAction`         | Sends an `addAction` envelope.                                            |
| `generateMany`      | Sends a `generateMany` envelope; resolves on the final `requestComplete`. |

### Edge Cases

| Case                            | Expected Behaviour                    |
| ------------------------------- | ------------------------------------- |
| Server returns `rateLimitError` | Throws `OpenAIRateLimit` typed error. |
| Server returns `openaiError`    | Throws `OpenAIUnavailable`.           |
| Server returns `nlpParseError`  | Throws `NlpParseError`.               |

## 🧪 api_key.ts

Domain wrappers for `/api-key`.

### Core Functionality

| Area  | Description                                     |
| ----- | ----------------------------------------------- |
| `get` | Calls `GET /api-key`; returns `string \| null`. |
| `put` | Calls `PUT /api-key` with the new key string.   |

### Edge Cases

| Case             | Expected Behaviour                           |
| ---------------- | -------------------------------------------- |
| `put` empty body | Throws `ValidationError` (422 from backend). |
