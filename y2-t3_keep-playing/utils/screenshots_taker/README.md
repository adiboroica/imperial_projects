# screenshots_taker

A tiny Node helper to (re)generate the PNGs in [`docs/screenshots/`](../../docs/screenshots/) against
the currently running app. Drives a visible Chromium window at 390×844 (Pixel-
phone size, matching the existing shots) and saves each screenshot directly to
disk via Puppeteer's `page.screenshot({ path })`.

## Why this exists

Grabbing the screenshots by hand is fiddly: get the right viewport, dismiss the
Flutter service-worker banner, snap at the right moment, save with the exact
name and dimensions. This script automates the non-creative parts (viewport,
banner, save path) and leaves the interactive parts (clicks, logins, view
toggles) to you, pausing between shots so the browser state matches what each
screenshot is supposed to show.

## Prereqs

- Node 18+ (anything ESM-capable)
- The full stack running: `docker compose up -d` from the repo root
- The Flutter app reachable at `http://localhost/app.html`

## First-run setup

```bash
cd utils/screenshots_taker
npm install
```

Downloads Puppeteer and, as a side effect, a matching Chromium build (~150 MB
the first time, cached to `~/.cache/puppeteer` after). Subsequent runs skip
this step.

## Usage

```bash
node take_screenshots.mjs
```

A Chromium window opens at 390×844, loads `http://localhost/app.html`,
dismisses the Flutter banner, and waits. The script advances one shot at a
time, prompting between each. To advance, create the trigger file from
**another terminal** (or via your editor):

```bash
touch utils/screenshots_taker/.snap-next
```

The script deletes the trigger after each snap and moves on to the next cue.

### The five shots

| # | File                              | Browser state before triggering |
|---|-----------------------------------|----------------------------------|
| 1 | `01-landing.png`                  | Landing page (role selector) — already there after launch |
| 2 | `02-login.png`                    | Clicked "Enter as organiser" |
| 3 | `03-organiser-calendar.png`       | Logged in as `organiser_demo` / `demo1234`, Calendar tab rendered |
| 4 | `04-organiser-events.png`         | Toggled Calendar → List view |
| 5 | `05-coach-feed.png`               | Logged out → "Enter as coach" → `coach_demo` / `demo1234` → Feed |

PNGs are written to `../../docs/screenshots/<filename>` (overwriting what's there).
The browser closes cleanly after the fifth shot.

## Files

- `take_screenshots.mjs` — the runner
- `package.json` / `package-lock.json` — Puppeteer dep pin
- `node_modules/` — installed deps (gitignored)
- `.snap-next` — trigger file you create, the script deletes (gitignored)
