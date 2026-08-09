# The Tab — iOS build (the Mac step)

Everything in this folder is prepared by the factory; the archive/sign/submit step
needs a Mac with Xcode 26+ and the Apple Developer account
(see [docs/NEEDS-FROM-HUMAN.md](../../../docs/NEEDS-FROM-HUMAN.md), item 6).

## One-time setup on the Mac

```bash
cd apps/the-tab
npm install @capacitor/core @capacitor/cli @capacitor/ios
npx cap add ios
cp ios/PrivacyInfo.xcprivacy ios/App/App/PrivacyInfo.xcprivacy   # bundle the privacy manifest
npx cap sync ios
npx cap open ios
```

Then in Xcode: set the team, bump `appId` in `capacitor.config.json` if the final
bundle ID differs, generate icons from `../icon-512.png` (already 1024-ready in
`marketing/`), archive, upload.

## Before every submission

1. Run the factory audit — from the repo root, invoke the `app-store-approval`
   skill against this app. Zero HARD BLOCK findings is the gate.
2. **3.1.1 (payments):** the web paywall stub (`unlockPremium()` in `index.html`)
   MUST be replaced with StoreKit in the native build — digital unlocks in an iOS
   app must use In-App Purchase. The planned products (`marketing/listing.md`):
   weekly $4.99 w/ 3-day trial, annual $29.99, lifetime $39.99 — map to
   auto-renewing subscriptions + one non-consumable. RevenueCat is the fastest
   integration once its key exists.
3. **4.2 (minimum functionality):** the native build should add at least one
   native capability beyond the wrap — the home-screen widget (WidgetKit, shows
   the remaining-dots wall) is the planned one; local notifications for the
   Sunday nudge is the second.
4. No purpose strings are currently required: the app uses no camera, location,
   contacts, mic, or tracking. If a future feature adds one, add the
   `NS*UsageDescription` string and re-run the audit.

## What's already handled

- `PrivacyInfo.xcprivacy` — declares UserDefaults-equivalent storage (localStorage
  via WKWebView, reason CA92.1) and "no tracking, no collected data".
- Offline-first: the app is fully client-side; airplane-mode review passes.
- Icons: 192/512/maskable-512/apple-touch included at the app root.
