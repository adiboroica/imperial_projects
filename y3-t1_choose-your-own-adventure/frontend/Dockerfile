# Multi-stage build:
#   `deps`     — install npm deps from the lockfile (cached separately).
#   `dev`      — deps + source, runs `npm test`/`vitest`/`tsc`. Used by
#                `docker-compose.dev.yml`; never shipped to production.
#   `builder`  — deps + source + production bundle (`npm run build`).
#   `prod`     — nginx alpine serving the static bundle. Default target.

FROM node:18-alpine AS deps

WORKDIR /app

COPY package*.json ./
RUN npm ci


FROM deps AS dev

COPY . .

EXPOSE 5173

# Default for `docker compose run --rm frontend`. Override with another
# command (e.g. `npm test`) via the compose run invocation.
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]


FROM deps AS builder

COPY . .
RUN npm run build


FROM nginx:alpine AS prod

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
