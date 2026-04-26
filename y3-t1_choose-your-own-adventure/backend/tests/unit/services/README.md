# Service Unit Tests

Unit-test coverage for every service in `src/services/`. Each service gets a pair of tables — `Core Functionality` for happy-path behaviours and `Edge Cases` for errors and boundary conditions.

## 📋 Overview

Five services, each tested against mocked repositories and (where relevant) mocked `ai/` primitives. Test files live at `tests/unit/services/test_<name>.py` (mirroring `src/services/<name>.py`).

## ▶️ Running

See [`../README.md`](../README.md#-running) for the test commands.

## 🧪 AuthService

Covers password hashing and verification, signup/login orchestration, session creation, and session validation. Tests inject mock `UserRepository` and `SessionRepository`.

### Core Functionality

| Area               | Description                                                                           |
| ------------------ | ------------------------------------------------------------------------------------- |
| Signup             | Creates a user, hashes the password with `bcrypt`, opens a session, returns the pair. |
| Login              | Verifies the password against the stored hash and opens a new session on success.     |
| Logout             | Expires the current session by setting `expiresAt` to now.                            |
| Session validation | Returns the `User` for a live session.                                                |
| Session TTL        | A new session expires seven days from creation.                                       |

### Edge Cases

| Case                          | Expected Behaviour                                                  |
| ----------------------------- | ------------------------------------------------------------------- |
| Signup with an existing email | Raises `EmailAlreadyExists`; no session created.                    |
| Login with wrong password     | Raises `InvalidCredentials`; no session created.                    |
| Login with unknown email      | Raises `InvalidCredentials` (no enumeration between the two cases). |
| Validate a missing session    | Raises `SessionNotFound`.                                           |
| Validate an expired session   | Raises `SessionExpired`; the stale record is deleted.               |

## 🧪 StoryService

Covers story CRUD and graph persistence. Tests inject a mock `StoryRepository`.

### Core Functionality

| Area        | Description                                                                 |
| ----------- | --------------------------------------------------------------------------- |
| Create      | Persists a new empty story for the calling user and returns its id.         |
| List        | Returns only the calling user's stories, ordered by `updatedAt` descending. |
| Fetch by id | Returns the full `Story` including its graph.                               |
| Rename      | Updates `name`; bumps `updatedAt`.                                          |
| Save graph  | Replaces the entire graph; bumps `updatedAt`.                               |
| Delete      | Removes the story document.                                                 |

### Edge Cases

| Case                                      | Expected Behaviour                                    |
| ----------------------------------------- | ----------------------------------------------------- |
| Fetch by unknown id                       | Raises `StoryNotFound`.                               |
| Fetch another user's story id             | Raises `StoryNotFound` (no existence leak).           |
| Save a graph that fails structural checks | Raises `InvalidGraph`; the stored graph is unchanged. |
| Delete an unknown id                      | Raises `StoryNotFound`.                               |

## 🧪 ApiKeyService

Covers fetch and rotate of the encrypted OpenAI API key. Tests inject a mock `UserRepository`.

### Core Functionality

| Area          | Description                                                            |
| ------------- | ---------------------------------------------------------------------- |
| Fetch         | Returns the decrypted API key for the user.                            |
| Fetch (unset) | Returns `None` when the user has not stored a key.                     |
| Rotate        | Encrypts the new key with `Fernet` and writes it to the user document. |

### Edge Cases

| Case                                    | Expected Behaviour                         |
| --------------------------------------- | ------------------------------------------ |
| Rotate with an empty key                | Raises `ValueError`; stored key unchanged. |
| Decrypt with a changed `ENCRYPTION_KEY` | Raises `ApiKeyCorrupted`.                  |
| Fetch for a user that no longer exists  | Raises `UserNotFound`.                     |

## 🧪 GenerationService

Covers LLM-driven graph expansion. Tests inject mocked `LLMClient`, `TextGenerator`, and `Analyser` — no real OpenAI or sentence-transformer calls.

### Core Functionality

| Area                              | Description                                                                   |
| --------------------------------- | ----------------------------------------------------------------------------- |
| `generate_initial_story`          | Produces the root narrative and `numActions` first-level action children.     |
| `generate_actions_from_narrative` | Expands a narrative node with the requested action count.                     |
| `add_actions`                     | Appends additional actions to a narrative that already has some.              |
| `generate_narrative_from_action`  | Produces a narrative continuation for an action node.                         |
| `bridge_node`                     | Produces a narrative node that links two existing nodes.                      |
| `generate_many`                   | Recursively expands a subtree to the requested depth.                         |
| Duplicate collapse                | Sibling actions flagged as semantically similar by `Analyser` become endings. |

### Edge Cases

| Case                                                   | Expected Behaviour                                     |
| ------------------------------------------------------ | ------------------------------------------------------ |
| `LLMClient` raises `OpenAIRateLimit`                   | Service propagates without swallowing; caller handles. |
| `LLMClient` raises `OpenAIUnavailable`                 | Service propagates.                                    |
| `TextGenerator` exhausts parse retries                 | Raises `NlpParseError`.                                |
| `generate_actions_from_narrative` on an action node    | Raises `InvalidNodeType`.                              |
| `generate_many` with depth 0                           | Returns the graph unchanged; no LLM calls.             |
| `bridge_node` between the same node (source == target) | Raises `InvalidNodeConnection`.                        |

## 🧪 ExportService

Covers DOCX and TXT rendering of a `Story` into bytes for download. Tests inject a mock `StoryRepository` and assert on the produced byte content.

### Core Functionality

| Area                | Description                                                                                |
| ------------------- | ------------------------------------------------------------------------------------------ |
| Render TXT          | Produces a plain-text rendering: title, then each narrative paragraph in traversal order.  |
| Render DOCX         | Produces a `.docx` file with the story title as a heading and one paragraph per narrative. |
| Filename suggestion | Returns a sanitised filename based on the story name (used for `Content-Disposition`).     |

### Edge Cases

| Case                                            | Expected Behaviour                                       |
| ----------------------------------------------- | -------------------------------------------------------- |
| Story id unknown                                | Raises `StoryNotFound`; no rendering attempted.          |
| Story id owned by another user                  | Raises `StoryNotFound` (no existence leak).              |
| Story with an empty graph                       | Renders title only; no paragraphs; no error.             |
| Unknown format string                           | Raises `UnsupportedExportFormat`.                        |
| Story name containing path separators or quotes | Filename is sanitised; no traversal characters survive.  |
