# Tech Stack

A short primer on every library, framework, and piece of infrastructure in the stack. Each entry is an overview of what the technology does at a high level; no CYOA-specific wiring here. The [🧩 How They Fit Together](#-how-they-fit-together) section at the end walks through two concrete flows through the full stack.

## 🎨 Frontend

**[React](https://react.dev/)** — a library for building UIs out of components: functions that return what should appear on screen.  
When data changes, React re-runs the relevant components and patches only the DOM that differs.

**[Redux Toolkit (RTK)](https://redux-toolkit.js.org/)** — state management for data that many components care about.  
The central abstraction is a **store** that lives outside React. Components **read** from it with selectors and **change** it by dispatching actions.

Three terms it helps to internalise:

- **Reducer** — a pure function `(state, action) => newState`. Reducers never mutate the input; they return a new state. RTK uses Immer under the hood, so you can *write* `state.foo = 1` inside a reducer body and it becomes an immutable update for free.
- **Slice** — a bundle of `initialState` plus a set of named reducers for one domain. RTK auto-generates an action creator for each reducer, so calling that creator produces the action object that triggers the matching reducer.
- **Thunk** (`createAsyncThunk`) — an action creator that can do async work. Given an `async` function, RTK auto-dispatches three lifecycle actions around it: `pending` (fired immediately), `fulfilled` (fired when the promise resolves), `rejected` (fired on error). The slice's `extraReducers` react to each stage — typically "show a spinner on pending, store the result on fulfilled, store the error on rejected."

**[ReactFlow](https://reactflow.dev/)** — an interactive node-and-edge diagram renderer.  
Feed it a list of nodes and a list of edges; it handles drawing, dragging, zooming, and snap-to-grid layout.

**[Mantine UI](https://mantine.dev/)** — a React component library.  
Pre-styled buttons, inputs, modals, tables, and dozens more. Consistent look without hand-rolled CSS.

**[Vite](https://vitejs.dev/)** — the build tool and dev server.  
Uses native browser ES modules in dev mode for near-instant hot reload, and Rollup for an optimised production bundle.

## ⚙️ Backend

**[FastAPI](https://fastapi.tiangolo.com/)** — a modern async Python web framework.  
Routes are `async def` functions decorated with `@router.post(...)` or `@router.get(...)`.  
Incoming requests are validated against Pydantic models at the boundary, and an OpenAPI schema is generated automatically from the route signatures.

**[Pydantic](https://docs.pydantic.dev/)** — data validation and serialisation for Python.  
Data shapes are defined as classes with typed fields; Pydantic rejects bad input (malformed email, wrong type, missing field) at construction and produces clean JSON on output.

**[Motor](https://motor.readthedocs.io/)** — the `asyncio`-compatible Python driver for MongoDB.  
A thin async wrapper around `pymongo` that lets you `await` every database operation.

**[sentence-transformers](https://www.sbert.net/)** — a library that turns text into embedding vectors reflecting meaning.  
Two sentences that mean similar things produce vectors close together in high-dimensional space; cosine similarity between vectors measures semantic closeness.

**[bcrypt](https://github.com/pyca/bcrypt/) + [cryptography](https://cryptography.io/)** — two crypto libraries with different jobs. Different problems, different tools.  
`bcrypt` hashes passwords (slow by design, salted, one-way).  
`cryptography` provides `Fernet` — symmetric authenticated encryption — for values you need to decrypt later.

## 🐳 Infrastructure

**[Docker Compose](https://docs.docker.com/compose/)** — a tool for defining and running multi-container applications.  
One YAML file declares every service, its build context, its environment, and how services reach each other on an internal network.

**[Nginx](https://nginx.org/)** — a high-performance reverse proxy and web server.  
Sits in front of application servers, serving static files directly and forwarding dynamic requests upstream.

**[MongoDB](https://www.mongodb.com/docs/)** — a document database.  
Stores data as BSON (binary JSON) documents in collections, with secondary and compound indexes for lookups, and TTL indexes for automatic document expiry.

## 🧩 How They Fit Together

**A REST request** (e.g., `GET /stories/{id}`):

1. Browser sends the request to Nginx on port `3000`.
2. Nginx proxies `/api/*` to FastAPI on port `8000`.
3. FastAPI matches the route; `Depends(get_current_user)` validates the session cookie by hitting `SessionRepository` (Motor → MongoDB).
4. The router calls `StoryService.get(id, user)`.
5. Service calls `StoryRepository.find_by_id(id, user_email)` — Motor queries MongoDB, translates the BSON document into a Pydantic `Story`.
6. Router serialises `Story` as JSON and returns 200.

**A WebSocket message** (e.g., `generateActions`):

1. Frontend's `pages/generator/slices/graph.ts` dispatches a thunk that sends a JSON envelope via `api/clients/ws.ts`.
2. Backend's `ws.py` validates the envelope with Pydantic and dispatches to `GenerationService`.
3. `GenerationService` calls `TextGenerator` (builds the prompt via `prompts.py`, hits OpenAI through `LLMClient`) and `Analyser` (duplicate check on sentence embeddings).
4. Service returns the updated graph; router sends it back as a `requestComplete` frame with the original `requestId`.
5. Frontend's `WSClient` correlates the response by `requestId` and resolves the awaiting Promise inside the thunk; the thunk's `fulfilled` reducer updates the graph slice; React components subscribed to graph state re-render. (For `generateMany`, the WS middleware additionally listens for server-pushed `progressUpdate` frames and dispatches a partial-update action between batches.)
