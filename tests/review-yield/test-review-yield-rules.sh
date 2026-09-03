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

# Every criterion this suite charges is a POSITION, not a substring: a rule
# inside a named bucket, inside a section, inside a table, and sometimes more
# than once in one file. A file-scoped grep passes when the rule is MOVED out
# of the place the criterion names, which is the mutation a branch review
# applied and got green on five assertions. These two helpers are the answer.

# Print the lines strictly between the first START match and the next END
# match after it. Neither delimiter is printed. No pipeline: a `grep -q`
# downstream exits on its first match and can SIGPIPE the producer, which
# `pipefail` then reports as a failure of the whole pipeline — a match read as
# a miss.
# The patterns travel through the ENVIRONMENT, never through `awk -v`: -v
# runs escape processing on the value first, so a regex like
# `\*\*Recommendations \(advisory` reaches awk as `**Recommendations (advisory`
# and dies as an invalid expression. Measured here on 2026-09-03.
slice_between() {
    local file="$1"
    START_RE="$2" END_RE="$3" awk '
        !inside && $0 ~ ENVIRON["START_RE"] { inside = 1; next }
        inside && $0 ~ ENVIRON["END_RE"] { exit }
        inside { print }
    ' "$REPO_ROOT/$file"
}

assert_in_slice() {
    local file="$1" start="$2" end="$3" pattern="$4" label="$5" slice
    slice="$(slice_between "$file" "$start" "$end")"
    if grep -qE "$pattern" <<<"$slice"; then
        printf 'ok   %s\n' "$label"
    else
        printf 'FAIL %s — %s: not found between /%s/ and /%s/: %s\n' \
            "$label" "$file" "$start" "$end" "$pattern"
        FAILURES=$((FAILURES + 1))
    fi
}

# A criterion naming more than one site needs the count, not the presence: one
# grep over a file cannot see that the second of two write points was deleted.
assert_count() {
    local file="$1" pattern="$2" want="$3" label="$4" got
    got="$(grep -cE "$pattern" "$REPO_ROOT/$file" || true)"
    if [ "$got" = "$want" ]; then
        printf 'ok   %s\n' "$label"
    else
        printf 'FAIL %s — %s carries %s occurrence(s) of %s, expected %s\n' \
            "$label" "$file" "$got" "$pattern" "$want"
        FAILURES=$((FAILURES + 1))
    fi
}

ledger_columns() {
    # The definitions live in the shipped reference, not in the ledger: the
    # ledger is a file in the PARTNER's project, and a project that has never
    # run a review has no such file to read a format from.
    local ref="skills/requesting-code-review/references/review-yield.md" c
    for c in 'Date' 'Branch' 'Face' 'Round' 'Blocking findings' \
             'Still open from the previous round'; do
        assert_in_slice "$ref" '^\| Column \| What goes in it \|' '^$' \
            "^\\| $c \\|" "ledger_columns: $c is defined"
    done
    # And the header a partner project is told to create the file with.
    assert_in_slice "$ref" '^```markdown' '^```$' \
        '^\| Date \| Branch \| Face \| Round \| Blocking findings \| Still open from the previous round \|' \
        'ledger_columns: the header to create the file with'
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
    assert_in_slice "skills/brainstorming/SKILL.md" \
        '^\*\*Spec Review:\*\*' '^## ' \
        'docs/superpowers/review-yield\.md' 'write_points: brainstorming, in Spec Review'
    assert_in_slice "skills/writing-plans/SKILL.md" '^## Plan Review' '^## ' \
        'docs/superpowers/review-yield\.md' 'write_points: writing-plans, in Plan Review'
    assert_in_slice "skills/requesting-code-review/SKILL.md" \
        '^\*\*3\. Act on feedback:\*\*' '^## ' \
        'docs/superpowers/review-yield\.md' 'write_points: requesting-code-review, in Act on feedback'
    assert_in_slice "skills/subagent-driven-development/SKILL.md" \
        '^### 3\. Review the task' '^### 4\.' \
        'docs/superpowers/review-yield\.md' 'write_points: sdd, in Review the task'
    assert_in_slice "skills/subagent-driven-development/SKILL.md" \
        '^### 4\. The fix loop' '^### 5\.' \
        'docs/superpowers/review-yield\.md' 'write_points: sdd, in The fix loop'
    assert_count "skills/subagent-driven-development/SKILL.md" \
        'docs/superpowers/review-yield\.md' 2 'write_points: exactly the two sites in sdd'
}

# columns_not_restated catches a copy of the ledger's header, which is the
# mutation it is written against. It does NOT catch IR2's other half — the same
# six columns rewritten as prose ("date, branch, the round, how many blocking
# findings came back") reads nothing like the header and passes here. That class
# is declared rather than gated, for the reason AC10 declares its own: a grep
# cannot tell a paraphrase from a sentence that merely mentions a date.
columns_not_restated() {
    local f c bad
    for f in "${WRITE_POINTS[@]}"; do
        bad=""
        for c in 'Still open from the previous round' 'Blocking findings' \
                 'blocking findings raised' 'What goes in it'; do
            if grep -qF "$c" "$REPO_ROOT/$f"; then
                printf 'FAIL columns_not_restated — %s restates a ledger column (%s); IR2 keeps the definitions in skills/requesting-code-review/references/review-yield.md alone\n' "$f" "$c"
                FAILURES=$((FAILURES + 1))
                bad=1
            fi
        done
        [ -n "$bad" ] || printf 'ok   columns_not_restated: %s\n' "$f"
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
        if grep -qE 'docs/superpowers/review-yield\.md' "$REPO_ROOT/$f"; then
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
        assert_in_slice "$f" '## Output Format' '^```' \
            '\*\*Previous findings:\*\*' "previous_findings_line: $f"
    done
}

round_one_in_words() {
    local f
    for f in "${DOC_REVIEWERS[@]}"; do
        assert_in_slice "$f" '## Output Format' '^```' \
            'none — round 1' "round_one_in_words: $f"
    done
}

# AC5 caps a bucket that ENDS with the report. The two buckets the controller
# is required to carry onward are not capped, and capped_faces / uncapped_faces
# are the two halves of that one rule — the second exists so nobody restores a
# cap that deletes findings on their way to the ledger.
capped_faces() {
    local f
    for f in "${DOC_REVIEWERS[@]}"; do
        assert_in_slice "$f" '\*\*Recommendations \(advisory' '^```' \
            'at most five Recommendations' "capped_faces: $f names Recommendations"
        assert_in_slice "$f" '\*\*Recommendations \(advisory' '^```' \
            'remainder as a count' "capped_faces: $f reports the remainder"
    done
    local c="skills/requesting-code-review/code-reviewer.md"
    assert_in_slice "$c" '#### Minor \(Nice to Have\)' '^ *###' \
        'at most five Minor' 'capped_faces: code-reviewer names Minor'
    assert_in_slice "$c" '#### Minor \(Nice to Have\)' '^ *###' \
        'remainder as a count' 'capped_faces: code-reviewer reports the remainder'
}

uncapped_faces() {
    local f
    for f in "skills/subagent-driven-development/task-reviewer-prompt.md" \
             "skills/subagent-driven-development/re-review-prompt.md"; do
        if grep -qE 'at most five' "$REPO_ROOT/$f"; then
            printf 'FAIL uncapped_faces — %s caps a bucket the controller must transcribe to the ledger; the cap would delete findings in transit\n' "$f"
            FAILURES=$((FAILURES + 1))
        else
            printf 'ok   uncapped_faces: %s\n' "$f"
        fi
        assert_contains "$f" 'not capped, and that is deliberate' \
            "uncapped_faces: $f says why"
    done
}


problem_required_first() {
    local f="skills/brainstorming/SKILL.md"
    local problem acceptance
    problem="$(grep -n '^| `## Problem`' "$REPO_ROOT/$f" | head -1 | cut -d: -f1 || true)"
    acceptance="$(grep -n '^| `## Acceptance Criteria`' "$REPO_ROOT/$f" | head -1 | cut -d: -f1 || true)"
    if [ -z "$problem" ]; then
        printf 'FAIL problem_required_first — %s has no `## Problem` row\n' "$f"
        FAILURES=$((FAILURES + 1))
    elif [ -z "$acceptance" ]; then
        printf 'FAIL problem_required_first — %s has no `## Acceptance Criteria` row\n' "$f"
        FAILURES=$((FAILURES + 1))
    elif [ "$problem" -lt "$acceptance" ]; then
        printf 'ok   problem_required_first\n'
    else
        printf 'FAIL problem_required_first — `## Problem` (line %s) is not above `## Acceptance Criteria` (line %s)\n' \
            "$problem" "$acceptance"
        FAILURES=$((FAILURES + 1))
    fi
}

problem_transition() {
    assert_contains "skills/brainstorming/SKILL.md" \
        'written before .*`## Problem`|`## Problem` .*became required' \
        'problem_transition'
}

problem_blocking() {
    assert_in_slice "skills/brainstorming/spec-document-reviewer-prompt.md" \
        '## Traceability \(blocking\)' '## Coverage Map' \
        'No `## Problem` section \| BLOCKING' 'problem_blocking'
}

criteria_serve_problem() {
    assert_in_slice "skills/brainstorming/spec-document-reviewer-prompt.md" \
        '## Traceability \(blocking\)' '## Coverage Map' \
        'does not serve the stated problem' 'criteria_serve_problem'
}

not_covered_section_refs() {
    local f="skills/writing-plans/scripts/check-cross-references"
    assert_in_slice "$f" 'WHAT IT DOES NOT COVER' '^# Usage:' \
        'section reference into another file' 'not_covered_section_refs: names the class'
    assert_in_slice "$f" 'WHAT IT DOES NOT COVER' '^# Usage:' \
        'check-links\.sh' 'not_covered_section_refs: names where it is covered'
}

ledger_columns
ci_step_present
write_points
columns_not_restated
reviewers_do_not_write
previous_findings_line
round_one_in_words
capped_faces
uncapped_faces
problem_required_first
problem_transition
problem_blocking
criteria_serve_problem
not_covered_section_refs

if [ "$FAILURES" -gt 0 ]; then
    printf '\n%s assertion(s) failed.\n' "$FAILURES"
    exit 1
fi
printf '\nAll assertions passed.\n'
