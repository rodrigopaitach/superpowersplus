# Final Review — the two end-of-branch gates and the fix wave

**Open this when the last task's completion line is in the ledger**, before
dispatching anything else. Nothing here applies during the task loop.

Two gates run at the end, in this order, and both feed ONE findings list.

### 1. Conformance audit (first)

Dispatch superpowersplus:final-branch-audit on the most capable available model,
with the plan file path, the branch range (MERGE_BASE = `git merge-base main
HEAD`), and this plan's ledger path. It walks every task and verdicts every
acceptance criterion against located evidence.

Fill its `**Tasks outside this execution's scope:**` slot yourself — `none`
when every task ran, which is the case here, since this file opens only once
the last task's completion line is in the ledger. It is yours to declare
because you dispatched the audit: the plan cannot declare it (a plan editing
itself to stop asking) and neither can the ledger's silence, which reads the
same for a task whose turn had not come and a task the loop skipped. What you
declare is searched anyway — code found for a declared-out-of-scope task is a
finding against the declaration.

It runs BEFORE the code review: a reviewer cannot flag a task nobody
implemented — absent code produces no diff. An audit FAIL does not skip the
code review; its gaps and FALSE COMPLETION findings join the review's
findings in the same fix wave.

### 2. Whole-branch code review

Dispatch superpowersplus:requesting-code-review — its "Before merge to main"
is mandatory and reaches this path here. It carries its own reviewer template
and the rules around it, including the one against reviewing your own diff.
Naming that template file here would hand you the form and leave the rules
behind, which is why gate 1 above dispatches a skill and not a file either.

Three inputs belong to this path, and that skill cannot know them:

- **The review package.** Run `scripts/review-package PLAN_FILE MERGE_BASE HEAD`
  (MERGE_BASE = the commit the branch started from, e.g. `git merge-base main
  HEAD`) and include the printed path in the dispatch, so the reviewer reads
  one file instead of re-deriving the branch diff with git commands.
- **The model** — the most capable available one (see Model Selection in
  SKILL.md).
- **The ledger's deferred-minor and parked lines**, so it can triage what must
  be fixed before merge.

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

**Parking an audit gap leaves the audit at FAIL, and that is the finished
state — not a step short of one.** The row stays NOT DELIVERED, so the verdict
cannot turn; what carries the branch forward is the ruling on the row, which
`../../finishing-a-development-branch/SKILL.md` reads and checks before
presenting the options. Do not re-run the audit hoping the verdict moves, and
never edit the plan to stop it asking — that is the resolution
`../../final-branch-audit/SKILL.md` forbids outright.

**Escalation shape** (detail and a worked example: `../../using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it. A gate verdict name (`LOST IN TRANSLATION`, `INVENTED SCOPE`, …) appears only in parentheses, never carrying the explanation.
