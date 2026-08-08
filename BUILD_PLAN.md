# BUILD: toolchain standards

> **Progress:** ✅ Phase 1 (repo built, 9 repos enrolled) · ⬜ **Phase 2 next**
> (wire Renovate + CI into each repo). Baseline `2026-08-08`.

## Phases

**✅ ~~Phase 1 — Build the standards repo and enrol every project.~~**
_Done 2026-08-08 — baseline.json resolved from live sources; 6 profiles;
baseline-check + enroll; 3 reusable workflows; templates. Nine repos enrolled,
seven green, mx-campaign holding 2 deliberate violations. Six exceptions total,
all on slotd-web, all expiring 2026-11-30._

**⬜ Phase 2 — Wire the consumers.** Per repo: point `renovate.json` at the
shared preset, call `baseline.yml` + `node-ci.yml`, drop in `/orient`. Order:
gcp-autobot, agent-ready-kit, lawndart-tools, lawndart-site, lawndart-cloud,
slotd-mobile, mx-campaign, slotd-web. **GATE per repo.**

**⬜ Phase 3 — Doc gaps.** Strip mutable status from all nine CLAUDE.md files;
`punchlist` CLI (add/close/file); prune the 70 closed items still sitting in
punchlists; close the cross-repo handoff loop with `blocks:` markers.

**⬜ Phase 4 — Git practice.** Branch protection on main across nine repos;
branch cleanup (slotd-web 91, lawndart-site 25); commitlint; CI for the four
repos that have none.

**⬜ Phase 5 — Verify.** Break a repo deliberately; confirm all four consumers
catch it. A guard nobody has tripped is a hypothesis.

## Standing rules
- Enrolment never upgrades. Debt gets an expiry date, not a fix, until its own gate.
- Re-resolve versions from source when updating the baseline. Never from memory.
- Floors are coarse (major lines). Targets carry precision.
