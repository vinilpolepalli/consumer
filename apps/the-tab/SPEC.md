# The Tab — Product Spec

> Idea + spec bundle as delivered by the spec squad. Build target: `apps/the-tab/`.

## Idea

- **Name:** The Tab
- **One-liner:** Type any habit — DoorDash, lattes, vapes — and a slot-machine receipt reveals your lifetime tab, then flips it to the number that hurts: what it'd be worth by 65 if you'd invested it.
- **Viral reel script:** HOOK (0-1s, on-screen text, face-cam, sound-off legible): "I'm 24 and my DoorDash habit is apparently costing me $486,000." BEATS: (1) 1-4s screen-record: creator types "$19 DoorDash order", taps "4x a week", drags age slider to 24. (2) 4-7s: taps the big "RUN MY TAB" button — digits roll like a slot machine to LIFETIME TAB, then the screen flips with a haptic thud to the invested-by-65 number as a CVS-length receipt unrolls past the bottom of the frame. (3) 7-12s: hard cut back to face-cam — silent, hands on head (duet/stitch bait frame). (4) 12-15s CTA: "run your own tab. comment a habit and I'll run it next."
- **Why it spreads:** Death Clock formula ported to money: a shocking personalized number that exists for every viewer. The receipt card is a built-in 9:16 shareable artifact, "comment a habit" generates infinite creator follow-ups, and the invested-instead flip triggers frugality-war comment velocity.
- **Target user:** 18-30 TikTok natives with guilt-spend habits — fluent in "girl math" and "latte factor" discourse.
- **Core loop:** Run a tab (15 seconds) → slot-machine reveal → share/save receipt card → stack more habits into the Full Life Audit → daily "skipped it" check-in builds a save-streak converting skipped spending into a projected-wealth graph.
- **Monetization:** Free: one habit tab, the full reveal, invested-instead flip, shareable receipt card. Paywall at the stack moment. One-time lifetime unlock at $14.99 ("Pay once. A subscription would be ironic."). Unlock = unlimited stacked habits, combined Full Life Audit receipt, invested curve, quit-streak tracker with projected-wealth graph, premium receipt themes. Purchases stubbed behind `unlockPremium()`, labeled "Free during early access", never a fake charge.
- **Design notes:** Receipt aesthetic meets Liquid Glass. HONEST MATH ONLY: lifetime tab = cost × frequency × years to 65; invested-instead at 7% real annual return, labeled an estimate. Playful roast of the habit, never the person; essentials never roasted. Edge cases: absurd inputs accepted up to caps, $0/empty kind nudge, age ≥ 65 flips to 10-year framing.

---

## UX SPEC (v1 client-side PWA)

Target: `apps/the-tab/` — single-page, fully client-side, offline-capable PWA. Designed at 390×844, safe-area insets, tap targets ≥44px, no horizontal scroll, `prefers-reduced-motion` honored. iOS-first: system fonts, sheets not modals, chips not dropdowns, Liquid Glass on every screen.

### Design frame
- **The glass world** (app chrome): committed dark treatment, translucent glass controls (`backdrop-filter: blur(24px) saturate(180%)` + `-webkit-`), inset specular borders, continuous-corner radii 20–28px, floating glass bottom CTA bar, glass sheets. Solid fallback via `@supports not (backdrop-filter: blur(1px))`.
- **The receipt** (the artifact): warm off-white thermal paper, monospace, tabular numerals, perforated zigzag edges, thermal banding, dashed dividers, barcode footer. One layout source of truth shared by on-screen receipt and share exports.
- Voice: roast the habit, never the person; every projection labeled an estimate; the 7% disclaimer wherever the invested number appears; no fake urgency/social proof; anti-subscription identity.

### Flow
First launch → S1 Run a Tab → S2 Reveal (roll → flip → unroll) → S3 Receipt (settled) with Share sheet / Stack (paywall) / explainer / new tab. Return visits with ≥1 saved tab → S4 The Audit (home) with stubs, skipped-it check-in, wealth graph (premium), settings. No tab bar; zero interstitials; number on screen in under 15 seconds.

### S2 choreography (≤6s, silence-proof)
P0 print stub feeds from top (0.4s) → P1 odometer roll, columns settle left-to-right with haptic ticks (2s) → P2 hard stop + rounds sub-line (0.7s) → P3 flip with visual thud + `vibrate(30)` to the invested number counting up (0.5s) → P4 receipt unrolls line-by-line, auto-scroll (~2s) → P5 action bar. Reduced motion: full receipt fades in, no motion, haptics off. Re-runs replay a half-duration reveal; never gated.

### Receipt card exports
One renderer → on-screen receipt, 4:5 (1080×1350) and 9:16 (1080×1920) canvas exports → Web Share API with download fallback. Dark glass-gradient backdrop, receipt centered ~78%/70% width, 9:16 hero in middle 60% safe zone. Anatomy: perforated edge · THE TAB wordmark · store line · date/CUSTOMER: YOU · items (verbatim habit name) · LIFETIME TAB (26px bold) · rule · stamped hero block (IF INVESTED, 44px, 2° rotation, only tilted element) · roast line · 7% disclaimer (non-negotiable on every export) · barcode generated from habit-name char codes · footer tag (toggleable) · perforated edge. Never on the card: user's exact age, QR codes, fabricated comparisons. Thumbnail gate: wordmark + invested number + BY AGE 65 legible at 200px.

### Themes
Thermal (free, default) + premium: Carbon, Diner, Top Shelf. Locked themes visible with lock glyph; tapping opens paywall. Receipt paper never inverts with app appearance (paper has no dark mode).

### Paywall (House Account)
Trigger: only explicit taps on locked things (stack button, ghost stub, locked themes, locked graph). Never auto-presents. Glass sheet containing a receipt-styled offer: line items INCLUDED, `SUBSCRIPTION FEES $0.00 FOREVER`, TOTAL $14.99 charged once, "Pay once. A subscription would be ironic.", honest anchor line computed from the user's real inputs (suppressed under $14.99/month), CTA (`unlockPremium()` stub: "Free during early access — open it"), Restore link, no dark patterns. `Premium.isActive()` single gate; `premiumchange` event re-renders in place; lapse never deletes data.

### Home (S4)
Audit totals block (combined for premium), receipt-stub cards per habit with SKIPPED IT TODAY buttons, ghost stub (free) → paywall, wealth graph section (premium: real SVG curve of banked skips compounding at 7%; free: locked line), + RUN A NEW TAB (free = replace mode with confirm if skips exist; premium = add).

### Math contract (honest math only)
perYear: daily 365 · 5×/wk 260 · 4×/wk 208 · 3×/wk 156 · weekly 52 · 2×/mo 24 · monthly 12 · custom n×(365/52/12). years = max(0, 65−age); age ≥ 65 → 10-year horizon, "BY AGE {age+10}". lifetimeTab = cost × perYear × years. invested = FV of end-of-year annual contributions at 7% real: `annual × ((1.07^years − 1)/0.07)`. Overflow displays `$99,999,999+` + `PRINTER MAXED OUT.`; math stays honest in the explainer.

### Edge states
Empty name/cost → in-voice nudges, never red. Cost ≥ $2,000 → "That's not a habit, that's a payroll. Running it anyway." Cost > $99,999 → clamp + "The register stops at five digits a round." Essentials (rent, groceries, meds…) → no roast, neutral store line "EVERY DOLLAR COUNTED". Age untouched → readout "——", CTA disabled. Offline-first via sw.js; storage-disabled still runs in memory.

---

## BRAND SPEC (key contracts)

- Name stays **The Tab**; App Store display name `The Tab: Lifetime Receipt`.
- Voice: deadpan bartender. No exclamation points, no emoji, no advice, no banned AI-slop/finance-shame vocabulary. ALL-CAPS reserved for receipt lines.
- Glass tokens (dark): bg `#0C0E12`, ink `#F4F6F8`/`#A7AEBB`/`#6C7380`, glass `rgba(255,255,255,0.08)` + blur(24px) saturate(180%), tab red `#FF6B57`, gain green `#4ED99B`, CTA paper pill `#F8F4EA`/`#211F1A`. Light treatment provided; receipt themes independent of appearance.
- Receipt themes: Thermal `#F8F4EA`/`#211F1A`/`#C7381F`/`#0E7A4E` (free) · Carbon · Diner · Top Shelf (gold, invested double-underlined).
- Type: system mono (`ui-monospace, "SF Mono", Menlo`) with `tabular-nums` for receipt + all rolling numbers; system sans for chrome. CTA renders in mono caps: exactly `RUN MY TAB` (reel-script contract — never rephrase).
- Numbers: totals whole dollars with commas; unit cost keeps cents on receipt only; never round up for drama.
- Key strings shipped verbatim: `paywall` set ("One habit runs free. The whole tab is one payment." / "A subscription would be ironic." / "One-time purchase. No subscription. Ever."), roast tiers t1–t6 + `roast.essential`, `reveal.disclaimer`, receipt footer lines (`NO REFUNDS ON TIME`, `THANK YOU FOR YOUR HABITS`, `THE TAB — RUN YOURS`), streak copy (winning money back, never penance), settings/explainer copy, a11y announcements.

## MONETIZATION SPEC (key contracts)

- The reveal IS the ad: reveal, flip, unroll, and share card free forever, never watermark-degraded. Free/premium share cards pixel-identical in the free theme.
- Swap is free (one habit at a time, unlimited re-runs); **stacking** a second habit is the paid verb. One SKU: $14.99 lifetime, no tiers, no subscription ever.
- Free also gets: the "skipped it" button and won-back tally. Premium: streaks + projected-wealth graph, unlimited stacked habits, combined audit receipt, curve, premium themes.
- `unlockPremium()` stub contract: `PAYMENTS.keysPresent=false`; stub CTA "free during early access" (no deadline), confirmation says "unlocked", never "purchased/paid/charged"; no payment UI ever rendered while stubbed; early-access unlocks grandfathered; refund/lapse never deletes data; Restore re-reads localStorage while stubbed.
- Anti-dark-pattern checklist enforced: no countdowns, fake discounts, decoy tiers, guilt-copy declines, or auto-presenting paywalls.

## MARKETING SPEC (build requirements honored)

1. Slot-machine odometer roll, tabular-nums, 60fps at 390px, sound-off legible; static fallback under reduced motion.
2. Haptic flip as a distinct second beat with visual thud fallback; both numbers persist on the final receipt.
3. CVS-length unroll on the free tier.
4. "Run it again" replay from stored inputs (multi-take filming).
5. Free-text habit names printed verbatim; roast line on every receipt (creator's spoken line); preset chips for comment-farm habits.
6. Absurd inputs play along up to caps — no error states on camera; $0/empty and age ≥ 65 handled gracefully.
7. Unlimited free single-habit runs; paywall only at the stack moment.
8. **Duel mode (v1, free):** two tabs back-to-back → one VS receipt with both columns, verdict line, gap amount, invested-gap hero; shareable in both aspects.
9. Honest math labeled on the card and during the flip.
10. Offline, instant load, dark treatment, safe-area insets, Liquid Glass material.

---

## Implementation notes (as built)

- Single-file app: `index.html` (inline CSS/JS), `manifest.webmanifest`, `sw.js` (offline precache + network-first HTML), generated icons.
- State in `localStorage['thetab.v1']`; no network calls, no trackers.
- One receipt line-model feeds the DOM renderer and the canvas exporter (single source of truth).
- Deviations from spec text (deliberate, small):
  - Reveal-order receipt on screen (totals first, itemization below) so the money shot stays at the top of the live screenshot; exports use the canonical brand §6.6 order.
  - Stub "swipe to comp" replaced with an explicit `comp it` button (more accessible, no hidden gesture).
  - Brand's stepper-chips for frequency replaced with the UX spec's fixed chip set + Custom sheet (single-tap for the reel).
  - Premium theme set follows the brand spec (Carbon/Diner/Top Shelf), which supersedes the monetization spec's earlier names.
  - Skipped-it: free tier gets the working button + banked tally (monetization spec's free list), premium gets streak day counter, projection line, and the wealth graph.
