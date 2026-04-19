# Widgets

Shared, reusable UI components used across coach and organiser pages.

## 📋 Overview

These widgets are not page-specific — they are shared building blocks extracted from pages to avoid duplication. Page-specific widgets live with their pages in `pages/`.

## 🧩 Widget Categories

| Category       | Description                                                                 |
| -------------- | --------------------------------------------------------------------------- |
| Event display  | Cards, detail tiles, and status-aware organiser event cards                 |
| Event creation | Form with date/time pickers, sport/role dropdowns, and validation           |
| Calendar       | `table_calendar` wrapper with event markers and day selection               |
| Feedback       | Confirmation dialog, error display with retry, loading spinner              |
| Navigation     | Exit guard that confirms before navigating away from unsaved changes        |
| User display   | Profile tiles with role-specific formatting                                 |
| Theming        | Centralized color palette, spacing constants, and `ThemeData`               |

## 🔗 Dependencies

Imports from `models/` and `constants.dart`.
