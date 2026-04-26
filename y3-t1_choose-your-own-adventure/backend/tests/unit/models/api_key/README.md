# API Key Model Tests

Unit-test coverage for `ApiKeyRequest` and `ApiKeyResponse` in `src/models/api_key/`.

## 📋 Overview

Covers the plain-string wire format and whitespace handling. Encryption is a service concern and lives in `tests/unit/services/`.

## ▶️ Running

See [`../README.md`](../README.md#-running) for the test commands.

## 🧪 Core Functionality

| Area             | Description                                                 |
| ---------------- | ----------------------------------------------------------- |
| `ApiKeyRequest`  | Takes a non-empty `apiKey` string.                          |
| `ApiKeyResponse` | Returns the decrypted `apiKey` string (or `null` if unset). |

## 🧪 Edge Cases

| Case                                 | Expected Behaviour                      |
| ------------------------------------ | --------------------------------------- |
| `ApiKeyRequest` with an empty string | Raises `ValidationError`.               |
| `ApiKeyRequest` with whitespace only | Raises `ValidationError` (after strip). |
