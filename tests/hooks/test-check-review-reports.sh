#!/usr/bin/env bash
#
# Tests for scripts/check-review-reports.sh.
#
# The gate resolves its repository root from its own location, like every other
# whole-tree gate here (scripts/check-links.sh:40, scripts/check-evidence-line.sh:40),
# so each case COPIES it into a throwaway tree and builds the ledger there.
#
# Do not switch this to `cd "$tree" && "$SCRIPT_UNDER_TEST"`, the idiom
# tests/hooks/test-check-changelog.sh uses. That works only because
# scripts/check-changelog.sh has no root resolution at all. Run a $0-rooted
# gate that way and it reads the REAL docs/superpowers/review-yield.md in every
# case — and the two cases that expect exit 0 would then pass without their
# fixtures ever being opened, because the real ledger also exits 0. Those two
# are the silent ones; the three that expect non-zero would fail loudly. That
# asymmetry is why the last two cases assert on the path the gate REPORTS, not
# only on its status.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-review-reports.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

PROBLEMS=()
T=""

begin() {
    PROBLEMS=()
    T="$(mktemp -d "$TEST_ROOT/tree.XXXXXX")"
    mkdir -p "$T/scripts" "$T/docs/superpowers/reviews"
    # `|| note` and not a bare cp: under `set -e` a missing gate would abort
    # the suite at the first case instead of failing all five, and a partial
    # run reports fewer failures than there are.
    cp "$SCRIPT_UNDER_TEST" "$T/scripts/check-review-reports.sh" 2>/dev/null \
        || note "scripts/check-review-reports.sh could not be copied into the tree"
}

note() {
    PROBLEMS+=("$1")
}

end() {
    if [ "${#PROBLEMS[@]}" -eq 0 ]; then
        echo "  [PASS] $1"
    else
        echo "  [FAIL] $1"
        local problem
        for problem in ${PROBLEMS[@]+"${PROBLEMS[@]}"}; do
            echo "        $problem"
        done
        FAILURES=$((FAILURES + 1))
    fi
}

# run_gate — runs the copied gate from inside its own tree.
run_gate() {
    STATUS=0
    bash "$T/scripts/check-review-reports.sh" >"$T/.stdout" 2>"$T/.stderr" || STATUS=$?
    OUT="$(cat "$T/.stdout" 2>/dev/null || true)"
    ERR="$(cat "$T/.stderr" 2>/dev/null || true)"
}

SEVEN_HEADER='| Date | Branch | Face | Round | Blocking findings | Still open from the previous round | Report |
|---|---|---|---|---|---|---|'
SIX_HEADER='| Date | Branch | Face | Round | Blocking findings | Still open from the previous round |
|---|---|---|---|---|---|'

echo "Test: check-review-reports.sh"

# --- 1. a linked report that is not there ----------------------------------
begin
{
    printf '# Review yield\n\n%s\n' "$SEVEN_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — | [report](reviews/gone.md) |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -ne 0 ] || note "exit 0, expected non-zero"
printf '%s' "$ERR" | grep -q 'review-yield.md:5' || note "the failure does not name the row: $ERR"
printf '%s' "$ERR" | grep -q 'reviews/gone.md' || note "the failure does not name the link: $ERR"
end "missing destination"

# --- 2. a linked report with no bytes in it --------------------------------
begin
: > "$T/docs/superpowers/reviews/r.md"
{
    printf '# Review yield\n\n%s\n' "$SEVEN_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — | [report](reviews/r.md) |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -ne 0 ] || note "exit 0, expected non-zero"
printf '%s' "$ERR" | grep -q 'empty' || note "the failure does not say the file is empty: $ERR"
end "empty destination"

# --- 3. two rows pointing at one report ------------------------------------
# Both rows are named. A failure naming only the second leaves the reader
# hunting for the row it collided with.
begin
printf 'a report\n' > "$T/docs/superpowers/reviews/r.md"
{
    printf '# Review yield\n\n%s\n' "$SEVEN_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — | [report](reviews/r.md) |\n'
    printf '| 06/09/2026 | b | spec | 2 | 0 | 0 | [report](reviews/r.md) |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -ne 0 ] || note "exit 0, expected non-zero"
printf '%s' "$ERR" | grep -q 'review-yield.md:6' || note "the failure does not name the second row: $ERR"
printf '%s' "$ERR" | grep -q 'review-yield.md:5' || note "the failure does not name the first row: $ERR"
end "duplicate destinations"

# --- 4. a ledger that has no seventh column at all -------------------------
# This is the state of this repository's own ledger until the column is added,
# and the state of every partner project that has adopted nothing. A gate
# written to REQUIRE a seventh cell passes case 5 and fails this one.
#
# The path assertion is what separates this from a gate that read the real
# ledger: that one also exits 0, and nothing about its output would look wrong.
begin
{
    printf '# Review yield\n\n%s\n' "$SIX_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
printf '%s' "$OUT" | grep -q "reading $T/" \
    || note "the gate did not report reading this case's ledger: [$OUT]"
end "a six-column ledger is green"

# --- 5. a seventh column whose every cell is an em-dash --------------------
begin
{
    printf '# Review yield\n\n%s\n' "$SEVEN_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — | — |\n'
    printf '| 06/09/2026 | b | spec | 2 | 0 | 0 | — |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
printf '%s' "$OUT" | grep -q "reading $T/" \
    || note "the gate did not report reading this case's ledger: [$OUT]"
end "an em-dash ledger is green"

# --- 6. the whole point, stated positively ---------------------------------
# Three cases assert what fails and two what is tolerated; without this one
# nothing asserts that a correct row PASSES, and a gate that rejected every
# ledger would satisfy all five.
#
# The path assertion is here for the same reason as in cases 4 and 5: this
# case expects exit 0, and so does a run that read the real ledger.
begin
printf 'a review report with bytes in it\n' > "$T/docs/superpowers/reviews/r.md"
{
    printf '# Review yield\n\n%s\n' "$SEVEN_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — | [spec 1](reviews/r.md) |\n'
    printf '| 06/09/2026 | b | spec | 2 | 0 | 0 | — |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
printf '%s' "$OUT" | grep -q "reading $T/" \
    || note "the gate did not report reading this case's ledger: [$OUT]"
printf '%s' "$OUT" | grep -q '1 linked report' || note "the gate did not count the link: [$OUT]"
end "a linked report that is there passes"

# --- 7-9. the cell forms the contract does NOT admit -----------------------
# skills/requesting-code-review/references/review-yield.md admits exactly two
# things in this cell: an em-dash, or a markdown link. Everything else has to
# fail, and the backticked path is the one that matters: it looks right to a
# reader, satisfies the column rule, and is read by no link gate at all —
# which is the silent failure AC21 exists to prevent.
begin
{
    printf '# Review yield\n\n%s\n' "$SEVEN_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — |  |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -ne 0 ] || note "exit 0, expected non-zero — an empty cell was accepted"
end "an empty cell fails"

begin
{
    printf '# Review yield\n\n%s\n' "$SEVEN_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — | - |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -ne 0 ] || note "exit 0, expected non-zero — a plain hyphen was accepted"
end "a plain hyphen fails"

begin
printf 'a review report with bytes in it\n' > "$T/docs/superpowers/reviews/r.md"
{
    printf '# Review yield\n\n%s\n' "$SEVEN_HEADER"
    printf '| 06/09/2026 | b | spec | 1 | 3 | — | `reviews/r.md` |\n'
} > "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -ne 0 ] || note "exit 0, expected non-zero — a backticked path was accepted"
printf '%s' "$ERR" | grep -q 'markdown link' \
    || note "the failure does not say what the cell must be: $ERR"
end "a backticked path fails"

# --- 10. no ledger at all --------------------------------------------------
# Declared in the gate's own header: a gate that passes when it cannot find its
# input is indistinguishable from a gate that found nothing wrong.
begin
rm -f "$T/docs/superpowers/review-yield.md"
run_gate
[ "$STATUS" -ne 0 ] || note "exit 0, expected non-zero — a missing ledger was accepted"
end "a missing ledger fails"

echo
if [ "$FAILURES" -gt 0 ]; then
    echo "$FAILURES check-review-reports test(s) failed"
    exit 1
fi
echo "All check-review-reports tests passed"
