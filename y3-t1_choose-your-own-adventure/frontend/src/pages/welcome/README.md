# Welcome Page

Landing screen at `/` for unauthenticated visitors. Logged-in users are redirected to `/dashboard` and never reach this page.

## 📋 Overview

A static hero with the project's tagline and two CTAs — `Log in` and `Sign up` — that link to the corresponding routes. The page renders no nav chrome (the header's tab list is empty when logged out) so first-time visitors land on a clean marketing surface, not on a half-rendered app shell.

## 📐 Design

- **No store wiring** — the page reads no state and dispatches no thunks. It only routes to `/login` or `/signup`.
- **Two CTAs, equal weight** — `Log in` is the filled primary button, `Sign up` is the outlined secondary. New visitors are nudged to sign up but the affordance is symmetrical.
- **Component-only file** — no `slices/` or `components/` subfolders; the route screen is the page.

## 🔗 Dependencies

Imports from [`@mantine/core`](https://mantine.dev/) and [`react-router-dom`](https://reactrouter.com/), and from [`../../utils/routes.ts`](../../utils/routes.ts) (`LOGIN_PAGE`, `SIGNUP_PAGE`). Never imports from `state`, `api/`, or another page.
