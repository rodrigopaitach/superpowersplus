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

ledger_columns
ci_step_present

if [ "$FAILURES" -gt 0 ]; then
    printf '\n%s assertion(s) failed.\n' "$FAILURES"
    exit 1
fi
printf '\nAll assertions passed.\n'
