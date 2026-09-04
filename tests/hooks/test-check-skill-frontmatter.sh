#!/usr/bin/env bash
#
# Tests for scripts/check-skill-frontmatter.sh.
#
# One case per constraint the Agent Skills specification states for `name` and
# `description`, because the defect this gate answers was three of those
# constraints being wrong in the skill that teaches people to write skills, for
# as long as nothing read them. A gate that checks four of seven rules is a
# gate that certifies the other three.
#
# Like the size gate's suite, each case builds a throwaway tree with the real
# script installed: the script resolves its root from its own location, so it
# runs against the fixture rather than against this repository.
#
# The last case is the exception and runs against this repository on purpose.
# It is the regression guard: every skill here must pass today, so a rule added
# to the script that this project itself violates fails loudly instead of
# arriving as a red nobody can act on.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-skill-frontmatter.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

new_tree() {
    local tree
    tree="$(mktemp -d "$TEST_ROOT/tree.XXXXXX")"
    mkdir -p "$tree/scripts" "$tree/skills"
    cp "$SCRIPT_UNDER_TEST" "$tree/scripts/check-skill-frontmatter.sh"
    printf '%s\n' "$tree"
}

# add_skill <tree> <directory> <name value> <description value>
add_skill() {
    local tree="$1" dir="$2" name="$3" desc="$4"
    mkdir -p "$tree/skills/$dir"
    {
        printf -- '---\n'
        [ "$name" = "@omit" ] || printf 'name: %s\n' "$name"
        [ "$desc" = "@omit" ] || printf 'description: %s\n' "$desc"
        printf -- '---\n\n# Body\n'
    } > "$tree/skills/$dir/SKILL.md"
}

# assert_run <expected exit> <description> <tree> [needle]
assert_run() {
    local expected="$1" description="$2" tree="$3" needle="${4:-}"
    local actual output
    output="$("$tree/scripts/check-skill-frontmatter.sh" 2>&1)" && actual=0 || actual=$?
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

echo "Testing scripts/check-skill-frontmatter.sh"

VALID_DESC="Produces a thing. Use when the thing is needed."

# --- The shape that must pass -----------------------------------------------
t="$(new_tree)"
add_skill "$t" good-skill good-skill "$VALID_DESC"
assert_run 0 "a conforming skill passes" "$t"

# --- name: the seven constraints --------------------------------------------
# The directory carries the same uppercase name on purpose: with a lowercase
# directory this case would be rejected by the name-equals-directory rule and
# would never reach the pattern. Measured — the pattern was mutated to accept
# uppercase and this suite stayed green.
t="$(new_tree)"; add_skill "$t" Bad-Case Bad-Case "$VALID_DESC"
assert_run 1 "uppercase in name is rejected" "$t" "Bad-Case"

t="$(new_tree)"; add_skill "$t" real-dir other-name "$VALID_DESC"
assert_run 1 "name not equal to its directory is rejected" "$t" "real-dir"

t="$(new_tree)"; add_skill "$t" double--hyphen double--hyphen "$VALID_DESC"
assert_run 1 "consecutive hyphens in name are rejected" "$t" "double--hyphen"

t="$(new_tree)"; add_skill "$t" -leading -leading "$VALID_DESC"
assert_run 1 "a leading hyphen in name is rejected" "$t" "-leading"

t="$(new_tree)"; add_skill "$t" trailing- trailing- "$VALID_DESC"
assert_run 1 "a trailing hyphen in name is rejected" "$t" "trailing-"

long_name="$(printf 'a%.0s' $(seq 1 65))"
t="$(new_tree)"; add_skill "$t" "$long_name" "$long_name" "$VALID_DESC"
assert_run 1 "a name over 64 characters is rejected" "$t" "64"

t="$(new_tree)"; add_skill "$t" claude-helper claude-helper "$VALID_DESC"
assert_run 1 "a reserved word in name is rejected" "$t" "claude-helper"

t="$(new_tree)"; add_skill "$t" missing-name "@omit" "$VALID_DESC"
assert_run 1 "a missing name is rejected" "$t" "missing-name"

# --- description ------------------------------------------------------------
t="$(new_tree)"; add_skill "$t" no-desc no-desc "@omit"
assert_run 1 "a missing description is rejected" "$t" "no-desc"

t="$(new_tree)"; add_skill "$t" empty-desc empty-desc ""
assert_run 1 "an empty description is rejected" "$t" "empty-desc"

long_desc="$(printf 'x%.0s' $(seq 1 1025))"
t="$(new_tree)"; add_skill "$t" long-desc long-desc "$long_desc"
assert_run 1 "a description over 1024 characters is rejected" "$t" "1024"

# --- no frontmatter at all --------------------------------------------------
t="$(new_tree)"
mkdir -p "$t/skills/no-frontmatter"
printf '# Just a body\n' > "$t/skills/no-frontmatter/SKILL.md"
assert_run 1 "a SKILL.md with no frontmatter is rejected" "$t" "no-frontmatter"

# --- One failing skill fails the run, not just the last one -----------------
t="$(new_tree)"
add_skill "$t" good-skill good-skill "$VALID_DESC"
add_skill "$t" Bad-Case Bad-Case "$VALID_DESC"
assert_run 1 "one bad skill among good ones fails the run" "$t" "Bad-Case"

# --- Regression guard: this repository ---------------------------------------
if "$SCRIPT_UNDER_TEST" >/dev/null 2>&1; then
    pass "every SKILL.md in this repository passes"
else
    fail "every SKILL.md in this repository passes"
    "$SCRIPT_UNDER_TEST" 2>&1 | sed 's/^/      /'
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All checks passed."
    exit 0
fi
echo "$FAILURES check(s) failed."
exit 1
