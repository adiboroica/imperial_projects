# Tests

pytest test suite covering models, serializers, services, views, authentication, permissions, and email notifications.

## 📋 Overview

Tests are organized into three categories. Architecture tests enforce dependency rules between modules. Unit tests validate individual components in isolation (models, serializers, services, views, permissions, authentication, email). Integration tests verify full HTTP request/response flows through the API.

## ▶️ Running

    pytest                         # all tests
    pytest tests/architecture      # architecture rules only
    pytest tests/unit              # unit tests only
    pytest tests/integration       # integration tests only

    # Specific layers
    pytest tests/unit/app/models
    pytest tests/unit/app/serializers
    pytest tests/unit/app/services
    pytest tests/unit/app/views

## 🧪 Test Categories

| Category     | Purpose                                                                          | Location              |
| ------------ | -------------------------------------------------------------------------------- | --------------------- |
| Architecture | Verify dependency rules between modules (import enforcement via `import-linter`) | `tests/architecture/` |
| Unit         | Test models, serializers, services, views, permissions, auth, email in isolation  | `tests/unit/`         |
| Integration  | Test API endpoints with full HTTP request/response flows                         | `tests/integration/`  |

## 📂 Structure

    tests/
    ├── conftest.py                              # shared fixtures (users, tokens, clients, events)
    ├── architecture/                            # import rule enforcement (import-linter)
    ├── unit/
    │   └── app/
    │       ├── models/                          # one file per model (user, coach, organiser, event)
    │       ├── serializers/                     # one file per serializer module
    │       ├── services/                        # business logic (temporal, workflows, email triggers)
    │       ├── views/                           # HTTP layer (field stripping, permissions, delegation)
    │       ├── authentication_test.py           # ExpiringTokenAuthentication
    │       ├── permissions_test.py              # IsCoach, IsOrganiser
    │       └── email_test.py                    # notification functions
    └── integration/
        ├── auth_test.py                         # registration, login, logout, hello, token lifecycle
        ├── coaches_test.py                      # feed, apply, unapply, cancel, upcoming jobs, profile view
        ├── events_test.py                       # CRUD, offers listing, organiser lookup, permissions
        ├── organisers_test.py                   # profile, favourites, block, accept, vote, public profile
        └── users_test.py                        # list, create, patch, role stripping

## 📐 Unit vs Integration

- **Unit tests** test functions/classes in isolation. Service tests call service functions directly with real models and mocked email. View tests use `APIRequestFactory` to verify HTTP concerns (field stripping, permissions, status codes). They mirror the source structure: `tests/unit/app/models/` ↔ `app/models/`, etc.
- **Integration tests** use `APIClient` to send real HTTP requests through the full middleware stack. They are organized by business domain (auth, coaches, events, organisers, users), not by source file.

## 📝 Conventions

- Test files are named `*_test.py`
- Test classes are named `*Test` (matching `python_classes = "*Test"` in [pyproject.toml](../pyproject.toml)). They group related tests and host class-scoped pytest fixtures — they do **not** inherit from `unittest.TestCase`, so each test is a plain pytest function.
- All database tests use `@pytest.mark.django_db`
- Shared fixtures in `conftest.py` provide pre-built users (organiser, coach, coach2), tokens, authenticated clients, and sample events (future, assigned, past)
- Unit tests mock external dependencies (`send_mail`, `settings`)
- Integration tests hit the DRF API via `APIClient` with token auth
