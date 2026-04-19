# View Unit Tests

## 📋 Overview

Unit tests for the HTTP layer — request parsing, field stripping, permission wiring, serializer delegation, and status code mapping. Business logic tests live in `tests/unit/app/services/`. Tests use `APIRequestFactory` to call views directly, bypassing URL routing.

## ▶️ Running

    pytest tests/unit/app/views

## 🧪 Auth Views (`auth_test.py`)

### Core Functionality

| Area                      | Description                                                                    |
| ------------------------- | ------------------------------------------------------------------------------ |
| CreateCoachUser           | Valid data returns 200, delegates to serializer<br/>Invalid data returns 400 with `error_msg` |
| CreateOrganiserUser       | Valid data returns 200, delegates to serializer<br/>Invalid data returns 400 with `error_msg` |
| HelloView                 | Returns greeting containing the authenticated username                         |
| ThrottledObtainAuthToken  | Has `AnonRateThrottle` to prevent brute-force login                            |
| LogoutView                | Deletes user's auth token, returns 200                                         |

### Edge Cases

| Case                               | Expected Behavior                          |
| ---------------------------------- | ------------------------------------------ |
| CreateCoachUser empty body         | Returns 400 with required field errors     |
| CreateOrganiserUser empty body     | Returns 400 with required field errors     |
| HelloView unauthenticated          | Returns 401 (IsAuthenticated permission)   |

## 🧪 Coach Views (`coaches_test.py`)

### Core Functionality

| Area                  | Description                                                              |
| --------------------- | ------------------------------------------------------------------------ |
| CoachEventView apply  | Delegates to service, returns 202 with serialized event                  |
| CoachUnapplyView      | Delegates to service, returns 202                                        |
| CoachCancelEventView  | Delegates to service, returns 202                                        |
| CoachFeedView         | Delegates to service, returns serialized event list                      |
| CoachUpcomingJobsView | Delegates to service, returns serialized event list                      |
| CoachModelView        | Returns serialized coach rating data                                     |

### Edge Cases

| Case                                  | Expected Behavior                                    |
| ------------------------------------- | ---------------------------------------------------- |
| Apply to non-existent event           | Returns 404                                          |
| Cancel non-existent event             | Returns 404                                          |
| CoachModelView for non-coach user     | Returns 404 — "User is not a coach"                  |
| CoachModelView for non-existent user  | Returns 404                                          |
| Organiser tries to access coach views | Returns 403 (IsCoach permission)                     |

## 🧪 Event Views (`events_test.py`)

### Core Functionality

| Area                  | Description                                                                                                |
| --------------------- | ---------------------------------------------------------------------------------------------------------- |
| EventView.get         | Delegates to service, returns serialized event list                                                         |
| EventView.post        | Validates via serializer, delegates to service, returns 201                                                 |
| EventView.patch       | Strips workflow fields (coach_user, coach, voted, offers, organiser_user_id) before validating and delegating |
| EventView.delete      | Delegates to service, returns 200                                                                           |
| EventOffersView       | Returns offer users with public profile and coach rating data                                               |
| EventGetOrganiserView | Returns the organiser's public profile for a given event                                                    |

### Edge Cases

| Case                                     | Expected Behavior                                      |
| ---------------------------------------- | ------------------------------------------------------ |
| Patch with workflow fields in body       | Workflow fields silently stripped, other fields updated |
| Post with invalid serializer data        | Returns 400 with serializer errors                     |
| Patch non-existent event                 | Returns 404                                            |
| Delete non-existent event                | Returns 404                                            |
| Coach tries to access organiser views    | Returns 403 (IsOrganiser permission)                   |

## 🧪 Organiser Views (`organisers_test.py`)

### Core Functionality

| Area                 | Description                                                   |
| -------------------- | ------------------------------------------------------------- |
| OrganiserView        | GET returns serialized profile<br/>PATCH validates and delegates to service, returns 202 |
| AcceptOfferView      | Delegates to service, returns 202                             |
| Block/Unblock        | Delegates to service, returns 202                             |
| Add/Remove favourite | Delegates to service, returns 202                             |

### Edge Cases

| Case                                    | Expected Behavior                                |
| --------------------------------------- | ------------------------------------------------ |
| OrganiserView.patch with invalid data   | Returns 400 with serializer errors               |
| Accept non-existent event               | Returns 404                                      |
| Accept non-existent coach               | Returns 404                                      |
| Block/favourite non-existent user       | Returns 404                                      |
| Block/favourite non-coach user          | Returns 404 (queryset filters `is_coach=True`)   |
| Coach tries to access organiser views   | Returns 403 (IsOrganiser permission)             |

## 🧪 User Views (`users_test.py`)

### Core Functionality

| Area                 | Description                                                                               |
| -------------------- | ----------------------------------------------------------------------------------------- |
| UsersRecordView.get  | Returns only users with `is_coach=True`<br/>Excludes password from response                |
| UserRecordView.get   | Returns authenticated user's full profile with pk                                          |
| UserRecordView.post  | Strips role flags, delegates to serializer, returns 201                                    |
| UserRecordView.patch | Strips role flags and password, delegates to serializer, returns 200                       |

### Edge Cases

| Case                                  | Expected Behavior                               |
| ------------------------------------- | ----------------------------------------------- |
| Post with `is_coach=True` in body     | Stripped — created user has `is_coach=False`     |
| Post with `is_organiser=True` in body | Stripped — created user has `is_organiser=False` |
| Post with `verified=True` in body     | Stripped — created user has `verified=False`     |
| Patch with role flags in body         | Stripped — role unchanged                        |
| Patch with `password` in body         | Stripped — password unchanged                    |
| Post with invalid serializer data     | Returns 400 with serializer errors               |
| UsersRecordView with no coaches       | Returns empty list                               |
