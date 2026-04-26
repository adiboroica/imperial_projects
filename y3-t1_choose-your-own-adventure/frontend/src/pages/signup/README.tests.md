# Signup Tests

Test contract for the signup page.

## 📋 Overview

`SignupPage` is an email and password form that dispatches the `signup` thunk on submit. One unit. Test file co-located: `SignupPage.test.tsx`.

## ▶️ Running

    npm test -- src/pages/signup

See [`../../../tests/README.md`](../../../tests/README.md) for the full test runner commands.

## 🧪 Core Functionality

| Area              | Description                                                           |
| ----------------- | --------------------------------------------------------------------- |
| Render form       | Email input, password input, password-min-length hint, submit button. |
| Submit dispatches | Submitting calls `dispatch(signup({email, password}))`.               |
| Success redirect  | On `signup.fulfilled`, navigates to `/dashboard`.                     |

## 🧪 Edge Cases

| Case                          | Expected Behaviour                                          |
| ----------------------------- | ----------------------------------------------------------- |
| Password shorter than minimum | Submit is blocked; inline error shows.                      |
| `signup.rejected` (409)       | Toast surfaces "Email already registered"; form stays open. |
| Already authenticated         | Route guard redirects to `/dashboard` before render.        |
