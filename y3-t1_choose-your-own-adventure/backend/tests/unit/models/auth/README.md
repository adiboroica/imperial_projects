# Auth Model Tests

Unit-test coverage for `User`, `Session`, `LoginRequest`, `SignupRequest`, and `UserResponse` in `src/models/auth/`.

## 📋 Overview

Covers construction validation, default values, and serialisation round-trips for the five shapes in the auth folder.

## ▶️ Running

See [`../README.md`](../README.md#-running) for the test commands.

## 🧪 Core Functionality

| Area                 | Description                                                                |
| -------------------- | -------------------------------------------------------------------------- |
| `LoginRequest`       | Validates `email` as RFC-5322; requires a non-empty `password`.            |
| `SignupRequest`      | Validates `email` and enforces a minimum password length.                  |
| `User`               | Carries `email`, `passwordHash`, optional `apiKey`; `apiKey` is encrypted. |
| `Session`            | `_id` is a UUID; `createdAt` and `expiresAt` are timestamps.               |
| `UserResponse` shape | Excludes `passwordHash` and `apiKey` from serialised output.               |

## 🧪 Edge Cases

| Case                                                     | Expected Behaviour                                           |
| -------------------------------------------------------- | ------------------------------------------------------------ |
| `LoginRequest` with a malformed email                    | Raises `ValidationError` at construction.                    |
| `SignupRequest` with a password shorter than the minimum | Raises `ValidationError`.                                    |
| `Session` with `expiresAt` before `createdAt`            | Raises `ValidationError` (custom validator).                 |
| `UserResponse` constructed from a `User`                 | `passwordHash` and `apiKey` never appear in `.model_dump()`. |
