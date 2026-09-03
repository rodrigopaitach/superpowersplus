# Review yield, a nit cap, and the problem the spec never carried — design

**Date:** 2026-09-03
**Status:** draft, pending review
**Route:** full process — more than two production files change (nine files across five skills), so criterion three of the short path fails and no offer was made.

## Problem

**This project measures what its reviews cost and never what they return.** The
median document review takes 7.3 minutes across the 29 runs on record
([`CHANGELOG.md`](../../../CHANGELOG.md), section `[1.16.0] - 2026-08-08`), and
a five-task branch dispatches between 13 and 69 subagents. Against that, there
is no record anywhere of how many blocking findings a round produced, or how
many survived the fix. The question "are the review passes paying for
themselves" cannot be answered from this repository — it can only be argued.

The gap is not academic. The `CHANGELOG` already records four separate
occasions where review passes in series missed the same defect, including
*"four independent review lenses and 68 catalogue measurements passed a defect
of this shape"* (section `[1.20.0] - 2026-08-24`). Whether that is the rule or
the exception decides whether the round caps are too high, too low, or right —
and nothing collects the data that would settle it.

**A second problem shares the same root: the spec has never carried the problem
it solves.** Six sections are required
([`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md),
section "After the Design", the required-sections table) and none of them states what is wrong today.
`superpowersplus:final-branch-audit` traces `AC` and `IR` row by row, which
proves the thing was built as specified; nothing anywhere asks whether the
specification addressed the problem. Authors have felt the gap and filled it by
hand — 73 of 201 specs across eleven projects carry such a section, under twelve
different names in two languages, and no gate reads any of them.

**Out of scope, deliberately.** Two candidates were investigated and held back
with their reasons recorded in the decision record below: telling reviewers not
to report what the deterministic gates already enforce (reasoned, never
measured — the instrument this design builds is what would measure it), and a
sixth short-path criterion (the short path has fired zero times in 34
opportunities, so the change would be unobservable).

## Acceptance Criteria

**AC1.** [`skills/brainstorming/spec-document-reviewer-prompt.md`](../../../skills/brainstorming/spec-document-reviewer-prompt.md), section "Output Format", carries a line reporting how many findings the previous round raised and how many are still open.

**AC2.** [`skills/writing-plans/plan-document-reviewer-prompt.md`](../../../skills/writing-plans/plan-document-reviewer-prompt.md), section "Output Format", carries the same line.

**AC3.** `docs/review-yield.md` exists and defines its own columns in its header: date, branch, face, round, blocking findings raised, findings still open from the previous round.

**AC4.** Four skills instruct the controller to append one row per review dispatch: [`brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md) section "Spec Review", [`writing-plans/SKILL.md`](../../../skills/writing-plans/SKILL.md) section "Plan Review", [`subagent-driven-development/SKILL.md`](../../../skills/subagent-driven-development/SKILL.md) section "2. Handle the report", and [`requesting-code-review/SKILL.md`](../../../skills/requesting-code-review/SKILL.md) section "3. Act on feedback".

**AC5.** Each of the five reviewer prompts caps its advisory bucket at five items and reports the remainder as a count.

**AC6.** [`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md), section "After the Design", the required-sections table, requires `## Problem` as its first row, above `## Acceptance Criteria`.

**AC7.** [`skills/brainstorming/spec-document-reviewer-prompt.md`](../../../skills/brainstorming/spec-document-reviewer-prompt.md) treats a missing `## Problem` as blocking, in the same form the absent `## Coverage Map` already takes.

**AC8.** The same reviewer charges every acceptance criterion that does not serve the stated problem, naming the criterion and what it serves instead.

**AC9.** [`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md) carries a transition instruction for specs written before this requirement, in the form the coverage map's own transition already uses.

## Implicit Requirements

**IR1.** A round-1 report writes the absence of previous findings in words ("none — round 1"), never a blank or an omitted line.

**IR2.** The ledger's column definitions live only in `docs/review-yield.md`; each of the four write points names the file and never restates the columns.

**IR3.** No reviewer writes the ledger. The controller appends the row, because three of the five prompts declare the review read-only on the checkout.

**IR4.** The nit cap is worded per face against that face's own bucket name — `#### Minor (Nice to Have)` for the three diff faces, `**Recommendations (advisory, do not block approval):**` for the two document faces — never one sentence shared across all five.

**IR5.** `## Problem` is written in English, like the six sections already required. The section's content carries no language constraint.

**IR6.** `docs/review-yield.md` passes `scripts/check-links.sh`, which walks `docs/` recursively.

**IR7.** The change stages a `CHANGELOG.md` entry with it, as `scripts/check-changelog.sh` requires of any staged change under `skills/`.

## Codebase Findings

**Five reviewer prompts, not four.** `skills/requesting-code-review/code-reviewer.md`, `skills/subagent-driven-development/task-reviewer-prompt.md`, `skills/subagent-driven-development/re-review-prompt.md`, `skills/brainstorming/spec-document-reviewer-prompt.md`, `skills/writing-plans/plan-document-reviewer-prompt.md`.

**Two output shapes, deliberately unlike.** Severity buckets at `skills/requesting-code-review/code-reviewer.md:118` — `#### Minor (Nice to Have)` — and `skills/subagent-driven-development/task-reviewer-prompt.md:206`. Status-plus-issues at `skills/brainstorming/spec-document-reviewer-prompt.md:230` and `skills/writing-plans/plan-document-reviewer-prompt.md:160`, whose advisory bucket is `**Recommendations (advisory, do not block approval):**` at `:240` and `:172` respectively.

**The re-review already measures yield per finding.** `skills/subagent-driven-development/re-review-prompt.md:90` — `### Finding Verdicts` — rules ADDRESSED, NOT ADDRESSED, CONFIRMED or WITHDRAWN on each finding carried in. This is why AC1 and AC2 name only the two document reviewers: the task loop already reports what survived, and `code-reviewer` and `task-reviewer` are single-pass faces with no prior round to compare against.

**Three of the five prompts declare the review read-only.** `skills/requesting-code-review/code-reviewer.md:33`, `skills/subagent-driven-development/task-reviewer-prompt.md:66`, `skills/subagent-driven-development/re-review-prompt.md:42` — *"Your review is read-only on this checkout. Do not mutate the working tree"*. A reviewer cannot write the ledger row.

**The existing ledger is not reusable.** `skills/final-branch-audit/SKILL.md:361` — *"The ledger is the claim under audit"*. It carries an adversarial role; measurement written into it would be measurement under audit.

**The two document reviewers already receive what AC1 and AC2 report on.** `[PREVIOUS_FINDINGS]` is a required placeholder from round 2 in both templates, and neither Output Format asks for a verdict on any of them.

**A precedent exists for gating a form across reviewer prompts.** `scripts/check-evidence-line.sh:62-69` declares eight carriers by explicit list.

**Prompt files carry no line ceiling.** `scripts/check-skill-size.sh:53` iterates `skills/*/SKILL.md` only.

**`check-links.sh` walks the whole of `docs/`.** `scripts/check-links.sh:71`.

**The transition precedent for a newly required section.** `skills/brainstorming/SKILL.md:44` — *"Resuming a spec written before the map was required?"* — written when `## Coverage Map` became required.

**The controller's existing reporting points.** `skills/brainstorming/SKILL.md:290` and `skills/writing-plans/SKILL.md:419` both read *"Report the run to your human partner in the form every carrier uses"*. `skills/subagent-driven-development/SKILL.md:228` is `### 2. Handle the report`; `skills/requesting-code-review/SKILL.md:52` is `**3. Act on feedback:**`.

**The short-path criteria are a conjunction.** `skills/brainstorming/SKILL.md:74` opens the criteria table and `:82` reads *"Any one failing means the full process, and no offer at all"*.

### Corpus measurements, 2026-09-03

Measured over every `docs/superpowers/specs` directory under `~/Projetos`: **201 specs across 11 projects**.

| Measurement | Result |
|---|---|
| Specs written since the short path shipped (2026-08-08) | 34, in 5 projects |
| Of those, declaring `**Route:**` at all | 5 |
| Of those, taking the short path | **0** |
| Specs carrying a problem section under any name | **73 of 201** |
| Distinct headings used for it | 12+, in two languages — `## Problema` (23), `## Contexto` (14), `## Problem` (9), `## O problema` (5), `## Background` (5), `### Problem` (4), and seven more |
| Problem section positioned before `## Acceptance Criteria` | **25; zero after** |

**The controlled comparison that justifies AC6.** Within that same corpus — same authors, same projects, same language — the six sections the skill names show one heading each and **zero translations in 201 specs**: `## Acceptance Criteria` (45 specs), `## Implicit Requirements` (44), `## Codebase Findings` (42), `## External Dependencies` (42), `## Assumptions to Confirm` (42), `## Coverage Map` (40). The one section the skill does not name shows twelve headings in two languages. The only variable that differs is whether the skill named it.

## External Dependencies

**The nit cap of five, and the `## Problem` heading, both come from the same published source:** the AI-Native SDLC playbook, Anthropic, `https://claude.com/blog/the-ai-native-sdlc-playbook`, consulted 2026-09-03. Its `REVIEW.md` template reads *"Report at most five nits per review; summarize the rest as a count"*, and its `intent.md` template opens with `## Problem` followed by proposed outcome, affected users and systems, constraints, and open questions.

This is a documentation source consulted for a convention, not a runtime dependency. This project remains zero-dependency.

## Assumptions to Confirm

**The yield ledger's usefulness cannot be verified before it holds data.** Three branches is the stated threshold and roughly one month at this repository's rate (4 specs since 2026-08-08). Searched: `find` over the repository for any stored review report, and `grep` for the phrase recording the 29 reviews. The 29 document reviews behind the 7.3-minute median are not stored in this checkout, so no yield figure can be computed retroactively.

**Whether the 7.3-minute median still holds.** It was measured on 2026-08-08 and recorded in `CHANGELOG.md` section `[1.16.0]`. Nothing has re-measured it since. It is cited here as a dated figure, not a current one.

**Why 29 of 34 recent specs carry no `**Route:**` line is not established.** The rule at `skills/brainstorming/SKILL.md:99` makes the header the only downstream signal and treats its absence as the full process, so the specs are correctly routed either way. Whether the sizing step ran and went unrecorded, or did not run, cannot be told from the artifacts — which is itself the finding, and it is left for a separate branch rather than folded in here.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | Scope settled across four exchanges; the two held-back candidates are named in `## Problem` and recorded below. AC1–AC9 |
| Domain and data model | Clear | The entity is a review finding and its lifecycle across rounds. Already modelled at `re-review-prompt.md:90`; the document faces gain the same notion through AC1–AC2 |
| Interaction flow | Clear | The only reader is the controller, and the four existing reporting points are where the row is written. No new flow |
| Non-functional attributes | Resolved | Observability is the subject of (a) itself. IR2, IR3 |
| Integrations and external dependencies | Clear | Zero-dependency plugin; the playbook is a consulted document, recorded under `## External Dependencies` |
| Edge cases and failures | Resolved | Round 1 has no previous findings — IR1. A reviewer cannot write files — IR3 |
| Constraints and tradeoffs | Resolved | The prohibition on harmonizing the review faces (`CLAUDE.md`, and `docs/review-scopes.md`) shapes IR4; the read-only declaration shapes IR3 |
| Terminology | Resolved | The five faces name findings differently — `Critical`/`Important`/`Minor` against `Issues`/`Recommendations`. IR4 keeps each face's own words rather than imposing one vocabulary |
| Completion signals | Resolved | Every AC names a file and a section, settleable by opening it. The ledger's own usefulness is explicitly deferred to data — recorded under `## Assumptions to Confirm` |
| Placeholders and vague adjectives | Resolved | "Nit cap" quantified at five, with its source declared. "Three branches" quantified in `## Assumptions to Confirm` |

### Decision record

**Q1 — Where is the yield number written, so it outlives the session?**
Answer: a ledger file in the repository. Recommendation given: the same, on the ground that a number nobody aggregates fails the "who consumes this?" test that `CLAUDE.md` applies to any new field. Source: general practice, declared as such — no pattern in this project answered it, and the one adjacent artifact (the task ledger) was ruled out by `final-branch-audit/SKILL.md:361`.

**Q2 — Does the gate-coverage exclusion silence the reviewer or downgrade the finding?**
Answer: downgrade with a label. Recommendation given: the same, because `CLAUDE.md` sanctions `git commit --no-verify`, so a skipped gate is a real state rather than a hypothesis. Source: a project pattern, `CLAUDE.md`, section "Preparing a commit". **Superseded:** the exclusion itself was later held back (Q4), so this answer governs no criterion here and is recorded for the branch that takes it up.

**Q3 — Does the sixth short-path criterion enter this branch?**
Answer: it was folded in, then withdrawn in favour of `## Problem`. Recommendation given: withdraw. Source: measurement — the short path has fired 0 times in 34 opportunities across 5 projects, and its binding constraint is the two-file criterion, never intent; a criterion added to a conjunction that never passes changes nothing observable. Two defects in the proposed wording were found before it was withdrawn and are recorded for the branch that takes it up: the criterion read an artifact the checklist builds one step later, and the route it governed is the one that deletes that artifact.

**Q4 — Does the gate-coverage exclusion enter this branch?**
Answer: no, wait for data. Recommendation given: the same. Source: measurement, or its absence — the exclusion is reasoned and was never measured, the 29 review reports are not stored so it cannot be measured retroactively, and (a) is the instrument that would measure it. Applying "measure before cutting" to Q3 and not to this would be inconsistent. The nit cap was kept, on the different ground that it controls volume rather than judgement and carries a declared external source.
