# Pages

Screen-level widgets organized by user role.

## 📋 Overview

Pages are organized into `coach/` and `organiser/` sub-directories reflecting the two user roles. Shared pages (landing, login) live at the root. Features that need local state management co-locate their Cubit with the page.

## 📱 User Flows

### Coach

- Browse a feed of available events, filtered by sport and role
- View event details and apply or withdraw
- View upcoming confirmed jobs
- View own profile with qualifications

### Organiser

- View all events on a calendar, drill into individual days
- Create, edit, and delete events
- Review coach applications and accept offers
- Rate coaches after events (reliability, flexibility, experience)
- Manage favourites and blocked coaches
- Set default values for new events (sport, role, location, price)

## 🏗️ Design

- **Co-located cubits** — FeedCubit lives in `coach/feed/`, EventsCubit in `organiser/events/`, OrganiserCubit in `organiser/profile/`. These cubits are scoped to their feature and use `DataState<T>` from `state/data_state.dart`.
- **BlocProvider scoping** — page-level cubits are provided via `BlocProvider` at the page level and destroyed when the page is popped. They do not outlive their screen.
- **Shared login page** — `SharedLoginPage` is a generic login form widget. `CoachLoginPage` and `OrganiserLoginPage` wrap it with role-specific configuration.

## 🔗 Dependencies

Imports from `state/`, `widgets/`, `repositories/`, and `models/`. Never imports from `api/` directly — concrete API clients are provided via `MultiRepositoryProvider` at the app root, so pages only see repository interfaces.

See [lib/README.md](../README.md) for the full dependency hierarchy.
