#!/usr/bin/env bash
#
# Tests for scripts/check-evidence-line.sh.
#
# The script resolves its repository root from its own location and reads a
# hardcoded list of carriers, so each case builds a throwaway tree with the
# script installed and all five carrier files present. That exercises the real
# script — its real carrier list, its real chaining rule — rather than a
# parameterized variant that only exists for tests.
#
# The two states that matter are the last two cases: a field REMOVED must fail,
# and the same fields REFORMATTED must pass. A gate that cannot tell those
# apart is a formatting linter wearing a gate's name.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-evidence-line.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() {
    echo "  [PASS] $1"
}

fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

CARRIERS=(
    "skills/executing-plans/SKILL.md"
    "skills/requesting-code-review/code-reviewer.md"
    "skills/subagent-driven-development/implementer-prompt.md"
    "skills/subagent-driven-development/re-review-prompt.md"
    "skills/subagent-driven-development/task-reviewer-prompt.md"
)

# The canonical form, as one indented wrapped line — the shape four of the five
# carriers actually use.
canonical_form() {
    cat <<'EOF'
    Some prose above the form.

    **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/failed/
    skipped]

    Some prose below it.
EOF
}

# new_tree — throwaway tree with the script and all five carriers. Echoes path.
new_tree() {
    local tree
    tree="$(mktemp -d "$TEST_ROOT/tree.XXXXXX")"
    mkdir -p "$tree/scripts"
    cp "$SCRIPT_UNDER_TEST" "$tree/scripts/check-evidence-line.sh"
    local carrier
    for carrier in "${CARRIERS[@]}"; do
        mkdir -p "$tree/$(dirname "$carrier")"
        canonical_form > "$tree/$carrier"
    done
    printf '%s\n' "$tree"
}

run_check() {
    bash "$1/scripts/check-evidence-line.sh" >/dev/null 2>&1
}

echo "Testing check-evidence-line.sh"

# --- the real repository -----------------------------------------------------

if bash "$SCRIPT_UNDER_TEST" >/dev/null 2>&1; then
    pass "this repository's five carriers agree"
else
    fail "this repository's five carriers agree"
fi

# --- baseline ----------------------------------------------------------------

tree="$(new_tree)"
if run_check "$tree"; then
    pass "identical carriers pass"
else
    fail "identical carriers pass"
fi

# --- a declared carrier missing ----------------------------------------------

tree="$(new_tree)"
rm "$tree/skills/executing-plans/SKILL.md"
if run_check "$tree"; then
    fail "a missing carrier file fails"
else
    pass "a missing carrier file fails"
fi

# --- a carrier that lost the form entirely -----------------------------------

tree="$(new_tree)"
printf 'Run the tests and report what happened.\n' \
    > "$tree/skills/subagent-driven-development/re-review-prompt.md"
if run_check "$tree"; then
    fail "a carrier with no evidence line at all fails"
else
    pass "a carrier with no evidence line at all fails"
fi

# --- MUTATION: one field removed from one carrier ----------------------------
# The failure this gate exists for. `**exit:**` disappears from one carrier and
# the other four keep it.

tree="$(new_tree)"
cat > "$tree/skills/subagent-driven-development/task-reviewer-prompt.md" <<'EOF'
    Some prose above the form.

    **Command:** [verbatim] — **counts:** [passed/failed/skipped]

    Some prose below it.
EOF
if run_check "$tree"; then
    fail "MUTATION: dropping **exit:** from one carrier fails"
else
    pass "MUTATION: dropping **exit:** from one carrier fails"
fi

# --- MUTATION: a field ADDED to one carrier ----------------------------------
# Divergence runs both ways: a carrier that grows a field is as out of step as
# one that loses it.

tree="$(new_tree)"
cat > "$tree/skills/requesting-code-review/code-reviewer.md" <<'EOF'
    **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/failed/
    skipped] — **duration:** [ms]
EOF
if run_check "$tree"; then
    fail "MUTATION: a sixth field on one carrier fails"
else
    pass "MUTATION: a sixth field on one carrier fails"
fi

# --- THE OTHER STATE: formatting changed, fields identical -------------------
# Everything the gate is required to tolerate, in one file: no indentation, the
# whole form on one line, a prose prefix before the marker, and a different
# trailing suffix.

tree="$(new_tree)"
cat > "$tree/skills/executing-plans/SKILL.md" <<'EOF'
- **Finishing:** what was delivered, and the test evidence from the run you made after your last edit — never a count carried from earlier: **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/failed/skipped] (base: [BASE_TEST_COUNT])
EOF
if run_check "$tree"; then
    pass "REFORMAT: unindented, unwrapped, prefixed and suffixed still passes"
else
    fail "REFORMAT: unindented, unwrapped, prefixed and suffixed still passes"
fi

# --- REFORMAT: wrapped mid-field --------------------------------------------
# The 1.8.2 lesson applied here: a check that reads line by line misses a form
# an editor split across lines, goes quiet, and shows the author a pass.

tree="$(new_tree)"
cat > "$tree/skills/subagent-driven-development/implementer-prompt.md" <<'EOF'
      **Command:**
      [verbatim]
      —
      **exit:** [code]
      — **counts:**
      [passed/failed/skipped]
EOF
if run_check "$tree"; then
    pass "REFORMAT: a form split across six lines still passes"
else
    fail "REFORMAT: a form split across six lines still passes"
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All check-evidence-line tests passed"
    exit 0
fi
echo "$FAILURES check-evidence-line test(s) failed"
exit 1
