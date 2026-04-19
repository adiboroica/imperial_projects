# Integration Tests

## 📋 Overview

Full page tests that render screens with real `BlocProvider` wiring and verify user flows end-to-end. Unlike unit tests (which test components in isolation with mocks), integration tests exercise the interaction between pages, cubits, widgets, and navigation.

## ▶️ Running

    flutter test test/integration

## 📂 Test Files

| File                    | Flows Tested              |
| ----------------------- | ------------------------- |
| landing_page_test.dart  | Role selection, navigation |
| login_page_test.dart    | Login, error, sign-up link |

## 🧪 Landing Page (`landing_page_test.dart`)

| Flow                  | Description                                                    |
| --------------------- | -------------------------------------------------------------- |
| Role selection        | Organiser and coach buttons displayed                          |
| Navigation            | Tapping organiser button navigates to organiser login page     |

## 🧪 Login Page (`login_page_test.dart`)

| Flow                  | Description                                                    |
| --------------------- | -------------------------------------------------------------- |
| Form fields           | Username and password fields displayed                         |
| Successful login      | Valid credentials navigate to home page                        |
| Failed login          | Invalid credentials show error snackbar                        |
| Sign-up link          | Tapping sign-up navigates to sign-up page                      |
