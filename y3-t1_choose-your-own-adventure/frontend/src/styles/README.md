# Styles

Global CSS and Mantine theme overrides. Imported once at app start; not consumed by individual pages or components.

## 📋 Overview

Two files:

- **`global.css`** — global resets, typography defaults, and any project-wide CSS that bypasses Mantine.
- **`theme.ts`** — Mantine theme configuration (palette, font stack, component defaults). Passed to `<MantineProvider>` in `App.tsx`.

## 🏗️ Structure

    styles/
    ├── global.css
    └── theme.ts

## 📐 Design

- **Imported once at app start** — `App.tsx` imports `theme.ts` and passes it to `<MantineProvider>`; `main.tsx` imports `global.css` for its side effect (CSS load).
- **No CSS Modules, no inline `<style>` tags elsewhere** — Mantine handles per-component styling. Global CSS is reserved for resets and app-wide concerns; component-local styles use Mantine's `style` / `sx` props or `createStyles`.
- **Theme is the only Mantine configuration point** — colour palette, fonts, default radii, component overrides all live in `theme.ts`. Pages and components never override Mantine's theme directly.

## 🔗 Dependencies

Leaf module — imports nothing from any other `src/` directory.
