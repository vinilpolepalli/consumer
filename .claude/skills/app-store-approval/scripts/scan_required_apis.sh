#!/usr/bin/env bash
# ITMS-91053 / ITMS-91055 — required-reason API usage vs PrivacyInfo.xcprivacy
# Five categories, each with a fixed allowlist of approved reason codes.
# Source: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
#
# Usage: scan_required_apis.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

MANIFEST="$(find_privacy_manifest)"

section "Required-reason APIs vs privacy manifest (ITMS-91053)"

if [ -z "$MANIFEST" ]; then
  echo "note: no PrivacyInfo.xcprivacy found under $ROOT"
else
  echo "manifest: $MANIFEST"
fi

# category-key | detection regex | approved reason codes
CATEGORIES=(
"NSPrivacyAccessedAPICategoryUserDefaults|UserDefaults|NSUserDefaults|CA92.1, 1C8F.1, C56D.1, AC6B.1"
"NSPrivacyAccessedAPICategoryFileTimestamp|\.(creationDate|modificationDate)|contentModificationDateKey|creationDateKey|NSFile(Creation|Modification)Date|\bstat\(|fstat\(|getattrlist|DDA9.1, C617.1, 3B52.1, 0A2A.1"
"NSPrivacyAccessedAPICategorySystemBootTime|systemUptime|mach_absolute_time|NSSystemUptime|35F9.1, 8FFB.1, 3D61.1"
"NSPrivacyAccessedAPICategoryDiskSpace|NSFileSystemFreeSize|volumeAvailableCapacity|systemFreeSize|\bstatfs\(|85F4.1, E174.1, 7D9E.1, B728.1"
"NSPrivacyAccessedAPICategoryActiveKeyboards|activeInputModes|UITextInputMode|3EC4.1, 54BD.1"
)

for entry in "${CATEGORIES[@]}"; do
  category="${entry%%|*}"
  rest="${entry#*|}"
  codes="${rest##*|}"
  pattern="${rest%|*}"

  hits="$(src_grep "$pattern" -l)"
  [ -z "$hits" ] && continue

  files="$(echo "$hits" | tr '\n' ' ')"
  if [ -z "$MANIFEST" ]; then
    finding "HARD BLOCK" "ITMS-91053" "$category used ($files) but the app has no PrivacyInfo.xcprivacy at all. Approved reasons: $codes"
  elif ! grep -q "$category" "$MANIFEST" 2>/dev/null; then
    finding "HARD BLOCK" "ITMS-91053" "$category used ($files) with no matching NSPrivacyAccessedAPIType entry in $MANIFEST. Approved reasons: $codes"
  else
    # Category declared — verify the reason codes are ones Apple accepts for it.
    declared="$(grep -A 12 "$category" "$MANIFEST" | grep -oE '[0-9A-F]{4}\.[0-9]' | sort -u)"
    if [ -z "$declared" ]; then
      finding "HARD BLOCK" "ITMS-91055" "$category declared in $MANIFEST with no NSPrivacyAccessedAPITypeReasons values. Approved reasons: $codes"
    else
      while IFS= read -r code; do
        [ -z "$code" ] && continue
        case "$codes" in
          *"$code"*) : ;;
          *) finding "HARD BLOCK" "ITMS-91055" "Reason code $code is not valid for $category. Approved reasons: $codes" ;;
        esac
      done <<< "$declared"
    fi
  fi
done

section "Privacy manifest structure"
if [ -n "$MANIFEST" ]; then
  for key in NSPrivacyTracking NSPrivacyTrackingDomains NSPrivacyCollectedDataTypes NSPrivacyAccessedAPITypes; do
    grep -q "$key" "$MANIFEST" || \
      finding "RISK FLAG" "ITMS-91056" "$MANIFEST is missing the top-level key <$key> (all four keys are expected)"
  done
  # Tracking declared true but no domains listed.
  if grep -A 1 'NSPrivacyTracking<' "$MANIFEST" 2>/dev/null | grep -q '<true/>'; then
    grep -A 3 'NSPrivacyTrackingDomains' "$MANIFEST" | grep -q '<string>' || \
      finding "LIKELY REJECTION" "5.1.2" "NSPrivacyTracking is true but NSPrivacyTrackingDomains is empty — list every domain used for tracking"
  fi
else
  finding "RISK FLAG" "ITMS-91053" "No PrivacyInfo.xcprivacy found. Required if the app (or any bundled SDK) touches a required-reason API, collects data, or tracks."
fi

summary
