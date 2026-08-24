#!/usr/bin/env bash
#
# Tests for skills/writing-plans/scripts/check-cross-references.
#
# Each case builds a throwaway git repository with a source file to cite and a
# document to check, then runs the real script against it. The repository is
# real because the script resolves short citations through `git ls-files` — a
# fixture without git would exercise a path the real runs never take.
#
# The cases that matter are the pairs: a clean document must PASS and the same
# document with ONE reference broken must FAIL. A gate that only ever fails is
# a gate nobody can distinguish from a broken invocation.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/skills/writing-plans/scripts/check-cross-references"
# The IR6 baseline is PINNED to the commit this branch was cut from, not
# derived from `merge-base main HEAD`. Derived, it becomes HEAD itself once the
# branch merges — on a push to main, actions/checkout creates refs/heads/main,
# so the "before" script becomes the "after" script and the case is either
# vacuous or, if the extracted copy cannot import its module, red for a reason
# that has nothing to do with the corpus. Pinned, it keeps asserting the one
# thing it exists for: this change moved no committed document's verdict.
#
# The pin narrows as the corpus grows: the loop below skips any document the
# baseline commit does not carry, so a document added after this pin is never
# compared. That is correct — there is no "before" verdict for it — but it means
# coverage falls with every release while the case goes on reading as green.
# It stops earning its place when the fence rewrite is no longer the newest
# reason a verdict could move; at that point delete it rather than repin, since
# a pin moved forward compares two versions of the same scanner.
BASE_REF="${BASE_REF:-0aa28b760dad693a544b39f5e7dbe9929d519071}"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

# Builds a fixture repo in $1 with a 20-line source file at src/verify.ts.
make_repo() {
    local dir="$1"
    mkdir -p "$dir/src" "$dir/docs"
    for i in $(seq 1 20); do echo "line $i"; done >"$dir/src/verify.ts"
    git -C "$dir" init -q
    git -C "$dir" add -A
    git -C "$dir" -c user.email=t@t -c user.name=t commit -qm fixture
}

# run_case <name> <expected exit> <document body>
run_case() {
    local name="$1" expected="$2" body="$3"
    local slug dir
    slug="$(echo "$name" | tr ' /' '__')"
    dir="$TEST_ROOT/$slug"
    make_repo "$dir"
    printf '%s\n' "$body" >"$dir/docs/doc.md"
    local actual=0
    "$SCRIPT_UNDER_TEST" "$dir/docs/doc.md" "$dir" >/dev/null 2>&1 || actual=$?
    if [[ "$actual" == "$expected" ]]; then
        pass "$name (exit $actual)"
    else
        fail "$name — expected exit $expected, got $actual"
        # `|| true`: the script exits non-zero by design here, and under
        # `set -euo pipefail` a bare failing pipeline aborts the whole suite at
        # the first failure — which made the "N test(s) failed" summary below
        # unreachable and hid every failure after the first one.
        { "$SCRIPT_UNDER_TEST" "$dir/docs/doc.md" "$dir" 2>&1 | sed 's/^/        /'; } || true
    fi
}

echo "Testing check-cross-references"

# --- spec shape: AC/IR ids -------------------------------------------------
CLEAN_SPEC='# Spec

## Acceptance Criteria

- AC1 The thing happens
- AC2 The other thing happens

## Implicit Requirements

- IR1 It logs the failure

## Codebase Findings

AC1 is grounded at `src/verify.ts:8`, AC2 at `src/verify.ts:12`, IR1 at
`verify.ts:3` (short form, one match).'

run_case "clean spec passes" 0 "$CLEAN_SPEC"

run_case "spec citing an undefined id fails" 1 "${CLEAN_SPEC}

The design also satisfies AC9, which no list defines."

run_case "spec citing past the end of a file fails" 1 "${CLEAN_SPEC}

One more finding at \`src/verify.ts:99\`."

run_case "spec citing a file that does not exist fails" 1 "${CLEAN_SPEC}

One more finding at \`src/nowhere.ts:3\`."

# --- plan shape: task criteria, matrix, tests ------------------------------
CLEAN_PLAN='# Plan

## Task 1: Build it

Acceptance criteria:
- T1.1 rejects the bad input

Step 1: write the test.

```js
it("rejects the bad input", () => {})
```

Grounded at `src/verify.ts:4`.

## Test Coverage Matrix

| Criterion | Test |
|---|---|
| T1.1 | > rejects the bad input |'

run_case "clean plan passes" 0 "$CLEAN_PLAN"

# The added row names a test that DOES exist, so the only thing wrong with it
# is the orphan label. Naming an absent test here made this case pass on the
# test-existence check instead — green for a mechanism its own name disclaims,
# and a mutation that disabled the label comparison left it green.
run_case "matrix label with no criterion in a task body fails" 1 "${CLEAN_PLAN}
| T2.7 | > rejects the bad input |"

run_case "task criterion with no matrix row fails" 1 "$(printf '%s' "$CLEAN_PLAN" |
    sed 's/^- T1.1 rejects the bad input$/- T1.1 rejects the bad input\n- T1.2 accepts the good input/')"

run_case "matrix naming a test no step creates fails" 1 "$(printf '%s' "$CLEAN_PLAN" |
    sed 's/| T1.1 | > rejects the bad input |/| T1.1 | > a test nobody wrote |/')"

run_case "announced task count that disagrees fails" 1 "${CLEAN_PLAN}

This plan has 4 tasks."

# --- fence awareness ------------------------------------------------------
# A plan that documents the plan format carries `## Task N` inside fenced
# examples. Measured 2026-08-24: the fence-blind extractor reported 17 tasks for
# a real plan carrying five, and 10 for a document carrying none.
FENCED_TASKS="$(printf '%s\n' "$CLEAN_PLAN" '' '````markdown' '## Task 7: an example' '' '```js' 'it("nothing", () => {})' '```' '````')"

run_case "fenced task headings are not counted" 0 "$FENCED_TASKS

This plan has 1 task."

# AC2 needs a fenced ANNOUNCEMENT, not just a fenced heading. With the fixture
# above, this case was byte-identical to the one before it and went red only
# through AC1's mechanism: mutating the announced-count scan at
# `check-cross-references:220` from `prose_text` back to `text` left the whole
# suite green. The sentence below sits inside the example, where a fence-blind
# scan reads it as this document's own claim.
FENCED_ANNOUNCE="$(printf '%s\n' "$CLEAN_PLAN" '' '````markdown' '## Task 7: an example' '' 'This example plan has 4 tasks.' '' '```js' 'it("nothing", () => {})' '```' '````')"

run_case "announced count matches when the extras are fenced" 0 "$FENCED_ANNOUNCE

This plan has 1 task."

# The `## Notes` heading is load-bearing. Without it the fenced section runs to
# the end of the file, swallows the AC9 citation below, and AC9 reads as
# DEFINED — so the case passes before the fix, for a mechanism its own name
# disclaims. With it, the pre-fix run charges AC9 as dangling and the case is
# red until the fenced heading stops starting a section.
run_case "a fenced acceptance-criteria heading defines nothing" 0 '# Doc

```markdown
## Acceptance Criteria

- AC1 only an example
```

## Notes

The design also satisfies AC9, which no list defines.'

run_case "a fenced matrix table raises no orphan label" 0 "${CLEAN_PLAN}

An example of the shape:

\`\`\`markdown
| T9.9 | > a test nobody wrote |
\`\`\`"

run_case "fenced task criteria are not counted" 0 "${CLEAN_PLAN}

\`\`\`markdown
- T4.4 an example criterion
\`\`\`"

# T3.5 asserts a COUNT, and run_case reads only the exit code. Reverting the
# extractor to the raw text leaves this document exiting 0 and moves the
# summary from `task criteria 1` to `task criteria 2` — green, with the number
# wrong. The criterion is the number, so the number is what gets read.
count_dir="$TEST_ROOT/printed_task_criteria"
make_repo "$count_dir"
printf '%s\n' "${CLEAN_PLAN}

\`\`\`markdown
- T4.4 an example criterion
\`\`\`" >"$count_dir/docs/doc.md"
count_out="$("$SCRIPT_UNDER_TEST" "$count_dir/docs/doc.md" "$count_dir" 2>&1 || true)"
if printf '%s' "$count_out" | grep -q 'task criteria 1,'; then
    pass "the printed task-criteria count omits fenced labels"
else
    fail "the printed task-criteria count omits fenced labels"
    { printf '%s' "$count_out" | grep -o 'task criteria [0-9]*' | sed 's/^/        /'; } || true
fi

run_case "a fenced citation past end of file fails" 1 "${CLEAN_SPEC}

\`\`\`bash
# see \`src/verify.ts:99\` for the detail
\`\`\`"

# AC8: a plan creates its tests inside fenced code blocks, so the test finder
# must keep reading them. This case is the guard that the fence work above did
# not reach into it.
#
# The test name appears ONLY inside the fenced block and in the matrix row —
# never on the criterion line. That placement is the whole case: writing-plans
# requires a real criterion line to name its covering test, so a fixture that
# followed the convention would carry the name in prose too, and the case would
# pass even with the test finder blinded to fences. Measured: with the name on
# the criterion line, blinding the finder leaves this case green.
run_case "a fenced step still creates its test" 0 '# Plan

## Task 1: Build it

Acceptance criteria:
- T1.1 rejects the bad input

Step 1: write the test.

```js
it("only inside the fence", () => {})
```

## Test Coverage Matrix

| Criterion | Test |
|---|---|
| T1.1 | > only inside the fence |'

run_case "a fenced undefined id still fails" 1 "${CLEAN_SPEC}

\`\`\`markdown
The design also satisfies AC9, which no list defines.
\`\`\`"

# --- unreadable input, and where the module comes from ---------------------
# An unclosed fence swallows every heading after it, which turns the checks off
# rather than failing them — a green verdict on a document the script stopped
# reading. scripts/check-no-dispatch.sh:120 is this project's precedent for
# failing when a gate cannot read its input.
run_case "an unterminated fence fails naming its line" 1 "${CLEAN_SPEC}

\`\`\`markdown
## Acceptance Criteria
"

# The script is packaged with the plugin and run against arbitrary repositories,
# so it must find its module beside itself and never relative to the caller's
# working directory.
elsewhere="$(mktemp -d "$TEST_ROOT/elsewhere.XXXXXX")"
away_repo="$TEST_ROOT/away"
make_repo "$away_repo"
printf '%s\n' "$CLEAN_SPEC" >"$away_repo/docs/doc.md"
away_exit=0
(cd "$elsewhere" && "$SCRIPT_UNDER_TEST" "$away_repo/docs/doc.md" "$away_repo" >/dev/null 2>&1) || away_exit=$?
if [ "$away_exit" -eq 0 ]; then
    pass "runs from an unrelated working directory"
else
    fail "runs from an unrelated working directory — exit $away_exit"
    { (cd "$elsewhere" && "$SCRIPT_UNDER_TEST" "$away_repo/docs/doc.md" "$away_repo" 2>&1) | sed 's/^/        /'; } || true
fi

# --- section levels, the letter suffix, the dead names ---------------------
# section() started on `## <title>` and returned at the next heading of ANY
# depth, so a section organising its criteria under `###` ended at its own first
# subsection. Measured 2026-08-24 on a committed spec: the section returned zero
# ids where it holds 21 — nineteen AC it defines plus two IR cited inside it —
# and fourteen were reported as cited-but-undefined.
run_case "a section survives its own subsections" 0 '# Spec

## Acceptance Criteria

### First group

- AC1 The thing happens

### Second group

- AC2 The other thing happens

## Implicit Requirements

- IR1 It logs the failure

## Codebase Findings

Both are grounded in the module under test.'

# TASK_CRIT carried no optional letter suffix while AC_IR on the line above did.
# Anchored with \b, `T1.1a` matched nothing at all, so the matrix row stopped
# being a matrix row and the three checks that depend on it stopped running.
run_case "a suffixed criterion label is still checked" 1 "$(printf '%s' "$CLEAN_PLAN" |
    sed 's/T1\.1/T1.1a/g; s/| > rejects the bad input |/| > a test nobody wrote |/')"

# IR5: the nine cases this suite carried before the branch are named here, so
# a later edit that quietly drops one is a failure rather than a smaller suite.
#
# The grep is anchored on `run_case "` and not on the name alone: the loop's own
# list below holds all nine strings, so a bare name search matches this block
# and passes whatever the suite actually contains.
missing_original=0
for original in \
    "clean spec passes" \
    "spec citing an undefined id fails" \
    "spec citing past the end of a file fails" \
    "spec citing a file that does not exist fails" \
    "clean plan passes" \
    "matrix label with no criterion in a task body fails" \
    "task criterion with no matrix row fails" \
    "matrix naming a test no step creates fails" \
    "announced task count that disagrees fails"; do
    if ! grep -Fq "run_case \"$original\"" "$0"; then
        echo "        missing: $original"
        missing_original=$((missing_original + 1))
    fi
done
if [ "$missing_original" -eq 0 ]; then
    pass "the nine original cases are still here"
else
    fail "the nine original cases are still here — $missing_original dropped"
fi

if grep -q 'body_only\|matrix_only' "$SCRIPT_UNDER_TEST"; then
    fail "no dead names survive"
    { grep -n 'body_only\|matrix_only' "$SCRIPT_UNDER_TEST" | sed 's/^/        /'; } || true
else
    pass "no dead names survive"
fi

# IR6: the committed corpus keeps its verdicts. The one document that changes is
# the one AC4 exists for, and it changes by LOSING a fabricated failure while
# keeping the real one, so its exit code does not move.
corpus_moved=0
corpus_skipped=""
if ! git -C "$REPO_ROOT" cat-file -e "$BASE_REF^{commit}" 2>/dev/null; then
    corpus_skipped="baseline commit $BASE_REF is not in this repository"
else
    git -C "$REPO_ROOT" show "$BASE_REF:skills/writing-plans/scripts/check-cross-references" \
        >"$TEST_ROOT/ccr-before" 2>/dev/null && chmod +x "$TEST_ROOT/ccr-before"
    # The baseline script may import the shared scanner. Extract it beside the
    # script when the baseline carries one: the carrier resolves its module
    # from its own directory, so a copy without it raises ModuleNotFoundError
    # for every document and the case reports the whole corpus as moved.
    if git -C "$REPO_ROOT" cat-file -e "$BASE_REF:skills/writing-plans/scripts/mdfence.py" 2>/dev/null; then
        git -C "$REPO_ROOT" show "$BASE_REF:skills/writing-plans/scripts/mdfence.py" \
            >"$TEST_ROOT/mdfence.py"
    fi
fi
for doc in "$REPO_ROOT"/docs/superpowers/specs/*.md "$REPO_ROOT"/docs/superpowers/plans/*.md; do
    [ -n "$corpus_skipped" ] && break
    [ -s "$TEST_ROOT/ccr-before" ] || continue
    # IR6 is scoped to the documents that PREDATE this branch. This branch's own
    # spec and plan are excluded because they are the corpus the branch was
    # written against, not evidence about it: the plan moves 1 -> 0 by design
    # when the test-name comparison stops knowing languages, and charging that
    # here would make the intended fix look like a regression.
    rel="${doc#"$REPO_ROOT"/}"
    git -C "$REPO_ROOT" cat-file -e "$BASE_REF:$rel" 2>/dev/null || continue
    before=0
    "$TEST_ROOT/ccr-before" "$doc" "$REPO_ROOT" >/dev/null 2>&1 || before=$?
    after=0
    "$SCRIPT_UNDER_TEST" "$doc" "$REPO_ROOT" >/dev/null 2>&1 || after=$?
    if [ "$before" != "$after" ]; then
        echo "        $(basename "$doc"): $before -> $after"
        corpus_moved=$((corpus_moved + 1))
    fi
done
if [ -n "$corpus_skipped" ]; then
    fail "the committed corpus keeps its verdicts — could not run: $corpus_skipped"
elif [ "$corpus_moved" -eq 0 ]; then
    pass "the committed corpus keeps its verdicts"
else
    fail "the committed corpus keeps its verdicts — $corpus_moved document(s) moved"
fi

# --- the test-name comparison knows no languages ---------------------------
# Measured 2026-08-24 on this branch's own plan: TEST_DEF knows it(), test(),
# describe(), def test_ and func Test, and reported all 26 of that plan's real
# bash cases as absent. Two designs were measured. "The name appears outside the
# matrix rows" is vacuous — writing-plans requires every task criterion to name
# its covering test, so the criterion line carries the name even when a step
# renamed the test. Searching the code blocks catches that mutation.
BASH_PLAN='# Plan

## Task 1: Build it

Acceptance criteria:
- T1.1 rejects the bad input

Step 1: write the test.

```bash
run_case "rejects the bad input" 0 "$FIXTURE"
```

## Test Coverage Matrix

| Criterion | Test |
|---|---|
| T1.1 | > rejects the bad input |'

run_case "a bash case named in the matrix is created" 0 "$BASH_PLAN"

run_case "a matrix naming a test no code block holds fails" 1 "$(printf '%s' "$BASH_PLAN" |
    sed 's/| T1.1 | > rejects the bad input |/| T1.1 | > a case nobody wrote |/')"

# The case that separates the two designs, and the only one that does. A step
# renames its test; the matrix and the criterion line still carry the old name.
# Searching the code blocks catches it. Searching the whole document does not,
# because writing-plans REQUIRES the criterion line to name its covering test —
# so the name is always somewhere outside the matrix, and the check that looks
# there passes on the one desync it exists for.
run_case "a renamed test is caught even though the criterion still names it" 1 "$(printf '%s' "$BASH_PLAN" |
    sed 's/run_case "rejects the bad input"/run_case "rejects bad input"/')"

echo
if [[ "$FAILURES" -eq 0 ]]; then
    echo "All check-cross-references tests passed"
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
