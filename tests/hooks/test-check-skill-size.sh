#!/usr/bin/env bash
#
# Tests for scripts/check-skill-size.sh.
#
# The script resolves its repository root from its own location, so each case
# builds a throwaway tree with the script installed and SKILL.md files of exact
# lengths. That exercises the real script — including its hardcoded ceiling and
# its hardcoded exemption — rather than a parameterized variant that only
# exists for tests.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-skill-size.sh"

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

# new_tree — throwaway tree with the script installed. Echoes its path.
new_tree() {
    local tree
    tree="$(mktemp -d "$TEST_ROOT/tree.XXXXXX")"
    mkdir -p "$tree/scripts" "$tree/skills"
    cp "$SCRIPT_UNDER_TEST" "$tree/scripts/check-skill-size.sh"
    printf '%s\n' "$tree"
}

# add_skill <tree> <skill name> <line count>
add_skill() {
    local tree="$1" name="$2" lines="$3" i
    mkdir -p "$tree/skills/$name"
    {
        printf -- '---\n'
        printf 'name: %s\n' "$name"
        printf -- '---\n'
        for ((i = 4; i <= lines; i++)); do
            printf 'body line %d\n' "$i"
        done
    } > "$tree/skills/$name/SKILL.md"
}

# assert_run <expected exit> <description> <tree> [needle in output]
assert_run() {
    local expected="$1" description="$2" tree="$3" needle="${4:-}"
    local actual output
    output="$("$tree/scripts/check-skill-size.sh" 2>&1)" && actual=0 || actual=$?

    if [ "$actual" -ne "$expected" ]; then
        fail "$description"
        echo "    expected exit $expected, got $actual"
        printf '%s\n' "$output" | sed 's/^/      /'
        return
    fi
    if [ -n "$needle" ] && ! printf '%s' "$output" | grep -Fq -- "$needle"; then
        fail "$description"
        echo "    output did not contain: $needle"
        printf '%s\n' "$output" | sed 's/^/      /'
        return
    fi
    pass "$description"
}

echo "Testing scripts/check-skill-size.sh"

# --- Under the ceiling ------------------------------------------------------

tree="$(new_tree)"
add_skill "$tree" short-skill 40
add_skill "$tree" another-skill 400
assert_run 0 "skills under the ceiling pass" "$tree"

# --- Over the ceiling -------------------------------------------------------

tree="$(new_tree)"
add_skill "$tree" fine-skill 100
add_skill "$tree" fat-skill 564
assert_run 1 "a skill over the ceiling fails" "$tree" "skills/fat-skill/SKILL.md"

tree="$(new_tree)"
add_skill "$tree" fat-skill 564
assert_run 1 "the failure names the measured line count" "$tree" "564 lines"

tree="$(new_tree)"
add_skill "$tree" fat-one 501
add_skill "$tree" fat-two 900
assert_run 1 "every file over the ceiling is named, not just the first" \
    "$tree" "skills/fat-two/SKILL.md"

# --- The boundary is 500, and it is inclusive -------------------------------
#
# Both directions, because an off-by-one here is invisible: a ceiling that
# rejects the documented maximum and one that accepts a line past it both look
# like a working gate from the outside.

tree="$(new_tree)"
add_skill "$tree" exactly-at-the-cap 500
assert_run 0 "exactly 500 lines passes" "$tree"

tree="$(new_tree)"
add_skill "$tree" one-past-the-cap 501
assert_run 1 "501 lines fails" "$tree" "501 lines"

# --- The exemption ----------------------------------------------------------
#
# skills/writing-skills/SKILL.md is exempt on a DEADLINE, not a condition: it
# holds while that file's structural review is open and falls when the review
# closes, whatever the review decides — scripts/check-skill-size.sh and
# docs/releasing.md, section "The SKILL.md ceiling exemption". The older reason,
# "upstream's file at upstream's length", stopped being true (686 here against
# 679 there) and stopped meaning anything when this project stopped pulling from
# them. The exemption is pinned here: if someone removes it, this test says so
# instead of the gate going red on a file nobody here may cut yet.
#
# The sizes below are synthetic — any value over the ceiling exercises the same
# branch, and echoing the real file's line count would age this test with it.

tree="$(new_tree)"
add_skill "$tree" writing-skills 600
assert_run 0 "the exempt skill is not measured" "$tree"

tree="$(new_tree)"
add_skill "$tree" writing-skills 600
add_skill "$tree" fat-skill 564
assert_run 1 "the exemption does not cover a second oversized skill" \
    "$tree" "skills/fat-skill/SKILL.md"

# --- No skills at all -------------------------------------------------------
#
# `skills/*/SKILL.md` with no match expands to the literal pattern under
# nullglob-off bash, and `wc -l` on it would kill the script under `set -e`.
# A tree with no skills must pass, not crash.

tree="$(new_tree)"
assert_run 0 "a tree with no skills passes" "$tree"

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All tests passed"
    exit 0
fi
echo "$FAILURES test(s) failed"
exit 1
