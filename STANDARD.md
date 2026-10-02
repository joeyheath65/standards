# The Lawn Dart repo standard

Every active Lawn Dart repo meets this contract. `check.sh <repo-path>` verifies the
deterministic parts and exits 1 on any failure.

## Required

| Path | Rule |
|---|---|
| `CLAUDE.md` | These sections, in this order: `What this is` (≤2 lines), `Stack`, `Commands`, `Layout`, `Gotchas`, `Deploy`. ≤150 lines. Overflow goes to path-scoped `.claude/rules/`. Template: `templates/CLAUDE.md`. |
| `BUILD_PLAN.md` | Direction and current phase only. No task lists, no shipped history. Template: `templates/BUILD_PLAN.md`. |
| `.claude/settings.json` | Committed. |
| `.claude/git-profile.md` | This repo's git and deploy facts, read by the `git-ops` agent. Template: `templates/git-profile.md`. |
| `.gitignore` | Ignores `.claude/settings.local.json`, `.claude/worktrees/`, `.claude/agent-memory-local/`. |

## Allowed, if needed (repo-specific only)

- `.claude/rules/`: every file has `paths:` frontmatter.
- `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`
- `docs/specs/`

## Banned

- Copies of umbrella agents or skills (`git-ops`, `capture`, `program`). They load from the umbrella.
- `.claude/commands/`. Use a skill.
- A tracked `.claude/settings.local.json`.
- Symlinks into gitignored paths, and dangling symlinks, under `.claude/`.
- Inventories in `CLAUDE.md`: plugin, key or repo lists.
- Conventions duplicated from the umbrella.
- A repo-level `.mcp.json`. MCP servers go inline in the agent that needs them.
- Decision logs in `CLAUDE.md`. Decisions go to the `.decisions` repo.
- `PUNCHLIST.md`, `docs/handoff*`, `*SESSION-LOG*`, `docs/prompts/`.
- Any `.claude/` in a repo under `archive/`.

`check.sh` doesn't check "inventories", "duplicated conventions" or "decision logs" in
`CLAUDE.md`. Those need judgement; the 150-line cap is the backstop.

## System of record

| Question | Answer lives in |
|---|---|
| What's the work queue? | GitHub Issues + the Project board |
| What shipped? | Merged PRs and closed issues |
| What did Joe decide? | The `.decisions` repo |
| Where was I? | Branch + draft PR + the SessionStart hook |
| What has Claude learned? | Auto memory + agent memory |

## Outside the repo

- A GitHub remote.
- Branch protection on `main` with required checks.

## The umbrella

`~/dev/work/lawndart` gets its own profile in `check.sh` (detected by `.decisions/projects.json`).
Its `CLAUDE.md` holds routing and a generated repo map between `<!-- map:start -->` and
`<!-- map:end -->`, so the six-section and `BUILD_PLAN.md` rules don't apply to it.
Everything else does.
