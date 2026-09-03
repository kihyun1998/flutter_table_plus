#!/usr/bin/env bash
# gates.sh — thegraph `gate` node for flutter_table_plus.
# Built from thegraph@3b21e3da2b66.
#
# There is NO CI in this repo. These are the only gates.
#
# Every command runs BARE — never piped. A pipeline's exit status is the last
# command's, so `flutter test | tail -1 && commit` always commits. A gate you
# cannot fail is not a gate.
#
# Runs ALL gates even after one fails: a partial matrix reads as a full one.
# Never lower a threshold to turn this green.
#
# Exit:  0  every gate passed
#        1  at least one gate failed (see the summary)
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"

names=(); codes=(); notes=()

run() {                       # run <label> <dir> <cmd...>
  local label="$1" dir="$2"; shift 2
  echo
  echo "══ $label ══"
  echo "   \$ $* ${dir:+(in $dir)}"
  ( cd "${dir:-.}" && "$@" )   # bare: no pipe, no tee, no redirect
  local code=$?
  names+=("$label"); codes+=("$code"); notes+=("")
  echo "   → exit $code"
}

skip() {                      # skip <label> <why>
  echo
  echo "══ $1 ══"
  echo "   NOT APPLICABLE: $2"
  names+=("$1"); codes+=(0); notes+=("$2")
}

run "analyze"         ""        flutter analyze
run "format"          ""        dart format --output=none --set-exit-if-changed lib test
run "test"            ""        flutter test
run "example:analyze" "example" flutter analyze
run "example:test"    "example" flutter test
run "map:check"       ""        python scripts/map/check_map.py docs/map
# A BASE REF, and it is load-bearing. `place` runs this bare before `implement`,
# when the work is uncommitted and the working tree IS the diff. By the time
# `gate` runs, the work is committed and a bare run considers ZERO paths and
# passes — measured 2026-09-03: 0 paths after the commit, 14 against main. A
# gate that cannot fail is not a gate.
BASE="${GATES_BASE:-$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')}"
BASE="${BASE:-main}"
run "tree-rule"       ""        scripts/thegraph/tree-rule.sh "$BASE"
run "slot-authority"  ""        scripts/thegraph/slot-authority.sh
run "agent-grants"    ""        scripts/thegraph/agent-grants.sh
# The dry-run validates the archive, but it also insists the version is an
# increment over what is published — and between releases pubspec.yaml sits AT
# the published version, so the gate is red for every change that is not a
# release. A gate that is always red is a gate everyone learns to ignore, which
# is #55's lesson about the example suite arriving at the same place.
#
# So it is asked first whether it can mean anything right now. This is not a
# lowered threshold: when the version IS ahead of the registry — the only time
# publishing is possible — the gate runs unchanged and its failure is fatal.
# When it is not, the gate says so out loud rather than passing quietly.
published=$(curl -fsS --max-time 10 https://pub.dev/api/packages/flutter_table_plus 2>/dev/null \
  | python -c "import json,sys; print(json.load(sys.stdin)['latest']['version'])" 2>/dev/null)
local_version=$(sed -n 's/^version: *//p' pubspec.yaml | tr -d '\r')

if [ -z "$published" ]; then
  # No answer is not the same as "not applicable" - run it and let it speak.
  run "publish:dry-run" ""      flutter pub publish --dry-run
elif [ "$published" = "$local_version" ]; then
  skip "publish:dry-run" "pubspec is at $local_version, already the published latest"
else
  run "publish:dry-run" ""      flutter pub publish --dry-run
fi

echo
echo "══ summary ══"
failed=0
for i in "${!names[@]}"; do
  if [ "${codes[$i]}" -eq 0 ]; then
    if [ -n "${notes[$i]}" ]; then
      printf '  N/A   %s  (%s)\n' "${names[$i]}" "${notes[$i]}"
    else
      printf '  PASS  %s\n' "${names[$i]}"
    fi
  else
    printf '  FAIL  %s  (exit %s)\n' "${names[$i]}" "${codes[$i]}"
    failed=1
  fi
done

cat <<'NOTE'

  Known blind spots — these gates do NOT cover them:
  · example/lib is outside `dart format` (deliberate: a demo, not published API)
  · publish:dry-run DOES report uncommitted changes to files inside the archive
    (measured 2026-08-25: it named a modified example/lib/pages/home_page.dart).
    What it cannot see is anything the root .pubignore excludes — docs/, scripts/,
    benchmark/ — because a root .pubignore turns off git-based file listing there.
    A green dry-run is still not evidence of a clean tree; run `git status`.
  · map:check verifies ATTRIBUTION, not location: resolve_dart searches
    lib/src -> lib -> example -> . , so a moved file still resolves. Placement is
    tree-rule's job and the two do not overlap.
  · tree-rule deliberately does NOT check place's unclassified rows U1 and U2.
    An undecided difference is not a rule, and enforcing one would ratify drift.
  · agent-grants asserts the DEFAULT, never the claim: it asks whether a generated
    agent holds a write-capable tool and whether a **Runs:** line names it. It does
    NOT look for the words "read-only" — an agent granted a shell whose description
    read "proposes edits rather than making them" passed a check that did. It also
    cannot see the opposite error: a brief WIDER than its grant is the caller's,
    made at invocation time, and only the delegated node saying so surfaces it.
  · anything that opens a window (flutter run) is not an agent gate — ask the user
NOTE

if [ "$failed" -ne 0 ]; then
  echo
  echo "  Back-edge to implement. Bound: three consecutive failures with the SAME"
  echo "  signature route to decide — the same failure surviving three fixes is a"
  echo "  design question, not a gate question."
  exit 1
fi
echo
echo "  All gates green. flutter pub publish itself is irreversible — the USER runs it."
