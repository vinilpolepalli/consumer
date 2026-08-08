# What the factory needs from you (and exactly when)

The factory runs end-to-end without any of this — research, build, audit, marketing
kits, PRs all work today. Each item below unlocks one specific step. None are needed
to review the first app.

## Now worth doing (unlocks real users)

| # | What | Why | How to hand it over |
|---|---|---|---|
| 1 | **Static hosting token** — Vercel, Netlify, or Cloudflare Pages (free tier is fine) | Turns every merged app into a live URL automatically; a live URL is required before any reel can be filmed | Create the account, generate a deploy token, add it as a repo Actions secret named `DEPLOY_TOKEN`, and tell the orchestrator which provider |
| 2 | **A domain** (~$10/yr, one domain, subdomain per app: `sundays.yourdomain.app`) | Credibility in reels and App Store later | Buy it, point DNS at the host from #1 |

## When the first app has traffic

| # | What | Why | How to hand it over |
|---|---|---|---|
| 3 | **Stripe account** (or RevenueCat once native) | Turns the built-in paywalls into actual revenue; web payments avoid the 30% store cut | Create account, add `STRIPE_PUBLISHABLE_KEY` + a Payment Link per app; the paywall stubs are one function away |
| 4 | **TikTok + Instagram accounts** for the studio | The factory writes ready-to-film reel scripts (`apps/*/marketing/reels.md`); a human films/posts ~15 min each | Just create them; filming instructions are in each script |
| 5 | **Plausible/PostHog key** (optional) | Conversion data feeds the maintain squad's decisions | Add snippet config as `ANALYTICS_KEY` |

## When an app proves demand (App Store step)

| # | What | Why | How to hand it over |
|---|---|---|---|
| 6 | **Apple Developer account** ($99/yr) | Native App Store distribution via Capacitor wrap | Enroll at developer.apple.com; the vendored `app-store-approval` skill audits before every submission |
| 7 | **Anthropic API key** (only for AI-genre apps) | Unlocks the scanner/chat genres (Cal AI-style) which need a vision/LLM backend | Say the word; the factory will propose the cheapest architecture first |

## What stays human forever

- Merging PRs (you're the review gate — by design).
- Posting content to your social accounts.
- Anything involving your identity, payments setup, or legal terms.

## Honest expectations

Revenue depends on distribution actually happening (items 1, 2, 4) and on hit-rate —
most consumer apps make ~nothing, a few make everything; the factory's answer is
volume + marketing-first ideation, not certainty. No number here is a promise.
