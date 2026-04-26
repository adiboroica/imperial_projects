# Repository Unit Tests

Unit-test coverage for every repository in `src/repositories/`. Each repository gets `Core Functionality` and `Edge Cases` tables focused on the translation layer between Pydantic models, Motor operations, and domain errors. Full query behaviour against a live database is covered separately by `tests/integration/`.

## 📋 Overview

Three repositories. Tests inject a mock `AsyncIOMotorDatabase` and assert on the shape of the query, update, and insert payloads passed to it, the translation of Motor return values into Pydantic models, and the mapping of `pymongo.errors` to domain exceptions.

## ▶️ Running

See [`../README.md`](../README.md#-running) for the test commands.

## 🧪 UserRepository

Covers the `users` collection: account creation, lookup by email, API-key storage, and index setup. Email uniqueness is the only structural constraint.

### Core Functionality

| Area             | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| Create           | Inserts a `User` document and returns the stored model.      |
| Get by email     | Returns the `User` for a matching email.                     |
| Update API key   | Writes the encrypted `apiKey` field on the user document.    |
| `ensure_indexes` | Declares a unique index on `email`.                          |

### Edge Cases

| Case                                | Expected Behaviour                                          |
| ----------------------------------- | ----------------------------------------------------------- |
| Create with an email already in use | `DuplicateKeyError` is translated to `EmailAlreadyExists`.  |
| Get for an unknown email            | Returns `None`; no exception.                               |
| Update API key for an unknown email | Raises `UserNotFound`.                                      |

## 🧪 SessionRepository

Covers the `sessions` collection: session creation, lookup, and deletion. Expiry enforcement is the TTL index's job; validity checks in `AuthService` look at `expiresAt` directly.

### Core Functionality

| Area             | Description                                                         |
| ---------------- | ------------------------------------------------------------------- |
| Create           | Inserts a `Session` document with the generated UUID as `_id`.      |
| Get by id        | Returns the `Session` record if present.                            |
| Delete by id     | Removes the session document.                                       |
| `ensure_indexes` | Declares a TTL index on `expiresAt` and a secondary on `userEmail`. |

### Edge Cases

| Case                             | Expected Behaviour                        |
| -------------------------------- | ----------------------------------------- |
| Get for an unknown session id    | Returns `None`; no exception.             |
| Delete for an unknown session id | Silently no-op (logout is idempotent).    |

## 🧪 StoryRepository

Covers the `stories` collection: CRUD operations with per-user isolation. Every method takes a `userEmail` and scopes its Mongo filter to that user, so foreign stories are invisible at the query level.

### Core Functionality

| Area             | Description                                                    |
| ---------------- | -------------------------------------------------------------- |
| Create           | Inserts a new story document and returns the generated id.     |
| List             | Returns the user's stories ordered by `updatedAt` descending.  |
| Get by id        | Returns the `Story` if it exists and belongs to the user.      |
| Update name      | Updates `name` and bumps `updatedAt`.                          |
| Save graph       | Replaces the entire graph field and bumps `updatedAt`.         |
| Delete           | Removes the story document.                                    |
| `ensure_indexes` | Declares a secondary index on `userEmail`.                     |

### Edge Cases

| Case                                     | Expected Behaviour                                         |
| ---------------------------------------- | ---------------------------------------------------------- |
| Get for an unknown story id              | Returns `None`.                                            |
| Get for a story id owned by another user | Returns `None` (ownership filter enforced at query level). |
| Update name when nothing matches         | Raises `StoryNotFound`.                                    |
| Save graph when nothing matches          | Raises `StoryNotFound`; stored document is unchanged.      |
| Delete when nothing matches              | Raises `StoryNotFound`.                                    |
