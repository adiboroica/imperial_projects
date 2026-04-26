# Auth Models

User, session, and the HTTP shapes the `/auth/*` routes accept and return.

## 📋 Overview

The auth domain holds the in-memory shapes for authentication: a `User` record, a `Session` cookie, and the request/response models that pass across the `/auth/*` routes.

## 🏗️ Structure

    auth/
    ├── domain.py       ─ User, Session
    ├── requests.py     ─ LoginRequest, SignupRequest
    └── responses.py    ─ UserResponse

## 📐 Design

- **`User` carries internal fields** — `passwordHash` and `apiKey` (encrypted) are part of `User` but never cross the service boundary; `UserResponse` is the safe projection for wire output.
- **`Session._id` is a UUID v4** — generated at login or signup; matches the `_id` of the sessions collection so the repository needs no join.
- **Session TTL is enforced twice** — MongoDB's TTL index reaps stale documents in the background, and `AuthService` checks `expiresAt` on every validate call so a still-reachable expired session is rejected deterministically.
- **`LoginRequest` does not re-validate password length** — an old account may hold a password shorter than the current minimum; only `SignupRequest` enforces the minimum-length rule.
- **Email validation via Pydantic's `EmailStr`** — RFC-5322 format check at construction; no custom regex.

## 🔗 Dependencies

Imports from `pydantic` and the standard library only. Never imports from any other `src/` module.
