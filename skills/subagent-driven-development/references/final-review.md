# Final Review — the two end-of-branch gates and the fix wave

**Open this when the last task's completion line is in the ledger**, before
dispatching anything else. Nothing here applies during the task loop.

Two gates run at the end, in this order, and both feed ONE findings list.

### 1. Conformance audit (first)

Dispatch superpowersplus:final-branch-audit on the most capable available model,
with the plan file path, the branch range (MERGE_BASE = `git merge-base main
HEAD`), and this plan's ledger path. It walks every task and verdicts every
acceptance criterion against located evidence.

It runs BEFORE the code review: a reviewer cannot flag a task nobody
implemented — absent code produces no diff. An audit FAIL does not skip the
code review; its gaps and FALSE COMPLETION findings join the review's
findings in the same fix wave.

### 2. Whole-branch code review

The final whole-branch review gets a package too: run
`scripts/review-package PLAN_FILE MERGE_BASE HEAD` (MERGE_BASE = the commit the
branch started from, e.g. `git merge-base main HEAD`) and include the
printed path in the final review dispatch, so the final reviewer reads
one file instead of re-deriving the branch diff with git commands. Dispatch
on the most capable available model (see Model Selection in SKILL.md), using
superpowersplus:requesting-code-review's
[code-reviewer.md](../../requesting-code-review/code-reviewer.md). Point it at
the ledger's deferred-minor and parked lines so it can triage which must be
fixed before merge.

### 3. The fix wave — up to 3 iterations

When the audit or the review returns findings, dispatch ONE fix subagent per
iteration with the complete list — audit gaps and review findings together,
never one fixer per finding. Per-finding fixers each rebuild context and
re-run suites; a real session's final-review fix wave cost more than all its
tasks combined.

Each iteration ends with exactly one scoped re-review of that iteration's fix
diff (`scripts/review-package PLAN_FILE FIX_BASE HEAD` over the fix range,
[re-review-prompt.md](../re-review-prompt.md)). When the iteration fixed audit
gaps, re-run the conformance audit too, scoped to those tasks — a gap is
closed by evidence, not by a fixer's word.

Three iterations maximum. Append each one to the ledger:
`Final: fix wave <I>/3 (<X> addressed, <Y> open — <one-liners>; commits <a7>..<b7>)`

Only after the third iteration, adjudicate what is still open as in the task
loop's breaker: park with rulings, or stop on load-bearing ones. Parking
before the cap is pre-judging with a different name. **A FALSE COMPLETION
finding is never parked** — a task the plan claims is done and the branch does
not contain is load-bearing by definition. Residual load-bearing findings
surface to your human partner when finishing-a-development-branch presents
the options — that presentation is where a person decides.

**Escalation shape** (detail and a worked example: `../../using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it. A gate verdict name (`LOST IN TRANSLATION`, `INVENTED SCOPE`, …) appears only in parentheses, never carrying the explanation.
