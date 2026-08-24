# Knowledge-to-skills traversal — design

**Status:** draft, pending review
**Date:** 2026-08-23

## Problem

Five lessons recorded in the owner's `~/.claude/knowledge/`, each with its own
measurement, govern behaviour that a superpowersplus skill is responsible for —
and no skill carries any of them. One of them names its destination in writing
(`Lição para `writing-plans``) and has been sitting unexecuted since July.

The mechanism is structural, not an oversight. Lessons are distilled in one
place and would have to act in another, and nothing crosses between them: the
knowledge file records a destination and stops there; the skill is never audited
against what the knowledge has accumulated. This is the owner's own rule applied
to itself — *"Regra sem leitor é invisível até falhar. Ao criar um
campo/convenção, perguntar quem CONSOME isto?"* — and the lessons carrying a
declared destination have no consumer.

This design carries those five lessons into the skills that execute them. It
does not build the crossing mechanism itself; that would be a second project,
and it is recorded under `## Assumptions to Confirm`.

## Codebase Findings

Every claim below was located in this checkout on 2026-08-23.

| Finding | Citation |
|---|---|
| The plan reviewer's blocking contract is a table of `Requirement \| If it fails` rows — the shape a new blocking rule takes | `skills/writing-plans/plan-document-reviewer-prompt.md:76` |
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
| The four review faces this project forbids harmonizing are the task reviewer, the code reviewer, the re-review and the final branch audit — the spec and plan *document* reviewers are not among them | `docs/review-scopes.md`, section "What each face runs" |
| `writing-plans` already uses progressive disclosure into `references/`, so the pattern exists | `skills/writing-plans/references/execution-path.md` |

## External Dependencies

None. This project takes no third-party dependencies, and this design adds no
tool, service or library.

The research below is cited as the **basis for three design decisions**, not as
a dependency. It was recorded in full in the owner's own knowledge base, outside
this repository and deliberately unresolvable from here, under the heading
"Fundamento externo das regras de gate".

| Claim | Source | What it decides here |
|---|---|---|
| Manual inspection yields higher recall (p ≤ 0.01) than automated approaches on natural-language requirements; perspective-based reading beats checklist-based reading | Kamsties, Berry & Paech, *Detecting Ambiguities in Requirements Documents Using Inspections*, https://cs.uwaterloo.ca/~dberry/FTP_SITE/reprints.journals.conferences/KamstiesBerryPaech2001DetectingAmbiguity.pdf | T1, T2 and T4 are judgements over prose and go to a reviewer, never to `check-cross-references` |
| Developers tolerate under 20% false positives; measured rates run 18%–86% | *Quieting the Static*, https://arxiv.org/pdf/2311.07482 | No rule here is added as a noisy advisory |
| 50.8% of static-analysis suppressions no longer affect any warning — they became useless | *An Empirical Study of Suppressed Static Analysis Warnings*, FSE 2025, https://dl.acm.org/doi/10.1145/3715729 | Demoting an imprecise rule to "advisory" is not a middle ground; a rule that cannot be precise is not added |

## Assumptions to Confirm

1. **That these five are the whole set.** The sweep covered 54 sections across
   `code-review-methodology.md` (34) and `testing-gotchas.md` (20); 21 fall in
   the domain the skills govern, and **8 were verified in depth**. Searched with
   `grep -rniE` over the skill names and over the domain vocabulary
   (plano|spec|revis|review|AC|task|matriz|gate|rodada). The remaining 13
   in-domain sections were not opened one by one. A sixth lesson may exist.
2. **That the crossing mechanism belongs to a later project.** This design
   carries five lessons across by hand. It does not make the next one cross by
   itself, so the same gap reopens with the next lesson recorded. Whether that
   mechanism is a gate, a checklist in the capture flow, or nothing at all was
   not investigated — no search was run for it.
3. **That `receiving-code-review` is the right home for T5.** It is the skill
   that handles findings, and `docs/review-scopes.md` does not list it among the
   four faces whose scopes must not be harmonized. Confirmed by reading that
   file's "What each face runs" table; not confirmed against any test that
   asserts the boundary.

## Acceptance Criteria

- **AC1** — The plan reviewer's blocking contract charges a task criterion whose
  prose promises coverage the task's own code steps do not write, naming the
  criterion and the step.
- **AC2** — The spec reviewer's Traceability section charges acceptance criteria
  read one at a time rather than in pairs, requiring each criterion to be read
  against the neighbours that touch the same field.
- **AC3** — `writing-plans` instructs the author, before writing any task, to
  read the branch's own `git log` when the work is a replan, and says what that
  finds: work from an earlier plan that survives in the branch and does not
  appear in a diff against the main branch.
- **AC4** — Both document reviewers charge a change of state whose target is
  measured without asking whether the executor can reach it.
- **AC5** — `receiving-code-review` instructs that a reviewer finding about a
  gate, a test result or a measurable fact is reproduced before it is acted on,
  and states the cost of not doing so.
- **AC6** — Every rule added carries the measurement that motivated it, in the
  form this repository already uses for a measured rule.
- **AC7** — `skills/writing-plans/SKILL.md` remains under the 500-line ceiling
  and `scripts/check-skill-size.sh` exits 0.

## Implicit Requirements

- **IR1** — No rule added is enforced by `check-cross-references` or any other
  mechanical gate. All five are judgements over prose, and the research above
  places that class where automation loses to inspection.
- **IR2** — No rule is added as a non-blocking advisory in a reviewer's table. A
  rule that cannot be stated precisely enough to block is not added at all.
- **IR3** — The four review faces named in `docs/review-scopes.md` are not
  touched. T1, T2 and T4 land on the spec and plan *document* reviewers, which
  that document does not govern.
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
| Functional scope and behavior | Resolved | AC1–AC5, one per lesson |
| Domain and data model | Clear | No data. The artifacts are markdown files already in the repository |
| Interaction flow | Clear | No user-facing flow; the readers are a subagent reviewer and the agent writing a plan |
| Non-functional attributes | Resolved | AC7 and IR5 — the ceiling gate and the link gate are the only runtime constraints this change can break |
| Integrations and external dependencies | Clear | None. Zero-dependency plugin, `CLAUDE.md` section "What does not belong here" |
| Edge cases and failures | Resolved | IR2 (no advisory rules), IR4 (single carrier). The failure mode is a rule too vague to act on, which IR2 refuses |
| Constraints and tradeoffs | Resolved | AC7 (500-line ceiling, 6 lines of headroom), IR3 (four faces untouched) |
| Terminology | Resolved | "Carrier" means the file a rule lives in, the sense `docs/review-scopes.md` already uses |
| Completion signals | Resolved | Every AC is settled by opening the named file and reading the rule, or by running the named gate |
| Placeholders and vague adjectives | Deferred | The exact wording of each rule belongs to the plan, where the surrounding text is in front of the author. `## Assumptions to Confirm` item 2 |

### Decision record

**Q: T1's lesson says "self-review", which is the plan author. But the author has six lines of headroom and the reviewer prompts have no ceiling. Where does it go?**
Recommended: the plan reviewer's blocking contract.
Source: two, and they agree. This project's own measurement —
`skills/writing-plans/plan-document-reviewer-prompt.md:76` is the blocking
contract and takes rows of exactly this kind — and the inspection research
above, which places judgement over prose with a reader rather than a script.
Answer: accepted, decided in session without escalation because both sources
agreed and no criterion changed. → AC1

**Q: Do T1, T2 and T4 enter as blocking or advisory?**
Recommended: blocking.
Source: the suppression measurement (FSE 2025) — 50.8% of suppressions become
useless, so an advisory that nobody can act on is not a softer rule, it is a
rule that decays. T2 additionally has a measurement saying the *generic*
version already present does not catch the defect, which is the case for
blocking rather than for another advisory beside it.
Answer: accepted. → IR2

**Q: Does touching the spec and plan document reviewers violate the prohibition on harmonizing the four review faces?**
Recommended: no.
Source: `docs/review-scopes.md`, section "What each face runs" — the four are
the task reviewer, the code reviewer, the re-review and the final branch audit.
The document reviewers are not listed.
Answer: accepted. → IR3
