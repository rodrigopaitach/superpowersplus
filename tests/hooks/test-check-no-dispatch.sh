#!/usr/bin/env bash
#
# Tests for scripts/check-no-dispatch.sh.
#
# The script resolves its repository root from its own location and reads a
# hardcoded carrier list, so each case builds a throwaway tree with the script
# installed and all seven carrier files present. That exercises the real
# script — its real carrier list — rather than a parameterized variant that
# only exists for tests.
#
# The third case is the one that matters most: a file carrying the clause that
# is NOT on the declared list must change nothing. A gate that globbed for the
# marker instead of declaring its carriers would pass that case wrongly, and a
# carrier that silently lost the clause would then be indistinguishable from a
# file that never had it.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-no-dispatch.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

CARRIERS=(
  "skills/subagent-driven-development/implementer-prompt.md"
  "skills/subagent-driven-development/task-reviewer-prompt.md"
  "skills/subagent-driven-development/re-review-prompt.md"
  "skills/requesting-code-review/code-reviewer.md"
  "skills/brainstorming/spec-document-reviewer-prompt.md"
  "skills/writing-plans/plan-document-reviewer-prompt.md"
  "skills/final-branch-audit/SKILL.md"
)

CLAUSE='    ## You Do Not Dispatch Subagents'
BODY='    Do all of this yourself. Never dispatch a subagent.'

# $1 = lab name. Builds a tree with every carrier holding the clause.
build_lab() {
  local dir="$TEST_ROOT/$1"
  mkdir -p "$dir/scripts"
  cp "$SCRIPT_UNDER_TEST" "$dir/scripts/check-no-dispatch.sh"
  chmod +x "$dir/scripts/check-no-dispatch.sh"
  local rel
  for rel in "${CARRIERS[@]}"; do
    mkdir -p "$dir/$(dirname "$rel")"
    printf '# A carrier\n\n%s\n\n%s\n' "$CLAUSE" "$BODY" >"$dir/$rel"
  done
  printf '%s' "$dir"
}

# $1 = label, $2 = expected exit, $3 = actual exit
assert_exit() {
  if [ "$2" -eq "$3" ]; then
    printf '  ok: %s\n' "$1"
  else
    printf '  FAIL: %s — expected exit %s, got %s\n' "$1" "$2" "$3"
    FAILURES=$((FAILURES + 1))
  fi
}

printf 'all carriers present passes\n'
lab="$(build_lab allpresent)"
set +e
(cd "$lab" && ./scripts/check-no-dispatch.sh >/dev/null 2>&1)
status=$?
set -e
assert_exit "exits 0" 0 "$status"

printf 'a carrier missing the clause fails\n'
lab="$(build_lab onemissing)"
printf '# A carrier\n\nBody with no clause.\n' >"$lab/${CARRIERS[3]}"
set +e
out="$(cd "$lab" && ./scripts/check-no-dispatch.sh 2>&1)"
status=$?
set -e
assert_exit "exits 1" 1 "$status"
if printf '%s' "$out" | grep -q "${CARRIERS[3]}"; then
  printf '  ok: names the carrier that lost it\n'
else
  printf '  FAIL: the failure does not name %s\n' "${CARRIERS[3]}"
  FAILURES=$((FAILURES + 1))
fi

printf 'an undeclared file with the clause is ignored\n'
lab="$(build_lab undeclared)"
printf '# Not a carrier\n\n%s\n\n%s\n' "$CLAUSE" "$BODY" >"$lab/skills/decoy.md"
printf '# A carrier\n\nBody with no clause.\n' >"$lab/${CARRIERS[0]}"
set +e
(cd "$lab" && ./scripts/check-no-dispatch.sh >/dev/null 2>&1)
status=$?
set -e
assert_exit "the decoy does not rescue a missing carrier" 1 "$status"


printf 'a reworded clause body fails\n'
lab="$(build_lab reworded)"
printf '# A carrier\n\n%s\n\n    Feel free to dispatch helpers when convenient.\n' \
  "$CLAUSE" >"$lab/${CARRIERS[1]}"
set +e
out="$(cd "$lab" && ./scripts/check-no-dispatch.sh 2>&1)"
status=$?
set -e
assert_exit "exits 1" 1 "$status"
if printf '%s' "$out" | grep -q 'body differs'; then
  printf '  ok: names the disagreement, not a missing heading\n'
else
  printf '  FAIL: the heading survived, so the gate must charge the body\n'
  printf '        output: %s\n' "$out"
  FAILURES=$((FAILURES + 1))
fi

printf 'a flush-left clause fails\n'
lab="$(build_lab flushleft)"
printf '# A carrier\n\n%s\n\n%s\n' \
  "$(printf '%s' "$CLAUSE" | sed 's/^ *//')" "$(printf '%s' "$BODY" | sed 's/^ *//')" \
  >"$lab/${CARRIERS[6]}"
set +e
out="$(cd "$lab" && ./scripts/check-no-dispatch.sh 2>&1)"
status=$?
set -e
assert_exit "exits 1" 1 "$status"
if printf '%s' "$out" | grep -q 'flush-left'; then
  printf '  ok: a clause outside the prompt body is not a clause\n'
else
  printf '  FAIL: flush-left placement was accepted\n'
  printf '        output: %s\n' "$out"
  FAILURES=$((FAILURES + 1))
fi

printf 'an unreadable carrier fails\n'
lab="$(build_lab unreadable)"
rm "$lab/${CARRIERS[2]}"
set +e
out="$(cd "$lab" && ./scripts/check-no-dispatch.sh 2>&1)"
status=$?
set -e
assert_exit "exits 1" 1 "$status"
if printf '%s' "$out" | grep -q 'could not be read'; then
  printf '  ok: a renamed or deleted carrier is not silently a pass\n'
else
  printf '  FAIL: the unreadable branch did not report\n'
  printf '        output: %s\n' "$out"
  FAILURES=$((FAILURES + 1))
fi

if [ "$FAILURES" -eq 0 ]; then
  printf '\nAll cases passed.\n'
else
  printf '\n%s case(s) failed.\n' "$FAILURES"
  exit 1
fi
