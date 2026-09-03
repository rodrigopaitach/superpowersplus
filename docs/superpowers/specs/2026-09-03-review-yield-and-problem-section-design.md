# Review yield, a nit cap, and the problem the spec never carried — design

**Date:** 2026-09-03
**Status:** draft, round 1 findings repaired
**Route:** full process — more than two production files change (ten files across five skills), so criterion three of the short path fails and no offer was made.

## Problem

**This project measures what its reviews cost and never what they return.** The
median document review takes 7.3 minutes across the 29 runs on record
([`CHANGELOG.md`](../../../CHANGELOG.md), section `[1.16.0] - 2026-08-08`), and
a five-task branch dispatches between 13 and 69 subagents. Against that, there
is no record anywhere of how many blocking findings a round produced, or how
many survived the fix. The question "are the review passes paying for
themselves" cannot be answered from this repository — it can only be argued.

The gap is not academic. The `CHANGELOG` already records occasions where review
passes in series missed the same defect, including *"four independent review
lenses and 68 catalogue measurements passed a defect of this shape"* (section
`[1.20.0] - 2026-08-24`). Whether that is the rule or the exception decides
whether the round caps are too high, too low, or right — and nothing collects
the data that would settle it.

**A second problem shares the same root: the spec has never carried the problem
it solves.** Six sections are required
([`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md),
section "After the Design", the required-sections table) and none of them states
what is wrong today. `superpowersplus:final-branch-audit` traces `AC` and `IR`
row by row, which proves the thing was built as specified; nothing anywhere asks
whether the specification addressed the problem. Authors have felt the gap and
filled it by hand — 56 of 201 specs across eleven projects carry such a section,
under fifteen different names in two languages, and no gate reads any of them.

**A third, smaller one: a mechanical check reports limits it does not have.**
`skills/writing-plans/scripts/check-cross-references` carries a
`WHAT IT DOES NOT COVER` block so a green run is not over-read. It lists five
exclusions and omits a sixth: it never resolves a section reference pointing
into another file. In this repository `scripts/check-links.sh` covers that class
from the pre-commit hook; in a partner project, where the skill presents
`check-cross-references` as the mechanical check to run before dispatching a
reviewer, nothing does — and the block that exists to say so stays silent.

**Out of scope, deliberately.** Two candidates were investigated and held back
with their reasons recorded in the decision record below: telling reviewers not
to report what the deterministic gates already enforce (reasoned, never
measured — the instrument this design builds is what would measure it), and a
sixth short-path criterion (the short path has fired zero times in 41
opportunities, so the change would be unobservable). A third was measured and
rejected: teaching `check-cross-references` to resolve section references, since
zero of the 40 such references in the corpus are broken.

## Acceptance Criteria

**AC1.** [`skills/brainstorming/spec-document-reviewer-prompt.md`](../../../skills/brainstorming/spec-document-reviewer-prompt.md), section "Output Format", carries a line reporting how many findings the previous round raised and how many are still open.

**AC2.** [`skills/writing-plans/plan-document-reviewer-prompt.md`](../../../skills/writing-plans/plan-document-reviewer-prompt.md), section "Output Format", carries the same line.

**AC3.** `docs/review-yield.md` exists and defines its own columns in its header: date, branch, face, round, blocking findings raised, findings still open from the previous round.

**AC4.** Four skills instruct the controller to append one row per review dispatch: [`brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md) section "Spec Review", [`writing-plans/SKILL.md`](../../../skills/writing-plans/SKILL.md) section "Plan Review", [`subagent-driven-development/SKILL.md`](../../../skills/subagent-driven-development/SKILL.md) sections "3. Review the task" and "4. The fix loop", and [`requesting-code-review/SKILL.md`](../../../skills/requesting-code-review/SKILL.md) section "3. Act on feedback".

**AC5.** Each of the five reviewer prompts caps its advisory bucket at five items and reports the remainder as a count.

**AC6.** [`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md), section "After the Design", the required-sections table, requires `## Problem` as its first row, above `## Acceptance Criteria`.

**AC7.** [`skills/brainstorming/spec-document-reviewer-prompt.md`](../../../skills/brainstorming/spec-document-reviewer-prompt.md) treats a missing `## Problem` as blocking, in the same form the absent `## Coverage Map` already takes.

**AC8.** The same reviewer charges every acceptance criterion that does not serve the stated problem, naming the criterion and what it serves instead.

**AC9.** [`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md) carries a transition instruction for specs written before this requirement, in the form the coverage map's own transition already uses.

**AC10.** `skills/writing-plans/scripts/check-cross-references` names, in its `WHAT IT DOES NOT COVER` block, that a section reference into another file is not resolved, and where that class is covered instead.

## Implicit Requirements

**IR1.** A round-1 report writes the absence of previous findings in words ("none — round 1"), never a blank or an omitted line.

**IR2.** The ledger's column definitions live only in `docs/review-yield.md`; each of the write points names the file and never restates the columns.

**IR3.** No reviewer writes the ledger. The controller appends the row, because three of the five prompts declare the review read-only on the checkout.

**IR4.** The nit cap is worded per face against that face's own bucket name — `#### Minor (Nice to Have)` for the three diff faces, `**Recommendations (advisory, do not block approval):**` for the two document faces — never one sentence shared across all five.

**IR5.** `## Problem` is written in English, like the six sections already required. The section's content carries no language constraint.

**IR6.** `docs/review-yield.md` passes `scripts/check-links.sh`, which walks `docs/` recursively.

**IR7.** The change stages a `CHANGELOG.md` entry with it, as `scripts/check-changelog.sh` requires of any staged change under `skills/`.

**IR8.** Every corpus figure this document states is accompanied by the rule that produced it, so a re-measurement that disagrees can be told from a measurement run differently.

## Codebase Findings

**Five reviewer prompts, not four.** `skills/requesting-code-review/code-reviewer.md`, `skills/subagent-driven-development/task-reviewer-prompt.md`, `skills/subagent-driven-development/re-review-prompt.md`, `skills/brainstorming/spec-document-reviewer-prompt.md`, `skills/writing-plans/plan-document-reviewer-prompt.md`.

**Two output shapes, deliberately unlike.** Severity buckets at `skills/requesting-code-review/code-reviewer.md:118` — `#### Minor (Nice to Have)` — and `skills/subagent-driven-development/task-reviewer-prompt.md:206`. Status-plus-issues at `skills/brainstorming/spec-document-reviewer-prompt.md:230` and `skills/writing-plans/plan-document-reviewer-prompt.md:160`, whose advisory bucket is `**Recommendations (advisory, do not block approval):**` at `:240` and `:172` respectively.

**The re-review already measures yield per finding.** `skills/subagent-driven-development/re-review-prompt.md:90` — `### Finding Verdicts` — rules ADDRESSED, NOT ADDRESSED, CONFIRMED or WITHDRAWN on each finding carried in. This is why AC1 and AC2 name only the two document reviewers: the task loop already reports what survived, and `code-reviewer` and `task-reviewer` are single-pass faces with no prior round to compare against.

**Three of the five prompts declare the review read-only.** `skills/requesting-code-review/code-reviewer.md:35`, `skills/subagent-driven-development/task-reviewer-prompt.md:66`, `skills/subagent-driven-development/re-review-prompt.md:42` — *"Your review is read-only on this checkout. Do not mutate the working tree"*. A reviewer cannot write the ledger row.

**The task loop's review points are sections 3 and 4, not section 2.** `skills/subagent-driven-development/SKILL.md:228` is `### 2. Handle the report`, and it handles the *implementer's* report — `:230` reads *"Implementer subagents report one of four statuses"* — which happens before any reviewer has run. The task reviewer is dispatched from `### 3. Review the task` at `:250`, and the re-review from `### 4. The fix loop` at `:311`.

**The existing ledger is not reusable.** `skills/final-branch-audit/SKILL.md:361` — *"The ledger is the claim under audit"*. It carries an adversarial role; measurement written into it would be measurement under audit.

**The two document reviewers already receive what AC1 and AC2 report on.** `[PREVIOUS_FINDINGS]` is a required placeholder from round 2 in both templates, and neither Output Format asks for a verdict on any of them.

**A precedent exists for gating a form across reviewer prompts.** `scripts/check-evidence-line.sh:62-69` declares eight carriers by explicit list.

**Prompt files carry no line ceiling.** `scripts/check-skill-size.sh:53` iterates `skills/*/SKILL.md` only.

**`check-links.sh` walks the whole of `docs/`, and resolves an indented heading.** `scripts/check-links.sh:71` sets the targets; `:104` is `SECTION_HEADING = re.compile(r"^\s*(#{1,6})\s+(.*?)\s*#*\s*$")`, whose leading `\s*` is what lets it read a heading indented inside a fenced prompt template.

**`check-cross-references` parses headings only inside the document under check.** `skills/writing-plans/scripts/check-cross-references:142` defines `section(title_re)` as *"Body of the first `## <title>` section"* of that document. It carries no pattern for a section reference into another file, and its `WHAT IT DOES NOT COVER` block at `:17` lists five exclusions, none of them this class.

**The transition precedent for a newly required section.** `skills/brainstorming/SKILL.md:44` — *"Resuming a spec written before the map was required?"* — written when `## Coverage Map` became required.

**The controller's existing reporting points.** `skills/brainstorming/SKILL.md:290` and `skills/writing-plans/SKILL.md:419` both read *"Report the run to your human partner in the form every carrier uses"*. `skills/requesting-code-review/SKILL.md:52` is `**3. Act on feedback:**`.

**The short-path criteria are a conjunction.** `skills/brainstorming/SKILL.md:74` opens the criteria table and `:82` reads *"Any one failing means the full process, and no offer at all"*.

**The short path shipped in `[1.15.0] - 2026-08-06`.** `CHANGELOG.md`, that section's `### Added` block — *"A short path for a small change"*. It is not in `[1.16.0] - 2026-08-08`, whose entry moves the mechanical check before the first dispatch.

### Corpus measurements, 2026-09-03

**Corpus:** every `*.md` under a directory matching `docs/superpowers/specs` beneath `~/Projetos`, excluding this document — **201 specs across 11 projects**.

**Heading rule, used by every count below:** a document carries section *X* when some line matches `^\s*#{1,6}\s+X\s*$` with internal whitespace normalized. The leading `\s*` is deliberate and matches `scripts/check-links.sh:104`, so a heading indented inside a fenced block counts.

| Measurement | Rule applied | Result |
|---|---|---|
| Specs written since the short path shipped | filename date `>= 2026-08-06` | **41**, in **6** projects |
| Of those, declaring `**Route:**` | `Route:` anywhere in the line, not anchored — the field legitimately follows `**Data:**`, a bullet marker, or a blockquote `>` | **12** |
| Of those, taking the short path | `**Route:**` followed by `short` or `caminho curto` | **0** |
| Specs carrying a problem section | heading in the closed set {Problem, Problems, Problema, Problemas, O problema, The request, Context, Contexto, Background}, plus `<one of those> — <gloss>` | **56 of 201**, under **15** distinct headings |
| Position relative to `## Acceptance Criteria` | of the 20 specs carrying both | **20 before, 0 after** |
| Section references into another file, corpus-wide (specs and plans) | markdown link to a `.md`, then `, section "…"`; title and headings whitespace-normalized | 40 found — **36 resolve, 0 name a missing heading**, 4 point at a file that does not exist |

**The controlled comparison that justifies AC6.** Under the same heading rule, within the same corpus — same authors, same projects, same language — the six sections the skill names show one heading each and **zero translations**: `## Acceptance Criteria` 44, `## Implicit Requirements` 43, `## Codebase Findings` 39, `## External Dependencies` 39, `## Assumptions to Confirm` 39, `## Coverage Map` 39; and 0 each for `## Critérios de Aceitação`, `## Requisitos Implícitos`, `## Achados no Código`, `## Dependências Externas`, `## Suposições a Confirmar`, `## Mapa de Cobertura`. The one section the skill does not name shows fifteen headings in two languages. The only variable that differs is whether the skill named it.

**What the problem-section count depends on.** The closed set above is a judgement, and a wider net returns a larger number — a permissive prefix match returns roughly twice as many, because it admits `## Contexto e problema`, `## Problemas conhecidos` and similar. The closed set is stated so a re-measurement that disagrees can be told from one run differently. AC6's argument rests on the contrast with zero, which no reasonable set changes.

## External Dependencies

**The nit cap of five, and the `## Problem` heading, both come from the same published source:** the AI-Native SDLC playbook, Anthropic, `https://claude.com/blog/the-ai-native-sdlc-playbook`, consulted 2026-09-03. Its `REVIEW.md` template reads *"Report at most five nits per review; summarize the rest as a count"*, and its `intent.md` template opens with `## Problem` followed by proposed outcome, affected users and systems, constraints, and open questions.

This is a documentation source consulted for a convention, not a runtime dependency. This project remains zero-dependency.

## Assumptions to Confirm

**The yield ledger's usefulness cannot be verified before it holds data.** Three branches is the stated threshold and roughly one month at this repository's rate. Searched: `find` over the repository for any stored review report, and `grep` for the phrase recording the 29 reviews. The 29 document reviews behind the 7.3-minute median are not stored in this checkout, so no yield figure can be computed retroactively.

**Whether the 7.3-minute median still holds.** It was measured on 2026-08-08 and recorded in `CHANGELOG.md` section `[1.16.0]`. Nothing has re-measured it since. It is cited here as a dated figure, not a current one.

**Why 29 of the 41 recent specs carry no `**Route:**` line is not established.** The rule at `skills/brainstorming/SKILL.md:99` makes the header the only downstream signal and treats its absence as the full process, so the specs are correctly routed either way. Whether the sizing step ran and went unrecorded, or did not run, cannot be told from the artifacts — searched by grepping the 41 for `Route:` under both an anchored and an unanchored pattern, which is what separates 12 from 6 and is itself recorded above. This is left for a separate branch rather than folded in here.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | Scope settled across five exchanges; the three held-back candidates are named in `## Problem` and recorded below. AC1–AC10 |
| Domain and data model | Clear | The entity is a review finding and its lifecycle across rounds. Already modelled at `re-review-prompt.md:90`; the document faces gain the same notion through AC1–AC2 |
| Interaction flow | Clear | The only reader is the controller, and the existing reporting points are where the row is written. No new flow |
| Non-functional attributes | Resolved | Observability is the subject of (a) itself — IR2, IR3 — and of AC10, which makes a gate's own blind spot legible |
| Integrations and external dependencies | Clear | Zero-dependency plugin; the playbook is a consulted document, recorded under `## External Dependencies` |
| Edge cases and failures | Resolved | Round 1 has no previous findings — IR1. A reviewer cannot write files — IR3 |
| Constraints and tradeoffs | Resolved | The prohibition on harmonizing the review faces (`CLAUDE.md`, and `docs/review-scopes.md`) shapes IR4; the read-only declaration shapes IR3 |
| Terminology | Resolved | The five faces name findings differently — `Critical`/`Important`/`Minor` against `Issues`/`Recommendations`. IR4 keeps each face's own words rather than imposing one vocabulary |
| Completion signals | Resolved | Every AC names a file and a section, settleable by opening it. The ledger's own usefulness is explicitly deferred to data — recorded under `## Assumptions to Confirm` |
| Placeholders and vague adjectives | Resolved | "Nit cap" quantified at five, with its source declared. Every corpus figure carries the rule that produced it — IR8 |

### Decision record

**Q1 — Where is the yield number written, so it outlives the session?**
Answer: a ledger file in the repository. Recommendation given: the same, on the ground that a number nobody aggregates fails the "who consumes this?" test that `CLAUDE.md` applies to any new field. Source: general practice, declared as such — no pattern in this project answered it, and the one adjacent artifact (the task ledger) was ruled out by `final-branch-audit/SKILL.md:361`.

**Q2 — Does the gate-coverage exclusion silence the reviewer or downgrade the finding?**
Answer: downgrade with a label. Recommendation given: the same, because `CLAUDE.md` sanctions `git commit --no-verify`, so a skipped gate is a real state rather than a hypothesis. Source: a project pattern, `CLAUDE.md`, section "Preparing a commit". **Superseded:** the exclusion itself was later held back (Q4), so this answer governs no criterion here and is recorded for the branch that takes it up.

**Q3 — Does the sixth short-path criterion enter this branch?**
Answer: it was folded in, then withdrawn in favour of `## Problem`. Recommendation given: withdraw. Source: measurement — the short path has fired 0 times in 41 opportunities across 6 projects, and its binding constraint is the two-file criterion, never intent; a criterion added to a conjunction that never passes changes nothing observable. Two defects in the proposed wording were found before it was withdrawn and are recorded for the branch that takes it up: the criterion read an artifact the checklist builds one step later, and the route it governed is the one that deletes that artifact.

**Q4 — Does the gate-coverage exclusion enter this branch?**
Answer: no, wait for data. Recommendation given: the same. Source: measurement, or its absence — the exclusion is reasoned and was never measured, the 29 review reports are not stored so it cannot be measured retroactively, and (a) is the instrument that would measure it. Applying "measure before cutting" to Q3 and not to this would be inconsistent. The nit cap was kept, on the different ground that it controls volume rather than judgement and carries a declared external source.

**Q5 — Does `check-cross-references` learn to resolve section references, or only declare that it does not?**
Answer: only declare it — AC10. Recommendation given: the same. Source: measurement — 40 such references exist across the corpus's specs and plans and **zero** name a missing heading, so there is no defect to catch; and in this repository `scripts/check-links.sh:104` already covers the class from the pre-commit hook. Building the resolver would be the same unmeasured construction that Q3 and Q4 were withdrawn for. What survives is that a green run must not read as coverage of a class the script never inspects.
