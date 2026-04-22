# Frameworks & Libraries

A short primer for anyone reading this repo who isn't already fluent with the main frameworks in the stack. Each entry is a quick overview of the framework; the final section traces how they line up end-to-end in Keep Playing.

## 🎨 Frontend

**[Flutter](https://docs.flutter.dev/)** — a UI toolkit from Google for building apps from a single [Dart](https://dart.dev/) codebase.  
UIs are trees of **widgets**; when state changes, Flutter rebuilds the affected subtree and diffs it against the last frame before painting.  
One codebase targets iOS, Android, web, and desktop.

**[flutter_bloc](https://bloclibrary.dev/) (BLoC / Cubit)** — state management for Flutter.  
A **Cubit** holds a single piece of state and exposes methods that emit new values; widgets subscribe via `BlocBuilder` and rebuild on each emission.  
**BLoC** is the fuller variant: widgets dispatch typed **event objects** (plain classes like `FeedLoadRequested` or `FeedItemTapped`) into the bloc instead of calling methods, and each event type is matched to a handler that emits the new state. Cubit is the lighter, method-driven form.

## ⚙️ Backend

**[Django](https://docs.djangoproject.com/)** — the batteries-included Python web framework.  
Ships an ORM, migrations, auth primitives, an admin UI, and a `manage.py` CLI for database and project operations.

**[Django REST Framework (DRF)](https://www.django-rest-framework.org/)** — a REST layer on top of Django.  
Views extend `APIView` with explicit `get`/`post`/`patch`/`delete` methods;  
`Serializer` classes validate incoming JSON and shape outgoing JSON; token and session authentication, permissions, and throttling are built in.

**[django-q2](https://django-q2.readthedocs.io/)** — a background task queue for Django that stores jobs in the database itself (no Redis/RabbitMQ needed).  
Request handlers enqueue work with `async_task(...)`; a separate `qcluster` worker process picks jobs up and runs them out-of-band, so the HTTP response isn't blocked on slow side-effects like SMTP.

## 🐳 Infrastructure

**[Docker Compose](https://docs.docker.com/compose/)** — declaratively describes a set of containers and how they're networked, so the whole stack boots with a single command. Profiles allow selectively enabling services (e.g. dev- or test-only containers).

**[nginx](https://nginx.org/)** — a web server and reverse proxy. Commonly used to terminate HTTP, serve static files directly, and forward dynamic traffic to an application server over the local network.

**[gunicorn](https://gunicorn.org/)** — a production WSGI server for Python web apps. Runs the application across multiple worker processes and typically sits behind a reverse proxy.

**[PostgreSQL](https://www.postgresql.org/docs/)** — a mature, open-source relational database with strong SQL compliance, transactional DDL, and rich indexing.

## 🧩 How They Fit Together

**A REST request** (coach applies to an event, `PATCH /coach/events/42/apply/`):

1. Browser sends the request to nginx on port `80` with `Authorization: Token <t>`.
2. nginx matches `/coach/...` and proxies to `backend:8000` (gunicorn + Django).
3. DRF's router hits `CoachEventView.patch` in [backend/app/views/coaches.py](backend/app/views/coaches.py). `ExpiringTokenAuthentication` validates the token; `IsCoach` confirms the user's role.
4. The view calls `apply_to_event(request.user, pk)` in [backend/app/services/coach.py](backend/app/services/coach.py), which enforces rules ("not past", "not already assigned", "not blocked"), adds the coach to `event.offers` inside `transaction.atomic()`, then calls `notify_organiser_new_offer(...)`.
5. `notify_organiser_new_offer` enqueues a django-q2 task via `async_task(...)` — the request doesn't wait for SMTP. The `backend-worker` container picks it up and sends the email.
6. DRF serialises the updated `Event`; the view returns `202 Accepted`.

**A frontend state update** (coach opens the feed):

1. `FeedPage` is built, its `BlocProvider` creates a `FeedCubit` wired to the `CoachRepository` injected at the app root ([frontend/lib/main.dart](frontend/lib/main.dart)).
2. `FeedCubit.loadFeed()` emits `DataLoading` and calls `coachRepository.getFeedEvents()` — the concrete implementation is `ApiCoach`, which hits `GET /coach/feed/` via `ApiClient` ([frontend/lib/api/client.dart](frontend/lib/api/client.dart)).
3. Each JSON object is parsed into an `Event` via `Event.fromJson`; the cubit emits `DataLoaded(events)` on success or `DataError(...)` on failure.
4. A `BlocBuilder<FeedCubit, DataState<List<Event>>>` in `FeedPage` matches on the state variant and rebuilds — `LoadingIndicator`, the event list, or `ErrorDisplay` with a retry button.
