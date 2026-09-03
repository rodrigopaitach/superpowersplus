# Review yield, a nit cap, and the problem section — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowersplus:subagent-driven-development or superpowersplus:executing-plans to implement this plan task-by-task — the `**Execution:**` field below names which of the two this plan was handed to, and that is the one to follow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/2026-09-03-review-yield-and-problem-section-design.md`

**Goal:** Give the review loop a record of what it returns, cap the advisory noise it produces, and make the spec carry the problem it solves.

**Architecture:** Every change is text in a skill file, a prompt file, or one script comment — there is no runtime code. What makes each one testable is a new deterministic suite, `tests/review-yield/`, that asserts each rule is present in the file that must carry it, in the idiom `tests/version-bump/test-bump-version.sh:15-24` already uses. The suite grows one assertion group per task and runs in CI from Task 1 onward, so a rule silently deleted by a later edit fails a push.

**Tech Stack:** Bash and `grep`, already the stack of every suite under `tests/` — `.github/workflows/ci.yml:54-60` runs them. No new dependency; the spec's `## External Dependencies` names none and this project is zero-dependency.

**Execution:** [blank until the execution path is chosen]

**Escalation shape** (detail and a worked example: `../../../skills/using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it. A gate verdict name appears only in parentheses, never carrying the explanation.

## Global Constraints

Every task's requirements implicitly include these, copied from the spec's `## Implicit Requirements`:

- **IR1** — A round-1 report writes the absence of previous findings in words ("none — round 1"), never a blank or an omitted line.
- **IR2** — The ledger's column definitions live only in `docs/review-yield.md`; each write point names the file and never restates the columns.
- **IR3** — No reviewer writes the ledger. The controller appends the row, because three of the five prompts declare the review read-only on the checkout.
- **IR4** — The nit cap is worded per face against that face's own bucket name — `#### Minor (Nice to Have)` for the three diff faces, `**Recommendations (advisory, do not block approval):**` for the two document faces — never one sentence shared across all five.
- **IR5** — `## Problem` is written in English, like the six sections already required. The section's content carries no language constraint.
- **IR6** — `docs/review-yield.md` passes `scripts/check-links.sh`, which walks `docs/` recursively.
- **IR7** — The change stages a `CHANGELOG.md` entry with it, as `scripts/check-changelog.sh` requires of any staged change under `skills/`.
- **IR8** — Every corpus figure this document states is produced by the script embedded in `### Corpus measurements`, and by no rule stated only in prose, so a re-measurement that disagrees is settled by running it rather than by re-reading a sentence.

**Outside the block above, and not a constraint:** the gate IR7 names covers more than the one prefix the spec quotes — `scripts/check-changelog.sh:49` declares `skills/ scripts/ githooks/ .github/ hooks/`. Every task below stages `CHANGELOG.md` regardless, so the narrower wording costs nothing here; it is recorded because Task 1 touches `.github/` and Task 7 touches `scripts/` under a skill.

## Test Coverage Matrix

Every row's test lives in `tests/review-yield/test-review-yield-rules.sh`, the suite Task 1 creates. The type name `static` and the layer `tests/` are this repository's own vocabulary: `docs/testing.md:6-8` calls the whole of `tests/` "Bash + node + python checks for manifests, plugin loading, hooks, sync scripts, and skill behavior", and every suite under it asserts against files rather than a running system.

| Criterion | Spec criterion | Test type | Layer | Test |
|-----------|----------------|-----------|-------|------|
| T1.1 The ledger file exists and names its six columns | AC3 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::ledger_columns` |
| T1.2 The suite runs from CI | AC3 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::ci_step_present` |
| T2.1 Each of the four skills instructs the controller to append a row | AC4 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::write_points` |
| T2.2 No write point restates the ledger's columns | IR2 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::columns_not_restated` |
| T2.3 No reviewer prompt is told to write the ledger | IR3 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::reviewers_do_not_write` |
| T3.1 Both document reviewers report previous findings received and still open | AC1, AC2 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::previous_findings_line` |
| T3.2 Round 1 is told to write the absence in words | IR1 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::round_one_in_words` |
| T4.1 All five reviewer prompts cap the advisory bucket at five | AC5 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::nit_cap_present` |
| T4.2 The cap names each face's own bucket, not one shared sentence | IR4 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::nit_cap_per_face` |
| T5.1 `## Problem` is the first row of the required-sections table | AC6 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::problem_required_first` |
| T5.2 A transition covers specs written before the requirement | AC9 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::problem_transition` |
| T6.1 The spec reviewer treats a missing `## Problem` as blocking | AC7 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::problem_blocking` |
| T6.2 The spec reviewer charges a criterion that does not serve the problem | AC8 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::criteria_serve_problem` |
| T7.1 `check-cross-references` names the section-reference class it does not cover | AC10 | static | `tests/` | `tests/review-yield/test-review-yield-rules.sh::not_covered_section_refs` |

**IR5, IR6, IR7 and IR8 carry no row of their own, and each is covered elsewhere by an existing gate rather than dropped.** IR5 is asserted inside `problem_required_first`, which matches the English heading literally. IR6 is `scripts/check-links.sh`, which walks `docs/` recursively (`scripts/check-links.sh:71`) and runs from `githooks/pre-commit`. IR7 is `scripts/check-changelog.sh`, in the same hook. IR8 constrains the spec, not this plan — no task restates a corpus figure, which is the whole of its reach here.

---

### Task 1: The ledger and the suite that guards it

**Spec criterion:** `AC3` — `docs/review-yield.md` exists and defines its own columns in its header.

**Files:**
- Create: `docs/review-yield.md`
- Create: `tests/review-yield/test-review-yield-rules.sh`
- Modify: `.github/workflows/ci.yml`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Produces: the shell function `assert_contains FILE PATTERN LABEL` and the counters `FAILURES` / `REPO_ROOT`, which every later task's assertions call. It prints `ok <label>` or `FAIL <label> — <file> does not carry: <pattern>` and increments `FAILURES` on a miss. Later tasks add assertion groups to the same file and must not redefine it.

**Acceptance criteria:**
- T1.1: `docs/review-yield.md` exists and its header names all six columns — date, branch, face, round, blocking findings raised, findings still open from the previous round — test: `tests/review-yield/test-review-yield-rules.sh::ledger_columns`
- T1.2: `.github/workflows/ci.yml` carries a step running this suite — test: `tests/review-yield/test-review-yield-rules.sh::ci_step_present`

- [ ] **Step 1: Write the failing test**

Create `tests/review-yield/test-review-yield-rules.sh`:

```bash
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
```

- [ ] **Step 2: Run it to verify it fails**

Run: `chmod +x tests/review-yield/test-review-yield-rules.sh && tests/review-yield/test-review-yield-rules.sh`
Expected: FAIL — `ledger_columns — docs/review-yield.md does not exist`, and `FAIL ci_step_present`, exit 1

- [ ] **Step 3: Create the ledger**

Create `docs/review-yield.md`:

```markdown
# Review yield

What each review dispatch returned, one row per dispatch. The cost of a review
is already on record — a median of 7.3 minutes across 29 document reviews,
[`CHANGELOG.md`](../CHANGELOG.md), section `[1.16.0] - 2026-08-08`. What it returns was not on
record anywhere, so "are the review passes paying for themselves" could be
argued and never answered.

**One row per dispatch, not per face and not per branch.** The round is what
the question turns on: if round 2 and round 3 keep coming back with zero
blocking findings, the extra rounds buy nothing, and that is legible here
without anyone reading prose.

**The controller appends the row, never the reviewer.** Three of the five
reviewer prompts declare the review read-only on the checkout —
`skills/requesting-code-review/code-reviewer.md:35`,
`skills/subagent-driven-development/task-reviewer-prompt.md:66`,
`skills/subagent-driven-development/re-review-prompt.md:42`.

| Column | What goes in it |
|---|---|
| Date | The date of the dispatch, `DD/MM/AAAA` |
| Branch | The branch the review ran against |
| Face | `spec`, `plan`, `task <N>`, `re-review <N>`, or `branch` |
| Round | `1` for the first dispatch of that face, then `2`, `3` |
| Blocking findings | How many the reviewer returned in this round |
| Still open from the previous round | How many of the previous round's blocking findings this round found unfixed. `—` on round 1 |

| Date | Branch | Face | Round | Blocking findings | Still open from the previous round |
|---|---|---|---|---|---|
```

- [ ] **Step 4: Add the CI step**

In `.github/workflows/ci.yml`, after the `Tests (version bump preflight)` step at `:56-57`, add:

```yaml
      - name: Tests (review yield rules)
        run: tests/review-yield/test-review-yield-rules.sh
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: PASS — all assertions ok, exit 0

- [ ] **Step 6: Add the changelog entry and commit**

Add under `## [Unreleased]` in `CHANGELOG.md` an entry describing the ledger and its suite. Then:

```bash
git add docs/review-yield.md tests/review-yield/test-review-yield-rules.sh .github/workflows/ci.yml CHANGELOG.md
git commit -m "feat: a ledger for what each review dispatch returns"
```

---

### Task 2: The four write points

**Spec criterion:** `AC4` — four skills instruct the controller to append one row per review dispatch.

**Files:**
- Modify: `skills/brainstorming/SKILL.md` — section "Spec Review", after the run-report line at `:290`
- Modify: `skills/writing-plans/SKILL.md` — section "Plan Review", after the run-report line at `:419`
- Modify: `skills/subagent-driven-development/SKILL.md` — sections `### 3. Review the task` at `:250` and `### 4. The fix loop` at `:311`
- Modify: `skills/requesting-code-review/SKILL.md` — section `**3. Act on feedback:**` at `:52`
- Modify: `tests/review-yield/test-review-yield-rules.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `assert_contains` and `FAILURES` from Task 1.
- Produces: nothing later tasks depend on.

**Acceptance criteria:**
- T2.1: each of the four skills carries an instruction naming `docs/review-yield.md` as the file to append a row to — test: `tests/review-yield/test-review-yield-rules.sh::write_points`
- T2.2: no write point restates the ledger's column names — test: `tests/review-yield/test-review-yield-rules.sh::columns_not_restated`
- T2.3: no reviewer prompt carries an instruction to append to the ledger — test: `tests/review-yield/test-review-yield-rules.sh::reviewers_do_not_write`

- [ ] **Step 1: Write the failing test**

Add to `tests/review-yield/test-review-yield-rules.sh`, before the invocation block at the bottom:

```bash
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
```

Then add `write_points`, `columns_not_restated` and `reviewers_do_not_write` to the invocation block.

- [ ] **Step 2: Run it to verify it fails**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: FAIL — four `write_points` failures; `columns_not_restated` and `reviewers_do_not_write` both passing, because nothing has been written yet. Exit 1.

**The two passing functions are the point, not an accident.** They guard against the wrong fix: `columns_not_restated` fails if a write point copies the ledger's column names into a skill, and `reviewers_do_not_write` fails if the append instruction lands in a reviewer prompt instead of a controller. Both are green before the change and must stay green after — a state neither can reach by the change succeeding.

- [ ] **Step 3: Add the instruction to the two document faces**

In `skills/brainstorming/SKILL.md`, immediately after the evidence-line block that follows `Report the run to your human partner in the form every carrier uses:`, add:

```markdown
**Then append one row to [`docs/review-yield.md`](../../docs/review-yield.md)** —
this dispatch's date, branch, face `spec`, the round, how many blocking findings
came back, and how many of the previous round's are still open. The file's own
header says what each column holds; do not restate it here. The reviewer cannot
write this row: its review is read-only on the checkout.
```

In `skills/writing-plans/SKILL.md`, at the same position after its own run-report line, add the identical paragraph with `face `plan`` in place of `face `spec``.

- [ ] **Step 4: Add the instruction to the two task-loop faces and the branch face**

In `skills/subagent-driven-development/SKILL.md`, at the end of `### 3. Review the task`, add:

```markdown
**Append one row to [`docs/review-yield.md`](../../docs/review-yield.md)** for
this dispatch: face `task <N>`, round `1`, the blocking findings the reviewer
returned, and `—` in the last column. The file's header defines the columns.
```

At the end of `### 4. The fix loop`, add:

```markdown
**Append one row to [`docs/review-yield.md`](../../docs/review-yield.md)** for
each re-review: face `re-review <N>`, the round number, its blocking findings,
and how many of the previous round's this one found still open.
```

In `skills/requesting-code-review/SKILL.md`, at the start of `**3. Act on feedback:**`, add:

```markdown
**First, append one row to [`docs/review-yield.md`](../../docs/review-yield.md)**:
face `branch`, round `1`, the count of Critical and Important findings, and `—`
in the last column. Then act on the findings.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: PASS — all assertions ok, exit 0

- [ ] **Step 6: Add the changelog entry and commit**

```bash
git add skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md skills/subagent-driven-development/SKILL.md skills/requesting-code-review/SKILL.md tests/review-yield/test-review-yield-rules.sh CHANGELOG.md
git commit -m "feat: the four review faces record what their dispatch returned"
```

---

### Task 3: The previous-findings line in the two document reviewers

**Spec criterion:** `AC1` and `AC2` — both document reviewer prompts report how many findings the previous round raised and how many are still open.

**Files:**
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md` — section "Output Format", at `:230`
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md` — section "Output Format", at `:162`
- Modify: `tests/review-yield/test-review-yield-rules.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `assert_contains` and `FAILURES` from Task 1.
- Produces: nothing later tasks depend on.

**Acceptance criteria:**
- T3.1: both prompts carry a `**Previous findings:**` line in their Output Format — test: `tests/review-yield/test-review-yield-rules.sh::previous_findings_line`
- T3.2: both prompts tell a round-1 reviewer to write the absence in words rather than leaving the line out — test: `tests/review-yield/test-review-yield-rules.sh::round_one_in_words`

- [ ] **Step 1: Write the failing test**

Add to `tests/review-yield/test-review-yield-rules.sh`:

```bash
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
```

Then add both to the invocation block.

- [ ] **Step 2: Run it to verify it fails**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: FAIL — four failures across the two functions, exit 1

- [ ] **Step 3: Add the line to both prompts**

In `skills/brainstorming/spec-document-reviewer-prompt.md`, inside the fenced prompt body, directly under `**Status:** Approved | Issues Found`, add:

```markdown
    **Previous findings:** [N] received — [M] still open: [which, or "none"]

    On round 1 write this line as `none — round 1`. Leaving it out makes a
    round that carried no previous findings and a round whose verdicts you
    skipped render identically.
```

Add the identical two blocks at the same position in `skills/writing-plans/plan-document-reviewer-prompt.md`.

- [ ] **Step 4: Run the test to verify it passes**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: PASS — all assertions ok, exit 0

- [ ] **Step 5: Add the changelog entry and commit**

```bash
git add skills/brainstorming/spec-document-reviewer-prompt.md skills/writing-plans/plan-document-reviewer-prompt.md tests/review-yield/test-review-yield-rules.sh CHANGELOG.md
git commit -m "feat: the document reviewers say what the previous round left open"
```

---

### Task 4: The nit cap, worded per face

**Spec criterion:** `AC5` — each of the five reviewer prompts caps its advisory bucket at five items and reports the remainder as a count.

**Files:**
- Modify: `skills/requesting-code-review/code-reviewer.md` — the `#### Minor (Nice to Have)` bucket at `:118`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md` — the `#### Minor (Nice to Have)` bucket at `:206`
- Modify: `skills/subagent-driven-development/re-review-prompt.md` — the `### Out-of-Scope Observations` bucket at `:110`
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md` — the `**Recommendations (advisory, do not block approval):**` bucket at `:240`
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md` — the same bucket at `:172`
- Modify: `tests/review-yield/test-review-yield-rules.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `assert_contains` and `FAILURES` from Task 1.
- Produces: nothing later tasks depend on.

**Acceptance criteria:**
- T4.1: all five prompts carry a cap of five with the remainder reported as a count — test: `tests/review-yield/test-review-yield-rules.sh::nit_cap_present`
- T4.2: the three diff faces name `Minor` or `Out-of-Scope` in their cap sentence and the two document faces name `Recommendations`, so the wording follows each face's own bucket — test: `tests/review-yield/test-review-yield-rules.sh::nit_cap_per_face`

- [ ] **Step 1: Write the failing test**

Add to `tests/review-yield/test-review-yield-rules.sh`:

```bash
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
```

Then add both to the invocation block.

- [ ] **Step 2: Run it to verify it fails**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: FAIL — assertions across all five prompts, exit 1

- [ ] **Step 3: Add the cap to the three diff faces**

In `skills/requesting-code-review/code-reviewer.md`, under the `#### Minor (Nice to Have)` bucket description, add:

```markdown
    Report at most five Minor items, and the remainder as a count. A long
    Minor list buries the Critical one above it.
```

In `skills/subagent-driven-development/task-reviewer-prompt.md`, add the identical two lines under its own `#### Minor (Nice to Have)` bucket.

In `skills/subagent-driven-development/re-review-prompt.md`, under `### Out-of-Scope Observations`, add:

```markdown
    Report at most five Out-of-Scope items, and the remainder as a count.
    These are ledgered for the final review, not acted on here.
```

- [ ] **Step 4: Add the cap to the two document faces**

In `skills/brainstorming/spec-document-reviewer-prompt.md`, under `**Recommendations (advisory, do not block approval):**`, add:

```markdown
    Report at most five Recommendations, and the remainder as a count. These
    do not block approval, so a long list costs attention the blocking
    findings need.
```

Add the identical block at the same position in `skills/writing-plans/plan-document-reviewer-prompt.md`.

- [ ] **Step 5: Run the test to verify it passes**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: PASS — all assertions ok, exit 0

- [ ] **Step 6: Add the changelog entry and commit**

```bash
git add skills/requesting-code-review/code-reviewer.md skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/re-review-prompt.md skills/brainstorming/spec-document-reviewer-prompt.md skills/writing-plans/plan-document-reviewer-prompt.md tests/review-yield/test-review-yield-rules.sh CHANGELOG.md
git commit -m "feat: five reviewer faces cap their advisory bucket at five"
```

---

### Task 5: `## Problem` becomes a required section

**Spec criterion:** `AC6` and `AC9` — the required-sections table requires `## Problem` as its first row, and a transition covers specs written before the requirement.

**Files:**
- Modify: `skills/brainstorming/SKILL.md` — the required-sections table under section "After the Design", which begins at `:230`
- Modify: `tests/review-yield/test-review-yield-rules.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `assert_contains` and `FAILURES` from Task 1.
- Produces: the required section name `## Problem`, which Task 6 charges in the reviewer.

**Acceptance criteria:**
- T5.1: the required-sections table's first data row is `## Problem`, ahead of `## Acceptance Criteria` — test: `tests/review-yield/test-review-yield-rules.sh::problem_required_first`
- T5.2: the skill carries a transition instruction for specs written before the requirement — test: `tests/review-yield/test-review-yield-rules.sh::problem_transition`

- [ ] **Step 1: Write the failing test**

Add to `tests/review-yield/test-review-yield-rules.sh`:

```bash
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
```

Then add both to the invocation block.

- [ ] **Step 2: Run it to verify it fails**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: FAIL — `problem_required_first — skills/brainstorming/SKILL.md has no \`## Problem\` row`, and `FAIL problem_transition`, exit 1

**The `|| true` on both assignments is load-bearing, not defensive noise.** The suite runs under `set -euo pipefail`, and a bare assignment from a pipeline takes that pipeline's exit status: when `grep` matches nothing it exits 1, `pipefail` carries it to the assignment, and `set -e` kills the script *before* the function prints its own `FAIL` line and before any later assertion runs. Measured by difference on 2026-09-03: without `|| true` the run produced **no output at all** and exit 1; with it, the intended `FAIL` line and the rest of the suite. A harness that dies silently on the state it exists to report is the failure this suite is written to prevent, occurring inside the suite.

- [ ] **Step 3: Add the row, above `## Acceptance Criteria`**

In `skills/brainstorming/SKILL.md`, in the required-sections table, insert as the first data row:

```markdown
| `## Problem` | What is wrong today, who it affects, and what is out of scope — stated before any criterion, because a criterion is an answer and this is the question. Every `AC` and `IR` below it exists to serve what this section states; one that serves something else is scope that arrived without being asked for, and superpowersplus:brainstorming's spec reviewer charges it. Written in English, like every heading in this table; its content follows the language of the conversation. |
```

- [ ] **Step 4: Add the transition**

Directly under the required-sections table, add:

```markdown
**Resuming a spec written before `## Problem` became required?** Write the
section from what the spec already says — the request it opens with, the
findings that motivated it — and do not reopen the design. A spec that never
had the chance to comply is not an author who skipped it, and the two must not
be treated alike.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: PASS — all assertions ok, exit 0

- [ ] **Step 6: Add the changelog entry and commit**

```bash
git add skills/brainstorming/SKILL.md tests/review-yield/test-review-yield-rules.sh CHANGELOG.md
git commit -m "feat: the spec carries the problem it solves"
```

---

### Task 6: The spec reviewer charges the problem section

**Spec criterion:** `AC7` and `AC8` — a missing `## Problem` is blocking, and every acceptance criterion that does not serve the stated problem is charged.

**Files:**
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md` — the Traceability blocking table, which begins at `:131`
- Modify: `tests/review-yield/test-review-yield-rules.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `assert_contains` and `FAILURES` from Task 1; the required section name `## Problem` from Task 5.
- Produces: nothing later tasks depend on.

**Acceptance criteria:**
- T6.1: the prompt carries a blocking row for a missing `## Problem` — test: `tests/review-yield/test-review-yield-rules.sh::problem_blocking`
- T6.2: the prompt carries a blocking row for a criterion that does not serve the stated problem — test: `tests/review-yield/test-review-yield-rules.sh::criteria_serve_problem`

- [ ] **Step 1: Write the failing test**

Add to `tests/review-yield/test-review-yield-rules.sh`:

```bash
problem_blocking() {
    assert_contains "skills/brainstorming/spec-document-reviewer-prompt.md" \
        'No `## Problem` section \| BLOCKING' 'problem_blocking'
}

criteria_serve_problem() {
    assert_contains "skills/brainstorming/spec-document-reviewer-prompt.md" \
        'does not serve the stated problem' 'criteria_serve_problem'
}
```

Then add both to the invocation block.

- [ ] **Step 2: Run it to verify it fails**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: FAIL — both assertions, exit 1

- [ ] **Step 3: Add both rows to the Traceability table**

In `skills/brainstorming/spec-document-reviewer-prompt.md`, in the Traceability blocking table, add:

```markdown
    | No `## Problem` section | BLOCKING — the same treatment the other required sections get. Report it as: "spec predates the requirement — write the section from what the spec already says before proceeding." The section became required after most specs were written, and a spec that never had the chance to comply is not an author who skipped it |
    | An acceptance criterion that does not serve the stated problem | BLOCKING — name the criterion and what it serves instead. Everything downstream traces criteria to tasks and tasks to evidence; nothing else in the chain ever asks whether the specification addressed the problem, so this is the only place it is charged |
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: PASS — all assertions ok, exit 0

- [ ] **Step 5: Add the changelog entry and commit**

```bash
git add skills/brainstorming/spec-document-reviewer-prompt.md tests/review-yield/test-review-yield-rules.sh CHANGELOG.md
git commit -m "feat: the spec reviewer charges criteria against the stated problem"
```

---

### Task 7: `check-cross-references` declares the class it does not cover

**Spec criterion:** `AC10` — the script names, in its `WHAT IT DOES NOT COVER` block, that a section reference into another file is not resolved, and where that class is covered instead.

**Files:**
- Modify: `skills/writing-plans/scripts/check-cross-references` — the `WHAT IT DOES NOT COVER` block, which begins at `:17`
- Modify: `tests/review-yield/test-review-yield-rules.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `assert_contains` and `FAILURES` from Task 1.
- Produces: nothing.

**Acceptance criteria:**
- T7.1: the script's `WHAT IT DOES NOT COVER` block names the section-reference class and where it is covered instead — test: `tests/review-yield/test-review-yield-rules.sh::not_covered_section_refs`

- [ ] **Step 1: Write the failing test**

Add to `tests/review-yield/test-review-yield-rules.sh`:

```bash
not_covered_section_refs() {
    local f="skills/writing-plans/scripts/check-cross-references"
    assert_contains "$f" 'section reference into another file' \
        'not_covered_section_refs: names the class'
    assert_contains "$f" 'check-links\.sh' \
        'not_covered_section_refs: names where it is covered'
}
```

Then add it to the invocation block.

- [ ] **Step 2: Run it to verify it fails**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: FAIL — both assertions, exit 1

- [ ] **Step 3: Add the bullet to the block**

In `skills/writing-plans/scripts/check-cross-references`, as the last bullet of the `WHAT IT DOES NOT COVER` block:

```bash
#   * A section reference into another file — a markdown link to a document,
#     followed by a comma and a quoted section title.
#     This script resolves headings only inside the document under check, to
#     find its own AC/IR lists. A reference naming a heading that does not
#     exist in the target passes here. In THIS repository that class is caught
#     by scripts/check-links.sh from the pre-commit hook; in a project that
#     installs the plugin without it, nothing catches it. Declared rather than
#     implemented because no reference of this shape was found broken when the
#     class was measured; the count and its date are in the changelog entry for
#     this change, where a number that ages stays legible as dated.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `tests/review-yield/test-review-yield-rules.sh`
Expected: PASS — all assertions ok, exit 0

- [ ] **Step 5: Verify the script itself still runs**

Run: `./skills/writing-plans/scripts/check-cross-references docs/superpowers/specs/2026-09-03-review-yield-and-problem-section-design.md .`
Expected: exit 0 — every reference resolves. A comment cannot change behavior, and this run is what proves the edit landed in a comment.

- [ ] **Step 6: Add the changelog entry and commit**

**The changelog entry for this task carries the measurement the comment defers to**, and is the only place it appears: how many section references were found across the corpus, how many named a missing heading, and the date of the run. The script comment states the condition; a measured number lives in `CHANGELOG.md` with its date, per `CLAUDE.md`, section "How you work here". Without this line the comment's forward reference points at content nobody was told to write.

```bash
git add skills/writing-plans/scripts/check-cross-references tests/review-yield/test-review-yield-rules.sh CHANGELOG.md
git commit -m "fix: a green mechanical check no longer reads as coverage of section references"
```
