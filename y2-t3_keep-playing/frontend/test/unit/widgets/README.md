# Widget Tests

## 📋 Overview

Widget tests for shared UI components — rendering, user interaction, and callback behavior. Uses `flutter_test` with `pumpWidget` for widget-level testing.

## ▶️ Running

    flutter test test/unit/widgets

## 📂 Test Files

| File             | Widgets Tested                                    |
| ---------------- | ------------------------------------------------- |
| widget_test.dart | ErrorDisplay, LoadingIndicator, ConfirmationDialog |

## 🧪 ErrorDisplay

| Area        | Description                                                       |
| ----------- | ----------------------------------------------------------------- |
| Rendering   | Shows error message text                                          |
| Retry       | Retry button visible when `onRetry` provided, hidden when null    |
| Interaction | Tapping retry triggers `onRetry` callback                         |

## 🧪 LoadingIndicator

| Area      | Description                                                                             |
| --------- | --------------------------------------------------------------------------------------- |
| Rendering | `LoadingIndicator` shows centered spinner<br/>`LoadingScreen` shows full-screen variant |

## 🧪 ConfirmationDialog

| Area      | Description                                                       |
| --------- | ----------------------------------------------------------------- |
| Rendering | Displays title and optional content<br/>Hides content when null   |
| Accept    | Tapping Yes button pops with true                                 |
| Dismiss   | Tapping No button pops with false                                 |
