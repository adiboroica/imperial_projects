# Pages

Per-page folders. One folder per URL route; each folder owns its route screen, page-local slice(s), and page-local components.

## 📋 Overview

Seven top-level pages. The Welcome page hosts `/` for unauthenticated visitors only — logged-in users hitting `/` are redirected to `/dashboard`.

- **`account/`** — logged-in user info and API-key management (`/account`).
- **`dashboard/`** — the current user's stories (`/dashboard`).
- **`generator/`** — interactive graph editor with WebSocket-driven generation (`/generator/:id`).
- **`login/`** — login form (`/login`).
- **`signup/`** — signup form (`/signup`).
- **`setup/`** — theme + attributes form for starting a new story (`/new`).
- **`welcome/`** — landing page for unauthenticated visitors (`/`).

## 🏗️ Page Anatomy

Every page folder follows the same shape:

    pages/<name>/
    ├── <Name>Page.tsx              ← the route screen at the folder root
    ├── slices/                     ← Redux slice(s) owned by the page (if any)
    │   └── <name>.ts
    └── components/                 ← page-local components (if any)
        └── ...

`slices/` and `components/` are present only when there's something to put there. State shared across pages lives in [`../features/`](../features/README.md), not in any single page.

## 📐 Conventions

- **`slices/` and `components/` only when there's something to put there** — `welcome/`, `login/`, and `signup/` have neither (they're just their `Page.tsx` files). Empty folders are not added for uniformity.
- **Slice files drop the `Slice` suffix** — the folder already declares the kind, so `slices/dashboard.ts` exports `dashboardSlice`. For pages with multiple slices (e.g., the generator), file names describe the concern: `slices/graph.ts` exports `graphSlice`, `slices/params.ts` exports `paramsSlice`, `slices/loading.ts` exports `loadingSlice`.
- **Cross-page state lives in `features/`** — when a slice is read by more than one page, it lives in `features/<feature>/slices/`, not inside any single page. Pages import it from there.

For the broader page rules — independence between pages, page-local component privacy, `store/hooks`-only imports — see [`../README.md`](../README.md).

## 📂 Sub-Module Documentation

- [`account/`](account/README.md) — account screen.
- [`dashboard/`](dashboard/README.md) — story list.
- [`generator/`](generator/README.md) — interactive graph editor.
- [`login/`](login/README.md) — login form.
- [`signup/`](signup/README.md) — signup form.
- [`setup/`](setup/README.md) — new-story theme + attributes form.
- [`welcome/`](welcome/README.md) — unauthenticated landing page.
