#!/usr/bin/env bash
#
# Tests for scripts/check-changelog.sh.
#
# Each case builds a throwaway repository and stages a specific combination of
# paths, because the script's entire input is the git index — asserting on it
# any other way would assert on a mock instead of on what the hook reads.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-changelog.sh"

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

# stage <path>... — fresh repository with an initial commit, then create and
# stage each path given. Echoes the repository directory.
stage() {
    local repo
    repo="$(mktemp -d "$TEST_ROOT/repo.XXXXXX")"
    git -C "$repo" init -q
    git -C "$repo" config user.email test@example.com
    git -C "$repo" config user.name Test
    echo seed > "$repo/seed.txt"
    git -C "$repo" add seed.txt
    git -C "$repo" commit -qm seed

    local path
    for path in "$@"; do
        mkdir -p "$repo/$(dirname "$path")"
        echo change > "$repo/$path"
        git -C "$repo" add "$path"
    done
    printf '%s\n' "$repo"
}

# assert_exit <expected> <description> <staged path>...
assert_exit() {
    local expected="$1"
    local description="$2"
    shift 2

    local repo actual output
    repo="$(stage "$@")"
    output="$(cd "$repo" && "$SCRIPT_UNDER_TEST" 2>&1)" && actual=0 || actual=$?

    if [ "$actual" -eq "$expected" ]; then
        pass "$description"
    else
        fail "$description"
        echo "    expected exit $expected, got $actual"
        printf '%s\n' "$output" | sed 's/^/      /'
    fi
}

echo "Test: every content prefix triggers the gate on its own"
assert_exit 1 "skills/ alone blocks"    skills/demo/SKILL.md
assert_exit 1 "scripts/ alone blocks"   scripts/demo.sh
assert_exit 1 "githooks/ alone blocks"  githooks/demo
assert_exit 1 "\.github/ alone blocks"  .github/workflows/demo.yml
assert_exit 1 "hooks/ alone blocks"     hooks/demo

echo "Test: the changelog staged alongside content passes"
assert_exit 0 "content plus CHANGELOG.md passes" skills/demo/SKILL.md CHANGELOG.md
assert_exit 0 "CHANGELOG.md alone passes"        CHANGELOG.md

echo "Test: paths outside the content prefixes are exempt"
assert_exit 0 "docs/ alone passes"                docs/note.md
assert_exit 0 "tests/skill-behavior/ alone passes" tests/skill-behavior/fixture.md
assert_exit 0 "tests/ alone passes"                tests/hooks/demo.sh
assert_exit 0 "a root file alone passes"           README.md
assert_exit 0 "an empty index passes"

echo "Test: a prefix match is anchored, not a substring"
assert_exit 0 "vendor/skills/ does not match skills/" vendor/skills/other.md

echo "Test: the message names the offending files and the escape hatch"
REPO="$(stage skills/demo/SKILL.md)"
MESSAGE="$(cd "$REPO" && "$SCRIPT_UNDER_TEST" 2>&1 || true)"
for needle in "skills/demo/SKILL.md" "git commit --no-verify" "git add CHANGELOG.md"; do
    if printf '%s' "$MESSAGE" | grep -Fq -- "$needle"; then
        pass "message contains '$needle'"
    else
        fail "message contains '$needle'"
        printf '%s\n' "$MESSAGE" | sed 's/^/      /'
    fi
done

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All check-changelog tests passed"
else
    echo "$FAILURES check-changelog test(s) failed"
    exit 1
fi
