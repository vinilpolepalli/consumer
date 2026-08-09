# Ship-readiness audit — The Tab

Audited 2026-08-09 · Scope: PWA ship-today + future Capacitor App Store wrap
**0 HARD BLOCK · 1 LIKELY REJECTION · 9 RISK FLAG**
App Store guidelines verified against `.claude/skills/app-store-approval` (last verified August 2026) — re-verify at <https://developer.apple.com/app-store/review/guidelines/> before submission.

---

## Part 1 — PWA, shippable today

### What passes (verified)

| Check | Status | Evidence |
|---|---|---|
| Manifest completeness | **PASS** — `id`, `name`, `short_name`, `description`, `start_url`, `scope`, `display: standalone`, `orientation`, `background_color`, `theme_color` all present | `manifest.webmanifest:1-17` |
| Icons | **PASS** — 192×192, 512×512, and a dedicated 512×512 `purpose: maskable` icon. Dimensions verified on disk; maskable art sits inside the 80% safe zone on a full-bleed background | `icon-192.png`, `icon-512.png`, `icon-maskable-512.png` |
| Service worker registration | **PASS** — registered on `load`, relative path, scope matches manifest, `file:` guard, silent-fail catch | `index.html:2231-2232` |
| Service worker correctness | **PASS** — versioned precache (`thetab-v1.1.0`), stale-cache cleanup on `activate`, `skipWaiting` + `clients.claim`, network-first HTML (ships fixes to installed users) with cache fallback, cache-first static assets, same-origin GET-only guard | `sw.js:13-58` |
| Offline behavior | **PASS** — full precache of all 7 shipped files; app is 100% client-side; settings shows an offline indicator ("Offline. The math still works.") | `sw.js:3-11`, `index.html:2148` |
| iOS installability | **PASS** — 180×180 `apple-touch-icon`, `apple-mobile-web-app-capable`, `apple-mobile-web-app-status-bar-style: black-translucent`, `apple-mobile-web-app-title`, `viewport-fit=cover` + safe-area insets, plus an in-app Add-to-Home-Screen instruction sheet with iOS/Android branching | `index.html:5-14`, `index.html:585-604`, `index.html:2199-2206` |
| Lighthouse basics | **PASS (one flag, below)** — `<meta charset>`, viewport, `<title>`, meta description, `lang="en"`, theme-color, no render-blocking external resources (single file, inline CSS/JS) | `index.html:1-11` |
| Privacy: no external requests | **PASS** — zero network calls in app code; the only `http://` string is the inert SVG namespace constant (`index.html:2058`). No fetch/XHR/WebSocket/sendBeacon, no analytics, no trackers, no fonts/CDNs | whole-file grep |
| Privacy: plain-language note in-app | **PASS** — Settings: "Everything stays on your phone. No account, no bank link, no tracking." Home footer: "Everything stays on your phone." | `index.html:536`, `index.html:445` |
| Data storage | **PASS** — single `localStorage` key `thetab.v1`, storage-disabled degrades to in-memory | `index.html:666-670` |
| Reduced motion / a11y | **PASS** — `prefers-reduced-motion` honored in CSS and JS (haptics off), 39 aria attributes, dialogs use `role="dialog"` + `aria-modal` | `index.html:337`, `621`, `789` |

### PWA findings

#### P1. RISK FLAG — `user-scalable=no` fails the Lighthouse accessibility audit
**Evidence:** `index.html:5` — `<meta name="viewport" content="... user-scalable=no">`
**Why:** Lighthouse flags `[user-scalable="no"]` as an accessibility failure (blocks low-vision zoom). iOS Safari has ignored it since iOS 10, so it isn't even delivering the intended behavior there.
**Fix:** Drop `user-scalable=no`; if double-tap-zoom jank is the concern, `touch-action: manipulation` on interactive elements achieves it accessibly.

#### P2. RISK FLAG — offline navigate fallback can resolve to `undefined` if the cache is evicted
**Evidence:** `sw.js:40` — `.catch(() => caches.match('./index.html'))`
**Why:** iOS evicts CacheStorage for infrequently used sites. If eviction happens, an offline launch hits `respondWith(undefined)` → a network-error page instead of a controlled failure.
**Fix:** Chain a final fallback: `caches.match('./index.html').then(r => r || caches.match('./')).then(r => r || new Response('<meta charset=utf-8>Offline — reopen once online.', {headers:{'Content-Type':'text/html'}}))`.

#### P3. RISK FLAG — `theme-color` stays dark when the user switches to the light appearance
**Evidence:** `index.html:6` (static `#0C0E12`) vs. the light/system appearance toggle at `index.html:529`, `2163-2164`
**Why:** In light mode, browser chrome / installed-app title bar renders dark against a light UI. Cosmetic, but visible on every launch for light-mode users.
**Fix:** Update the meta tag from JS when appearance changes, or ship paired `<meta name="theme-color" media="(prefers-color-scheme: …)">` tags plus a JS override for the manual toggle.

**Minor nits (not counted as findings):** manifest has no `screenshots`/`categories` (richer Android install sheet — you already have 5 screenshots in `screenshots/`); no `apple-touch-startup-image` (iOS shows a blank launch frame); no `<noscript>` message; the legacy `apple-mobile-web-app-capable` meta could gain the standard `mobile-web-app-capable` twin.

**PWA verdict: shippable today.** Nothing blocks install, offline use, or the privacy promise on any platform.

---

## Part 2 — Future Capacitor wrap (App Store)

Severity per the app-store-approval skill model: HARD BLOCK / LIKELY REJECTION / RISK FLAG. No Xcode project exists yet (`capacitor.config.json` only), so nothing can deterministically fail an upload *today* — that is why there are no HARD BLOCKs. Several RISK FLAGs below convert to HARD BLOCK the moment the named condition occurs.

### HARD BLOCK
None found.

### LIKELY REJECTION

#### A1. 2.1 / 2.2 — Stubbed commerce UI in a shipped binary: price displayed, "early access" framing, Restore that can never restore
**Evidence:** `index.html:1862` (renders `TOTAL $14.99`), `index.html:1882` (CTA `FREE DURING EARLY ACCESS — OPEN IT`), `index.html:488` + `1896-1907` ("Restore purchase" reads `localStorage`, toasts "No purchase on this phone yet."), `index.html:620` (`PAYMENTS.keysPresent: false`)
**Why:** Apple rejects incomplete/demo builds (2.1 is ~22% of observed rejections; 2.2 bars betas/trials from the store). A reviewer sees a $14.99 total on the paywall, a Restore button with nothing behind it, and the literal words "early access" — the standard read is "unfinished app / placeholder commerce."
**Fix:** Before wrapping, pick one: (a) wire real StoreKit IAP and drop the early-access copy, or (b) ship genuinely free — remove the price line, the Restore button, and any "early access" wording from UI and metadata. Do not ship the stub as-is.
**Source:** <https://developer.apple.com/forums/thread/116236>

### RISK FLAG

#### A2. 4.2 — Minimum functionality: a bare wrap of a single-page web calculator is the canonical webview-wrapper rejection
**Evidence:** `capacitor.config.json:4` (`webDir: "."` — the wrap is exactly the PWA, no native layer), single-file `index.html` app
**Why:** 4.2 is "the #1 killer of webview wrappers": apps that are "not particularly useful, unique, or app-like" are rejected. Offline-first and local-only helps, but a reviewer comparing the app to the free website sees no iOS-specific value. (RISK FLAG rather than LIKELY per the skill's model — minimum functionality is a human judgement call — but a *bare* wrap trends toward rejection.)
**What would settle it:** Add real native capability before submitting: Capacitor Haptics for the flip beat (`index.html:789` currently uses `navigator.vibrate`, which WKWebView does not support — the signature haptic is silently dead in a wrap), native share sheet for receipt export, a home-screen widget (streak / banked total), App Shortcuts. Two or more of these moves 4.2 from live risk to defensible.
**Source:** rejection-db §4.2

#### A3. 3.1.1 — When payments go native, the $14.99 unlock must be StoreKit IAP, and Restore must be StoreKit restore
**Evidence:** `index.html:674-676` (`unlockPremium()` stub, comment says only internals change when keys exist), `index.html:1896-1907` (Restore = localStorage read), `index.html:2172` (premium persisted locally)
**Why:** A lifetime unlock of digital features is a digital good — IAP only. Any Stripe/PayPal/web-checkout path is a rejection outside the US storefront (post-Epic carve-out is US-only, 3.1.1(a)/3.1.3); a localStorage "restore" also fails review because a reinstall or new device loses a real paid entitlement.
**Fix:** One non-consumable SKU via StoreKit 2; `payRestore` calls `AppStore.sync()`/`Transaction.currentEntitlements`, not localStorage; keep the "purchase never deleted" contract via the App Store, not device storage.
**Source:** <https://developer.apple.com/news/?id=9txfddzf>, rejection-db §3.1.1

#### A4. 5.1.1 / ITMS-90683 — Purpose strings: none exist yet; becomes a HARD BLOCK the moment a plugin needs one
**Evidence:** no `Info.plist` in the repo; share flow at `index.html:1786-1799` (Web Share of a generated PNG with download fallback)
**Why:** If the wrapped share flow saves receipts to Photos (the common Capacitor pattern via `PHPhotoLibrary`), a missing `NSPhotoLibraryAddUsageDescription` is ITMS-90683 — the upload fails before review. Generic strings ("App needs access") are rejected at review under 5.1.1.
**Fix:** When creating the Xcode project, audit every Capacitor plugin's required `NS*UsageDescription` keys; write specific strings naming the feature, benefit, and data type (e.g. "Saves your receipt image to your photo library when you tap Save").
**Source:** <https://ptkd.com/journal/how-to-fix-itms-90683-missing-purpose-string-in-info-plist>

#### A5. ITMS-91053 — Required-reason APIs: the wrap needs a `PrivacyInfo.xcprivacy`
**Evidence:** prospective — Capacitor's bridge and common plugins touch `UserDefaults` natively; app web code uses only web `localStorage` (`index.html:666-670`), which itself needs no declaration
**Why:** Uploads with undeclared required-reason API use are rejected by App Store Connect (ITMS-91053); wrong reason codes are ITMS-91055. Recent Capacitor versions bundle SDK-level manifests, but the app target still needs its own manifest if app-level native code (or an added plugin without one) touches a listed category.
**Fix:** Ship `PrivacyInfo.xcprivacy` with `NSPrivacyAccessedAPICategoryUserDefaults` reason `CA92.1` if applicable; `NSPrivacyCollectedDataTypes` stays empty (nothing is collected — keep it that way and the App Privacy label is simply "Data Not Collected").
**Source:** <https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api>

#### A6. 5.1.1(v) — Account deletion: not applicable today; a HARD BLOCK the day accounts exist
**Evidence:** `index.html:536` ("No account, no bank link, no tracking") — no signup/login anywhere in the code
**Why:** Any future account system (sync, leaderboards, "save your tab to the cloud") triggers the requirement: in-app *initiation* of real server-side deletion. Sign-out is not deletion; a support email is not deletion; reviewers test the button. This applies even to SSO-created accounts.
**Fix:** None needed now. Record this as a gate in the spec: accounts ship with in-app deletion or they don't ship.
**Source:** <https://ptkd.com/journal/rejection-5-1-1-v-account-deletion-for-ai-social-login>

#### A7. 4.3 — Spam/template risk for a factory-built app portfolio
**Evidence:** repo context — this is app #2 from an automated build pipeline sharing structure (single-file PWA + Capacitor wrap) with `apps/last-visits`
**Why:** AI-generated template apps are a named, growing 4.3 target; multiple structurally similar submissions from one developer account can auto-reject within seconds. 4.3 also has the highest false-positive/appeal-win rate.
**Fix:** Distinct icons/names/UX per app (already true), stagger submissions, document each app's unique functionality in reviewer notes, and be ready to appeal.
**Source:** <https://developer.apple.com/forums/thread/788165>

#### A8. Capacitor config hygiene — `webDir: "."` ships repo files into the .ipa; custom `iosScheme` pins the storage origin
**Evidence:** `capacitor.config.json:4` (`"webDir": "."` — bundle would include `SPEC.md`, `AUDIT.md`, 1.4 MB of `screenshots/`, `sw.js`), `capacitor.config.json:11` (`"iosScheme": "thetab"`)
**Why:** Internal spec/audit docs inside a reviewed binary invite 2.1 "information needed" questions and bloat the app; `localStorage` (all user data *and* the premium unlock) is keyed to the WebView origin, so changing the scheme in any later release silently wipes every user's data and entitlement — and the SW registration (`index.html:2231`) is dead weight inside WKWebView.
**Fix:** Point `webDir` at a `dist/` containing only `index.html`, manifest, and icons; treat `iosScheme` as frozen forever once v1 ships; optionally skip SW registration when `window.Capacitor` is present.

### SUBMISSION ARTIFACTS (live in App Store Connect, not in code)

| Item | Status |
|---|---|
| Privacy policy URL | **Required even with zero collection** — ASC will not let you submit without one; also link it in-app (Settings is the natural spot). Unverified |
| Support URL with real contact method | Unverified — top-3 rejection reason when dead (1.5) |
| App Privacy labels | Should be "Data Not Collected" — must stay consistent with the manifest in A5 |
| Export compliance | Set `ITSAppUsesNonExemptEncryption = false` (no non-exempt crypto in this app) or TestFlight sticks on "Missing Compliance" |
| Demo credentials | Not needed — no login exists |
| Age rating questionnaire | Answer under the 5-tier system; no UGC/social surface in v1 |
| Build SDK | iOS 26 SDK / Xcode 26+ mandatory since 2026-04-28 (ITMS-90725) — pin CI before first upload |
| App name | Spec says display name "The Tab: Lifetime Receipt" — keep screenshots/description matched to the shipped build (2.3) |

### Manual review checklist (cannot be verified statically)

- [ ] Screenshots and description match the shipped build (2.3)
- [ ] Age-rating questionnaire answered under the 5-tier system
- [ ] App Privacy labels match actual data flows and `PrivacyInfo.xcprivacy` (5.1.1)
- [ ] Support URL is live and contains a real contact method (1.5)
- [ ] Privacy policy URL is live, and also linked inside the app (5.1.1(i))
- [ ] If IAP ships: Terms/EULA link in the App Store **Description** field; every IAP has a review screenshot; paywall shows what is provided, full price most prominently, Terms, Privacy, and Restore (3.1.2)
- [ ] Built with the iOS 26 SDK / Xcode 26+, including on CI (ITMS-90725)
- [ ] Purpose strings name the feature, the benefit, and the data type (5.1.1)
- [ ] Icon and app name use no other developer's brand (4.1(c)) — icon is an original receipt illustration; verified no third-party marks
- [ ] Export compliance answered — TestFlight not stuck on "Missing Compliance"
- [ ] Tested on a physical device, cold install, in Airplane Mode too

---

*This audit is risk-scoring, not a guarantee — reviewer inconsistency is real, Apple's guidelines change (verify the 3.1.x numbering against the live page before submitting), and none of this is legal advice.*
