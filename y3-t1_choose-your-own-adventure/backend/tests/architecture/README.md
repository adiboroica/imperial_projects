# Architecture Tests

`import-linter` contracts that enforce the layering rules defined in [`../../src/README.md`](../../src/README.md). Any change that violates the import hierarchy fails the test suite before it lands.

## 📋 Overview

Contracts live in `.importlinter` as separate `forbidden` or `independence` clauses, so a failure points at the exact module and import that violated the boundary. A pytest wrapper (`dependency_test.py`) invokes `lint-imports` via subprocess so architecture checks run as part of the regular `pytest` run.

## ▶️ Running

    pytest tests/architecture

## 📐 Rules Enforced

| Rule                                                    | Description                                                                |
| ------------------------------------------------------- | -------------------------------------------------------------------------- |
| `models/` has no internal imports                       | Must not import from `routers/`, `services/`, `repositories/`, or `ai/`.   |
| `ai/` imports only from `models/` and `config.py`       | Must not import from `routers/`, `services/`, or `repositories/`.          |
| `repositories/` imports only from `models/` and `db.py` | Must not import from `routers/`, `services/`, or `ai/`.                    |
| `services/` never imports routers or `motor`            | Persistence flows through `repositories/` only; never `db.py` or `motor`.  |
| `routers/` stays thin                                   | Must not import from `repositories/`, `ai/`, `db.py`, or `motor` directly. |
| Services are independent                                | No service imports another; cross-service flows live in routers.           |
| No circular imports                                     | No module pair where `A` imports `B` and `B` imports `A`.                  |
