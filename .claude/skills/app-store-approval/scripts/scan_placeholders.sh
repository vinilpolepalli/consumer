#!/usr/bin/env bash
# 2.1 App Completeness + 2.3.10 (other marketplaces)
# Finds placeholder content, debug leftovers, test keys and Android references
# that reviewers routinely reject under Guideline 2.1.
#
# Usage: scan_placeholders.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

section "Placeholder / incomplete content (Guideline 2.1)"

# --- Placeholder copy -------------------------------------------------------
hits="$(src_grep '[Ll]orem ipsum|[Cc]oming soon|[Pp]laceholder text|TBD|Insert (text|copy) here|YOUR_[A-Z_]+_HERE|example\.com')"
if [ -n "$hits" ]; then
  while IFS= read -r line; do
    finding "LIKELY REJECTION" "2.1" "Placeholder content shipped in binary — $line"
  done <<< "$hits"
fi

# Also check localisable strings / storyboards / xibs / plists, where copy lives.
hits="$(any_grep '[Ll]orem ipsum|[Cc]oming soon|example\.com' --include=*.strings --include=*.storyboard --include=*.xib --include=*.plist --include=*.json --include=*.xcstrings)"
if [ -n "$hits" ]; then
  while IFS= read -r line; do
    finding "LIKELY REJECTION" "2.1" "Placeholder content in resources — $line"
  done <<< "$hits"
fi

# --- Unfinished work markers in user-facing strings -------------------------
hits="$(src_grep '(Text|Label|title|message|subtitle).*"(TODO|FIXME|XXX)[^"]*"')"
if [ -n "$hits" ]; then
  while IFS= read -r line; do
    finding "LIKELY REJECTION" "2.1" "TODO/FIXME rendered in UI — $line"
  done <<< "$hits"
fi

# --- Test / dummy credentials ----------------------------------------------
hits="$(src_grep 'sk_test_|pk_test_|sk-(test|proj)?-?[A-Za-z0-9]{16,}|AIza[0-9A-Za-z_-]{20,}|(api|API)_?[Kk]ey[[:space:]]*=[[:space:]]*"(test|dummy|xxx|changeme|1234)')"
if [ -n "$hits" ]; then
  while IFS= read -r line; do
    finding "LIKELY REJECTION" "2.1" "Test/dummy API key in shipping code (also a secrets leak) — $line"
  done <<< "$hits"
fi

# --- Debug switches left enabled -------------------------------------------
hits="$(src_grep '(isDebug|DEBUG_MODE|debugMode|showDebug|enableTestMode|isTestBuild)[[:space:]]*(=|:)[[:space:]]*(true|YES|1)')"
if [ -n "$hits" ]; then
  while IFS= read -r line; do
    finding "RISK FLAG" "2.1" "Debug flag hardcoded on — $line"
  done <<< "$hits"
fi

# --- Non-production endpoints ----------------------------------------------
hits="$(src_grep 'https?://(localhost|127\.0\.0\.1|10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.[0-9]+\.[0-9]+|[a-z0-9.-]*(staging|dev|test)\.[a-z]+)')"
if [ -n "$hits" ]; then
  while IFS= read -r line; do
    finding "LIKELY REJECTION" "2.1" "Non-production endpoint referenced — reviewer devices cannot reach it — $line"
  done <<< "$hits"
fi

section "References to other marketplaces (Guideline 2.3.10)"
hits="$(any_grep '(Google Play|Play Store|[Aa]vailable on Android|APK download|Amazon Appstore)' --include=*.swift --include=*.m --include=*.mm --include=*.strings --include=*.storyboard --include=*.xib --include=*.json --include=*.md --include=*.html --include=*.xcstrings)"
if [ -n "$hits" ]; then
  while IFS= read -r line; do
    finding "LIKELY REJECTION" "2.3.10" "Reference to another marketplace/platform in shipped content — $line"
  done <<< "$hits"
fi

section "Login gate without demo access (Guideline 2.1)"
login_hits="$(src_grep '(signIn|logIn|login)\(|LoginView|SignInView|AuthViewController')"
if [ -n "$login_hits" ]; then
  demo_hits="$(src_grep 'demo|guest|skipSignIn|continueAsGuest|browseWithoutAccount' -il)"
  if [ -z "$demo_hits" ]; then
    finding "RISK FLAG" "2.1" "Login flow found and no guest/demo path detected — supply demo credentials in App Review notes (see references/metadata-review.md)"
  fi
fi

summary
