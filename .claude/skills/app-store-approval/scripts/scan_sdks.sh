#!/usr/bin/env bash
# ITMS-91061 — third-party SDKs on Apple's list must ship a privacy manifest
# and a valid signature. Cross-references the project's dependency files against
# scripts/data/apple-sdk-manifest-list.txt.
#
# Usage: scan_sdks.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

LIST="$(dirname "$0")/data/apple-sdk-manifest-list.txt"

section "Third-party SDKs requiring a privacy manifest (ITMS-91061)"

if [ ! -f "$LIST" ]; then
  echo "error: SDK list not found at $LIST" >&2
  exit 1
fi

DEP_FILES="$(find "$ROOT" \
  \( -name 'Package.swift' -o -name 'Package.resolved' -o -name 'Podfile' \
     -o -name 'Podfile.lock' -o -name 'Cartfile' -o -name 'Cartfile.resolved' \
     -o -name 'pubspec.yaml' -o -name 'pubspec.lock' -o -name 'project.pbxproj' \) \
  -not -path '*/.build/*' -not -path '*/DerivedData/*' 2>/dev/null)"

if [ -z "$DEP_FILES" ]; then
  echo "note: no dependency manifests found under $ROOT"
  summary
  exit 0
fi

echo "dependency files scanned:"
echo "$DEP_FILES" | sed 's/^/  /'
echo

matched=""
while IFS= read -r sdk; do
  case "$sdk" in ''|'#'*) continue ;; esac
  while IFS= read -r depfile; do
    [ -z "$depfile" ] && continue
    if grep -qE "(^|[^A-Za-z0-9_])${sdk}([^A-Za-z0-9_]|$)" "$depfile" 2>/dev/null; then
      matched="${matched}${sdk}
"
      break
    fi
  done <<< "$DEP_FILES"
done < "$LIST"

if [ -z "$matched" ]; then
  echo "no listed SDKs detected"
  summary
  exit 0
fi

while IFS= read -r sdk; do
  [ -z "$sdk" ] && continue
  bundled="$(find "$ROOT" -ipath "*${sdk}*" -name 'PrivacyInfo.xcprivacy' 2>/dev/null | head -1)"
  if [ -n "$bundled" ]; then
    echo "ok: $sdk — manifest found at $bundled"
  else
    finding "HARD BLOCK" "ITMS-91061" "$sdk is on Apple's list but no bundled PrivacyInfo.xcprivacy was found for it — update to a version that ships one (signed), or remove the SDK"
  fi
done <<< "$matched"

cat <<'EOF'

note: dependencies that resolve at build time (SPM checkouts, un-installed Pods)
may not be on disk, so a missing manifest here is a prompt to check the vendor's
release notes — not proof of non-compliance. Binary dependencies additionally need
a valid signature.
Source: https://developer.apple.com/support/third-party-SDK-requirements/
EOF
summary
