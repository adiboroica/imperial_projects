# Stories Integration Tests

End-to-end coverage for `/stories` CRUD and `/stories/{id}/graph` persistence. Each test runs against a real MongoDB instance behind a fresh authenticated session.

## 📋 Overview

One table covering every workflow. Every mutation is followed by a read that verifies the persisted side-effect; isolation between users is asserted explicitly via foreign-id lookups.

## ▶️ Running

    pytest tests/integration/stories

## 🧪 Workflows

| Case                                                        | Expected                                    |
| ----------------------------------------------------------- | ------------------------------------------- |
| `POST /stories` authenticated                               | 201; returns the new story id.              |
| `POST /stories` unauthenticated                             | 401.                                        |
| `GET /stories` authenticated                                | 200; returns only the caller's stories.     |
| `GET /stories/{id}` as owner                                | 200; returns the full story with graph.     |
| `GET /stories/{id}` with an unknown id                      | 404 `StoryNotFound`.                        |
| `GET /stories/{id}` for a foreign user's id                 | 404 (no existence leak).                    |
| `PATCH /stories/{id}` as owner                              | 200; name updated; `updatedAt` bumped.      |
| `PATCH /stories/{id}` with an empty name                    | 422.                                        |
| `PUT /stories/{id}/graph` as owner with a valid graph       | 200; graph persisted.                       |
| `PUT /stories/{id}/graph` with a structurally invalid graph | 422.                                        |
| `DELETE /stories/{id}` as owner                             | 204; document removed.                      |
| `DELETE /stories/{id}` with an unknown id                   | 404.                                        |
| `GET /stories/{id}/export?format=docx` as owner             | 200; binary DOCX body; `Content-Disposition: attachment`. |
| `GET /stories/{id}/export?format=txt` as owner              | 200; plain-text body; `Content-Disposition: attachment`. |
| `GET /stories/{id}/export?format=docx` for a foreign id     | 404 (no existence leak).                    |
| `GET /stories/{id}/export?format=pdf` (unknown format)      | 422.                                        |
| `GET /stories/{id}/export` unauthenticated                  | 401.                                        |
