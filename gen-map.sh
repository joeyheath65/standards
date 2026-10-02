#!/usr/bin/env bash
# gen-map.sh [umbrella-root] — regenerate the repo map in the umbrella CLAUDE.md from
# .decisions/projects.json. Rewrites only the lines between <!-- map:start --> and
# <!-- map:end -->. Needs jq.

set -euo pipefail

ROOT=${1:-$HOME/dev/work/lawndart}
REG="$ROOT/.decisions/projects.json"
DOC="$ROOT/CLAUDE.md"

command -v jq >/dev/null || { echo "gen-map: jq not found" >&2; exit 1; }
[ -f "$REG" ] || { echo "gen-map: $REG not found" >&2; exit 1; }
grep -q '<!-- map:start -->' "$DOC" && grep -q '<!-- map:end -->' "$DOC" \
  || { echo "gen-map: map markers missing in $DOC" >&2; exit 1; }

MAP=$(mktemp)
trap 'rm -f "$MAP" "$MAP.doc"' EXIT

jq -r '
  [.projects[] | select(.status != "archived")] | sort_by(.kind, .id)[] |
  "- **\(.id)** · \(.kind) · \(.status) · `\(.path)`"
  + (if .remote then " · \(.remote | sub("^github.com/"; "gh:"))" else "" end)
  + (if .blast_radius then "\n  - Hazard: \(.blast_radius)" else "" end)
' "$REG" > "$MAP"

jq -r '
  [.projects[] | select(.status == "archived") | .id] | sort |
  if length > 0 then "\nArchived (`archive/`): " + join(", ") else empty end
' "$REG" >> "$MAP"

awk -v map="$MAP" '
  /<!-- map:start -->/ { print; while ((getline line < map) > 0) print line; skip = 1; next }
  /<!-- map:end -->/   { skip = 0 }
  !skip
' "$DOC" > "$MAP.doc"

cat "$MAP.doc" > "$DOC"
echo "gen-map: $(grep -c '^- \*\*' "$MAP") active/paused projects written to $DOC"
