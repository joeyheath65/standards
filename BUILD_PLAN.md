# BUILD: toolchain standards

> **Progress:** ✅ Phase 1 (built, 9 enrolled) · ✅ Phase 2 (5 repos consuming `@v1`) ·
> ✅ Phase 3 (punchlist CLI, 11 items pruned, status stripped from CLAUDE.md) ·
> ✅ Phase 4 (branch protection, branch cleanup; commitlint deliberately skipped) ·
> ⬜ **Phase 5 next** — verify the guards actually trip. Baseline `2026-08-08`.
> Blocked on Joe: install the Renovate app (P2), and `lawndart-site` / `slotd-app`
> are his to enrol.

## Phases

**✅ ~~Phase 1 — Build the standards repo and enrol every project.~~**
_Done 2026-08-08 — baseline.json resolved from live sources; 6 profiles;
baseline-check + enroll; 3 reusable workflows; templates. Nine repos enrolled,
seven green, mx-campaign holding 2 deliberate violations. Six exceptions total,
all on slotd-web, all expiring 2026-11-30._

**✅ ~~Phase 2 — Wire the consumers.~~** Per repo: point `renovate.json` at the
shared preset, call `baseline.yml` + `node-ci.yml`, drop in `/orient`. Order:
gcp-autobot, agent-ready-kit, lawndart-tools, lawndart-site, lawndart-cloud,
slotd-mobile, mx-campaign, slotd-web. **GATE per repo.**

**✅ ~~Phase 3 — Doc gaps.~~** Strip mutable status from all nine CLAUDE.md files;
`punchlist` CLI (add/close/file); prune the 70 closed items still sitting in
punchlists; close the cross-repo handoff loop with `blocks:` markers.

**✅ ~~Phase 4 — Git practice.~~** Branch protection on main across nine repos;
branch cleanup (slotd-web 91, lawndart-site 25); commitlint; CI for the four
repos that have none.

**⬜ Phase 5 — Verify.** Break a repo deliberately; confirm all four consumers
catch it. A guard nobody has tripped is a hypothesis.

## Standing rules
- Enrolment never upgrades. Debt gets an expiry date, not a fix, until its own gate.
- Re-resolve versions from source when updating the baseline. Never from memory.
- Floors are coarse (major lines). Targets carry precision.

_Phase 2 done 2026-08-08 — gcp-autobot, agent-ready-kit, lawndart-tools, lawndart-cloud and
slotd-mobile all consume `@v1` for the baseline workflow and the Renovate preset. Three real
bugs in the reusable node-ci fell out of agent-ready-kit's first-ever CI run: `--if-present`
is npm-only, an empty `test-command` inlined via `${{ }}` is a bash syntax error, and the
actions were at v7 not v5/v6._

_Phase 3 done 2026-08-08 — `bin/punchlist` (add/close/file/ls); 11 closed items pruned into
shipped history across four repos, all now at zero; gcp-autobot's CLAUDE.md status block
removed, closing the four-phase contradiction that started this work._

_Phase 4 done 2026-08-08 — force-push and deletion blocked on main across five repos.
**Required status checks deliberately NOT enabled**: GitHub rejects direct pushes to a branch
with required checks, and Joe pushes to main constantly. The protection that helps a solo dev
is against destructive accidents, not against himself. Six merged local branches deleted from
lawndart-tools. **Commitlint deliberately skipped** — measured 93% conventional-commit
conformance on recent non-merge commits, with the misses being auto-generated merge commits
and initial scaffolding. A gate for a problem that does not exist._

## Shipped

- **P7** (2026-08-08) — **DOCS** — no tests for `baseline-check`. The `--today` flag exists
  _tests/test_baseline_check.py - precision, expiry, lockfile sync; run by self-test.yml_

- **P5** (2026-08-08) — **CODE — `clients/mx-campaign`** — two real violations left red on
  _moot - mx-campaign retired: billing unlinked, repo archived, deregistered_

- **P1** (2026-08-08) — **OWNER (next)** — **Create `github.com/joeyheath65/standards`, public,
  _github.com/joeyheath65/standards created public, pushed, tagged v1_

- **P6** (2026-08-08) — **DOCS** — `bin/punchlist` (add/close/file) does not exist yet;
  _bin/punchlist shipped; ids are allocated, close prunes into shipped history_
