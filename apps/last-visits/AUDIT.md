# Ship-readiness audit — Last Visits

Audited 2026-08-08 · Scope: (1) PWA shipping today, (2) Capacitor/App-Store wrap later
**1 HARD BLOCK · 3 LIKELY REJECTION · 6 RISK FLAG**
App Store findings use the `app-store-approval` severity model. Guidelines verified August 2026 — re-verify at <https://developer.apple.com/app-store/review/guidelines/>.

---

## Part 1 — PWA today

### Verified passing

| Check | Result |
|---|---|
| Manifest completeness | PASS — `name`, `short_name`, `description`, `start_url: "./"`, `scope: "./"`, `display: standalone`, `orientation`, `background_color`, `theme_color: #0F0E0C` (`manifest.webmanifest`) |
| Icons | PASS — 192×192 + 512×512 (`purpose` default any) + 512×512 `purpose: maskable`, all real PNGs at declared sizes (verified with `file`) |
| Service worker correctness | PASS — versioned cache (`lv-v1.2.0`), precache of all app assets, network-first HTML with cache fallback (fixes reach installed users), cache-first static assets, old-cache cleanup on activate, `skipWaiting` + `clients.claim`, non-GET and cross-origin requests passed through (`sw.js`) |
| Offline behavior | PASS — app is a single self-contained `index.html`; after first load every screen, the reveal, the planner, logging, and share-card rendering work with no network. Cold offline navigation falls back to cached `index.html` (`sw.js:32-43`) |
| iOS installability | PASS — `apple-touch-icon` 180×180 (`index.html:14`), `apple-mobile-web-app-capable` + `black-translucent` status-bar meta + `apple-mobile-web-app-title` (`index.html:8-10`), `viewport-fit=cover` with safe-area padding, manual Add-to-Home-Screen instructions sheet for Safari (`index.html:536-552`), install banner gated to ≤2 dismissals |
| Lighthouse basics | Mostly PASS — `<title>`, `lang="en"`, meta description, theme-color, ≥44px tap targets, ARIA roles/labels on sheets and switches, no render-blocking external resources. One failure: see PWA-1 |
| Privacy | PASS — zero external requests of any kind (grep: no `http(s)://` URLs, no `fetch`, no `XMLHttpRequest`, no `sendBeacon`, no third-party `<script>`/`<link>`); no trackers or analytics; plain-language privacy note in-app, reachable from Settings → Privacy and the paywall footer (`index.html:1379`); local-only "Erase everything" with confirm (`index.html:1705-1714`) |

### PWA findings

#### PWA-1 · RISK FLAG — `user-scalable=no` disables pinch zoom
**Evidence:** `index.html:5`
**Why:** Fails the Lighthouse accessibility audit and WCAG 1.4.4 (resize text); low-vision users cannot zoom. iOS ≥10 ignores it in Safari but it still penalizes the score and it *is* honored inside a WKWebView wrap.
**Fix:** Drop `user-scalable=no` (the layout already survives zoom; `-webkit-tap-highlight` and fast-tap behavior no longer need it).
**Source:** <https://dequeuniversity.com/rules/axe/4.9/meta-viewport>

#### PWA-2 · RISK FLAG — localStorage-only persistence can be evicted by Safari
**Evidence:** `index.html:648` (`lv_state`), `index.html:593` (`lv_premium`)
**Why:** WebKit's Intelligent Tracking Prevention deletes all script-writable storage after **7 days of no use** when the app runs as a browser tab (home-screen installs are exempt). For an app whose core loop is weekly streaks and logged visits, a browser-tab user who skips two weeks loses everything, including their premium grant.
**Fix:** Call `navigator.storage.persist()` at boot; mirror state to IndexedDB (also script-writable, but `persist()` shields both); keep pushing the existing install banner — installed = exempt.
**Source:** <https://webkit.org/tracking-prevention/>

#### PWA-3 · RISK FLAG — iOS install polish gaps (manifest `id`, splash, Save-image fallback)
**Evidence:** `manifest.webmanifest` (no `id` member); `index.html` head (no `apple-touch-startup-image`); `index.html:1287-1289` ("Save image" anchor-`download` of a blob URL)
**Why:** Missing `id` ties app identity to the deploy URL (a path move becomes a "different app" to the browser); no splash images means a white flash on iOS launch; anchor blob downloads are unreliable in iOS standalone display mode, so "Save image" can silently no-op (the Share path via Web Share Level 2 is fine and is the primary path).
**Fix:** Add `"id": "./"` to the manifest; generate `apple-touch-startup-image` links (or accept the flash); for Save, fall back to `navigator.share` when the anchor path is unavailable.
**Source:** <https://developer.mozilla.org/docs/Web/Progressive_web_apps/Manifest/Reference/id>

**PWA verdict: shippable today.** Nothing blocks install or offline use on Android or iOS. The three flags above are quality/durability items, with PWA-2 the one most worth fixing before real users build streaks. Remember the non-code prerequisite: HTTPS hosting with `sw.js` served from the app root.

---

## Part 2 — App Store wrap (Capacitor) later

Context: `capacitor.config.json` wraps this exact `index.html`; `ios/PrivacyInfo.xcprivacy` and `ios/README.md` already exist. Findings assume the wrap ships the code as it stands today.

### HARD BLOCK

#### AS-1 · 3.1.1 — the only checkout path is an external web redirect; the moment payments go native this is a deterministic rejection
**Evidence:** `index.html:597-607` — `unlockPremium()` does `window.location.href = PAYMENTS.links[plan]` ("checkout must redirect back with `?premium=<plan>`", i.e. Stripe-style payment links); grant on return at `index.html:1760-1768`.
**Why:** Digital unlocks (planner, logging, themes = digital content/features) in an iOS binary must use In-App Purchase; external checkout URLs that unlock digital content are the canonical 3.1.1 detection signal. The US-storefront external-link carve-out (post-*Epic*, May 2025) does not apply everywhere else and is not what this code implements. Today `PAYMENTS.enabled` is `false` so the path is dormant — flipping it on in the wrapped build without StoreKit fails review on a fact verifiable from the code, hence HARD BLOCK on the payments milestone.
**Fix:** In the native build, replace `unlockPremium()` with StoreKit 2 (or RevenueCat, per `ios/README.md`): weekly $4.99 w/ 3-day trial + annual $29.99 as auto-renewing subscriptions, lifetime $39.99 as a non-consumable. Keep the web-redirect path for the PWA only, behind a platform check.
**Source:** <https://developer.apple.com/app-store/review/guidelines/#in-app-purchase>

### LIKELY REJECTION

#### AS-2 · 2.1 — paywall shows priced tiers with a stub purchase and "Payments aren't live yet" placeholder copy
**Evidence:** `index.html:1299-1303` (three $-priced plans rendered), `index.html:598-601` (CTA grants premium for free), `index.html:1322-1324` ("Payments aren't live yet — More Time is free while we're getting started"), `index.html:1370-1373` ("Nothing to restore yet"), `index.html:505` (Restore button).
**Why:** 2.1 App Completeness is the largest rejection bucket; "coming soon" / placeholder monetization is an explicit detection signal. A reviewer who taps "$29.99 / year" and receives the unlock free, with fine print saying payments aren't live, will treat the purchase flow as unfinished — and the priced tiers double as 3.1.1 bait.
**Fix:** For any native submission before StoreKit lands, strip prices and the Restore button entirely (present More Time as free-during-early-access with no $ figures), or hold submission until AS-1's StoreKit work is done — which also brings the 3.1.2 seven-element paywall obligations (see checklist).
**Source:** <https://developer.apple.com/forums/thread/116236>

#### AS-3 · 4.2 — a bare wrap ships zero native capability
**Evidence:** `capacitor.config.json` (no plugins; `webDir: "."` wraps the PWA verbatim); no Capacitor API usage anywhere in `index.html`.
**Why:** 4.2 minimum functionality is the documented #1 killer of webview wrappers: "essentially a single WKWebView with no native features." Offline support and app-like polish help, but as wrapped today the binary is indistinguishable from the free Safari home-screen install of the same file. Final call is a human reviewer's — which is exactly why it must not ship bare.
**Fix:** Land the two items `ios/README.md` already plans before first submission: the WidgetKit remaining-dots widget and local notifications for the Sunday nudge. Native share-sheet integration via Capacitor Share (see AS-4) adds a third cheaply.
**Source:** <https://developer.apple.com/app-store/review/guidelines/#minimum-functionality>

#### AS-4 · 2.1 — the PWA-install UI ships inside the native app and reads as an unfinished web port
**Evidence:** `index.html:577` — `STANDALONE` checks `display-mode: standalone` / `navigator.standalone`, **both false inside a Capacitor WKWebView**, so: the install banner ("add Last Visits to your home screen", `index.html:561-565`, trigger `1729-1737`) can appear inside the native app; Settings keeps an "Add to Home Screen" row (`index.html:1699`); tapping it opens Safari share-toolbar instructions (`index.html:536-552`, `1738-1742`). Also `index.html:1287-1289`: the "Save image" anchor-blob download is a silent no-op in WKWebView (no download handling wired), a dead button for the reviewer to find.
**Why:** Broken and out-of-context UI is core 2.1 territory, and browser-installation prompts inside a native binary advertise that this is a wrapped website — feeding AS-3.
**Fix:** Add a platform gate (`window.Capacitor?.isNativePlatform?.()` or a build flag) that treats native as installed: suppress the banner, the Settings row, and `sheet-ios`; route "Save image" through Capacitor Filesystem/Media instead of the anchor. Note: saving to Photos then requires `NSPhotoLibraryAddUsageDescription` — a specific string naming the feature, or it becomes ITMS-90683 (see AS-5).
**Source:** <https://developer.apple.com/forums/thread/116236>

### RISK FLAG

#### AS-5 · 5.1.1 — purpose strings: none required today; two become required with planned fixes
**Evidence:** Verified absent: no camera, location, contacts, microphone, photo-library, or tracking API use anywhere in `index.html`; `navigator.vibrate` (`index.html:579`) is a no-op in WKWebView and needs no string.
**Why:** Nothing is missing now — matching `ios/README.md`'s claim — but AS-4's Photos fix requires `NSPhotoLibraryAddUsageDescription`, and AS-3's local notifications require the notification permission prompt. A missing string at that point is ITMS-90683 at upload; a generic one is a 5.1.1 review rejection.
**Fix:** When those land, add strings that name the feature, benefit, and data type (e.g. "Saves your share card image to your photo library."). Re-run this audit after.
**Source:** <https://ptkd.com/journal/how-to-fix-itms-90683-missing-purpose-string-in-info-plist>

#### AS-6 · 4.3 — AI-factory template lineage is a growing spam target
**Evidence:** This is app #1 of a factory pipeline (repo structure; `SPEC.md`); more apps from the same account/template are planned.
**Why:** The rejection DB notes AI-generated template apps are an increasing 4.3 target, often auto-flagged; 4.3 also has the highest false-positive/appeal rate. One polished app is fine — risk compounds when sibling apps share bundle structure, UI shell, or metadata phrasing under one developer account.
**Fix:** Keep each factory app genuinely distinct in function, icon, and metadata; document unique features in reviewer notes; be ready to appeal a 4.3 (fix-and-resubmit or appeal wins most false positives).
**Source:** <https://developer.apple.com/forums/thread/788165>

#### AS-7 · 2.3 — `webDir: "."` bundles internal docs and screenshots into the shipped binary
**Evidence:** `capacitor.config.json:4` — web assets = the whole app folder: `SPEC.md` (monetization/viral strategy notes), `screenshots/` (~6 PNGs), `ios/`, and this `AUDIT.md`.
**Why:** Dead weight in the bundle, and internal strategy documents inside a reviewable binary are needless exposure (metadata/professionalism, 2.3-adjacent). Not a documented rejection cause by itself — hence RISK FLAG.
**Fix:** Build a `dist/` containing only `index.html`, `manifest.webmanifest`, `sw.js`, and the icons; point `webDir` at it.
**Source:** <https://capacitorjs.com/docs/config>

### Conditional obligations (no finding today — tripwires if the app grows)

| If this ever ships | Then |
|---|---|
| Accounts / sign-in of any kind | 5.1.1(v): in-app account **deletion** initiation is mandatory (sign-out and "email support" don't count; applies to SSO too). The local "Erase everything" (`index.html:1705`) is not account deletion. Reviewers test the button. Design it in from day one. |
| Third-party login (Google/Facebook) | 4.8: Sign in with Apple (or equivalent privacy-preserving option) becomes mandatory. |
| Any server/analytics/AI call | The "no collected data" privacy manifest, App Privacy labels, and the in-app privacy note (`index.html:1379`) must all change together — a label/binary mismatch is a top-3 rejection cause. Third-party AI calls need explicit consent first (5.1.2(i)). |
| Health/longevity claims beyond "estimate" | 1.4.1: no diagnosis or measurement claims. Current copy ("estimate built from public averages", `index.html:1378`) is on the safe side; keep it there. |

### Submission artifacts (live in App Store Connect, not in code — all currently unverified)

| Item | Status |
|---|---|
| `PrivacyInfo.xcprivacy` actually copied into the Xcode target (`ios/README.md` step) | Prepared; verify after `cap add ios` — Capacitor/WebKit UserDefaults use with no manifest = ITMS-91053. Declared category+reason (UserDefaults/CA92.1) is valid. |
| Built with iOS 26 SDK / Xcode 26+ (ITMS-90725, mandatory since 2026-04-28) | Unverified — README targets Xcode 26+; confirm on the build Mac and CI |
| Privacy policy URL (live, public, also linked in-app) | MISSING — in-app note exists (`index.html:1379`) but there is no hosted URL yet; required field in App Store Connect |
| Support URL with real contact method | MISSING — top-3 rejection reason when dead (1.5) |
| Export compliance / `ITSAppUsesNonExemptEncryption` | Not set — HTTPS-only exemption applies (`false`); set it or TestFlight shows "Missing Compliance" |
| App Privacy labels ("Data Not Collected") | Must match the empty `NSPrivacyCollectedDataTypes` in the manifest |
| Demo credentials | N/A — no login exists |
| IAP review screenshots + Terms/EULA link in the Description field | Required at the StoreKit milestone (AS-1/AS-2) |

### Manual review checklist

- [ ] Screenshots and description match the shipped build (2.3)
- [ ] Working demo account in App Review notes; tested on a cold install (2.1) — N/A while no login exists
- [ ] Age-rating questionnaire answered under the 5-tier system; social feeds force 13+ from Sept 2026
- [ ] App Privacy labels match the actual data flows and `PrivacyInfo.xcprivacy` (5.1.1)
- [ ] Support URL is live and contains a real contact method (1.5)
- [ ] Privacy policy URL is live, and also linked inside the app (5.1.1(i))
- [ ] Terms of Use (EULA) link is in the App Store **Description** field (3.1.2)
- [ ] Built with the iOS 26 SDK / Xcode 26+, including on CI (ITMS-90725)
- [ ] Purpose strings name the feature, the benefit, and the data type (5.1.1)
- [ ] The paywall shows title, duration, full renewal price as the most prominent price, what is provided, Terms, Privacy, and Restore (3.1.2)
- [ ] Icon and app name use no other developer's brand (4.1(c))
- [ ] Export compliance answered — TestFlight is not stuck on "Missing Compliance"
- [ ] Every IAP has a review screenshot and description
- [ ] Tested on a physical device, cold install, in Airplane Mode too

---

*Severities are risk scores, not guarantees — reviewer inconsistency is real. Verified against guideline text as of August 2026; Apple's guidelines change, and this is not legal advice.*
