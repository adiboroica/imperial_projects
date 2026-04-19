# Serializer Tests

## 📋 Overview

Unit tests for DRF serializers — validation rules, field visibility, password hashing, and atomic user+profile creation.

## ▶️ Running

    pytest tests/unit/app/serializers

## 📂 Test Files

| File              | Serializers Tested                                                                    |
| ----------------- | ------------------------------------------------------------------------------------- |
| user_test.py      | PublicUserSerializer, UserSerializer, NewCoachUserSerializer, NewOrganiserUserSerializer |
| event_test.py     | EventSerializer                                                                       |
| coach_test.py     | CoachSerializer                                                                       |
| organiser_test.py | OrganiserSerializer                                                                   |

## 🧪 User Serializers (`user_test.py`)

### Core Functionality

| Area                              | Description                                                              |
| --------------------------------- | ------------------------------------------------------------------------ |
| PublicUserSerializer fields       | Includes only public fields, excludes password, email, and qualification |
| PublicUserSerializer values       | Serializes role flags, name, location correctly                          |
| PublicUserSerializer dual-role    | User with both `is_coach` and `is_organiser` serialized correctly        |
| UserSerializer password           | Password is write-only (excluded from output) and hashed on create       |
| UserSerializer fields             | All expected fields present in serialized output                         |
| UserSerializer create no password | User created successfully when password is omitted                       |
| UserSerializer partial update     | Can update individual fields without resending all data                  |
| NewCoachUser create               | Creates User + Coach atomically, sets `is_coach=True`                    |
| NewCoachUser password             | Password is hashed, not stored as plaintext                              |
| NewCoachUser optionals            | Optional fields (email, first_name, last_name, qualification) stored     |
| NewOrganiserUser create           | Creates User + Organiser atomically, sets `is_organiser=True`            |
| NewOrganiserUser password         | Password is hashed, not stored as plaintext                              |
| NewOrganiserUser optionals        | Optional fields (email, first_name, last_name, qualification) stored     |

### Edge Cases

| Case                                                 | Expected Behavior                                                  |
| ---------------------------------------------------- | ------------------------------------------------------------------ |
| Duplicate username (coach/organiser)                 | Rejects with validation error on `username`                        |
| Weak password (coach/organiser)                      | Rejects for: too short, too common, all numeric, similar to username |
| Empty string password (coach/organiser)              | Rejects with required field or validation error                    |
| Missing username (coach/organiser)                   | Rejects with required field error                                  |
| Missing password (coach/organiser)                   | Rejects with required field error                                  |
| Completely empty data (coach/organiser)              | Rejects with required field errors for both username and password   |
| Extra fields in registration (e.g., `is_organiser`)  | Ignored — only declared fields are accepted                        |
| Atomic rollback on coach creation failure            | If Coach creation fails after User creation, User is rolled back   |
| Atomic rollback on organiser creation failure        | If Organiser creation fails, User is rolled back                   |
| UserSerializer duplicate username+email              | UniqueTogetherValidator rejects the combination                    |
| UserSerializer partial update with password          | No custom `update()` — password saved as plaintext (view strips it, serializer does not) |
| PublicUserSerializer with all defaults               | Empty location, null qualification, all flags False serialize correctly |

## 🧪 Event Serializer (`event_test.py`)

### Core Functionality

| Area           | Description                                                           |
| -------------- | --------------------------------------------------------------------- |
| Valid data     | Accepts valid future date, today, zero price                          |
| Create         | Sets `organiser_user` from `organiser_user_id`, creates Event in DB   |
| Read-only      | `coach`, `coach_user`, `voted`, `offers` cannot be set via serializer |
| Partial update | Can update individual fields (e.g., name) on an existing event        |

### Edge Cases

| Case                                             | Expected Behavior                                                        |
| ------------------------------------------------ | ------------------------------------------------------------------------ |
| Date in the past                                 | Rejects with error on `date`                                             |
| Date exactly yesterday                           | Rejects with error on `date`                                             |
| Negative price                                   | Rejects with error on `price`                                            |
| End time before start time                       | Rejects with error on `end_time`                                         |
| End time equal to start time                     | Rejects with error on `end_time`                                         |
| Flexible end before flexible start               | Rejects with error on `flexible_end_time`                                |
| Flexible end equal to flexible start             | Rejects with error on `flexible_end_time`                                |
| Missing required fields                          | Rejects with required field errors for each missing field                |
| Blank `details` field                            | Rejects — CharField does not allow blank                                 |
| Partial update: end_time before existing start   | Cross-field validation still applies on partial update                   |
| Partial update: start_time after existing end    | Cross-field validation still applies on partial update                   |
| `organiser_user_id` references non-existent user | Rejects with validation error on `organiser_user_id`                     |
| `recurring=True` with `recurring_end_date=None`  | Accepted (open-ended recurring event)                                    |
| `recurring_end_date` before `date`               | Accepted (no cross-field validation between these — documented behavior) |
| Multiple read-only fields in one request         | All ignored — `coach_user`, `voted`, `offers` stripped silently          |

## 🧪 Coach Serializer (`coach_test.py`)

### Core Functionality

| Area   | Description                                                                    |
| ------ | ------------------------------------------------------------------------------ |
| Fields | All rating fields present (votes, experience, flexibility, reliability)        |
| Read   | Serializes values and user FK correctly                                        |

## 🧪 Organiser Serializer (`organiser_test.py`)

### Core Functionality

| Area       | Description                                                                        |
| ---------- | ---------------------------------------------------------------------------------- |
| Defaults   | Saves default_sport, default_role, default_price, default_location                 |
| Favourites | `favourites_ids` sets the favourites M2M relation                                  |
| Blocked    | `blocked_ids` sets the blocked M2M relation                                        |
| Write-only | `favourites_ids`/`blocked_ids` excluded from read, `favourites`/`blocked` included |
| Partial    | Partial update (only some default fields) leaves others unchanged                  |

### Edge Cases

| Case                                            | Expected Behavior                                                 |
| ----------------------------------------------- | ----------------------------------------------------------------- |
| Non-coach user in `favourites_ids`              | Rejects (queryset filters `is_coach=True`)                        |
| Non-coach user in `blocked_ids`                 | Rejects (queryset filters `is_coach=True`)                        |
| Non-existent PK in `favourites_ids`             | Rejects with validation error                                     |
| Non-existent PK in `blocked_ids`                | Rejects with validation error                                     |
| Empty `favourites_ids` list                     | Clears all existing favourites                                    |
| Empty `blocked_ids` list                        | Clears all existing blocked coaches                               |
| Omit `favourites_ids` in partial update         | Existing favourites left unchanged                                |
| Omit `blocked_ids` in partial update            | Existing blocked list left unchanged                              |
| Same user in both favourites and blocked        | Accepted (no cross-field constraint — business logic allows this) |
| Negative `default_price`                        | Accepted (no validation on organiser defaults — only on events)   |
| Null `default_price`                            | Accepted (field is nullable)                                      |
| Empty string `default_sport`                    | Accepted (CharField allows blank)                                 |
| Update defaults without providing M2M fields    | Defaults updated, M2M relations untouched                         |
| Update M2M fields without providing defaults    | M2M updated, default fields untouched                             |
