#!/usr/bin/env bash
# 2.5.1 HealthKit transparency + 5.1.3 health data handling.
# Real rejections run both directions: HealthKit used but not visible in the UI,
# and HealthKit linked (often dragged in by an SDK) with no health feature at all.
#
# Usage: scan_healthkit.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

section "HealthKit linkage vs actual health features (Guideline 2.5.1)"

hk_code="$(src_grep 'HKHealthStore|HKQuantityType|HKSample|import HealthKit')"
hk_entitlement="$(any_grep 'com\.apple\.developer\.healthkit' --include=*.entitlements --include=*.pbxproj --include=*.plist)"
hk_linked="$(any_grep 'HealthKit\.framework|HealthKit' --include=*.pbxproj)"

if [ -z "$hk_code" ] && [ -z "$hk_entitlement" ] && [ -z "$hk_linked" ]; then
  echo "no HealthKit usage detected"
else
  if [ -n "$hk_code" ]; then
    echo "HealthKit code found:"
    echo "$hk_code" | sed 's/^/  /'
    health_ui="$(any_grep '(health|fitness|workout|steps|heart rate|sleep|nutrition)' --include=*.strings --include=*.xcstrings --include=*.storyboard --include=*.xib -i)"
    [ -z "$health_ui" ] && finding "LIKELY REJECTION" "2.5.1" "HealthKit is used but no health/fitness feature is identifiable in user-facing strings — the health feature must be clearly identified in the app's UI and metadata"
  fi
  if [ -z "$hk_code" ] && { [ -n "$hk_entitlement" ] || [ -n "$hk_linked" ]; }; then
    finding "LIKELY REJECTION" "2.5.1" "HealthKit is linked/entitled but there is no HealthKit code — usually an SDK dragged it in. Strip the framework and entitlement, or ship a real health feature."
  fi
fi

section "Health data isolation (Guideline 5.1.3)"

if [ -n "$hk_code" ]; then
  ad_sdks="$(src_grep 'FBSDK|AppsFlyer|Adjust|Branch|Amplitude|Mixpanel|FirebaseAnalytics|GoogleMobileAds|TikTokBusiness|Segment')"
  if [ -n "$ad_sdks" ]; then
    finding "RISK FLAG" "5.1.3" "HealthKit and advertising/analytics SDKs coexist. Health data may not be used for advertising, marketing, or use-based data mining, nor sold to data brokers — verify by hand that no health value reaches these SDKs."
  fi
  icloud="$(src_grep 'NSUbiquitousKeyValueStore|CKContainer|NSPersistentCloudKitContainer|ubiquityIdentityToken')"
  if [ -n "$icloud" ]; then
    finding "RISK FLAG" "5.1.3" "HealthKit and iCloud storage coexist — personal health information must not be stored in iCloud"
  fi
  fake_write="$(src_grep 'HKHealthStore\(\)\.save|\.save\(.*HKQuantitySample')"
  if [ -n "$fake_write" ]; then
    echo
    echo "note: HealthKit writes detected — confirm only real user data is written (false/fabricated data is a 5.1.3 violation):"
    echo "$fake_write" | sed 's/^/  /'
  fi
fi

section "Unsubstantiated health measurement claims (Guideline 1.4.1)"
claims="$(any_grep '(measure|measuring|track|check).{0,25}(blood pressure|blood glucose|body temperature|oxygen saturation|SpO2|BPM|heart rate).{0,40}(camera|flash|sensor|phone|fingertip)' --include=*.swift --include=*.strings --include=*.xcstrings --include=*.md -i)"
if [ -n "$claims" ]; then
  while IFS= read -r line; do
    finding "LIKELY REJECTION" "1.4.1" "Claim to measure a vital sign with device sensors alone — Apple rejects these unless the accuracy claim is substantiated — $line"
  done <<< "$claims"
fi

summary
