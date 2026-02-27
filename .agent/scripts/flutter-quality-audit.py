#!/usr/bin/env python3
"""
flutter-quality-audit.py

Runs project quality checks for Flutter with a practical gate:
- `flutter analyze --no-fatal-infos` (warnings/errors fail, infos don't)
- optional `flutter test`
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path


def run_command(command: list[str], cwd: Path) -> tuple[int, str]:
    command_to_run = command
    if os.name == "nt":
        command_to_run = ["cmd", "/c", *command]

    process = subprocess.run(
        command_to_run,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    combined_output = f"{process.stdout}{process.stderr}"
    if combined_output:
        print(combined_output, end="")
    return process.returncode, combined_output


def count_findings(output: str) -> tuple[int, int]:
    warnings = len(re.findall(r"^\s*warning - ", output, flags=re.MULTILINE))
    errors = len(re.findall(r"^\s*error - ", output, flags=re.MULTILINE))
    return warnings, errors


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run Flutter quality audit (analyze + optional tests).",
    )
    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="Flutter project root path (default: current directory).",
    )
    parser.add_argument(
        "--with-tests",
        action="store_true",
        help="Run `flutter test` after analyze.",
    )
    args = parser.parse_args()

    root = Path(args.path).resolve()
    if not root.exists() or not root.is_dir():
        print(f"Invalid project path: {root}", file=sys.stderr)
        return 2

    print("== Flutter Quality Audit ==")
    print(f"Project: {root}")

    analyze_rc, analyze_output = run_command(
        ["flutter", "analyze", "--no-fatal-infos"],
        cwd=root,
    )
    warnings, errors = count_findings(analyze_output)
    print(f"\nAnalyze summary: warnings={warnings}, errors={errors}")

    tests_rc = 0
    if args.with_tests:
        print("\n== Running tests ==")
        tests_rc, _ = run_command(["flutter", "test"], cwd=root)

    if analyze_rc != 0 or tests_rc != 0:
        print("\nQuality audit: FAILED")
        return 1

    print("\nQuality audit: PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
