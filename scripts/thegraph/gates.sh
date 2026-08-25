#!/usr/bin/env bash
# gates.sh — thegraph `gate` node for flutter_table_plus.
# Built from thegraph@100dbdb10d85.
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

names=(); codes=()

run() {                       # run <label> <dir> <cmd...>
  local label="$1" dir="$2"; shift 2
  echo
  echo "══ $label ══"
  echo "   \$ $* ${dir:+(in $dir)}"
  ( cd "${dir:-.}" && "$@" )   # bare: no pipe, no tee, no redirect
  local code=$?
  names+=("$label"); codes+=("$code")
  echo "   → exit $code"
}

run "analyze"         ""        flutter analyze
run "format"          ""        dart format --output=none --set-exit-if-changed lib test
run "test"            ""        flutter test
run "example:analyze" "example" flutter analyze
run "example:test"    "example" flutter test
run "publish:dry-run" ""        flutter pub publish --dry-run

echo
echo "══ summary ══"
failed=0
for i in "${!names[@]}"; do
  if [ "${codes[$i]}" -eq 0 ]; then
    printf '  PASS  %s\n' "${names[$i]}"
  else
    printf '  FAIL  %s  (exit %s)\n' "${names[$i]}" "${codes[$i]}"
    failed=1
  fi
done

cat <<'NOTE'

  Known blind spots — these gates do NOT cover them:
  · example/lib is outside `dart format` (deliberate: a demo, not published API)
  · publish:dry-run does NOT see uncommitted changes — the root .pubignore turns
    off git-based file listing, so a dirty tree still passes with 0 warnings.
    A green dry-run is not evidence of a clean tree; run `git status` yourself.
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
