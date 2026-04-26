# Story Model Tests

Unit-test coverage for `Story`, the story request models, and the story response models in `src/models/stories/`.

## 📋 Overview

Covers construction, validation, and delegated graph-structure validation for the six shapes in the stories folder.

## ▶️ Running

See [`../README.md`](../README.md#-running) for the test commands.

## 🧪 Core Functionality

| Area                     | Description                                                            |
| ------------------------ | ---------------------------------------------------------------------- |
| `CreateStoryRequest`     | Accepts optional `name`, `genre`, and `attributes`.                    |
| `UpdateStoryNameRequest` | Takes a required non-empty `name`.                                     |
| `SaveGraphRequest`       | Takes a valid `graph` (delegates to `GamebookGraph` validation).       |
| `Story`                  | Carries `_id`, `userEmail`, `name`, `graph`, `createdAt`, `updatedAt`. |
| `StoryListItem`          | Lean view: `id`, `name`, `firstParagraph`, `totalSections`.            |
| `StoryResponse`          | Full view including the embedded graph.                                |

## 🧪 Edge Cases

| Case                                                       | Expected Behaviour                    |
| ---------------------------------------------------------- | ------------------------------------- |
| `UpdateStoryNameRequest` with an empty `name`              | Raises `ValidationError`.             |
| `UpdateStoryNameRequest` with `name` over the length limit | Raises `ValidationError`.             |
| `SaveGraphRequest` with a structurally invalid graph       | Raises `ValidationError` (delegated). |
