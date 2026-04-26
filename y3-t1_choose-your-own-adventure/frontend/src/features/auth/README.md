# Auth Feature

Shared state for everything authentication-related. Owns the `auth` slice that login, signup, and the account page all read from.

## 📋 Overview

One slice. Three pages depend on it:

- `/login` reads loading state, dispatches the `login` thunk.
- `/signup` reads loading state, dispatches the `signup` thunk.
- `/account` reads the current user and API-key state, dispatches `logout`, `getApiKey`, and `updateApiKey`.

## 🏗️ Structure

    auth/
    └── slices/
        └── auth.ts

## 📐 Design

- **Single slice for the whole auth domain** — `loggedIn`, `user`, and `apiKey` live here together. They change in lock-step with auth lifecycle events; splitting them would create coordination overhead.
- **All auth thunks live here** — `login`, `signup`, `logout`, `session`, `getApiKey`, `updateApiKey`. Pages consume them by import; they're never redefined per page.
- **No UI in this feature** — the slice has no React components; pages provide their own UI using shared widgets from [`components/shared/`](../../components/README.md).

## 🔗 Dependencies

Imports from [`../../types`](../../types) (`auth`, `user`, `api_key`) and [`../../api`](../../api) (`auth`, `api_key`). The slice's selectors import `RootState` from [`../../store/store.ts`](../../store/store.ts) — a type-only import for selector signatures, the only `store/` reference allowed. Never imports from `pages/`, `components/`, or another feature.
