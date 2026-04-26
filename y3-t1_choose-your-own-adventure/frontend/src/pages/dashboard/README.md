# Dashboard

The user's story library — a list of saved stories with quick actions to open or delete each one.

## 📋 Overview

One route screen, one slice, two page-local components:

- **`DashboardPage.tsx`** (`/dashboard`) — fetches the user's stories on mount and renders them as a list.
- **`StoryListItem.tsx`** — one story preview row: title, first paragraph, action count, open and delete buttons.
- **`DeleteStoryButton.tsx`** — confirmation-wrapped delete trigger.

## 🏗️ Structure

    dashboard/
    ├── DashboardPage.tsx
    ├── slices/
    │   └── dashboard.ts
    └── components/
        ├── StoryListItem.tsx
        └── DeleteStoryButton.tsx

## 📐 Design

- **List loads on mount** — `DashboardPage` dispatches `listStories()` inside a `useEffect`; the slice tracks loading and error states so the page can render a skeleton during the fetch and a toast on failure.
- **Delete is pessimistic** — `DeleteStoryButton` dispatches `deleteStory(id)` and disables itself while the request is in flight. The slice removes the story from local state only on the `fulfilled` action; on `rejected`, the row stays and a toast appears. Destructive operations want the user to see real confirmation that the backend acted, not an optimistic flash followed by a rollback.
- **Components stay presentational** — `StoryListItem` takes a `Story` prop plus `onOpen` and `onDelete` callbacks; it does not read state or dispatch directly. The page wires the callbacks to slice actions.

## 🔗 Dependencies

Imports from [`../../types`](../../types) (`story`), [`../../api`](../../api) (`stories`), [`../../components`](../../components), and [`../../store/hooks.ts`](../../store/hooks.ts). Never imports from another page.
