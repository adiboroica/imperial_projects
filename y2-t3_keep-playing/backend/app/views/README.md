# Views

DRF API views — thin HTTP wrappers over the service layer.

## 📋 Overview

Views handle HTTP concerns only: request parsing, permission checks, serializer validation, and response formatting. Business logic (temporal filtering, atomic workflows, email notifications) lives in `services/`, not here. Views call services and translate the result into HTTP responses with appropriate status codes.

## 🔐 Permission Model

| Class           | Rule                                       | Used By                                                          |
| --------------- | ------------------------------------------ | ---------------------------------------------------------------- |
| IsAuthenticated | DRF built-in — rejects anonymous requests  | All views                                                        |
| IsCoach         | `is_authenticated and is_coach`            | Feed, apply, unapply, cancel, upcoming jobs                      |
| IsOrganiser     | `is_authenticated and is_organiser`        | Events CRUD, accept, block, favourites, vote, organiser profile  |

Ownership checks (e.g., "is this your event?") are enforced by services, not by DRF object-level permissions.

## 🔐 Authentication

`ExpiringTokenAuthentication` extends DRF's `TokenAuthentication`. Tokens older than `TOKEN_EXPIRY_HOURS` (default 72) are rejected and deleted. Set to 0 to disable expiry.

`ThrottledObtainAuthToken` subclasses DRF's `ObtainAuthToken` to add anonymous rate-limiting, since the stock view explicitly clears throttle classes. `LogoutView` deletes the user's token server-side, preventing reuse of stolen tokens after logout.

## 🏗️ Design

- **Class-based APIViews** — all views are `APIView` subclasses with explicit `get`/`post`/`patch`/`delete` methods. No ViewSets or routers.
- **Views don't contain business logic** — they validate the request via serializers, call a service function, and return the result. Atomic transactions, temporal filtering, and email triggers all live in `services/`.
- **Role stripping at the HTTP boundary** — `UserRecordView.post` and `patch` strip `is_coach`, `is_organiser`, and `verified` from request data before passing to the serializer, preventing privilege escalation.
- **Workflow field stripping at the HTTP boundary** — `EventView.patch` strips `coach_user`, `coach`, `voted`, `offers`, and `organiser_user_id` from request data, ensuring these can only be modified through dedicated endpoints.

## 🔗 Dependencies

Imports from `services/`, `serializers/`, and `permissions.py`. Never imports from `models/` — all data access goes through services. Enforced by import-linter.
