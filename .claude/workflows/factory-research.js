export const meta = {
  name: 'factory-research',
  description: 'One research cycle: trend recon, reel-first ideation across 5 lenses, 3-judge scoring. Returns a ranked idea backlog.',
  whenToUse: 'Run at the start of every factory cycle that needs a new app idea. Optional args: { theme: "focus area", avoid: ["names of apps already built or rejected"] }',
  phases: [
    { title: 'Recon', detail: '5 trend scouts in parallel' },
    { title: 'Ideate', detail: '5 viral ideators, one lens each' },
    { title: 'Judge', detail: '3-judge scoring panel' },
  ],
}

const theme = (args && args.theme) || 'open — hunt broadly'
const avoid = (args && args.avoid && args.avoid.join(', ')) || 'none yet'

const RECON_SCHEMA = { type: 'object', properties: { findings: { type: 'array', items: { type: 'object', properties: { fact: { type: 'string' }, source: { type: 'string' }, relevance: { type: 'string' } }, required: ['fact', 'relevance'] } }, summary: { type: 'string' } }, required: ['findings', 'summary'] }
const IDEAS_SCHEMA = { type: 'object', properties: { ideas: { type: 'array', items: { type: 'object', properties: { name: { type: 'string' }, one_liner: { type: 'string' }, viral_reel_script: { type: 'string' }, why_it_spreads: { type: 'string' }, target_user: { type: 'string' }, core_loop: { type: 'string' }, monetization: { type: 'string' }, buildable_without_api_keys: { type: 'boolean' }, build_effort_days: { type: 'number' }, existing_competitors: { type: 'string' } }, required: ['name', 'one_liner', 'viral_reel_script', 'why_it_spreads', 'target_user', 'core_loop', 'monetization', 'buildable_without_api_keys', 'build_effort_days'] } } }, required: ['ideas'] }
const SCORE_SCHEMA = { type: 'object', properties: { scores: { type: 'array', items: { type: 'object', properties: { idea_name: { type: 'string' }, score: { type: 'number' }, reasoning: { type: 'string' }, fatal_flaw: { type: 'string' } }, required: ['idea_name', 'score', 'reasoning'] } } }, required: ['scores'] }

phase('Recon')
const RECON_TASKS = [
  { key: 'charts', task: 'Current iOS App Store top charts and breakout consumer apps: what simple apps are charting, which categories indies break into, pricing, saturated vs open niches.' },
  { key: 'viral-formats', task: 'Reel formats getting millions of views for consumer apps on TikTok/IG right now: hook structures, named examples, why they work.' },
  { key: 'case-studies', task: 'Fresh case studies of viral consumer apps (growth channel, revenue, pricing, the viral video format). Include apps that broke out in the last 6 months.' },
  { key: 'monetization', task: 'Current consumer subscription benchmarks: paywall conversion for social-video traffic, weekly vs annual pricing, web-to-app funnels, realistic indie revenue examples.' },
  { key: 'buildability', task: 'Which viral consumer app concepts are fully buildable client-side (no backend, no AI keys) vs not; PWA installability on iOS today; App Store 4.2 minimum-functionality bar for simple utilities.' },
]
const recon = await parallel(RECON_TASKS.map(r => () =>
  agent(`Research task: ${r.task}\nTheme for this cycle: ${theme}. Already built/rejected (skip): ${avoid}.\nReturn findings via StructuredOutput.`,
    { label: `recon:${r.key}`, phase: 'Recon', schema: RECON_SCHEMA, agentType: 'trend-scout' })
))
const reconDigest = recon.filter(Boolean).map((r, i) => `## ${RECON_TASKS[i] ? RECON_TASKS[i].key : i}\n${r.summary}\n` + r.findings.map(f => `- ${f.fact} (${f.source || 'no source'}) — ${f.relevance}`).join('\n')).join('\n\n')

phase('Ideate')
const LENSES = [
  { key: 'emotional-time', lens: 'Emotional time/mortality/family math — a life statistic becomes a gut-punch visual.' },
  { key: 'self-improvement', lens: 'Self-improvement and glow-up — streaks, discipline, brutal-honesty ratings.' },
  { key: 'money', lens: 'Money and spending — shocking personalized number reveals.' },
  { key: 'relationships', lens: 'Relationships and social — two-person results people tag each other in.' },
  { key: 'identity-fun', lens: 'Identity and shareable cards — Wrapped-style personal reports everyone wants.' },
]
const ideation = await parallel(LENSES.map(L => () =>
  agent(`Your lens: ${L.lens}\nTheme: ${theme}. Already built/rejected (do not repeat): ${avoid}.\n\nResearch digest:\n${reconDigest}\n\nPropose exactly 3 ideas per your agent instructions (reel first, admissibility test, ≥2 of 3 fully client-side). Return via StructuredOutput.`,
    { label: `ideate:${L.key}`, phase: 'Ideate', schema: IDEAS_SCHEMA, agentType: 'viral-ideator' })
))
const allIdeas = ideation.filter(Boolean).flatMap(r => r.ideas)
log(`${allIdeas.length} ideas generated; judging`)

phase('Judge')
const ideaSheet = allIdeas.map((i, n) => `### ${n + 1}. ${i.name}\n${i.one_liner}\nReel: ${i.viral_reel_script}\nSpreads: ${i.why_it_spreads}\nUser: ${i.target_user}\nLoop: ${i.core_loop}\nMonetization: ${i.monetization}\nClient-side v1: ${i.buildable_without_api_keys} | Effort: ${i.build_effort_days}d\nCompetitors: ${i.existing_competitors || 'unknown'}`).join('\n\n')
const JUDGES = [
  { key: 'virality', prompt: 'Judge ONLY organic viral potential: would the reel stop scrolls? Is the result screen screenshot-bait? Penalize tired formats.' },
  { key: 'monetization', prompt: 'Judge ONLY money: real paywall moment, would social traffic convert, defensible price. Penalize all-value-free ideas.' },
  { key: 'buildability', prompt: 'Judge ONLY speed-to-ship for a client-side PWA: polished v1 in days, no hidden complexity, no legal sensitivity. Reward "90% one great screen".' },
]
const judged = await parallel(JUDGES.map(J => () =>
  agent(`You are a ruthless judge. ${J.prompt}\nScore EVERY idea 0-10 with reasoning; name fatal flaws.\n\n${ideaSheet}\n\nReturn via StructuredOutput.`,
    { label: `judge:${J.key}`, phase: 'Judge', schema: SCORE_SCHEMA })
))
const scoreMap = {}
for (const j of judged.filter(Boolean)) for (const s of j.scores) {
  if (!scoreMap[s.idea_name]) scoreMap[s.idea_name] = { total: 0, n: 0, flaws: [] }
  scoreMap[s.idea_name].total += s.score
  scoreMap[s.idea_name].n += 1
  if (s.fatal_flaw) scoreMap[s.idea_name].flaws.push(s.fatal_flaw)
}
const ranking = Object.entries(scoreMap).map(([name, v]) => ({ name, avg: v.total / v.n, flaws: v.flaws })).sort((a, b) => b.avg - a.avg)
return { reconDigest, allIdeas, ranking }
