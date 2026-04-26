# WebSocket Model Tests

Unit-test coverage for `WSEnvelope` and the per-message payload models in `src/models/ws/`.

## 📋 Overview

Covers envelope validation and discriminated-union dispatch. Close-code mapping (`1003` on validation failure) is a router concern and lives in `tests/integration/ws/`.

## ▶️ Running

See [`../README.md`](../README.md#-running) for the test commands.

## 🧪 Core Functionality

| Area                 | Description                                                        |
| -------------------- | ------------------------------------------------------------------ |
| `WSEnvelope`         | Requires `requestId` (UUID v4), `type`, and `payload`.             |
| Discriminator        | `type` selects the right payload model from the per-message union. |
| Per-message payloads | Each payload model validates its own required fields and types.    |

## 🧪 Edge Cases

| Case                             | Expected Behaviour        |
| -------------------------------- | ------------------------- |
| Envelope missing `requestId`     | Raises `ValidationError`. |
| `requestId` not a valid UUID     | Raises `ValidationError`. |
| Envelope with an unknown `type`  | Raises `ValidationError`. |
| Payload missing a required field | Raises `ValidationError`. |
