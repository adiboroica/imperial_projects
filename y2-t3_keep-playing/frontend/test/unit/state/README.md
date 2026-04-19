# State Management Tests

## 📋 Overview

Unit tests for global authentication state — login/logout flows, session restoration, token validation, and persistent storage.

## ▶️ Running

    flutter test test/unit/state

## 📂 Test Files

| File                   | Classes Tested |
| ---------------------- | -------------- |
| auth_storage_test.dart | AuthStorage    |

Note: AuthCubit tests live in `test/unit/cubits/cubits_test.dart`.

## 🧪 AuthCubit (in `cubits_test.dart`)

### Core Functionality

| Area            | Description                                                                                                  |
| --------------- | ------------------------------------------------------------------------------------------------------------ |
| Initial state   | Starts as `AuthInitial`<br/>`currentUser` returns null                                                       |
| Login success   | Emits `AuthLoading` → `AuthAuthenticated`<br/>Sets token on ApiClient<br/>Persists token and user to storage |
| Logout          | Clears token on ApiClient, clears storage<br/>Emits `AuthUnauthenticated`                                    |
| Restore session | Valid stored token → validates against backend → `AuthAuthenticated`                                         |

### Edge Cases

| Case                                       | Expected Behavior                                         |
| ------------------------------------------ | --------------------------------------------------------- |
| Login with bad credentials (400)           | Emits `AuthError("Invalid credentials")`                  |
| Login with network error                   | Emits `AuthError` with error message, token cleared       |
| Login succeeds but getCurrentUser fails    | Emits `AuthError`, token cleared from ApiClient           |
| Restore session with invalid/expired token | Clears storage, stays `AuthInitial`                       |
| Restore session with no stored token       | Stays `AuthInitial`, no API calls made                    |
| `currentUser` after successful login       | Returns the authenticated User                            |
| `currentUser` after logout                 | Returns null                                              |
| Logout when already unauthenticated        | Clears token/storage, emits `AuthUnauthenticated` (no-op) |

## 🧪 AuthStorage (`auth_storage_test.dart`)

### Core Functionality

| Area  | Description                                                                     |
| ----- | ------------------------------------------------------------------------------- |
| Token | `saveToken` persists, `getToken` retrieves<br/>Returns null when no token saved |
| User  | `saveUser` serializes to JSON, `getUser` deserializes back                      |
| Clear | `clear` removes both token and user                                             |

### Edge Cases

| Case                       | Expected Behavior     |
| -------------------------- | --------------------- |
| `getToken` before any save | Returns null          |
| `getUser` before any save  | Returns null          |
| `getToken` after `clear`   | Returns null          |
| `getUser` after `clear`    | Returns null          |
| Save then overwrite token  | Latest token returned |
| Save then overwrite user   | Latest user returned  |
