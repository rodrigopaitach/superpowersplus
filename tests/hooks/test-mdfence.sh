#!/usr/bin/env bash
#
# Tests for skills/writing-plans/scripts/mdfence.py.
#
# The cases that matter are the ones the naive toggle this module replaces gets
# wrong: a three-backtick block nested inside a four-backtick block, an opener
# carrying leading spaces, and a tilde fence. Measured 2026-08-24, the naive
# toggle and this rule classify 77 structural headings differently across 6
# documents of this repository.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODULE_DIR="$REPO_ROOT/skills/writing-plans/scripts"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

# run_py <name> <python body> — body asserts; a raised AssertionError fails.
run_py() {
    local name="$1" body="$2"
    # -B: importing the module must not leave a __pycache__ beside it. The
    # carriers set sys.dont_write_bytecode for the same reason — the gates run
    # from a pre-commit hook, inside an installed plugin nobody wants written to.
    if python3 -B -c "
import sys
sys.path.insert(0, '$MODULE_DIR')
from mdfence import fence_mask, prose
$body
" 2>"$TEST_ROOT/err"; then
        pass "$name"
    else
        fail "$name"
        sed 's/^/        /' <"$TEST_ROOT/err"
    fi
}

echo "Testing mdfence"

run_py "nested fence keeps inner content fenced" '
lines = ["before", "````markdown", "# inner", "```md", "## deep", "```", "````", "after"]
mask, unclosed = fence_mask(lines)
assert unclosed is None, unclosed
assert mask[0] is False, "line before the fence"
assert mask[2] is True, "heading inside the outer block"
assert mask[4] is True, "heading inside the nested block"
assert mask[7] is False, "line after the fence"
'

run_py "indented opener is recognised" '
lines = ["   ```", "## fenced", "   ```", "## real"]
mask, _ = fence_mask(lines)
assert mask[1] is True, "heading under an indented opener"
assert mask[3] is False, "heading after the indented close"
'

run_py "tilde fence behaves like a backtick fence" '
lines = ["~~~", "## fenced", "```", "still fenced", "~~~", "## real"]
mask, _ = fence_mask(lines)
assert mask[1] is True, "heading inside the tilde block"
assert mask[3] is True, "a backtick line does not close a tilde block"
assert mask[5] is False, "heading after the tilde close"
'

run_py "an unclosed fence is reported with its line" '
lines = ["a", "```", "## swallowed"]
mask, unclosed = fence_mask(lines)
assert unclosed == 2, unclosed
assert mask[2] is True, "everything after an unclosed opener is fenced"
'

run_py "prose blanks fenced lines and keeps numbering" '
lines = ["## real", "```", "## fenced", "```", "## also real"]
out = prose(lines)
assert len(out) == len(lines), (len(out), len(lines))
assert out[0] == "## real"
assert out[2] == ""
assert out[4] == "## also real"
'

# --- the module ships where the packager stages ----------------------------
# scripts/package-codex-plugin.sh stages `skills` wholesale and fails the build
# on any archived path beginning `scripts/`. A module at the repository root
# would reach Claude Code, whose plugin cache is a full checkout, and not Codex,
# where check-cross-references still ships and would fail to import.
packager="$REPO_ROOT/scripts/package-codex-plugin.sh"
if [ -f "$MODULE_DIR/mdfence.py" ] &&
   printf '%s' "$MODULE_DIR" | grep -q "/skills/" &&
   grep -q '\^scripts/' "$packager"; then
    pass "the module ships where the packager stages"
else
    fail "the module ships where the packager stages"
    echo "        module dir: $MODULE_DIR"
    grep -n '\^scripts/' "$packager" | sed 's/^/        /'
fi

# --- the module carries no dependency ---------------------------------------
# An absent module must fail this case, not pass it: grep over a missing file
# matches nothing, and a negation over nothing approves the absence.
if [ ! -f "$MODULE_DIR/mdfence.py" ]; then
    fail "module imports only re"
    echo "        module not found: $MODULE_DIR/mdfence.py"
elif grep -nE "^(import|from) " "$MODULE_DIR/mdfence.py" | grep -qvE "^[0-9]+:import re$"; then
    fail "module imports only re"
    grep -nE "^(import|from) " "$MODULE_DIR/mdfence.py" | sed 's/^/        /'
else
    pass "module imports only re"
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All mdfence tests passed"
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
