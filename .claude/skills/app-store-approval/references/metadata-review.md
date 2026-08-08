# Metadata, review notes and the appeal process

Read this for 2.1 / 2.3 / 4.3 findings, and whenever the user has already been
rejected and needs to respond.

**Last verified: August 2026.**

---

## What reviewers check that no script can

| Item | Guideline | What "pass" looks like |
|---|---|---|
| Screenshots match the shipped build | 2.3 | Same UI, same features, no mockup frames claiming features that do not exist |
| Description matches the binary | 2.3 | No promised feature that is absent or gated |
| Demo account works | 2.1 | Credentials in App Review notes, account not expired, not rate-limited, works on a cold install |
| Age rating questionnaire | — | Answered under the 5-tier system (4+/9+/13+/16+/18+); social feeds force 13+ minimum from Sept 2026 |
| App Privacy labels match data flows | 5.1.1 | Every collected type declared, matching `PrivacyInfo.xcprivacy` |
| Support URL is live and has a contact route | 1.5 | Reachable page, real contact method |
| Privacy policy URL is live | 5.1.1(i) | Reachable, and also linked in-app |
| No references to other platforms | 2.3.10 | No "Android", "Google Play" anywhere |
| Icon/name do not use another developer's brand | 4.1(c) | Original branding |

## App Review notes — the template that prevents 2.1

```
DEMO ACCOUNT
  Username: reviewer@example.com
  Password: ********
  (Account is permanent, has sample data, and no rate limits.)

HOW TO REACH THE MAIN FEATURES
  1. Sign in with the demo account (or tap "Continue as guest").
  2. Tap + on the home screen to create a …
  3. The paywall appears under Settings → Upgrade.

THIRD-PARTY DATA SHARING
  Messages you send are processed by <Vendor, legal entity> (<product>).
  The consent screen appears on first launch and blocks all AI features until
  accepted. Privacy policy: <url>

HARDWARE / ACCOUNTS REQUIRED
  Bluetooth device not required — a simulator mode is included under
  Settings → Demo Mode.

WHY THIS APP IS NOT A DUPLICATE (if 4.3 has been raised before)
  <one paragraph naming the unique functionality>
```

Reviewers read these. Most 2.1 "Information Needed" rejections are answered
before they happen by a good notes field.

## 4.3 spam — what actually helps

- Do not publish near-identical binaries across your own account.
- Do not publish the same app to overlapping storefronts as separate listings.
- Name the unique functionality explicitly in the review notes.
- 4.3 has the highest false-positive rate of any guideline, and it is often
  auto-flagged within seconds of upload. If you are genuinely differentiated,
  appealing is reasonable — see below.

---

## The rejection response path

**1. Resolution Center (always start here).**
Rejections land in App Store Connect → Resolution Center. Reply there.
Typical turnaround **24–72 hours**; you get one reply thread per rejected build.
This clears most cases.

**2. Fix and resubmit — usually faster than arguing.**
In roughly 90% of fixable cases, correcting the issue and resubmitting beats
debating it. Make **surgical** fixes only: do not bundle unrelated changes into a
resubmission, because a new build re-opens every other guideline.

**3. App Review Board appeal — for genuine misapplication.**
One appeal per submission. No published timeline; forum reports run 2–3+ weeks.
Use it when you believe the guideline was applied incorrectly, not as a faster
retry.

**4. Phone call.** You can request one; useful for complex or repeatedly
misunderstood cases.

### Writing the Resolution Center reply

- Answer the exact guideline cited, in the first sentence.
- Say what changed, and where to see it ("Settings → Delete Account, third row").
- Attach a screenshot or a screen recording when the fix is visual — this is what
  resolves "consent screen not seen" loops.
- Do not argue precedent ("app X does this"). It does not work.
- If the rejection is a misunderstanding, say what the reviewer likely saw and
  why the app behaves differently — politely, once.

### When the user pastes a rejection notice

1. Find the cited guideline number in [rejection-db.md](rejection-db.md).
2. Apply the fix listed there.
3. Re-run the relevant scan to confirm the pattern is gone.
4. Draft the Resolution Center reply using the structure above.
5. Check whether the same root cause appears elsewhere in the app — reviewers
   re-reject on a second instance of the issue they just flagged (this is
   especially common with 5.2.2 AI assets: sweep the whole bundle, not the one
   file cited).
