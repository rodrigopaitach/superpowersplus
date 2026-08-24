# RESULT — criteria read in pairs, two runs, two instruments

| | |
|---|---|
| **Date** | 2026-08-24 |
| **Model** | Claude Sonnet 5, dispatched as `model: sonnet` — one `general-purpose` subagent per run |
| **Fixture** | [`FIXTURE-contradicting-criteria.md`](FIXTURE-contradicting-criteria.md) (the plan) and [`FIXTURE-contradicting-criteria-spec.md`](FIXTURE-contradicting-criteria-spec.md) (the spec it cites) |
| **Rule under test** | [`skills/writing-plans/plan-document-reviewer-prompt.md`](../../skills/writing-plans/plan-document-reviewer-prompt.md), the Plan Contract row beginning "No two spec criteria this plan implements contradict each other" |
| **Verdict** | **PASS on the second instrument, 3 of 3 criteria.** The first run did not exercise the rule, and why it did not is the second finding below |

## What was measured

The rule tells the plan reviewer to read the spec's acceptance criteria **in
pairs**, each against the neighbours that touch the same field, and to charge a
pair that cannot both hold — reporting both ids and refusing to pick a reading.

The "before" state was collected at no cost and is not a run of this fixture.
During the review of the spec this rule came from, a Coverage Map row pointed at
the wrong neighbouring item and **two rounds of adversarial spec review passed
it**, with the generic `Internal contradictions, conflicting requirements`
check present the whole time. That is the half this record compares against.

The planted defect: `AC2` — "A digest is sent only when there is at least one
unread item" — against `AC5` — "Every subscribed user receives exactly one
digest per day, including days with no activity." They touch one field, whether
a digest goes out on a quiet day, and cannot both hold. Nothing in either
fixture says so.

## Approval requires all three

1. Reports that `AC2` and `AC5` cannot both hold, naming both ids.
2. Does not pick a reading — routes the contradiction back rather than
   resolving it.
3. Reaches the finding by reading criteria against each other, not by noticing
   a broken citation or a missing section.

## Run 1 — the rule was never exercised

The first fixture was a 37-line plan citing
`docs/superpowers/specs/2026-08-24-digest-design.md`, a path that did not
exist. The reviewer opened with the Plan Contract row above it — "The header
cites a source spec path that exists and is committed" — and stopped there.
Its own words:

> Given the spec is missing, several Plan Contract rows (Spec Alignment
> coverage, **criteria-pair contradiction check**, dropped-criterion check) are
> **unverifiable rather than checked-and-passed** — they are reported as
> blocking via the missing-spec finding above rather than silently skipped.

Seven blocking findings, all correct, none of them the contradiction. **This is
not a failure of the rule and must not be recorded as one.** The instrument
tripped a neighbouring row, and a rule that never ran cannot be said to have
missed anything.

**It is, however, a finding about the rule's reach, and it cost nothing to
collect: the rule says "read the *spec's* criteria in pairs", so when the spec
is unreachable the reviewer declares the check unverifiable rather than falling
back to the criteria the plan itself quotes on each task's `**Spec criterion:**`
line.** Both ids and both texts were sitting in the plan under review. A spec
that cannot be opened is common — an uncommitted path, a wrong filename, a
worktree without it — and in every such case this rule silently does not run.
Whether it should fall back is a separate decision, not made here.

## Run 2 — the instrument repaired

The fixture was rebuilt as a complete plan, in a throwaway git repository at
`/tmp/skill-behavior-run` with the spec committed, so that the contradiction is
the only defect a reviewer can find. The plan cites the committed spec, covers
every `AC` and `IR`, labels its own criteria `T<task>.<n>`, carries a
five-column Test Coverage Matrix whose every row names a test its steps
actually write, and — deliberately — carries **no** test asserting a value its
own implementation would not produce. Planting that second defect would have
made the verdict ambiguous: two defects, one report, and no way to say which
rule fired.

The subagent was given the reviewer prompt as it stands after the rule was
added, with `[PLAN_FILE_PATH]` and `[ROUND]` filled in, plus one operational
line naming `/tmp/skill-behavior-run` as the repository root — the previous run
had resolved relative paths against the wrong repository, and that ambiguity is
not what is under test. No other framing. The fixture headers were stripped by
`sed '1,/^---$/d'` before the run, so nothing told it this was a measurement.

**Result: the contradiction was the only blocking finding in the report.**

| Criterion | Verdict | Evidence from the report |
|---|---|---|
| 1. Names both ids | **PASS** | "`AC2` states … (`…digest-design.md:28`). `AC5` states … (`…digest-design.md:31-32`). On a day with zero unread items these cannot both hold: AC2 forbids sending anything, AC5 requires a digest anyway." |
| 2. Does not pick a reading | **PASS** | "Per the Plan Contract, this is the spec's to resolve, not the plan's: report both ids to the spec author rather than picking a reading." And under its own scope note: "it needs to go back to whoever owns `…digest-design.md` for a decision." |
| 3. Reached by reading criteria against each other | **PASS** | It cites both criteria by line and reasons about the field they share, then traces each to the task implementing it. No citation was broken and no section was missing — the plan passed every other Plan Contract row, which the reviewer verified one by one and reported |

## What the reviewer found that the fixture did not intend

It went past naming the pair and said **why the plan hides the conflict**:

> The plan does not resolve this — it implements the two criteria as two
> disconnected pure functions with no task that wires them together … Because
> no task ever calls both together, the plan never has to answer "does a quiet
> day actually send an email or not" — the conflict is hidden rather than
> settled … whichever wiring an implementer eventually writes silently decides
> which AC is the real one, and nothing in the plan or spec says which.

That mechanism — a contradiction staying invisible because no task makes the
two criteria meet — was not designed into the fixture. It is the shape the
original measurement had too, and the rule found it without being told.

## What this does not measure

- **One run per instrument, one model.** Whether a cheaper tier finds the same
  pair is unmeasured. So is whether the rule survives a plan carrying several
  defects at once, which is the ordinary case.
- **The "before" is not a run of this fixture.** It is the recorded failure of
  two adversarial spec-review rounds on a different document, with the generic
  consistency check present. The two states are comparable in what they say
  about the generic rule, not in their inputs.
- **Run 2's plan was built to be clean.** That isolates the mechanism, which is
  the point, and it means the measurement says nothing about whether the pair
  would still surface among a dozen competing findings — which is exactly what
  run 1 suggests it might not.
