/// <reference types="vitest" />
import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import viteTsconfigPaths from "vite-tsconfig-paths";

export default defineConfig(({ mode }) => {
  // Resolve the backend host once. Inside docker-compose.dev.yml the dev
  // container reaches the backend over the docker network as `backend:8000`;
  // host-native dev (`npm run dev` from `frontend/`) talks to the backend on
  // `localhost:8000`. Override with `VITE_BACKEND_URL` to point elsewhere.
  const env = loadEnv(mode, process.cwd(), "");
  const inDocker = process.env.HOSTNAME && process.env.HOSTNAME !== "localhost";
  const backend =
    env.VITE_BACKEND_URL ?? (inDocker ? "http://backend:8000" : "http://localhost:8000");
  const wsBackend = backend.replace(/^http/, "ws");

  return {
    plugins: [react(), viteTsconfigPaths()],
    server: {
      host: "0.0.0.0",
      port: 3000,
      // Docker Desktop on Windows does not propagate inotify events from
      // host bind mounts into the container, so chokidar's default watcher
      // misses host-side edits. Polling is the standard workaround. The
      // overhead is negligible for a project this size and only kicks in
      // when running under docker-compose.dev.yml.
      watch: { usePolling: true, interval: 300 },
      proxy: {
        "/api": {
          target: backend,
          changeOrigin: true,
          // Backend mounts routers without an `/api` prefix, so strip it.
          rewrite: (path) => path.replace(/^\/api/, ""),
        },
        "/ws": {
          target: wsBackend,
          ws: true,
        },
      },
    },
    test: {
      globals: true,
      environment: "jsdom",
      setupFiles: ["./tests/setup.ts"],
      include: [
        "src/**/__tests__/**/*.{test,spec}.{ts,tsx}",
        "src/**/*.{test,spec}.{ts,tsx}",
        "tests/**/*.{test,spec}.{ts,tsx}",
      ],
    },
  };
});
