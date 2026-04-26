# Auth Feature Tests

Test contract for the shared auth slice.

## 📋 Overview

The `auth` slice holds `loggedIn`, `user`, `apiKey`; owns all auth and API-key thunks. One unit. Test file co-located: `auth.test.ts` next to `auth.ts`.

## ▶️ Running

    npm test -- src/features/auth

See [`../../../tests/README.md`](../../../tests/README.md) for the full test runner commands.

## 🧪 Core Functionality

| Area                     | Description                                              |
| ------------------------ | -------------------------------------------------------- |
| `login.fulfilled`        | Sets `loggedIn: true`, populates `user`.                  |
| `signup.fulfilled`       | Sets `loggedIn: true`, populates `user`.                  |
| `logout.fulfilled`       | Clears `loggedIn`, `user`, and `apiKey`.                  |
| `session.fulfilled`      | Populates `user` and sets `loggedIn: true`; called once at app boot to restore the session. |
| `getApiKey.fulfilled`    | Populates `apiKey` (string or `null`).                    |
| `updateApiKey.fulfilled` | Updates `apiKey` to the new value.                        |

## 🧪 Edge Cases

| Case                    | Expected Behaviour                                                  |
| ----------------------- | ------------------------------------------------------------------- |
| `login.rejected`        | State unchanged; `error` populated with typed `InvalidCredentials`. |
| `signup.rejected`       | State unchanged; `error` populated with typed `EmailAlreadyExists`. |
| `session.rejected`      | Clears `loggedIn`, `user`, and `apiKey`; `App.tsx` falls back to the unauthenticated routes (`/` renders the Welcome page). |
| `updateApiKey.rejected` | `apiKey` unchanged; `error` populated.                              |
