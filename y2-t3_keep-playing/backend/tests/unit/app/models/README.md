# Model Tests

## 📋 Overview

Unit tests for Django models — field defaults, relationships, cascade behavior, computed properties, and constraints.

## ▶️ Running

    pytest tests/unit/app/models

## 📂 Test Files

| File              | Model Tested |
| ----------------- | ------------ |
| user_test.py      | User         |
| coach_test.py     | Coach        |
| organiser_test.py | Organiser    |
| event_test.py     | Event        |

## 🧪 User Model (`user_test.py`)

### Core Functionality

| Area          | Description                                      |
| ------------- | ------------------------------------------------ |
| Create        | User created with pk, `__str__` returns username |
| Role defaults | `is_coach` and `is_organiser` default to False   |
| Verified      | `verified` defaults to False                     |
| Location      | Defaults to empty string, stores provided value  |
| Qualification | ImageField defaults to empty/null                |

### Edge Cases

| Case                               | Expected Behavior                              |
| ---------------------------------- | ---------------------------------------------- |
| Both roles True                    | User can be both coach and organiser           |
| Neither role True                  | User exists without any role                   |
| Duplicate username                 | Raises IntegrityError                          |
| Empty string username              | Rejected by Django's AbstractUser              |
| Unicode username                   | `__str__` returns unicode characters correctly |
| Max length location (100)          | Accepted at exactly 100 characters             |
| Overlong location (101+)           | Raises database-level error                    |
| `user.coach` when no Coach         | Raises `RelatedObjectDoesNotExist`             |
| `user.organiser` when no Organiser | Raises `RelatedObjectDoesNotExist`             |

## 🧪 Coach Model (`coach_test.py`)

### Core Functionality

| Area             | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| Create           | OneToOne link to User, `__str__` returns "Coach: {username}" |
| Rating defaults  | votes, experience, flexibility, reliability all default to 0 |
| Rating increment | Fields can be incremented and persisted                      |
| Cascade delete   | Deleting the User deletes the Coach                          |

### Edge Cases

| Case                               | Expected Behavior                                     |
| ---------------------------------- | ----------------------------------------------------- |
| Coach PK equals User PK           | `primary_key=True` — Coach.pk is the User's pk        |
| Reverse relation `user.coach`      | Accessible when Coach exists                          |
| Duplicate Coach for same User      | Raises IntegrityError (OneToOne)                      |
| Large rating values                | Accepted (IntegerField has no upper bound by default) |
| Negative rating values             | Accepted (no model-level constraint)                  |
| Zero votes with non-zero ratings   | Accepted (averages computed at read time, not here)   |
| Delete Coach without deleting User | User still exists after Coach deletion                |

## 🧪 Organiser Model (`organiser_test.py`)

### Core Functionality

| Area           | Description                                                                |
| -------------- | -------------------------------------------------------------------------- |
| Create         | OneToOne link to User, `__str__` returns "Organiser: {username}"           |
| Default fields | default_location='', default_price=None, default_sport='', default_role='' |
| Favourites M2M | Add and remove coaches from favourites                                     |
| Blocked M2M    | Add and remove coaches from blocked list                                   |
| Cascade delete | Deleting the User deletes the Organiser                                    |

### Edge Cases

| Case                                          | Expected Behavior                                    |
| --------------------------------------------- | ---------------------------------------------------- |
| Organiser PK equals User PK                  | `primary_key=True` — Organiser.pk is the User's pk   |
| Reverse relation `user.organiser`             | Accessible when Organiser exists                     |
| Duplicate Organiser for same User             | Raises IntegrityError (OneToOne)                     |
| Add same coach to both favourites and blocked | Accepted (no model-level constraint)                 |
| Add same coach to favourites twice            | Silently deduplicated (M2M behavior)                 |
| Add non-coach user to favourites              | Accepted (M2M has no model-level role check)         |
| Remove user not in favourites                 | No-op, no error                                      |
| Remove user not in blocked                    | No-op, no error                                      |
| Delete favourited coach user                  | Coach removed from favourites (M2M cleared silently) |
| Delete blocked coach user                     | Coach removed from blocked (M2M cleared silently)    |
| Reverse M2M `user.favourite_coaches`          | Coach can query which organisers favourited them     |
| Reverse M2M `user.blocked_coaches`            | Coach can query which organisers blocked them        |
| Delete Organiser without deleting User        | User still exists after Organiser deletion           |
| Max length default_location (100)             | Accepted at exactly 100 characters                   |
| Max length default_sport (50)                 | Accepted at exactly 50 characters                    |

## 🧪 Event Model (`event_test.py`)

### Core Functionality

| Area                   | Description                                                          |
| ---------------------- | -------------------------------------------------------------------- |
| Create                 | Event created with pk, `__str__` returns "name (date)"               |
| `coach` property       | Returns False when `coach_user` is None (unassigned)<br/>Returns True when `coach_user` is set |
| Offers M2M             | Add and remove users from offers                                     |
| coach_user SET_NULL    | Deleting the assigned coach nulls the FK, event preserved            |
| organiser_user CASCADE | Deleting the organiser deletes the event                             |
| Recurring defaults     | `recurring` defaults to False, `recurring_end_date` defaults to None |
| Voted default          | `voted` defaults to False                                            |

### Edge Cases

| Case                                     | Expected Behavior                                                   |
| ---------------------------------------- | ------------------------------------------------------------------- |
| `coach` property uses `coach_user_id`    | Checks raw FK value (no DB query), not `coach_user`                 |
| Event with no coach and no offers        | Valid — represents a fresh unassigned event                         |
| Event with coach set and offers present  | Valid — offers list can coexist with an assigned coach              |
| Multiple events for same organiser       | Accepted (FK, not OneToOne)                                         |
| Multiple events for same coach           | Accepted (FK, not OneToOne)                                         |
| Delete organiser with multiple events    | All events cascade-deleted                                          |
| Offers cleared after coach assignment    | Not enforced at model level (handled in view)                       |
| Add same user to offers twice            | Silently deduplicated (M2M behavior)                                |
| Reverse relation `organiser.organised_events` | Organiser can query all their events                           |
| Reverse relation `coach.events`          | Coach can query all assigned events                                 |
| Reverse relation `user.applied_events`   | User can query events they applied to via offers M2M                |
| Past date on event                       | Accepted at model level (validation is on serializer)               |
| Negative price                           | Accepted at model level (validation is on serializer)               |
| Null coach_user                          | Accepted (nullable FK — unassigned event)                           |
| `__str__` with unicode in name           | Special characters in event name rendered correctly                 |
| Max length name (50)                     | Accepted at exactly 50 characters                                   |
| Max length location (100)                | Accepted at exactly 100 characters                                  |
| Max length details (200)                 | Accepted at exactly 200 characters                                  |
| Max length sport (50)                    | Accepted at exactly 50 characters                                   |
| Max length role (50)                     | Accepted at exactly 50 characters                                   |
| Null creation_started/creation_ended     | Accepted (nullable DateTimeFields)                                  |
| Recurring with end_date before date      | Accepted at model level (no constraint)                             |
| Event with all optional fields null      | Valid — coach_user, recurring_end_date, creation_* all nullable     |
