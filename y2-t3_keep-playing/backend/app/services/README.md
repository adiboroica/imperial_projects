# Services

Business logic layer — orchestrates models, enforces rules, and triggers side effects.

## 📋 Overview

Services own all business logic that goes beyond simple CRUD. They sit between views and models: views handle HTTP concerns (request parsing, response formatting, status codes), while services handle domain logic (temporal filtering, atomic workflows, validation rules, email notifications). This separation means the same business logic can be called from views, management commands, or future entry points without duplication.

## 🔧 Responsibilities

| Area                  | Description                                                                                           |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| Coach workflows       | Feed filtering (active, unassigned, unblocked), apply/unapply/cancel with validation, upcoming jobs   |
| Event management      | Create with organiser assignment, update with workflow field protection, delete with ownership check   |
| Organiser workflows   | Accept offer (atomic, clears offers), block/unblock (mutual exclusion with favourites), favourites (mutual exclusion with blocked), vote/rate coach with score validation |
| Temporal logic        | `active_event_q()`, `is_event_active()`, `is_event_concluded()` — shared by coach and organiser flows |
| Email notifications   | Triggered after successful mutations (new offer, acceptance, cancellation, new event for favourites)  |

## 🏗️ Design

- **Services return domain objects, not HTTP responses** — views are responsible for status codes and serialization. Services raise exceptions for error conditions (e.g., `ValidationError` for "event already has a coach").
- **Atomic transactions live here** — `select_for_update` and `transaction.atomic()` for race-condition-sensitive operations (apply, accept, vote) are owned by services, not views.
- **Email as a side effect** — services call notification functions after successful mutations. If the mutation fails, no email is sent.
- **Temporal helpers are shared** — `active_event_q()` (queryset filter) and `is_event_active()` / `is_event_concluded()` (instance checks) are used by both coach and organiser services.

## 🔗 Dependencies

Imports from `models/` and `email.py`. Never imports from `views/`, `serializers/`, or `config/`.
