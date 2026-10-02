#!/usr/bin/env bash
# check.sh <repo-path> — read-only conformance check against STANDARD.md.
# Prints PASS/FAIL per check; exits 1 on any FAIL. Bash + git only.
# Bash 3.2 compatible (macOS /bin/bash): no associative arrays, no mapfile.

set -u

[ $# -eq 1 ] || { echo "usage: check.sh <repo-path>" >&2; exit 2; }
R=$(cd "$1" 2>/dev/null && pwd -P) || { echo "FAIL  repo path: $1 not found"; exit 1; }
TOP=$(git -C "$R" rev-parse --show-toplevel 2>/dev/null) || { echo "FAIL  git repo: $R is not a git repo"; exit 1; }
TOP=$(cd "$TOP" && pwd -P)
[ "$TOP" = "$R" ] || { echo "FAIL  git repo: $R is inside $TOP; pass the repo root"; exit 1; }

FAILS=0
pass() { echo "PASS  $1"; }
fail() { echo "FAIL  $1${2:+ — $2}"; FAILS=$((FAILS + 1)); }
check() { if [ "$2" = ok ]; then pass "$1"; else fail "$1" "$2"; fi; }

# Profiles: umbrella (has .decisions/projects.json), ledger (is .decisions, holds
# projects.json at its root), or repo.
PROFILE=repo
[ -f "$R/.decisions/projects.json" ] && PROFILE=umbrella
[ "$(basename "$R")" = .decisions ] && [ -f "$R/projects.json" ] && PROFILE=ledger
UMBRELLA=no; [ $PROFILE = repo ] || UMBRELLA=yes   # umbrella + ledger share the relaxed rules
ARCHIVED=no
case "$R" in */archive/*) ARCHIVED=yes ;; esac

echo "check.sh: $R (profile: $PROFILE)"

# --- archive: the only rule is "no .claude/" -------------------------------
if [ $ARCHIVED = yes ]; then
  if [ -e "$R/.claude" ]; then fail "archive: no .claude/" ".claude/ present"; else pass "archive: no .claude/"; fi
  [ $FAILS -eq 0 ] && exit 0 || exit 1
fi

# --- required files ---------------------------------------------------------
case $PROFILE in
  ledger) REQ=".claude/settings.json .claude/git-profile.md .gitignore" ;;
  umbrella) REQ="CLAUDE.md .claude/settings.json .claude/git-profile.md .gitignore" ;;
  *) REQ="CLAUDE.md .claude/settings.json .claude/git-profile.md .gitignore BUILD_PLAN.md" ;;
esac
for f in $REQ; do
  if [ -f "$R/$f" ]; then pass "required: $f"; else fail "required: $f" "missing"; fi
done

if [ -f "$R/.claude/settings.json" ]; then
  if git -C "$R" ls-files --error-unmatch .claude/settings.json >/dev/null 2>&1; then
    pass "committed: .claude/settings.json"
  else
    fail "committed: .claude/settings.json" "exists but not tracked"
  fi
fi

# --- CLAUDE.md shape --------------------------------------------------------
if [ -f "$R/CLAUDE.md" ] && [ $PROFILE != ledger ]; then
  N=$(wc -l < "$R/CLAUDE.md" | tr -d ' ')
  if [ "$N" -le 150 ]; then pass "CLAUDE.md ≤150 lines ($N)"; else fail "CLAUDE.md ≤150 lines" "$N lines"; fi

  if [ $UMBRELLA = yes ]; then
    if grep -q '<!-- map:start -->' "$R/CLAUDE.md" && grep -q '<!-- map:end -->' "$R/CLAUDE.md"; then
      pass "CLAUDE.md map markers"
    else
      fail "CLAUDE.md map markers" "<!-- map:start --> / <!-- map:end --> missing"
    fi
  else
    WANT="What this is|Stack|Commands|Layout|Gotchas|Deploy"
    GOT=$(grep -E '^## ' "$R/CLAUDE.md" | sed 's/^## *//; s/[[:space:]]*$//' | grep -xE "$WANT" | tr '\n' '|' | sed 's/|$//')
    if [ "$GOT" = "$WANT" ]; then
      pass "CLAUDE.md sections in order"
    else
      fail "CLAUDE.md sections in order" "want [$WANT], found [${GOT:-none}]"
    fi
    if grep -qE '^## What this is[[:space:]]*$' "$R/CLAUDE.md"; then
      W=$(awk '/^## What this is[[:space:]]*$/{f=1;next} /^#/{if(f)exit} f && NF{c++} END{print c+0}' "$R/CLAUDE.md")
      if [ "$W" -le 2 ]; then pass "CLAUDE.md 'What this is' ≤2 lines"; else fail "CLAUDE.md 'What this is' ≤2 lines" "$W lines"; fi
    fi
  fi
fi

# --- .gitignore covers local-only paths (asks git, so allowlists work too) ---
for p in .claude/settings.local.json .claude/worktrees/probe .claude/agent-memory-local/probe; do
  label=${p%/probe}
  if git -C "$R" check-ignore -q --no-index "$p" 2>/dev/null; then
    pass "gitignored: $label"
  else
    fail "gitignored: $label" "not ignored"
  fi
done

# --- settings.local.json never tracked --------------------------------------
if [ -n "$(git -C "$R" ls-files .claude/settings.local.json)" ]; then
  fail "untracked: .claude/settings.local.json" "tracked in git"
else
  pass "untracked: .claude/settings.local.json"
fi

# --- banned paths -----------------------------------------------------------
# Candidate files = tracked + untracked-not-ignored. Respects nested repos and
# skips node_modules/build output without a hand-kept exclude list.
FILES=$(git -C "$R" ls-files -co --exclude-standard 2>/dev/null)

banned() { # label, grep -E pattern over repo-relative paths
  local hits
  hits=$(printf '%s\n' "$FILES" | grep -E "$2" | grep -v '^\.claude/worktrees/' | head -3 | tr '\n' ' ')
  if [ -n "$hits" ]; then fail "banned: $1" "$hits"; else pass "banned: $1"; fi
}
banned "PUNCHLIST.md"          '(^|/)PUNCHLIST\.md$'
banned "docs/handoff*"         '^docs/handoff'
banned "*SESSION-LOG*"         'SESSION-LOG'
banned "docs/prompts/"         '^docs/prompts/'
banned "repo-level .mcp.json"  '^\.mcp\.json$'

if [ -d "$R/.claude/commands" ]; then fail "banned: .claude/commands/" "present"; else pass "banned: .claude/commands/"; fi

if [ $UMBRELLA = no ]; then
  COPIES=""
  for n in git-ops capture program; do
    [ -e "$R/.claude/agents/$n.md" ] && COPIES="$COPIES agents/$n.md"
    [ -e "$R/.claude/skills/$n" ] && COPIES="$COPIES skills/$n"
  done
  if [ -n "$COPIES" ]; then fail "banned: copies of umbrella agents/skills" "$COPIES"; else pass "banned: copies of umbrella agents/skills"; fi

  # Repo rules must be path-scoped. (The umbrella may carry always-on rules.)
  if [ -d "$R/.claude/rules" ]; then
    NOPATHS=""
    for f in "$R"/.claude/rules/*.md; do
      [ -f "$f" ] || continue
      if ! awk 'NR==1 && !/^---[[:space:]]*$/{exit 1} NR>1 && /^---[[:space:]]*$/{exit found?0:1} NR>1 && /^paths:/{found=1} END{if(!found)exit 1}' "$f"; then
        NOPATHS="$NOPATHS $(basename "$f")"
      fi
    done
    if [ -n "$NOPATHS" ]; then fail "rules have paths: frontmatter" "$NOPATHS"; else pass "rules have paths: frontmatter"; fi
  fi
fi

# --- symlinks under .claude/ ------------------------------------------------
DANGLING=""; IGNORED=""
if [ -d "$R/.claude" ]; then
  LINKS=$(find "$R/.claude" -path "$R/.claude/worktrees" -prune -o -type l -print 2>/dev/null)
  for l in $LINKS; do
    if [ ! -e "$l" ]; then DANGLING="$DANGLING ${l#$R/}"; continue; fi
    t=$(readlink "$l")
    case "$t" in /*) abs=$t ;; *) abs=$(dirname "$l")/$t ;; esac
    real=$(cd "$abs" 2>/dev/null && pwd -P || { d=$(cd "$(dirname "$abs")" 2>/dev/null && pwd -P) && echo "$d/$(basename "$abs")"; })
    case "$real" in
      "$R"/*) git -C "$R" check-ignore -q --no-index "${real#$R/}" 2>/dev/null && IGNORED="$IGNORED ${l#$R/}" ;;
    esac
  done
fi
if [ -n "$DANGLING" ]; then fail "no dangling symlinks under .claude/" "$(echo $DANGLING | cut -c1-200)"; else pass "no dangling symlinks under .claude/"; fi
if [ -n "$IGNORED" ]; then fail "no symlinks into gitignored paths" "$(echo $IGNORED | wc -w | tr -d ' ') link(s), e.g. $(echo $IGNORED | cut -d' ' -f1)"; else pass "no symlinks into gitignored paths"; fi

echo "---"
if [ $FAILS -eq 0 ]; then echo "all checks passed"; exit 0; fi
echo "$FAILS check(s) failed"
exit 1
