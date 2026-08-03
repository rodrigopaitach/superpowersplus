---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowersplus:using-git-worktrees` skill at execution time.

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

**Pick the smallest structure that meets the criterion.** The plan is where the size of the answer is decided — an implementer handed a new layer builds the layer, and every gate downstream passes it, because the gates charge whether the criterion was asked for and tested, never how much was built to meet it.

- Before putting a new layer, module, or abstraction in the plan, check whether structure that already exists in this project meets the criterion. Reusing it means citing it the way every other claim about this codebase is cited — `path/file.ext:line` for the structure you are reusing.
- A new layer, module, or abstraction carries a one-line justification naming the criterion that forces it. One that names no criterion is invented scope under the rule the plan is already held to.
- **That justification line is also where a refused simplification lands.** When the plan reviewer proposes a smaller version and you keep the larger one, the reason goes on that line, in the same form the Coverage Map requires of a `Deferred` or `Outstanding` state: one line, stated, in the document. Refusing is yours to do; refusing silently leaves a structure nobody can tell was questioned from one nobody ever looked at.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

**Work that leaves nothing in the repository is not a task.** The test is the
one the audit already runs: does this task leave something a
`path/file.ext:line` citation can prove? Merging, deploying, applying a
migration to a real environment, publishing a release, a smoke run somebody
performs by hand, watching a metric after rollout — none of them do. They
happen after the conformance audit returns PASS, outside the plan: the merge
through superpowersplus:finishing-a-development-branch, the rest in your
human partner's hands. Written into the plan they deadlock that skill against
the audit: no merge option is presented until the audit PASSes, and the audit
cannot PASS while a task nobody could have run yet carries no evidence. The
plan ends at the last task that leaves a tested deliverable in the branch.

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

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowersplus:subagent-driven-development (recommended) or superpowersplus:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` —
the exact path of the approved design this plan implements, committed. Not
a title, not "the design doc": the path superpowersplus:final-branch-audit will
open.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries. Every entry traces to the
spec's `## External Dependencies` or its architecture section, or to a
manifest already in this repo — name which, `package.json:31`. A library
appearing here for the first time is a design decision nobody approved:
take it to your human partner instead of writing it in.]

**Escalation shape** (detail and a worked example: `../using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it. A gate verdict name (`LOST IN TRANSLATION`, `INVENTED SCOPE`, …) appears only in parentheses, never carrying the explanation.

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

## Test Coverage Matrix

[One row per task criterion, across every task — one row, one test. Every
`AC` and every `IR` in the spec appears in the Spec criterion column of at
least one row. Test types and layer names are this repository's own — see
the section below before filling it.]

| Criterion | Spec criterion | Test type | Layer | Test |
|-----------|----------------|-----------|-------|------|
| T3.1 Rejects expired tokens | AC1 | unit | `tests/auth/` | `tests/auth/test_verify.py::test_rejects_expired` |
| T3.2 Rejected tokens are logged once | AC1 | unit | `tests/auth/` | `tests/auth/test_verify.py::test_logs_one_rejection` |
| T5.1 Login survives a token refresh | AC3 | e2e | `e2e/` | `e2e/login.spec.ts > refreshes mid-session` |
| T5.2 Two refreshes in flight rotate the token once | IR2 | integration | `tests/integration/` | `tests/integration/test_refresh.py::test_concurrent_refresh_rotates_once` |

---
```

## Task Structure

Two registers, and the difference is load-bearing: **bracketed text is a
slot you fill; a code block is code that runs as shown.** A step whose
snippet cannot run is a step the implementer debugs instead of executes.

````markdown
### Task N: [Component Name]

**Spec criterion:** [the id of the item in the spec's `## Acceptance
Criteria` or `## Implicit Requirements` list this task exists to deliver —
e.g. `AC4 Refresh rotates the token`, `IR2 Concurrent refreshes rotate
once`. A task with no spec criterion is scope you invented while planning.]

**Files:**
- Create: `src/auth/verify.py`
- Modify: `src/auth/middleware.py:123-145`
- Test: `tests/auth/test_verify.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

**Acceptance criteria:** [labeled `T<task number>.<n>`. `AC` and `IR` are
the spec's ids and never a task's — the audit reads one table by spec id and
another by task label, and the same string in both is how it conflates them.]
- TN.1: [one observable behavior, stated so a `file:line` citation can settle
  it] — test: `tests/auth/test_verify.py::test_rejects_expired`
- TN.2: [next behavior] — test: `tests/auth/test_verify.py::test_logs_one_rejection`

- [ ] **Step 1: Write the failing test**

```python
def test_rejects_expired():
    assert verify_token(expires_at=0, now=1) is False
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/auth/test_verify.py::test_rejects_expired -v`
Expected: FAIL — `NameError: name 'verify_token' is not defined`

- [ ] **Step 3: Write minimal implementation**

```python
def verify_token(expires_at, now):
    return expires_at > now
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/auth/test_verify.py::test_rejects_expired -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/auth/test_verify.py src/auth/verify.py
git commit -m "feat(auth): reject expired tokens"
```
````

## Acceptance Criteria

Every task carries them, and superpowersplus:final-branch-audit charges them one
by one at the end of the branch — one row per criterion, each needing an
implementation `file:line` and a test `file:line` before it counts as
delivered. Write them in the form that audit can settle.

| Requirement | Why |
|-------------|-----|
| Labeled `T<task number>.<n>`, never `AC` or `IR` | Those two prefixes belong to the spec's ids. The audit's traceability table is keyed by spec id and its delivery table by task label; a task criterion called `AC1` collides with the spec's `AC1` and the two tables stop lining up. |
| One observable behavior per criterion | A criterion bundling three behaviors cannot take one verdict. |
| Stated so a citation settles it | "Handles errors well" is unauditable. "Returns 429 with a `Retry-After` header" is a row the auditor can cite or fail. |
| Names the covering test | The audit fails any criterion whose implementation exists untested. Naming the test here is what makes it exist. |
| Backed by steps that build it | A criterion no step implements is a gap you wrote into the plan yourself. |

An unauditable criterion is a plan failure, exactly like a placeholder — the
auditor charges what the plan wrote, and the branch fails on wording you
controlled.

## Traceability to the Spec

superpowersplus:final-branch-audit opens the spec and traces it against this
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

One row per task criterion, naming the kind of test required, the layer it
lives in, and the spec criterion it refines. **One row, one test:** a task
criterion whose behavior takes two tests is two criteria — split it in the
task, then give each half its row. A task criterion with no row is a
criterion nobody planned to test.

Read the table the other way and it answers the spec: every `AC` and every
`IR` must appear in the Spec criterion column of at least one row. One that
appears in none was never planned for testing, whatever the plan says
elsewhere.

**`IR` items are criteria of the first class here, not a second tier.** The
spec's `## Implicit Requirements` — concurrency, error handling,
observability, edge cases, limits — are refined into task criteria and
tested on the same terms as every `AC`: a named test type, a real layer, an
exact test id. An `IR` in no row is an omission, not a decision. If one
genuinely cannot be tested at the layers this repository has, say so in a
row of its own and take it to your human partner; do not drop it and do not
leave the row blank.

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
| Criterion | The task's own label and text (`T3.1 Rejects expired tokens`), copied verbatim from that task — the label carries the task number, so no separate Task column |
| Spec criterion | The `AC` or `IR` id it refines, taken from that task's `**Spec criterion:**` line |
| Test type | This repository's vocabulary, not a generic one — whatever its config and existing tests call the kinds |
| Layer | The real directory the type lives in here |
| Test | The exact test id a step in that task creates — one per row |

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Code That Calls a Dependency

Every code block here is transcribed, not interpreted: `scripts/task-brief`
extracts the task verbatim and the controller hands it over as "your
requirements, with the exact values to use verbatim". A signature you
half-remembered reaches the implementer labeled as fact, and the first thing
to disagree with it is the running system.

superpowersplus:brainstorming grounds every claim the spec makes about a
library, external API, or third-party service in one of two forms: the
lockfile-pinned version plus the line you read inside the dependency, or the
vendor's official documentation for that version. A step whose code calls
that dependency carries the same source, in the same forms.

| In the step | What it carries |
|-------------|-----------------|
| Code the spec already grounded | The spec's citation, copied into the block as a comment |
| A signature, field name, error code, header, status, or default the spec never stated | Its own source, in one of the two forms. The spec settled the design, not every symbol you now have to type |
| A call you could not ground at either source | Not a step. Take it to your human partner with what you tried — same routing as an unverifiable claim in the spec |

**An unreachable source is not an approval.** Writing the call anyway
inverts the cost: it reaches the implementer as an exact value, the reviewer
sees code that looks deliberate, and the disagreement surfaces at
integration.

The citation and the code have to be the same language: a JavaScript source
cannot ground a Python call, however real the line it points at.

A pinned-source citation names a path you opened in this checkout, never one
you expect to be there. A directory that exists in the vendor's repository
is routinely absent from the published tarball — `stripe`'s `src/*.ts` on
GitHub ships as `cjs/*.js` in `node_modules` — and the reviewer opens what
you cite.

```javascript
// stripe@19.1.0 — https://docs.stripe.com/api/idempotent_requests
// create(params, options): the idempotency key is a request option,
// never a param — RequestOptions.idempotencyKey sets the
// Idempotency-Key header.
const intent = await stripe.paymentIntents.create(
  {amount: 1200, currency: 'brl'},
  {idempotencyKey: key},
);
```

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
superpowersplus:final-branch-audit runs at the end of the branch, run now, when
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
- **REQUIRED SUB-SKILL:** Use superpowersplus:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowersplus:executing-plans
- Batch execution with checkpoints for review
