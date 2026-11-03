#!/usr/bin/env python3
"""check_format.py — the formatter gate, run with a pinned dart_style.

Usage:  python scripts/format/check_format.py          check lib/ and test/
        python scripts/format/check_format.py --fix    format them in place
Exit:   0 clean · 1 a file would change · 2 setup failed

Activates dart_style DART_STYLE_VERSION as a global package when the active one
differs, then runs its `format` executable over lib/ and test/ from the
repository root. Needs Dart 3.11 or newer on PATH, the floor that version of
dart_style declares.
"""
from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys

DART_STYLE_VERSION = "3.1.14"
TARGETS = ["lib", "test"]

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def _dart() -> str:
    dart = shutil.which("dart")
    if dart is None:
        print("check_format: `dart` is not on PATH", file=sys.stderr)
        sys.exit(2)
    return dart


def _active_version(dart: str) -> str | None:
    out = subprocess.run(
        [dart, "pub", "global", "list"],
        capture_output=True,
        text=True,
        check=False,
    ).stdout
    match = re.search(r"^dart_style (\S+)", out, re.M)
    return match.group(1) if match else None


def _ensure_pinned(dart: str) -> None:
    if _active_version(dart) == DART_STYLE_VERSION:
        return
    print(f"check_format: activating dart_style {DART_STYLE_VERSION}")
    done = subprocess.run(
        [dart, "pub", "global", "activate", "dart_style", DART_STYLE_VERSION],
        check=False,
    )
    if done.returncode != 0 or _active_version(dart) != DART_STYLE_VERSION:
        print(
            f"check_format: could not activate dart_style {DART_STYLE_VERSION}",
            file=sys.stderr,
        )
        sys.exit(2)


def main(argv: list[str]) -> int:
    fix = "--fix" in argv
    dart = _dart()
    _ensure_pinned(dart)
    args = [dart, "pub", "global", "run", "dart_style:format"]
    if not fix:
        args += ["--output=none", "--set-exit-if-changed"]
    args += TARGETS
    return 1 if subprocess.run(args, cwd=ROOT, check=False).returncode else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
