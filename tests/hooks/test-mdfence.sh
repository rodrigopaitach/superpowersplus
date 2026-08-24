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

# --- the packager forbids the root scripts path ----------------------------
# scripts/package-codex-plugin.sh stages `skills` wholesale and fails the build
# on any archived path beginning `scripts/`. A module at the repository root
# would reach Claude Code, whose plugin cache is a full checkout, and not Codex,
# where check-cross-references still ships and would fail to import.
packager="$REPO_ROOT/scripts/package-codex-plugin.sh"
# Two conjuncts, not three: `printf '%s' "$MODULE_DIR" | grep -q "/skills/"`
# tested a string this same script hardcoded above, and could not fail.
#
# The name says what the two conjuncts REACH, and no more. Neither asserts that
# the archive carries the module — the first is a file test on a path this
# script hardcodes at :15, the second a property of the packager — so narrowing
# `scripts/package-codex-plugin.sh:241` from `skills` to a subset would leave
# this case green. That half is `AC19`'s, held by
# `tests/codex/test-package-codex-plugin.sh > archive carries the shared fence
# scanner`, whose red state was measured by deleting the module and committing.
if [ -f "$MODULE_DIR/mdfence.py" ] &&
   grep -q '\^scripts/' "$packager"; then
    pass "the packager forbids the root scripts path, and the module is not under it"
else
    fail "the packager forbids the root scripts path, and the module is not under it"
    echo "        module dir: $MODULE_DIR"
    { grep -n '\^scripts/' "$packager" | sed 's/^/        /'; } || true
fi

# --- the module carries no dependency ---------------------------------------
# An absent module must fail this case, not pass it: grep over a missing file
# matches nothing, and a negation over nothing approves the absence.
if [ ! -f "$MODULE_DIR/mdfence.py" ]; then
    fail "module imports only re"
    echo "        module not found: $MODULE_DIR/mdfence.py"
elif grep -nE "^(import|from) " "$MODULE_DIR/mdfence.py" | grep -qvE "^[0-9]+:import re$"; then
    fail "module imports only re"
    { grep -nE "^(import|from) " "$MODULE_DIR/mdfence.py" | sed 's/^/        /'; } || true
else
    pass "module imports only re"
fi

run_py "a closing candidate carrying an info string does not close" '
lines = ["````", "x", "````js", "## still fenced", "````", "## real"]
mask, unclosed = fence_mask(lines)
assert unclosed is None, unclosed
assert mask[3] is True, "a closer may carry no info string"
assert mask[5] is False, "the real closer has none"
'

run_py "a four-space opener is an indented code block, not a fence" '
lines = ["```", "## fenced", "```", "    ```", "## still prose"]
mask, unclosed = fence_mask(lines)
assert unclosed is None, unclosed
assert mask[4] is False, "four spaces exceeds the three-space bound"
'

run_py "a closer shorter than its opener does not close" '
lines = ["`````", "x", "```", "## still fenced", "`````", "## real"]
mask, _ = fence_mask(lines)
assert mask[3] is True, "three backticks cannot close five"
assert mask[5] is False, "five can"
'

# --- one scanner, not three: the carrier's ANSWER must depend on the module ---
# AC18 says each carrier "obtains the mask from the shared module". Five
# instruments were tried here; four were defeated by text, and the fifth has a
# residual that is named rather than denied:
#
#   1. a blacklist of source spellings — beaten by a duplicate under new names;
#   2. a grep for `from mdfence import` — beaten by a comment quoting the
#      string, and by a live-but-unused import;
#   3. deleting the module and requiring a refusal — this asks about the
#      module's PRESENCE, and a carrier can depend on the presence while
#      ignoring the contents: keep the real try/except, which still prints the
#      refusal, and shadow the imported names with a duplicate defined after it;
#   4. this one: replace the module with a stub that masks nothing and require
#      each carrier's verdict to MOVE.
#
# Each of 1–3 was measured with the whole battery green. **The residual, also
# measured:** a carrier can keep its own scanner for the real work and read the
# module purely so its exit code moves — a canary. No rename, comment, dead
# import or shadowed name defeats this case; a deliberate canary does, and that
# is what is left. It is not what a careless refactor produces, which is the
# class this gate exists for.
#
# TWO copies, differing ONLY in the module. Comparing the real repository
# against a copy would move three variables at once — the module, the added
# fixtures, and any untracked file — and attribute all of it to the module.
# And the pair asserted is SPECIFIC (0 then 1), never "different": a carrier
# that crashes under the stub also produces a different code, and a crash read
# as success is the hole this replaces.
carrier_logic=0
real_root="$TEST_ROOT/with-module"
stub_root="$TEST_ROOT/with-stub"
for root in "$real_root" "$stub_root"; do
    mkdir -p "$root"
    ( cd "$REPO_ROOT" && git ls-files -z | xargs -0 cp --parents -t "$root" )
    mkdir -p "$root/docs/probe"
    # One real task and one inside a fence, announcing one: masked → 0, unmasked → 1.
    printf '%s\n' '# Plan' '' '## Task 1: real' '' '````markdown' '## Task 2: only an example' '````' '' 'This plan has 1 task.' \
        >"$root/docs/probe/doc.md"
    # A link that only resolves while fences are masked. The copied corpus holds
    # others, so this file is not the only thing moving check-links.sh — it is
    # here so the case still moves if the corpus ever stops holding one.
    printf '%s\n' '# Probe' '' '```markdown' '[gone](no-such-file.md)' '```' \
        >"$root/docs/probe/link.md"
done

cat >"$stub_root/skills/writing-plans/scripts/mdfence.py" <<'STUB'
"""Stub: every line is prose. A carrier that uses this cannot see a fence."""


def fence_mask(lines):
    return [False] * len(lines), None


def prose(lines):
    return list(lines)
STUB

check_pair() {  # real must be 0 AND stub must be 1 — not merely different
    local label="$1" real="$2" stub="$3"
    if [ "$real" != "0" ]; then
        echo "        $label: exit $real with the REAL module, where the fixture is built to pass"
        carrier_logic=$((carrier_logic + 1))
    fi
    if [ "$stub" != "1" ]; then
        echo "        $label: exit $stub with a stub that masks nothing, expected 1"
        [ "$stub" = "0" ] && echo "          — its answer does not depend on the module's behaviour"
        [ "$stub" != "0" ] && echo "          — a code other than 1 is a crash, not a moved verdict"
        carrier_logic=$((carrier_logic + 1))
    fi
}

r=0; "$real_root/skills/writing-plans/scripts/check-cross-references" \
    "$real_root/docs/probe/doc.md" "$real_root" >/dev/null 2>&1 || r=$?
s=0; "$stub_root/skills/writing-plans/scripts/check-cross-references" \
    "$stub_root/docs/probe/doc.md" "$stub_root" >/dev/null 2>&1 || s=$?
check_pair "check-cross-references" "$r" "$s"

r=0; ( cd "$real_root" && ./scripts/check-links.sh ) >/dev/null 2>&1 || r=$?
s=0; ( cd "$stub_root" && ./scripts/check-links.sh ) >/dev/null 2>&1 || s=$?
check_pair "check-links.sh" "$r" "$s"

# Kept beside the probe, and not carrying the case: a carrier could use the
# module AND keep a stale pattern of its own, which no behavioural probe sees.
for carrier in "$REPO_ROOT/scripts/check-links.sh" \
               "$REPO_ROOT/skills/writing-plans/scripts/check-cross-references"; do
    if grep -nE 'in_fence|infence|FENCE = re\.compile|`\{3,\}' "$carrier" >/dev/null 2>&1; then
        echo "        $(basename "$carrier"): keeps a fence pattern of its own"
        { grep -nE 'in_fence|infence|FENCE = re\.compile|`\{3,\}' "$carrier" | sed 's/^/          /'; } || true
        carrier_logic=$((carrier_logic + 1))
    fi
done

if [ "$carrier_logic" -eq 0 ]; then
    pass "each carrier's verdict moves when the shared module's behaviour changes"
else
    fail "each carrier's verdict moves when the shared module's behaviour changes — $carrier_logic problem(s)"
fi

# --- the import leaves no bytecode beside the module ------------------------
# Both carriers set sys.dont_write_bytecode. They run from a pre-commit hook and
# from inside an installed plugin directory, where a .pyc dropped beside the
# module ships with the plugin. `.gitignore` has carried a `__pycache__/` rule
# since 2026-08-24, so a stray file is no longer committable — this case is the
# guard in depth, and the only one that notices the flags going away.
#
# It runs against the COPY built above, never the developer's checkout: a suite
# that deletes directories out of the tree it is testing is one typo away from
# deleting something else, and the copy answers the same question.
copy_module_dir="$real_root/skills/writing-plans/scripts"
rm -rf "$copy_module_dir/__pycache__"
( cd "$real_root" && ./scripts/check-links.sh >/dev/null 2>&1 ) || true
( cd "$real_root" && ./skills/writing-plans/scripts/check-cross-references \
    docs/superpowers/specs/2026-08-24-cross-references-extractor-design.md . >/dev/null 2>&1 ) || true
if [ -d "$copy_module_dir/__pycache__" ]; then
    fail "running a carrier leaves no bytecode beside the module"
    { ls "$copy_module_dir/__pycache__" | sed 's/^/        /'; } || true
else
    pass "running a carrier leaves no bytecode beside the module"
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All mdfence tests passed"
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
