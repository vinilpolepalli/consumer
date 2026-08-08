# Last Visits — launch checklist: repo merged → first reel posted

Ordered. Steps marked **[HUMAN #n]** need a key, account, or action only a human can
provide — the number is the row in [docs/NEEDS-FROM-HUMAN.md](../../../docs/NEEDS-FROM-HUMAN.md).
Everything unmarked is autonomous or 5-minute mechanical work.

## Phase 1 — from merge to live URL

1. **[HUMAN — review gate]** Merge the draft PR. Merging is the factory's ship
   signal; nothing below starts before it.
2. **[HUMAN #1]** Create Vercel / Netlify / Cloudflare Pages account (free tier),
   generate a deploy token, add it as repo Actions secret `DEPLOY_TOKEN`, tell the
   orchestrator which provider. Unlocks the deploy Action. *Hard requirement:
   HTTPS, with `sw.js` served from the app root (AUDIT.md).*
3. **[HUMAN #2]** Buy the domain (~$10/yr), point DNS at the host. Target URL:
   `lastvisits.<domain>` (or `visits.<domain>`). A raw `*.vercel.app` URL is
   acceptable for reel 1 if the domain stalls — do not let this step block filming.
4. Deploy fires on merge. Confirm the live URL serves `index.html`, the manifest,
   and registers the service worker (cache `lv-v1.2.0`).
5. Recommended pre-traffic fix (AUDIT PWA-2): ship the `navigator.storage.persist()`
   patch so browser-tab users don't lose streaks and premium after 7 idle days.
   Small, autonomous, worth doing before real users exist. (PWA-1's
   `user-scalable=no` removal can ride along.)

## Phase 2 — verify on a real phone (15 min, needs a human hand but no accounts)

6. On an iPhone in Safari: run the full flow cold — input → reveal → explainer →
   share card → paywall sheet ("Free during early access", no charge language).
7. Add to Home Screen; relaunch standalone; enable Airplane Mode; confirm the app
   fully works offline, including the reveal and card rendering.
8. Confirm Share actually hands the card to the iOS share sheet, and the saved
   image looks right in Photos (both 4:5 and 9:16).
9. Screen-record one throwaway reveal to check it reads at reel size: number
   legible, dots crisp, no browser chrome during the reveal.

## Phase 3 — accounts and staging for content

10. **[HUMAN #4]** Create the studio TikTok + Instagram accounts. Bio line:
    "You can change this number." + the live URL. Same handle both platforms if
    possible.
11. Put the live URL in link-in-bio on both. No link shorteners — the domain is the
    credibility.
12. **[HUMAN #3 — optional, not blocking]** Stripe Payment Links per plan +
    `STRIPE_PUBLISHABLE_KEY` flip `PAYMENTS.enabled` to real checkout. Launch does
    not wait for this; "Free during early access" is honest and converts installs.
13. **[HUMAN #5 — optional]** Plausible/PostHog key as `ANALYTICS_KEY` if
    conversion data is wanted from day one. Note: adding analytics changes the
    "nothing leaves your phone" copy in-app and in the listing — do both together
    or neither (AUDIT.md conditional obligations).

## Phase 4 — film and post (the launch)

14. **[HUMAN — ~45 min]** Film Reel 1 ("14") exactly per
    [reels.md](reels.md): shared prep block, then the five beats. Keep the silence.
15. **[HUMAN — ~10 min]** Post to TikTok and IG Reels natively (no cross-post
    watermarks). Caption from the script. Pin a comment with the link and one
    line: "It says 'about' on purpose — estimate, rounded up in her favor."
16. **[HUMAN — first 2 hours]** Reply to every "I got N" comment. The comment
    section is the second distribution surface; the replies are free reach.
17. Post Reel 3 (founder build-in-public) 2–3 days later; Reel 2 (tag-a-friend)
    once comments prove the compare instinct. Log view counts in docs/STATE.md —
    the kill criteria in docs/SHIP-CHECKLIST.md need real numbers.

## Not in this checklist (later, only with traction)

- App Store wrap: gated on **[HUMAN #6]** (Apple Developer account) and on fixing
  AUDIT.md AS-1 through AS-4 (StoreKit replaces the web paywall, native features
  land, PWA-install UI gated off, `dist/` webDir). Path lives in
  docs/SHIP-CHECKLIST.md stage 5; listing copy is ready in
  [listing.md](listing.md).
- Privacy policy + support URLs: required at App Store Connect time, not for the
  PWA launch (the in-app privacy note ships already).
