---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` —
the exact path of the approved design this plan implements, committed. Not
a title, not "the design doc": the path superpowers:final-branch-audit will
open.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

## Test Coverage Matrix

[One row per spec criterion — every `AC` and every `IR` — across every
task. Test types and layer names are this repository's own — see the
section below before filling it.]

| Task | Criterion | Test type | Layer | Test |
|------|-----------|-----------|-------|------|
| 3 | AC1 Rejects expired tokens | unit | `tests/auth/` | `tests/auth/test_verify.py::test_rejects_expired` |
| 5 | AC3 Login survives a token refresh | e2e | `e2e/` | `e2e/login.spec.ts::refreshes mid-session` |
| 5 | IR2 Two refreshes in flight rotate the token once | integration | `tests/integration/` | `tests/integration/test_refresh.py::test_concurrent_refresh_rotates_once` |

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Spec criterion:** [the id of the item in the spec's `## Acceptance
Criteria` or `## Implicit Requirements` list this task exists to deliver —
e.g. `AC4 Refresh rotates the token`, `IR2 Concurrent refreshes rotate
once`. A task with no spec criterion is scope you invented while planning.]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

**Acceptance criteria:**
- AC1: [one observable behavior, stated so a `file:line` citation can settle
  it] — test: `tests/exact/path/to/test.py::test_specific_behavior`
- AC2: [next behavior] — test: `tests/exact/path/to/test.py::test_other`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## Acceptance Criteria

Every task carries them, and superpowers:final-branch-audit charges them one
by one at the end of the branch — one row per criterion, each needing an
implementation `file:line` and a test `file:line` before it counts as
delivered. Write them in the form that audit can settle.

| Requirement | Why |
|-------------|-----|
| One observable behavior per criterion | A criterion bundling three behaviors cannot take one verdict. |
| Stated so a citation settles it | "Handles errors well" is unauditable. "Returns 429 with a `Retry-After` header" is a row the auditor can cite or fail. |
| Names the covering test | The audit fails any criterion whose implementation exists untested. Naming the test here is what makes it exist. |
| Backed by steps that build it | A criterion no step implements is a gap you wrote into the plan yourself. |

An unauditable criterion is a plan failure, exactly like a placeholder — the
auditor charges what the plan wrote, and the branch fails on wording you
controlled.

## Traceability to the Spec

superpowers:final-branch-audit opens the spec and traces it against this
plan, in both directions. Two rules make that pass possible:

| Rule | Why |
|------|-----|
| The header cites the spec's exact committed path | The auditor takes the path from the plan. No citation, and the traceability pass cannot run at all — it is reported as blocking, not skipped. |
| Every task names the spec criterion it delivers | A task tracing to nothing is INVENTED SCOPE at the audit. A spec criterion no task names is LOST IN TRANSLATION. |
| `AC` and `IR` ids trace identically | The audit charges both lists. An implicit requirement no task names fails the same way an acceptance criterion would. |

Both failures are found by reading the spec and the plan side by side —
which is what the auditor does, and what you should do before saving. A
requirement dropped while planning leaves no trace in the plan itself.

If the work genuinely needs a task the spec does not cover, the spec is
incomplete: take it back to your human partner rather than smuggling the
task in. Amending the spec is cheap now and blocking later.

## Test Coverage Matrix

Derived from the spec: one row per criterion, naming the kind of test
required and the layer it lives in. A criterion promised a test in its own
line and given no row is a criterion nobody planned to test.

**`IR` items are criteria of the first class here, not a second tier.** The
spec's `## Implicit Requirements` — concurrency, error handling,
observability, edge cases, limits — get a row each, on the same terms as
every `AC`: a named test type, a real layer, an exact test id. An `IR` with
no row is an omission, not a decision. If one genuinely cannot be tested at
the layers this repository has, say so in the row and take it to your human
partner; do not drop it and do not leave the row blank.

The matrix is what the task reviewer charges test by test, and what marks a
test matching no requirement as invented scope.

**Read this repository's conventions before writing a single row.** You are
recording the standard already in use, not importing one:

| Source | What it tells you |
|--------|-------------------|
| `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` | Stated testing rules, coverage floors, banned patterns |
| Test runner config — `pytest.ini`, `vitest.config.*`, `package.json` scripts, `Makefile` | The command that runs tests, and how suites are split |
| CI workflow files | Which suites gate a merge, and in what order |
| Existing tests | The layers that actually exist here, their directories and naming |

Cite what you found as `path/file.ext:line`. Found nothing — no test
directory, no runner configured? Say that in the matrix and propose the
layers, labeled as a proposal for your human partner to approve.

| Column | Rule |
|--------|------|
| Task | The task that delivers the criterion |
| Criterion | The spec id (`AC1`, `IR2`) plus the text, copied verbatim |
| Test type | This repository's vocabulary, not a generic one — whatever its config and existing tests call the kinds |
| Layer | The real directory the type lives in here |
| Test | The exact test id a step in that task creates |

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Plan Review

Save the complete plan, then dispatch a plan document reviewer subagent
using the template at
[plan-document-reviewer-prompt.md](plan-document-reviewer-prompt.md). The
reviewer reads the file, not your context — save first.

**Do NOT review it inline yourself.** You wrote the plan; reading it again
gives you the same blind spots that wrote it, and the checks that matter
here are exactly the ones an author passes by assumption: that the spec
path resolves, that every criterion has a task, that every task traces
back, that the matrix names tests the steps actually create. The reviewer
opens the spec and reads it against your plan — the same pass
superpowers:final-branch-audit runs at the end of the branch, run now, when
a gap costs a paragraph instead of a re-plan.

Hand it the plan file path and nothing else: the spec path comes from the
plan's own header, and confirming it is part of what the reviewer checks.

Fix every blocking issue the reviewer returns, then re-dispatch.
Recommendations are advisory. If it reports a spec requirement with no
task, add the task — never resolve a gap by narrowing the plan's stated
scope.

## Execution Handoff

After the plan review passes, offer execution choice:

**"Plan complete, reviewed, and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
