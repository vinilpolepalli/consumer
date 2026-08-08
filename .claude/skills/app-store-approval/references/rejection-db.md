# App Store rejection database

Guideline → rule → how to detect it in a codebase → fix. This is the file to
cross-check every scan finding against before writing it into the report.

**Last verified: August 2026.**

---

## Caveats — read before writing any finding

- **Reviewer inconsistency is real.** Identical builds pass and then fail,
  especially under 4.3. Consent screens that exist get reported as "not seen".
  Every heuristic here is risk-scoring, not a guarantee.
- **Static analysis has hard limits.** Purpose-string *quality*, "ongoing value"
  of a subscription, minimum functionality, spam/duplication, and metadata
  accuracy all need a human. Separate **HARD BLOCK** (deterministic: the upload
  or the review fails on a fact you can verify) from **RISK FLAG**
  (probabilistic: a reviewer may or may not call it).
- **The guidelines are a living document.** A single update (Nov 13, 2025)
  changed 5.1.2(i), 4.1(c) and 4.7 at once. Re-verify guideline numbers against
  <https://developer.apple.com/app-store/review/guidelines/> before each release
  of this skill — **especially the 3.1.x numbering**.
- **Not legal advice.**

---

## How often this actually happens

Apple's 2024 App Store Transparency Report: **7,771,599** submissions reviewed,
**1,931,400** rejected (**24.85%**), **295,109** later approved after fixes.

By pillar, largest first:

| Pillar | Rejections |
|---|---|
| Performance (2.x) | 1,235,471 — largest by far |
| Legal (5.x) | 445,696 |
| Design (4.x) | 378,300 |
| Business (3.x) | below Design |
| Safety (1.x) | below Business |

Independent developer tallies put 4.3 (spam) at roughly 28% and 2.1
(completeness) at roughly 22% of the rejections they personally observed —
indicative, not authoritative.

Source: <https://www.macrumors.com/2025/05/30/app-store-2024-transparency-report/>

**What this means for triage:** weight 2.x and 5.x findings highest. A 2.1
placeholder and a 5.1.1(v) missing delete button are worth more of the user's
time than an exotic 3.1.3 edge case.

---

# 1. SAFETY

## 1.2 User-Generated Content
**Rule.** Any app hosting UGC needs all of: a content filter, a mechanism to
report content, a mechanism to block abusive users, and published developer
contact information. **AI chat output counts as UGC.**
**Detect.** Chat/feed/comment UI present (`ChatView`, `sendMessage`, `FeedView`,
streaming completions) with no report/block handlers. Static flag → confirm by
hand.
**Fix.** Ship the full moderation stack, act on reports within 24 hours, and
publish a contact route.

## 1.4.1 Physical Harm
**Rule.** Apps claiming to measure blood pressure, blood glucose, body
temperature or blood-oxygen using device sensors alone are rejected. Health
accuracy claims must be substantiated.
**Detect.** Claim strings — "measure blood pressure", "BPM from camera",
"check your temperature with your phone".
**Fix.** Remove the claim, or substantiate it; add medical disclaimers; do not
imply diagnosis.
Source: <https://developer.apple.com/forums/thread/708478>

## 1.5 Developer Information
**Rule.** The Support URL must work and must contain a real contact method.
**Detect.** Only verifiable by hand — open the URL. A dead or contact-less
support page is a top-3 rejection reason in 2026.
**Fix.** Live page, real contact route, before submission.

---

# 2. PERFORMANCE — the largest bucket

## 2.1 App Completeness
**Rule.** No placeholder content, no crashes, no broken links; login-gated apps
must supply a demo account or a demo mode. 2.1 is also used as a catch-all
"Information Needed" rejection, and accounts for more than 40% of unresolved
cases.
**Detect (high-value, static).** `Lorem ipsum`, `TODO`, `FIXME`, "coming soon",
`example.com`, `YOUR_API_KEY_HERE`, test keys (`sk_test_`, `pk_test_`), debug
flags hardcoded on, localhost/staging endpoints, login flow with no demo
credentials recorded.
**Fix.** Scrub placeholders; put working demo credentials in App Review notes;
test on a physical device on a cold install.
Source: <https://developer.apple.com/forums/thread/116236>

## 2.3 / 2.3.1 Accurate Metadata & hidden features
**Rule.** Screenshots and description must match the shipped binary. No hidden,
dormant or undocumented features. Remote-config "switches" that reveal
functionality after review risk **account termination**, not just rejection.
**Detect.** Feature toggles keyed to date, region, storefront or build number;
remote-config gates around whole features.
**Fix.** Remove the switches, or document the functionality in the review notes
so it is disclosed rather than hidden.

## 2.3.10 Other marketplaces
**Rule.** No references to Android, Google Play, or other platforms in the app
or its metadata.
**Detect.** Grep strings, assets, and store copy for "Android", "Google Play",
"also available on…".
**Fix.** Strip the references from binary and metadata alike.

## 2.5.1 HealthKit transparency
**Rule.** Real rejections run in both directions:
(a) HealthKit is used but the health feature is not clearly identified in the
app's UI and metadata; (b) the binary links HealthKit — often dragged in by an
SDK — with no health feature at all.
**Detect.** HealthKit entitlement or `HKHealthStore` usage with no health UI
strings; `HealthKit` in the pbxproj with zero HealthKit code.
**Fix.** Surface the health feature and its purpose strings, or strip the
framework and entitlement.
Sources: <https://developer.apple.com/forums/thread/802626> ,
<https://developer.apple.com/forums/thread/762128>

---

# 3. BUSINESS

Full detail in [iap-storekit.md](iap-storekit.md). Summary:

## 3.1.1 In-App Purchase
Digital unlocks — subscriptions, in-app currency, levels, premium content,
full-version unlocks — must use IAP. No license keys, QR codes, or crypto as an
unlock mechanism. Digital gift cards redeemable in-app must use IAP.
**Detect.** Stripe/PayPal/Braintree SDKs or external checkout URLs in an app that
unlocks digital content; license-key entry fields.
**Fix.** Route digital goods through StoreKit.

## 3.1.1(a) / 3.1.3 / 3.1.3(a) — REGIONAL, post-*Epic*, since May 1 2025
**US storefront only:** no prohibition on buttons, external links or CTAs to
other purchase methods, and no entitlement required.
**Everywhere else:** anti-steering stands — IAP, or a regional External Purchase
Link entitlement (the EU has DMA-specific terms).
**Detect.** External purchase links present → flag storefront gating for manual
review.
**Fix.** Gate the steering UI to the US storefront; IAP elsewhere.
Source: <https://developer.apple.com/news/?id=9txfddzf>

## 3.1.2 Subscriptions
Seven required paywall elements, tested end-to-end by the reviewer. See
[iap-storekit.md](iap-storekit.md#the-seven-required-paywall-elements).

---

# 4. DESIGN

## 4.1(c) Copycats (new Nov 2025)
**Rule.** You may not use another developer's icon, brand or product name in your
own icon or app name without approval.
**Detect.** Manual review of icon and name.

## 4.2 Minimum Functionality
**Rule.** The #1 killer of webview wrappers: an app that is "not particularly
useful, unique, or app-like" is rejected.
**Detect.** App is essentially a single `WKWebView` with no native features.
**Fix.** Add genuine native capability — offline support, push notifications,
widgets, Face ID, share sheet, background refresh, on-device processing.

## 4.3 / 4.3(a) Spam
**Rule.** Duplicate content or functionality, template apps, or a binary/metadata
shared with a terminated account. Often auto-rejected within seconds. Also
triggered by publishing the same app across overlapping storefronts.
AI-generated template apps are a growing target.
**Detect.** Near-duplicate bundles across the developer's own apps; overlapping
storefront availability.
**Fix.** Differentiate genuinely; document unique features in the reviewer notes;
appeal if the call is wrong (4.3 has the highest false-positive rate).
Sources: <https://developer.apple.com/forums/thread/788165> ,
<https://developer.apple.com/forums/thread/774789>

## 4.7 Mini apps and mini games (clarified Nov 2025)
**Rule.** HTML5/JS mini apps and mini games are explicitly in scope: they need
age-restriction mechanisms and may not extend native APIs without approval.
**Detect.** Embedded JS runtimes — `JSContext`, `JavaScriptCore`,
`evaluateJavaScript`, CodePush-style dynamic code loading.

## 4.8 Login Services
**Rule.** If the app offers third-party login (Google, Facebook, …), it must also
offer an equivalent privacy-preserving option. Sign in with Apple qualifies. The
equivalent option must: collect only name and email, allow the email to be kept
private via a relay, and not collect interactions for advertising without
consent.
**Detect (high-value, static).** `GIDSignIn` / `FBSDKLoginKit` present with no
`AuthenticationServices` / `ASAuthorizationAppleIDButton`.
**Fix.** Add Sign in with Apple, or drop third-party SSO.
Source: <https://developer.apple.com/forums/thread/765145>

---

# 5. LEGAL — second-largest bucket

Full detail in [privacy.md](privacy.md). Summary:

## 5.1.1(i) Privacy policy
Data-collecting apps need a privacy policy linked in App Store Connect **and**
accessible in-app, plus consent for collection.

## 5.1.1(v) Account Deletion
**Rule.** Any app that supports account creation must let the user *initiate*
account deletion from inside the app. Sign-out is not deletion. "Email support"
is not deletion. A web-only form is not enough. This applies even when the
account was created through Google/Facebook/Apple SSO. **Reviewers specifically
test the button.**
**Detect (high-value, static).** Signup flow with no "Delete Account" action; or
a `deleteAccount()` that only calls `signOut()` / clears local state.
**Fix.** Real server-side deletion, reachable in-app. Revoke the Sign in with
Apple credential as part of it.
Source: <https://ptkd.com/journal/rejection-5-1-1-v-account-deletion-for-ai-social-login>

## 5.1.1 Forced login
Login may not be required for features that do not depend on an account. Allow
guest browsing.

## 5.1.1 Purpose strings
Every sensitive API needs a specific, non-generic `NS*UsageDescription`. Generic
("App needs access") is rejected at review; missing is **ITMS-90683** at upload.
**Fix.** Name the feature, the benefit, and the data type in each string.
Source: <https://ptkd.com/journal/how-to-fix-itms-90683-missing-purpose-string-in-info-plist>

## 5.1.2(i) Third-party AI — added Nov 13, 2025
The highest-value check for any AI app. Verbatim rule:

> "You must clearly disclose where personal data will be shared with third
> parties, including with third-party AI, and obtain explicit permission before
> doing so."

Full requirements, the real rejection text, and the documented repeat-rejection
trap: [privacy.md](privacy.md#512i-third-party-ai-consent).

## 5.1.2 App Tracking Transparency
Tracking users across apps and websites (Facebook, Firebase, AppsFlyer, TikTok
SDKs) requires the `ATTrackingManager` prompt plus
`NSUserTrackingUsageDescription`.
**Detect.** Tracking SDK present with no ATT prompt or usage string.

## 5.1.3 Health data
HealthKit, Motion & Fitness and health-research data may **not** be used for
advertising, marketing, or use-based data mining, nor sold to data brokers. No
writing false data into HealthKit. No personal health data in iCloud.
**Detect.** HealthKit reads flowing into ad/analytics SDKs; health data written
to iCloud / `NSUbiquitousKeyValueStore`.
**Fix.** Isolate health data from ad pipelines and iCloud; disclose sharing
explicitly.
Source: <https://developer.apple.com/health-fitness/>

## 5.2.2 Third-party IP in AI-generated assets
AI-generated icons and splash art containing recognizable brand fragments get
flagged. Sweep the whole bundle before resubmitting, not just the file that was
called out.
Source: <https://ptkd.com/journal/rejection-guideline-5-2-2-ai-assets>

---

# Submission-time ITMS errors (hard blocks)

These fail before a human ever sees the app, and are mostly detectable
statically.

| Error | Cause | Detection |
|---|---|---|
| **ITMS-90725** | Not built with the iOS 26 SDK (Xcode 26+), required since April 28, 2026 | `xcodebuild -version`, `xcodebuild -showsdks`, CI image version |
| **ITMS-90683** | Missing `NS*UsageDescription` purpose string | `scan_plist.sh` |
| **ITMS-91053** | Missing required-reason API declaration | `scan_required_apis.sh` |
| **ITMS-91055 / 91056** | Invalid reason code for the category, or an invalid manifest | `scan_required_apis.sh` |
| **ITMS-91061** | A listed third-party SDK ships no privacy manifest (or no signature) | `scan_sdks.sh` |

## Required-reason API categories and approved reason codes

| Category | Approved reason codes |
|---|---|
| `NSPrivacyAccessedAPICategoryUserDefaults` | CA92.1, 1C8F.1, C56D.1, AC6B.1 |
| `NSPrivacyAccessedAPICategoryFileTimestamp` | DDA9.1, C617.1, 3B52.1, 0A2A.1 |
| `NSPrivacyAccessedAPICategorySystemBootTime` | 35F9.1, 8FFB.1, 3D61.1 |
| `NSPrivacyAccessedAPICategoryDiskSpace` | 85F4.1, E174.1, 7D9E.1, B728.1 |
| `NSPrivacyAccessedAPICategoryActiveKeyboards` | 3EC4.1, 54BD.1 |

A made-up or wrong-category code is **ITMS-91055**, not a warning.
Source: <https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api>

## Third-party SDK manifests (ITMS-91061)

Apple publishes a list of 86 commonly-used SDKs — Firebase, Alamofire,
AFNetworking, the FBSDK family, Google libraries, Flutter plugins such as
`connectivity_plus` and `image_picker_ios`, and so on. **Any version** of a
listed SDK counts, as does anything that repackages one. Binary dependencies
also need a valid signature.
Mirror of the list: [`../scripts/data/apple-sdk-manifest-list.txt`](../scripts/data/apple-sdk-manifest-list.txt)
Source: <https://developer.apple.com/support/third-party-SDK-requirements/>

## PrivacyInfo.xcprivacy structure

Four top-level keys: `NSPrivacyTracking`, `NSPrivacyTrackingDomains`,
`NSPrivacyCollectedDataTypes`, `NSPrivacyAccessedAPITypes`.
The manifest must agree with the App Privacy nutrition labels — a label/binary
mismatch is itself a top-3 rejection cause.
