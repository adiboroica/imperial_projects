# Story Models

The `Story` domain model and the HTTP shapes that the `/stories/*` routes accept and return.

## 📋 Overview

Stories embed their full graph; there is no separate graph collection. Requests cover create, rename, and graph-save; responses come in a lean list view and a full fetch view.

## 🏗️ Structure

    stories/
    ├── domain.py       ─ Story
    ├── requests.py     ─ CreateStoryRequest, UpdateStoryNameRequest, SaveGraphRequest
    └── responses.py    ─ StoryListItem, StoryResponse

## 📐 Design

- **Graph is embedded, not referenced** — `Story.graph` is a `GamebookGraph` held directly on the document. No cross-collection join, no foreign key.
- **`StoryListItem` is a projection** — `id`, `name`, `firstParagraph`, `totalSections`. The list endpoint never sends full graphs; heavy payload stays on single-fetch.
- **`SaveGraphRequest` validates structure at the boundary** — cycle detection and orphan-child checks run in the `GamebookGraph` validator, before the service is called.
- **Rename is its own request** — `UpdateStoryNameRequest` carries only `name`. A future multi-field PATCH would add a new request model, not overload this one.
- **Timestamps are server-owned** — `createdAt` is set once at create; `updatedAt` is bumped by the service on every mutation. Clients never set them.

## 🔗 Dependencies

Imports from `pydantic`, the standard library, and `models.graph`. Never imports from any other `src/` module.
