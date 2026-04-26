# Features

Cross-page domains. Each feature folder holds state and helpers shared by multiple pages of the same domain — typically a Redux slice, sometimes shared hooks or feature-specific components.

## 📋 Overview

One feature folder per cross-page domain:

- **[`auth/`](auth/README.md)** — login state, user, and API-key state. Used by the `/login`, `/signup`, and `/account` pages.

A feature only earns a folder when state or logic is genuinely shared across multiple pages. Single-page concerns live inside the page's own folder.

## 📐 Conventions

- **Features are independent** — no feature imports from another feature, same rule as pages.
- **Pages may import from features** — a page reads from a feature's slice for shared state and dispatches the feature's thunks.
- **Page-local stays page-local** — only state that's actually shared between multiple pages graduates into a feature.

## 📂 Sub-Module Documentation

- [`auth/`](auth/README.md) — login state, user, API-key state, and the auth thunks.
