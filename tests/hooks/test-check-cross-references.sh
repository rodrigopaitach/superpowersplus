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

run_case "announced count matches when the extras are fenced" 0 "$FENCED_TASKS

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

run_case "a fenced citation past end of file fails" 1 "${CLEAN_SPEC}

\`\`\`bash
# see \`src/verify.ts:99\` for the detail
\`\`\`"

# AC8: a plan creates its tests inside fenced code blocks, so the test finder
# must keep reading them. This case is the guard that the fence work above did
# not reach into it — the plan's only test lives inside a fenced block, and the
# matrix names it.
run_case "a fenced step still creates its test" 0 '# Plan

## Task 1: Build it

Acceptance criteria:
- T1.1 rejects the bad input

Step 1: write the test.

```js
it("rejects the bad input", () => {})
```

## Test Coverage Matrix

| Criterion | Test |
|---|---|
| T1.1 | > rejects the bad input |'

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

echo
if [[ "$FAILURES" -eq 0 ]]; then
    echo "All check-cross-references tests passed"
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
