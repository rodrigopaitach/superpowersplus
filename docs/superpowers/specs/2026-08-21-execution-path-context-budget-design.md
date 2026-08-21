# Execution Path Criterion — Context Budget and Coupling

**Route:** full process (the short path was offered and refused by the sizing —
three production files and a public contract change; see "Sizing" below).

**Status:** design under review (brainstormed with Rodrigo 2026-08-21);
implementation plan to follow.

**Objective:** replace the temporal criterion that selects between inline
execution and subagent-driven execution — "does it finish in one sitting" —
with the two questions a third-party measurement establishes: does the plan fit
in one context window *with slack for a correction round*, and is there a
low-coupling boundary between its tasks. The decision stays with the human
partner; what changes is what the offer asks.

**Out of scope, decided 2026-08-21:** grouping plan tasks into clusters for a
single dispatch. The measurement that motivates it targets an orchestrator that
carries diffs and reports in its own window, which this project's controller
does not (Finding 4). Revisit only with a measurement taken against this
plugin.

## Problems

Three, all located.

1. **The selection criterion is temporal, and the measurement shows temporal
   does not predict occupancy.** The single-agent run of the third-party
   benchmark took practically the same wall time as the best configuration
   measured — both sources state this — and ended with its context window at
   74% full against that configuration's 26%, leaving no budget for the
   correction round that follows a first pass. Same sitting, three times the
   occupancy. A plan can be short in time and dense in context, and the
   current criterion cannot tell the two apart.

2. **The criterion is replicated in eight places across three skills.** No
   single statement owns it, so correcting it means correcting it three times
   and hoping the fourth reader finds the same words.

3. **Coupling has no place in the vocabulary of plan execution.** The only
   skill that treats it as a first-class variable is walled off from plan runs
   on purpose (Finding 6), so the variable the measurement identifies as
   decisive cannot be named where the decision is taken.

## Sizing

The short path was evaluated at checklist item 2 and does not apply.

| Criterion | Result |
|---|---|
| No migration or schema change | Pass — this repository has none |
| No new dependency | Pass — zero-dependency plugin |
| Two or fewer production files touched | **Fail** — three `SKILL.md` files carry the criterion |
| No public contract changes | **Fail** — the criterion is the contract between `writing-plans` and the two execution skills |
| Touches no money, auth, or PII | Pass — by path, none of the files touched |

## Design

### The canonical statement

A new file, `skills/writing-plans/references/execution-path.md`, becomes the
one statement of the criterion. The three `SKILL.md` files point to it by
markdown link and stop repeating it.

It goes to a reference rather than into `skills/writing-plans/SKILL.md` because
that file is at 486 lines against a 500-line ceiling
(`skills/writing-skills/anthropic-best-practices.md:1119`), and this
repository's [`CLAUDE.md`](../../../CLAUDE.md), section "Where the obvious
move is wrong", requires progressive disclosure rather than compression for a
body over the line.

Extraction at the third occurrence is this project's normal rule. The inversion
— "unified in place, never extracted" — governs forms inside a subagent's
`## Output Format` and does not reach here.

### The two questions

The statement asks, in this order:

1. Does the plan fit in one context window **with slack left for a correction
   round**?
2. Is there a **low-coupling boundary** between the tasks — a point where they
   stop sharing a file, an interface, or state?

And it carries the sentence the measurement makes sayable, which appears
nowhere in the plugin today: **a subagent is context-budget management, not a
quality technique.** The subagent path is currently sold on review-per-task and
on resumability; never on budget.

### What the agent declares, and what it does not

Measured (Finding 5): nothing in the plugin lets an agent read its own window
occupancy. The rule therefore does not ask it to. The offer declares what the
agent *can* measure from the plan — the task count it already reports
(`skills/writing-plans/SKILL.md:442-444`) plus the density, meaning how many
distinct files the tasks touch — and states plainly that the slack judgement
belongs to the human partner, who has the meter on screen.

### Coupling

Enters as content of two nodes that already exist; no new machinery.

- The `"Tasks mostly independent?"` node of the decision graph
  (`skills/subagent-driven-development/SKILL.md:79-80`) gains an operational
  definition: shared file, shared interface, shared state.
- The offer (`skills/writing-plans/SKILL.md:456-469`) names coupling, which it
  does not today.

### The evidence document

A new `docs/context-budget.md` records the measurement the rule rests on: the
scoreboard of the four configurations with grade, final window occupancy, token
spend and wall time; the decision rule; and — required, not optional — what the
measurement does **not** cover, naming the turning point and the cost curve
that its own author marks as unmeasured.

It is marked as a third-party measurement, never as this project's. Its sources
are named in text with no URL, because `docs/` is not exempt from the
third-party link diet ([`docs/docs-and-links.md`](../../docs-and-links.md),
section "The third-party link diet") and that diet allows four host
prefixes, none of which covers them.

### What does not change

No task grouping — one dispatch per task stands. The four review faces,
untouched. Both end-of-branch gates, untouched. No script and no reviewer
prompt changes.

## Acceptance Criteria

- **AC1** — `skills/writing-plans/references/execution-path.md` exists and
  states the criterion once.
- **AC2** — The statement presents the two decision questions in order: window
  fit with slack for a correction round, then low-coupling boundary.
- **AC3** — The statement contains the assertion that a subagent is
  context-budget management and not a quality technique.
- **AC4** — Each of `skills/writing-plans/SKILL.md`,
  `skills/executing-plans/SKILL.md` and
  `skills/subagent-driven-development/SKILL.md` reaches the criterion by a
  markdown link to that file, and none of them restates it.
- **AC5** — `grep -rn "one sitting" skills/` returns no occurrence that is
  serving as the decision criterion.
- **AC6** — The offer in `skills/writing-plans/SKILL.md` states that the slack
  judgement belongs to the human partner and that the agent does not observe
  its own window occupancy.
- **AC7** — The offer reports, for the plan in hand, the task count and the
  number of distinct files its tasks touch.
- **AC8** — The `"Tasks mostly independent?"` node of the decision graph in
  `skills/subagent-driven-development/SKILL.md` carries the operational
  definition of coupling: shared file, shared interface, or shared state.
- **AC9** — `docs/context-budget.md` exists and carries the scoreboard of the
  four configurations (1, 3, 7 and 18 workers), with grade, final window
  occupancy, token spend and wall time. A cell no source carries is left
  explicitly empty; no cell is estimated, interpolated, or filled by inference.
- **AC10** — `docs/context-budget.md` carries a section stating what the
  measurement does not cover, naming the single-to-multi turning point and the
  cost curve.
- **AC11** — `docs/context-budget.md` states that the measurement is a third
  party's and not this project's.
- **AC12** — `scripts/check-links.sh` passes with the new document present.
- **AC13** — `skills/writing-plans/SKILL.md` is at or under 500 lines after the
  change.
- **AC14** — `CHANGELOG.md` carries an `[Unreleased]` entry describing the
  change, staged in the same commit as the `skills/` change.
- **AC15** — Every figure in that scoreboard is marked either as corroborated
  by both artifacts or as carried by one, per the split recorded in
  `## Assumptions to Confirm` item 2.

## Implicit Requirements

- **IR1** — Where the harness has no subagents, the inline path remains the
  answer without the criterion being consulted; the new criterion does not
  introduce a state in which no path is selectable.
- **IR2** — The resumability difference measured 2026-08-04
  (`skills/writing-plans/SKILL.md:463-465`) survives in the offer. The budget
  criterion is added beside it, not in place of it.
- **IR3** — No rule introduced here requires an agent to read its own context
  window occupancy.
- **IR4** — `docs/context-budget.md` is not cited anywhere as a measurement of
  this project; every citation of it names the third party.
- **IR5** — No reviewer prompt and no script under `skills/*/scripts/` is
  modified.
- **IR6** — The existing gates stay green: `check-links.sh`,
  `check-changelog.sh`, `check-docs-sync.sh`, and the `SKILL.md` line ceiling.

## Codebase Findings

1. **The criterion is temporal, and it is the recommendation the human partner
   reads.** `skills/writing-plans/SKILL.md:467`:
   > "**Recommend: subagent-driven when the plan will not finish in one sitting, or when a task's context would crowd out the next one — roughly, more than a handful of tasks. Inline when the plan is short enough to finish now and you want it done in this conversation.**"

2. **It is replicated in eight occurrences across three files.** Measured
   2026-08-21 with `grep -rn "one sitting" skills/`:
   `skills/writing-plans/SKILL.md:444`, `:467`;
   `skills/executing-plans/SKILL.md:14`, `:63`;
   `skills/subagent-driven-development/SKILL.md:67`, `:76`, `:77`, `:78`.

3. **`writing-plans` is already the de facto owner of the offer.**
   `skills/executing-plans/SKILL.md:14`:
   > "superpowersplus:writing-plans makes that offer with the measured difference and writes the answer into the plan header's `**Execution:**` field."

4. **The controller of the subagent path already keeps its window near
   constant, by handing every artifact over as a file.**
   `skills/subagent-driven-development/SKILL.md:180-181`:
   > "prints back — stays resident in your context for the rest of the session / and is re-read on every later turn. Hand artifacts over as files."

   `skills/subagent-driven-development/SKILL.md:205-206`:
   > "the dispatch prompt. The implementer writes the full report there and / returns only status, commits, a one-line test summary, and concerns."

   `skills/subagent-driven-development/SKILL.md:254`:
   > "file). The output never enters your own context, and the reviewer sees"

   The controller reads the plan once — `skills/subagent-driven-development/SKILL.md:136`:
   > "Read the plan once, note its context and Global Constraints, and create a"

   This is why the task-grouping half of the original proposal is out of scope:
   the window the third-party measurement drives from 74% to 26% is not this
   controller's window.

5. **Nothing in the plugin gives an agent its own window occupancy.** Measured
   2026-08-21 with `grep -rn -iE "compact|token budget|context (limit|usage|meter|left)|remaining context" skills/`. Every
   hit treats compaction as an accomplished fact rather than an observable
   quantity — `skills/subagent-driven-development/SKILL.md:117`:
   > "Conversation memory does not survive compaction."

   and `skills/subagent-driven-development/references/resuming.md:11`:
   > "sequences. Conversation memory does not survive compaction. The ledger and"

   The only "Token budgets" heading in the repository,
   `skills/writing-skills/anthropic-best-practices.md:1117-1119`, is about the
   500-line `SKILL.md` ceiling:
   > "Keep SKILL.md body under 500 lines for optimal performance."

6. **Coupling is named only in a skill walled off from plan execution.**
   `skills/dispatching-parallel-agents/SKILL.md:18-20`:
   > "**This skill does not reach the tasks of a plan under execution.** There, / superpowersplus:subagent-driven-development governs, and its rule is / unconditional: never dispatch multiple implementation subagents in parallel."

7. **A defect inside an approved unit is still caught at the end of the
   branch.** `skills/final-branch-audit/SKILL.md:3`:
   > "audits every task one by one and proves each acceptance criterion with located evidence"

8. **`skills/writing-plans/SKILL.md` is at 486 lines against a 500-line
   ceiling.** Measured 2026-08-21 with `wc -l skills/*/SKILL.md`. This is why
   the canonical statement goes to `references/`.

9. **`docs/` is not exempt from the third-party link diet, and the allowlist
   has four prefixes.** [`docs/docs-and-links.md`](../../docs-and-links.md),
   section "The third-party link diet":
   > "Everything under `skills/` is exempt because a skill legitimately cites vendor documentation"

   — the exemption names `skills/`, not `docs/`.

10. **This project's plans do not live at the granularity the third-party
    measurement compared.** Measured 2026-08-21 over the 13 plans in
    `docs/superpowers/plans/`, counting task headings exactly as
    `skills/subagent-driven-development/scripts/task-brief:28-34` does —
    pattern `^#+[ \t]+Task[ \t]+[0-9]+`, **and skipping fenced blocks**, which
    that script does at line 29. The series is
    `0 4 4 5 5 5 7 7 7 8 8 10 23`: median 7 tasks, 11 of 13 at 8 or fewer, one
    outlier at 23 (`docs/superpowers/plans/2026-05-06-lift-drill-into-evals.md`).

    **The fence rule is not a detail, and omitting it changes the answer.**
    Three of these plans are plans about the SDD skill itself and quote
    `## Task N` headings inside fenced examples. Counted without the fence
    rule they read 9, 17 and 11 instead of 7, 5 and 8
    (`docs/superpowers/plans/2026-06-09-sdd-task-scoped-review-dispatch.md`,
    `docs/superpowers/plans/2026-07-06-sdd-plan-scoped-workspace.md`,
    `docs/superpowers/plans/2026-07-15-sdd-fix-loop-redesign.md`), which moves
    the "8 or fewer" count from 11 to 8. Any re-measurement of this finding
    must skip fences or it is measuring a different thing.

    One plan, `docs/superpowers/plans/2026-06-09-visual-companion-issues.md`,
    matches zero — it uses a different heading scheme and is a catalog, not a
    task plan.

## External Dependencies

None. This is a zero-dependency plugin and the change adds no library, API, or
service.

The third-party measurement the rule rests on is not a dependency of the code;
it is evidence recorded in `docs/context-budget.md`, and its provenance is
handled under `## Assumptions to Confirm` below.

## Assumptions to Confirm

1. **The benchmark's numbers are transcribed from the artifacts in `research/`,
   which are not under version control and which I could not independently
   reproduce.** Searched: `research/Aula — Sub-agents Benchmark
   (Fakeflix).excalidraw` (582 elements, text extracted with a JSON parse) and
   `research/Video Transcription Request - Google Gemini.pdf` (extracted with
   `pdftotext`). What could not be confirmed is the benchmark itself — the
   runs, the harness, and the scoring method are described in the artifacts and
   were not re-run. The document must therefore attribute rather than assert.

2. **The two artifacts are not two sources of equal weight, and treating them
   as such was an error caught in spec review.** The excalidraw is the
   benchmark author's own board and is the primary record: it alone carries the
   full scoreboard. The PDF is a Gemini-produced summary of a video which
   declares in its own opening that it is not a verbatim transcript. It
   corroborates part of the board and is silent on the rest.

   **Corroborated by both** — the 74% and 26% window occupancies, the 0.95,
   0.93 and 0.81 grades, the 43-minute and 18-minute times, the ~25M and ~10M
   token figures, and that the single-agent run took practically the same wall
   time as the sweet-spot configuration.

   **Carried by the excalidraw alone** — the single-agent run's 19 minutes and
   9M tokens, and the entire 7-worker configuration (35m · 15M · 0.90).

   The rule the design applies: a figure carried by one source may be recorded,
   but it is marked as such and never used to carry an argument in the prose.
   The first draft of this spec broke that rule by opening Problem 1 with the
   19-minute figure; the prose now uses only corroborated figures.

3. **Whether the human partner can in fact read a context meter is
   harness-dependent and was not verified per harness.** Searched:
   `skills/using-superpowers/references/` for the per-platform tool references.
   The offer must therefore ask rather than assume the number is on screen.

4. **The license status of the two third-party articles in `research/` was not
   checked.** This is why the design keeps them out of git and names the
   sources in text instead. If any excerpt beyond a named citation is ever
   wanted in `docs/`, the license question opens first.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved — scope was cut twice in the interview, first to criterion + coupling, then task grouping removed outright | AC1–AC8, and the "Out of scope" line in the header |
| Domain and data model | Clear — no entity, no persistence, no identity; the artifacts are markdown files already governed by existing gates | Finding 9 |
| Interaction flow | Resolved — the only flow is the offer to the human partner, and its error state is "the partner cannot see a meter" | AC6, Assumption 3 |
| Non-functional attributes | Resolved — the one non-functional constraint that binds is the 500-line ceiling, and it forced the reference-file design | AC13, Finding 8 |
| Integrations and external dependencies | Clear — zero-dependency plugin, nothing added | `## External Dependencies` |
| Edge cases and failures | Resolved — the harness-without-subagents case would otherwise become a state with no selectable path | IR1 |
| Constraints and tradeoffs | Resolved — the third-party link diet constrains the evidence document's form, and the line ceiling constrains where the statement lives | AC12, AC13, Finding 9 |
| Terminology | Resolved — "coupling" was undefined in the plugin and is given an operational definition rather than left to judgement | AC8 |
| Completion signals | Resolved — every AC above is settled by a grep, a line count, a file's existence, or a gate's exit code | AC5, AC12, AC13 |
| Placeholders and vague adjectives | Outstanding, low impact accepted — "slack for a correction round" is deliberately unquantified, because the turning point is the one figure the source measurement declares it did not measure. Quantifying it here would invent the number the evidence refuses to give | Assumption 1, AC10 |

### Decision record

| Question asked | Answer | Recommendation given | Declared source |
|---|---|---|---|
| Where do we start, given three located gaps? | Criterion + grouping (B+A) | B+A | The third-party scoreboard, before the fit analysis was run |
| What happens to the review gate when tasks are grouped? | One reviewer, one cluster verdict | One reviewer, verdict per task | `skills/subagent-driven-development/SKILL.md:242-301` — the existing per-task gate |
| What triggers grouping? | "What do the studies show?" — answered from the sources instead of chosen | The sources give a conjunction (window fit AND low-coupling boundary) and explicitly decline to give a threshold | The benchmark's own decision block and its "not validated" block |
| Does this improve the plugin? | Proceed with criterion + coupling; grouping dropped | Criterion has direct evidence; grouping does not, and costs a certain gate for an unproven gain | Findings 4 and 10 |
| How does the citation resolve, given the artifacts are untracked and 6.6M? | Summary in `docs/`, binaries stay out | Summary in `docs/` | [`docs/docs-and-links.md`](../../docs-and-links.md), section "The third-party link diet" |

**Two corrections made during the interview, recorded because an approval that
hides them is not auditable:** the first framing put task grouping in
`subagent-driven-development` as the primary gain, which Finding 4 contradicts;
and two of the four trigger options offered to the partner (a task-count
threshold, and reading the agent's own occupancy) had no support in any source,
which Finding 5 and the benchmark's own "not validated" block establish.
