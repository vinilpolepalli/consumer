#!/usr/bin/env bash
# 4.2 Minimum Functionality, 1.2 User-Generated Content, 2.3.1 hidden features,
# 4.7 embedded mini apps / JS runtimes.
# These are the judgement-heavy guidelines — the script narrows where to look;
# the verdict is a human call.
#
# Usage: scan_functionality.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

section "Minimum functionality / webview wrapper (Guideline 4.2)"

webview="$(src_grep 'WKWebView|SFSafariViewController|UIWebView')"
if [ -n "$webview" ]; then
  swift_files="$(find "$ROOT" \( -name '*.swift' -o -name '*.m' \) -not -path '*/Pods/*' -not -path '*/.build/*' 2>/dev/null | wc -l | tr -d ' ')"
  native="$(src_grep 'WidgetKit|UNUserNotificationCenter|LAContext|ShareLink|UIActivityViewController|CoreData|SwiftData|CoreLocation|AVFoundation|HKHealthStore|StoreKit|BGTaskScheduler|CoreML' -l)"
  native_count="$(echo "$native" | grep -c . || true)"
  echo "WKWebView/SFSafariViewController present; source files: $swift_files; files using native frameworks: $native_count"
  if [ "$swift_files" -lt 15 ] && [ "$native_count" -lt 2 ]; then
    finding "LIKELY REJECTION" "4.2" "The app looks like a thin web wrapper (few source files, almost no native framework use). Apple rejects apps that are \"not particularly useful, unique, or app-like\" — add offline support, push, widgets, biometrics, share sheet, or another genuine native capability."
  else
    finding "RISK FLAG" "4.2" "Webview present alongside native code — confirm the native features are substantial enough that the app is not a repackaged website"
  fi
else
  echo "no webview usage detected"
fi

section "User-generated content moderation (Guideline 1.2)"

ugc="$(src_grep '(ChatView|MessageView|CommentView|FeedView|PostView|sendMessage|postComment|uploadPost|chatCompletion|streamMessage)' -l)"
if [ -n "$ugc" ]; then
  echo "UGC / chat surfaces detected in:"
  echo "$ugc" | sed 's/^/  /'
  report="$(any_grep '(report (content|user|post|abuse)|reportPost|reportUser|flagContent)' --include=*.swift --include=*.strings --include=*.xcstrings --include=*.storyboard -i)"
  block="$(any_grep '(block ?(user|account)|blockUser|blockedUsers|muteUser)' --include=*.swift --include=*.strings --include=*.xcstrings --include=*.storyboard -i)"
  filter="$(src_grep '(moderation|profanityFilter|contentFilter|OpenAIModeration|blocklist|bannedWords)' -i)"
  [ -z "$report" ] && finding "LIKELY REJECTION" "1.2" "UGC surface with no report-content mechanism"
  [ -z "$block" ]  && finding "LIKELY REJECTION" "1.2" "UGC surface with no block-user mechanism"
  [ -z "$filter" ] && finding "LIKELY REJECTION" "1.2" "UGC surface with no content filtering. Note: AI chat output counts as UGC."
  echo "reminder: 1.2 also requires published developer contact info and acting on reports within 24h."
else
  echo "no UGC surfaces detected"
fi

section "Hidden / dormant features (Guideline 2.3.1)"
toggles="$(src_grep '(remoteConfig|featureFlag|RemoteConfig\.|isFeatureEnabled|LaunchDarkly|kill_?switch|hiddenFeature)' -i)"
if [ -n "$toggles" ]; then
  gated="$(src_grep '(Locale\.current\.regionCode|storefront|countryCode|buildNumber|Date\(\) *[<>]).*([Ff]lag|[Ee]nabled|[Ff]eature)')"
  if [ -n "$gated" ]; then
    while IFS= read -r line; do
      finding "LIKELY REJECTION" "2.3.1" "Feature toggle keyed to region/date/build — undisclosed switchable functionality risks removal and account termination — $line"
    done <<< "$gated"
  else
    finding "RISK FLAG" "2.3.1" "Remote feature flags in use — document any reviewer-invisible functionality in the App Review notes"
  fi
fi

section "Embedded mini apps / JS runtimes (Guideline 4.7)"
js_runtime="$(src_grep 'JSContext|JavaScriptCore|evaluateJavaScript|hermes|JSCRuntime|CodePush|react-native-code-push')"
if [ -n "$js_runtime" ]; then
  finding "RISK FLAG" "4.7" "Embedded JS runtime / dynamic code loading detected. Since Nov 2025, HTML5/JS mini apps and mini games are explicitly in scope: they need age-restriction mechanisms and may not extend native APIs without Apple's approval."
fi

summary
