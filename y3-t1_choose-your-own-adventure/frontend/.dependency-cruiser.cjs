/**
 * Architecture rules — enforces the layering documented in `src/README.md`.
 *
 * Run via `npx depcruise --validate .dependency-cruiser.cjs src` (also wired
 * up as `npm run test:arch`).
 */

module.exports = {
  forbidden: [
    {
      name: "types-no-internal-imports",
      severity: "error",
      comment: "types/ is a leaf — must not import from any other src/ directory.",
      from: { path: "^src/types" },
      to: {
        path: "^src/(api|components|features|pages|store|utils)",
      },
    },
    {
      name: "utils-no-internal-imports",
      severity: "error",
      comment: "utils/ may only import from types/ and stdlib.",
      from: { path: "^src/utils" },
      to: {
        path: "^src/(api|components|features|pages|store)",
      },
    },
    {
      name: "components-no-state-or-network",
      severity: "error",
      comment: "components/ stay presentational — no store, no network.",
      from: { path: "^src/components" },
      to: { path: "^src/(api|store|pages|features)" },
    },
    {
      name: "api-types-only",
      severity: "error",
      comment: "api/ imports types only.",
      from: { path: "^src/api" },
      to: { path: "^src/(components|pages|store|features|utils)" },
    },
    {
      name: "features-no-pages-store-other-features",
      severity: "error",
      comment: "Features cannot import from pages, store, or another feature.",
      from: { path: "^src/features/([^/]+)" },
      to: {
        path: ["^src/pages", "^src/store"],
        pathNot: ["^src/features/$1"],
      },
    },
    {
      name: "pages-no-cross-page-imports",
      severity: "error",
      comment: "Pages cannot import from another page.",
      from: { path: "^src/pages/([^/]+)" },
      to: { path: "^src/pages/(?!$1)([^/]+)" },
    },
    {
      name: "store-only-hooks-from-pages",
      severity: "error",
      comment: "Pages and components import store/hooks only — never store directly or rootReducer.",
      from: {
        path: "^src/(pages|components|features)",
        pathNot: ["^src/(pages|features)/.*/slices/"],
      },
      to: {
        path: ["^src/store/store", "^src/store/rootReducer"],
      },
    },
    {
      name: "no-circular",
      severity: "error",
      comment: "Forbid circular dependencies.",
      from: {},
      to: { circular: true },
    },
  ],
  options: {
    tsConfig: { fileName: "tsconfig.json" },
    doNotFollow: { path: "node_modules" },
    includeOnly: "^src",
    enhancedResolveOptions: {
      exportsFields: ["exports"],
      conditionNames: ["import", "require", "node", "default"],
    },
  },
};
