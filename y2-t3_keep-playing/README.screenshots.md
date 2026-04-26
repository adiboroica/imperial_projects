# Screenshots

A visual tour of the running app.

## 📋 Overview

The current UI is captured as static PNGs taken from the dev stack at `docs/screenshots/`. The Flutter web app renders inside a phone-frame wrapper at `http://localhost`, so the screenshots reflect that framing.

## 🖼️ Current UI

### Landing

![Landing page with "Enter as organiser" and "Enter as coach" CTAs](docs/screenshots/01-landing.png)

The unauthenticated entry point. Two pill-shaped role buttons route to the organiser or coach login flow. Owned by [`frontend/lib/pages/landing_page.dart`](frontend/lib/pages/landing_page.dart). Logged-in users hitting the landing page are auto-redirected to their role's home (`OrganiserHomePage` or `CoachHomePage`); users who hold both roles get a chooser dialog before navigation.

### Login

![Login form with the Keep Playing logo, username and password fields, and a sign-up link](docs/screenshots/02-login.png)

Username + password form fronted by the Keep Playing logo, with a `Sign Up` link below the login button. The app bar title (`Organiser Login` here, or `Coach Login` for the coach entry) marks which role variant is active — the same widget powers both, with each variant supplying a role check and a sign-up route. Owned by [`frontend/lib/pages/shared_login_page.dart`](frontend/lib/pages/shared_login_page.dart); the underlying auth state lives in [`frontend/lib/state/`](frontend/lib/state/) and credentials are verified by [`backend/app/views/`](backend/app/views/README.md).

### Organiser (Calendar)

![Organiser events screen in calendar mode with filter toggles and event dots on scheduled days](docs/screenshots/03-organiser-calendar.png)

The organiser's events screen in **calendar mode** — a `table_calendar` view with event dots on days that have something scheduled, and a highlighted selected day. Three toggles at the top filter past / pending / scheduled events; a `+ New Job` floating button opens the event creator; the bottom tab bar switches between `Events` and `Profile`. The icon in the top-right of the app bar toggles to the [list view](docs/screenshots/04-organiser-events.png). The calendar wrapper comes from [`frontend/lib/widgets/`](frontend/lib/widgets/README.md); events are loaded via the `ApiOrganiser` client in [`frontend/lib/api/`](frontend/lib/api/README.md). Owned by [`frontend/lib/pages/organiser/`](frontend/lib/pages/organiser/).

### Organiser (Events)

![Organiser events screen in list mode showing event cards with date, location, and price](docs/screenshots/04-organiser-events.png)

The same Events screen in **list mode** — every event surfaced as a card with date, time, name, location, and price, plus a `Details` button to drill in. The same past / pending / scheduled toggles and `+ New Job` floating button apply; the calendar icon in the top-right toggles back to [calendar view](docs/screenshots/03-organiser-calendar.png). Owned by [`frontend/lib/pages/organiser/events/`](frontend/lib/pages/organiser/events/); cards come from [`frontend/lib/widgets/`](frontend/lib/widgets/README.md). Events CRUD is documented in [`backend/app/views/`](backend/app/views/README.md).

### Coach (Feed)

![Coach feed showing an open event card with Details and Apply buttons](docs/screenshots/05-coach-feed.png)

The coach's open-event feed, filtered by sport and role. Each card shows date, time, name, location, and price, with `Details` to drill in and `Apply` to express interest in the role. The bottom tab bar switches between `Feed` (here), `Upcoming Jobs` (confirmed assignments), and `Profile`. Owned by [`frontend/lib/pages/coach/feed/`](frontend/lib/pages/coach/feed/); REST CRUD is documented in [`backend/app/views/`](backend/app/views/README.md).

## 📂 Sub-Module Documentation

- [`README.md`](README.md) — root README with quick start, demo accounts, and configuration.
- [`README.tech-stack.md`](README.tech-stack.md) — primer on every library and framework in the stack.
