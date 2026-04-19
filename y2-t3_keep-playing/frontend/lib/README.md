# Frontend Source

Dart source code for the Keep Playing Flutter web app.

## 📋 Overview

The source is organized into six directories, each with a single responsibility. Dependencies flow strictly upward — lower layers never import from higher layers.

## 🏗️ Dependency Hierarchy

    models/           ← no internal dependencies (pure data)
    repositories/     ← abstract interfaces, imports models/
    api/              ← implements repositories, imports models/
    state/            ← imports repositories/ + models/ (never api/)
    widgets/          ← imports models/
    pages/            ← imports state/, widgets/, models/

`api/` implements the repository interfaces but is never imported directly by `state/` or `pages/`. The wiring happens at the app root (`main.dart` / `app.dart`) via dependency injection.

## 📂 Directories

| Directory      | Purpose                                                                |
| -------------- | ---------------------------------------------------------------------- |
| models/        | Immutable data classes with JSON serialization (Event, User, etc.)     |
| repositories/  | Abstract interfaces defining data operations                           |
| api/           | HTTP client implementing repositories — talks to the backend REST API |
| state/         | Global state management (AuthCubit, DataState)                         |
| widgets/       | Shared reusable UI components used across pages                        |
| pages/         | Screen-level widgets organized by user role (coach, organiser)         |

## 📄 Root Files

| File           | Purpose                                                     |
| -------------- | ----------------------------------------------------------- |
| main.dart      | App entry point — initializes dependencies, runs the app    |
| app.dart       | Root widget — MaterialApp, routing, BlocProvider wiring      |
| constants.dart | Theme and configuration constants                            |
| utils.dart     | Shared utility functions (e.g., time formatting)             |
