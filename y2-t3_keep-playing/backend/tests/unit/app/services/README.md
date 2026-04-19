# Service Unit Tests

## 📋 Overview

Unit tests for business logic — temporal helpers, workflow validation, atomic operations, ownership checks, and email triggers. Tests call service functions directly without HTTP, using real model instances and mocked email.

## ▶️ Running

    pytest tests/unit/app/services

## 🧪 Temporal Helpers

### Core Functionality

| Function              | Tests                                                                                                                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `active_event_q`     | Includes future non-recurring, excludes past non-recurring<br/>Includes recurring with no end date, excludes recurring with past end date<br/>Includes recurring with future end date<br/>Today's event: included if start_time not yet reached, excluded if passed |
| `is_event_active`    | Mirrors `active_event_q` for instance-level checks on all above scenarios                                                                                                                          |
| `is_event_concluded` | Non-recurring: past date → True, future date → False, today after end_time → True, before end_time → False<br/>Recurring: past end_date → True, future start date → False<br/>Recurring on same weekday after end_time → True, before end_time → False<br/>Recurring on different weekday with past occurrence → True |

## 🧪 Coach Workflows

### Core Functionality

| Area          | Description                                                                                                                          |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Feed          | Returns active, unassigned events<br/>Excludes events from organisers who blocked the coach<br/>Orders by date                        |
| Upcoming jobs | Returns active events assigned to the requesting coach<br/>Excludes events assigned to other coaches                                  |
| Apply         | Adds coach to event offers<br/>Triggers `notify_organiser_new_offer`                                                                  |
| Unapply       | Removes coach from event offers                                                                                                       |
| Cancel        | Sets coach_user to None, removes from offers<br/>Triggers `notify_organiser_coach_cancelled`                                          |

### Edge Cases

| Case                              | Expected Behavior                                            |
| --------------------------------- | ------------------------------------------------------------ |
| Apply to already-assigned event   | Raises error — "already has a coach"                         |
| Apply to past event               | Raises error — "past events"                                 |
| Apply when blocked by organiser   | Raises error — "blocked"                                     |
| Apply to event already applied to | Raises error — "Already applied"                             |
| Cancel event assigned to another  | Raises error — "Not your assignment"                         |
| Unapply from event not applied to | Succeeds silently (M2M remove is no-op)                      |
| Unapply from nonexistent event    | Raises error — "not found"                                   |
| Cancel nonexistent event          | Raises error — "not found"                                   |
| Feed with no matching events      | Returns empty list                                           |
| Upcoming jobs with no assignments | Returns empty list                                           |

## 🧪 Event Management

### Core Functionality

| Area   | Description                                                                                               |
| ------ | --------------------------------------------------------------------------------------------------------- |
| Create | Creates event with organiser assignment<br/>Triggers `notify_favourites_of_new_event`                      |
| Update | Updates event fields, enforces ownership                                                                   |
| Delete | Deletes event, enforces ownership                                                                          |
| Offers | Returns offer users with coach rating data                                                                 |

### Edge Cases

| Case                                | Expected Behavior                           |
| ----------------------------------- | ------------------------------------------- |
| Update past event                   | Raises error — "Cannot edit past events"    |
| Update event owned by another       | Raises error — "Not your event"             |
| Delete event owned by another       | Raises error — "Not your event"             |
| Offers for another organiser's event | Raises error — "Not your event"            |
| Offers with no applicants           | Returns empty list                          |
| Offer user without Coach profile    | Returns public profile without rating data  |

## 🧪 Organiser Workflows

### Core Functionality

| Area            | Description                                                                                                         |
| --------------- | ------------------------------------------------------------------------------------------------------------------- |
| Accept offer    | Sets coach_user atomically, clears all offers<br/>Triggers `notify_coach_offer_accepted`                             |
| Block/Unblock   | Adds/removes coach from organiser's blocked list (removes from favourites when blocking)                              |
| Favourites      | Adds/removes coach from organiser's favourites list (removes from blocked when adding)                                |
| Vote/Rate coach | Increments coach rating scores atomically, marks event as voted<br/>Validates scores are integers between 1 and 5    |

### Edge Cases

| Case                                         | Expected Behavior                                   |
| -------------------------------------------- | --------------------------------------------------- |
| Accept non-coach user                        | Raises error — "not a coach"                        |
| Accept coach not in offers                   | Raises error — "not applied"                        |
| Accept on event owned by another organiser   | Raises error — "Not your event"                     |
| Accept on already-assigned event             | Raises error — "already has a coach"                |
| Unblock user not in blocked list             | Succeeds silently (M2M remove is no-op)             |
| Remove favourite not in list                 | Succeeds silently (M2M remove is no-op)             |
| Block removes from favourites                | If coach was favourited, removed when blocked        |
| Favourite removes from blocked               | If coach was blocked, removed when favourited        |
| Vote with missing fields                     | Raises error — required integers                    |
| Vote with non-integer scores                 | Raises error — required integers                    |
| Vote with out-of-range scores (0 or 6)       | Raises error — "between 1 and 5"                    |
| Vote on future event                         | Raises error — "not happened yet"                   |
| Vote on already-rated event                  | Raises error — "already been rated"                 |
| Vote on event with no assigned coach         | Raises error — "no assigned coach"                  |
| Vote on another organiser's event            | Raises error — "Not your event"                     |
| Vote with boundary scores (1 and 5)          | Accepted — valid range                              |

## 🧪 Email Triggers

| Trigger                                | When                                                  |
| -------------------------------------- | ----------------------------------------------------- |
| `notify_organiser_new_offer`           | Coach successfully applies to an event                 |
| `notify_organiser_coach_cancelled`     | Coach cancels an assigned job                          |
| `notify_coach_offer_accepted`          | Organiser accepts a coach's offer                      |
| `notify_favourites_of_new_event`       | Organiser creates a new event (sent to each favourite) |
| No email sent on validation failure    | If the operation raises an error, no email is sent     |
