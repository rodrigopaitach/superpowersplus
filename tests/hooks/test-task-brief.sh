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
    sed 's/^/        /' "$brief" || true
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
    sed 's/^/        /' "$brief1" || true
fi

# --- the awk copy and the shared scanner agree ----------------------------
# This carrier deliberately keeps a SECOND hand-written copy of the closing
# rule, because reaching skills/writing-plans/scripts/mdfence.py from another
# skill's directory would make one shipped skill depend on another's internals.
# A copied form owes a gate, or "unified in place" is just "copied" — this is
# that gate. It states the invariant the design rests on: two implementations,
# one rule.
#
# It is differential rather than a list of cases because the terms that can
# drift are the awk's alone: closer character, closer length, closer info
# string, and the two OPENER terms — minimum length three, and at most three
# spaces of indent. Each of the five was measured to have no red state before
# the case covering it existed; the opener pair was added after a review found
# that widening the length test to one, or the indent to five spaces, left both
# suites green.
MODULE_DIR="$REPO_ROOT/skills/writing-plans/scripts"
diff_plan="$TEST_ROOT/differential.md"
cat >"$diff_plan" <<'PLAN'
# Plan

## Task 1: backticks nested in backticks

````markdown
```js
## Task 9: not a task
```
````

## Task 2: a tilde block a backtick cannot close

~~~text
## Task 8: not a task either
```
still inside the tilde block
~~~

## Task 3: a closer carrying an info string

````
x
````js
## Task 7: not a task
````

## Task 4: a closer shorter than its opener

`````
```
## Task 6: not a task
`````

`mdfence` is a module name, and this line STARTS with a backtick without
opening a fence. Under a minimum length of one it opens a block that swallows
every heading below it, and the four-space line further down cannot close it.

    ```

The line above is an indented code block, not a fence, and it has no partner:
under an indent wider than three spaces it opens a block nothing closes.

## Task 5: an indented opener

   ```md
## Task 5: this heading is fenced
   ```

end of plan
PLAN

differential_failed=0
for n in 1 2 3 4 5 6 7 8 9; do
    "$TASK_BRIEF" "$diff_plan" "$n" "$TEST_ROOT/awk-$n.md" >/dev/null 2>&1 || :
    [ -f "$TEST_ROOT/awk-$n.md" ] || : >"$TEST_ROOT/awk-$n.md"
    python3 -B - "$diff_plan" "$n" "$MODULE_DIR" >"$TEST_ROOT/py-$n.md" <<'PY'
import re
import sys

sys.path.insert(0, sys.argv[3])
from mdfence import fence_mask

lines = open(sys.argv[1], encoding="utf-8").read().splitlines()
n = sys.argv[2]
mask, _ = fence_mask(lines)
intask = False
out = []
for index, line in enumerate(lines):
    if mask[index]:
        if intask:
            out.append(line)
        continue
    if re.match(r"^#+[ \t]+Task[ \t]+[0-9]+", line):
        intask = bool(re.match(r"^#+[ \t]+Task[ \t]+%s([^0-9]|$)" % n, line))
    if intask:
        out.append(line)
sys.stdout.write("".join(l + "\n" for l in out))
PY
    if ! cmp -s "$TEST_ROOT/awk-$n.md" "$TEST_ROOT/py-$n.md"; then
        echo "        task $n differs:"
        { diff "$TEST_ROOT/py-$n.md" "$TEST_ROOT/awk-$n.md" | head -8 | sed 's/^/          /'; } || true
        differential_failed=$((differential_failed + 1))
    fi
done
if [ "$differential_failed" -eq 0 ]; then
    pass "the awk copy and mdfence extract identically"
else
    fail "the awk copy and mdfence extract identically — $differential_failed task(s) differ"
fi

# The differential proves the two AGREE; it cannot prove either is right. This
# pair does: tasks 1 to 5 are real and each must come out non-empty, and the
# four numbers that appear only inside fenced examples must come out empty.
shape_failed=0
for n in 1 2 3 4 5; do
    [ -s "$TEST_ROOT/awk-$n.md" ] || { echo "        real task $n came out empty"; shape_failed=$((shape_failed + 1)); }
done
for n in 6 7 8 9; do
    [ -s "$TEST_ROOT/awk-$n.md" ] && { echo "        fenced task $n was extracted"; shape_failed=$((shape_failed + 1)); }
done
if [ "$shape_failed" -eq 0 ]; then
    pass "five real tasks extract, four fenced ones do not"
else
    fail "five real tasks extract, four fenced ones do not — $shape_failed wrong"
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All task-brief tests passed"
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
