---
description: Orient in this repo before doing any work.
---

Orient. Read in this order, then report. Do not start work until this is done.

1. `CLAUDE.md` — durable facts only. **If it contains a build status, phase
   marker, or version claim, that is a defect**: report it and offer to move
   the content to `BUILD_PLAN.md`. Status does not live in CLAUDE.md.
2. `BUILD_PLAN.md` — the phased prompt and shipped history. Current phase and
   next gate come from here and nowhere else.
3. `PUNCHLIST.md` — open work. Note anything marked `filed by the <x> session`
   (a cross-repo handoff aimed at this repo) and anything with `blocks:`.
4. `.baseline.json` — then run:
   `python3 ~/dev/work/lawndart/platform/standards/bin/baseline-check . --quiet`
5. `~/dev/work/lawndart/.decisions/index.md` — standing decisions.

Report exactly this shape, nothing else:

```
<repo> — phase <N> (<name>), next gate: <what>
Open: <n> items (<n> OWNER — need Joe)
Filed at us: <items other repos handed off, or "none">
Baseline: <n> violations, <n> warnings, <n> exceptions (<n> expiring <30d>)
Blocked: <the one thing stopping progress, or "nothing">
```

Then stop and wait. Do not propose work, do not summarise the codebase, do not
list what you read. If any of the five sources contradict each other, say so —
that contradiction is the most useful thing you can report.
