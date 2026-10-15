# The Lawn Dart repo standard

Every active Lawn Dart repo meets this contract. `check.sh <repo-path>` verifies the
deterministic parts and exits 1 on any failure.

## Required

| Path | Rule |
|---|---|
| `AGENTS.md` | The project rules, read whole by every agent harness at every session start. These sections, in this order: `What this is` (≤2 lines), `Stack`, `Commands`, `Layout`, `Gotchas`, `Deploy`, then optionally `Context files`. ≤150 lines. Overflow goes to on-demand context files (below). Template: `templates/AGENTS.md`. |
| `CLAUDE.md` | Imports `@AGENTS.md`, then at most a short `# Claude Code` section with Claude-only items (`.claude/` rules, skills, agents, hooks). Template: `templates/CLAUDE.md`. |
| `BUILD_PLAN.md` | Direction and current phase only. No task lists, no shipped history. Template: `templates/BUILD_PLAN.md`. |
| `.claude/settings.json` | Committed. |
| `.claude/git-profile.md` | This repo's git and deploy facts, read by the `git-ops` agent. Template: `templates/git-profile.md`. |
| `.gitignore` | Ignores `.claude/settings.local.json`, `.claude/worktrees/`, `.claude/agent-memory-local/`. |

## Where a rule goes

Content is placed by what happens if an agent misses it.

| If it's missed... | It goes in |
|---|---|
| Something breaks (deploy, data, money, security) and a script can tell | A test or CI check. Prose is the fallback, not the first choice. |
| Something breaks and only judgement can tell | `AGENTS.md` `Gotchas`, one line each, with the why. |
| Work in one area goes worse | An on-demand context file: `docs/agents/<topic>.md`, indexed in `AGENTS.md`. |
| Only matters when certain files are touched, and only Claude needs it | `.claude/rules/<topic>.md` with `paths:` frontmatter. |
| It's history, status, or a decision | Git history, GitHub Issues, or the `.decisions` repo. Never `AGENTS.md`. |

## On-demand context files

- Live in `docs/agents/<topic>.md`, ≤150 lines each, harness-neutral.
- Indexed in the `AGENTS.md` `## Context files` table: one row per file, `| \`path\` | Read it when |`. The trigger names the files, commands or task that make it relevant.
- Referenced by plain path, never `@`-imported (an import loads it every session, which defeats the point).
- Every `docs/agents/*.md` is in the table, and every path in the table exists. The table may also index existing docs elsewhere in the repo.
- Shared topic names across repos, where they apply: `deploy.md`, `layout.md`, `env-and-secrets.md`, `design-system.md`, `testing.md`.

## Allowed, if needed (repo-specific only)

- `.claude/rules/`: every file has `paths:` frontmatter. Claude-only, so harness-neutral guidance goes in `docs/agents/` instead.
- `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`
- `docs/specs/`

## Banned

- Copies of umbrella agents or skills (`git-ops`, `capture`, `program`). They load from the umbrella.
- `.claude/commands/`. Use a skill.
- A tracked `.claude/settings.local.json`.
- Dangling symlinks under `.claude/`, and symlinks into gitignored paths unless the target
  is inside a repo registered in `projects.json` (or the `.decisions` repo itself).
- Inventories in `AGENTS.md` or `CLAUDE.md`: plugin, key or repo lists.
- Conventions duplicated from the umbrella.
- A repo-level `.mcp.json`. MCP servers go inline in the agent that needs them.
- Decision logs in `AGENTS.md` or `CLAUDE.md`. Decisions go to the `.decisions` repo.
- `PUNCHLIST.md`, `docs/handoff*`, `*SESSION-LOG*`, `docs/prompts/`.
- Any `.claude/` in a repo under `archive/`.

`check.sh` doesn't check "inventories", "duplicated conventions" or "decision logs" in
`AGENTS.md`. Those need judgement; the 150-line cap is the backstop.

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
- Delete-branch-on-merge enabled.

## The umbrella

`~/dev/work/lawndart` gets its own profile in `check.sh` (detected by `.decisions/projects.json`).
Its `AGENTS.md` holds routing and a generated repo map between `<!-- map:start -->` and
`<!-- map:end -->`, so the six-section and `BUILD_PLAN.md` rules don't apply to it.
Everything else does.
