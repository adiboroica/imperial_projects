// Screenshot helper for docs/screenshots/*.png.
//
// Drives a visible Chromium window at 390×844 (matching existing shots) and
// writes PNGs directly to disk via `page.screenshot({ path })`. The script
// waits for a trigger file between shots so an outer process (or another
// terminal) can advance it while the user manipulates the browser:
//
//   touch scripts/.snap-next
//
// The script deletes the trigger after each snap. Prereq: Flutter app up at
// http://localhost/app.html (docker compose up -d).

import puppeteer from 'puppeteer';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.resolve(__dirname, '..', 'docs', 'screenshots');
const APP_URL = 'http://localhost/app.html';
const TRIGGER = path.resolve(__dirname, '.snap-next');

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function waitForTrigger(cue) {
  console.log(`\n[waiting] ${cue}`);
  console.log(`          → touch ${path.relative(process.cwd(), TRIGGER)} to advance`);
  while (!fs.existsSync(TRIGGER)) {
    await sleep(250);
  }
  fs.unlinkSync(TRIGGER);
}

async function waitForFlutter(page) {
  await page.waitForSelector('flt-glass-pane', { timeout: 30000 });
  await sleep(500); // let first frame paint
}

async function snap(page, file) {
  const full = path.join(OUT, file);
  await page.screenshot({ path: full, type: 'png' });
  console.log(`  ✓ saved ${file}`);
}

async function main() {
  // Clean any stale trigger from a previous run.
  if (fs.existsSync(TRIGGER)) fs.unlinkSync(TRIGGER);

  const browser = await puppeteer.launch({
    headless: false,
    defaultViewport: { width: 390, height: 844 },
    args: ['--window-size=430,920'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 390, height: 844 });

  await page.goto(APP_URL, { waitUntil: 'domcontentloaded' });
  await page.evaluate(() => {
    localStorage.setItem('flutter.SERVICE_BANNER_DISMISSED_v1', 'true');
  });
  await page.reload({ waitUntil: 'domcontentloaded' });
  await waitForFlutter(page);

  const steps = [
    { file: '01-landing.png', cue: 'Landing page (role selector) should be visible.' },
    { file: '02-login.png', cue: 'Click "Enter as organiser" in the browser.' },
    { file: '03-organiser-calendar.png', cue: 'Log in organiser_demo / demo1234; wait for Calendar tab.' },
    { file: '04-organiser-events.png', cue: 'Toggle Calendar → List view.' },
    { file: '05-coach-feed.png', cue: 'Logout → Enter as coach → coach_demo / demo1234 → Feed.' },
  ];

  for (const step of steps) {
    await waitForTrigger(step.cue);
    await snap(page, step.file);
  }

  console.log('\nDone. All 5 screenshots in docs/screenshots/.');
  await browser.close();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
