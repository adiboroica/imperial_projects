# Architecture Tests

`dependency-cruiser` contracts that enforce the layering rules defined in [`../../src/README.md`](../../src/README.md). Any change that violates the import hierarchy fails the test suite before it lands.

## 📋 Overview

Module-level contracts live in `.dependency-cruiser.cjs` and are enforced by `boundaries.test.ts`, which invokes `depcruise --validate` via subprocess. Statement-level contracts (rules about which named imports a folder may use) live in `purity.test.ts`, which scans file contents directly. Both wrappers run as part of `npm test` alongside every other test layer.

## ▶️ Running

    npm test -- tests/architecture

## 📐 Rules Enforced

Two kinds of rule, split by the tool that enforces them.

### Module-level (`boundaries.test.ts`)

Forbidden import edges between layers, validated by `dependency-cruiser`.

| Rule                                       | Description                                                                               |
| ------------------------------------------ | ----------------------------------------------------------------------------------------- |
| `types/` has no internal imports           | Must not import from `utils/`, `components/`, `api/`, `pages/`, or `store/`.              |
| `utils/` has no internal imports           | Must not import from any other `src/` directory.                                          |
| `components/` imports only types and utils | Must not import from `api/`, `pages/`, or `store/`.                                       |
| `api/` imports only types                  | Must not import from `utils/`, `components/`, `pages/`, or `store/`.                      |
| Pages are independent                      | No file under `pages/<X>/` imports from `pages/<Y>/` for any `X ≠ Y`.                     |
| Features are independent                   | No file under `features/<X>/` imports from `features/<Y>/` for any `X ≠ Y`.               |
| Pages may import features                  | Pages can read feature slices and dispatch feature thunks; features cannot import pages.   |
| Page-local components stay private         | No file outside `pages/<X>/` imports from `pages/<X>/components/`.                        |
| Components never touch state or network    | Files under `components/**` must not import from `store/` or `api/`.                      |
| Pages import only `store/hooks`            | Never `store/store` or `store/rootReducer` directly.                                      |
| No circular imports                        | No module pair where `A` imports `B` and `B` imports `A` — `dependency-cruiser` built-in. |

### Statement-level (`purity.test.ts`)

Forbidden named imports inside specific folders, validated by direct content scans.

| Rule                                 | Description                                                                                                               |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| `store/` defines no slices or thunks | No `createSlice` or `createAsyncThunk` import in any `store/**/*.ts` file. Slices and thunks live in `pages/<X>/slices/` or `features/<X>/slices/`. |
