#!/usr/bin/env python3
"""check_map.py — the one gate for docs/map/.

Usage:  python scripts/map/check_map.py [path ...]      (default: docs/map)
Exit:   0 clean · 1 findings

What it checks, in the order these pay off:

  1. every backticked `*.dart` path under `## Code` exists
  2. every backticked symbol under `## Code` is greppable in lib/ or example/lib
     (and a `file.dart:123` line number is itself a finding)
  3. every markdown link resolves — file AND `#anchor`
  4. the section set is exactly the one for that note kind
  5. reciprocity: every territory an invariant claims claims it back

Two failure modes this is written against, both measured by the skill that
generated it:

  · CRLF — headings are split on /\\r?\\n/, never on '\\n'. A '\\r' left on the
    line makes the heading pattern match ZERO headings, so every anchor set comes
    back empty and every correct link is reported broken. That output is
    indistinguishable from a real defect.
  · Documentation about links contains link-shaped text. Code spans and fenced
    blocks are blanked (replaced with spaces, so line numbers survive) before
    anything is extracted.

A gate is not verified until it has been shown to PASS on known-good input, FAIL
on each defect kind, and IGNORE what it should ignore. Run --selftest.
"""
from __future__ import annotations

import io
import os
import re
import unicodedata
import sys

try:  # Windows consoles default to cp949 here; the arrows are not decoration
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:  # pragma: no cover - older interpreters
    pass

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

TERRITORY_SECTIONS = [
    "What it is",
    "Governing decisions",
    "Design model",
    "Code",
    "Reference behaviour",
    "Cross-cutting invariants",
    "Blast radius",
    "Known holes / open",
]
INVARIANT_SECTIONS = [
    "The fact",
    "Why it is cross-cutting",
    "Territories it holds in",
    "What a violation looks like",
    "Discovery history",
    "Where it will recur",
]

LINK = re.compile(r"\[([^\]\n]*)\]\(([^)\s]+)\)")
BACKTICK = re.compile(r"`([^`\n]+)`")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*$")


def read(path: str) -> str:
    with io.open(path, encoding="utf-8") as fh:
        return fh.read()


def lines_of(text: str) -> list[str]:
    """Split CRLF-safely. Splitting on '\\n' alone is the measured killer."""
    return re.split(r"\r?\n", text)


def _blank(out: list[str], a: int, b: int) -> None:
    for i in range(a, b):
        if out[i] not in ("\n", "\r"):
            out[i] = " "


def blank_fences(text: str) -> str:
    """Blank fenced blocks only. A `## ` inside a fence is not a heading."""
    out = list(text)
    for m in re.finditer(r"^[ \t]*```.*?^[ \t]*```", text, re.S | re.M):
        _blank(out, *m.span())
    return "".join(out)


def blank_code(text: str) -> str:
    """Blank fenced blocks *and* inline code, preserving offsets and newlines.

    For link extraction only. Never for headings: GitHub strips the backticks
    from a heading and keeps the words, so blanking `pubspec` there yields an
    anchor of nine hyphens and every correct link to it reports broken.
    """
    out = list(blank_fences(text))
    for m in re.finditer(r"`[^`\n]*`", "".join(out)):
        _blank(out, *m.span())
    return "".join(out)


def slug(heading: str) -> str:
    """GitHub's anchor slug (github-slugger's rule, not an approximation).

    Lowercase, strip inline markup, delete every Unicode punctuation and symbol
    except '-' and '_', then replace each remaining space with '-' **without
    collapsing runs**. Both details bite on this repo's headings: an em dash is
    deleted and leaves two spaces behind, so `Step 2 - 경계` anchors with TWO
    hyphens. A slugger that keeps the dash, or collapses the run, validates links
    against its own wrong model and passes ones that silently land at the top of
    the target document.
    """
    s = re.sub(r"`([^`]*)`", r"\1", heading)
    s = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", s)
    s = s.strip().lower()
    s = "".join(
        ch
        for ch in s
        if ch in "-_" or not unicodedata.category(ch).startswith(("P", "S"))
    )
    return s.replace(" ", "-")


def anchors_of(path: str) -> set[str]:
    seen: dict[str, int] = {}
    out: set[str] = set()
    for line in lines_of(blank_fences(read(path))):
        m = HEADING.match(line)
        if not m:
            continue
        base = slug(m.group(2))
        if not base:
            continue
        n = seen.get(base, 0)
        seen[base] = n + 1
        out.add(base if n == 0 else f"{base}-{n}")
    return out


def sections_of(text: str) -> list[str]:
    return [
        m.group(2).strip()
        for line in lines_of(blank_fences(text))
        if (m := HEADING.match(line)) and len(m.group(1)) == 2
    ]


def section_body(text: str, name: str, raw: bool = False) -> str:
    """Body of one `## ` section.

    `raw=True` keeps code spans. The `## Code` section *is* backticks end to end,
    so blanking them there leaves an empty string — and every check over it then
    passes having inspected nothing, which is the one failure indistinguishable
    from a clean run. Measured here: two planted defects, neither caught.
    """
    body, inside = [], False
    for line in lines_of(text if raw else blank_fences(text)):
        m = HEADING.match(line)
        if m and len(m.group(1)) == 2:
            inside = m.group(2).strip() == name
            continue
        if inside:
            body.append(line)
    return "\n".join(body)


_TREE: list[str] = []


def tree() -> list[str]:
    """Every .dart source, read once. No external tool: `rg` is not reliably on
    PATH for a subprocess on Windows, and a checker that dies there reports
    nothing rather than failing loudly."""
    if not _TREE:
        for d in ("lib", "example/lib", "test"):
            base = os.path.join(ROOT, d)
            for dirpath, _, names in os.walk(base):
                for n in names:
                    if n.endswith(".dart"):
                        _TREE.append(read(os.path.join(dirpath, n)))
    return _TREE


def greppable(symbol: str) -> bool:
    pat = re.compile(rf"\b{re.escape(symbol)}\b")
    return any(pat.search(src) for src in tree())


def resolve_dart(rel_path: str) -> str | None:
    for d in ("lib/src", "lib", "example", "."):
        cand = os.path.join(ROOT, d, rel_path)
        if os.path.isfile(cand):
            return cand
    return None


def in_file(symbol: str, abs_path: str) -> bool:
    return re.search(rf"\b{re.escape(symbol)}\b", read(abs_path)) is not None


def check_file(path: str, all_notes: dict[str, str]) -> list[str]:
    rel = os.path.relpath(path, ROOT).replace("\\", "/")
    text = all_notes[path]
    clean = blank_code(text)
    found: list[str] = []

    kind = (
        "territory"
        if "/territory/" in rel
        else "invariant" if "/invariant/" in rel else "hub"
    )

    # 4. section set
    if kind in ("territory", "invariant"):
        want = TERRITORY_SECTIONS if kind == "territory" else INVARIANT_SECTIONS
        got = sections_of(text)
        if got != want:
            missing = [s for s in want if s not in got]
            extra = [s for s in got if s not in want]
            if missing:
                found.append(f"{rel}: missing section(s): {', '.join(missing)}")
            if extra:
                found.append(f"{rel}: unexpected section(s): {', '.join(extra)}")
            if not missing and not extra:
                found.append(f"{rel}: sections out of order")

    # 1 & 2. code section, line by line, so a symbol is checked against the file
    # the line names it in. Attribution is the layer that actually decays: a
    # refactor moves symbols, the claims above them stay true, and a symbol that
    # merely exists *somewhere* would still pass.
    if kind == "territory":
        for raw in lines_of(section_body(text, "Code", raw=True)):
            toks = [t.strip() for t in BACKTICK.findall(raw)]
            if not toks:
                continue
            owner = None
            for tok in toks:
                if re.search(r"\.dart:\d+", tok):
                    found.append(
                        f"{rel}: line number in `{tok}` — name the symbol instead"
                    )
                    continue
                if tok.endswith(".dart"):
                    owner = resolve_dart(tok)
                    if owner is None:
                        found.append(f"{rel}: path does not exist: `{tok}`")
                    continue
                if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", tok):
                    continue
                if owner is not None:
                    if not in_file(tok, owner):
                        d = os.path.relpath(owner, ROOT).replace("\\", "/")
                        found.append(f"{rel}: `{tok}` is not in {d} (attribution)")
                elif not greppable(tok):
                    found.append(f"{rel}: symbol not found in tree: `{tok}`")

    # 3. links
    for _, target in LINK.findall(clean):
        if target.startswith(("http://", "https://", "mailto:")):
            continue
        file_part, _, anchor = target.partition("#")
        dest = (
            os.path.normpath(os.path.join(os.path.dirname(path), file_part))
            if file_part
            else path
        )
        if file_part and not os.path.isfile(dest):
            found.append(f"{rel}: broken link → {target}")
            continue
        if anchor and anchor not in anchors_of(dest):
            found.append(f"{rel}: broken anchor → {target}")

    return found


def reciprocity(all_notes: dict[str, str]) -> list[str]:
    found = []
    for path, text in all_notes.items():
        rel = os.path.relpath(path, ROOT).replace("\\", "/")
        if "/invariant/" not in rel:
            continue
        for _, target in LINK.findall(
            blank_code(section_body(text, "Territories it holds in"))
        ):
            file_part = target.partition("#")[0]
            dest = os.path.normpath(os.path.join(os.path.dirname(path), file_part))
            if dest not in all_notes:
                continue
            back = section_body(all_notes[dest], "Cross-cutting invariants")
            me = os.path.basename(path)
            if me not in back:
                d = os.path.relpath(dest, ROOT).replace("\\", "/")
                found.append(f"{d}: does not claim back invariant {me} (one-way edge)")
    return found


def hub_reachable(notes: dict[str, str]) -> list[str]:
    """Every note on disk is linked from the hub, and every hub link resolves.

    The hub's `## Nodes` list is a second copy of what `ls docs/map/territory
    docs/map/invariant` already says, so it can disagree with the folder — and
    when it did, this gate reported `clean` over 32 notes while an invariant
    note sat unlinked. Nothing pointed at it, so the run that needed it could
    not find it from the hub.

    The check runs BOTH directions, like every other rooted copy here: an
    orphan (on disk, not in the hub) and a dangling entry (in the hub, not on
    disk) are the same defect seen from two ends.
    """
    hub = os.path.join(ROOT, "docs", "map", "README.md")
    if not os.path.isfile(hub):
        return []
    text = blank_code(read(hub))
    linked = {
        os.path.normpath(os.path.join(os.path.dirname(hub), m.group(2)))
        for m in LINK.finditer(text)
        if m.group(2).endswith(".md")
    }
    on_disk = {
        os.path.normpath(p)
        for p in notes
        if os.path.basename(os.path.dirname(p)) in ("territory", "invariant")
    }
    out = []
    for p in sorted(on_disk - linked):
        rel = os.path.relpath(p, ROOT).replace("\\", "/")
        out.append(
            f"{rel}: on disk but not linked from docs/map/README.md "
            f"(orphan — nothing can reach it from the hub)"
        )
    for p in sorted(linked - on_disk):
        if "/territory/" in p.replace("\\", "/") or "/invariant/" in p.replace("\\", "/"):
            rel = os.path.relpath(p, ROOT).replace("\\", "/")
            out.append(f"docs/map/README.md: links {rel}, which is not on disk")
    return out

def collect(paths: list[str]) -> dict[str, str]:
    out = {}
    for p in paths:
        p = os.path.abspath(p)
        if os.path.isdir(p):
            for dirpath, _, names in os.walk(p):
                for n in names:
                    if n.endswith(".md"):
                        f = os.path.join(dirpath, n)
                        out[f] = read(f)
        elif p.endswith(".md"):
            out[p] = read(p)
    return out


def selftest() -> int:
    """PASS on good, FAIL on each defect kind, IGNORE what it should ignore."""
    good = "# T\n\n## What it is\nx\n\n## Governing decisions\n**None.**\n"
    assert sections_of(good) == ["What it is", "Governing decisions"]
    crlf = good.replace("\n", "\r\n")
    assert sections_of(crlf) == ["What it is", "Governing decisions"], "CRLF split"
    assert slug("## 1. Ctrl+Wheel 시 문제".replace("## ", "")) == "1-ctrlwheel-시-문제"
    # An em dash is deleted and leaves its spaces behind: two hyphens, not one.
    assert slug("Step 2 — 경계") == "step-2--경계", "em dash / space runs"
    quoted = "see `[x](../NOPE.md)` and:\n\n```\n[y](../ALSO-NOPE.md)\n```\n"
    assert LINK.findall(blank_code(quoted)) == [], "code spans must be ignored"
    live = "real [z](../NOPE.md)"
    assert LINK.findall(blank_code(live)) == [("z", "../NOPE.md")], "live link kept"
    assert blank_code(quoted).count("\n") == quoted.count("\n"), "offsets preserved"
    print("selftest: pass (good input passes, CRLF survives, code spans ignored,")
    print("          live links still extracted, line offsets preserved)")
    return 0


def main() -> int:
    args = [a for a in sys.argv[1:] if a != "--selftest"]
    if "--selftest" in sys.argv[1:]:
        return selftest()
    notes = collect(args or [os.path.join(ROOT, "docs", "map")])
    if not notes:
        print("no notes found — check the scope you passed", file=sys.stderr)
        return 1
    findings = []
    for path in sorted(notes):
        findings += check_file(path, notes)
    findings += reciprocity(notes)
    findings += hub_reachable(notes)
    print(f"checked {len(notes)} note(s)")
    for f in findings:
        print(f"  FINDING  {f}")
    print("clean" if not findings else f"{len(findings)} finding(s)")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
