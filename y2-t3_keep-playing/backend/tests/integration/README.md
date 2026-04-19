# Integration Tests

## 📋 Overview

Full HTTP request/response tests using `APIClient` through the DRF middleware stack. Organised by business domain — each file covers a group of related API endpoints, testing happy paths, error cases, permissions, and ownership checks.

## ▶️ Running

    pytest tests/integration

## 📂 Test Files

| File               | Endpoints Covered                                                                 |
| ------------------ | --------------------------------------------------------------------------------- |
| auth_test.py       | `/login/`, `/logout/`, `/new_coach/`, `/new_organiser/`, `/hello/`, `/user/`      |
| coaches_test.py    | `/coach/feed/`, `/coach/upcoming-jobs/`, `/coach/events/<pk>/*`, `/coach/<pk>/`   |
| events_test.py     | `/organiser/events/`, `/organiser/events/<pk>/`, `offers/`, `/event/<pk>/organiser/` |
| organisers_test.py | `/organiser/`, `block/`, `unblock/`, `add-favourite/`, `remove-favourite/`, `accept/`, `vote/`, `coach-model/`, `/organiser/<pk>/` |
| users_test.py      | `/users/`, `/user/` (GET, POST, PATCH)                                            |

## 🧪 Auth (`auth_test.py`)

| Area                      | Description                                                                  |
| ------------------------- | ---------------------------------------------------------------------------- |
| Registration              | Coach and organiser sign-up create User + profile<br/>Duplicate username returns 400 |
| Login                     | Valid credentials return token<br/>Invalid credentials return 400            |
| Logout                    | Deletes token server-side<br/>Token unusable after logout<br/>Unauthenticated returns 401 |
| Hello                     | Returns greeting with username<br/>Unauthenticated returns 401              |
| Token auth                | Valid token accesses `/user/`<br/>Missing token returns 401                  |

## 🧪 Coach Flows (`coaches_test.py`)

| Area           | Description                                                                                       |
| -------------- | ------------------------------------------------------------------------------------------------- |
| Feed           | Shows unassigned future events<br/>Excludes assigned, past, and blocked-organiser events           |
| Apply          | Adds coach to offers (202)<br/>Blocked coach rejected (403)<br/>Past/assigned events rejected (400) |
| Unapply        | Removes coach from offers (202)                                                                    |
| Cancel         | Nulls coach_user (202)<br/>Ignores malicious body fields<br/>Other coach rejected (403)            |
| Upcoming jobs  | Lists assigned events<br/>Excludes other coaches' events                                           |
| Profile view   | Any authenticated user can view `/coach/<pk>/`<br/>Non-existent returns 404<br/>Unauthenticated returns 401 |
| Permissions    | Organiser cannot access feed or apply                                                              |
| Notifications  | Apply triggers `notify_organiser_new_offer`<br/>Cancel triggers `notify_organiser_coach_cancelled`  |

## 🧪 Events (`events_test.py`)

| Area            | Description                                                                                      |
| --------------- | ------------------------------------------------------------------------------------------------ |
| CRUD            | GET lists organiser's events<br/>POST creates event (201)<br/>PATCH updates event (202)<br/>DELETE removes event (200) |
| Offers          | Lists offer users with rating data<br/>Empty when no offers<br/>Non-existent event returns 404<br/>Other organiser rejected (403) |
| Organiser lookup | `/event/<pk>/organiser/` returns the organiser's public profile                                 |
| Validation      | Missing required fields returns 400<br/>Non-existent event returns 404                           |
| Permissions     | Coach cannot create/delete events (403)<br/>Other organiser cannot delete/patch (403)<br/>Unauthenticated returns 401 |

## 🧪 Organiser Flows (`organisers_test.py`)

| Area            | Description                                                                                         |
| --------------- | --------------------------------------------------------------------------------------------------- |
| Profile         | GET returns organiser data<br/>PATCH updates defaults (sport, role, price, location)                 |
| Favourites      | Add returns 202<br/>Remove returns 202                                                               |
| Block           | Block returns 202<br/>Unblock returns 202                                                            |
| Accept offer    | Sets coach_user, clears offers (202)<br/>Non-existent event/coach returns 404<br/>Coach not in offers returns 400<br/>Non-coach user returns 400<br/>Other organiser rejected (403) |
| Vote            | Rates coach, increments scores (200)<br/>Double vote is idempotent<br/>Future event rejected (400)<br/>No-coach event rejected (400)<br/>Non-existent event returns 404<br/>Missing/invalid fields return 400<br/>Other organiser rejected (403) |
| Coach model     | Returns coach rating data                                                                            |
| Public profile  | `/organiser/<pk>/` returns public profile<br/>Non-existent returns 404<br/>Unauthenticated returns 401 |
| Permissions     | Coach cannot access organiser profile or accept offers (403)                                         |

## 🧪 Users (`users_test.py`)

| Area            | Description                                                                            |
| --------------- | -------------------------------------------------------------------------------------- |
| List            | Returns coaches only, excludes password<br/>Unauthenticated returns 401                |
| Create (POST)   | Creates user with hashed password (201)<br/>Unauthenticated returns 401               |
| Update (PATCH)  | Updates name and location<br/>Strips `is_coach`, `is_organiser`, `verified`, `password` |
| Role stripping  | POST ignores `is_coach`, `is_organiser`, `verified` in request body                    |
