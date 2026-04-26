# Account

The logged-in user's account screen at `/account` — email and API-key management.

## 📋 Overview

One page (`AccountPage.tsx`) and one page-local component (`ApiKeyForm.tsx`). The auth state itself lives in [`features/auth/`](../../features/auth/README.md), which the account page reads from and dispatches into.

## 🏗️ Structure

    account/
    ├── AccountPage.tsx
    └── components/
        └── ApiKeyForm.tsx

## 📐 Design

- **Auth state lives in the auth feature** — `AccountPage` reads `state.auth.user` and `state.auth.apiKey` via typed hooks; dispatches `logout`, `getApiKey`, and `updateApiKey` thunks defined in [`features/auth/slices/auth.ts`](../../features/auth/slices/auth.ts).
- **`ApiKeyForm` is page-local** — only `AccountPage` uses it. If a future flow needed an API-key prompt elsewhere, `ApiKeyForm` would graduate to [`components/shared/`](../../components/README.md).
- **Route guard upstream** — `App.tsx` redirects unauthenticated visitors to `/login` before this page renders.

## 🔗 Dependencies

Imports from [`../../types`](../../types) (`user`, `api_key`), [`../../features/auth`](../../features/auth), [`../../components`](../../components), and [`../../store/hooks.ts`](../../store/hooks.ts). Never imports from another page.
