# App

The Django application — models, services, API views, and supporting infrastructure.

## 📋 Overview

The app is organized into layered modules with strict dependency direction. Lower layers never import from higher layers. Business logic lives in `services/`, not in views or serializers.

## 🏗️ Dependency Hierarchy

    models/           ← no internal dependencies (pure data)
    permissions.py    ← no internal dependencies (checks request.user)
    authentication.py ← no internal dependencies (extends DRF TokenAuth)
    email.py          ← imports models/
    serializers/      ← imports models/ (validation + JSON only)
    services/         ← imports models/, email.py (business logic + orchestration)
    views/            ← imports services/, serializers/, permissions.py (thin HTTP wrappers)

`config/` sits outside `app/` — it wires everything together via `urls.py` and `settings.py`.

`management/commands/` (e.g., `seed_demo_data`) imports from `models/` directly — it's a development utility outside the runtime graph, so it bypasses services intentionally.

## 📐 Dependency Rules

- `models/` never imports from any other app module
- `serializers/` imports from `models/` only — no business logic, no email, no services
- `services/` imports from `models/` and `email.py` — owns all business logic and orchestration
- `views/` imports from `services/`, `serializers/`, and `permissions.py` — never from `models/` directly for write operations
- `email.py` imports from `models/` only — receives model instances, formats and sends notifications
- Dependencies flow upward only — no circular imports
