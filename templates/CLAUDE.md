# CLAUDE.md — <repo>

Guidance for Claude Code working in this repo.

> **This file holds durable facts only.** Architecture, constraints, traps,
> access patterns. It is loaded automatically at session start and is almost
> never edited mid-work, which makes it the worst possible home for anything
> that changes. **No build status, no phase markers, no version numbers.**
> `baseline-check` fails a CLAUDE.md that carries them.
>
> | You want to know | Read |
> |---|---|
> | current phase, what shipped | `BUILD_PLAN.md` |
> | what is open right now | `PUNCHLIST.md` |
> | which tool versions apply | `.baseline.json` + the shared baseline |
> | what Joe has already decided | `~/dev/work/lawndart/.decisions/index.md` |

## Worklist — start here

Run `/orient`. It reads the four sources above in order and reports the deltas.

- **`PUNCHLIST.md` — canonical open work.** Every item typed
  **CODE / OWNER / DOCS / GROWTH**. **OWNER** means a console or config step an
  agent cannot perform.
- **`BUILD_PLAN.md` — the phased execution prompt** plus shipped history.

Close an item where you close the work: move it into `BUILD_PLAN.md`'s shipped
history in the same commit. There is no "prune later" pass — that is how a
punchlist grows to a thousand lines nobody reads.

**A finding in another repo does not get fixed from here.** File it on that
project's `PUNCHLIST.md` with `filed by the <this repo> session <date>` and a
`blocks:` marker if it gates work here — decision
`ld-2026-07-31-cross-repo-handoff-via-punchlist`. The PreToolUse boundary hook
enforces this; do not work around it.

## Toolchain

This repo declares its profile and any dated exceptions in `.baseline.json`.
Versions come from `platform/standards/baseline.json` — **do not restate them
here.** Check with:

```sh
python3 ~/dev/work/lawndart/platform/standards/bin/baseline-check . --quiet
```

An exception is debt with an expiry date, not permission. If you need one, say
so and add it with a real `until` and `reason`.

## LawnDart decision log

- **At session start, READ** `~/dev/work/lawndart/.decisions/index.md`. If
  `_state.json`'s `last_success` is more than 24h old, **say so**.
- **When Joe decides, WRITE a record** into `.decisions/records/`
  (id `ld-YYYY-MM-DD-<slug>`). Draft, confirm the wording, write. **Joe decides.**
- **Commit locally; never push.** The `SessionStart` hook owns pull and push.
- **Conflicts escalate, they don't resolve.**

## What this is

<one paragraph: what the repo does and who it serves>

## Architecture

<the shape. services, boundaries, what talks to what>

## Hard constraints

<the things that must not be violated, and why. be specific — "no latest tags"
beats "pin dependencies">

## Traps

<what has already bitten someone here. each one cost real time; that is why it
is written down>

## Working norms

- **Phased + gated:** stop at the end of each `BUILD_PLAN.md` phase, present
  results, wait for Joe's explicit approval.
- **Pushback welcome.** Sanity-check plans against ground truth. Prefer the
  simplest thing that fits the real workload; flag over-engineering.
- Surprises → stop and ask.

## Repo layout

<dir → purpose, one line each>
