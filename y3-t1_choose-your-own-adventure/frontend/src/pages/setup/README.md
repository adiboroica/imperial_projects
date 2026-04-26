# Setup

The form where the user kicks off a new story — picks a genre, fills in attributes (characters, items, setting), and starts generation.

## 📋 Overview

One route screen, one slice, six page-local components for the form fields:

- **`SetupPage.tsx`** (`/new`) — the form layout; submits the gathered theme and attributes to start a new story.
- **`slices/setup.ts`** — form state (selected genre, attribute rows) and the `startStory` thunk that creates the story, navigates to `/generator/:id`, and seeds the generator's `initialStory` WS request.
- Six form components covering the genre dropdown, attribute editor, free-text input, and submit button.

## 🏗️ Structure

    setup/
    ├── SetupPage.tsx
    ├── slices/
    │   └── setup.ts
    └── components/                 ─ genre dropdown, attribute editor, free-text input, submit button
        └── *.tsx

## 📐 Design

- **Form state lives in the slice, not in component state** — `SetupPage` reads from `useAppSelector` and dispatches changes; per-component `useState` is reserved for transient UI (e.g., is a dropdown open). Keeping the form in Redux makes it resumable across navigation and trivially testable.
- **`startStory` is a multi-step thunk** — calls `api.stories.create(...)` to mint a fresh story id, navigates to `/generator/:id`, then sends an `initialStory` WS frame to populate the root narrative. Failure at any step rolls the slice back and surfaces a notification via `notificationMiddleware`.
- **Components stay presentational** — every form widget takes its value plus an `onChange` callback as props. Store wiring happens in `SetupPage`, not inside the widgets.

## 🔗 Dependencies

Imports from [`../../types`](../../types) (`story`), [`../../api`](../../api) (`stories`, `generation`), [`../../components`](../../components), and [`../../store/hooks.ts`](../../store/hooks.ts). Never imports from another page.
