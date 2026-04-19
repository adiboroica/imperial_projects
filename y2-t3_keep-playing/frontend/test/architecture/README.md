# Architecture Tests

## 📋 Overview

Verifies that modules respect the dependency hierarchy by checking import statements. If a module imports from a layer it shouldn't, the test fails.

## ▶️ Running

    flutter analyze                              # locally
    docker compose run --rm frontend-analyze     # via Docker

## 📐 Rules Enforced

| Rule                                          | Description                                                   |
| --------------------------------------------- | ------------------------------------------------------------- |
| `models/` has no internal imports             | Must not import from api, repositories, state, pages, widgets |
| `repositories/` only imports `models/`        | Must not import from api, state, pages, widgets               |
| `api/` never imports upward                   | Must not import from state, pages, widgets                    |
| `state/` never imports `api/` or `pages/`     | Imports from repositories and models only                     |
| `widgets/` never imports `state/` or `pages/` | Imports from models only                                      |
| No circular imports                           | No module pair where A imports B and B imports A              |

## 🏗️ Design

Uses the `import_guard` analyzer plugin. Each module directory contains an `import_guard.yaml` file listing denied import paths. Rules are enforced by `flutter analyze` — violations appear as analyzer warnings alongside regular lint rules. No separate test runner needed.
