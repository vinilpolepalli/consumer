# consumer — the autonomous app factory

An agent-swarm business that continuously ideates, builds, and ships small consumer
apps, working backwards from viral marketing. Run and maintained by Claude Code;
reviewed by a human through pull requests.

**Start here → [FACTORY.md](FACTORY.md)** — architecture, pipeline, and the
continuous loop.

| Doc | What it is |
|---|---|
| [FACTORY.md](FACTORY.md) | The system: squads, workflows, the 24/7 cycle |
| [PLAYBOOK.md](PLAYBOOK.md) | The ideation doctrine: work backwards from the reel |
| [docs/IDEAS.md](docs/IDEAS.md) | Ranked idea backlog (regenerated every research cycle) |
| [docs/NEEDS-FROM-HUMAN.md](docs/NEEDS-FROM-HUMAN.md) | The short list of keys/accounts that unlock each next stage |
| [docs/SHIP-CHECKLIST.md](docs/SHIP-CHECKLIST.md) | Repo → live PWA → App Store path |
| [apps/](apps/) | The apps. Each is a self-contained, installable PWA |

## Machinery

- **Workflows** — [`.claude/workflows/`](.claude/workflows/): `factory-research`
  (recon → ideation → judges), `factory-build` (spec → build → 5-critic panel → QA),
  `factory-ship` (audit → marketing kit). Parameterized; a full cycle runs 20–30
  agents.
- **Agents** — [`.claude/agents/`](.claude/agents/): trend-scout, viral-ideator,
  app-builder, design-critic, qa-tester, aso-marketer.
- **Skills** — [`.claude/skills/app-store-approval/`](.claude/skills/app-store-approval/):
  vendored iOS submission audit (MIT, from
  [artbyjazi/app-store-approval](https://github.com/artbyjazi/app-store-approval)).

## Running an app locally

Every app is static — no build step:

```bash
python3 -m http.server 8000 --directory apps/<slug>
# open http://localhost:8000 (best at iPhone viewport, 390×844)
```
