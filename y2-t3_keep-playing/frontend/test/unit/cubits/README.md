# Cubit Tests

## 📋 Overview

Unit tests for page-level cubits — load/error lifecycle, filter logic, and reload behavior. Uses `bloc_test` for emission sequences and `mocktail` for API mocking.

## ▶️ Running

    flutter test test/unit/cubits

## 📂 Test Files

| File             | Cubits Tested                                                  |
| ---------------- | -------------------------------------------------------------- |
| cubits_test.dart | FeedCubit, UpcomingJobsCubit, EventsCubit, AuthCubit, OrganiserCubit |

AuthCubit test cases are documented in `test/unit/state/README.md`.

## 🧪 FeedCubit (in `cubits_test.dart`)

### Core Functionality

| Area         | Description                                    |
| ------------ | ---------------------------------------------- |
| Initial      | Starts as `DataInitial`                        |
| Load success | Emits `DataLoading` → `DataLoaded` with events |
| Load failure | Emits `DataLoading` → `DataError` with message |

### Edge Cases

| Case             | Expected Behavior                |
| ---------------- | -------------------------------- |
| Empty feed       | `DataLoaded` with empty list     |
| Multiple reloads | Each load replaces previous data |

## 🧪 UpcomingJobsCubit (in `cubits_test.dart`)

### Core Functionality

| Area         | Description                                    |
| ------------ | ---------------------------------------------- |
| Initial      | Starts as `DataInitial`                        |
| Load success | Emits `DataLoading` → `DataLoaded` with events |
| Load failure | Emits `DataLoading` → `DataError` with message |

### Edge Cases

| Case             | Expected Behavior                |
| ---------------- | -------------------------------- |
| No upcoming jobs | `DataLoaded` with empty list     |
| Multiple reloads | Each load replaces previous data |

## 🧪 EventsCubit (in `cubits_test.dart`)

### Core Functionality

| Area              | Description                                                                              |
| ----------------- | ---------------------------------------------------------------------------------------- |
| Load              | Success emits `DataLoading` → `DataLoaded`<br/>Failure emits `DataLoading` → `DataError` |
| Filter: past      | `setAllowPastEvents(false)` removes past events                                          |
| Filter: pending   | `setAllowPendingEvents(false)` removes events without a coach                            |
| Filter: scheduled | `setAllowScheduledEvents(false)` removes events with coach + in future                   |

### Edge Cases

| Case                             | Expected Behavior                                       |
| -------------------------------- | ------------------------------------------------------- |
| Combined filters                 | Multiple filters applied → intersection of results      |
| All filters disabled             | Empty list returned                                     |
| Re-enabling a filter             | Previously hidden events restored                       |
| Filter applied before load       | Filter takes effect after next load                     |
| Load failure after filter change | Error state, filters preserved for next successful load |

## 🧪 OrganiserCubit (in `cubits_test.dart`)

### Core Functionality

| Area           | Description                              |
| -------------- | ---------------------------------------- |
| Initial        | State is the provided `initialOrganiser` |
| Reload success | Emits new organiser data from API        |

### Edge Cases

| Case             | Expected Behavior                             |
| ---------------- | --------------------------------------------- |
| Reload failure   | Keeps current state unchanged (no error)      |
| Multiple reloads | Each success replaces previous organiser data |
