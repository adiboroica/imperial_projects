# Repositories

Abstract interfaces defining data operations for each domain.

## 📋 Overview

Repositories are the boundary between business logic and data access. `state/` and page-level cubits depend on these interfaces, not on concrete API implementations. The `api/` layer implements them. This inversion means the state layer can be tested with mock repositories and swapped to a different data source without changing any business logic.

## 🏗️ Design

- **One interface per domain** — `AuthRepository` (login, logout, token management), `UserRepository` (user queries, sign-up), `CoachRepository` (feed, jobs, apply/cancel), `OrganiserRepository` (events, offers, favourites, blocked, ratings, defaults).
- **Return types are domain objects** — repositories return `User`, `Event`, `Organiser`, `CoachRating`, not HTTP responses. The only exceptions are mutation methods that return `http.Response` for status checking at the call site.
- **Implemented by `api/`** — `ApiUsers implements AuthRepository, UserRepository`, `ApiCoach implements CoachRepository`, `ApiOrganiser implements OrganiserRepository`.
- **Wired at the app root** — `main.dart` provides concrete implementations via `MultiRepositoryProvider`. No module below `pages/` knows which implementation is active.

## 🔗 Dependencies

Imports from `models/` only. Never imports from `api/`, `state/`, `pages/`, or `widgets/`.
