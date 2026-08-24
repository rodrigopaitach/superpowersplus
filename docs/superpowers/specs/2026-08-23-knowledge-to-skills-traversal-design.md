# Knowledge-to-skills traversal — design

**Status:** draft, pending review
**Date:** 2026-08-23

## Problem

Five defect classes cross spec, plan and review without a gate. Each was
measured in a real session; none is caught by anything this plugin runs today.

**They are stated here as measurements, not as citations, and that is
deliberate.** Each was measured outside this repository, in work this project
cannot link to. What travels is the defect and the size of what it cost — never
a path no reader can open. This is the form the repository already uses for a
session measurement, at
[plan-document-reviewer-prompt.md](../../../skills/writing-plans/plan-document-reviewer-prompt.md),
section "Which Round This Is".

| # | The defect | What measured it |
|---|---|---|
| D1 | A plan's own test asserts a value the implementation the same plan specifies would not produce — the test expects one item where the plan's formula yields two | An implementer on a cheap model "fixed" the test by changing the implementation, diverging from the spec in silence. Caught by reading the implementer's report, not its status |
| D2 | Two approved acceptance criteria of one spec contradict each other on the same field — one refused a rule, the other taught an example that is that rule | **Two rounds of adversarial spec review missed it.** It surfaced only while writing the plan, where criteria sit next to each other as code |
| D3 | A replan writes tasks to build what the branch already contains — work surviving from an earlier plan does not appear in a diff against the main branch | 3 of 10 findings in one review were artifacts that already existed |
| D4 | A change of state is reviewed by measuring the target and never asking whether whoever applies it can reach that state | Four independent review lenses, 68 measurements in the catalogue, and the defect passed all of them. The gap was one line |
| D5 | A reviewer's finding about a gate or a measurable fact is acted on without being reproduced | A reviewer reported three type errors reading an artifact under a stale version convention; running it again showed zero. Separately, two reviewers asserted opposite facts about the same code — the cost of settling it was one file read |

Every one of these is stack-agnostic: D1 needs only a plan carrying tests and an
implementation, D2 only a spec with a numbered criteria list, D3 only git, D4
only a reviewed state change, D5 only a review performed by an agent.

**None of the five was ever recorded here — not caught, and not written down
either.** Searched on 2026-08-23 across the 15 plans in
`docs/superpowers/plans/`, the 20 specs in `docs/superpowers/specs/`, the whole
of [`CHANGELOG.md`](../../../CHANGELOG.md), and every one of the 41 items in its
`## Open gaps` section, read by title. Two grep hits in old plans were opened and
are false positives — one is a fix-loop test scenario, the other a browser
confused-deputy note. So these are not gaps this project weighed and deferred;
they never reached it.

**One open gap is adjacent to D1 and is not the same defect.**
[`CHANGELOG.md`](../../../CHANGELOG.md), section "Open gaps", item "No mutation
sensor", records that nothing kills a test passing by accident — an assertion
that never reaches the behavior. D1 is narrower and needs no mutation to find:
the test's expected value and the formula the *same plan* specifies disagree,
which is settled by reading the two side by side. Closing D1 does not close that
gap, and that gap would not have caught D1.

## Codebase Findings

Every claim below was located in this checkout on 2026-08-23.

| Finding | Citation |
|---|---|
| The plan reviewer's blocking contract is a table of `Requirement \| If it fails` rows — the shape a new blocking rule takes | `skills/writing-plans/plan-document-reviewer-prompt.md:82` (heading at `:76`) |
| The spec reviewer's Traceability section is blocking and takes `Finding \| Verdict` rows | `skills/brainstorming/spec-document-reviewer-prompt.md:130`, table at `:136` |
| The spec reviewer already carries a generic consistency check, `Internal contradictions, conflicting requirements` | `skills/brainstorming/spec-document-reviewer-prompt.md:68` |
| The spec reviewer's Groundedness section is blocking and takes the same row shape | `skills/brainstorming/spec-document-reviewer-prompt.md:73`, table at `:77` |
| `receiving-code-review` handles external reviewer feedback in its own section and says nothing about validating a finding before acting | `skills/receiving-code-review/SKILL.md:67` |
| `writing-plans` opens with a `## Scope Check` that decides what the plan covers before any task is written | `skills/writing-plans/SKILL.md:21` |
| `executing-plans` reads the branch's `git log` to *resume* an interrupted run — not to replan | `skills/executing-plans/SKILL.md:68` |
| Every `SKILL.md` is held under a 500-line ceiling, counting the whole file including frontmatter | `scripts/check-skill-size.sh:26` (`MAX=500`), rationale at `:3-19` |
| The ceiling gate holds exactly one exemption, and it runs on a deadline | `scripts/check-skill-size.sh:35` |
| `skills/writing-plans/SKILL.md` is 494 lines — six below the ceiling | measured 2026-08-23, `wc -l` |
| The reviewer prompt files are not `SKILL.md` and are not subject to the ceiling — the gate iterates `skills/*/SKILL.md` | `scripts/check-skill-size.sh:45` |
| The four review faces this project forbids harmonizing are the task reviewer, the code reviewer, the re-review and the final branch audit — the spec and plan *document* reviewers are not among them | [`docs/review-scopes.md`](../../review-scopes.md), section "What each face runs" |
| `writing-plans` already uses progressive disclosure into `references/`, so the pattern exists | `skills/writing-plans/references/execution-path.md` |

## External Dependencies

None. This project takes no third-party dependencies, and this design adds no
tool, service or library.

The research below is cited as the **basis for three design decisions**, not as
a dependency. These are public, citable sources; each was read for the fact it
grounds.

| Claim | Source | What it decides here |
|---|---|---|
| Manual inspection yields higher recall (p ≤ 0.01) than automated approaches on natural-language requirements; perspective-based reading beats checklist-based reading | Kamsties, Berry & Paech, *Detecting Ambiguities in Requirements Documents Using Inspections*, https://cs.uwaterloo.ca/~dberry/FTP_SITE/reprints.journals.conferences/KamstiesBerryPaech2001DetectingAmbiguity.pdf | AC1, AC2 and AC4 are judgements over prose and go to a reviewer, never to `check-cross-references` |
| Developers tolerate under 20% false positives; measured rates run 18%–86% | *Quieting the Static*, https://arxiv.org/pdf/2311.07482 | No rule here is added as a noisy advisory |
| 50.8% of static-analysis suppressions no longer affect any warning — they became useless | *An Empirical Study of Suppressed Static Analysis Warnings*, FSE 2025, https://dl.acm.org/doi/10.1145/3715729 | Demoting an imprecise rule to "advisory" is not a middle ground; a rule that cannot be precise is not added |

## Assumptions to Confirm

1. **That these five defect classes are the whole set.** They were drawn from a
   body of 54 recorded session measurements; 21 of those fall in the domain
   these skills govern, and **8 were examined in depth**. Searched by skill name
   and by domain vocabulary (plan, spec, review, criterion, matrix, gate,
   round). The remaining 13 in-domain records were not opened one by one, so a
   sixth class may exist. Nothing in this repository can answer this — the body
   searched is outside it.
2. **That no mechanism here makes the next such lesson arrive on its own.**
   This design carries five defect classes into the skills by hand. Whatever
   would carry the sixth belongs to whoever records it, not to this plugin:
   under [`CLAUDE.md`](../../../CLAUDE.md), section "What does not belong here",
   a change serving one workflow is refused, and a capture pipeline is one
   person's workflow by construction. **This is the same finding the security
   lens took** — measured, justified, and belonging one level down, in the
   `CLAUDE.md` of the projects rather than here. It is recorded in
   [`CHANGELOG.md`](../../../CHANGELOG.md), section "Open gaps", which states it
   as "the finding is that it belongs one level down". Cited by link and section
   rather than by line because that list is live and edited every release.
3. **That `receiving-code-review` is the right home for D5.** It is the skill
   that handles findings, and
   [`docs/review-scopes.md`](../../review-scopes.md), section "What each face
   runs", does not list it among the four faces whose scopes must not be
   harmonized. Confirmed by reading that table; **not** confirmed against any
   test — a grep found none asserting that boundary for any face.
4. **That each rule's wording fits the space its carrier has.** Four of the five
   land in reviewer prompt files, which carry no ceiling; AC3 lands in
   `skills/writing-plans/SKILL.md`, which has six lines before it fails
   `scripts/check-skill-size.sh`. Whether AC3's rule can be stated in four lines
   without becoming a pointer nobody follows is not settled here — the
   surrounding text has to be in front of the author. Measured: the file is 494
   lines today. **If it cannot, the fix is progressive disclosure into
   `references/`, never compression** — the rule this repository states in
   [`CLAUDE.md`](../../../CLAUDE.md), section "Where the obvious move is wrong".

## Acceptance Criteria

- **AC1** (D1) — The plan reviewer's blocking contract charges a step whose test
  asserts a value the implementation specified by the same plan would not
  produce, naming the test and the step that contradicts it.
- **AC2** (D2) — The plan reviewer's blocking contract requires the spec's
  acceptance criteria to be read in pairs — each against the neighbours that
  touch the same field — and charges a pair that cannot both hold.
- **AC3** (D3) — `writing-plans` instructs the author, before writing any task,
  to read the branch's own `git log` when the work is a replan, and says what
  that finds: work from an earlier plan that survives in the branch and does not
  appear in a diff against the main branch.
- **AC4** (D4) — Both document reviewers charge a change of state whose target
  is measured without asking whether whoever applies it can reach that state.
- **AC5** (D5) — `receiving-code-review` instructs that a reviewer finding about
  a gate, a test result or a measurable fact is reproduced before it is acted
  on, and states the cost of not doing so.
- **AC6** — Every rule added carries the measurement that motivated it, in the
  form used at
  [plan-document-reviewer-prompt.md](../../../skills/writing-plans/plan-document-reviewer-prompt.md),
  section "Which Round This Is" — the effect and its size, with no path a reader
  outside this repository could not open.
- **AC7** — `skills/writing-plans/SKILL.md` remains under the 500-line ceiling
  and `scripts/check-skill-size.sh` exits 0.

## Implicit Requirements

- **IR1** — No rule added is enforced by `check-cross-references` or any other
  mechanical gate. All five are judgements over prose, and the research above
  places that class where automation loses to inspection.
- **IR2** — No rule is added as a non-blocking advisory in a reviewer's table. A
  rule that cannot be stated precisely enough to block is not added at all.
- **IR3** — The four review faces named in
  [`docs/review-scopes.md`](../../review-scopes.md) are not touched. AC1 and AC2
  land on the plan *document* reviewer, AC4 on both document reviewers — neither
  of which that file governs.
- **IR4** — Each rule lands in exactly one carrier. A rule that would have to be
  repeated across carriers to work is out of scope here, because this repository
  charges copied shapes with a gate and none exists for these.
- **IR5** — Every citation this design introduces into a skill resolves, and
  `check-links.sh` stays green.
- **IR6** — `CHANGELOG.md` is staged with the change, per the pre-commit gate
  `scripts/check-changelog.sh`.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | AC1–AC5, one per defect class |
| Domain and data model | Clear | No data. The artifacts are markdown files already in the repository |
| Interaction flow | Clear | No user-facing flow; the readers are a subagent reviewer and the agent writing a plan |
| Non-functional attributes | Resolved | AC7 and IR5 — the ceiling gate and the link gate are the only runtime constraints this change can break |
| Integrations and external dependencies | Clear | None. Zero-dependency plugin, `CLAUDE.md` section "What does not belong here" |
| Edge cases and failures | Resolved | IR2 (no advisory rules), IR4 (single carrier). The failure mode is a rule too vague to act on, which IR2 refuses |
| Constraints and tradeoffs | Resolved | AC7 (500-line ceiling, 6 lines of headroom), IR3 (four faces untouched) |
| Terminology | Resolved | "Carrier" means the file a rule lives in, the sense [`docs/review-scopes.md`](../../review-scopes.md) already uses |
| Completion signals | Resolved | Every AC is settled by opening the named file and reading the rule, or by running the named gate |
| Placeholders and vague adjectives | Deferred | The exact wording of each rule belongs to the plan, where the surrounding text is in front of the author and the line budget is visible. `## Assumptions to Confirm` item 4 |

### Decision record

**Q: D2 was missed twice by adversarial spec review and surfaced while writing the plan. Does the new rule go to the spec reviewer, to `writing-plans`, or to the plan reviewer?**
Recommended: the plan reviewer.
Source: the measurement itself. Putting a stronger rule in the spec reviewer
puts it in the process the measurement says failed twice — changing the rule
while keeping the instrument, which this repository already treats as the wrong
move. `writing-plans` is where the lesson says the defect appeared, but its
`SKILL.md` has six lines of headroom and AC3 spends four of them. The plan
reviewer is where the spec and the plan are read side by side — the condition
that exposed the defect — and its prompt file carries no ceiling.
Answer: accepted. → AC2

**Q: D1's lesson describes a self-review by the plan author. But the author has six lines of headroom and the reviewer prompts have no ceiling. Where does it go?**
Recommended: the plan reviewer's blocking contract.
Source: two, and they agree. This project's own measurement —
`skills/writing-plans/plan-document-reviewer-prompt.md:76` is the blocking
contract and takes rows of exactly this kind — and the inspection research
above, which places judgement over prose with a reader rather than a script.
Answer: accepted, decided in session without escalation because both sources
agreed and no criterion changed. → AC1

**Q: Do AC1, AC2 and AC4 enter as blocking or advisory?**
Recommended: blocking.
Source: the suppression measurement (FSE 2025) — 50.8% of suppressions become
useless, so an advisory that nobody can act on is not a softer rule, it is a
rule that decays. D2 additionally has a measurement saying the *generic*
version already present does not catch the defect, which is the case for
blocking rather than for another advisory beside it.
Answer: accepted. → IR2

**Q: Does touching the spec and plan document reviewers violate the prohibition on harmonizing the four review faces?**
Recommended: no.
Source: `docs/review-scopes.md`, section "What each face runs" — the four are
the task reviewer, the code reviewer, the re-review and the final branch audit.
The document reviewers are not listed.
Answer: accepted. → IR3
