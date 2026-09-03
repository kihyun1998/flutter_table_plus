#!/usr/bin/env bash
# slot-authority.sh — thegraph `gate`: every derived slot, against its authority.
# Built from thegraph@8820d1293c04.
#
# Decider: code. A DERIVED slot is a copy of a fact that lives somewhere else.
# Being a copy it is never EMPTY — it fails by being silently wrong, and no node
# will notice, because a node that receives a value uses it. `build_gaps` fires
# on an empty slot and therefore cannot see this class at all: two consecutive
# updates here carried in zero gaps and both found real drift, all of it derived.
#
# BOTH DIRECTIONS, and that is the whole of it. Forward alone ("everything the
# doc names exists") only proves the doc is not lying about what it listed. It
# cannot see what the doc LEFT OUT, and both gaps this check was written for
# were that shape: a generated agent hand-copying a file count the tree had
# moved past, and a gate invoked without the argument that lets it see anything.
#
# What it does NOT assert is a DECIDED slot — the maintainer's judgement with no
# fact anywhere to check it against. Those are printed at the end instead of
# being silently absent, so a slot cannot leave the map by going quiet. An
# unassertable slot that announces itself is a known hole; one that says nothing
# is indistinguishable from a checked one.
#
# Usage:  scripts/thegraph/slot-authority.sh
#
# Exit:  0  every derived slot agrees with its authority
#       14  a slot disagrees with the fact it is a copy of
#       15  the graph doc is missing — the check would pass vacuously
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

DOC="docs/agents/thegraph.md"
SKILL="${HOME}/.claude/skills/thegraph/SKILL.md"
fail=0

if [[ ! -f "$DOC" ]]; then
  echo "no $DOC — nothing to check, and a vacuous pass is worse than a red." >&2
  exit 15
fi

bad() { echo "  MISMATCH  $*"; fail=1; }
note() { echo "  $*"; }

echo "── slot authorities, both directions ──"

# ── 1. build stamp ──────────────────────────────────────────────────────────
# Authority: the sha256 of the installed catalog. A stamp is a label, not a
# root, until something compares it to the thing that can have changed.
doc_stamp="$(grep -oE 'thegraph@[a-f0-9]{12}' "$DOC" | head -1 | cut -d@ -f2)"
if [[ -f "$SKILL" ]]; then
  real_stamp="$(sha256sum "$SKILL" | cut -c1-12)"
  if [[ "$doc_stamp" != "$real_stamp" ]]; then
    note "stamp      doc=$doc_stamp  catalog=$real_stamp  — BEHIND (warn, never fail:"
    note "           thegraph says so and continues; a rebuild passes through the maintainer)"
  else
    note "stamp      $doc_stamp — current"
  fi
else
  note "stamp      $doc_stamp — catalog not installed at \$HOME, unassertable here"
fi

# ── 2. sacred paths: every path the doc names resolves ──────────────────────
sacred=$(grep -oE '^\| `(lib/[^`]+|pubspec\.yaml|CHANGELOG\.md|\.pubignore)`' "$DOC" \
         | sed 's/^| `//; s/`$//' | sort -u)
n_sacred=0
while IFS= read -r p; do
  [[ -z "$p" ]] && continue
  n_sacred=$((n_sacred + 1))
  # a trailing /** in the doc names a directory
  probe="${p%/\*\*}"
  [[ -e "$probe" ]] || bad "sacred path does not resolve: $p"
done <<< "$sacred"
note "sacred     $n_sacred paths named, all resolve"

# ── 2b. …and the guard evaluates as many as the doc lists ───────────────────
# Reverse direction: a path dropped from the script and left in the doc reads as
# guarded and is not.
if [[ -f scripts/thegraph/sacred-diff.sh ]]; then
  n_guard=$(grep -cE "^\s+'?(lib/|pubspec|CHANGELOG|\.pubignore)" scripts/thegraph/sacred-diff.sh || true)
  if (( n_guard < n_sacred )); then
    bad "sacred-diff.sh evaluates $n_guard patterns; the doc names $n_sacred"
  else
    note "sacred     guard evaluates $n_guard — not fewer than the doc names"
  fi
fi

# ── 3. sweep surfaces: every file the doc points at exists ──────────────────
for p in CHANGELOG.md README.md docs/THEMING.md docs/FEATURES.md docs/MIGRATION.md \
         example example/README.md example/pubspec.lock .pubignore docs/map \
         docs/agents/lessons.md; do
  [[ -e "$p" ]] || bad "sweep surface does not resolve: $p"
done
note "surfaces   11 named, all resolve"

# ── 4. gate list: the doc and gates.sh, BOTH directions ─────────────────────
doc_gates=$(awk '/^## `gate`/{f=1} f&&/^```$/{c++} f&&c==1&&/^(flutter|dart|python|scripts)/{n++} c==2{exit} END{print n+0}' "$DOC")
run_gates=$(grep -cE '^\s*run "' scripts/thegraph/gates.sh || true)
# publish appears twice in the script (one branch each) and once in the doc
run_gates=$(( run_gates - 1 ))
if [[ "$doc_gates" != "$run_gates" ]]; then
  bad "gate list: doc lists $doc_gates, gates.sh runs $run_gates"
else
  note "gates      $doc_gates in the doc, $run_gates in the runner"
fi

# ── 5. extraction plan: BOTH directions ─────────────────────────────────────
for f in .claude/agents/ftp-*.md scripts/thegraph/*.sh; do
  grep -q "$(basename "$f")" "$DOC" || bad "on disk, absent from the extraction plan: $f"
done
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  [[ -e "$f" ]] || bad "in the extraction plan, absent from disk: $f"
done < <(grep -oE '(\.claude/agents/ftp-[a-z-]+\.md|scripts/thegraph/[a-z-]+\.sh)' "$DOC" | sort -u)
note "artifacts  $(ls .claude/agents/ftp-*.md scripts/thegraph/*.sh | wc -l) on disk, all listed; all listed exist"

# ── 6. no hand-copied counts in a generated artifact ────────────────────────
# This asserts an ABSENCE. The rule is "name the source and stop", and this repo
# has been bitten three times by a number copied out of a tree that then moved.
copied=0
for a in .claude/agents/ftp-*.md; do
  if grep -qE 'flat at [0-9]+ files|\([0-9]+ files\)|[0-9]+ territor|[0-9]+ invariant' "$a"; then
    bad "$a carries a hand-copied count — name the source and stop"
    copied=1
  fi
done
(( copied )) || note "counts     no generated agent carries one"

# ── 7. reference siblings exist where the doc says ──────────────────────────
for d in ../just_tooltip ../flutter_checkbox; do
  [[ -d "$d" ]] || bad "reference sibling missing: $d"
done
note "siblings   ../just_tooltip, ../flutter_checkbox present"

echo
echo "── unassertable, by design — printed so none goes quiet ──"
cat <<'DECIDED'
  sacred paths — VALUE        where a bug costs more than a wrong number
  sweep surfaces — VALUE      which docs describe behaviour here
  reference classes, routing  which real source answers which change type
  summarized: flags           what may never produce a CONFIRMED finding
  layers, proof per layer     what actually convinces the maintainer
  tautological traps          a check that can only confirm what it assumes
  tie-breaker per layer       who wins when prior art and measurement disagree
  deliberate divergence       arguments that are already over
  gate blind spots            what the commands above cannot reach
  U1 / U2                     deliberately unresolved; enforcing one would
                              ratify drift
  peers' trees                outside this repo. Names stored, trees never.
                              Confirmed by the maintainer 2026-08-31
  boundary rule and seams     CLAUDE.md, prose — stated, not machine-checked
DECIDED

echo
if (( fail )); then
  echo "SLOTS: a derived slot disagrees with the fact it is a copy of." >&2
  exit 14
fi
echo "SLOTS: every derived slot agrees with its authority, both directions."
echo "       The list above is what nothing here can check. It is printed, not"
echo "       omitted: an unassertable slot that announces itself is a known"
echo "       hole; one that says nothing looks exactly like a checked one."
