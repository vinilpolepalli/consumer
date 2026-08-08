#!/usr/bin/env bash
# Shared helpers for app-store-approval scan scripts.
# Sourced by every scan_*.sh. Keep POSIX-friendly: these run on macOS (BSD grep)
# as well as GNU grep, so no -P / --perl-regexp anywhere.

ROOT="${1:-.}"

# Directories that are never the developer's own source.
EXCLUDES=(
  --exclude-dir=.git
  --exclude-dir=.claude
  --exclude-dir=Pods
  --exclude-dir=Carthage
  --exclude-dir=.build
  --exclude-dir=.swiftpm
  --exclude-dir=DerivedData
  --exclude-dir=build
  --exclude-dir=node_modules
  --exclude-dir=vendor
)

SRC_INCLUDES=(
  --include=*.swift
  --include=*.m
  --include=*.mm
  --include=*.h
  --include=*.c
  --include=*.cpp
  --include=*.kt
  --include=*.js
  --include=*.ts
)

FINDING_COUNT=0

# src_grep <extended-regex> [extra grep args...]
# Always returns 0 so `set -e` callers do not abort on "no matches".
src_grep() {
  local pattern="$1"; shift
  grep -rEn --binary-files=without-match "${EXCLUDES[@]}" "${SRC_INCLUDES[@]}" \
    "$@" -- "$pattern" "$ROOT" 2>/dev/null || true
}

# any_grep <extended-regex> [extra grep args...]  — all file types, not just source
any_grep() {
  local pattern="$1"; shift
  grep -rEn --binary-files=without-match "${EXCLUDES[@]}" \
    "$@" -- "$pattern" "$ROOT" 2>/dev/null || true
}

# finding <SEVERITY> <GUIDELINE-OR-ERROR-CODE> <message>
# SEVERITY is one of: HARD BLOCK | LIKELY REJECTION | RISK FLAG
finding() {
  FINDING_COUNT=$((FINDING_COUNT + 1))
  printf '[%s] %s :: %s\n' "$1" "$2" "$3"
}

section() { printf '\n=== %s ===\n' "$1"; }

summary() {
  if [ "$FINDING_COUNT" -eq 0 ]; then
    printf -- '-- clean (0 findings)\n'
  else
    printf -- '-- %s finding(s)\n' "$FINDING_COUNT"
  fi
}

# Path to the first PrivacyInfo.xcprivacy belonging to the app (not a pod).
find_privacy_manifest() {
  find "$ROOT" -name 'PrivacyInfo.xcprivacy' \
    -not -path '*/Pods/*' -not -path '*/Carthage/*' -not -path '*/.build/*' \
    2>/dev/null | head -1
}

# Path to the app's Info.plist (best effort: shortest path wins, test targets skipped).
find_info_plist() {
  find "$ROOT" -name 'Info.plist' \
    -not -path '*/Pods/*' -not -path '*/Carthage/*' -not -path '*/.build/*' \
    -not -path '*/build/*' -not -path '*Tests/*' -not -path '*/DerivedData/*' \
    2>/dev/null | awk '{ print length"\t"$0 }' | sort -n | cut -f2- | head -1
}
