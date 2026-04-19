# Tests

Flutter test suite covering architecture enforcement, models, API client, state management, cubits, widgets, and page-level integration.

## 📋 Overview

Tests are organized into three categories. Architecture tests enforce dependency rules between modules. Unit tests validate individual components in isolation. Integration tests verify full page behavior with real providers and navigation.

## ▶️ Running

    flutter test                          # all tests
    flutter test test/architecture        # architecture rules only
    flutter test test/unit                # unit tests only
    flutter test test/integration         # integration tests only

    # Specific unit layers
    flutter test test/unit/models
    flutter test test/unit/api
    flutter test test/unit/state
    flutter test test/unit/cubits
    flutter test test/unit/widgets

## 🧪 Test Categories

| Category     | Purpose                                                       | Location             |
| ------------ | ------------------------------------------------------------- | -------------------- |
| Architecture | Verify dependency rules between modules (import enforcement)  | `test/architecture/` |
| Unit         | Test models, API client, state, cubits, widgets in isolation  | `test/unit/`         |
| Integration  | Test full pages with real BlocProviders and navigation         | `test/integration/`  |

## 📂 Structure

    test/
    ├── architecture/                    # import rule enforcement
    ├── unit/
    │   ├── models/                      # serialization, computed properties, filter logic
    │   ├── api/                         # HTTP client with mock responses
    │   ├── state/                       # AuthStorage persistence
    │   ├── cubits/                      # AuthCubit + page-level cubits with mocked APIs
    │   └── widgets/                     # individual widget rendering and interaction
    └── integration/
        └── pages/                       # full page tests with real providers and navigation

## 📝 Conventions

- Test files named `*_test.dart`
- Mock classes use `mocktail` (`extends Mock implements X`)
- Cubit tests use `bloc_test` for emission sequences and plain `test()` for multi-step filter logic
- Helper factories (e.g., `makeEvent()`) provide sensible defaults to reduce test boilerplate
- API tests use `http_testing.MockClient` for HTTP-level mocking
- Integration tests use `pumpWidget` with real `BlocProvider` wiring
