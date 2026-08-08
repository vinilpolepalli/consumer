# Dated requirements

**Verified August 2026.** Re-verify against
<https://developer.apple.com/news/upcoming-requirements/> before relying on this
after **Q4 2026**. Everything below has a date attached because it either has
already flipped from "recommended" to "enforced", or is scheduled to.

Read this file first — it is short, and a missed SDK minimum is a hard block that
makes every other finding irrelevant.

## Already enforced

| Date | Requirement | Failure mode |
|---|---|---|
| **Feb 17, 2025** | EU: verified DSA trader status required | App removed from EU storefronts |
| **May 1, 2025** | US storefront: no prohibition on external purchase links/CTAs (post-*Epic*). Anti-steering still applies everywhere else | 3.1.1(a) rejection outside the US |
| **Nov 13, 2025** | 5.1.2(i) third-party AI consent; 4.1(c) other developers' brands/icons; 4.7 mini apps & mini games in scope; 3.2.2(ix) loans capped at 36% APR and no ≤60-day full-repayment terms; crypto exchanges added to 5.1.1(ix) highly-regulated; 2.5.10 (empty ad banners) deleted | Rejection under the new text |
| **Jan 31, 2026** | New 5-tier age ratings: 4+, 9+, 13+, 16+, 18+ (12+ and 17+ removed). New questionnaire is mandatory | App updates blocked until the questionnaire is answered |
| **April 28, 2026** | iOS/iPadOS apps must be built with the **iOS 26 SDK (Xcode 26+)**; watchOS builds must be 64-bit. Deployment target may stay lower | **ITMS-90725** on upload |
| **Sept 2026** | Social-media questions added to the age-rating questionnaire; apps with social feeds are forced to **13+ minimum** | Age rating changed / update blocked |

## How to check the SDK minimum locally

```bash
xcodebuild -version          # Xcode 26.x or newer
xcodebuild -showsdks         # iphoneos26.x present
```

In CI, check the runner image's Xcode version — this is the most common cause of
"it uploads from my machine but not from CI".

The **deployment target** (`IPHONEOS_DEPLOYMENT_TARGET`) is a separate setting and
does *not* need to move; only the SDK the binary is built against.

## Staleness rule for this skill

If today's date is past **Q4 2026**, treat every row above as *probably still true
but unverified*, tell the user so in the report, and fetch
<https://developer.apple.com/news/upcoming-requirements/> plus
<https://developer.apple.com/app-store/review/guidelines/> before giving advice
that depends on a date.

Sources:
- <https://developer.apple.com/news/upcoming-requirements/>
- <https://developer.apple.com/news/?id=ey6d8onl> (Nov 13, 2025 guideline update)
- <https://9to5mac.com/2026/07/09/apple-adds-social-media-questions-to-app-store-connect-age-rating-questionnaire/>
