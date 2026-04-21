# Keep Playing — Frontend

Flutter web app for the Keep Playing platform, using BLoC/Cubit for state management.

## 💻 Local Development

Requires [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.41+) and a running backend (see root README).

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

The `API_BASE_URL` tells the app where to find the backend API. When omitted (or empty), the app uses relative URLs — this is the default for production, where nginx proxies API requests.

## 🧪 Running Tests

**With Docker** (recommended):

```bash
docker compose run --rm --build frontend-test    # from project root
```

**Without Docker**:

```bash
flutter test
```

Tests cover models, serialization, cubits (`FeedCubit`, `UpcomingJobsCubit`, `EventsCubit`, `AuthCubit`, `OrganiserCubit`), API client error handling, and filter logic.

## 🔍 Dependency Audit

Check Flutter/Dart dependencies for outdated or insecure versions:

```bash
flutter pub outdated --show-all
```

## 📊 Test Coverage

```bash
flutter test --coverage
```

Generates `coverage/lcov.info` — open with an LCOV viewer or `genhtml` for a browsable report.

## 📱 User Flows

The app supports two user roles, each with their own sign-up, login, and home screen:

### Organiser

- Create events with sport, role, date/time, location, and price
- View events on a calendar or drill into a specific day
- Review coach applications and accept offers
- Rate coaches after events (reliability, flexibility, experience)
- Manage favourites and blocked coaches
- Set default values for new events

### Coach

- Browse a feed of available events
- Apply or withdraw from events
- View upcoming confirmed jobs
- View event and organiser details

## 📂 Sub-Module Documentation

- [Source Architecture](lib/README.md) — dependency hierarchy and directory overview
- [Models](lib/models/README.md) — Dart data classes and DTOs
- [Repositories](lib/repositories/README.md) — abstract interfaces for data operations
- [API Client](lib/api/README.md) — HTTP client implementing repositories
- [State](lib/state/README.md) — global auth state management
- [Widgets](lib/widgets/README.md) — shared reusable components
- [Pages](lib/pages/README.md) — screen organization by role
- [Tests](test/README.md) — test suite overview
