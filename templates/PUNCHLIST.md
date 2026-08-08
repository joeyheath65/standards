# <repo> — Punchlist

Canonical list of **open** work. Start here.

Legend: `[ ]` open · `[~]` partial/in-progress
**Type** CODE / OWNER / DOCS / GROWTH · `GH #NN` linked issue (`→ needs issue` = create one)

**OWNER** items are console/config steps with no code — an agent cannot do them.
Phase detail lives in `BUILD_PLAN.md`; this file is what is actionable *now*.

**Closed items do not live here.** When work ships, move the line into
`BUILD_PLAN.md`'s shipped history in the same commit. `[x]` is not a state this
file has — an item is either open or it is somewhere else. Use
`standards/bin/punchlist close <id>` and it happens for you.

**Cross-repo items** carry `filed by the <repo> session <date>`, and `blocks:
<id>` when they gate work in the filing repo. Do not fix them from here.

---

## 0 · <the thing that matters most>

- P1. `[ ]` **CODE** · → needs issue — <one line: what and why. If the reason is
  not obvious in six months, write the reason.>

## 1 · Hygiene

- P2. `[ ]` **DOCS** — <smaller things that still deserve to not be forgotten>

---

## Known traps

- <what will bite the next session. this section earns its keep>
