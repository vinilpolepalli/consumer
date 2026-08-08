#!/usr/bin/env bash
# Submission artifacts that ARE visible from the repo: app icon, launch screen,
# export compliance, version keys, in-app Terms link, and whether a login flow
# means demo credentials are mandatory.
#
# Everything else on the App Store Connect side is in
# references/submission-artifacts.md and has to be asked, not scanned.
#
# Usage: scan_submission_readiness.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

PLIST="$(find_info_plist)"
PBXPROJ="$(find "$ROOT" -name 'project.pbxproj' -not -path '*/Pods/*' 2>/dev/null | head -1)"

# plist_has <key> — Info.plist or the generated-plist build settings
plist_has() {
  local key="$1"
  { [ -n "$PLIST" ] && grep -q "<key>${key}</key>" "$PLIST" 2>/dev/null; } && return 0
  { [ -n "$PBXPROJ" ] && grep -q "INFOPLIST_KEY_${key}" "$PBXPROJ" 2>/dev/null; } && return 0
  return 1
}

section "Required assets (ITMS-90022 / ITMS-90023)"

ICONSET="$(find "$ROOT" -type d -name 'AppIcon.appiconset' -not -path '*/Pods/*' 2>/dev/null | head -1)"
if [ -z "$ICONSET" ]; then
  finding "HARD BLOCK" "ITMS-90022" "No AppIcon.appiconset found — the upload is rejected for a missing app icon. Needs a 1024x1024 icon with no alpha channel."
else
  icons="$(find "$ICONSET" \( -name '*.png' -o -name '*.jpg' \) 2>/dev/null | head -1)"
  if [ -z "$icons" ]; then
    finding "HARD BLOCK" "ITMS-90022" "$ICONSET exists but contains no image files — an empty asset catalog entry still fails the upload"
  else
    echo "ok: app icon set found at $ICONSET"
  fi
fi

launch="$(find "$ROOT" \( -name 'LaunchScreen.storyboard' -o -name 'LaunchScreen.xib' \) -not -path '*/Pods/*' 2>/dev/null | head -1)"
if [ -z "$launch" ] && ! plist_has UILaunchScreen && ! plist_has UILaunchStoryboardName; then
  finding "LIKELY REJECTION" "2.1" "No launch screen found (LaunchScreen storyboard, UILaunchScreen or UILaunchStoryboardName) — required, and its absence reads as an unfinished app"
fi

section "Export compliance"

if plist_has ITSAppUsesNonExemptEncryption; then
  echo "ok: ITSAppUsesNonExemptEncryption declared"
else
  finding "RISK FLAG" "export-compliance" "ITSAppUsesNonExemptEncryption is not set. App Store Connect will ask the encryption questionnaire on every upload, and TestFlight builds sit at \"Missing Compliance\" so testers cannot be invited. Set it to false if the app only uses HTTPS/OS encryption."
fi

section "Version identifiers"

plist_has CFBundleShortVersionString || \
  finding "RISK FLAG" "2.1" "CFBundleShortVersionString not found — the marketing version must be set and must be higher than the last released version"
plist_has CFBundleVersion || \
  finding "RISK FLAG" "2.1" "CFBundleVersion not found — the build number must be unique per upload"

section "Demo credentials for login-gated apps (Guideline 2.1)"

login="$(src_grep '(signIn|logIn|login|createUser|signUp|createAccount)\(|LoginView|SignInView|SignUpView|AuthViewController')"
if [ -n "$login" ]; then
  finding "RISK FLAG" "2.1" "A login/account flow is present. App Review Information → Sign-in required must carry working demo credentials: permanent account, not rate-limited, reaching every gated feature including paid tiers. A reviewer who cannot sign in rejects under 2.1."
  echo "  login surfaces:"
  echo "$login" | sed 's/^/    /' | head -5
else
  echo "no login flow detected — demo credentials likely not required"
fi

section "Terms of Use reachable in-app"

terms="$(any_grep '(terms of (use|service)|termsURL|EULA|license agreement)' --include=*.swift --include=*.m --include=*.strings --include=*.xcstrings --include=*.storyboard --include=*.xib -i)"
if [ -z "$terms" ]; then
  finding "RISK FLAG" "3.1.2" "No Terms of Use / EULA link found in the app. Required in the paywall for subscription apps, and the link must also appear in App Store metadata — there is no dedicated field, so it goes in the Description."
fi

cat <<'EOF'

the rest of the submission checklist cannot be scanned — ask the user:
  demo credentials, privacy policy URL live, support URL contact method,
  App Privacy labels, age rating questionnaire, screenshots, IAP review
  screenshots, content rights, copyright.
See references/submission-artifacts.md.
EOF
summary
