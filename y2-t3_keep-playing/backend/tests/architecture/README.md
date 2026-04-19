# Architecture Tests

## 📋 Overview

Verifies that modules respect the dependency hierarchy by checking import rules. Uses `import-linter` to enforce module boundaries defined in `app/README.md`.

## ▶️ Running

    pytest tests/architecture

## 📐 Rules Enforced

| Rule                                           | Description                                                      |
| ---------------------------------------------- | ---------------------------------------------------------------- |
| `models/` has no internal imports              | Must not import from serializers, services, views, or email      |
| `serializers/` only imports `models/`          | Must not import from services, views, or email                   |
| `services/` only imports `models/` and `email` | Must not import from serializers or views                        |
| `views/` never imports `models/` for writes    | Write operations go through services                             |
| `email.py` only imports `models/`              | Must not import from serializers, services, or views             |
| No circular imports                            | No module pair where A imports B and B imports A                 |

## 🏗️ Design

Uses `import-linter` with contracts defined in `.importlinter`. Each rule is a separate contract, so failures pinpoint exactly which module and import violated the boundary.
