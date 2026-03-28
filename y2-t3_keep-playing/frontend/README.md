# Keep Playing — Frontend

Flutter web app for the Keep Playing platform, using BLoC/Cubit for state management.

## 💻 Local Development

Requires [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.41+).

```bash
flutter pub get
flutter run -d chrome
```

By default the app expects the backend API at `http://localhost:8000`. This is configured in `lib/api/client.dart`.

## 🧪 Running Tests

```bash
flutter test
```

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
