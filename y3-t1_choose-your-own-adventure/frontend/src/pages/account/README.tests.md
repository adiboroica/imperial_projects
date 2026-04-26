# Account Tests

Test contract for the account page (`/account`).

## 📋 Overview

Two units: `AccountPage` and `ApiKeyForm`. Test files co-located alongside source. Auth-slice tests live in [`features/auth/README.tests.md`](../../features/auth/README.tests.md).

## ▶️ Running

    npm test -- src/pages/account

See [`../../../tests/README.md`](../../../tests/README.md) for the full test runner commands.

## 🧪 AccountPage

Renders the logged-in user's email and embeds `ApiKeyForm`. Provides a logout button.

### Core Functionality

| Area              | Description                                                          |
| ----------------- | -------------------------------------------------------------------- |
| Render user email | Reads `state.auth.user.email` and renders it.                        |
| Render ApiKeyForm | Always renders `ApiKeyForm` for the logged-in user.                  |
| Logout dispatch   | Logout button dispatches `logout()` thunk; navigates to `/` (Welcome page once logged out). |

### Edge Cases

| Case               | Expected Behaviour                                            |
| ------------------ | ------------------------------------------------------------- |
| User not logged in | `App.tsx` route guard redirects to `/login` before render.    |
| Logout in flight   | Logout button shows a spinner; clicking again is a no-op.     |

## 🧪 ApiKeyForm

Input + save button; reads `apiKey` from auth-slice state, dispatches `updateApiKey` on save.

### Core Functionality

| Area                | Description                                              |
| ------------------- | -------------------------------------------------------- |
| Render current key  | Shows the user's stored key (or empty if unset).         |
| Save dispatches     | Save button dispatches `updateApiKey(input)`.            |
| Disabled when empty | Save button is disabled when the input is empty.         |

### Edge Cases

| Case                    | Expected Behaviour                                          |
| ----------------------- | ----------------------------------------------------------- |
| Whitespace-only input   | Save is disabled.                                           |
| `updateApiKey.rejected` | Toast surfaces error; input retains the user's typed value. |
