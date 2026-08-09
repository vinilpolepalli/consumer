# The Tab — launch checklist: repo merged → first reel posted

Ordered. Steps marked **[HUMAN #n]** need a key, account, or action only a human can
provide — the number is the row in [docs/NEEDS-FROM-HUMAN.md](../../../docs/NEEDS-FROM-HUMAN.md).
Everything unmarked is autonomous or 5-minute mechanical work.

## Phase 1 — from merge to live URL

1. **[HUMAN — review gate]** Merge the draft PR. Merging is the factory's ship
   signal; nothing below starts before it.
2. **[HUMAN #1]** Hosting token (Vercel / Netlify / Cloudflare Pages, free tier) as
   repo Actions secret `DEPLOY_TOKEN`; tell the orchestrator which provider. *Hard
   requirement: HTTPS with `sw.js` served from the app root.* If last-visits already
   set this up, this step is already done — same token deploys both apps.
3. **[HUMAN #2]** Domain: point `thetab.<domain>` (or `tab.<domain>`) at the host.
   A raw `*.vercel.app` URL is acceptable for Reel 1 — do not let DNS block filming.
4. Deploy fires on merge. Confirm the live URL serves `index.html`, the manifest,
   and registers the service worker (cache `thetab-v1.1.0`).
5. Pre-traffic fixes from AUDIT.md, all small and autonomous — ship before users
   exist: **P1** drop `user-scalable=no` (a11y), **P2** chain the offline navigate
   fallback so cache eviction can't produce a blank error page, **P3** sync
   `theme-color` with the light appearance.

## Phase 2 — verify on a real phone (15 min, human hands, no accounts)

6. iPhone Safari, cold: full flow — input → RUN MY TAB → roll → flip → unroll →
   share sheet → paywall sheet (must read "Free during early access", no charge
   language anywhere).
7. Known iOS behavior to confirm, not fix: the flip's vibration will NOT fire
   (`navigator.vibrate` is unsupported on iOS) — verify the visual thud reads
   clearly on its own, because that's what gets filmed.
8. Add to Home Screen; relaunch standalone; Airplane Mode; confirm the whole app
   works offline including the reveal and receipt export.
9. Share both export sizes (4:5 and 1080×1920 9:16) to Photos; check the invested
   number and BY AGE 65 are legible at thumbnail size; confirm the 7% disclaimer is
   on every card.
10. Run a Tab Duel end to end — Reel 3 depends on the VS receipt exporting clean.
11. Screen-record one throwaway reveal and watch it at reel size: odometer smooth,
    digits crisp, no browser chrome over the receipt.

## Phase 3 — accounts and staging for content

12. **[HUMAN #4]** Studio TikTok + Instagram accounts (skip if created for
    last-visits — one studio account carries all apps). Bio line: "RUN YOURS." +
    the live URL, link-in-bio on both, no shorteners.
13. **[HUMAN #3 — optional, not blocking]** Stripe Payment Link +
    `STRIPE_PUBLISHABLE_KEY` to make the $14.99 unlock real. Launch does not wait:
    "Free during early access" is honest and converts installs into fans.
14. **[HUMAN #5 — optional]** Analytics key as `ANALYTICS_KEY`. Warning: adding it
    breaks "Nothing you type leaves your phone" in-app, in the listing, and in the
    pinned-comment defense — change all of them together or add nothing.

## Phase 4 — film and post (the launch)

15. **[HUMAN — ~45 min]** Film Reel 1 ("$848,137") exactly per [reels.md](reels.md):
    shared prep block, then the six beats. Do not cut during the odometer roll.
16. **[HUMAN — ~10 min]** Post natively to TikTok and IG Reels (no cross-post
    watermarks). Caption from the script. Pin a comment: the link + "the 7% is
    labeled on the receipt — long-run average, an estimate, not advice."
17. **[HUMAN — first 2 hours]** Every "run mine: X, $Y" comment gets a reply. Run
    the tab, screenshot the receipt, reply with the roast line. Each reply is a
    micro-reel and the queue for Reel 2's "I'll read you your roast" promise.
18. Post Reel 2 (brutal honesty) 2–3 days later, feeding on the commented habits;
    Reel 3 (Tab Duel) once comments show pairs tagging each other. Log view counts
    in docs/STATE.md — the kill criteria in docs/SHIP-CHECKLIST.md need real numbers.

## Not in this checklist (later, only with traction)

- **App Store wrap:** gated on **[HUMAN #6]** (Apple Developer account) and on
  AUDIT.md Part 2 — above all **A1** (the stubbed $14.99 paywall + dead Restore is a
  likely 2.1/2.2 rejection: wire StoreKit or ship genuinely free before wrapping),
  plus A2 (add native haptics/share/widget so it isn't a bare webview), A8 (`webDir`
  → clean `dist/`, never change `iosScheme`). Listing copy is ready in
  [listing.md](listing.md) with its own submission-time notes.
- **Privacy policy + support URLs:** required at App Store Connect time, not for
  the PWA launch (the in-app privacy note ships already).
