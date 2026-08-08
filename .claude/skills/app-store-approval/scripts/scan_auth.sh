#!/usr/bin/env bash
# 4.8 Login Services + 5.1.1(v) Account Deletion + 5.1.1 forced login.
# Two of the highest-yield static checks: reviewers test the Delete Account
# button by hand, and third-party SSO without an equivalent private option is
# an automatic 4.8.
#
# Usage: scan_auth.sh [project-root]
set -uo pipefail
# shellcheck source=_common.sh
. "$(dirname "$0")/_common.sh"

section "Third-party login without a privacy-preserving option (Guideline 4.8)"

third_party="$(src_grep 'GIDSignIn|GoogleSignIn|FBSDKLoginKit|LoginManager\(\)|FBSDKCoreKit|TWTRLogIn|LineSDK|VKSdk|WXApi|KakaoSDK|NaverThirdPartyLogin')"
apple_signin="$(src_grep 'ASAuthorizationAppleID|SignInWithAppleButton|AuthenticationServices|ASAuthorizationController')"

if [ -n "$third_party" ]; then
  echo "third-party SSO detected:"
  echo "$third_party" | sed 's/^/  /'
  if [ -z "$apple_signin" ]; then
    finding "LIKELY REJECTION" "4.8" "Third-party login is offered with no equivalent privacy-preserving option. Add Sign in with Apple (name + email only, private relay, no tracking without consent) or drop third-party SSO."
  else
    echo "ok: Sign in with Apple present"
  fi
else
  echo "no third-party SSO detected"
fi

section "Account deletion (Guideline 5.1.1(v))"

creates_account="$(src_grep 'createUser|signUp|register(User|Account)?\(|createAccount|SignUpView|RegistrationViewController|auth\.createUser')"
if [ -z "$creates_account" ] && [ -z "$third_party" ] && [ -z "$apple_signin" ]; then
  echo "no account-creation flow detected — 5.1.1(v) likely does not apply"
else
  delete_ui="$(any_grep '(delete[ _]?account|deleteAccount|Delete My Account|closeAccount|DeleteAccountView)' --include=*.swift --include=*.m --include=*.strings --include=*.xcstrings --include=*.storyboard --include=*.xib -i)"
  if [ -z "$delete_ui" ]; then
    finding "HARD BLOCK" "5.1.1(v)" "The app creates accounts but no in-app account-deletion path was found. Sign-out, 'email support', or a web-only form do not satisfy this — reviewers press the button."
  else
    echo "account-deletion symbols found:"
    echo "$delete_ui" | sed 's/^/  /'
    # Deletion that only signs the user out is the classic re-rejection.
    fake_delete="$(src_grep 'func +deleteAccount' -A 12 | grep -iE 'signOut|logout|clearLocal|UserDefaults.*remove' || true)"
    if [ -n "$fake_delete" ]; then
      finding "LIKELY REJECTION" "5.1.1(v)" "deleteAccount() appears to only sign out / clear local state — deletion must remove the account server-side"
    fi
    server_call="$(src_grep 'func +deleteAccount' -A 12 | grep -iE 'delete\(|DELETE"|\.delete|deleteUser|revoke' || true)"
    if [ -z "$server_call" ]; then
      finding "RISK FLAG" "5.1.1(v)" "Could not confirm a server-side delete call in the deletion path — verify by hand that the account is actually removed"
    fi
  fi
fi

section "Forced login for non-account features (Guideline 5.1.1)"
guest="$(src_grep '(continueAsGuest|skipLogin|browseWithoutAccount|guestMode|isGuest|skipSignIn)' -i)"
if [ -n "$creates_account" ] && [ -z "$guest" ]; then
  finding "RISK FLAG" "5.1.1" "Account creation with no guest path detected. Content that does not require an account must stay reachable without login."
fi

section "Sign in with Apple — revocation handling"
if [ -n "$apple_signin" ]; then
  revoke="$(src_grep 'ASAuthorizationAppleIDProvider|credentialRevoked|getCredentialState|revokeAppleIDCredential')"
  [ -z "$revoke" ] && finding "RISK FLAG" "5.1.1(v)" "Sign in with Apple is used but no credential-revocation handling found — deleting the account should also revoke the Apple token (REST revoke endpoint)"
fi

summary
