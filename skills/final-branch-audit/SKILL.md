---
name: final-branch-audit
description: Use when all plan tasks are done and before finishing a development branch - traces every spec criterion to the plan's tasks, then audits every task one by one and proves each acceptance criterion with located evidence
---

# Final Branch Audit

Trace EVERY criterion of the source spec to the plan tasks that cover it,
then walk EVERY task and prove, one at a time, that its acceptance criteria
were delivered — with `file:line` citations the auditor located itself.

**This is not a code review.** The code reviewer judges the quality of the
diff it is handed. The audit answers a different question: *was everything
the plan asked for actually built?* A branch passes code review with three
tasks silently missing, because a missing task produces no diff to criticize.

**Read-only.** The auditor fixes nothing, commits nothing, and never mutates
the working tree, the index, HEAD, or branch state. It reports; the
controller routes the gaps into the fix wave.

**Evidence-or-zero.** A criterion with no located citation is NOT DELIVERED.
There is no "probably done", no "looks implemented", no partial credit.

## When to Use

- After the last task of a plan, BEFORE the final code review
  (superpowersplus:subagent-driven-development dispatches it there)
- Before presenting merge options
  (superpowersplus:finishing-a-development-branch requires it)
- Any time you inherited a branch and need to know what the plan promised
  versus what the branch contains

## The Spec Is the Root, Not the Plan

The plan is an artifact under audit, not the requirement. A spec requirement
the plan dropped in translation leaves no trace in the plan — checking the
plan against itself can never find it.

**Where the spec comes from:** the plan cites its source spec path
(superpowersplus:writing-plans requires it). Take the path from the plan, then
confirm it yourself:

| Check | If it fails |
|-------|-------------|
| The cited file exists at that path | BLOCKING |
| It is committed — `git log -1 -- <spec path>` names a commit | BLOCKING: an uncommitted spec is not an auditable artifact |

A plan citing no spec at all is BLOCKING on its own. Do not infer the spec,
do not guess which document in `docs/` was meant, and do not fall back to
auditing the plan alone. Report it and say the traceability pass could not
run.

## The Traceability Table

Produce this FIRST, before the task table. One row per item in the spec's
`## Acceptance Criteria` list **and one per item in its `## Implicit
Requirements` list** — superpowersplus:brainstorming requires both sections, so
a spec lacking either is a blocking issue in its own right: report it, then
trace against the spec's numbered requirement headings instead. The lists
are what fix the row count; without them, two auditors enumerate two
different sets. Then one row per plan task that no criterion motivated:

| Spec criterion | Plan task(s) covering it | Verdict |
|----------------|--------------------------|---------|
| AC1 Tokens expire after 15 minutes | Task 3 | TRACED |
| AC2 Rate-limited calls retry with backoff | Task 4 | TRACED |
| AC4 Refresh rotates the token | — | LOST IN TRANSLATION |
| IR2 Concurrent refreshes rotate the token once | Task 5 | TRACED |
| IR3 Refresh failures are logged with the account id | — | LOST IN TRANSLATION |
| — | Task 7 (admin export) | INVENTED SCOPE |

`AC` and `IR` are one id space here. An implicit requirement no task covers
is LOST IN TRANSLATION exactly like an acceptance criterion — the spec
raised it, the plan dropped it, and the branch will ship without it.

| Situation | Verdict |
|-----------|---------|
| Spec criterion covered by one or more plan tasks | TRACED |
| Spec criterion no task covers | **LOST IN TRANSLATION — BLOCKING** |
| Plan task no spec criterion motivated | **INVENTED SCOPE — BLOCKING** |

Cite the spec criterion by its id, the task by number. Both failures block
PASS exactly like a NOT DELIVERED row: the first ships less than the spec
asked for, the second ships work nobody asked for. Neither is visible to a
task review, which only ever sees one task's diff — and neither is visible
to the task table below, which asks only whether the plan's own tasks
landed.

A task delivering a criterion the spec states differently is not INVENTED
SCOPE — trace it to that criterion and note the divergence in the row.

## The Audit Table

The second table. Its rows answer "did the plan's tasks land"; the
traceability table above answers "did the plan ask for the right things".

The auditor's report MUST contain this table, with one row per acceptance
criterion of every task in the plan — including tasks the plan or the ledger
marks complete:

| Task | Criterion | Implementation | Test | Verdict |
|------|-----------|----------------|------|---------|
| 3 | T3.1 Rejects expired tokens | `src/auth/verify.ts:88` | `tests/auth/verify.test.ts:41` | DELIVERED |
| 4 | T4.2 Retries on 429 with backoff | — | — | NOT DELIVERED |
| 5 | T5.1 Concurrent refreshes rotate the token once | `src/auth/refresh.ts:52` | `tests/integration/test_refresh.py:73` | DELIVERED |
| 7 | T7.1 Admin export produces a CSV | `src/admin/export.ts:19` | `tests/admin/export.test.ts:8` | DELIVERED |

Every task in one table appears in the other. Task 4 is traced above and
NOT DELIVERED here; Task 7 is DELIVERED here and INVENTED SCOPE above —
working code the spec never asked for is still a finding.

- **Two id spaces, never mixed.** This table is keyed by the plan's
  task-level labels (`T3.1`, superpowersplus:writing-plans requires that form);
  the traceability table above is keyed by the spec's ids (`AC1`, `IR2`). A
  row here carrying an `AC` or `IR` id is citing the wrong list.
- **Implementation** and **Test** are `path/file.ext:line` — a path alone is
  not a citation, and neither is a commit SHA.
- Cite the line that DOES the thing, not the file that mentions it.
- A criterion with no test citation is NOT DELIVERED even when the
  implementation exists. Untested is undelivered.
- No row may be omitted. A task the auditor could not locate at all gets a
  row with `—` in both citation columns.

## Verdict Rules

| Situation | Verdict |
|-----------|---------|
| Implementation and test both cited, both check out | DELIVERED |
| No citation, or a citation that does not check out | NOT DELIVERED |
| Implementation cited, no covering test | NOT DELIVERED |
| Cited line exists but does not do what the criterion states | NOT DELIVERED |
| Criterion delivered somewhere other than the plan said | DELIVERED — note the real location in the row |
| Task marked complete in the plan or the ledger, no evidence found | NOT DELIVERED + **CRITICAL — FALSE COMPLETION** |

**FALSE COMPLETION is the maximum-severity finding of this audit.** A ticked
checkbox or a `Task N: complete` ledger line that no evidence supports is
worse than an open task: it is a gap that already reported itself as closed.
Report each one separately from the ordinary gaps.

## The Auditor Re-Runs the Searches

Take nothing on anyone's word — not the plan's, not the ledger's, not the
implementer's report, not a prior reviewer's approval. Those are claims
under audit, not evidence.

For each criterion:

1. Search the repo for the behavior yourself (grep the identifiers, the
   strings, the error messages the criterion names; glob the paths).
2. Open the hit and read it. Confirm the code does what the criterion says.
3. Search for the covering test the same way. Open it and confirm it asserts
   the criterion's behavior — a test that never fails if the behavior breaks
   is not a covering test.
4. Only then write the row.

If a document told you where to look, verify it there AND search
independently — a stale pointer that happens to name a real file is the
easiest way to certify a gap as delivered.

## Dispatch

Dispatch on the most capable available model — this is the gate that decides
whether the branch delivered the plan.

```
Subagent (general-purpose):
  description: "Audit branch against plan"
  prompt: |
    You are a conformance auditor. Prove, task by task, that this branch
    delivered what the plan required. You are read-only: fix nothing, commit
    nothing, never mutate the working tree, the index, HEAD, or branch state.

    **Plan (an artifact under audit):** [PLAN_FILE_PATH]
    **Branch range:** [MERGE_BASE]..[HEAD]
    **Ledger (claims under audit, not evidence):** [LEDGER_PATH or "none"]

    The source spec is not passed to you: its path comes from the plan, and
    confirming that path is part of the audit.

    ## Step 1: Resolve the Spec

    Read the plan and find the source spec path it cites. Confirm the file
    exists and is committed (`git log -1 -- <spec path>` names a commit).

    A plan citing no spec, a path that does not exist, or a spec that is not
    committed is a BLOCKING issue: report it, say the traceability pass could
    not run, and continue with the task table. Never infer which document was
    meant, and never substitute the plan for the spec.

    Read the spec itself. It is the requirement; the plan is an artifact
    under audit.

    ## Step 2: Traceability

    One row per item in the spec's `## Acceptance Criteria` list AND one per
    item in its `## Implicit Requirements` list — `AC` and `IR` are one id
    space, charged identically — plus one row per plan task no criterion
    motivated. A spec missing either section is a blocking issue: report it,
    then trace against its numbered requirement headings.

    - Spec criterion covered by one or more tasks → TRACED
    - Spec criterion no task covers → LOST IN TRANSLATION (blocking)
    - Plan task no spec criterion motivated → INVENTED SCOPE (blocking)

    A task delivering a criterion the spec words differently is TRACED —
    note the divergence in the row rather than calling it invented.

    ## Step 3: Every Task in the Plan

    Every acceptance criterion of every task. One row each in the task table
    below — including tasks the plan or ledger calls complete.

    Cite each one by the plan's task-level label (`T3.1`), not by an `AC` or
    `IR` id: those belong to the spec and key the traceability table in Step
    2. Same string in both tables means the two stopped lining up.

    Evidence-or-zero: a criterion with no `path/file.ext:line` citation is
    NOT DELIVERED. A citation that does not check out is NOT DELIVERED.
    Implementation without a covering test is NOT DELIVERED.

    Re-run every search yourself. The plan, the ledger, the implementer
    reports, and any prior review approval are claims under audit — never
    evidence. Open each cited line and confirm it does what the criterion
    states. Confirm each cited test actually asserts that behavior.

    A task marked complete with no evidence is a CRITICAL — FALSE COMPLETION
    finding: report it separately, it is the maximum severity here.

    If the plan states a task's criteria vaguely enough that no citation could
    settle them, say so in the row instead of inventing a verdict.

    ## Output Format

    ## Branch Conformance Audit

    **Spec:** [path cited by the plan] — exists: yes/no, committed: yes/no
    **Verdict:** PASS | FAIL
    (PASS only when every traceability row is TRACED AND every task row is
    DELIVERED)

    ### Traceability

    | Spec criterion | Plan task(s) | Verdict |
    |----------------|--------------|---------|
    | ... | Task N / — | TRACED / LOST IN TRANSLATION / INVENTED SCOPE |

    ### Task Delivery

    | Task | Criterion | Implementation | Test | Verdict |
    |------|-----------|----------------|------|---------|
    | ... | ... | `path:line` | `path:line` | DELIVERED / NOT DELIVERED |

    ### Traceability Failures (blocking)
    - LOST IN TRANSLATION — <spec criterion>: no task covers it. Searched:
      <what you read in the plan to conclude it>.
    - INVENTED SCOPE — Task N: no spec criterion motivates it. Searched:
      <what you read in the spec to conclude it>.

    ### False Completions (critical)
    - Task N: <criterion> — claimed complete by <plan checkbox / ledger line>,
      no evidence found. Searches run: <what you ran>.

    ### Gaps
    - Task N: <criterion> — what is missing, and what you searched to
      conclude it is missing.

    ### Unauditable Criteria
    - Task N: <criterion> — why no citation could settle it.

    Return this report only. Do not propose patches.
```

## Handling the Result

The audit's gaps are input to a fix wave, not a report to file away. FAIL
means the branch is not done, regardless of how clean the code review is.
Never resolve a gap by editing the plan to stop asking for it.

Traceability failures do not route like delivery gaps:

| Failure | Route |
|---------|-------|
| LOST IN TRANSLATION | The plan is incomplete. Adding the missing work is a plan change — take it to your human partner with the spec text beside the plan's silence. |
| INVENTED SCOPE | Work exists that nobody specified. Your human partner decides: amend the spec to cover it, or remove it. Not the fixer's call. |
| No spec cited, or the cited spec is missing/uncommitted | Stop and ask. There is nothing to trace against, and inferring a spec fabricates the baseline. |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Every task already passed its task review" | Task reviews see one diff each. Nothing in that chain proves the set is complete — a task nobody dispatched has no diff and no reviewer. |
| "The ledger says all tasks are complete" | The ledger is the claim under audit. FALSE COMPLETION exists because that line gets written by the same loop that skipped the work. |
| "The code review will catch anything missing" | A reviewer judges the diff in front of it. Absent code is invisible to it. |
| "I can see the feature works, that's evidence enough" | Evidence is `file:line`. "I can see it" is the exact judgment the audit exists to replace. |
| "The implementation is there, the test is obvious" | Untested is undelivered. Write the row as NOT DELIVERED and let the fix wave add the test. |
| "This criterion is too vague to audit — I'll assume it passed" | Put it in Unauditable Criteria. An assumed pass is a fabricated row. |
| "Auditing every task is overkill for a small plan" | The tasks that go missing are never the ones you would have thought to spot-check. |
| "The plan was written from the spec, so tracing them is redundant" | The plan is the artifact under audit. A requirement lost while writing it leaves no trace in it — that is exactly the gap the traceability table exists to catch. |
| "The plan doesn't cite a spec, I'll find the obvious one in docs/" | Inferring the spec means auditing against a document nobody approved for this plan. Report the missing citation as blocking. |
| "Task 7 isn't in the spec but it's clearly needed" | Then the spec needed amending and nobody did it. INVENTED SCOPE is a finding, not a judgment call about usefulness. |
| "IR3 is non-functional — it's not really a deliverable criterion" | The spec gave it an id, which makes it a criterion. Implicit requirements are the ones that quietly disappear between spec and plan; that is exactly why they carry ids and get charged here. |
