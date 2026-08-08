#!/usr/bin/env bash
# Runs every scan against an iOS project and prints one combined report body.
#
# Usage: run_all.sh [project-root]
#   run_all.sh                 # audit the current directory
#   run_all.sh ~/dev/MyApp     # audit a specific project
set -uo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"

if [ ! -d "$ROOT" ]; then
  echo "error: $ROOT is not a directory" >&2
  exit 1
fi

echo "app-store-approval — static scans"
echo "project: $(cd "$ROOT" && pwd)"
echo "date:    $(date +%Y-%m-%d)"

# Project-type detection (step 1 of the SKILL workflow).
echo
echo "########## project detection ##########"
for f in '*.xcodeproj' '*.xcworkspace' 'Package.swift' 'Podfile.lock' 'Info.plist' 'PrivacyInfo.xcprivacy' 'pubspec.yaml'; do
  found="$(find "$ROOT" -maxdepth 3 -name "$f" -not -path '*/Pods/*' 2>/dev/null | head -3)"
  if [ -n "$found" ]; then
    echo "$found" | sed "s/^/  found: /"
  else
    echo "  missing: $f"
  fi
done

for s in scan_required_apis scan_sdks scan_plist scan_ai_endpoints scan_auth \
         scan_paywall scan_healthkit scan_functionality scan_placeholders \
         scan_submission_readiness; do
  echo
  echo "########## $s ##########"
  bash "$DIR/$s.sh" "$ROOT" || echo "(script exited non-zero — check output above)"
done

cat <<'EOF'

########## end of static scans ##########
Static analysis cannot judge: purpose-string quality, "ongoing value" of a
subscription, minimum functionality, spam/duplication, or metadata accuracy.
Finish with the manual checklist in SKILL.md.
EOF
