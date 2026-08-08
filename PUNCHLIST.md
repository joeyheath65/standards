# standards — Punchlist

Canonical list of **open** work. Start here.

Legend: `[ ]` open · `[~]` partial/in-progress
**Type** CODE / OWNER / DOCS / GROWTH

**OWNER** items are console/config steps with no code — an agent cannot do them.
Closed items move to `BUILD_PLAN.md` shipped history in the same commit.

---

## 0 · Make the consumers real

- P1. `[ ]` **OWNER (next)** — **Create `github.com/joeyheath65/standards`, public,
  push, tag `v1`.** Until this exists, the Renovate preset path and every
  workflow `uses:` line resolve to nothing. Everything else in Phase 2 is
  blocked on it.
- P2. `[ ]` **OWNER** — **Install/authorise Renovate** on the account so the
  shared preset resolves for all nine repos.
- P3. `[ ]` **CODE** — Wire `inject.py` in the decision store to read
  `baseline.json` and report per-repo deltas at SessionStart.
- P4. `[ ]` **CODE** — PreToolUse guard beside `pretooluse_boundary.py` that runs
  `baseline-check --json` on a `package.json` write and asks before adding a
  below-floor dependency.

## 1 · Deliberate red

- P5. `[ ]` **CODE — `clients/mx-campaign`** — two real violations left red on
  purpose, both needing a deploy test on a client repo:
  `firebase-hosting.yml` runs **Node 18** (below floor; its own functions
  declare `engines.node: 22`), and `@types/node ^25.2.3` types a runtime that
  does not exist there. Fix together, verify the Firebase deploy, then re-check.

## 2 · Hygiene

- P6. `[ ]` **DOCS** — `bin/punchlist` (add/close/file) does not exist yet;
  Phase 3 depends on it. IDs are still hand-allocated until it lands.
- P7. `[ ]` **DOCS** — no tests for `baseline-check`. The `--today` flag exists
  precisely so expiry logic can be tested; nothing uses it yet.

---

## Known traps

- **Enrolment must never upgrade.** `enroll` records where a repo *is*. If it
  starts fixing things, it becomes a migration tool and nobody will run it.
- **Floors are coarse on purpose.** A patch-level floor (`15.5.23`) fails builds
  over noise. Floors gate major lines; targets carry the precision.
- **`.nvmrc` of `22` is a line pin, not `22.0.0`.** `below()` compares only as
  precisely as both sides were stated. Do not "fix" that into a strict compare.
- **The lockfile is the truth for what is installed.** A loose range whose lock
  resolves fine is a warning, not a violation — they are different defects.
