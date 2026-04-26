# Welcome Page Tests

Test contract for `WelcomePage.tsx`.

## 📋 Overview

The Welcome page is a static landing surface with two routing CTAs. Tests verify the hero renders and that both CTAs point at the correct routes.

## ▶️ Running

    npm test -- src/pages/welcome

See [`../../../tests/README.md`](../../../tests/README.md) for the full test-runner shape.

## 🧪 Core Functionality

| Area              | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| Hero title        | The H1 reads "Choose Your Own Adventure".                                  |
| Auth CTAs         | The `Log in` button links to `/login`; the `Sign up` button links to `/signup`. |

## 🧪 Edge Cases

No edge cases — the page has no state, no async behaviour, and no inputs to validate.
