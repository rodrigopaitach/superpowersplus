---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- At the final gate of the subagent path, once, over the whole branch — the
  review after each task there runs a different instrument,
  [task-reviewer-prompt.md](../subagent-driven-development/task-reviewer-prompt.md)
- Before merge to main — and superpowersplus:final-branch-audit runs BEFORE this
  review, not after: a reviewer judges the diff it is handed, and a task
  nobody implemented produces no diff to judge.

**Ad-hoc, and only when your human partner asks.** Review has gates — spec,
plan, task, audit, branch — and
[using-superpowers](../using-superpowers/SKILL.md), section "Review Lives in
the Gates", holds everything between them. Stuck, mid-refactor, just past a
complex bug, a feature that feels big enough: that is where the urge to
dispatch one anyway arrives, and the urge is what the rule answers. The branch
gate reads that same diff later, so a review you start on your own initiative
is the work paid for twice. Asked for one: a single dispatch carrying every
requested lens, never one per lens.

## How to Request

**1. Get git SHAs:**
```bash
# Never HEAD~1: a task with more than one commit loses all but the last,
# silently. Use the BASE recorded before the work started, or the fork point.
BASE_SHA=$(git merge-base <base-branch> HEAD)
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer subagent:**

Dispatch a `general-purpose` subagent, filling the template at [code-reviewer.md](code-reviewer.md)

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit

**3. Act on feedback:**

**First, append one row to the project's `docs/superpowers/review-yield.md`**,
face `branch` — columns and the header to create it with are in
[review-yield.md](references/review-yield.md).

- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Last plan task committed; superpowersplus:final-branch-audit has returned]

You: Let me request the branch code review before presenting merge options.

# The fork point, never HEAD~1: this path commits as it goes, so HEAD~1 hands
# the reviewer the last task's diff and calls it the branch.
BASE_SHA=$(git merge-base main HEAD)
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Index verification and repair, whole branch
  PLAN_OR_REQUIREMENTS: docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Test Run: `npm test` (from package.json scripts.test) — exit 0 —
            18 passed / 0 failed / 0 skipped
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Recommendations: Progress reporting for long operations
  Assessment: Ready to proceed

You: [Fix progress indicators, re-run what the fix touched]
[Then superpowersplus:finishing-a-development-branch]
```

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'll just review the diff myself instead of dispatching a reviewer" | You're the coordinator — reviewing the diff inline burns the context window you need to keep driving the work. Dispatch a reviewer subagent: the diff and the evaluation live in its context, and only the findings come back to you. |
| "The reviewer needs my whole session history to understand the change" | Hand it precisely crafted context, never your session's history. That keeps the reviewer on the work product, not your thought process. |

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: [code-reviewer.md](code-reviewer.md)
