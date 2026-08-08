# Privacy: manifests, required-reason APIs, ATT, AI consent, labels

Read this when `scan_required_apis.sh`, `scan_plist.sh` or `scan_ai_endpoints.sh`
produce findings, or whenever the app touches personal data.

**Last verified: August 2026.**

---

## PrivacyInfo.xcprivacy

A property list added to the app target (and to each framework/extension that
needs one). Four top-level keys:

| Key | Type | Meaning |
|---|---|---|
| `NSPrivacyTracking` | Bool | Does the app track users as defined by ATT? |
| `NSPrivacyTrackingDomains` | Array\<String\> | Every domain used for tracking. If tracking is true this must not be empty; domains listed here are blocked unless the user grants ATT permission |
| `NSPrivacyCollectedDataTypes` | Array\<Dict\> | What is collected, whether it is linked to identity, whether it is used for tracking, and why |
| `NSPrivacyAccessedAPITypes` | Array\<Dict\> | Required-reason API categories plus approved reason codes |

Skeleton:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key><false/>
  <key>NSPrivacyTrackingDomains</key><array/>
  <key>NSPrivacyCollectedDataTypes</key><array/>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>CA92.1</string></array>
    </dict>
  </array>
</dict>
</plist>
```

**The manifest must agree with the App Privacy nutrition labels in App Store
Connect and with the privacy policy.** A mismatch between what the binary does
and what the labels claim is one of the top three rejection causes — and it is
the one that gets caught *after* approval, in an update.

## Required-reason APIs (ITMS-91053 / 91055)

Five categories. Declaring a category with a code that Apple does not list for
it is an invalid-manifest error, not a warning.

| Category | Typical triggers in code | Approved reason codes |
|---|---|---|
| `…CategoryUserDefaults` | `UserDefaults`, `NSUserDefaults`, `@AppStorage` | CA92.1, 1C8F.1, C56D.1, AC6B.1 |
| `…CategoryFileTimestamp` | `.creationDate`, `.contentModificationDate`, `stat()`, `getattrlist` | DDA9.1, C617.1, 3B52.1, 0A2A.1 |
| `…CategorySystemBootTime` | `systemUptime`, `mach_absolute_time` | 35F9.1, 8FFB.1, 3D61.1 |
| `…CategoryDiskSpace` | `volumeAvailableCapacity`, `NSFileSystemFreeSize`, `statfs` | 85F4.1, E174.1, 7D9E.1, B728.1 |
| `…CategoryActiveKeyboards` | `activeInputModes`, `UITextInputMode` | 3EC4.1, 54BD.1 |

Notes that save a resubmission cycle:
- `@AppStorage` is `UserDefaults`. So is any wrapper library over it.
- The rule covers the *app's* code **and** code in any framework you ship. A
  vendored framework with its own manifest covers itself; source you pasted in
  does not.
- Pick the reason that is actually true. `CA92.1` (access only to app-group data
  written by the app) is not a blanket answer.

Source: <https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api>

## Third-party SDK manifests (ITMS-91061)

86 commonly-used SDKs must ship both a privacy manifest and a valid signature.
Any version, and any repackaging, is covered. Mirror of Apple's list:
[`../scripts/data/apple-sdk-manifest-list.txt`](../scripts/data/apple-sdk-manifest-list.txt).

The practical fix is almost always "bump the dependency" — most vendors shipped
compliant versions in 2024. If a vendor never did, the SDK has to go.

Source: <https://developer.apple.com/support/third-party-SDK-requirements/>

---

## Purpose strings (5.1.1 / ITMS-90683)

Missing string with the framework linked → the **upload** fails. Present but
generic → the **review** fails.

A good purpose string names three things: the feature, the benefit to the user,
and the data involved.

| Bad | Good |
|---|---|
| "App needs access to your camera." | "Snapbook uses the camera so you can photograph a receipt and attach it to an expense. Photos stay on your device unless you share them." |
| "Required for location." | "Trailmark uses your location while the app is open to show your position on the trail map and to record the route you walked." |

Modern Xcode projects generate `Info.plist` from build settings — the keys live
in `project.pbxproj` as `INFOPLIST_KEY_NSCameraUsageDescription`. `scan_plist.sh`
checks both locations.

---

## 5.1.2(i) Third-party AI consent

Added **Nov 13, 2025**. The highest-value check in this skill for any app that
sends user data to an AI provider.

**Verbatim rule:**

> "You must clearly disclose where personal data will be shared with third
> parties, including with third-party AI, and obtain explicit permission before
> doing so."

**Real rejection text:**

> "The app appears to share the user's personal data with a third-party AI
> service but the app does not clearly explain what data is sent, identify who
> the data is sent to, and ask the user's permission before sharing the data."

### All four requirements must be met

1. **Disclose WHAT data is sent** — "the text of your message and any photo you
   attach", not "some data".
2. **Name WHO receives it** — the legal entity and product, e.g. "Anthropic, PBC
   (Claude)", "OpenAI, L.L.C. (GPT-4o)". A generic "our AI partner" fails.
3. **Obtain permission BEFORE sending** — the consent gate must sit in front of
   the *first* network transmission, not in a settings screen the user may never
   open.
4. **The privacy policy must identify all of it** and confirm that the third
   party protects the data equivalently.

### The documented repeat-rejection trap

Developers have logged **8+ rejection cycles** on this one guideline. The root
cause in the best-documented case: the consent gate was correct, but the check
was written as

```swift
// WRONG — the reviewer never saw the screen
if !hasSeenConsent && !hasConsented { showConsent() }
```

A `hasSeenConsent`-style flag (or anything reset per-launch/per-install
differently on the reviewer's device) meant the consent screen did not appear on
the review device, so the reviewer reported "the app does not ask permission".

The fix that cleared it was gating the entire app on the consent value **alone**:

```swift
// RIGHT — no "seen" flag anywhere in the condition
if !hasConsented {
    ConsentView()      // blocks all AI functionality until accepted
} else {
    RootView()
}
```

`scan_ai_endpoints.sh` flags exactly this pattern: consent symbols combined with
`hasSeen*` / `didShow*` / `firstLaunch*` flags.

### Consistency triangle

The consent UI, the App Privacy nutrition labels, and the privacy policy must all
describe the *same* data flow. Reviewers compare them. If the consent screen says
"your messages", the label must declare the corresponding data type, and the
policy must name the vendor.

Sources: <https://developer.apple.com/news/?id=ey6d8onl> ,
<https://developer.apple.com/forums/thread/815109> ,
<https://developer.apple.com/forums/thread/820209>

---

## 5.1.2 App Tracking Transparency

Tracking = linking user or device data collected in your app with data collected
by *other* companies for advertising or measurement, or sharing it with a data
broker.

If any of Facebook SDK, Firebase (with ad features), AppsFlyer, Adjust, Branch,
TikTok Business SDK, or similar are present and used for attribution:

- Show the `ATTrackingManager.requestTrackingAuthorization` prompt **before**
  collecting the IDFA.
- Ship `NSUserTrackingUsageDescription`.
- Set `NSPrivacyTracking` true and list the domains in `NSPrivacyTrackingDomains`.
- Do not gate app functionality on the user granting tracking.

---

## 5.1.3 Health data

- HealthKit, Motion & Fitness and health-research data may not be used for
  advertising, marketing, or use-based data mining.
- It may not be sold to data brokers or shared with third parties for those
  purposes.
- Do not write false or test data into HealthKit.
- Do not store personal health information in iCloud.

`scan_healthkit.sh` flags HealthKit code coexisting with ad/analytics SDKs or
with CloudKit/`NSUbiquitousKeyValueStore` — those are pointers to check by hand,
not proof.

Source: <https://developer.apple.com/health-fitness/>

---

## 5.1.1(v) Account deletion — implementation notes

The button must be reachable inside the app and must start a real deletion.
Common failure modes seen in rejections:

- `deleteAccount()` that calls `signOut()` and clears `UserDefaults`.
- A link that opens a web form (allowed only as a *continuation*; initiation must
  be in-app).
- Deletion offered only to email/password accounts, not to SSO accounts.
- Sign in with Apple credential never revoked — call the revoke endpoint as part
  of deletion.

Highly-regulated apps (banking, health) may direct the user to a supervised
process, but must still surface it in-app.
