#!/usr/bin/env bash
#
# tests/review-yield/test-review-yield-rules.sh — the rules added by
# docs/superpowers/plans/2026-09-03-review-yield-and-problem-section.md are
# present in the files that must carry them.
#
# Every rule here is text in a skill, a prompt, or a script comment. Nothing
# executes it, so nothing notices when an edit removes it. That is what this
# suite is for: one assertion per rule, failing on the mutation that deletes
# it. It cannot judge whether a rule is well worded — only that it is there.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

FAILURES=0

assert_contains() {
    local file="$1" pattern="$2" label="$3"
    if grep -qE "$pattern" "$REPO_ROOT/$file"; then
        printf 'ok   %s\n' "$label"
    else
        printf 'FAIL %s — %s does not carry: %s\n' "$label" "$file" "$pattern"
        FAILURES=$((FAILURES + 1))
    fi
}

ledger_columns() {
    local f="docs/review-yield.md"
    if [ ! -f "$REPO_ROOT/$f" ]; then
        printf 'FAIL ledger_columns — %s does not exist\n' "$f"
        FAILURES=$((FAILURES + 1))
        return
    fi
    assert_contains "$f" '\| *Date *\|' 'ledger_columns: Date'
    assert_contains "$f" '\| *Branch *\|' 'ledger_columns: Branch'
    assert_contains "$f" '\| *Face *\|' 'ledger_columns: Face'
    assert_contains "$f" '\| *Round *\|' 'ledger_columns: Round'
    assert_contains "$f" '\| *Blocking findings *\|' 'ledger_columns: Blocking findings'
    assert_contains "$f" '\| *Still open from the previous round *\|' \
        'ledger_columns: Still open from the previous round'
}

ci_step_present() {
    assert_contains ".github/workflows/ci.yml" \
        'tests/review-yield/test-review-yield-rules\.sh' \
        'ci_step_present'
}

WRITE_POINTS=(
    "skills/brainstorming/SKILL.md"
    "skills/writing-plans/SKILL.md"
    "skills/subagent-driven-development/SKILL.md"
    "skills/requesting-code-review/SKILL.md"
)

write_points() {
    local f
    for f in "${WRITE_POINTS[@]}"; do
        assert_contains "$f" 'docs/review-yield\.md' "write_points: $f"
    done
}

# columns_not_restated catches a copy of the ledger's header, which is the
# mutation it is written against. It does NOT catch IR2's other half — the same
# six columns rewritten as prose ("date, branch, the round, how many blocking
# findings came back") reads nothing like the header and passes here. That class
# is declared rather than gated, for the reason AC10 declares its own: a grep
# cannot tell a paraphrase from a sentence that merely mentions a date.
columns_not_restated() {
    local f
    for f in "${WRITE_POINTS[@]}"; do
        if grep -qE 'Still open from the previous round' "$REPO_ROOT/$f"; then
            printf 'FAIL columns_not_restated — %s restates a ledger column; IR2 keeps the definitions in docs/review-yield.md alone\n' "$f"
            FAILURES=$((FAILURES + 1))
        else
            printf 'ok   columns_not_restated: %s\n' "$f"
        fi
    done
}

REVIEWER_PROMPTS=(
    "skills/brainstorming/spec-document-reviewer-prompt.md"
    "skills/writing-plans/plan-document-reviewer-prompt.md"
    "skills/requesting-code-review/code-reviewer.md"
    "skills/subagent-driven-development/task-reviewer-prompt.md"
    "skills/subagent-driven-development/re-review-prompt.md"
)

reviewers_do_not_write() {
    local f
    for f in "${REVIEWER_PROMPTS[@]}"; do
        if grep -qE 'docs/review-yield\.md' "$REPO_ROOT/$f"; then
            printf 'FAIL reviewers_do_not_write — %s tells a reviewer to write the ledger; three of these five declare the review read-only on the checkout, so the row is the controller\x27s to append\n' "$f"
            FAILURES=$((FAILURES + 1))
        else
            printf 'ok   reviewers_do_not_write: %s\n' "$f"
        fi
    done
}

DOC_REVIEWERS=(
    "skills/brainstorming/spec-document-reviewer-prompt.md"
    "skills/writing-plans/plan-document-reviewer-prompt.md"
)

previous_findings_line() {
    local f
    for f in "${DOC_REVIEWERS[@]}"; do
        assert_contains "$f" '\*\*Previous findings:\*\*' "previous_findings_line: $f"
    done
}

round_one_in_words() {
    local f
    for f in "${DOC_REVIEWERS[@]}"; do
        assert_contains "$f" 'none — round 1' "round_one_in_words: $f"
    done
}

nit_cap_present() {
    local f
    for f in "${DOC_REVIEWERS[@]}" \
             "skills/requesting-code-review/code-reviewer.md" \
             "skills/subagent-driven-development/task-reviewer-prompt.md" \
             "skills/subagent-driven-development/re-review-prompt.md"; do
        assert_contains "$f" 'at most five' "nit_cap_present: $f"
        assert_contains "$f" 'remainder as a count' "nit_cap_count: $f"
    done
}

nit_cap_per_face() {
    assert_contains "skills/requesting-code-review/code-reviewer.md" \
        'at most five Minor' 'nit_cap_per_face: code-reviewer names Minor'
    assert_contains "skills/subagent-driven-development/task-reviewer-prompt.md" \
        'at most five Minor' 'nit_cap_per_face: task-reviewer names Minor'
    assert_contains "skills/subagent-driven-development/re-review-prompt.md" \
        'at most five Out-of-Scope' 'nit_cap_per_face: re-review names Out-of-Scope'
    local f
    for f in "${DOC_REVIEWERS[@]}"; do
        assert_contains "$f" 'at most five Recommendations' \
            "nit_cap_per_face: $f names Recommendations"
    done
}

ledger_columns
ci_step_present
write_points
columns_not_restated
reviewers_do_not_write
previous_findings_line
round_one_in_words
nit_cap_present
nit_cap_per_face

if [ "$FAILURES" -gt 0 ]; then
    printf '\n%s assertion(s) failed.\n' "$FAILURES"
    exit 1
fi
printf '\nAll assertions passed.\n'
