export const meta = {
  name: 'factory-build',
  description: 'Build one app from an idea: 4 parallel spec agents, builder implements, 5-critic panel, fix pass, QA gate with screenshots.',
  whenToUse: 'After factory-research picks a winner. Required args: { slug: "app-dir-name", idea: { name, one_liner, viral_reel_script, target_user, core_loop, monetization } }',
  phases: [
    { title: 'Spec', detail: 'UX, brand/copy, monetization, marketing angles in parallel' },
    { title: 'Build', detail: 'app-builder implements the PWA' },
    { title: 'Critique', detail: '5 critics, one lens each' },
    { title: 'Fix + QA', detail: 'builder applies fixes, qa-tester gates' },
  ],
}

const ARGS = (typeof args === 'string') ? JSON.parse(args) : args

if (!ARGS || !ARGS.slug || !ARGS.idea) throw new Error('factory-build requires args: { slug, idea }')
const slug = ARGS.slug
const idea = typeof ARGS.idea === 'string' ? ARGS.idea : JSON.stringify(ARGS.idea, null, 2)
const appDir = `apps/${slug}`

const SPEC_SCHEMA = { type: 'object', properties: { spec: { type: 'string' } }, required: ['spec'] }
const FINDINGS_SCHEMA = { type: 'object', properties: { findings: { type: 'array', items: { type: 'object', properties: { severity: { type: 'string', enum: ['blocker', 'should-fix', 'polish'] }, finding: { type: 'string' }, fix: { type: 'string' } }, required: ['severity', 'finding', 'fix'] } }, verdict: { type: 'string', enum: ['ship', 'fix-first'] } }, required: ['findings', 'verdict'] }

phase('Spec')
const SPECS = [
  { key: 'ux', prompt: `Write the UX spec for this app: screen-by-screen flow, the result-card design (this is the ad — describe it precisely: layout, typography intent, what data appears), input design, empty/edge states, install prompt placement. Mobile-first at 390px.` },
  { key: 'brand', prompt: `Write the brand + copy spec: app name check (short, sayable, not trademark-adjacent), color palette (exact hexes, light+dark), type choices from system/bundled fonts, and EVERY user-facing string — onboarding, inputs, result card, share CTA, paywall sheet. No AI-slop phrasing.` },
  { key: 'monetization', prompt: `Write the monetization spec: exactly what is free vs premium, the paywall trigger moment (at peak desire, after value is proven), price and framing, the paywall sheet contents, and how unlockPremium() stubs cleanly until payment keys exist. No dark patterns, no fake urgency.` },
  { key: 'marketing', prompt: `Write the marketing-angle spec: the 3 strongest reel angles for THIS app and what each needs from the product (e.g. a specific stat on the card, a dramatic reveal animation, a taggable duo mode). List product requirements marketing imposes — these are build requirements, not suggestions.` },
]
const specs = await parallel(SPECS.map(S => () =>
  agent(`App idea:\n${idea}\n\nTarget directory: ${appDir}\nRead PLAYBOOK.md and .claude/agents/app-builder.md for the quality bar first.\n\n${S.prompt}\n\nReturn the spec as markdown via StructuredOutput.`,
    { label: `spec:${S.key}`, phase: 'Spec', schema: SPEC_SCHEMA })
))
const specDoc = specs.filter(Boolean).map((s, i) => `# ${SPECS[i].key.toUpperCase()} SPEC\n${s.spec}`).join('\n\n---\n\n')

phase('Build')
await agent(`Build the app now. Idea:\n${idea}\n\nFull spec from the spec squad:\n${specDoc}\n\nCreate it in ${appDir}/ per your agent instructions (index.html with inline CSS/JS, manifest.webmanifest, sw.js, icons as inline-SVG-derived PNGs or a generated icon set). Also write ${appDir}/SPEC.md containing the spec you were given. Work until it meets the bar; then reply with what you built and any spec deviations.`,
  { label: `build:${slug}`, phase: 'Build', agentType: 'app-builder', effort: 'high' })

phase('Critique')
const LENSES = ['visual-design', 'copy', 'bugs', 'mobile-ux', 'monetization']
const critiques = await parallel(LENSES.map(lens => () =>
  agent(`Lens: ${lens}. App directory: ${appDir}. Review per your agent instructions and return findings via StructuredOutput.`,
    { label: `critic:${lens}`, phase: 'Critique', schema: FINDINGS_SCHEMA, agentType: 'design-critic' })
))
const allFindings = critiques.filter(Boolean).flatMap(c => c.findings)
const blockers = allFindings.filter(f => f.severity === 'blocker')
log(`Critique: ${allFindings.length} findings, ${blockers.length} blockers`)

phase('Fix + QA')
const fixList = allFindings.filter(f => f.severity !== 'polish').map((f, i) => `${i + 1}. [${f.severity}] ${f.finding}\n   Fix: ${f.fix}`).join('\n')
if (fixList) {
  await agent(`Apply these critic findings to ${appDir}. Use judgement — a critic can be wrong, but explain any finding you decline.\n\n${fixList}`,
    { label: `fix:${slug}`, phase: 'Fix + QA', agentType: 'app-builder', effort: 'high' })
}
const qa = await agent(`QA the app in ${appDir} per your agent instructions. Save screenshots to ${appDir}/screenshots/. Return findings via StructuredOutput — verdict "ship" only if the core loop, persistence, share flow, and offline reload all pass with zero console errors.`,
  { label: `qa:${slug}`, phase: 'Fix + QA', schema: FINDINGS_SCHEMA, agentType: 'qa-tester' })
if (qa && qa.verdict === 'fix-first') {
  const qaFixes = qa.findings.map((f, i) => `${i + 1}. [${f.severity}] ${f.finding}\n   Fix: ${f.fix}`).join('\n')
  await agent(`QA failed the build. Fix these in ${appDir} and verify locally:\n\n${qaFixes}`,
    { label: `fix2:${slug}`, phase: 'Fix + QA', agentType: 'app-builder', effort: 'high' })
}
return { appDir, findings: allFindings, qa }
