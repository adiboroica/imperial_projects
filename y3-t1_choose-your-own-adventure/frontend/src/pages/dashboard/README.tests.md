# Dashboard Tests

Test contract for the dashboard page (story list).

## 📋 Overview

Four units: the page, the slice, and the two page-local components. Test files are co-located: `<Name>.test.tsx` next to `<Name>.tsx`, `<name>.test.ts` next to `<name>.ts`.

## ▶️ Running

    npm test -- src/pages/dashboard

See [`../../../tests/README.md`](../../../tests/README.md) for the full test runner commands.

## 🧪 DashboardPage

Mounts, fetches the user's stories, renders a loading state and then the list. Wires `StoryListItem` callbacks to slice actions.

### Core Functionality

| Area             | Description                                                                  |
| ---------------- | ---------------------------------------------------------------------------- |
| Mount fetch      | Dispatches `listStories()` on mount via `useEffect`.                         |
| Loading skeleton | Renders a skeleton placeholder while the list is fetching.                   |
| List render      | Renders one `StoryListItem` per story returned from the slice.               |
| Open story       | Clicking a list item navigates to `/generator/:id`.                          |
| Delete story     | Clicking delete dispatches `deleteStory(id)` through the confirmation flow.  |

### Edge Cases

| Case             | Expected Behaviour                                                  |
| ---------------- | ------------------------------------------------------------------- |
| Empty list       | Renders an empty-state placeholder with a CTA to start a story.     |
| Fetch failure    | Renders an error state; `notificationMiddleware` shows a toast.     |
| Delete in flight | Delete button on the affected item is disabled until resolution.    |

## 🧪 dashboard slice

Holds the story list and the loading flags for `listStories` / `deleteStory` thunks.

### Core Functionality

| Area                    | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| `listStories.fulfilled` | Replaces the list with the fetched array.                    |
| `deleteStory.fulfilled` | Removes the deleted story id from the list.                  |
| Loading flags           | `pending` sets `loading: true`; terminal actions clear it.   |

### Edge Cases

| Case                   | Expected Behaviour                                                       |
| ---------------------- | ------------------------------------------------------------------------ |
| `listStories.rejected` | List unchanged; `error` populated with the typed error.                  |
| `deleteStory.rejected` | List unchanged (delete is pessimistic); `error` populated.               |

## 🧪 StoryListItem

Pure presentational. Takes a `Story` plus `onOpen` and `onDelete` callbacks.

### Core Functionality

| Area         | Description                                                              |
| ------------ | ------------------------------------------------------------------------ |
| Render       | Renders title, first paragraph, total sections, open and delete buttons. |
| Open click   | `onOpen(id)` is called with the story's id.                              |
| Delete click | `onDelete(id)` is called with the story's id.                            |

### Edge Cases

| Case                   | Expected Behaviour                                          |
| ---------------------- | ----------------------------------------------------------- |
| Story with empty graph | Renders "No content yet" instead of the first paragraph.    |
| Very long title        | Title truncates with ellipsis at the row width limit.       |

## 🧪 DeleteStoryButton

Confirmation-wrapped delete trigger.

### Core Functionality

| Area                     | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| Click opens confirmation | First click opens a Mantine confirmation popover.            |
| Confirm fires callback   | Confirming the popover calls the `onDelete` prop.            |
| Cancel does nothing      | Cancelling closes the popover without calling `onDelete`.    |

### Edge Cases

| Case               | Expected Behaviour                                       |
| ------------------ | -------------------------------------------------------- |
| `disabled` prop    | Button is non-interactive; the confirmation never opens. |
