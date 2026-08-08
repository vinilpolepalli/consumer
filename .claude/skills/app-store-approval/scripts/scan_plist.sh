#!/usr/bin/env bash
# 5.1.1 purpose strings / ITMS-90683 — every sensitive API needs a specific,
# non-generic NS*UsageDescription. Missing key = upload block. Generic string =
# review rejection.
#
# Handles both classic Info.plist files and Xcode's generated-plist build
# settings (INFOPLIST_KEY_* in project.pbxproj).
#
# Usage: scan_plist.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

PLIST="$(find_info_plist)"
PBXPROJ="$(find "$ROOT" -name 'project.pbxproj' -not -path '*/Pods/*' 2>/dev/null | head -1)"

section "Purpose strings (Guideline 5.1.1 / ITMS-90683)"
[ -n "$PLIST" ]   && echo "Info.plist: $PLIST"     || echo "note: no Info.plist found (Xcode may be generating it)"
[ -n "$PBXPROJ" ] && echo "pbxproj:    $PBXPROJ"

# usage-description key | API/framework detection regex | human name
CHECKS=(
"NSCameraUsageDescription|AVCaptureDevice|UIImagePickerController|\.camera\b|camera"
"NSPhotoLibraryUsageDescription|PHPhotoLibrary|PhotosPicker|photoLibrary|photo library (read)"
"NSPhotoLibraryAddUsageDescription|UIImageWriteToSavedPhotosAlbum|PHAssetCreationRequest|photo library (write)"
"NSMicrophoneUsageDescription|AVAudioRecorder|AVAudioSession|requestRecordPermission|microphone"
"NSLocationWhenInUseUsageDescription|CLLocationManager|requestWhenInUseAuthorization|location (when in use)"
"NSLocationAlwaysAndWhenInUseUsageDescription|requestAlwaysAuthorization|location (always)"
"NSContactsUsageDescription|CNContactStore|CNAuthorizationStatus|contacts"
"NSCalendarsUsageDescription|EKEventStore|calendar"
"NSRemindersUsageDescription|EKReminder|reminders"
"NSMotionUsageDescription|CMMotionManager|CMPedometer|CMMotionActivityManager|motion & fitness"
"NSHealthShareUsageDescription|HKHealthStore|requestAuthorization\(toShare|HealthKit read"
"NSHealthUpdateUsageDescription|HKHealthStore|toShare:|HealthKit write"
"NSBluetoothAlwaysUsageDescription|CBCentralManager|CBPeripheralManager|Bluetooth"
"NSSpeechRecognitionUsageDescription|SFSpeechRecognizer|speech recognition"
"NSFaceIDUsageDescription|LAContext|LAPolicy\.deviceOwnerAuthenticationWithBiometrics|Face ID"
"NSLocalNetworkUsageDescription|NWBrowser|NetService|Bonjour|local network"
"NSUserTrackingUsageDescription|ATTrackingManager|requestTrackingAuthorization|App Tracking Transparency"
)

# value_for <key> — looks in Info.plist first, then INFOPLIST_KEY_* in pbxproj
value_for() {
  local key="$1" val=""
  if [ -n "$PLIST" ]; then
    val="$(grep -A 2 "<key>${key}</key>" "$PLIST" 2>/dev/null \
      | grep -m1 -o '<string>.*</string>' | sed 's|<string>||; s|</string>||')"
  fi
  if [ -z "$val" ] && [ -n "$PBXPROJ" ]; then
    val="$(grep -m1 "INFOPLIST_KEY_${key}" "$PBXPROJ" 2>/dev/null \
      | sed 's/.*= *//; s/;$//; s/^"//; s/"$//')"
  fi
  printf '%s' "$val"
}

GENERIC='^(App|This app|The app|We)? ?(needs|need|requires|require|uses|use|would like)? ?(access|permission)|^access|^permission|^required|^needed|^for (better )?(experience|functionality)$'

for entry in "${CHECKS[@]}"; do
  key="${entry%%|*}"
  rest="${entry#*|}"
  label="${rest##*|}"
  pattern="${rest%|*}"

  used="$(src_grep "$pattern" -l)"
  [ -z "$used" ] && continue
  files="$(echo "$used" | tr '\n' ' ')"

  val="$(value_for "$key")"
  if [ -z "$val" ]; then
    finding "HARD BLOCK" "ITMS-90683" "$label API used ($files) but $key is missing — the upload is rejected before review"
  elif [ "${#val}" -lt 20 ]; then
    finding "LIKELY REJECTION" "5.1.1" "$key is too short to be specific (\"$val\") — name the feature, the benefit, and the data type"
  elif echo "$val" | grep -qiE "$GENERIC"; then
    finding "LIKELY REJECTION" "5.1.1" "$key reads as generic boilerplate (\"$val\") — say what the feature does with the data"
  fi
done

section "Privacy policy reachable in-app (Guideline 5.1.1(i))"
policy="$(any_grep '(privacy.?policy|privacyPolicyURL|privacyURL|/privacy-policy)' --include=*.swift --include=*.strings --include=*.xcstrings --include=*.storyboard --include=*.xib -i)"
if [ -z "$policy" ]; then
  finding "LIKELY REJECTION" "5.1.1(i)" "No in-app privacy policy link found. A policy in App Store Connect alone is not enough for data-collecting apps."
fi

section "App Transport Security"
if [ -n "$PLIST" ] && grep -A 1 'NSAllowsArbitraryLoads' "$PLIST" 2>/dev/null | grep -q '<true/>'; then
  finding "RISK FLAG" "2.1" "NSAllowsArbitraryLoads is true — expect a request to justify disabling ATS"
fi

summary
