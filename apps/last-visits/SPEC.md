# Last Visits — Build Spec (as given to the builder)

## Idea

- **Name:** Last Visits
- **One-liner:** Type your mom's age and how often you fly home; the app shows the shockingly small number of times you'll ever see her again — as a wall of dots you can't unsee — then shows you exactly how to raise the number.
- **Viral reel script:** HOOK (0-1s): Black screen, white text, muffled heartbeat audio: "You will see your mom 14 more times." BEAT 2 (1-4s): Screen recording — fingers type "Mom, 61" and tap "I see her about twice a year." BEAT 3 (4-8s): The app renders a grid of dots. Amber dots flood in fast (visits you've already had), then the animation stops and only 14 white dots remain, pulsing against a field of gray. A counter rolls down and freezes on 14. Slow zoom, no music. BEAT 4 (8-12s): Cut to creator's face lit by the phone in a dark room, silent, eyes glassy. On-screen text: "I call her every Sunday now." BEAT 5 (12-15s): Back in the app, they change "twice a year" to "once a month" and 9 gray dots re-ignite amber: "+9 visits." Text: "The number isn't fixed." CTA: "It's free to see your number."
- **Why it spreads:** Productizes the most proven stat in the genre (Jesse Itzler's parents-visits talking-head pulled ~4.9M likes with no app attached). Every viewer's number is different → reaction/duet format. Comment section becomes a grief ritual ("calling my mom rn"). The dot-grid card is a born screenshot: dark, minimal, one horrifying number. Diaspora/immigrant audiences (fly home once a year) make the math more brutal and are underserved.
- **Target user:** Adults 22-40 living away from their parents — especially immigrants and college-leavers who see family once or twice a year and carry low-grade guilt about it.
- **Core loop:** Log a visit or a call and a dot re-lights with a satisfying animation; call streak builds. Planner simulates "what if I visited every 2 months" and dots come back — the emotional reward loop is literally adding time with your parents. (Widget + push notifications are native-phase features, not v1 PWA.)
- **Monetization:** Free: one person (Mom), the full reveal, and one share card — the reveal must stay free because it IS the ad. Paywall immediately after the first reveal. Premium is the LOOP, not more arithmetic — the "change the math" planner, visit/call logging with streaks, the whole family as a family wall, premium card themes. $4.99/week w/ 3-day trial anchored against $29.99/year and $39.99 lifetime. All purchases stubbed behind unlockPremium() until payment keys exist.
- **Design notes:** TONE IS EVERYTHING: this app handles mortality-adjacent emotion. Framing is "this is about time, not death" — never mention death or dying; the number is "visits left", driven by honest life-expectancy math (approximate SSA period life tables, clearly labeled an estimate, slightly generous rounding). Include a gentle "why this number" explainer. Handle edge cases with care: very old parent ages, ages that imply the parent may be near end of life, user older than parent (reject kindly), absurd inputs. No fake precision, no fake urgency, no guilt-tripping copy — the number does the work; the app's voice stays warm and calm. The reveal animation IS the product: dots flood amber (visits already had), then the remaining white dots pulse. Counter rolls. The share card must be a beautiful dark minimal artifact with the dot grid, the number, and the app name small at the bottom.

---

## UX Spec (summary of the spec-squad document)

- Fully client-side PWA at `apps/last-visits/`, single `index.html`, committed dark theme, designed at 390×844, safe-area insets, tap targets ≥44px, no horizontal scroll.
- **Voice rules:** never say death/die/dying/gone/lost/"too late"/"running out"/countdown. Every number prefixed "about." No guilt, no urgency mechanics, one amber accent meaning *time together*. Recurring closing thought: "You can change this number."
- **Flow:** S1 Input (person chips, parent age hero stepper, optional user age with skip-estimate, frequency chips, bottom CTA) → S2 Reveal (amber flood → stillness → dim to ember → white dots ignite one-by-one and pulse → counter rolls down and freezes → actions fade in) → Sheet A "Why this number" / Sheet B Share card / Sheet C Paywall (auto-presents once ever, after dwell, never over another sheet) → S3 Home ("The Wall") → S4 Planner → S5 Logging & streaks → S7 Settings.
- **Grid:** shared layout function for reveal, thumbnails, planner, and card canvas. Scaling: ≤440 dots → 1 dot = 1 visit; ≤2200 → 1 dot = 5 visits (honesty label always visible); beyond → 1 dot = a month together (warm reframe).
- **Math:** embedded approximate SSA period life table (female/male anchors, blended for custom names), remaining years rounded up, visitsLeft = ceil(years × visitsPerYear), visitsSoFar estimated from (userAge − 18) × pace, everything labeled an estimate. Never expose e(x), target years, or dates.
- **Edge cases:** warm inline validation for impossible/very-close ages; parent 95–99 gets "read this as a floor" framing; parent 100+ never sees a number — dedicated "outrun the math" screen with free visit logging; skipped user age is estimated and labeled; `prefers-reduced-motion` gets a static reveal; offline-first via sw.js; delete-everything in Settings; the app never contradicts a user whose inputs imply a parent is no longer living — silence, not a feature.

## Brand Spec (summary)

- Keep the name **Last Visits**. Manifest description: "Count the visits you have left with the people you love. Then raise the number."
- Palette (dark): paper `#0F0E0C`, surface `#1A1815`, line `#2A2723`, ink `#F4EFE6`, ink-2 `#A69E90`, ink-3 `#6E675C`, amber `#E8A33D`, amber-deep `#C97F1D`, on-amber `#201503`, dot-left `#FFF8EC`, dot-rest `#2E2B26`, rose `#D98B7E` (errors, never red).
- Type: display serif ("New York", ui-serif, Georgia) for the number and headlines; system sans for everything else; tabular numerals mandatory.
- Card themes: **Ember** (free, dark default), **Ivory**, **Dusk**, **Grain** (premium).
- All user-facing strings specified in the brand doc are used verbatim or near-verbatim: input labels ("Honestly, how often do you see {name}?"), reveal copy ("About {n}. An estimate — and we rounded up on purpose."), explainer ("Where {n} comes from… The number can't predict anything. It's for deciding things."), paywall, planner ("It works in both directions. No judgment."), logging/streaks ("Streak started. Same time next week?"), settings, and the edge-case care section (`err.age_order`, `edge.95`, `edge.100` "…has outrun the math").
- Number rules: bare numeral; "about" in the supporting line; ceil at both steps ("rounded in {name}'s favor" literally true); zero never displayed; 100+ never sees a number; no gendered pronouns; no exclamation points; no emoji.

## Monetization Spec (summary)

- Premium tier: **More Time**. Free forever: one person, full reveal, explainer, edits/re-runs, Ember share card with unlimited shares. Premium: full planner + saved pace, visit/call logging with streaks, family wall, extra card themes.
- **Free taste:** the planner slider works exactly once for free (it is Beat 5 of the reel); the next intent raises the sheet. Auto-present at most once ever.
- Prices: $4.99/week (3 days free) preselected, $29.99/year ("Best value" — the only badge), $39.99 lifetime. Truth-labeled CTAs; while `PAYMENTS.enabled === false` the CTA is early-access free and no charge is ever faked.
- `unlockPremium(plan)` is the only purchase path; `Premium.isActive()` the only gate; all locked UI re-renders on `premiumchange`. Lapse never deletes or hides user data.
- Banned everywhere: countdowns, fake social proof, guilt copy, death vocabulary.

## Marketing Spec (summary — build requirements)

1. Cold open → reveal in ≤10s: two inputs, zero interstitials, no signup.
2. Reveal ≤6s: flood → deceleration → hard stop → white pulse → counter freezes; ≥2s still hold; silence-proof; dark always.
3. Planner recompute live; re-ignition dot-by-dot with floating "+N visits."
4. Log-a-call re-lights a dot and advances a visible streak.
5. Transform/opacity-only animations, 60fps, reduced-motion respected.
6. Chrome hides during reveal; number passes the 200px thumbnail test.
7. Card: canvas render, Web Share API + download fallback, both 4:5 and 9:16, human-readable math line ("about once a year × ~24 more years · an estimate"), app name small at bottom, no ages on the card.
8. Card variants: (a) reveal card, (b) "+N visits" delta card, (c) optional "What's your number?" tag toggle.
9. Frequency chips verbatim on the card: "Every few years", "Once a year", "Twice a year", plus "A few times a year", "Every couple months", "Monthly", "Weekly+".
10. Free-text relationship labels (Amma, Abuela, Nai Nai); "Mom" suggested, never forced.
11. Edge cases handled warmly on camera; two-reel arc supported (planner simulates without destroying the baseline).

## Deliberate deviations (documented)

- **Hook screen dropped:** the brand doc's standalone hook screen ("There's a number.") conflicted with the marketing hard requirement of zero interstitials before the reveal; S1 opens directly on "Who do you want more time with?".
- **"Unlock" wording avoided** in user-facing strings (brand banned-word list) even where the monetization doc's example CTAs used it; the code-level contract name `unlockPremium()` is kept as specified.
- **Life table:** Mom/Grandma → female table, Dad/Grandpa → male table, custom names → blended (UX-spec behavior; the brand doc's "always blended" rule applies to custom names where we never ask).
- **Logged-pace blend simplified:** the number recomputes from a saved plan only after a visit is logged after the plan was set (the honest-plan rule); the softer 24-month observed-pace blend is deferred.
- **Light theme deferred:** the UX spec commits to dark-only; the brand doc's light palette is not shipped in v1.
- **Parent age range:** 20–110 accepted (UX said 16–110, brand said 20–119; the life table is honest between 20 and 110).
