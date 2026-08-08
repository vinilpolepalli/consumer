#!/usr/bin/env bash
# 5.1.2(i) — third-party AI data sharing requires disclosure + explicit consent
# BEFORE any personal data leaves the device. Added Nov 13, 2025; the single
# highest-value check for AI apps.
#
# Usage: scan_ai_endpoints.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

section "Third-party AI endpoints (Guideline 5.1.2(i))"

AI_PATTERN='api\.openai\.com|api\.anthropic\.com|generativelanguage\.googleapis\.com|api\.x\.ai|api\.mistral\.ai|api\.cohere\.(ai|com)|api\.together\.xyz|api\.groq\.com|api\.perplexity\.ai|openrouter\.ai|api\.deepseek\.com|bedrock-runtime|aiplatform\.googleapis\.com|openai\.azure\.com'
AI_SDK_PATTERN='import (OpenAI|OpenAIKit|Anthropic|SwiftAnthropic|GoogleGenerativeAI|LangChain)|AnthropicClient|OpenAIClient|GenerativeModel\(|ChatGPTAPI'

endpoints="$(src_grep "$AI_PATTERN")"
sdks="$(src_grep "$AI_SDK_PATTERN")"
config_hits="$(any_grep "$AI_PATTERN" --include=*.plist --include=*.json --include=*.xcconfig --include=*.yaml --include=*.yml)"

if [ -z "$endpoints" ] && [ -z "$sdks" ] && [ -z "$config_hits" ]; then
  echo "no third-party AI endpoints or SDKs detected"
  summary
  exit 0
fi

if [ -n "$endpoints" ]; then
  while IFS= read -r line; do
    finding "RISK FLAG" "5.1.2(i)" "AI endpoint call site — $line"
  done <<< "$endpoints"
fi

if [ -n "$sdks" ]; then
  while IFS= read -r line; do
    finding "RISK FLAG" "5.1.2(i)" "AI SDK import — $line"
  done <<< "$sdks"
fi

if [ -n "$config_hits" ]; then
  while IFS= read -r line; do
    finding "RISK FLAG" "5.1.2(i)" "AI endpoint in configuration — $line"
  done <<< "$config_hits"
fi

# --- Is there a consent gate at all? ---------------------------------------
consent="$(src_grep '(hasConsented|aiConsent|dataSharingConsent|privacyConsent|ConsentView|ConsentGate|didAcceptDataSharing|agreedToAIProcessing)')"
if [ -z "$consent" ]; then
  finding "LIKELY REJECTION" "5.1.2(i)" "AI data sharing detected with NO consent gate anywhere in source. Apple requires: what data is sent, who receives it (named), and explicit permission BEFORE the first transmission."
else
  echo
  echo "consent-related symbols found:"
  echo "$consent" | sed 's/^/  /'
fi

# --- The documented repeat-rejection trap ----------------------------------
if [ -n "$consent" ]; then
  seen_flag="$(src_grep '(hasSeen|didShow|alreadyShown|onboardingComplete|firstLaunch)[A-Za-z]*[[:space:]]*(&&|\|\|)')"
  if [ -n "$seen_flag" ]; then
    while IFS= read -r line; do
      finding "LIKELY REJECTION" "5.1.2(i)" "Consent logic combined with a 'seen/first-launch' flag — the documented cause of 8+ rejection loops (the reviewer never sees the screen). Gate on the consent value ALONE — $line"
    done <<< "$seen_flag"
  fi
fi

# --- Vendor named in user-facing copy? -------------------------------------
vendor_named="$(any_grep '(OpenAI|Anthropic|Gemini|Google AI|xAI|Mistral|Cohere|Perplexity)' --include=*.swift --include=*.strings --include=*.xcstrings --include=*.storyboard --include=*.xib --include=*.json)"
if [ -z "$vendor_named" ]; then
  finding "LIKELY REJECTION" "5.1.2(i)" "No third-party AI vendor is named anywhere in user-facing strings. The consent screen must identify WHO receives the data (e.g. \"Anthropic, PBC (Claude)\")."
fi

cat <<'EOF'

manual confirmation required (static analysis cannot verify these):
  1. The consent screen appears BEFORE the first network transmission of user data.
  2. It states WHAT data is sent and WHO receives it, by name.
  3. The privacy policy names the same vendors and confirms equal protection.
  4. The App Privacy nutrition labels match the actual data flow.
See references/privacy.md.
EOF
summary
