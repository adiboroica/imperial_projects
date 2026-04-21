# Models

Dart data classes with JSON serialization for the Keep Playing domain.

## 📋 Overview

Immutable data classes mirroring the backend API. Each read model provides a `fromJson` factory for deserializing API responses. Separate DTO classes (`NewEvent`, `CoachNewRating`, `OrganiserDefaults`, `UserLogin`, `CoachSignUp`, `OrganiserSignUp`) represent write payloads with `toJson` methods.

## 🏗️ Design

- **Immutable classes** — all fields are `final` with `const` constructors. No mutable state.
- **`fromJson` factories** — read models (`Event`, `User`, `CoachRating`, `Organiser`) deserialize from API JSON. Null/missing optional fields fall back to safe defaults (`''`, `false`, `0`).
- **`toJson` methods** — write DTOs (`NewEvent`, `CoachNewRating`, `OrganiserDefaults`, `UserLogin`, `OrganiserSignUp`) serialize to API-expected JSON with snake_case keys.
- **`NewEvent.fromEvent`** — enables edit-from-existing flows by copying an `Event`'s fields into a `NewEvent`.
- **Rich computed properties on Event** — `isInThePast` (handles recurring), `isInTheFuture`, `hasCoach`, `occursOn(day)` (weekday matching for recurring), `check()` (multi-filter), `priceInPounds` (GBP formatting), `startTimestamp`/`endTimestamp`.
- **CoachRating averages** — `experienceAverage`, `flexibilityAverage`, `reliabilityAverage` divide by `votes`, returning 0 when `votes == 0` (no division by zero).
- **Organiser helper methods** — `isFavourite(user)` and `isBlocked(user)` check if a user's PK is in the respective list.

## 🔗 Dependencies

No internal dependencies. Models are the leaf of the frontend's dependency graph — they never import from `api/`, `repositories/`, `state/`, `widgets/`, or `pages/`. Enforced by `import_guard`.

See [lib/README.md](../README.md) for the full dependency hierarchy.
