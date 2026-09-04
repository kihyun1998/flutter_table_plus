#!/usr/bin/env bash
# sacred-diff.sh — thegraph `verify` inbound guard for flutter_table_plus.
# Built from thegraph@3b21e3da2b66.
#
# Decider: code. This overrides judgement — you do not reason your way out of a
# hit because the diff looks small.
#
# Usage:  scripts/thegraph/sacred-diff.sh [base-ref]
#   no base-ref : working tree + index + untracked, against HEAD
#   base-ref    : that ref's merge-base ...HEAD, plus uncommitted work
#
# Exit:  0  no sacred path touched — the guard did not fire (enumeration risk,
#           decided by AI, still applies)
#       10  sacred path touched — the verify pass is MANDATORY
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# glob|why it costs more than a wrong number
PATTERNS=(
  'lib/src/models/theme/*|a field can be dropped silently — no test breaks, and scaledBy(1.0) hides it (#50, #116)'
  'lib/src/widgets/drag_selection_controller.dart|auto-scroll Timer + gesture state machine — a leak keeps scrolling in the consumer app'
  'lib/src/widgets/row_locator.dart|the port both sides of drag-select agree on'
  'lib/src/widgets/synced_scroll_controllers.dart|the single-coordinate-frame invariant'
  'lib/src/widgets/flutter_table_plus.dart|where edit commits and selection callbacks cross into consumer data'
  'lib/src/widgets/row_geometry.dart|drag-select hit-testing reads row geometry, never exercised against changing row heights (#128)'
  'lib/src/widgets/table_body.dart|it caches measured row heights, and shipped stale ones when calculateRowHeight changed identity (#120)'
  'lib/src/widgets/table_plus_merged_row.dart|it owns the height distribution: each member extent, and which cell absorbs the group border (#121)'
  'lib/src/utils/table_row_height_calculator.dart|public API, exported from the barrel, that every row geometry derives from'
  'lib/src/widgets/cells/table_plus_cell.dart|#155 routed the merged row through it, so one defect here lands on every plain row AND every group member at once; #156 records two live ones in it'
  'lib/src/utils/text_overflow_detector.dart|all THREE overflow call sites go through it - the ordinary cell, the header cell, the merged row spanning cell - so one defect here is three at once. #156 found four, every one silent, and a diff touching only this file touches no other sacred path'
  'lib/src/widgets/table_header.dart|a caller headerTheme.decoration is applied to the box wrapping the whole header and the body has no equivalent box. One border slid every header column against its body column: measured 2.0px, no exception, no banner, and it broke the alignment CLAUDE.md names as core (#160)'
  'lib/src/utils/row_measurement.dart|the ONE list both height caches consult. A forgotten input stales the RowGeometry every drag hit-test reads AND the scroll total (#120, #128); its identical guard read differently in JIT and AOT (#137)'
  'lib/src/utils/row_cache_invalidation.dart|the response half of that same rule: which caches an update invalidates, for both widgets that hold any. structural must dominate measurementOnly or a list sorted in place reads as a height change; the id walk sits behind two identical checks and nothing in the return value holds that order (#169)'
  'pubspec.yaml|a false floor breaks users trees while pub get succeeds here (#69, 2.16.0)'
  'CHANGELOG.md|pub.dev snapshots at publish — an edited published entry splits repo from registry (2.15.0)'
  '.pubignore|it decides the archive, and the archive cannot be un-published'
)

base="${1:-}"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
{
  git diff --name-only HEAD
  git diff --name-only --cached
  git ls-files --others --exclude-standard
  if [ -n "$base" ]; then
    git diff --name-only "$(git merge-base "$base" HEAD)...HEAD"
  fi
} | sed '/^$/d' | sort -u > "$tmp"

echo "── patterns evaluated (${#PATTERNS[@]}) ──"
for entry in "${PATTERNS[@]}"; do echo "   ${entry%%|*}"; done
echo "── files considered: $(wc -l < "$tmp" | tr -d ' ') ──"

hits=()
while IFS= read -r f; do
  [ -z "$f" ] && continue
  for entry in "${PATTERNS[@]}"; do
    pat="${entry%%|*}"; why="${entry#*|}"
    # shellcheck disable=SC2254
    case "$f" in $pat) hits+=("$f  <- $why");; esac
  done
done < "$tmp"

if [ ${#hits[@]} -eq 0 ]; then
  echo
  echo "VERIFY: guard did not fire — no sacred path in this diff."
  echo "        Enumeration risk still decides (decider: AI): many edges, domain"
  echo "        semantics, cross-feature interaction. Nothing is skipped here."
  exit 0
fi

echo
echo "VERIFY: MANDATORY — sacred paths touched:"
printf '  %s\n' "${hits[@]}"
echo
echo "        Both corpora, both lenses (gap + refute). The guard overrides judgement."
exit 10
