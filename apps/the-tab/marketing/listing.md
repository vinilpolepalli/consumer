# The Tab — App Store listing

Researched against live listings and the web, August 2026. Three camps, none holding
our ground:

- **Web-only habit-cost calculators** — Compound Vice, HabitCalculator, Latte Factor
  calculators on financialmentor.com / moneyunder30.com. The exact mechanic exists as
  boring web forms with charts. Zero App Store presence, zero share artifact, zero
  personality. This is the strongest signal: proven search intent, no app owning it.
- **Compound interest calculator apps** — Compound Interest Pro, Investing Calculator,
  FIRE calculators. Own "compound interest"/"investing calculator". Spreadsheet energy,
  built for people who already invest. Self-serious; nothing to screenshot.
- **Quit-habit apps** — QuitVape, UnPuff, Quitty, Smoke Free. "Money saved" is a side
  stat inside a health journey. They own quit-intent but the money is a footnote, tied
  to one vice, and framed as recovery, not revelation.

**The gap:** the shock number + the invested flip + a shareable receipt, for ANY habit.
Nobody indexes hard on *habit cost, latte factor, spending calculator, girl math*. The
reels create the searches ("that receipt app", "lifetime tab app"); the listing's job is
to catch them plus the latent latte-factor intent that today dead-ends on websites.

Deliberate exclusions: "DoorDash" and other brand names are kept OUT of name/subtitle/
keywords (metadata trademark risk, 2.3.7 per the app-store-approval skill — the reels
can say it, the metadata can't). "budget"/"finance" head terms skipped: unwinnable
against Mint-class apps and wrong intent (we are not a tracker).

---

## Name (25/30 chars)

```
The Tab: Lifetime Receipt
```

Brand-spec contract (display name ships verbatim). "Lifetime" and "receipt" are also
honest keywords — "lifetime receipt" is the phrase the reels will teach.

## Subtitle (28/30 chars)

```
What your habit really costs
```

The whole pitch in five words, and it indexes *habit* + *cost* — the two terms every
web calculator proves people search. Cross-combines with keywords for "habit cost
calculator", "what my habit costs", "habit spending".

## Keyword field (100/100 chars)

```
spending,calculator,latte,factor,delivery,compound,interest,invest,money,savings,girl,math,quit,vape
```

No word duplicates name or subtitle (Apple cross-combines all three fields). Built
combinations we actually want: *spending calculator, habit calculator (subtitle+field),
latte factor, compound interest, compound interest calculator, invest calculator, money
math, girl math, savings calculator, quit vaping money, delivery spending, lifetime
tab (name+field).* Skipped: brand names (trademark risk), "app"/"free" (wasted),
plurals (Apple stems), "budget"/"tracker" (wrong intent, unwinnable).

## Description

First three lines carry everything — they render before "more":

```
Your $19 delivery habit, four times a week, is a $162,032 lifetime tab. Invested
instead, that money is $848,137 by age 65. The Tab runs the honest math on any
habit in fifteen seconds and prints it on a receipt made to be shown around.
```

Full description:

```
Your $19 delivery habit, four times a week, is a $162,032 lifetime tab. Invested
instead, that money is $848,137 by age 65. The Tab runs the honest math on any
habit in fifteen seconds and prints it on a receipt made to be shown around.

HOW IT WORKS
Type the habit — takeout, lattes, vapes, whatever you'd rather not add up. Tap
what one round costs and how often. The register rolls like a slot machine to
your lifetime tab, then flips to the number that actually hurts: what it would
be worth by 65 if you'd invested it instead.

HONEST MATH ONLY
Lifetime tab = cost x frequency x years to 65. The invested number assumes a 7%
real annual return — the long-run market average — and it is labeled an estimate
everywhere it appears. Nothing is rounded up for drama. No advice, no shame.
Arithmetic with a thermal-paper attitude.

THE RECEIPT IS THE POINT
Every run prints a lifetime receipt: perforated edges, barcode, a roast line
about the habit (never about you), the invested number stamped in green. Share
it straight to the group chat, story size or post size.

TAB DUEL
Run two habits back to back and get one VS receipt — both columns, the gap, a
verdict. Settle the coffee-versus-vape argument in writing.

ONE HABIT RUNS FREE. THE WHOLE TAB IS ONE PAYMENT.
Running a habit — the full reveal, the flip, the shareable receipt, the
skipped-it button that banks what you didn't spend — is free forever. One
payment of $14.99 unlocks the Full Life Audit: unlimited stacked habits, one
combined receipt, quit streaks with a projected-wealth graph, premium receipt
themes. No subscription. Ever. A subscription would be ironic.

Nothing you type leaves your phone. No account, no bank link, no tracking.

NO REFUNDS ON TIME.
```

Notes for submission time: the $162,032 / $848,137 figures match the shipped
screenshots exactly (2.3 metadata-match — keep them in sync if screenshots re-shoot).
The paywall paragraph assumes StoreKit is live; while `unlockPremium()` is stubbed this
listing cannot ship (AUDIT.md A1) — either wire IAP or strip the price paragraph.
Append Terms of Use / EULA link when IAP lands (3.1.2). Privacy label: Data Not
Collected.

## Screenshot captions

Order for the store — lead with the ad, not the form. Overlay text in the app's mono,
paper `#F8F4EA` on glass-dark `#0C0E12`:

| # | File | Caption |
|---|---|---|
| 1 | `screenshots/03-receipt.png` | **The tab you didn't know you were running.** |
| 2 | `screenshots/01-input.png` | **The habit, the cost, how often. Fifteen seconds.** |
| 3 | `screenshots/02-reveal-rolling.png` | **It rolls. Then it flips to the number that hurts.** |
| 4 | `screenshots/04-share.png` | **Made for the group chat. Story size or post size.** |
| 5 | `screenshots/05-paywall.png` | **One payment. A subscription would be ironic.** |
