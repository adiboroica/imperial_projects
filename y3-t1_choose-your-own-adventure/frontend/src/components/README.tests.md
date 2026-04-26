# Components Tests

Test contract for the layout chrome (the only populated subfolder of `components/` today).

## 📋 Overview

Three units, all in `layout/`, all covered by direct tests. Test files co-located alongside source. Components are presentational only — tests focus on render output and prop-driven callbacks; nothing here mocks the store. The `shared/` subfolder is empty today; once a widget graduates from a page-local `components/` folder its test contract belongs in this file.

## ▶️ Running

    npm test -- src/components

See [`../../tests/README.md`](../../tests/README.md) for the full test runner commands.

## 🧪 AppHeader (`layout/`)

Top navigation bar. Reads `loggedIn`, `email`, and a `onLogout` callback as props (wired by `App.tsx`, not by the component itself).

### Core Functionality

| Area                | Description                                                                |
| ------------------- | -------------------------------------------------------------------------- |
| Render logo + brand | Always renders the brand mark with a link to `/`.                          |
| Logged-out state    | Renders "Log in" and "Sign up" links.                                      |
| Logged-in state     | Renders the user's email and a logout button.                              |
| Logout click        | Fires the `onLogout` prop.                                                 |

### Edge Cases

| Case                  | Expected Behaviour                                            |
| --------------------- | ------------------------------------------------------------- |
| Long user email       | Truncates with ellipsis at the header width limit.            |

## 🧪 AppFooter (`layout/`)

Footer with project metadata.

### Core Functionality

| Area               | Description                                                          |
| ------------------ | -------------------------------------------------------------------- |
| Render copy        | Renders project credits and the GitHub link.                         |

### Edge Cases

No edge cases — the footer is fully static.

## 🧪 AppMenu (`layout/`)

Account dropdown — Mantine `Menu` triggered from a "Account" button in the header. Conditionally renders a "Log out" or "Log in" item based on the `loggedIn` prop.

### Core Functionality

| Area                          | Description                                                              |
| ----------------------------- | ------------------------------------------------------------------------ |
| Trigger render                | Always renders the "Account" trigger button.                             |
| Logged-out dropdown           | After click, the dropdown shows "Account settings" + "Log in".           |
| Logged-in dropdown            | After click, the dropdown shows "Account settings" + "Log out".          |
| Logout dispatch               | Clicking "Log out" fires the `onLogout` prop.                            |

### Edge Cases

| Case                | Expected Behaviour                                          |
| ------------------- | ----------------------------------------------------------- |
| Mantine transition  | The dropdown opens via `pop-top-right`; tests use `findByText` to wait for the items to mount in the portal. |
