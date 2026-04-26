# API Key Integration Tests

End-to-end coverage for `GET /api-key` and `PUT /api-key`. Each test runs against a real MongoDB instance; the stored key is encrypted with the configured `ENCRYPTION_KEY`.

## 📋 Overview

One table covering every workflow. Each `PUT` is followed by a `GET` that confirms the new value round-trips through encryption and decryption correctly.

## ▶️ Running

    pytest tests/integration/api_key

## 🧪 Workflows

| Case                                  | Expected                          |
| ------------------------------------- | --------------------------------- |
| `GET /api-key` with a stored key      | 200; returns the decrypted key.   |
| `GET /api-key` with no key            | 200; returns `null`.              |
| `PUT /api-key` with a new key         | 200; encrypted key written.       |
| `PUT /api-key` with an empty string   | 422.                              |
| `GET /api-key` unauthenticated        | 401.                              |
| `PUT /api-key` unauthenticated        | 401.                              |
