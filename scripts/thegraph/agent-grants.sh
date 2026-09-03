#!/usr/bin/env bash
# agent-grants.sh — thegraph `gate`: every generated agent's tool grant.
# Built from thegraph@3b21e3da2b66.
#
# Decider: code. Invariant (1) licenses delegating a node on the grounds that it
# READS without adjudicating. A write-capable tool in the grant makes that false
# no matter what the prose above it says, so the grant is the license and this
# is where it is checked.
#
# ASSERT THE DEFAULT, NEVER THE CLAIM. This asks "is a write-capable tool
# granted, and does the brief declare a command naming it?" — it does NOT look
# for the words "read-only". That was written first and let through an agent
# granted a shell whose description read "proposes edits rather than making
# them": same claim, different words, no violation reported. A generated
# artifact that can dodge its own check by rephrasing has not been checked.
#
# What this CANNOT see: a brief WIDER than its grant. That is the caller's error,
# made at invocation time against a static file, and what stands in for a check
# there is the delegated node's obligation to say what it could not reach.
#
# Usage:  scripts/thegraph/agent-grants.sh
#
# Exit:  0  every generated agent's grant matches its brief
#       12  a write-capable tool is granted without a declaration naming it
#       13  no generated agent found — the check would pass vacuously
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# Tools that can change state. The test is the PROPERTY, not the name: reading a
# corpus is Read/Grep/Glob, and a fetcher reaching the network with WebFetch or
# WebSearch is still read-only. These are the ones that are not.
WRITE_CAPABLE=(Bash Write Edit MultiEdit NotebookEdit Task Agent '*')

shopt -s nullglob
agents=(.claude/agents/ftp-*.md)
shopt -u nullglob

if [ ${#agents[@]} -eq 0 ]; then
  echo "GRANTS: no .claude/agents/ftp-*.md found."
  echo "        A check with nothing to check passes vacuously, which is the one"
  echo "        result it must never return. Rebuild with /grill-the-graph."
  exit 13
fi

echo "── generated agents (${#agents[@]}) ──"

violations=()
declared=()

for f in "${agents[@]}"; do
  # The tools: line inside the frontmatter block, first occurrence only.
  tools=$(awk '/^---$/{n++; next} n==1 && /^tools:[[:space:]]*/{sub(/^tools:[[:space:]]*/,""); print; exit}' "$f")
  body=$(cat "$f")

  printf '   %-34s %s\n' "${f##*/}" "${tools:-<none>}"

  for t in "${WRITE_CAPABLE[@]}"; do
    # Word-boundary match against the comma-separated grant.
    case ",${tools// /}," in
      *",$t,"*) ;;
      *) continue ;;
    esac

    # A declaration must NAME the tool it licenses, on a **Runs:** line.
    # "**Runs:** nothing much" licenses nothing — that was the first form of
    # this rule and it was a formality, not a check.
    if printf '%s' "$body" | grep -qE '^\*\*Runs:\*\*.*`'"$t"'`'; then
      declared+=("${f##*/}  grants $t  — declared")
    else
      violations+=("${f##*/}  grants $t  — NO **Runs:** line names \`$t\`")
    fi
  done
done

if [ ${#declared[@]} -ne 0 ]; then
  echo
  echo "  declared, and licensed by that declaration:"
  printf '    %s\n' "${declared[@]}"
fi

if [ ${#violations[@]} -ne 0 ]; then
  echo
  echo "GRANTS: a delegated node holds a tool that can write, undeclared —"
  printf '    %s\n' "${violations[@]}"
  cat <<'WHY'

        Read-only is the DEFAULT, not a claim to be matched. Either remove the
        tool, or declare it in the brief in the form invariant (1) fixes:

          **Runs:** `Bash`, for one thing only — `tar -xzf docs/.../*.tgz`,
          because the source class is a gzipped archive and `Read` cannot
          decompress it.

        The declaration must NAME each tool it licenses. A node that can write
        is one whose report a later run has to take on trust, and the
        declaration is the price of that.

        This is not hypothetical here: #131. Four agents each said "Read-only",
        each held `Bash`, and no brief asked for a command. One mutated lib/
        while the refuting lens was reading it, and the refuter graded the run
        UNADJUDICATED on evidence that was the other pass's artifact.
WHY
  exit 12
fi

echo
echo "GRANTS: every generated agent's grant matches its brief."
echo "        Not checked, and uncheckable here: a brief that names what its"
echo "        grant cannot reach. That is the caller's error — the delegated"
echo "        node must say so when it happens."
