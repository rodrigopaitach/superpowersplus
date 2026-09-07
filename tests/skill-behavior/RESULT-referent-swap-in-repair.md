# RESULT — a repair that swaps the referent, four arms of a 2×2

| | |
|---|---|
| **Date** | 2026-09-06 |
| **Model** | Claude Opus 5, one `general-purpose` subagent per arm, the same tier in all four. No arm was re-run and no arm was discarded |
| **Fixture** | [`FIXTURE-referent-swap-in-repair.md`](FIXTURE-referent-swap-in-repair.md) — four throwaway repositories built from this repository's own `471cdd1` |
| **Rule under test** | [plan-document-reviewer-prompt.md](../../skills/writing-plans/plan-document-reviewer-prompt.md), the nine lines closing step (a) of "Which Round This Is" — name the quantity a claim is *about* before measuring, confirm the instrument produces that quantity, report unverified rather than settling with a neighbour. They sit **outside** the Plan Contract, so a trivial observation does not acquire a mandatory form |
| **Rule path** | skills/writing-plans/plan-document-reviewer-prompt.md |
| **Runs** | N=4, and none are replicates: one draw in each cell of a 2×2 — fixture with the defect and fixture corrected, crossed with the template as it shipped before this change and the template carrying the candidate lines. **One draw per cell is a draw, not a rate** |
| **Verdict** | **The 2×2 came out complete and in the direction the candidate predicts.** On the defective fixture, the arm without the lines returned **FIXED** on the finding that carries the defect; the arm with them charged it, in **both** occurrences, from its own measurement. On the corrected fixture, **neither** arm accused the corrected sentence. Per criterion: **C1 FAIL without the lines, PASS with them; C2 PASS in both control arms; C3 PASS in the one arm that could settle it.** No arm produced a false positive and none failed to execute |

**This is measurement and provenance, not delivery evidence.** Four live-agent
draws on a throwaway fixture. Nothing here is offered in place of the branch
audit, which resolves a delivery's criteria against `HEAD`.

**Measured before the lines were committed, and against text byte-identical to
what shipped.** [`tests/skill-behavior/README.md`](README.md), section "When the
rule under test changes", names this exact case — a record measured on the day
its rule moves should say the hour or be re-measured on a quiet day. What
answers it here is stronger than an hour and is checkable: the frozen template
the two candidate arms ran on is byte-for-byte the fenced template block of the
shipped file, `diff` clean over all 187 lines, and the frozen template the two
control arms ran on is that same block with these nine lines removed. The runs
did not measure an approximation of the shipped wording; they measured it.

## What is measured

A round-2 reviewer verdicts the previous round's blocking findings. Here the
repair is real — the hardcoded total is gone — and the author added a sentence
explaining why it was wrong. That sentence quotes two true numbers, 42 and 44,
and attaches them to a subject that does not move.

The question is which quantity the reviewer reaches for. Both numbers are
printed on one line of the suite's output, `36 of 44`, and the cheap instrument
returns them.

**This is not a measurement of whether reviewers should measure.** All four
arms measured. What separates them is which quantity the measurement was of.

## Approval requires all three

1. **C1 — the swapped referent is charged where it exists.** On the defective
   fixture, the report says the supporting sentence names a quantity the
   instrument does not produce.
2. **C2 — the corrected sentence is not charged where it is right.** On the
   corrected fixture, no finding accuses it.
3. **C3 — the instruction survives the correction.** Charging the sentence does
   not take down the paragraph it justifies, which is correct.

| Criterion | arm 1 · F-def, no lines | arm 2 · F-def, lines | arm 3 · F-ok, lines | arm 4 · F-ok, no lines |
|---|---|---|---|---|
| **C1** — charges the swapped referent | **FAIL** — verdicted FIXED | **PASS** — both occurrences | n/a | n/a |
| **C2** — leaves the correct sentence alone | n/a | n/a | **PASS** | **PASS** |
| **C3** — the instruction survives | n/a | **PASS** | n/a | n/a |

**Each criterion is settled by one pair, not by four runs.** C1 cannot fail on
the corrected fixture and C2 cannot fail on the defective one. **C3 can only be
settled by an arm that charged the sentence**, so exactly one run reaches it —
stated here rather than left to read as three verdicts confirming each other.

## The 2×2

| | **template as shipped before this change** | **template + the nine lines** |
|---|---|---|
| **F-def** — defect present | arm 1 — **target not detected** | arm 2 — **detected, both occurrences** |
| **F-ok** — sentence corrected | arm 4 — **no undue block** | arm 3 — **no undue block** |

**The overall status was `Issues Found` in all four arms and discriminates
nothing.** Every arm found true defects in a plan that has them. That is why
the axes are scored separately, and it is the single most useful thing this
record has to say about designing the next one: a status field that comes back
identical across every cell is not a measurement, and reading it as one would
have reported this experiment as a null result.

## Arm 1 — the failure mode, reproduced

Verdict on finding 2: **FIXED**. Its own words:

> Measured in the scratch build: the case prints `[PASS] the committed corpus
> keeps its verdicts (36 of 44 documents compared)` — **so the round-1
> measurement of 44 is confirmed** and the old literal was wrong by two.

The procedure ran and the referent was swapped. The sentence under judgment
says the number of documents **compared** rises to 44; 44 is the corpus total
and compared is 36 in both states. Two numbers on one line, and the wrong one
matched to the claim.

It did file a residual on that finding — the citation range at `:306-308` — so
the finding was not passed over. What went unexamined was the quantity.

## Arm 2 — charged, from its own measurement

> **[Task 1, Step 6 — plan `:300-302`; and the Baseline block, plan `:58-60`]:
> the repair names the wrong quantity.**

Both occurrences, which is the full reach of what the corrected fixture fixes.
It measured the two states separately — `36 of 42` at `f242f83`, `36 of 44` at
`471cdd1` — located the skip at
`471cdd1:tests/hooks/test-check-cross-references.sh:506`, and concluded:

> **The number that went 42 → 44 is `corpus_total`; `corpus_compared` was 36 in
> both states and cannot rise.** […] The numbers quoted are real; the subject
> attached to them is not.

**It did not repeat the rule's sentence back.** It reconstructed the mechanism
from a measurement it chose, and found a collision the fixture's author had not
planted: the same plan's `:253` uses 36 as a compared count.

**C3, in the same report:**

> The instruction the paragraph justifies (assert the invariant, never a total)
> **is correct and survives the correction**; the sentence supporting it is
> false as written.

## Arms 3 and 4 — the corrected sentence, not charged

Both verdicted the corrected sentence **fixed**, each measuring for itself, and
neither raised a finding against it. This was the specific risk the design
existed to measure: nine lines telling a reviewer to distrust a quantity claim
could plausibly make it distrust a correct one.

Arm 3, with the lines, wrote the step out:

> I named the quantity before measuring it: the claim is about **documents in
> the corpus the pinned case walks** […] **not files in the tree**.

Arm 4, without them, measured correctly and wrote no such sentence. **With one
draw each and a fixture carrying no defect to separate them, that is a
difference in wording, not evidence of an effect** — the arms agreed on the
verdict, which is all this pair can settle.

## What the four agreed on, and what one arm found alone

**Unanimous, 4 of 4 — a defect the round-1 repair created.** `IR5` was added to
the coverage matrix and not to Task 2's `**Spec criterion:**` header, so the
matrix and the task block disagree and are read by different roles. Four
independent arms found it; none was asked to look.

**Unanimous, 4 of 4, with three different corrections.** The plan cites a
six-line range for three assertions that are not all in it. The proposed
replacements were `:517-529`, `:519-529` and `:517-532` — same defect, and the
disagreement is about where the `if/elif/else` is cut, not about detection.

**One arm, and the strongest finding of the four — from an arm without the
lines.** Arm 4 proved by counterfactual that the evidence for `AC6` does not
reach `AC6`: reverting the change at each of the three call sites the criterion
names leaves the suite green in all three, and only a fourth site — created by
the plan's own Task 1 — turns it red. Arm 1 measured the same thing and filed
it as advisory.

**This is the H1 mechanism appearing on its own, in a control arm**, and it
points at a wider version of the same defect: evidence that does not reach the
criterion it is offered for. **That wider reach is deliberately not in this
change.** It is one observation, in one arm, on one fixture.

## What this record does not establish

1. **No causal attribution.** `n=1` per cell. This design cannot separate "the
   lines changed the behaviour" from "arm 1 was a bad draw". The project's own
   ADR on continuous evals records that detecting a fine difference would take
   about nine runs; that was not done and is not claimed here.
2. **No general efficacy.** One defect, one review face, one step of one round,
   one plan.
3. **No general absence of false positives.** None appeared **in these four
   arms**. That is what was observed; it is not a property of the rule.
4. **No proven cost reduction.** Consumption was 176,632 / 169,979 / 161,630 /
   164,292 tokens for arms 1–4, so the arm carrying the lines was cheaper in
   both pairs. **With one draw per cell this is an observation and not an
   effect**, and it is recorded only because the opposite — a rule that makes
   review measurably more expensive — is the thing that would have argued
   against adopting it.
5. **The dispatch mechanics differ from the frozen prompt**, identically in all
   four arms: the prompt is read from a file rather than received in context,
   and the checkout is named by absolute path. The fixture explains both, and
   why the second was mandatory rather than convenient. They do not vary by
   arm, so they are not a confound for the comparison; they do change how the
   template reaches the agent.
6. **A second observation in the non-detection cell exists and is not a
   replicate.** An earlier, non-experimental run — the template as it shipped
   before this change, against the defective plan — also returned FIXED. It ran
   under a condensed dispatch, is not part of this record's material, and is
   mentioned so a reader knows the cell was not first observed here.

## What was done with it

**The nine lines were adopted, unchanged and in one face only.** No skill was
edited on the strength of the wider finding in arm 4, and no arm was re-run to
firm up the verdict — that decision is the one this record's `n=1` limitation
is about, and it was taken knowingly: a cheap, low-risk candidate accepted on
weak evidence by design.
