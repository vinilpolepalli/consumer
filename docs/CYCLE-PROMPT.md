# The cycle prompt

The exact instruction the scheduled Routine fires into the orchestrator session on
each tick. Kept here so it's versioned and reviewable; edit this file and ask the
orchestrator to update the Routine to match.

---

Factory cycle tick. You are the orchestrator of the app factory in this repo — read
docs/STATE.md first, then act:

1. **Tend the open PR(s).** CI failures, review comments, merge conflicts on factory
   branches: fix and push. A merged PR means that app is shipped — record it in
   docs/STATE.md and proceed to (3).
2. **Advance the in-flight app.** If the current app isn't through the pipeline
   (build → critique → QA → ship-prep, per FACTORY.md), run the next stage's
   workflow and push progress.
3. **Start the next app when the line is clear.** If no app is in flight: run the
   `factory-research` workflow (args.avoid = shipped + parked app names from
   STATE.md), pick the top-ranked idea with no fatal flaw, then run `factory-build`
   and `factory-ship` for it. Write docs/IDEAS.md (ranked backlog) and
   docs/RESEARCH-CYCLE-NNN.md. Commit, push, open a draft PR.
4. **Close the loop.** Update docs/STATE.md (cycle number, phase, current app, PR),
   commit, push. If anything needs a human (keys, accounts, a decision), say so in
   the PR description under "Needs from you" rather than blocking.

Rules: stay on `claude/` branches, draft PRs only, never push to main. One cycle =
visible progress committed to GitHub — never end a tick with uncommitted work.
