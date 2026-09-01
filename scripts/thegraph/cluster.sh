#!/usr/bin/env bash
# cluster.sh — thegraph `search` node for flutter_table_plus (query half only).
# Built from thegraph@b188918a1bba.
#
# Search BY THE ARTIFACT the candidate touches — the module, the field, the
# predicate, the config key — NEVER by the feature name. A related issue almost
# never shares your vocabulary.
#
# Usage:  scripts/thegraph/cluster.sh <artifact> [<artifact> ...]
#   e.g.  scripts/thegraph/cluster.sh scaledBy rowTooltipTheme
#         scripts/thegraph/cluster.sh RowLocator idsBetween
#
# THIS SCRIPT DECIDES NOTHING. It owns the query and hands back candidates.
# The four outs — already-exists / conflict / sibling / nothing — are adjudicated
# on the main thread. In particular the CONFLICT out ("an existing issue whose
# proposal this change would break") is judgement and no query finds it: a
# conflicting issue almost never shares your vocabulary. A script that silently
# answered "nothing" for that out would be mislabelled (invariant ④).
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"

if [ $# -eq 0 ]; then
  echo "usage: $0 <artifact> [<artifact> ...]   # symbols/paths, not feature names"
  exit 64
fi

for artifact in "$@"; do
  echo
  echo "══ artifact: $artifact ══"

  echo "── open issues ──"
  gh issue list --state open --search "$artifact" --limit 20 \
     --json number,title,labels \
     --jq '.[] | "  #\(.number) \(.title)  [\([.labels[].name] | join(","))]"'

  echo "── closed issues (they hold the rejected alternatives) ──"
  gh issue list --state closed --search "$artifact" --limit 20 \
     --json number,title \
     --jq '.[] | "  #\(.number) \(.title)"'

  echo "── this artifact in the changelog (this repo's bug inventory) ──"
  grep -n -- "$artifact" CHANGELOG.md | head -10 || echo "  (no changelog mention)"
done

cat <<'NOTE'

══ before you propose an anchor ══
  Areas already carrying a DECISION RECORD, accepted or proposed:  NONE.
  docs/adr/ does not exist yet, so nothing preempts an anchor today.
  Only a decision record preempts one. The module map in docs/agents/thegraph.md
  does NOT: it is descriptive and lives in a file, while a roster is current
  state and needs a mutable home.

══ what the query cannot answer ══
  · CONFLICT — an existing issue whose proposal this change would break.
    Judgement, on the main thread. No query finds it.
  · Whether a match shares your ROOT or only your PROVENANCE. Different claims;
    only the root routes.

══ if you open an anchor ══
  Its roster is the SUBTREE, not a list in the body. GitHub sub-issues are
  available here, so enroll siblings through the relation:
    gh api repos/{owner}/{repo}/issues/<anchor>/sub_issues -f sub_issue_id=<id>
  An anchor opens at issue TWO — enroll the siblings that motivated it in the
  same batch that opens it, or it under-reports its own cluster from day one.
NOTE
