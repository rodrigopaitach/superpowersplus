# Scoped Re-Review Prompt Template

Use this template when dispatching a re-review after a fix round. It is not
a fresh review — the full review already happened.

**Purpose:** verify each finding from the previous review was addressed, the
tests still pass, and the fix diff broke nothing new.

```
Subagent (general-purpose):
  description: "Re-review Task N fix round R"
  model: [MODEL — REQUIRED: choose per SKILL.md Model Selection; an omitted
         model silently inherits the session's most expensive one]
  prompt: |
    You are re-reviewing one task's fix round. A previous review produced
    findings; an implementer has attempted to fix them. Your job is to
    verdict each finding and inspect the fix diff — nothing else.

    ## The Task

    Read the task brief: [BRIEF_FILE]

    ## The Findings Under Verification

    [FINDINGS]

    ## The Fix

    Read the implementer's report (fix reports are appended at the end):
    [REPORT_FILE]

    **Fix base:** [FIX_BASE_SHA] (the head the previous review saw)
    **Head:** [HEAD_SHA]
    **Diff file:** [DIFF_FILE]

    Read the diff file once — it contains the fix commits, a stat summary,
    and the fix diff with surrounding context. Do not re-run git commands.
    If the diff file is missing, fetch the diff yourself:
    `git diff --stat [FIX_BASE_SHA]..[HEAD_SHA]` and
    `git diff [FIX_BASE_SHA]..[HEAD_SHA]`.

    Your review is read-only on this checkout. Do not mutate the working
    tree, the index, HEAD, or branch state in any way.

    ## You Do Not Dispatch Subagents

    Do all of this yourself. Never dispatch a subagent — the controller owns every review seat, and one you create duplicates a seat this process already provides, at full cost and for a verdict that counts for nothing. If the work feels too large for one pass, do it in passes yourself and say so in your report.

    ## Scope

    Your scope is the findings list and the fix diff. Verdict every finding,
    including any the implementer marked DISPUTED — you rule on those, the
    author does not rule on its own dispute.
    Inspect the fix diff for new problems the fix itself introduced. Do NOT
    re-review code the fix did not touch: if you notice an issue entirely
    outside the fix diff, report it under Out-of-Scope Observations — it
    does not block this task and does not extend the loop. A broad
    whole-branch review happens after all tasks are complete.

    ## Tests — Run Them Yourself

    The implementer appended its fix test run to the report file. That is a
    claim about a run you did not watch, written by the author of the tests.
    Re-run them: `[TEST_COMMAND]`. Report the command verbatim, its exit
    code, and the counts (passed / failed / skipped).

    Compare against `[BASE_TEST_COUNT]`, the count the previous review
    reported. A count that fell — or any test this fix diff deleted, renamed
    away, or newly marked skipped, `xfail`, or `.only` — is new breakage:
    report it under New Breakage in the Fix Diff, whatever the pass line
    says. A finding "fixed" by deleting the test that caught it is NOT
    ADDRESSED.

    Stay read-only: run the tests, never checkout, stash, or reset. If you
    cannot run commands in this environment, say so in your first line and
    name the command you would have run — never infer a pass from the
    report.

    ## Output Format

    Your final message is the report itself: begin directly with the first
    finding's verdict. Every line is a verdict, a finding with file:line,
    or a check you ran — no preamble, no process narration.

    ### Test Run

    **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/failed/
    skipped] (previous: [BASE_TEST_COUNT])

    ### Finding Verdicts

    For each finding in The Findings Under Verification, in order:
    - **[finding one-liner]** — ADDRESSED | NOT ADDRESSED, with file:line
      evidence. "Attempted" is not addressed: the specific defect must no
      longer exist.
    - A finding the implementer marked **DISPUTED** gets CONFIRMED or
      WITHDRAWN instead. Read the code at the implementer's citation
      yourself and rule on what that code does — its argument is a pointer,
      not evidence. **CONFIRMED:** the finding stands; say why the cited
      code does not contradict it, and it stays open for the next round.
      **WITHDRAWN:** the citation does contradict the finding; it leaves the
      list. A DISPUTED carrying no file:line citation is NOT ADDRESSED, not
      a dispute. These three are the only dispute states.

    ### New Breakage in the Fix Diff

    Anything the fix itself broke or introduced, with severity
    (Critical/Important/Minor) and file:line. "None" if clean.

    ### Out-of-Scope Observations

    Issues you noticed entirely outside the fix diff. Non-blocking; the
    controller ledgers these for the final review. "None" if none.

    **This bucket is not capped, and that is deliberate.** These go to the
    ledger as deferred minors and are the only channel by which a re-review
    scoped to one fix diff hands a broad finding to the final review. A cap
    would delete them in transit. Report them all.

    ### Verdict

    **Fix round:** [All findings addressed, no new Critical/Important
    breakage | Findings remain open] — list the open ones. A CONFIRMED
    dispute is open; a WITHDRAWN one is not.
```

**Placeholders:**
- `[MODEL]` — REQUIRED: reviewer model per SKILL.md Model Selection; scoped
  re-reviews of small fix diffs take a cheap-to-mid tier
- `[BRIEF_FILE]` — the task brief file (same file the implementer worked from)
- `[FINDINGS]` — the Critical/Important findings and spec gaps from the
  previous review, copied verbatim, one per bullet
- `[REPORT_FILE]` — the implementer's report file (fix reports appended)
- `[TEST_COMMAND]` — REQUIRED: the same command the task review ran, so the
  two runs compare; the re-reviewer runs it itself
- `[BASE_TEST_COUNT]` — the counts the previous review reported. Pass
  `unknown` when there are none, and expect the delta to come from the diff.
  **It is labelled `previous:` in the evidence line**, which is the one part of
  that line each face words differently: this one compares against the previous
  review, the task review against the commit before the task (`base:`), and the
  whole-branch review has no prior count and carries no label at all
- `[FIX_BASE_SHA]` — the head the previous review saw
- `[HEAD_SHA]` — current commit
- `[DIFF_FILE]` — the path `scripts/review-package PLAN_FILE FIX_BASE HEAD` printed

**Re-reviewer returns:** its own test run (command, exit code, counts),
per-finding verdicts (ADDRESSED / NOT ADDRESSED, or CONFIRMED / WITHDRAWN
for a disputed finding), new breakage in the fix diff, out-of-scope
observations, and a round verdict.
