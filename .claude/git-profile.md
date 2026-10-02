# git-profile — standards

## Deploy trigger
Moving the `v1` tag. Every consuming repo's Renovate preset and CI follow `@v1`, so a merge to
`main` changes nothing until the tag moves. Only Joe moves the tag.

## Pre-push checks
- `python3 tests/test_baseline_check.py`
- `python3 bin/baseline-check . --quiet`
- `bash -n check.sh gen-map.sh`

## CI jobs
`self-test` (`.github/workflows/self-test.yml`) on every PR.

## Deploy constraints
Never move or recreate the `v1` tag.

## Post-merge checks
none

## Cross-repo hazards
- Every Lawn Dart repo consumes `baseline.json`, `default.json` and the reusable workflows via `@v1`.
- `gen-map.sh` writes the umbrella `CLAUDE.md` (`joeyheath65/lawndart-umbrella`); the regenerated map is committed there, not here.

## Board
Project number: none
Owner: none

## Repo quirks
- `PUNCHLIST.md` has uncommitted edits from another session. Never stage it with standard work.
