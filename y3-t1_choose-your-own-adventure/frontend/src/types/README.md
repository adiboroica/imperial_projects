# Types

Cross-cutting type definitions shared between layers. Zero runtime code — `.ts` files that compile to nothing but affect every other layer's type checking.

## 📋 Overview

Five files, organised per domain to mirror the backend's `models/` layout. Every shape that crosses a layer boundary (api → store, store → page, page → component) is defined here once.

## 🏗️ Structure

    types/
    ├── graph.ts
    ├── story.ts
    ├── user.ts
    ├── auth.ts
    └── api_key.ts

## 📐 Design

- **Per-domain files** — one file per domain, mirroring `backend/src/models/` subfolders. A reader looking up "what does a story look like?" opens `types/story.ts` and sees the domain shape, the list shape, and the full response shape together.
- **camelCase wire format** — every field name matches exactly what crosses the network. No aliasing, no adapter layer between the backend's Pydantic output and these definitions.
- **Type-only exports** — files export `type` and `interface` declarations, never runtime values. Import sites should prefer `import type { Story } from '...'` so the TypeScript compiler erases them at build time.
- **Requests and responses live with their domain** — `LoginRequest` sits in `auth.ts` (alongside anything else auth-related), not in `api/auth.ts`. The API layer imports its call signatures from here.
- **Nullable vs optional** — field types distinguish "present but null" (`apiKey: string | null` for a user who hasn't stored a key) from "absent in the payload" (`field?: T`). Match whatever Pydantic emits on the backend.
- **Cross-domain references** — `Story` carries a `Graph`, so `types/story.ts` imports `Graph` from `types/graph.ts`. Intra-folder imports are fine; neither file reaches outside `types/`.

## 🔗 Dependencies

Imports from the TypeScript standard library only. Never imports from any other `src/` directory or from third-party runtime packages.
