# Auth Integration Tests

End-to-end coverage for `/auth/signup`, `/auth/login`, `/auth/logout`, and `/auth/session`. Each test writes to a real MongoDB instance and drives the flow via `httpx.AsyncClient`.

## 📋 Overview

One table covering every workflow. Each signup writes a real user document; each login opens a real session cookie; each test runs against a fresh database.

## ▶️ Running

    pytest tests/integration/auth

## 🧪 Workflows

| Case                                         | Expected                                          |
| -------------------------------------------- | ------------------------------------------------- |
| `POST /auth/signup` with a new email         | 201; user document written; session cookie set.   |
| `POST /auth/signup` with an existing email   | 409 `EmailAlreadyExists`.                         |
| `POST /auth/signup` with a malformed email   | 422.                                              |
| `POST /auth/signup` with a short password    | 422.                                              |
| `POST /auth/login` with correct credentials  | 200; session cookie set.                          |
| `POST /auth/login` with a wrong password     | 401 `InvalidCredentials`.                         |
| `POST /auth/login` with an unknown email     | 401 `InvalidCredentials` (no enumeration).        |
| `POST /auth/login` over the rate limit       | 429 after 10 requests per minute.                 |
| `POST /auth/logout` with an active session   | 200; session deleted; cookie cleared.             |
| `POST /auth/logout` without a session        | 401.                                              |
| `GET /auth/session` with an active session   | 200; returns `UserResponse`.                      |
| `GET /auth/session` with no cookie           | 401.                                              |
| `GET /auth/session` with an expired session  | 401; the stale record is deleted.                 |
