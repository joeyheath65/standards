#!/usr/bin/env python3
"""Tests for baseline-check.

Covers the logic that is easy to get subtly wrong and expensive when it is:
version comparison precision, exception expiry, and lockfile sync. Every case
here corresponds to something that actually bit during the 2026-08-08 rollout.

Run: python3 tests/test_baseline_check.py
"""
from __future__ import annotations

import datetime as dt
import importlib.machinery
import importlib.util
import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_loader(
    "baseline_check",
    importlib.machinery.SourceFileLoader("baseline_check", str(HERE.parent / "bin" / "baseline-check")),
)
bc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bc)

FAILURES = []


def check(label, got, want):
    if got != want:
        FAILURES.append(f"{label}: got {got!r}, want {want!r}")


# ---- version precision -----------------------------------------------------
# `.nvmrc` of "22" is a LINE pin meaning "newest 22.x". Comparing it against a
# patch floor as 22.0.0 failed every correctly-configured repo we had.
check("nvmrc line pin vs patch floor", bc.below("22", "22.22.2"), False)
check("nvmrc 20 vs floor 22", bc.below("20", "22.22.2"), True)
check("explicit patch below floor", bc.below("22.20.0", "22.22.2"), True)
check("explicit patch above floor", bc.below("22.23.0", "22.22.2"), False)
check("caret range takes its minimum", bc.below("^18.3.1", "19.0.0"), True)
check("caret at floor", bc.below("^19.0.0", "19.0.0"), False)
# A union can resolve to any branch, so its guarantee is the lowest.
check("union guarantees the lowest", bc.below("^18.2.0 || ^19.0.0", "19.0.0"), True)
check(">= range", bc.below(">=22", "22"), False)
check("x wildcard", bc.below("22.x", "22.22.2"), False)
check("unparseable is not a violation", bc.below("workspace:*", "1.0.0"), False)

# ---- exception expiry ------------------------------------------------------
def judged(until, today):
    rep = bc.Report()
    bc.judge_exception(rep, "packages", "react", "18.3.1", "19.0.0",
                       {"react": {"until": until}}, dt.date.fromisoformat(today))
    return rep.rows[0]["level"]

check("live exception warns", judged("2026-11-30", "2026-08-08"), bc.WARN)
check("exception on its last day still warns", judged("2026-11-30", "2026-11-30"), bc.WARN)
check("expired exception is an ERROR", judged("2026-11-30", "2026-12-01"), bc.ERROR)

rep = bc.Report()
bc.judge_exception(rep, "packages", "react", "18.3.1", "19.0.0", {}, dt.date(2026, 8, 8))
check("no exception is an ERROR", rep.rows[0]["level"], bc.ERROR)

rep = bc.Report()
bc.judge_exception(rep, "packages", "react", "18.3.1", "19.0.0",
                   {"react": {"reason": "no date"}}, dt.date(2026, 8, 8))
check("exception without a date is an ERROR", rep.rows[0]["level"], bc.ERROR)

# ---- lockfile sync ---------------------------------------------------------
# The bug that took down a Cloud Run deploy: package.json edited, lock not
# regenerated. Every individual version was correct; only the pair was wrong.
def lock_case(pkg_dep, lock_dep):
    with tempfile.TemporaryDirectory() as d:
        repo = Path(d)
        (repo / "package.json").write_text(json.dumps(
            {"devDependencies": {"@types/node": pkg_dep}}))
        (repo / "package-lock.json").write_text(json.dumps(
            {"packages": {"": {"devDependencies": {"@types/node": lock_dep}}}}))
        rep = bc.Report()
        bc.check_lockfile_sync(rep, repo)
        return rep.rows[0]["level"]

check("lock in sync", lock_case("^22", "^22"), bc.OK)
check("lock out of sync", lock_case("^22", "^20"), bc.ERROR)

# ---- resolved_version ------------------------------------------------------
with tempfile.TemporaryDirectory() as d:
    repo = Path(d)
    (repo / "package-lock.json").write_text(json.dumps(
        {"packages": {"node_modules/tailwindcss": {"version": "3.4.19"}}}))
    check("reads the installed version", bc.resolved_version(repo, "tailwindcss"), "3.4.19")
    check("absent package is None", bc.resolved_version(repo, "nope"), None)

# ---------------------------------------------------------------------------
if FAILURES:
    print(f"FAILED ({len(FAILURES)})")
    for f in FAILURES:
        print("  " + f)
    sys.exit(1)
print("all baseline-check tests passed")
