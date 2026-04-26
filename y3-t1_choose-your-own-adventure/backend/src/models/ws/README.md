# WebSocket Models

The universal `WSEnvelope` plus the per-message payload shapes for every client and server frame on `/ws`.

## 📋 Overview

Every WebSocket frame is a `WSEnvelope` carrying a `requestId`, a `type` string, and a typed `payload`. The payload's concrete class is selected from a discriminated union on `type`.

## 🏗️ Structure

    ws/
    ├── envelope.py     ─ WSEnvelope
    ├── requests.py     ─ client-to-server payloads (InitialStoryPayload, GenerateActionsPayload, …)
    └── responses.py    ─ server-to-client payloads (RequestCompletePayload, ProgressUpdatePayload, …)

## 📐 Design

- **Discriminated union on `type`** — Pydantic's discriminator resolves the concrete payload class at validation time; an unknown `type` fails validation and the router closes the socket with code `1003`.
- **`requestId` is always present** — required on both directions. The server echoes the client's id back on every response so concurrent in-flight messages can be correlated.
- **Client payloads carry the full graph** — generation is stateless with respect to storage; every client message includes the current `GamebookGraph` rather than a story id.
- **Server payloads also carry the graph** — `RequestCompletePayload` and `ProgressUpdatePayload` return the updated `GamebookGraph`. The client saves later via REST.
- **Error responses share a shape** — `RateLimitErrorPayload`, `OpenAIErrorPayload`, and `NlpParseErrorPayload` all carry a human-readable `message` field plus the original `requestId`.

## 🔗 Dependencies

Imports from `pydantic`, the standard library, and `models.graph`. Never imports from any other `src/` module.
