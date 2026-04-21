# Pages

Screen-level widgets organized by user role.

## 📋 Overview

Pages are organized into `coach/` and `organiser/` sub-directories reflecting the two user roles. Shared pages (landing, login) live at the root. Features that need local state management co-locate their Cubit with the page.

See [the frontend README](../../README.md) for the user-flow summary by role.

## 📂 Layout

    pages/
    ├── landing_page.dart          # role selector
    ├── shared_login_page.dart     # generic login form used by both roles
    ├── coach/                     # coach-role pages
    │   ├── feed/                  # event browse + FeedCubit
    │   └── upcoming_jobs/         # assigned jobs + UpcomingJobsCubit
    └── organiser/                 # organiser-role pages
        ├── events/                # calendar, day drill-in, create/edit + EventsCubit
        ├── profile/               # defaults, favourites, blocked + OrganiserCubit
        └── past_event/            # past-event detail + rate-coach

## 🏗️ Design

- **Co-located cubits** — `FeedCubit` lives in `coach/feed/`, `EventsCubit` in `organiser/events/`, `OrganiserCubit` in `organiser/profile/`. These cubits are scoped to their feature and use `DataState<T>` from `state/data_state.dart`.
- **BlocProvider scoping** — page-level cubits are provided via `BlocProvider` at the page level and destroyed when the page is popped. They do not outlive their screen.
- **Shared login page** — `SharedLoginPage` is a generic login form widget. `CoachLoginPage` and `OrganiserLoginPage` wrap it with role-specific configuration.

## 🔗 Dependencies

Imports from `state/`, `widgets/`, `repositories/`, and `models/`. Never imports from `api/` directly — concrete API clients are provided via `MultiRepositoryProvider` at the app root, so pages only see repository interfaces.

See [lib/README.md](../README.md) for the full dependency hierarchy.
