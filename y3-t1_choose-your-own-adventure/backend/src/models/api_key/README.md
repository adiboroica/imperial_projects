# API Key Models

Wire shapes for `GET /api-key` and `PUT /api-key`.

## 📋 Overview

No domain model lives here — the API key is a field on `User`, not a standalone entity. This folder carries only the request and response shapes the API-key endpoints use.

## 🏗️ Structure

    api_key/
    ├── requests.py     ─ ApiKeyRequest
    └── responses.py    ─ ApiKeyResponse

## 📐 Design

- **Plain string on the wire** — `ApiKeyRequest.apiKey` and `ApiKeyResponse.apiKey` are plain strings. Encryption and decryption happen inside `ApiKeyService`; the model layer never sees the cipher.
- **Nullable response** — `ApiKeyResponse.apiKey` is `str | None`. A user who has not stored a key receives `null`, not a 404.
- **Whitespace stripping at validation** — `ApiKeyRequest.apiKey` strips surrounding whitespace; a whitespace-only input fails validation as empty.

## 🔗 Dependencies

Imports from `pydantic` and the standard library only. Never imports from any other `src/` module.
