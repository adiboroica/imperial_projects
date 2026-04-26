# Login Tests

Test contract for the login page.

## 📋 Overview

`LoginPage` is an email and password form that dispatches the `login` thunk on submit. One unit. Test file co-located: `LoginPage.test.tsx`.

## ▶️ Running

    npm test -- src/pages/login

See [`../../../tests/README.md`](../../../tests/README.md) for the full test runner commands.

## 🧪 Core Functionality

| Area              | Description                                            |
| ----------------- | ------------------------------------------------------ |
| Render form       | Email input, password input, submit button.            |
| Submit dispatches | Submitting calls `dispatch(login({email, password}))`. |
| Success redirect  | On `login.fulfilled`, navigates to `/dashboard`.       |

## 🧪 Edge Cases

| Case                   | Expected Behaviour                                     |
| ---------------------- | ------------------------------------------------------ |
| Invalid email format   | Submit is blocked; HTML5 validation message shows.     |
| Empty password         | Submit is blocked.                                     |
| `login.rejected` (401) | Toast surfaces "Invalid credentials"; form stays open. |
| Already authenticated  | Route guard redirects to `/dashboard` before render.   |
