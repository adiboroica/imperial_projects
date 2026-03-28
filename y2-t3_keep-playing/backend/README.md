# Keep Playing — Backend

Django REST Framework API serving the Keep Playing platform.

## 💻 Local Development

Requires Python 3.12+ and a running PostgreSQL instance.

```bash
pip install -e ".[test]"
python manage.py makemigrations app
python manage.py migrate
python manage.py seed_demo_data
python manage.py runserver
```

### Running tests

```bash
pytest
```

Tests cover auth, models, events CRUD, coach workflows, and organiser workflows.

## 📡 API Endpoints

All endpoints except registration and login require a `Token` header (`Authorization: Token <token>`).

### Auth

| Method | Path              | Description                   |
| ------ | ----------------- | ----------------------------- |
| POST   | `/login/`         | Obtain auth token             |
| POST   | `/new_coach/`     | Register a coach account      |
| POST   | `/new_organiser/` | Register an organiser account |

### Users

| Method | Path      | Description           |
| ------ | --------- | --------------------- |
| GET    | `/hello/` | Greeting (auth check) |
| GET    | `/users/` | List all users        |
| GET    | `/user/`  | Current user profile  |

### Coach Actions

| Method | Path                          | Description                                  |
| ------ | ----------------------------- | -------------------------------------------- |
| GET    | `/coach/feed/`                | Available events (excludes blocked/assigned) |
| GET    | `/coach/upcoming-jobs/`       | Assigned future events                       |
| PATCH  | `/coach/events/<id>/apply/`   | Apply to an event                            |
| PATCH  | `/coach/events/<id>/unapply/` | Withdraw application                         |
| PATCH  | `/coach/events/<id>/cancel/`  | Cancel an assigned job                       |
| GET    | `/coach/<id>/`                | View a coach's profile                       |

### Organiser Actions

| Method | Path                                        | Description                        |
| ------ | ------------------------------------------- | ---------------------------------- |
| GET    | `/organiser/`                               | Current organiser profile          |
| PATCH  | `/organiser/`                               | Update organiser settings/defaults |
| GET    | `/organiser/events/`                        | List own events                    |
| POST   | `/organiser/events/`                        | Create an event                    |
| PATCH  | `/organiser/events/<id>/`                   | Update an event                    |
| DELETE | `/organiser/events/<id>/`                   | Delete an event                    |
| PATCH  | `/organiser/events/<id>/accept/<coach_id>/` | Accept a coach's offer             |
| PATCH  | `/organiser/block/<coach_id>/`              | Block a coach                      |
| PATCH  | `/organiser/unblock/<coach_id>/`            | Unblock a coach                    |
| PATCH  | `/organiser/add-favourite/<coach_id>/`      | Add coach to favourites            |
| PATCH  | `/organiser/remove-favourite/<coach_id>/`   | Remove coach from favourites       |
| PATCH  | `/organiser/vote/<event_id>/`               | Rate a coach for a past event      |
| GET    | `/organiser/coach-model/<coach_id>/`        | Get coach rating data              |

### Cross-Cutting

| Method | Path                     | Description                   |
| ------ | ------------------------ | ----------------------------- |
| GET    | `/event/<id>/organiser/` | Get the organiser of an event |
