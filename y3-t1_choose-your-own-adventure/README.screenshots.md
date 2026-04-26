# Screenshots

A visual tour of the running app, plus an archive of GIFs from an earlier version of the UI.

## 📋 Overview

The current UI is captured as static PNGs taken from the dev stack at `docs/screenshots/`. The four GIFs in `docs/screenshots/legacy/` were captured against an earlier build — the flows still illustrate the major paths through the app, but the visuals have evolved (auth-aware routing, polished header, refreshed Mantine layouts).

## 🖼️ Current UI

### Welcome

![Welcome page with Log in and Sign up CTAs](docs/screenshots/welcome.png)

The unauthenticated landing page at `/`. Hero copy plus the two routing CTAs. Owned by [`frontend/src/pages/welcome/`](frontend/src/pages/welcome/README.md). Logged-in users hitting `/` are redirected straight to `/dashboard`.

### Login

![Log in form](docs/screenshots/login.png)

`/login` — email + password form, "No account? Sign up" link to `/signup`. Owned by [`frontend/src/pages/login/`](frontend/src/pages/login/README.md); the underlying thunk lives in [`frontend/src/features/auth/`](frontend/src/features/auth/README.md).

### Signup

![Sign up form](docs/screenshots/signup.png)

`/signup` — email + password (`Minimum 8 characters` hint), "Already have an account? Log in" link. Owned by [`frontend/src/pages/signup/`](frontend/src/pages/signup/README.md).

### Dashboard

![Dashboard with two demo stories](docs/screenshots/dashboard.png)

`/dashboard` — the current user's stories with first-paragraph previews, section counts, and an `Open` / delete affordance per row. The `New story` button routes to `/setup`. Owned by [`frontend/src/pages/dashboard/`](frontend/src/pages/dashboard/README.md); REST CRUD is documented in [`backend/src/routers/`](backend/src/routers/README.md).

### Setup (new story)

![Setup form for a new story](docs/screenshots/setup.png)

`/setup` — genre picker (or `Custom` toggle), attribute table (themes, characters, items by default), and the `Generate story` button that fires the first WebSocket request. Owned by [`frontend/src/pages/setup/`](frontend/src/pages/setup/README.md); the WS protocol is described in [`backend/src/routers/`](backend/src/routers/README.md).

### Account

![Account page with email and API-key form](docs/screenshots/account.png)

`/account` — signed-in email, `Log out` button, and the OpenAI API-key form. Keys are encrypted at rest by [`backend/src/services/api_key.py`](backend/src/services/) before they hit MongoDB.

### Generator

![Generator graph canvas with the options panel](docs/screenshots/generator.png)

`/generator/:storyId` — the interactive graph editor for an open story. Left: the ReactFlow canvas with narrative and action nodes laid out by dagre. Right: the node-options panel for the selected node (`Narrative` text, `Mark as ending`, `Generate actions`, `Add another action`, `Bulk-expand subtree`, `Delete node`). Top: title + creativity / action-count / bulk-depth knobs. Owned by [`frontend/src/pages/generator/`](frontend/src/pages/generator/README.md); generation orchestration lives in [`backend/src/services/generation.py`](backend/src/services/).

## 🎬 Earlier Captures (legacy)

> The GIFs below were taken against an earlier version of the UI — before the auth-aware routing, the multi-stage Docker build, and the polished header. The flows still illustrate the major paths through the app; visual details have evolved.

### Authentication flow (legacy)

![Authentication flow — earlier UI](docs/screenshots/legacy/auth-flow.gif)

Welcome page transitioning into signup and login. Modern equivalents: [`welcome.png`](docs/screenshots/welcome.png), [`login.png`](docs/screenshots/login.png), [`signup.png`](docs/screenshots/signup.png).

### Dashboard (legacy)

![Dashboard — earlier UI](docs/screenshots/legacy/dashboard.gif)

Story library walkthrough with delete confirmation. Modern equivalent: [`dashboard.png`](docs/screenshots/dashboard.png).

### Setup (legacy)

![Setup form — earlier UI](docs/screenshots/legacy/setup.gif)

Genre + attributes form filling out before kicking off generation. Modern equivalent: [`setup.png`](docs/screenshots/setup.png).

### Generator (legacy)

![Generator graph — earlier UI](docs/screenshots/legacy/generator.gif)

Graph editor with node expansion, save, and download. Modern equivalent: [`generator.png`](docs/screenshots/generator.png).

## 📂 Sub-Module Documentation

- [`README.md`](README.md) — root README with quick start, the demo account, and configuration.
- [`README.tech-stack.md`](README.tech-stack.md) — primer on every library and framework in the stack.
