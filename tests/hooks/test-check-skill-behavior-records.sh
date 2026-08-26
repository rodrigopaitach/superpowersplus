#!/usr/bin/env bash
#
# Tests for scripts/check-skill-behavior-records.sh.
#
# The staleness pass compares two dates: the one the record declares and the one
# git holds for the rule the record measures. So each case builds a throwaway
# GIT repository — not just a tree — with commit dates set explicitly. A tree
# without history would make the pass skip, and a skipped check passes for the
# wrong reason.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-skill-behavior-records.sh"

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

# new_tree — throwaway git repository with the script installed. Echoes its path.
new_tree() {
    local tree
    tree="$(mktemp -d "$TEST_ROOT/tree.XXXXXX")"
    mkdir -p "$tree/scripts" "$tree/skills/demo" "$tree/tests/skill-behavior"
    cp "$SCRIPT_UNDER_TEST" "$tree/scripts/check-skill-behavior-records.sh"
    git -C "$tree" init --quiet
    git -C "$tree" config user.email test@example.com
    git -C "$tree" config user.name Test
    printf '%s\n' "$tree"
}

# commit_rule <tree> <relative path> <YYYY-MM-DD> — writes the file and commits
# it with both dates pinned, so `git log` reports exactly this day.
commit_rule() {
    local tree="$1" path="$2" date="$3"
    mkdir -p "$tree/$(dirname "$path")"
    printf 'rule text, revision of %s\n' "$date" > "$tree/$path"
    git -C "$tree" add "$path"
    GIT_AUTHOR_DATE="${date}T12:00:00" GIT_COMMITTER_DATE="${date}T12:00:00" \
        git -C "$tree" commit --quiet -m "rule as of $date"
}

# add_record <tree> <name> <extra table rows...> — a well-formed record whose
# rows can be overridden by passing replacements.
add_record() {
    local tree="$1" name="$2"
    shift 2
    {
        printf '# RESULT — %s\n\n| | |\n|---|---|\n' "$name"
        printf '| **Date** | 2026-08-05 |\n'
        printf '| **Model** | Claude Opus 5 |\n'
        local row
        for row in "$@"; do
            printf '%s\n' "$row"
        done
        printf '| **Verdict** | **PASS** — 3 of 3 |\n'
    } > "$tree/tests/skill-behavior/RESULT-$name.md"
}

# assert_run <expected exit> <description> <tree> [needle in output]
assert_run() {
    local expected="$1" description="$2" tree="$3" needle="${4:-}"
    local actual output
    set +e
    output="$("$tree/scripts/check-skill-behavior-records.sh" 2>&1)"
    actual=$?
    set -e
    if [ "$actual" -ne "$expected" ]; then
        fail "$description (expected exit $expected, got $actual)"
        printf '%s\n' "$output" | sed 's/^/        /'
        return
    fi
    if [ -n "$needle" ] && ! printf '%s' "$output" | grep -qF "$needle"; then
        fail "$description (exit $expected as expected, but output never said '$needle')"
        printf '%s\n' "$output" | sed 's/^/        /'
        return
    fi
    pass "$description"
}

echo "check-skill-behavior-records: rule path and run count"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
add_record "$tree" no-rule-path \
    '| **Runs** | N=1 |'
assert_run 1 "a record with no **Rule path** row fails" "$tree" "Rule path"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
add_record "$tree" no-runs \
    '| **Rule path** | skills/demo/SKILL.md |'
assert_run 1 "a record with no **Runs** row fails" "$tree" "Runs"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
add_record "$tree" bare-dash \
    '| **Rule path** | — |' \
    '| **Runs** | N=1 |'
assert_run 1 "an unresolvable rule path must carry its reason, not a bare dash" "$tree" "Rule path"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
add_record "$tree" declared-not-a-file \
    '| **Rule path** | — (the rule is plus.26/plus.27, not a file) |' \
    '| **Runs** | N=1 |'
assert_run 0 "an unresolvable rule path passes when the record says why" "$tree"

echo "check-skill-behavior-records: staleness"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
add_record "$tree" rule-older \
    '| **Rule path** | skills/demo/SKILL.md |' \
    '| **Runs** | N=1 |'
assert_run 0 "a rule last touched before the measurement passes" "$tree"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
commit_rule "$tree" skills/demo/SKILL.md 2026-08-20
add_record "$tree" rule-newer \
    '| **Rule path** | skills/demo/SKILL.md |' \
    '| **Runs** | N=1 |'
assert_run 1 "a rule edited after the measurement fails without the mark" "$tree" "2026-08-20"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
commit_rule "$tree" skills/demo/SKILL.md 2026-08-20
add_record "$tree" rule-newer-marked \
    '| **Rule path** | skills/demo/SKILL.md |' \
    '| **Rule changed since** | 2026-08-20 — measured against earlier text |' \
    '| **Runs** | N=1 |'
assert_run 0 "the mark clears the staleness it names" "$tree"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
commit_rule "$tree" skills/demo/SKILL.md 2026-08-20
commit_rule "$tree" skills/demo/SKILL.md 2026-08-24
add_record "$tree" rule-newer-than-mark \
    '| **Rule path** | skills/demo/SKILL.md |' \
    '| **Rule changed since** | 2026-08-20 — measured against earlier text |' \
    '| **Runs** | N=1 |'
assert_run 1 "a mark older than the newest edit fails again" "$tree" "2026-08-24"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
commit_rule "$tree" skills/demo/SKILL.md 2026-08-20
add_record "$tree" mark-in-the-future \
    '| **Rule path** | skills/demo/SKILL.md |' \
    '| **Rule changed since** | 2099-01-01 — measured against earlier text |' \
    '| **Runs** | N=1 |'
assert_run 1 "a mark dated past the newest edit fails — it buys a pass the gate never computed" "$tree" "2099-01-01"

# Author dates are NOT monotonic with the graph: a commit written on another
# machine, or in another timezone, lands on top carrying an EARLIER day. Asking
# `git log -1` for the newest commit's date then reports a day older than an
# edit that really happened, and the record passes for text that moved.
tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
commit_rule "$tree" skills/demo/SKILL.md 2026-08-20
commit_rule "$tree" skills/demo/SKILL.md 2026-08-10
add_record "$tree" non-monotonic-dates \
    '| **Rule path** | skills/demo/SKILL.md |' \
    '| **Rule changed since** | 2026-08-10 — measured against earlier text |' \
    '| **Runs** | N=1 |'
assert_run 1 "the newest EDIT wins, not the newest commit — a mark below it still fails" "$tree" "2026-08-20"

echo "check-skill-behavior-records: nothing to compare against"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
add_record "$tree" missing-file \
    '| **Rule path** | skills/demo/GONE.md |' \
    '| **Runs** | N=1 |'
assert_run 1 "a rule path that resolves to nothing fails" "$tree" "GONE.md"

tree="$(new_tree)"
commit_rule "$tree" skills/demo/SKILL.md 2026-08-01
printf 'uncommitted\n' > "$tree/skills/demo/UNTRACKED.md"
add_record "$tree" untracked-file \
    '| **Rule path** | skills/demo/UNTRACKED.md |' \
    '| **Runs** | N=1 |'
assert_run 1 "a rule git has no date for is reported, never skipped in silence" "$tree" "UNTRACKED.md"

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All check-skill-behavior-records tests passed"
    exit 0
fi
echo "$FAILURES test(s) failed"
exit 1
