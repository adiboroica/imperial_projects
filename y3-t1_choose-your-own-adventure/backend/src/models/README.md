# Models

Pydantic shapes for every value that crosses a layer boundary — HTTP request, HTTP response, WebSocket frame, MongoDB document, in-memory domain type.

## 📋 Overview

Organised by domain, not by kind. Each domain is a folder; inside, a consistent three-way split separates `domain.py` (in-memory types), `requests.py` (HTTP/WS input), and `responses.py` (HTTP/WS output). Folders skip the files that aren't meaningful for them — `api_key/` has no domain model, `graph/` has no wire split.

## 🏗️ Structure

    models/
    ├── auth/             ─ user + session domain, login/signup requests, user response
    ├── stories/          ─ story domain + CRUD requests + list/full responses
    ├── api_key/          ─ wire shapes for GET/PUT /api-key
    ├── graph/            ─ shared graph types (used by domain, storage, and wire)
    ├── ws/               ─ WS envelope + per-message payload shapes
    └── errors.py         ─ domain exception classes

Per-folder file layouts (`domain.py` / `requests.py` / `responses.py` where each applies) are documented in each subfolder's own README.

## 📐 Design

- **Domain models are the in-memory representation** — services and repositories manipulate them. A model like `User` carries internal fields (`passwordHash`, `apiKey`) that never leave the service layer.
- **Request models are validated at the HTTP boundary** — email format, password length, payload size. A request model never crosses down into services; services receive the already-validated domain value.
- **Response models are declared on every endpoint** — `response_model=...` ensures the OpenAPI schema matches what's returned and that internal fields are stripped.
- **camelCase wire format, camelCase storage** — field names match across Pydantic, MongoDB, and the HTTP/WS wire. No alias conversion layer.
- **Pydantic v2 strict mode** — no silent type coercion. A string where an integer is expected raises at the boundary.
- **Errors are plain exception classes, not Pydantic models** — services raise them; routers catch and translate to HTTP status codes.

## 📂 Sub-Module Documentation

- [`auth/README.md`](auth/README.md) — user, session, login/signup request and response shapes.
- [`stories/README.md`](stories/README.md) — story domain, CRUD requests, list and full-fetch responses.
- [`api_key/README.md`](api_key/README.md) — wire shapes for fetch and rotate of the user's OpenAI key.
- [`graph/README.md`](graph/README.md) — `GamebookGraph`, `NarrativeNode`, `ActionNode` — the shared graph model.
- [`ws/README.md`](ws/README.md) — `WSEnvelope` and the per-message payload models.

## 🔗 Dependencies

Imports from `pydantic` and the standard library only. Never imports from any other `src/` module.
