# standards — Punchlist

Canonical list of **open** work. Start here.

Legend: `[ ]` open · `[~]` partial/in-progress
**Type** CODE / OWNER / DOCS / GROWTH

**OWNER** items are console/config steps with no code — an agent cannot do them.
Closed items move to `BUILD_PLAN.md` shipped history in the same commit.

---

## 0 · Make the consumers real
- P1. `[ ]` **CODE** — **`punchlist close` silently truncates multi-line items — data loss.** `cmd_close` deletes the item's whole block from PUNCHLIST.md (via `body_of`) but builds the BUILD_PLAN entry from `block[0]` only, so every continuation line is destroyed. It hit `lawndart-site` on 2026-08-08 (commit `c5cb628`): six closures — P1 P7 P8 P11 P12 P18 — landed as sentence fragments and the reasoning was only recoverable from git. Fix: carry the full block into the shipped entry. Secondary: the entry is stamped `--today` (the run date) rather than the disposition date already present in the item text, which produced `(2026-08-08) — DONE 2026-08-05` on all six.
  *(Filed from a `lawndart-site` session 2026-08-11 as a cross-repo handoff — `ld-2026-07-31-cross-repo-handoff-via-punchlist`.)*

- P2. `[ ]` **CODE** — **The checker treats every package in a monorepo as its own repo, so a
  correctly-configured monorepo reports phantom structural gaps.** In `slotd-web` (4 packages,
  profiles declared per-package in `.baseline.json`) this produces **7 of its 42 warnings**, all
  false:

  | Warning | Reality |
  |---|---|
  | `[booking] workflows none -> want present (repo has no CI)` ×3 | The repo has **5 workflows** at root, including `baseline.yml@v1` and `renovate.yml@v1` — it is one of the best-enrolled repos in the fleet |
  | `[booking] .editorconfig missing` ×3 | Root `.editorconfig` exists |
  | `[firestore-tests] .gitignore missing` ×1 | Root `.gitignore` covers it — verified with `git check-ignore` |

  **Why it matters more than a miscount:** "repo has no CI" is the single most alarming line the
  tool emits, and here it is wrong three times in a repo whose CI is the standard's own gate. A
  check that cries wolf on its best citizen trains people to skim the output — which is exactly
  how the real warnings in the same list get missed. **Fix:** resolve repo-level structural checks
  (`workflows`, `.editorconfig`, `.gitignore`, and anything else that is a property of the *repo*)
  once at the repo root, not once per package. Only package-level facts (deps, `engines`, lockfile
  sync) should be evaluated per package.
  *(Filed from a `slotd-web` session 2026-08-11 — `ld-2026-07-31-cross-repo-handoff-via-punchlist`.)*

- P3. `[ ]` **CODE** — **No profile fits a Vite SPA, and no way to declare a runtime-pinned Node.**
  Two gaps found enrolling `slotd-web`; both make a deliberate choice read as unfixed debt.

  **(a) Missing `web-vite` profile.** `booking` and `dashboard` are React + Vite + Tailwind SPAs
  with no Next.js and no intention of adopting it. The nearest available profile is `web-next`, so
  they are enrolled there and permanently report `next absent -> want >=15.0.0` and
  `@tailwindcss/postcss absent -> want >=4.0.0` — **4 warnings demanding packages the app is
  designed not to have.** A profile that can only be satisfied by changing frameworks is not debt,
  and an exception does not fit either (the exception schema keys on a version `floor`, and the
  defect here is "absent", not "too old"). Wanted: a `web-vite` profile — React/Tailwind/TS/Vite
  floors, no Next, no Tailwind-v4 postcss requirement.

  **(b) Node cannot be pinned to a deployment runtime.** `slotd-web` deploys to Cloud Functions
  `nodejs22`, and its deploy workflow is a single job that builds the apps *and* runs
  `firebase deploy`, so CI's Node is deliberately equal to the GCF runtime. That yields 6
  permanent `node 22 -> want 24.19.0 (behind Active LTS)` warnings that **cannot be declared**:
  verified 2026-08-11 that adding `"node"` to `.baseline.json`'s `exceptions` has **no effect** —
  the Node/runtime check does not consult exceptions the way version checks do. So the one
  category where the platform, not the repo, sets the version is the one category with no way to
  record why. Wanted: either exceptions apply to the Node check too, or a profile-level
  `runtimePinned: true` that downgrades it to informational.

  ⚠️ **Both (a) and (b) are the same shape as an expired exception in reverse:** a warning that can
  never be actioned is indistinguishable from one nobody has gotten to yet, and it accumulates.
  `slotd-web` currently carries **11 warnings of the 39 remaining that no action can ever clear.**
  *(Filed from a `slotd-web` session 2026-08-11 — `ld-2026-07-31-cross-repo-handoff-via-punchlist`.)*

## 1 · Deliberate red

## 2 · Hygiene

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
