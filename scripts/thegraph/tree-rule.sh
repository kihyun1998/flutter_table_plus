#!/usr/bin/env bash
# tree-rule.sh — thegraph `place` guard for flutter_table_plus, and `gate` again
# over the final diff.
# Built from thegraph@08b7768e9e35.
#
# Decider: code. Layout is where a seam is physically expressed, so a file in the
# wrong directory breaks the seam while producing no error, no failing test and
# no warning. This is the firing mechanism; prose alone would make `place` a bar
# nothing can trip.
#
# Usage:  scripts/thegraph/tree-rule.sh [base-ref]
#         scripts/thegraph/tree-rule.sh --audit
#   no base-ref : working tree + index + untracked, against HEAD
#   base-ref    : that ref's merge-base ...HEAD, plus uncommitted work
#   --audit     : every tracked file, to measure the rule against the whole tree
#
# Exit:  0  every changed path is owned by a rule, and lib/src/utils is clean
#       10  a path inside a ruled root matches no rule — route to `decide`
#       11  a lib/src/utils file declares a Widget subclass — the axis is broken
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# dir|file-glob|what this directory owns
#
# The directory is matched EXACTLY, never as a glob, so lib/src/models/*.dart
# cannot silently swallow lib/src/models/theme/ or a subdirectory nobody decided
# to create. That is the whole point of the check.
RULES=(
  'lib|flutter_table_plus.dart|the barrel — the only public entry point'
  'lib/src/models|*.dart|value types the consumer constructs and passes in'
  'lib/src/models/theme|*.dart|theme value types'
  'lib/src/utils|*.dart|computation that does not know the widget tree'
  'lib/src/widgets|*.dart|widgets, or collaborators only a widget uses'
  'lib/src/widgets/cells|*.dart|cell widgets a body row draws'
  'test|*.dart|tests, flat — no subdirectories'
  'benchmark|*.dart|standalone benchmarks, outside every gate'
  'docs|*.md|public prose — THEMING, FEATURES, MIGRATION'
  'docs/map|README.md|the MAP entry point'
  'docs/map/territory|*.md|MAP territory notes'
  'docs/map/invariant|*.md|MAP cross-cutting invariant notes'
  'docs/agents|*.md|agent bindings'
  'scripts/thegraph|*.sh|generated scripts (bash)'
  'scripts/map|*.py|the MAP gate (python)'
  'scripts/fonts|*.py|one-off asset tooling (python)'
  '.claude/agents|ftp-*.md|generated agents'
)

# Prefixes the example owns wholesale — subdirectories are free there.
FREE_PREFIXES=(
  'example/lib/'
  'example/test/'
)

# Roots the rule claims ownership inside. A path under one of these that matches
# no rule is a VIOLATION. A path outside all of them is out of scope: the tree
# rule assigns ownership inside the roots it names, it does not adjudicate where
# a manifest goes.
SCOPE_PREFIXES=(
  'lib/'
  'test/'
  'benchmark/'
  'docs/'
  'scripts/'
  '.claude/agents/'
  'example/lib/'
  'example/test/'
)

audit=0
base=""
case "${1:-}" in
  --audit) audit=1 ;;
  "")      ;;
  *)       base="$1" ;;
esac

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

if [ "$audit" -eq 1 ]; then
  git ls-files > "$tmp"
else
  {
    git diff --name-only HEAD
    git diff --name-only --cached
    git ls-files --others --exclude-standard
    if [ -n "$base" ]; then
      git diff --name-only "$(git merge-base "$base" HEAD)...HEAD"
    fi
  } | sed '/^$/d' | sort -u > "$tmp"
fi

echo "── rules evaluated (${#RULES[@]}) ──"
for entry in "${RULES[@]}"; do
  d="${entry%%|*}"; rest="${entry#*|}"; g="${rest%%|*}"
  printf '   %s/%s\n' "$d" "$g"
done
for p in "${FREE_PREFIXES[@]}"; do printf '   %s** (subdirectories free)\n' "$p"; done
echo "── paths considered: $(wc -l < "$tmp" | tr -d ' ') ──"

owned=0; outside=0
violations=()
utils_broken=()

while IFS= read -r f; do
  [ -z "$f" ] && continue

  matched=0
  for p in "${FREE_PREFIXES[@]}"; do
    case "$f" in "$p"*) matched=1; break;; esac
  done

  if [ "$matched" -eq 0 ]; then
    dir="${f%/*}"; [ "$dir" = "$f" ] && dir="."
    name="${f##*/}"
    for entry in "${RULES[@]}"; do
      d="${entry%%|*}"; rest="${entry#*|}"; g="${rest%%|*}"
      [ "$dir" = "$d" ] || continue
      # shellcheck disable=SC2254
      case "$name" in $g) matched=1; break;; esac
    done
  fi

  if [ "$matched" -eq 1 ]; then
    owned=$((owned + 1))
    # The lib/src/utils axis is widget-AWARENESS. A Widget subclass landing there
    # breaks it, and nothing else in the repo would say so.
    case "$f" in
      lib/src/utils/*.dart)
        if [ -f "$f" ] && grep -qE 'extends (StatelessWidget|StatefulWidget|InheritedWidget|RenderObjectWidget|SingleChildRenderObjectWidget|MultiChildRenderObjectWidget|LeafRenderObjectWidget|ProxyWidget)\b' "$f"; then
          utils_broken+=("$f")
        fi
        ;;
    esac
    continue
  fi

  inscope=0
  for p in "${SCOPE_PREFIXES[@]}"; do
    case "$f" in "$p"*) inscope=1; break;; esac
  done

  if [ "$inscope" -eq 1 ]; then
    violations+=("$f")
  else
    outside=$((outside + 1))
  fi
done < "$tmp"

echo
echo "  owned by a rule : $owned"
echo "  out of scope    : $outside  (manifests, generated output, platform scaffolding)"
echo "  unruled in scope: ${#violations[@]}"

cat <<'BANNER'

  NOT CHECKED — place's unclassified rows. An undecided difference is not a
  rule, and a guard that enforced one would ratify drift:
   · U1  widgets/cells/ (3) vs widgets/table_header_cell.dart — all four are
         StatelessWidget cells; the only axis is body-row vs header consumer
   · U2  test/ flat at 55 files — the peers split 2:1
  Argue either twice and `place` writes `triggers`; `promote` counts it.
BANNER

status=0

if [ ${#utils_broken[@]} -ne 0 ]; then
  echo
  echo "PLACE: lib/src/utils declares a Widget subclass —"
  printf '  %s\n' "${utils_broken[@]}"
  echo
  echo "       That directory is 'computation that does not know the widget tree'."
  echo "       Not 'no state' (overflow_cache.dart holds six fields and belongs there)"
  echo "       and not 'not exported' (two of its files are public API). Widget"
  echo "       awareness is the axis, and this file crossed it. Move it to"
  echo "       lib/src/widgets/, or bring the rule to the maintainer — do not"
  echo "       widen it here."
  status=11
fi

if [ ${#violations[@]} -ne 0 ]; then
  echo
  echo "PLACE: inside a ruled root, owned by no rule —"
  printf '  %s\n' "${violations[@]}"
  echo
  echo "       Either it belongs in a directory that already exists, or the change"
  echo "       needs a NEW TOP-LEVEL AREA — which is place's out-edge to \`decide\`,"
  echo "       a structure call and the maintainer's by type. Do not create the"
  echo "       directory and rationalise it afterwards."
  [ "$status" -eq 0 ] && status=10
fi

if [ "$status" -ne 0 ]; then
  exit "$status"
fi

echo
echo "PLACE: every path in scope is owned by a rule, and lib/src/utils is clean."
if [ "$audit" -eq 1 ]; then
  echo "       Audited the whole tree — the rule describes what is actually on disk."
fi
