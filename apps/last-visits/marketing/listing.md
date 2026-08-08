# Last Visits — App Store listing

Researched against live listings, August 2026. The field is split into three camps and
none of them own our ground:

- **Death Clock: The Life Lab** (id6499554412) — AI longevity/health. Owns "death clock",
  "life expectancy". Self-focused, clinical, health-data heavy.
- **Lifetime: Life Calendar**, **Life Time Left: 4K Weeks**, **Left: Widgets for Time Left** —
  memento-mori week grids about *your own* life. Widgets, stoic journaling. Self-focused.
- **Call Mom: Family Reminders**, **Hey Mom!** — pure reminder utilities. They have "call mom"
  intent but no emotional payload, no number, no share card.

**The gap:** the intersection of "a number about a specific person you love" and "the fix."
Nobody indexes hard on mom / parents / family visits / fly home. That's the whole ASO play.
We deliberately do NOT chase "death clock" — it's another app's brand, it pulls
wrong-intent traffic, and death vocabulary is banned everywhere in this product. The reel
sends high-intent traffic; the listing's job is to catch "app that shows how many times
you'll see your parents" searches the reels themselves create.

---

## Name (26/30 chars)

```
Last Visits: Time With Mom
```

"Mom" is the highest-volume family term and matches the reel hook verbatim. The app
suggests Mom and never forces her — Dad, Grandma, Amma, Abuela all work — and the
subtitle + keywords widen the net.

## Subtitle (21/30 chars)

```
See your parents more
```

Sells the promise (the fix, not the fear) and indexes "parents", "see", "more" —
combining with the name for "see mom more", "time with parents", "parents visits".

## Keyword field (100/100 chars)

```
family,dad,grandma,call,left,life,calendar,count,together,long,distance,reminder,tracker,streak,home
```

No word duplicates the name or subtitle (Apple cross-combines fields). Built combinations
we actually want: *time left, call mom, call dad, call home, fly home, visit home, family
calendar, life calendar, long distance family, family tracker, call reminder, visit count,
family time, streak.* Skipped: "death", "dying", "countdown" (brand-banned), "app"/"free"
(wasted), plurals Apple stems automatically.

## Description

First three lines carry everything — they render before "more":

```
You might see your mom about 14 more times. Or 200. The number depends on choices
you're making right now — and almost nobody has ever actually looked at it.
Two questions. Ten seconds. No account. Then the app shows you how to raise it.
```

Full description:

```
You might see your mom about 14 more times. Or 200. The number depends on choices
you're making right now — and almost nobody has ever actually looked at it.
Two questions. Ten seconds. No account. Then the app shows you how to raise it.

HOW IT WORKS
Tell us who you want more time with — Mom, Dad, Grandma, Amma, Abuela, anyone.
Tell us their age and, honestly, how often you see them. Last Visits turns public
life-expectancy averages into one honest estimate, drawn as a wall of dots: the
visits you've already had in amber, the visits still ahead in white.

Every number says "about." Every number is rounded up, in their favor, on purpose.
There's a plain-language explainer behind every result. This is an estimate for
deciding things — not a prediction.

THE NUMBER ISN'T FIXED
That's the point of the app. Slide the planner from "once a year" to "every couple
months" and watch dots re-ignite: +100 visits. Log a real visit or a call and a dot
lights with it. Keep a streak. Add the whole family to one wall.

FREE, ALWAYS
Your first person, the full reveal, the explainer, and a share card — free, no
account, and nothing you enter ever leaves your phone. More Time (premium) adds the
full planner, visit and call logging with streaks, the family wall, and extra card
themes.

Made for everyone living far from their people — one flight, one time zone, or one
busy calendar away.

You can change this number.
```

(When StoreKit lands, append Terms of Use / EULA link here — 3.1.2 requirement, see
AUDIT.md. Privacy policy + support URLs go in App Store Connect fields at that stage.)

## Screenshot captions

Order for the store (lead with the ad, not the form). Overlay text set in the app's
serif, ink-on-paper `#F4EFE6` on `#0F0E0C`:

| # | File | Caption |
|---|---|---|
| 1 | `screenshots/02-reveal.png` | **The number no one ever shows you.** |
| 2 | `screenshots/01-input.png` | **Two questions. Ten seconds. No account.** |
| 3 | `screenshots/06-planner.png` | **Change the pace. Watch the dots come back.** |
| 4 | `screenshots/05-home.png` | **Log a visit. Light a dot. Keep the streak.** |
| 5 | `screenshots/04-share-card.png` | **A card made for the group chat.** |
| 6 | `screenshots/03-paywall.png` | **The reveal is free. Always.** |
