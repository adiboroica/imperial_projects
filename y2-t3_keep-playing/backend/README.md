# Keep Playing — Backend

Django REST Framework API serving the Keep Playing platform.

## 💻 Local Development

**With Docker** (recommended):

```bash
docker compose --profile dev up    # from project root — runs postgres + backend with hot reload
```

**Without Docker** (requires Python 3.12+ and a running PostgreSQL instance):

```bash
cp ../.env.example ../.env         # create env config if not already done
pip install -e ".[test]"
python manage.py makemigrations app
python manage.py migrate
python manage.py seed_demo_data
python manage.py runserver
```

> `psycopg2` compiles from source, so local installs need the PostgreSQL client libraries:
> - Ubuntu/Debian: `sudo apt-get install libpq-dev build-essential`
> - macOS: `brew install postgresql`
> - Windows: install PostgreSQL via the official installer, or swap `psycopg2` for `psycopg2-binary` in a local branch.

The settings module reads `.env` from the backend directory or the project root.

## 🧪 Running Tests

**With Docker** (recommended):

```bash
docker compose run --rm --build backend-test    # from project root
```

**Without Docker**:

```bash
pytest
```

Tests cover auth, models, events CRUD, coach workflows, organiser workflows, email notifications, input validation, and permission checks.

## 🔍 Dependency Audit

Check installed Python dependencies for known CVEs:

```bash
docker compose run --rm backend pip-audit
# or without Docker:
pip-audit
```

## 🧹 Formatting & Lint

Ruff handles both formatting and import-order linting:

```bash
docker compose run --rm backend ruff format .        # apply formatter
docker compose run --rm backend ruff check .         # lint (relative-import ban, etc.)
```

## 📊 Test Coverage

```bash
docker compose run --rm backend pytest --cov=app --cov-report=term-missing
# or without Docker:
pytest --cov=app --cov-report=term-missing
```

## 📡 API Endpoints

All endpoints except registration and login require a `Token` header (`Authorization: Token <token>`).

### Auth

| Method | Path              | Description                            |
| ------ | ----------------- | -------------------------------------- |
| POST   | `/login/`         | Obtain auth token (rate-limited)       |
| POST   | `/logout/`        | Invalidate auth token (requires login) |
| POST   | `/new_coach/`     | Register a coach account               |
| POST   | `/new_organiser/` | Register an organiser account          |

### Users

| Method | Path      | Description           |
| ------ | --------- | --------------------- |
| GET    | `/hello/` | Greeting (auth check) |
| GET    | `/users/` | List all coaches      |
| GET    | `/user/`  | Current user profile  |
| POST   | `/user/`  | Create user profile   |
| PATCH  | `/user/`  | Update user profile   |

### Coach Actions

| Method | Path                          | Description                                  |
| ------ | ----------------------------- | -------------------------------------------- |
| GET    | `/coach/feed/`                | Available events (excludes blocked/assigned) |
| GET    | `/coach/upcoming-jobs/`       | Assigned future events                       |
| PATCH  | `/coach/events/<pk>/apply/`   | Apply to an event                            |
| PATCH  | `/coach/events/<pk>/unapply/` | Withdraw application                         |
| PATCH  | `/coach/events/<pk>/cancel/`  | Cancel an assigned job                       |
| GET    | `/coach/<pk>/`                | View a coach's profile                       |

### Organiser Actions

| Method | Path                                        | Description                        |
| ------ | ------------------------------------------- | ---------------------------------- |
| GET    | `/organiser/`                               | Current organiser profile          |
| PATCH  | `/organiser/`                               | Update organiser settings/defaults |
| GET    | `/organiser/events/`                        | List own events                    |
| POST   | `/organiser/events/`                        | Create an event                    |
| PATCH  | `/organiser/events/<pk>/`                   | Update an event                    |
| DELETE | `/organiser/events/<pk>/`                   | Delete an event                    |
| PATCH  | `/organiser/events/<pk>/accept/<coach_pk>/` | Accept a coach's offer             |
| PATCH  | `/organiser/block/<coach_pk>/`              | Block a coach                      |
| PATCH  | `/organiser/unblock/<coach_pk>/`            | Unblock a coach                    |
| PATCH  | `/organiser/add-favourite/<coach_pk>/`      | Add coach to favourites            |
| PATCH  | `/organiser/remove-favourite/<coach_pk>/`   | Remove coach from favourites       |
| PATCH  | `/organiser/vote/<event_pk>/`               | Rate a coach for a past event      |
| GET    | `/organiser/events/<pk>/offers/`            | List coach offers for an event     |
| GET    | `/organiser/coach-model/<coach_pk>/`        | Get coach rating data              |
| GET    | `/organiser/<pk>/`                          | View an organiser's public profile |

### Cross-Cutting

| Method | Path                     | Description                   |
| ------ | ------------------------ | ----------------------------- |
| GET    | `/event/<pk>/organiser/` | Get the organiser of an event |

## 📂 Sub-Module Documentation

- [App Architecture](app/README.md) — dependency hierarchy and module overview
- [Models](app/models/README.md) — domain models and relationships
- [Services](app/services/README.md) — business logic and orchestration
- [Views](app/views/README.md) — thin HTTP wrappers and permission model
- [Serializers](app/serializers/README.md) — request validation and response shaping
- [Tests](tests/README.md) — test suite overview with coverage details
