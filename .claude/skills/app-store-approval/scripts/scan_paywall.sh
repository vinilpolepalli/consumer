#!/usr/bin/env bash
# 3.1.1 / 3.1.2 — IAP and subscription paywall requirements.
# Reviewers walk the purchase flow end to end and check for the seven required
# disclosure elements (see references/iap-storekit.md).
#
# Usage: scan_paywall.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

section "Purchase mechanism (Guideline 3.1.1)"

storekit="$(src_grep 'import StoreKit|SKProduct|Product\.products|Transaction\.|AppStore\.sync|RevenueCat|Purchases\.shared|Adapty|Superwall|Qonversion')"
external_pay="$(src_grep 'stripe\.com|api\.stripe|StripePaymentSheet|import Stripe|paypal\.com|PayPalCheckout|braintree|checkout\.com|lemonsqueezy|paddle\.com|razorpay')"
license_key="$(src_grep '(license|activation|redeem|voucher)[ _]?(key|code)' -i)"

if [ -n "$external_pay" ]; then
  while IFS= read -r line; do
    finding "RISK FLAG" "3.1.1" "External payment SDK/endpoint — allowed only for physical goods & services, or under a regional exception. Digital content must use IAP outside the US storefront — $line"
  done <<< "$external_pay"
fi

if [ -n "$license_key" ]; then
  while IFS= read -r line; do
    finding "RISK FLAG" "3.1.1" "License/redemption code entry — unlocking digital features this way is rejected unless it fits a 3.1.3 category — $line"
  done <<< "$license_key"
fi

if [ -z "$storekit" ]; then
  echo "no StoreKit / purchase SDK detected — remaining paywall checks skipped"
  summary
  exit 0
fi
echo "StoreKit or purchase SDK detected"

section "Subscription paywall disclosures (Guideline 3.1.2)"

# (3) Price must come from StoreKit, never a hardcoded string.
hardcoded="$(any_grep '\$[0-9]+([.,][0-9]{2})?[ ]*(/|per )?(mo|month|yr|year|wk|week)?|[0-9]+[.,][0-9]{2}[ ]*(USD|EUR|GBP)' --include=*.swift --include=*.strings --include=*.xcstrings --include=*.storyboard --include=*.xib)"
if [ -n "$hardcoded" ]; then
  while IFS= read -r line; do
    finding "LIKELY REJECTION" "3.1.2" "Hardcoded price string — use Product.displayPrice so the price is correct and localized in every storefront — $line"
  done <<< "$hardcoded"
fi

# (7) Restore Purchases.
restore="$(src_grep 'restorePurchases|AppStore\.sync|restoreCompletedTransactions|Purchases\.shared\.restore|SKPaymentQueue.*restore' -i)"
[ -z "$restore" ] && finding "LIKELY REJECTION" "3.1.2" "No Restore Purchases mechanism found — required on any paid/subscription app"

# (5)(6) Terms of Use (EULA) + Privacy Policy links, in the paywall itself.
terms="$(any_grep '(terms of (use|service)|EULA|termsURL|apple\.com/legal/internet-services/itunes)' --include=*.swift --include=*.strings --include=*.xcstrings --include=*.storyboard --include=*.xib -i)"
[ -z "$terms" ] && finding "LIKELY REJECTION" "3.1.2" "No Terms of Use (EULA) link found — required in the paywall AND in App Store metadata (put it in the Description field)"

privacy="$(any_grep 'privacy.?policy' --include=*.swift --include=*.strings --include=*.xcstrings --include=*.storyboard --include=*.xib -i)"
[ -z "$privacy" ] && finding "LIKELY REJECTION" "3.1.2" "No privacy policy link found near the purchase flow"

# (2)(4) Duration + what the user gets per period.
duration="$(any_grep '(per (month|year|week)|/mo|/yr|monthly|yearly|annual|weekly|subscriptionPeriod)' --include=*.swift --include=*.strings --include=*.xcstrings -i)"
[ -z "$duration" ] && finding "RISK FLAG" "3.1.2" "No subscription length/duration wording found — the paywall must state title, duration, price per period, and what is provided"

# Auto-renew disclosure.
autorenew="$(any_grep '(auto.?renew|renews automatically|cancel any ?time)' --include=*.swift --include=*.strings --include=*.xcstrings -i)"
[ -z "$autorenew" ] && finding "RISK FLAG" "3.1.2" "No auto-renewal wording found in the paywall copy"

section "Family Sharing / entitlement handling"
family="$(src_grep 'isFamilyShareable|ownershipType')"
[ -z "$family" ] && finding "RISK FLAG" "3.1.2" "No Family Sharing handling (Product.isFamilyShareable / Transaction.ownershipType). Note: enabling Family Sharing in App Store Connect is IRREVERSIBLE."

section "External purchase links (Guideline 3.1.1(a) / 3.1.3)"
steering="$(src_grep '(openURL|UIApplication\.shared\.open|Link\().*(subscribe|upgrade|pricing|checkout|billing)' -i)"
if [ -n "$steering" ]; then
  while IFS= read -r line; do
    finding "RISK FLAG" "3.1.1(a)" "Possible steering link to an external purchase flow. Since May 1 2025 this is unrestricted on the US storefront only; elsewhere it needs an External Purchase Link entitlement or must be removed. Gate by storefront — $line"
  done <<< "$steering"
fi

summary
