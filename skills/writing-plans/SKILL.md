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

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

## Test Coverage Matrix

[One row per acceptance criterion, across every task. Test types and layer
names are this repository's own — see the section below before filling it.]

| Task | Criterion | Test type | Layer | Test |
|------|-----------|-----------|-------|------|
| 3 | Rejects expired tokens | unit | `tests/auth/` | `tests/auth/test_verify.py::test_rejects_expired` |
| 5 | Login survives a token refresh | e2e | `e2e/` | `e2e/login.spec.ts::refreshes mid-session` |

---
```

## Task Structure

````markdown
### Task N: [Component Name]

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

## Test Coverage Matrix

Derived from the spec: one row per acceptance criterion, naming the kind of
test required and the layer it lives in. A criterion promised a test in its
own line and given no row is a criterion nobody planned to test.

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
| Criterion | Copied verbatim from that task's acceptance criteria |
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

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Auditable criteria:** Does every task have acceptance criteria, each one observable, settled by a citation, and naming its covering test? Read each one as the auditor will: could a `file:line` prove or disprove it? If not, rewrite it.

**5. Matrix coverage:** Does every acceptance criterion have a row in the Test Coverage Matrix, and does every row name a test some step actually creates? A row pointing at a test no step writes is a placeholder wearing a table.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
