# Login

The login page at `/login`.

## 📋 Overview

One file: `LoginPage.tsx`. Form for email and password; dispatches the `login` thunk from the auth feature; navigates to `/dashboard` on success.

## 🏗️ Structure

    login/
    └── LoginPage.tsx

## 📐 Design

- **No own slice** — login state (`loggedIn`, `user`) is shared with the signup and account pages, owned by [`features/auth/`](../../features/auth/README.md). The login page dispatches the thunk and reads loading state from there.
- **Form widgets inline** — for a two-input form (email + password), separate components would be ceremony. The form lives directly in `LoginPage.tsx`.
- **Success navigation** — on `login.fulfilled`, calls `useNavigate()` to go to `/dashboard`. Failures stay on the page; `notificationMiddleware` shows the toast.

## 🔗 Dependencies

Imports from [`../../types`](../../types) (`auth`), [`../../features/auth`](../../features/auth) (the `login` thunk), [`../../components`](../../components), and [`../../store/hooks.ts`](../../store/hooks.ts). Never imports from another page.
