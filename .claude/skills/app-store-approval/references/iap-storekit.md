# In-app purchase, subscriptions and paywalls (3.1.x)

Read this when `scan_paywall.sh` fires, or whenever the app charges money.

**Last verified: August 2026.** The 3.1.x numbering has moved more than any other
part of the guidelines — verify against
<https://developer.apple.com/app-store/review/guidelines/> before quoting a
sub-number to the user.

---

## 3.1.1 — what must use IAP

Anything that unlocks features or content **inside** the app: subscriptions,
in-app currency, game levels, premium content, "pro" unlocks, and digital gift
cards redeemable in-app. No alternative mechanism — license keys, redemption
codes, QR codes, crypto payments — may unlock digital content.

Detection signals: Stripe/PayPal/Braintree/Paddle SDKs or external checkout URLs
inside an app that unlocks digital content; a "enter your license key" field.

## 3.1.1(a) / 3.1.3 / 3.1.3(a) — the regional split (since May 1, 2025)

Post-*Epic*:

- **US storefront:** no prohibition on buttons, external links or calls to action
  pointing at other purchase methods. No entitlement required.
- **Every other storefront:** anti-steering still applies. Use IAP, or hold a
  regional **External Purchase Link** entitlement (the EU has its own DMA terms).

So an app with a "subscribe on our website" button is fine in the US and a
rejection in Germany unless the UI is storefront-gated:

```swift
let storefront = await Storefront.current?.countryCode   // "USA", "DEU", …
if storefront == "USA" { ExternalPurchaseLink() }
```

Source: <https://developer.apple.com/news/?id=9txfddzf>

## 3.1.3 categories — who may use non-IAP payment

| Category | Rule |
|---|---|
| (a) Reader apps | Content bought outside may be consumed in-app |
| (b) Multiplatform services | Content bought elsewhere may be used in-app, if also offered as IAP |
| (c) Enterprise services | Consumer and family sales must still use IAP |
| (d) Person-to-person services | Real-time 1:1 services may use non-IAP; **1-to-many must use IAP** |
| (e) Physical goods and services | **Must** use a non-IAP payment method |
| (f) Free companion apps | Paid content unlocked by an existing purchase elsewhere |
| (g) Advertising management apps | May use non-IAP |

Numbering note: **3.1.4 = Hardware-Specific Content, 3.1.5 = Cryptocurrencies.**
Verify against the live page before shipping advice.

---

## The seven required paywall elements

Reviewers walk the purchase flow end to end. All seven must be visible on the
paywall itself, not buried in a settings screen:

1. **Subscription title.**
2. **Length / duration** of the subscription period.
3. **The full renewal price, as the most prominent price element**, localized —
   plus a per-unit price if helpful. A large "$4.99/mo" next to a small
   "billed $59.99/year" is a rejection.
4. **What the user gets for each period.**
5. **A functional Privacy Policy link.**
6. **A functional Terms of Use (EULA) link.**
7. **A Restore Purchases mechanism.**

Additional requirements:

- The Terms of Use and Privacy Policy links must **also** appear in App Store
  metadata. There is no dedicated Terms field — put the link in the **Description**.
- Minimum subscription length is **7 days**, and the subscription must be
  available across all of the user's devices.
- Thin utility subscriptions attract "does this provide ongoing value?"
  challenges under 3.1.2 — prepare reviewer notes that answer it directly.

### Prices come from StoreKit, never from a string

```swift
// WRONG — wrong currency, wrong tax, wrong number in most storefronts
Text("$9.99 / month")

// RIGHT
Text(product.displayPrice)                       // localized, correct
Text(product.subscription?.subscriptionPeriod.formatted() ?? "")
```

A hardcoded price is both a 3.1.2 finding and a real-world bug: the App Store
shows the localized price at purchase, so the paywall and the sheet disagree.

### Restore Purchases

```swift
Button("Restore Purchases") {
    Task { try? await AppStore.sync() }
}
```

Required even if the app auto-syncs entitlements — the reviewer looks for the
control.

### Family Sharing

Check `Product.isFamilyShareable` and `Transaction.ownershipType` before granting
entitlements, otherwise family members get nothing and leave 1-star reviews.

> **Enabling Family Sharing for a product in App Store Connect is IRREVERSIBLE.**
> Decide before you switch it on.

Sources: <https://developer.apple.com/app-store/subscriptions/> ,
<https://developer.apple.com/forums/thread/813493>

---

## Reviewer notes that pre-empt 3.1.2 challenges

Include, in the App Review notes:

- The exact steps to reach the paywall.
- A sandbox account, if a purchase must be tested.
- One sentence on the ongoing value delivered per period (this is what the
  "thin utility subscription" challenge is asking for).
- If external purchase links exist: state that they are gated to the US
  storefront, and how.
