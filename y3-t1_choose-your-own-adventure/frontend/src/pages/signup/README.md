# Signup

The signup page at `/signup`.

## 📋 Overview

One file: `SignupPage.tsx`. Form for email and password; dispatches the `signup` thunk from the auth feature; navigates to `/dashboard` on success.

## 🏗️ Structure

    signup/
    └── SignupPage.tsx

## 📐 Design

- **No own slice** — auth state is shared with the login and account pages, owned by [`features/auth/`](../../features/auth/README.md). The signup page dispatches the thunk and reads loading state from there.
- **Form widgets inline** — same simple two-input form as the login page; no separate components needed.
- **Success navigation** — on `signup.fulfilled`, calls `useNavigate()` to go to `/dashboard`.

## 🔗 Dependencies

Imports from [`../../types`](../../types) (`auth`), [`../../features/auth`](../../features/auth) (the `signup` thunk), [`../../components`](../../components), and [`../../store/hooks.ts`](../../store/hooks.ts). Never imports from another page.
