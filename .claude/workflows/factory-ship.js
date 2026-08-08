export const meta = {
  name: 'factory-ship',
  description: 'Ship prep for a finished app: store-readiness audit, ASO listing, three ready-to-film reel scripts.',
  whenToUse: 'After factory-build passes QA. Required args: { slug: "app-dir-name" }',
  phases: [
    { title: 'Audit', detail: 'store-readiness + web-app compliance review' },
    { title: 'Marketing kit', detail: 'ASO listing, reel scripts, launch checklist' },
  ],
}

const ARGS = (typeof args === 'string') ? JSON.parse(args) : args

if (!ARGS || !ARGS.slug) throw new Error('factory-ship requires args: { slug }')
const appDir = `apps/${ARGS.slug}`

phase('Audit')
const audit = await agent(`Audit ${appDir} for ship-readiness as a PWA today and an App-Store-wrapped app later.
PWA now: manifest completeness (name, icons incl. 512px maskable, theme_color, display), service worker correctness, offline behavior, iOS installability (apple-touch-icon, status-bar meta), Lighthouse-style basics, privacy (no trackers, no external requests, a plain-language privacy note in-app).
App Store later: read .claude/skills/app-store-approval/SKILL.md and its references/rejection-db.md, then flag what a Capacitor wrap of this app would trip — 4.2 minimum functionality, 3.1.1 if payments go native, missing purpose strings, account deletion if accounts ever exist. Severity per that skill's model (HARD BLOCK / LIKELY REJECTION / RISK FLAG).
Write the report to ${appDir}/AUDIT.md and reply with the finding count by severity.`,
  { label: `audit:${ARGS.slug}`, phase: 'Audit' })

phase('Marketing kit')
const kit = await agent(`Produce the marketing kit for ${appDir} per your agent instructions: marketing/listing.md, marketing/reels.md (3 scripts), marketing/launch-checklist.md. Reply with a one-paragraph summary of the strongest reel.`,
  { label: `marketing:${ARGS.slug}`, phase: 'Marketing kit', agentType: 'aso-marketer' })

return { audit, kit }
