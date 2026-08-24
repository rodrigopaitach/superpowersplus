#!/usr/bin/env bash
#
# Tests for skills/subagent-driven-development/scripts/task-brief.
#
# The script had one assertion before this suite existed — in
# tests/claude-code/test-sdd-workspace.sh, which checks where the brief file
# lands rather than what it contains, and which CI does not run. Measured
# 2026-08-24, its fence handling had diverged from nothing on the current
# corpus; this suite is what keeps that true.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TASK_BRIEF="$REPO_ROOT/skills/subagent-driven-development/scripts/task-brief"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

echo "Testing task-brief"

# --- a fenced task heading is not a task ----------------------------------
repo="$TEST_ROOT/repo"
mkdir -p "$repo"
git -C "$repo" init -q
# The fenced heading sits inside the NESTED block, and that placement is the
# whole case. Under the naive toggle the fence state is "odd number of fence
# lines so far": the outer opener turns it on and the inner opener turns it
# back off, so anything inside the nested block reads as real structure. A
# heading placed directly under the outer opener is skipped by both rules and
# reproduces nothing.
cat >"$repo/plan.md" <<'PLAN'
# Plan

## Task 1: the real one

Body of the real task.

````markdown
An example of what a task heading looks like:

```md
## Task 2: only an example
```
````

Trailing prose.
PLAN
git -C "$repo" add -A
git -C "$repo" -c user.email=t@t -c user.name=t commit -qm fixture

brief="$TEST_ROOT/brief-2.md"
: >"$brief"
(cd "$repo" && "$TASK_BRIEF" plan.md 2 "$brief" >/dev/null 2>&1) || true
if [ ! -s "$brief" ]; then
    pass "a fenced task heading is not extracted"
else
    fail "a fenced task heading is not extracted"
    sed 's/^/        /' "$brief"
fi

# The pair: the REAL task must still come out whole, fenced example included.
# Without it, an awk that extracts nothing at all passes the case above.
brief1="$TEST_ROOT/brief-1.md"
(cd "$repo" && "$TASK_BRIEF" plan.md 1 "$brief1" >/dev/null 2>&1) || true
if [ -s "$brief1" ] && grep -q 'Body of the real task' "$brief1" &&
   grep -q '## Task 2: only an example' "$brief1"; then
    pass "the real task is extracted whole, fenced example included"
else
    fail "the real task is extracted whole, fenced example included"
    sed 's/^/        /' "$brief1"
fi

# --- the branch touches only its declared files ---------------------------
ALLOWED='^(skills/writing-plans/scripts/(mdfence\.py|check-cross-references)|skills/writing-skills/anthropic-best-practices\.md|skills/subagent-driven-development/scripts/task-brief|scripts/check-links\.sh|tests/hooks/test-(mdfence|check-cross-references|check-links|task-brief)\.sh|\.github/workflows/ci\.yml|CHANGELOG\.md|docs/superpowers/(specs|plans)/2026-08-24-cross-references-extractor.*\.md)$'
base="$(git -C "$REPO_ROOT" merge-base main HEAD 2>/dev/null || echo "")"
if [ -z "$base" ]; then
    pass "the branch touches only its declared files (no base to compare)"
else
    stray="$(git -C "$REPO_ROOT" diff --name-only "$base"..HEAD | grep -Ev "$ALLOWED" || true)"
    if [ -z "$stray" ]; then
        pass "the branch touches only its declared files"
    else
        fail "the branch touches only its declared files"
        printf '%s\n' "$stray" | sed 's/^/        /'
    fi
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All task-brief tests passed"
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
