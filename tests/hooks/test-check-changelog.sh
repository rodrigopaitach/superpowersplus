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

# --------------------------------------------------------------------------
# Structural checks on a staged CHANGELOG.md.
# --------------------------------------------------------------------------

# stage_changelog <head-body> <staged-body> [tracked-path...]
# A repository whose HEAD carries <head-body> as CHANGELOG.md and whose index
# carries <staged-body>. Each tracked path is created with three lines and
# committed, so anchor resolution has real files to find. Echoes the directory.
stage_changelog() {
    local head_body="$1" staged_body="$2"
    shift 2

    local repo path
    repo="$(mktemp -d "$TEST_ROOT/repo.XXXXXX")"
    git -C "$repo" init -q
    git -C "$repo" config user.email test@example.com
    git -C "$repo" config user.name Test

    for path in "$@"; do
        mkdir -p "$repo/$(dirname "$path")"
        printf 'one\ntwo\nthree\n' >"$repo/$path"
        git -C "$repo" add "$path"
    done

    printf '%s\n' "$head_body" >"$repo/CHANGELOG.md"
    git -C "$repo" add CHANGELOG.md
    git -C "$repo" commit -qm seed

    printf '%s\n' "$staged_body" >"$repo/CHANGELOG.md"
    git -C "$repo" add CHANGELOG.md
    printf '%s\n' "$repo"
}

# assert_structure <expected exit> <description> <head-body> <staged-body> [tracked...]
assert_structure() {
    local expected="$1" description="$2" head_body="$3" staged_body="$4"
    shift 4

    local repo actual output
    repo="$(stage_changelog "$head_body" "$staged_body" "$@")"
    output="$(cd "$repo" && "$SCRIPT_UNDER_TEST" 2>&1)" && actual=0 || actual=$?

    if [ "$actual" -eq "$expected" ]; then
        pass "$description"
    else
        fail "$description"
        echo "    expected exit $expected, got $actual"
        printf '%s\n' "$output" | sed 's/^/      /'
    fi
}

TWO_HEADINGS='## [Unreleased]

- **A.** text

## [1.0.0] - 2026-01-01

- **B.** text'

echo "Test: (a) a '## ' heading may not disappear"
assert_structure 1 "a dropped heading blocks" "$TWO_HEADINGS" '## [Unreleased]

- **A, edited over B.** text

- **B.** text'
assert_structure 0 "an added entry under the same headings passes" "$TWO_HEADINGS" '## [Unreleased]

- **New.** text

- **A.** text

## [1.0.0] - 2026-01-01

- **B.** text'
assert_structure 0 "a new heading passes" "$TWO_HEADINGS" '## [Unreleased]

## [1.1.0] - 2026-02-01

- **A.** text

## [1.0.0] - 2026-01-01

- **B.** text'

echo "Test: (b) headings are unique"
assert_structure 1 "a duplicated version heading blocks" "$TWO_HEADINGS" '## [Unreleased]

- **A.** text

## [1.0.0] - 2026-01-01

- **B.** text

## [1.0.0] - 2026-01-01

- **B again.** text'
assert_structure 1 "two [Unreleased] headings block" "$TWO_HEADINGS" '## [Unreleased]

- **A.** text

## [Unreleased]

- **A again.** text

## [1.0.0] - 2026-01-01

- **B.** text'

echo "Test: (c) an anchor added by this commit resolves and is in range"
assert_structure 0 "a repo-root anchor in range passes" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `src/real.sh:2`

## [1.0.0] - 2026-01-01

- **B.** text' src/real.sh
assert_structure 1 "an anchor past the end of the file blocks" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `src/real.sh:99`

## [1.0.0] - 2026-01-01

- **B.** text' src/real.sh
assert_structure 1 "an anchor naming no file blocks" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `src/ghost.sh:1`

## [1.0.0] - 2026-01-01

- **B.** text' src/real.sh
assert_structure 0 "an anchor relative to skills/ resolves" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `demo/SKILL.md:2`

## [1.0.0] - 2026-01-01

- **B.** text' skills/demo/SKILL.md
assert_structure 1 "an anchor relative to skills/ is range-checked too" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `demo/SKILL.md:99`

## [1.0.0] - 2026-01-01

- **B.** text' skills/demo/SKILL.md
assert_structure 0 "a unique basename resolves and is range-checked" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `only.md:2`

## [1.0.0] - 2026-01-01

- **B.** text' deep/dir/only.md
assert_structure 1 "a unique basename past the end blocks" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `only.md:99`

## [1.0.0] - 2026-01-01

- **B.** text' deep/dir/only.md

echo "Test: (c) the declared limits stay open, so nobody assumes coverage"
assert_structure 0 "an ambiguous basename is skipped, not failed" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `dup.md:99`

## [1.0.0] - 2026-01-01

- **B.** text' a/dup.md b/dup.md
assert_structure 0 "a bare basename naming nothing is skipped" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `ghost.md:1`

## [1.0.0] - 2026-01-01

- **B.** text' src/real.sh
assert_structure 0 "an anchor on the wrong line of a real file still passes" "$TWO_HEADINGS" '## [Unreleased]

- **A.** see `src/real.sh:1`

## [1.0.0] - 2026-01-01

- **B.** text' src/real.sh
assert_structure 0 "an anchor already at HEAD is not re-checked" '## [Unreleased]

- **A.** see `src/gone.sh:400`

## [1.0.0] - 2026-01-01

- **B.** text' '## [Unreleased]

- **A.** see `src/gone.sh:400`

- **New.** no anchor here

## [1.0.0] - 2026-01-01

- **B.** text'

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All check-changelog tests passed"
else
    echo "$FAILURES check-changelog test(s) failed"
    exit 1
fi
