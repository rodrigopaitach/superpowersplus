# The four review scopes

Each face runs something different. They are **not one rule written four ways** —
harmonizing them into a common protocol changes the reach of three gates at
once. [`CLAUDE.md`](../CLAUDE.md) carries the prohibition; this file is what it
prohibits flattening. Read it before editing any reviewer prompt.

## What each face runs

| Face | What it actually runs |
|---|---|
| [task-reviewer-prompt.md](../skills/subagent-driven-development/task-reviewer-prompt.md), section "Tests — Run Them Yourself" | The verification instrument each criterion names — the task's test command, `[TEST_COMMAND]`, reported verbatim where a `behavioral` criterion requires one; the read-only validator or command otherwise |
| [code-reviewer.md](../skills/requesting-code-review/code-reviewer.md), section "What to Check" | The **project's** suite, with a fallback to the command the dispatch named |
| [re-review-prompt.md](../skills/subagent-driven-development/re-review-prompt.md), section "Tests — Run Them Yourself" | **Re-runs** what already ran — the test command where the fix touched a `behavioral` criterion, the criterion's own read-only instrument otherwise — reporting command, exit code, and counts |
| [final-branch-audit/SKILL.md](../skills/final-branch-audit/SKILL.md), section "The Auditor Re-Runs the Searches" | **Read-only verification, per criterion** — re-runs the searches against the spec, and re-runs the instrument each criterion's evidence class names: the test for `behavioral`, the validating command or the located ranges for `structural`, the command over the declared scope for `negative`. It never mutates the checkout, and it does not take over the project-suite reviewer's job: it re-runs what a criterion claims, not the suite as a whole |

## The evidence line

The block `**Command:** [verbatim] — **exit:** [code] — **counts:** …` is
carried by every file `check-evidence-line.sh` declares, identical but for a
baseline suffix that is content, not wording. The review faces are these three;
the other carriers are the points where a completion claim is made, not where a
diff is judged, and they take no suffix.

| Carrier | Baseline suffix |
|---|---|
| [task-reviewer-prompt.md](../skills/subagent-driven-development/task-reviewer-prompt.md), section "Verification Evidence" | `base:` |
| [re-review-prompt.md](../skills/subagent-driven-development/re-review-prompt.md), section "Test Run" | `previous:` |
| [code-reviewer.md](../skills/requesting-code-review/code-reviewer.md), section "Test Run" | none — it has no prior count |

**The reader changes at the last carrier, and that is the one that was missing.**
Every other carrier is read by a subagent.
[`finishing-a-development-branch/SKILL.md`](../skills/finishing-a-development-branch/SKILL.md), section "Step 1: Verify Tests"
is read by a person, immediately before merge
options are on the table — so the shape was enforced everywhere an agent reports
to an agent and nowhere an agent reports to its human partner. Added in `1.14.0`.

## Why the form is copied rather than extracted

**A form inside a subagent's `## Output Format` is unified in place, never
extracted.** This inverts the ordinary rule that a third occurrence gets
extracted, and the inversion is measured rather than preferred:
[escalation-format.md](../skills/using-superpowers/references/escalation-format.md)
records three runs of the same scenario moving from 1 of 3 to 3 of 3 as the
shape moved out of that file and into the moment of use. A subagent reads its
own output block; it does not follow a pointer out of it. The runs themselves
are in [tests/skill-behavior/README.md](../tests/skill-behavior/README.md).

**Without a gate, "unified in place" is just "copied."** Each of these carries
that weight:

- [check-evidence-line.sh](../scripts/check-evidence-line.sh) — comparing the
  evidence line's fields across every declared carrier, tolerating formatting.
  The list is declared in the script, not discovered by globbing: a carrier that
  silently lost the form has to be distinguishable from a file that never had
  it. The count is printed at run time and written down nowhere, because it ages
  every time the list grows.
- [check-escalation-shape.sh](../scripts/check-escalation-shape.sh) — six
  carriers, five skills, `subagent-driven-development` holding the shape twice.
  A list of skill names undercounts the files that have to agree.
- [check-no-dispatch.sh](../scripts/check-no-dispatch.sh) — the clause saying a
  review seat does not open another one, carried in every dispatched prompt.
  It cannot live behind a link for a reason peculiar to it:
  [using-superpowers/SKILL.md](../skills/using-superpowers/SKILL.md) opens with
  a `<SUBAGENT-STOP>` block telling a dispatched subagent to ignore the skill,
  so the one rule governing review dispatch cannot be read by anyone able to
  violate it. The clause is therefore carried in the prompt body itself, never
  in the skill's own prose around it.

- [tests/review-yield/test-review-yield-rules.sh](../tests/review-yield/test-review-yield-rules.sh)
  — the five-item cap on the advisory bucket, carried by three of the five
  reviewer prompts. **The other two are uncapped on purpose**: the controller
  transcribes their bucket item by item into the progress ledger, so a cap
  there deletes findings in transit rather than saving anyone's attention. The
  suite charges both halves. **Two things about the gate diverge from the three
  above, and both are weaknesses rather than design.** It is not in
  [githooks/pre-commit](../githooks/pre-commit), so a local commit dropping the
  cap from one carrier is caught only on push. And it does not compare the
  carriers against each other the way the three above do — it asserts a per-face
  string in each file, because the cap is deliberately worded per face against
  that face's own bucket name and there is no single form to compare.

They run whole-tree from the pre-commit hook rather than over the staged range:
the carriers are edited one at a time, so a range-scoped check would read the
one being changed and never the others it must match. Each names what drifted
when it fails.

**That last paragraph does not describe the cap's gate**, which runs from CI
instead. The reason is not a decision anyone defends: the check was written as a
test suite because everything else in that change needed one, and nothing moved
it into the hook afterwards.
