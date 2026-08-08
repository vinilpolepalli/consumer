# Playbook: work backwards from the marketing

The factory's ideation doctrine, operationalized from Roy Lee's advice. Every agent in
the research and build squads follows this. The failure mode it exists to prevent:
building "a scheduling app for your local college" — products with no distribution
story baked in.

## The doctrine

1. **The idea matters, and the idea is downstream of distribution.** Don't ask "what
   app should exist?" Ask "what 15-second video gets 5 million views?" — then build
   the app that video advertises.
2. **The reel comes first, shot-by-shot.** An idea is not admissible to the backlog
   without: the exact hook line (first 1.5 seconds), the visual beats, and the reason
   a viewer shares or screenshots it. If the reel is boring, the app is dead — stop.
3. **The result screen is the ad.** The app's output must be a beautiful, personal,
   screenshot-worthy card. Organic distribution means users do the marketing when
   they share their result. Design that screen first; the app is the machine that
   produces it.
4. **High-intent views beat big views.** A plant identifier is a "boring" app with a
   killer demo video. Boring-but-demoable beats clever-but-unfilmable, every time.
5. **$20k/month is the target, not $1B users.** Small, sharp, monetized utilities.
   Weekly/annual subscription or a one-time unlock, paywall moment designed on day
   one, price anchored to the emotional value of the result.
6. **Ship velocity is the moat.** A client-side PWA that ships this week beats a
   backend product that ships next quarter. If demand shows up, invest; if not, the
   next cycle starts tomorrow.

## The admissibility test (every idea must pass)

| Gate | Question | Kills the idea if |
|---|---|---|
| Hook | Does the reel stop a scroll in 1.5s? | You can't write the hook line |
| Share | Would a viewer screenshot/tag someone? | Result is generic, not personal |
| Demo | Can the app be demoed on camera in 10s? | Value needs explanation |
| Paywall | Is there a moment someone pays at? | All value is free or in the reel itself |
| Build | Polished v1 client-side in days? | Needs backend/ML/moderation/accounts for v1 |
| Fresh | New angle vs. existing viral apps? | Tired format with no twist |

## Design doctrine (non-negotiable since cycle 001)

These are **iOS apps**. Every screen uses Apple's **Liquid Glass** design language:
translucent layered materials with backdrop blur and saturation, specular edge
highlights, floating glass controls over scrolling content, glass sheets for
paywall and share moments, large continuous-corner radii, system typography.
Flat opaque cards and desktop idioms are rejected in critique. The shareable
result card must read as a native iOS artifact — the reel audience should think
"what app is that?" from the material alone.

## Idea sources (research squad sweeps these every cycle)

- App Store top charts: Top Free, rising utilities/lifestyle/health — what's breaking
  out and what reel format is fueling it.
- TikTok/IG search: "apps you didn't know you needed", "this app is scary accurate",
  app-demo formats trending this month.
- The proven genres, hunted for fresh angles: emotional calculators (Death Clock,
  time-with-parents), scanners/identifiers (Cal AI, plant ID), brutal-honesty raters
  (Umax), shareable identity cards (Wrapped-style, quizzes), couple/friend duo apps
  (tag-a-friend distribution built in).

## Reel formats that carry apps (write scripts against these)

1. **The gut-punch stat reveal** — "I found out how many Sundays I have left with my
   mom" → screen recording of the result forming → silence, no music, CTA in caption.
2. **POV demo** — hands + phone, "watch what happens when I point this at X".
3. **Brutal honesty** — the app rates/roasts something personal, creator reacts.
4. **Tag-a-friend result** — two-person result card, comment section does the work.
5. **Founder build-in-public** — "nobody believed this app idea, day 12, it hit #3 in
   Utilities" — works even before the app is big.

Every shipped app gets three ready-to-film scripts in its `marketing/` folder, one
per applicable format, written by the ship squad.
