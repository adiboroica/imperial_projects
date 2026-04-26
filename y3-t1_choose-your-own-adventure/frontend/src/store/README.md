# Store

Redux store wiring, typed hooks, and cross-cutting middleware. Pure composition — no slice is defined here, no business logic lives here.

## 📋 Overview

Three top-level files plus a middleware folder:

- **`store.ts`** — calls `configureStore` over the combined reducer; exports `store`, `RootState`, `AppDispatch`.
- **`rootReducer.ts`** — `combineReducers` over every page and feature slice reducer. The single place that knows about every slice in the app.
- **`hooks.ts`** — typed `useAppSelector` and `useAppDispatch`. Pages and components use these instead of the raw `react-redux` hooks so the state shape is checked at compile time.
- **`middleware/`** — cross-cutting Redux concerns that don't fit cleanly inside any slice's reducer.

## 🏗️ Structure

    store/
    ├── store.ts
    ├── rootReducer.ts
    ├── hooks.ts
    └── middleware/                ─ cross-cutting Redux concerns (WS bridge, error toasts)
        ├── ws.ts                  ─ exports `wsMiddleware`
        └── notification.ts        ─ exports `notificationMiddleware`

## 📐 Design

- **Composition, not logic** — `store/` exists to wire pieces together: combine reducers, register middleware, expose typed hooks. No slice is defined here, no `createSlice`, no `createAsyncThunk`, no `extraReducers`.
- **`rootReducer.ts` is the only place that imports slice reducers** — `pages/<X>/slices/*` and `features/<X>/slices/*` reducers get combined here. This is the one expected import-from-pages-or-features direction in the whole `store/` tree; `App.tsx` does the same for page components when routing.
- **Pages import only from `hooks.ts`** — typed `useAppSelector` and `useAppDispatch`. Pages never import `store` (the store object) or `rootReducer` directly — those imports would couple a page to the composition.
- **Middleware is for cross-cutting concerns only** — anything that can live in a slice's `extraReducers` should. Middleware is reserved for global behaviour: toasts on errors, bridging external sources (server-pushed WebSocket frames) into Redux dispatches.
- **`wsMiddleware` handles only server-pushed frames** — request/response WS calls go through the Promise-based client in `api/clients/ws.ts` and are awaited inside thunks. Middleware only fires for unsolicited frames such as `progressUpdate` during `generateMany`, where the server emits updates the client did not directly request.
- **`notificationMiddleware` listens for `*/rejected`** — every thunk that fails dispatches a `*/rejected` action carrying the error payload; the middleware translates that into a Mantine notification. Slices stay focused on state; they do not know the user-facing toast machinery exists.

## 🔗 Dependencies

Imports from `pages/<X>/slices/*` and `features/<X>/slices/*` (only inside `rootReducer.ts`) and the typed WS client from `api/clients/ws.ts` (only inside `middleware/ws.ts`). Never imports from `components/`, page components, or `pages/<X>/components/`.
