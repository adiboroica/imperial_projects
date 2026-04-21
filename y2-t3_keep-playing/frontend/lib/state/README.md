# State Management

Global authentication state using BLoC/Cubit with persistent storage.

## 📋 Overview

The `state/` directory holds app-wide state that outlives any single page. `AuthCubit` manages login, logout, and session restoration. `AuthStorage` persists the token and user to `SharedPreferences` so sessions survive app restarts. `DataState` is a generic sealed class reused by all page-level cubits for their loading/loaded/error lifecycle.

Page-level cubits (`FeedCubit`, `EventsCubit`, `OrganiserCubit`, `UpcomingJobsCubit`) live with their pages in `pages/`, not here — they are scoped to individual screens and destroyed when the page is popped.

## 🏗️ Design

- **AuthState is a sealed class** — five variants (`AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`) enable exhaustive `switch` in the UI. `AuthAuthenticated` carries both the `User` and the `token`.
- **Token validation on startup** — `restoreSession()` doesn't just check local storage; it calls `getCurrentUser()` against the backend to verify the token is still valid. Invalid tokens are cleared silently.
- **Login verifies both token and user** — after receiving a token, `login()` fetches the current user before persisting either. If the user fetch fails, the token is cleared.
- **DataState\<T\> is generic and reused** — `DataInitial`, `DataLoading`, `DataLoaded<T>`, `DataError` provide a standard loading lifecycle. Page-level cubits (`FeedCubit`, `EventsCubit`, etc.) extend `Cubit<DataState<T>>` with their specific data type.
- **Logout invalidates server-side** — `logout()` calls the backend to delete the token before clearing local storage, preventing reuse of stolen tokens.
- **AuthStorage is injectable** — `AuthCubit` accepts an optional `AuthStorage`, defaulting to a real instance. This allows tests to inject a mock.

## 🔗 Dependencies

Imports from `repositories/` and `models/`. Never imports from `api/`, `pages/`, or `widgets/`.
