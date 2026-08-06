# The four review scopes

Each face runs something different. They are **not one rule written four ways** —
harmonizing them into a common protocol changes the reach of three gates at
once. [`CLAUDE.md`](../CLAUDE.md) carries the prohibition; this file is what it
prohibits flattening. Read it before editing any reviewer prompt.

## What each face runs

| Face | What it actually runs |
|---|---|
| [task-reviewer-prompt.md](../skills/subagent-driven-development/task-reviewer-prompt.md), section "Tests — Run Them Yourself" | The **task's** test command, `[TEST_COMMAND]`, reported verbatim |
| [code-reviewer.md](../skills/requesting-code-review/code-reviewer.md), section "What to Check" | The **project's** suite, with a fallback to the command the dispatch named |
| [re-review-prompt.md](../skills/subagent-driven-development/re-review-prompt.md), section "Tests — Run Them Yourself" | **Re-runs** what already ran, reporting command, exit code, and counts |
| [final-branch-audit/SKILL.md](../skills/final-branch-audit/SKILL.md), section "The Auditor Re-Runs the Searches" | **No tests at all** — re-runs the *searches* against the spec |

## The evidence line

The block `**Command:** [verbatim] — **exit:** [code] — **counts:** …` appears
three times, identical but for a baseline suffix that is content, not wording.

| Carrier | Baseline suffix |
|---|---|
| [task-reviewer-prompt.md](../skills/subagent-driven-development/task-reviewer-prompt.md), section "Test Evidence" | `base:` |
| [re-review-prompt.md](../skills/subagent-driven-development/re-review-prompt.md), section "Test Run" | `previous:` |
| [code-reviewer.md](../skills/requesting-code-review/code-reviewer.md), section "Test Run" | none — it has no prior count |

## Why the form is copied rather than extracted

**A form inside a subagent's `## Output Format` is unified in place, never
extracted.** This inverts the ordinary rule that a third occurrence gets
extracted, and the inversion is measured rather than preferred:
[escalation-format.md](../skills/using-superpowers/references/escalation-format.md)
records three runs of the same scenario moving from 1 of 3 to 3 of 3 as the
shape moved out of that file and into the moment of use. A subagent reads its
own output block; it does not follow a pointer out of it. The runs themselves
are in [tests/skill-behavior/README.md](../tests/skill-behavior/README.md).

**Without a gate, "unified in place" is just "copied."** Two carry that weight:

- [check-evidence-line.sh](../scripts/check-evidence-line.sh) — five carriers,
  comparing the evidence line's fields and tolerating formatting.
- [check-escalation-shape.sh](../scripts/check-escalation-shape.sh) — six
  carriers, five skills, `subagent-driven-development` holding the shape twice.
  A list of skill names undercounts the files that have to agree.

Both run whole-tree from the pre-commit hook rather than over the staged range:
the carriers are edited one at a time, so a range-scoped check would read the
one being changed and never the others it must match. Both name what drifted
when they fail.
