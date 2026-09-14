# standards

One toolchain baseline, consumed by every repo. Edit one file; everything else follows.

Built because nine repos drifted to three Next majors, six Tailwind versions and
seven TypeScript ranges while every `CLAUDE.md` claimed a standard in prose.
Prose does not stop drift.

## The idea

`baseline.json` is the single source of truth for versions. It has four consumers,
and none of them restate it:

| Consumer | How | Catches drift |
|---|---|---|
| Renovate | `"extends": ["github>joeyheath65/standards#v1"]` | continuously, as PRs |
| CI | `uses: joeyheath65/standards/.github/workflows/baseline.yml@v1` | at PR — the hard gate |
| SessionStart | the decision store reads this repo and reports your deltas | before you type |
| PreToolUse | the same `bin/baseline-check` | as a session writes a bad dep |

You update `baseline.json`, move the `v1` tag, and every repo rolls forward.

**Pin the `#v1` in the Renovate preset.** A bare `github>joeyheath65/standards`
resolves against the default branch, not the tag — so Renovate would follow
`main` while CI follows `v1`, and the tag would stop being the single rollout
lever. Both consumers must reference the same ref or the design leaks.

## floor vs target

**floor** — CI fails below it. A major line you must not be under.
**target** — what Renovate drives toward and new repos start at.

Floors are deliberately coarse (`15.0.0`, not `15.5.23`). A patch-level floor
fails builds over noise and trains people to ignore the check.

## Exceptions: nothing breaks on day one

A repo below floor does not fail. It declares dated, machine-readable debt:

```json
{
  "profile": "web-next",
  "exceptions": {
    "react": { "floor": "18.3.1", "until": "2026-11-30",
               "reason": "dashboard+booking on 18; RSC migration is its own build plan" }
  }
}
```

CI passes. `/orient` reports the count and what expires soon. An **expired**
exception fails harder than the original violation — that is what stops this
becoming a permanent amnesty.

Drift cannot get worse; existing debt is counted rather than hidden.

## Enrolling a repo

```sh
bin/enroll <repo> --profile web-next          # dry run, shows what it would do
bin/enroll <repo> --profile web-next --apply
```

Non-destructive by design: it converts today's violations into dated exceptions
and never upgrades anything. Structural gaps (no `.nvmrc`, `@types/node` not
matching the runtime, CI below floor) are reported as **must fix**, not
excepted — an exception for "you have no `.nvmrc`" would hide the work forever.

Burning debt down is separate, gated work. A migration disguised as a config
change is how you break nine builds in an afternoon.

## Checking

```sh
bin/baseline-check .            # full table
bin/baseline-check . --quiet    # only problems
bin/baseline-check . --json     # for hooks and CI
```

Exit `0` clean or warnings · `1` violation · `2` could not run.

Stdlib-only Python. A baseline check that needs a toolchain to tell you your
toolchain is wrong is a circular dependency.

## Profiles

| id | for |
|---|---|
| `web-next` | Next + React + Tailwind app |
| `node-lib` | TS library or monorepo package |
| `functions` | Firebase Cloud Functions (adds the GCF runtime check and its decommission dates) |
| `python-svc` | Python service or tool |
| `flutter-app` | Flutter app |
| `infra` | Terraform + Compose (no app runtime) |

Repos whose work lives entirely in sub-packages omit the root profile:

```json
{ "packages": { "booking": "web-next", "functions": "functions" } }
```

## AI models: `ai.gemini`

`baseline.json`'s `ai.gemini` block is the one place a Gemini model id is set.
No service hardcodes one.

```json
"ai": { "gemini": {
  "location": "global", "primary": "gemini-3.8-flash", "fallback": "gemini-3.7-flash",
  "warnDays": 60, "verified": "2026-09-14",
  "models": { "gemini-2.5-flash": { "stage": "ga", "retiresOn": "2026-10-16" }, "...": {} }
} }
```

- `primary` is the pinned model. It is deliberately not the `gemini-flash-latest`
  alias, which would silently change a live tool's behaviour and price.
- `fallback` must be a different model id. Both must be listed in `models`.
- `models[id].retiresOn` is the published retirement date, or `null` for none.
- `verified` is the date `primary` and `fallback` were last confirmed by live calls.

**How services consume it.** Each consuming deploy workflow checks out this repo at
`main` and sets three runtime env vars with `gcloud run deploy --update-env-vars`:

| Env var | From |
|---|---|
| `GEMINI_MODEL` | `ai.gemini.primary` |
| `GEMINI_FALLBACK_MODEL` | `ai.gemini.fallback` |
| `GEMINI_LOCATION` | `ai.gemini.location` |

Consumers read `main`, not `v1`: a model retirement is not a toolchain rollout.

**Changing a model** is a one-line PR here. Update `primary` or `fallback`, add the
new id to `models`, and bump `verified`. It reaches each service on that service's
next deploy.

**Enforcement.** `baseline-check` scans non-test source (`*.ts`, `*.tsx`, `*.js`,
`*.mjs`, `*.py`) in every enrolled repo, whatever its profile:

- a `gemini-<digit>…` literal is a **warning**, named by `file:line`;
- a literal whose `retiresOn` is within `warnDays` is a **warning**, and on or past it a
  **violation**;
- `primary` and `fallback` get the same retirement test, but only in repos that
  reference Gemini (a literal, or `GEMINI_MODEL` in source or workflows). Repos with no AI
  stay quiet.

## Reusing this outside Lawn Dart

Nothing in the machinery is Lawn Dart specific — the org name appears only in
the Renovate preset path and the workflow `uses:` line. Fork it, replace
`baseline.json`, keep everything else. Add a profile rather than a fork when the
version table is shared and only the checks differ.

## Three files, three lifecycles

| file | answers | changes when |
|---|---|---|
| `baseline.json` | *which version* | a version ships |
| `platform.json` | *which thing to build on* | you change your mind about architecture |
| `inventory.json` | *what you actually have* | you buy, cancel, or set something up |

Keeping them separate is deliberate. Folding the resource inventory into the
version table would mean editing a versions file to record that you switched
registrar.

`inventory.json` exists because sessions guess. Its most useful section is
`doesNotHave` — most bad guesses are a capability being assumed that was never
set up, and a positive list alone never catches those.

`platform.json` does not pick your database. Data-store choice is a per-project
business and architecture decision made on that project's facts
(`ld-2026-08-08-relational-split-by-role`). What it encodes is the failure mode
to avoid — relational shapes forced into a document store with the joins
papered over in application code — and, once you are relational, the role split:
Cloud SQL when the store is authoritative, Supabase when it is derived.

## Layout

```
baseline.json            the version table — the file you edit
platform.json            what to build on: stores, compute, auth, secrets, DNS
inventory.json           what exists: GCP, Workspace, domains, models, homelab
default.json             shared Renovate preset
profiles/                which checks apply to which kind of repo
bin/baseline-check       the checker (terminal, CI, and hook all call this)
bin/enroll               non-destructive enrolment
.github/workflows/       reusable: baseline, node-ci, python-ci
templates/               CLAUDE.md, PUNCHLIST.md, orient.md, editorconfig
```

## Updating the baseline

1. Re-resolve versions from source — never from memory. `baseline.json`'s
   `sources` block lists exactly where each number comes from.
2. Record the change as a decision (`ld-YYYY-MM-DD-<slug>`).
3. Move the `v1` tag.
4. Renovate opens the PRs.

Held items (`held` in `baseline.json`) carry a reason and a review date. Today:
TypeScript 7 (native compiler rewrite, one month old) and Node 26 (Current, LTS
2026-10-28). Both review 2026-11-01.
