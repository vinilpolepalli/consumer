# Submission artifacts — everything that lives outside the code

The scans read your source tree. None of this is in your source tree, and it is
where a large share of rejections actually come from: a reviewer who cannot sign
in, a privacy policy URL that 404s, an age-rating questionnaire nobody answered.

Read this whenever the audit reaches the submission-artifacts step, and always
when the user asks "am I ready to submit".

**Last verified: August 2026.**

---

## Ordered by what it costs you

| Missing | Cost |
|---|---|
| App icon, launch screen | **Upload rejected** (ITMS-90022 / 90023) |
| Export compliance answer | **TestFlight blocked** — build sits at "Missing Compliance", testers cannot be invited |
| Demo account for a login-gated app | **Rejection under 2.1**, one of the most common of all |
| Privacy policy URL | **Rejection under 5.1.1(i)** |
| Support URL / contact method | **Rejection under 1.5** |
| Age rating questionnaire | **Update blocked** until answered |
| App Privacy labels wrong | **Rejection**, and it can surface on a later update |
| Review notes, contact info | **Delay** — reviewer guesses, or asks and waits |

---

## App Review Information

Found in App Store Connect under the version you are submitting. This is the
section people forget, and it is the cheapest one to get right.

### Sign-in required

Toggle it on if **any** feature is behind a login, then provide:

- **User name** and **Password** for a demo account.

The demo account must:

- **exist and be permanent** — not a trial that expired between submission and
  review, not something seeded on your laptop
- **not be rate-limited or IP-locked** — reviewers connect from Apple's network,
  often days after you submitted
- **reach every gated feature** — including the paid tier. If a feature needs a
  subscription, either grant the demo account the entitlement or explain the
  sandbox flow in the notes
- **work on a cold install** — no state left over from your device
- **survive being used more than once** — reviewers may re-open after a rejection

If the app cannot use a demo account at all (hardware pairing, real bank
credentials, an invitation-only workspace), say so in the notes and provide a
**demo mode** in the build or an attached video walkthrough. "Contact us for
access" is a rejection.

### Contact information

Name, phone number, email of someone who can answer during review. Missing
contact info does not reject you on its own — it turns a five-minute question
into a multi-day round trip.

### Notes (4000 characters)

The highest-leverage text field in App Store Connect. Use the template in
[metadata-review.md](metadata-review.md#app-review-notes--the-template-that-prevents-21).
At minimum: how to reach the main features, anything non-obvious, and — for AI
apps — which third party receives user data and where the consent screen appears.

### Attachments

Accepted: `.pdf .doc .docx .rtf .pages .xls .xlsx .numbers .zip .rar .plist
.crash .jpg .png .mp4 .avi`.

A 30-second screen recording is the fastest way to clear a "we could not find
the feature" or "the consent screen did not appear" rejection.

---

## URLs

| Field | Required | Guideline | What "done" looks like |
|---|---|---|---|
| **Privacy Policy URL** | Yes | 5.1.1(i) | Live, not behind a login, describes the actual data flow, names third parties including any AI vendor. Must **also** be reachable from inside the app |
| **Support URL** | Yes | 1.5 | Live page with a real contact route — an email address or a form that works. A marketing page with no contact is a documented top-3 rejection |
| **Marketing URL** | No | — | Optional; if given, it must work |

Check all of them yourself, in a private browser window, the day you submit. A
policy URL that resolves for you because you are logged into your own CMS is a
classic.

---

## Terms of Use / EULA

- Apple provides a **standard EULA** that applies by default.
- If you use a **custom EULA**, it goes in App Store Connect under App
  Information → License Agreement.
- **There is no dedicated Terms field on the version page.** For an app with a
  subscription, guideline 3.1.2 requires the Terms link in your metadata — put
  it in the **Description**, and keep the functional link in the paywall itself.

See [iap-storekit.md](iap-storekit.md#the-seven-required-paywall-elements) for
the paywall side.

---

## App Privacy labels

Answered once per app in App Store Connect, then kept in sync forever.

They must agree with **both** `PrivacyInfo.xcprivacy` and what the app actually
does — including data your SDKs collect on your behalf. Reviewers compare the
label to the binary; a mismatch is a rejection cause in its own right, and one
that often surfaces on a later update rather than the first submission.

The three-way consistency requirement (labels ↔ manifest ↔ in-app consent copy)
is detailed in [privacy.md](privacy.md#consistency-triangle).

---

## Age rating

Answered via the questionnaire; the app cannot be updated until it is complete.

- Five tiers since Jan 31, 2026: **4+, 9+, 13+, 16+, 18+** (12+ and 17+ removed).
- From **Sept 2026**, social-media questions are part of the questionnaire and
  apps with social feeds are forced to a **13+ minimum**.

See [deadlines.md](deadlines.md).

---

## Export compliance

App Store Connect asks about encryption on **every** upload unless you answer it
in the build. Until it is answered, TestFlight shows **"Missing Compliance"** and
you cannot distribute to testers.

Put the answer in `Info.plist` once:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

- **`false`** — the app only uses encryption Apple exempts, e.g. HTTPS through
  `URLSession`, or the OS keychain. This covers most apps.
- **`true`** — the app ships its own cryptography, a bundled crypto library, a
  VPN, encrypted messaging, or encrypted storage. You then answer the full
  questionnaire and may need documentation.

If you are unsure, do not guess in the plist — answer the questionnaire in App
Store Connect and take advice. This is an export-control declaration, not a
formality.

Sources:
<https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-export-compliance-information-for-beta-builds/>

---

## The rest, one line each

| Item | What "done" looks like |
|---|---|
| **App icon** | 1024×1024 in the asset catalog, no alpha channel, no transparency. Missing or wrong-size → ITMS-90022 / ITMS-90023 |
| **Launch screen** | A launch storyboard or `UILaunchScreen` in Info.plist — required, and its absence looks like an unfinished app |
| **Screenshots** | Real UI from the shipped build, correct sizes for every required device class. No device frames claiming features you do not have (2.3) |
| **App name & subtitle** | Within the character limits, no other developer's brand (4.1(c)), no keyword stuffing (2.3.7) |
| **Category** | Matches what the app does — a mismatch invites 2.3 |
| **Content rights** | Declare whether the app contains third-party content, and be ready to show you have the rights |
| **Copyright** | Year and entity you actually own |
| **IAP metadata** | Every product needs a display name, description, and a **review screenshot** — a missing review screenshot blocks the IAP, not the app, and people miss it |
| **Version & build numbers** | `CFBundleShortVersionString` incremented past the last released version; `CFBundleVersion` unique |
| **TestFlight beta info** | Beta description and, for external testing, beta App Review — external groups need their own review pass |
| **What to test** | Fill it in for TestFlight builds; testers who do not know what changed do not test it |

---

## Questions to ask the user

These cannot be answered from the repository. Ask only the ones the audit gave a
reason to ask, and record the answer in the report so it is visibly checked
rather than silently skipped:

| If the audit found | Ask |
|---|---|
| A login or account-creation flow | "Are working demo credentials in App Review Information → Sign-in required?" |
| Any data collection | "Is the privacy policy URL live, public, and also linked in-app?" |
| A subscription or IAP | "Is the Terms/EULA link in the Description field, and does every IAP have a review screenshot?" |
| No `ITSAppUsesNonExemptEncryption` | "Has export compliance been answered — is TestFlight showing Missing Compliance?" |
| A social feed or UGC surface | "Is the age-rating questionnaire answered under the 5-tier system?" |
| Anything at all | "Is the Support URL live with a working contact method?" |

A "no" is a finding at its real severity. A "yes" is a resolved line — the
report should show what was verified, not only what was broken.
