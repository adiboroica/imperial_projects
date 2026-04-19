# Model Tests

## 📋 Overview

Unit tests for Dart data classes — JSON serialization, computed properties, filter logic, and DTO formatting.

## ▶️ Running

    flutter test test/unit/models

## 📂 Test Files

| File             | Classes Tested                                                                   |
| ---------------- | -------------------------------------------------------------------------------- |
| models_test.dart | Event, NewEvent, User, CoachRating, Organiser, formatTime |

## 🧪 Event & NewEvent

### Core Functionality

| Area                      | Description                                                                                                          |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Event.fromJson            | All fields parsed correctly including date/time<br/>Null/missing optional fields fall back to defaults<br/>`creation_started`/`creation_ended` default to `date` when missing<br/>`voted` mapped to `rated`, `coach_user` mapped to `coachPk`<br/>`recurring_end_date` parsed when present, null when absent |
| Event computed properties | `isInThePast`/`isInTheFuture` for past and future dates<br/>`isInThePast` for recurring with/without end date<br/>`hasCoach` returns `coach` field, `isRecurring` returns `recurring` field<br/>`priceInPounds` formats with £ symbol<br/>`startTimestamp`/`endTimestamp` combine date + time |
| Event.occursOn            | Matches exact date<br/>Matches recurring weekday within range<br/>Rejects date before event start<br/>Rejects date after `recurringEndDate`<br/>Non-recurring on different day returns false |
| Event.check filter        | Filters past, pending (no coach), scheduled (coach + future)<br/>Filters by day with `onDay`<br/>Filters by coach with `withCoachUser`<br/>Filters combine correctly (intersection) |
| NewEvent.toJson           | Date formatted as `yyyy-MM-dd`<br/>Times formatted as `HH:mm`<br/>`creation_started`/`creation_ended` formatted as `yyyy-MM-dd HH:mm:ss`<br/>`recurring_end_date` omitted when null, included when set |
| NewEvent.fromEvent        | All fields copied from Event to NewEvent                                                                              |

### Edge Cases

| Case                                        | Expected Behavior                                          |
| ------------------------------------------- | ---------------------------------------------------------- |
| Filters combine correctly                   | Multiple filters applied → intersection of results         |
| All filters disabled                        | Empty list returned                                        |
| Re-enabling filter                          | Previously hidden events restored                          |
| Recurring event with null end date          | `isInThePast` returns false (open-ended)                   |
| Recurring event with past end date          | `isInThePast` returns true                                 |
| `occursOn` for non-recurring on wrong day   | Returns false                                              |
| `occursOn` for recurring before start date  | Returns false                                              |

## 🧪 User

### Core Functionality

| Area                   | Description                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------ |
| User.fromJson          | All fields parsed correctly<br/>Null/missing optional fields default to `''`, `false`<br/>Produces snake_case keys in output |
| User.toJson            | Round-trip produces equivalent data (fromJson ∘ toJson = identity)                    |
| User.fullName          | Returns concatenated first/last name                                                  |

### Edge Cases

| Case                           | Expected Behavior                                 |
| ------------------------------ | ------------------------------------------------- |
| Empty first or last name       | `fullName` handles gracefully (e.g., `" Smith"`)  |
| Both names empty               | `fullName` returns `" "` (space)                  |
| All optional fields null       | Defaults to empty strings and false               |

## 🧪 CoachRating

### Core Functionality

| Area                  | Description                                                                    |
| --------------------- | ------------------------------------------------------------------------------ |
| CoachRating.fromJson  | All fields parsed correctly                                                    |
| CoachRating averages  | Correct division (experience/votes, etc.)                                      |

### Edge Cases

| Case                        | Expected Behavior                           |
| --------------------------- | ------------------------------------------- |
| Zero votes                  | All averages return 0 (no division by zero) |
| Non-zero votes with ratings | Averages computed correctly (e.g., 20/4 = 5.0) |

## 🧪 Organiser

### Core Functionality

| Area                     | Description                                                                          |
| ------------------------ | ------------------------------------------------------------------------------------ |
| Organiser.fromJson       | All fields parsed correctly<br/>Null/missing defaults fall back to `''`, `null`       |
| Organiser.isFavourite    | Returns true for PK in favourites, false otherwise                                    |
| Organiser.isBlocked      | Returns true for PK in blocked, false otherwise                                       |

### Edge Cases

| Case                       | Expected Behavior                  |
| -------------------------- | ---------------------------------- |
| Empty favourites list      | `isFavourite` always returns false |
| Empty blocked list         | `isBlocked` always returns false   |
