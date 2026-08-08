# Ship checklist: repo → live PWA → App Store

The standard path every factory app walks. Stages 1–3 are fully autonomous today;
stage 4 needs items from [NEEDS-FROM-HUMAN.md](NEEDS-FROM-HUMAN.md); stage 5 needs
the Apple Developer account.

## 1. Built (autonomous)
- [ ] `apps/<slug>/` contains `index.html`, `manifest.webmanifest`, `sw.js`, icons,
      `SPEC.md`, `screenshots/`
- [ ] Critic panel findings applied; QA verdict = ship (zero console errors,
      offline reload works, share/save works)

## 2. Ship-prepped (autonomous)
- [ ] `AUDIT.md` written; zero HARD BLOCK findings
- [ ] `marketing/listing.md`, `marketing/reels.md` (3 scripts),
      `marketing/launch-checklist.md` present

## 3. Merged (human: review the PR)
- [ ] Draft PR reviewed and merged — merge is the factory's signal to start the
      next app

## 4. Live (needs hosting token + domain)
- [ ] Deployed to `<slug>.<domain>` via the deploy Action
- [ ] Installability verified on a real iPhone (Add to Home Screen)
- [ ] First reel filmed from `marketing/reels.md` script #1 and posted
- [ ] Paywall connected to a Stripe Payment Link (when Stripe exists)

## 5. App Store (needs Apple Developer account; only for apps with traction)
- [ ] Capacitor wrap (`npx cap add ios`), native icons/splash generated
- [ ] Run the vendored skill: audit per
      [.claude/skills/app-store-approval/SKILL.md](../.claude/skills/app-store-approval/SKILL.md)
      → `APP_STORE_APPROVAL.md` with zero HARD BLOCK
- [ ] IAP via StoreKit replaces the web paywall in the native build (3.1.1)
- [ ] Screenshots, listing from `marketing/listing.md`, privacy labels, age rating
- [ ] Submit; on rejection, the skill's rejection-db drives the fix-and-resubmit

## Kill criteria (the factory moves on without sentiment)

An app is parked (not deleted) when, after real distribution attempts:
- 3+ posted reels all under ~10k views, or
- traffic arrives but <0.5% ever open the paywall, or
- a structurally better idea is waiting and the maintain cost isn't zero.

Parked apps keep working forever (they're static PWAs) — they cost nothing to leave
live, and occasionally one resurrects on a random viral hit.
