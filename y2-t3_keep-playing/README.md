# Keep Playing

A sports coaching platform that connects event organisers with coaches and referees.

> See [screenshots](README.screenshots.md) for a visual overview of the app.

## ✨ Features

Grouped by audience: shared capabilities first, then what each role can do.

### General

| Feature             | Description                                                 |
| ------------------- | ----------------------------------------------------------- |
| Two-role system     | Separate sign-up and login flows for organisers and coaches |
| Email notifications | Coaches are notified when accepted for an event             |
| Demo data seeding   | Pre-populated accounts and events for quick evaluation      |

### For Organisers

| Feature                    | Description                                                              |
| -------------------------- | ------------------------------------------------------------------------ |
| Create and manage events   | Set sport, role, date, time, location, and price                         |
| Calendar view              | See all your events at a glance, drill into individual days              |
| Accept coach offers        | Review applicants and choose the best fit                                |
| Rate coaches               | Score reliability, flexibility, and experience after each event          |
| Favourites and block lists | Save coaches you trust, block ones you don't                             |
| Default settings           | Pre-fill new events with your preferred sport, role, location, and price |

### For Coaches

| Feature                     | Description                                         |
| --------------------------- | --------------------------------------------------- |
| Browse available events     | Feed of open events filtered by your sport and role |
| Apply and withdraw          | Express interest in events or change your mind      |
| Upcoming jobs               | See all your confirmed assignments in one place     |
| Profile with qualifications | Showcase your experience and certifications         |

## 🚀 Getting Started

Docker is the only hard requirement — everything else runs inside the compose stack.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose

### Start the app

```bash
cp .env.example .env       # create local config (edit if needed)
docker compose up --build
```

First build takes a few minutes (Flutter SDK download + compilation). Subsequent starts are much faster.

Open **http://localhost** in your browser. The app renders inside a phone-frame wrapper.

### Demo accounts

| Role      | Username         | Password   |
| --------- | ---------------- | ---------- |
| Organiser | `organiser_demo` | `demo1234` |
| Coach     | `coach_demo`     | `demo1234` |
| Coach 2   | `coach_demo2`    | `demo1234` |

Demo data is seeded automatically on first start.

### Stop the app

```bash
docker compose down        # Stop containers (data persists)
docker compose down -v     # Stop and delete all data (clean reset)
```

## 💻 Development

The app can run in three ways: fully in Docker, locally, or a hybrid of both.

### Docker (simplest)

```bash
cp .env.example .env
docker compose up --build    # full app at http://localhost
```

### Locally

Requires Python 3.12+, [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.41+, and PostgreSQL.

```bash
cp .env.example .env
docker compose up -d postgres                  # just the database in Docker
cd backend
pip install -e ".[test]"
python manage.py makemigrations app && python manage.py migrate
python manage.py seed_demo_data
python manage.py runserver                     # backend at http://localhost:8000
```

In a separate terminal:

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

### Hybrid (recommended for backend development)

Postgres and backend run in Docker with hot reload (code mounted from host). Frontend runs locally with Flutter's dev server.

```bash
cp .env.example .env
docker compose --profile dev up                # postgres + backend with auto-reload
```

The backend-dev service mounts your local `backend/` directory, so code changes are reflected immediately without rebuilding.

In a separate terminal:

```bash
cd frontend
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

### Deployed

Set environment variables in your platform's dashboard (AWS ECS, Fly.io, Railway, Kubernetes, etc.) instead of using a `.env` file. At minimum:

- `DEBUG=False`
- `SECRET_KEY=<real-secret-key>` (app refuses to start with the default insecure key when debug is off)
- `ALLOWED_HOSTS=<your-domain>`
- Database credentials pointing to your managed database

`API_BASE_URL` stays empty for production — nginx proxies API requests via relative URLs. Optionally enable `USE_S3=True` and `EMAIL_NOTIFICATIONS_ENABLED=True` with their respective credentials.

## 🧪 Running Tests

```bash
docker compose run --rm --build backend-test     # backend tests (Django + pytest)
docker compose run --rm --build frontend-test    # frontend tests (Flutter)
```

## 🔧 Configuration

All configuration is via environment variables. Copy `.env.example` to `.env` for local development.

| Variable                      | Default                       | Description                                                                           |
| ----------------------------- | ----------------------------- | ------------------------------------------------------------------------------------- |
| `POSTGRES_DB_NAME`            | `keep_playing`                | Database name                                                                         |
| `POSTGRES_USER`               | `keepplaying`                 | Database user                                                                         |
| `POSTGRES_PASSWORD`           | `keepplaying`                 | Database password                                                                     |
| `POSTGRES_HOST`               | `localhost`                   | Database host (`postgres` in Docker)                                                  |
| `SECRET_KEY`                  | insecure dev key              | Django secret key (required in production)                                            |
| `DEBUG`                       | `False`                       | Django debug mode (`.env.example` sets `True` for dev)                                |
| `ALLOWED_HOSTS`               | `localhost,127.0.0.1,backend` | Comma-separated allowed hosts                                                         |
| `USE_S3`                      | `False`                       | Enable S3 storage for media files                                                     |
| `EMAIL_NOTIFICATIONS_ENABLED` | `False`                       | Enable email notifications via Mailgun                                                |
| `API_BASE_URL`                | _(empty)_                     | Frontend API base URL (empty = relative, behind nginx)                                |
| `CSRF_TRUSTED_ORIGINS`        | _(empty)_                     | Comma-separated HTTPS origins allowed to POST/PATCH (e.g., `https://app.example.com`) |

For production, set `DEBUG=False` and provide a real `SECRET_KEY`. The app will refuse to start with the default insecure key when debug mode is off.

## 🛠 Tech Stack

| Layer          | Technology                                       |
| -------------- | ------------------------------------------------ |
| Backend        | Django 5.2, Django REST Framework, PostgreSQL 14 |
| Frontend       | Flutter 3.41 (web), BLoC/Cubit state management  |
| Infrastructure | Docker Compose, nginx reverse proxy, gunicorn    |

See [backend/README.md](backend/README.md) and [frontend/README.md](frontend/README.md) for component-specific documentation.

> **Docs drift note**: the module READMEs describe the code as of their last update. When the structure changes (files renamed, responsibilities shifted), run `git log -- <module>/` to see what's changed recently; the README may be behind.
