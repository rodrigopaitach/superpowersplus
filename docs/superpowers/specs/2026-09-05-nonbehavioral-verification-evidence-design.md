# Non-behavioral verification evidence in the implementer's short status

**Route:** full process
**Date:** 2026-09-05
**Evidence model:** v2

## Problem

**The structural fact.** The implementer's mandatory short-status evidence slot
is framed as a test run, and it does not distinguish, per criterion, evidence
that the TDD process ran from evidence that the requirement was verified. A
criterion whose declared instrument is not a test has no admissible value for
that slot.

**What that allows.** A probe the implementer wrote to drive its own TDD cycle
can be reported there in place of the criterion's declared verification
instrument. Such a probe need not be that instrument and need not survive into
the commit, so the one line the controller reads before dispatching the reviewer
can name an artifact absent from the delivered tree.

**What was measured.** In the `structural` + `negative` production run
summarised under `## Measurement Background / Design Evidence`, that is what
happened: a TDD probe was reported in the short status although it was neither
the declared requirement instrument nor present in the delivered commit.

**The boundary is the criterion, not the task.** A task may carry criteria of
more than one class, so a rule gated on "this task has no `behavioral`
criterion" leaves the mixed case uncovered: one behavioural criterion would
route the whole status through the test-shaped slot and the other criteria's
declared instruments would never reach the controller.

The fix separates the two responsibilities, per criterion. It does not touch
the Iron Law and does not decide whether TDD applies to a `structural` task.

**Prior decisions checked:** the canonical `## Open gaps` sweep found no
existing decision governing non-behavioral short-status verification evidence.

**Out of scope**, each considered and left out rather than overlooked: changing
the universal TDD requirement, the Iron Law, or its three exceptions; deciding
that `structural` or `negative` criteria do not use TDD; promoting
*validator-as-TDD* into a rule; the seven files IR2 names; the separate finding
that the inline finishing status can omit the instruments behind its evidence;
the Verification Matrix and the 2–5 minute microstep rule; whether a temporary
TDD probe must be removed before DONE; Codex packager linked-worktree
compatibility, a separate follow-up; cutting any version or publishing any
release; editing historical behaviour records outside this change.

## Acceptance Criteria

AC1–AC9 are satisfied in
[`implementer-prompt.md`](../../../skills/subagent-driven-development/implementer-prompt.md);
AC10 and AC11 name their own file.

- **AC1** `[structural]` — **Criterion-level evidence routing.** The
  short-status contract resolves each criterion's requirement verification by
  *that* criterion's declared evidence class and instrument, rather than once
  for the task.
- **AC2** `[structural]` — **Mixed-class independence.** The presence of a
  `behavioral` criterion in a task does not change the criterion-level routing
  of that task's `structural` or `negative` criteria. (So they are not omitted,
  their declared instruments are not replaced by the task's test command, and
  they do not become behavioural evidence — three readings of the one
  invariant.)
- **AC3** `[structural]` — **Behavioral preservation.** For a `behavioral`
  criterion the existing contract is kept: the command verbatim, its exit code,
  and counts of passed/failed/skipped.
- **AC4** `[structural]` — **Declared instrument identity.** For a `structural`
  or `negative` criterion, the instrument reported is the one the brief
  declares, after the flow's ordinary placeholder substitutions and nothing
  else — never a wider check, a narrower check, a different check that would
  answer the same question, or another criterion's test command.
- **AC5** `[structural]` — **Non-behavioral command exit.** For a `structural`
  or `negative` criterion whose declared instrument is a command, the evidence
  line reports the real exit code of that instrument.
- **AC6** `[structural]` — **Non-behavioral counts field.** For that same
  criterion, `counts:` is exactly the literal `—` and nothing else.
- **AC7** `[structural]` — **Additional result placement.** Additional result
  information, when needed, is reported as prose outside the standardised
  `Command` / `exit` / `counts` evidence form, and does not introduce an
  additional chained evidence field.
- **AC8** `[structural]` — **Located structural evidence.** When a `structural`
  criterion is settled by located evidence, the short-status contract carries
  the smallest semantically sufficient located range.
- **AC9** `[structural]` — **TDD-probe separation.** A test or probe is not
  requirement verification *merely by having been the implementer's TDD
  evidence*; what occupies a criterion's verification slot is the instrument
  that criterion declares. Where the declared instrument is itself the test the
  TDD cycle ran, it serves both roles; what is forbidden is a probe **other
  than** the declared instrument occupying that slot.
- **AC10** `[structural]` — **Controller terminology.**
  [`subagent-driven-development/SKILL.md`](../../../skills/subagent-driven-development/SKILL.md)
  describes the implementer's relevant return as verification evidence or
  summary rather than a universal test summary.
- **AC11** `[structural]` — **Controller remains thin.** That file does not
  restate the detailed short-status evidence contract, which belongs to the
  implementer prompt: it names the kind of return, and the prompt stays the
  source of the format.

## Implicit Requirements

- **IR1** `[negative]` — **TDD remains untouched.** The diff does not alter the
  TDD Iron Law, its three exceptions, the full-report `TDD Evidence` section, or
  [`test-driven-development/SKILL.md`](../../../skills/test-driven-development/SKILL.md).
- **IR2** `[negative]` — **Sibling carriers stay outside.** These stay out of
  the diff: `task-reviewer-prompt.md`, `re-review-prompt.md`,
  `executing-plans/SKILL.md`, `writing-plans/SKILL.md`,
  `final-branch-audit/SKILL.md`, `docs/evidence-model.md`,
  `scripts/check-evidence-line.sh`. **If coherence turns out to require touching
  one, the work stops and the insufficiency is reported — it is not resolved by
  widening the diff.**
- **IR3** `[structural]` — **Versioned behavior record exists.** The delivery
  contains a `RESULT-*` under `tests/skill-behavior/` for this rule, following
  that directory's existing convention. Supporting files the convention requires
  are resolved by the plan under that same convention; this spec introduces no
  new one.
- **IR4** `[structural]` — **Per-run claims are truthful.** No run in that
  record is given a verdict for a criterion it did not measure — in particular,
  a run in which no reviewer was dispatched is not described as passing a
  reviewer criterion.
- **IR5** `[structural]` — **Measurement is not delivery evidence.** The record
  states that live-agent runs are measurement case studies and provenance, and
  do not substitute for the delivery instruments the final branch audit re-runs.
- **IR6** `[structural]` — **Version history truthfulness.**
  [`CHANGELOG.md`](../../../CHANGELOG.md), in the `## [Unreleased]` section
  created for this change, records only the scope actually delivered and does
  not state that sibling carriers were fixed.
- **IR7** `[negative]` — **No dependency or script surface added.** No
  dependency manifest, lockfile, or file under `scripts/` is added or modified
  by this change. *(The wider consequences — no external service, no licence, no
  runtime requirement — follow from that and from `## External Dependencies`;
  they are design consequences, not claims a filename-scoped command can
  settle.)*

## Codebase Findings

Every claim is a located range in this checkout at
`fc80701587525bd3714e2e33d68c70a2c1a046bb`. Block quotes reproduce the cited
range literally; where the source continues past the range, the claim is
paraphrased instead of quoted.

**The short-status evidence bullet is explicitly framed as `test evidence`** —
the framing AC1–AC7 answer.
`skills/subagent-driven-development/implementer-prompt.md:202`:

> `- The test evidence, one line, from the run you made after your last`

**The form that bullet prescribes is `Command` / `exit` / `counts`**, which is
what AC3 preserves and AC5–AC7 scope for the other classes.
`skills/subagent-driven-development/implementer-prompt.md:204-205`:

> `      **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/`
> `      failed/skipped]. A bare count ("6/6 green") does not say which`

**One task may carry criteria of more than one class** — why AC1 and AC2 are
scoped to the criterion. `skills/subagent-driven-development/task-reviewer-prompt.md:93`
opens with "**One task may mix classes**".

**The controller supplies a test command whenever *any* criterion is
behavioural** — the mechanism AC2 blocks from reaching the other criteria.
`skills/subagent-driven-development/SKILL.md:288-289` makes `[TEST_COMMAND]`
"required only when the task carries at least one `behavioral` criterion".

**The controller's description of the return is test-shaped** — what AC10
and AC11 correct. `skills/subagent-driven-development/SKILL.md:224`:

> `returns only status, commits, a one-line test summary, and concerns.`

**Both halves of what IR1 protects live in the same file and stay untouched:**
`skills/subagent-driven-development/implementer-prompt.md:51-52` states that
step 1 "is not conditional on the task asking for it" and names the Iron Law as
binding every task, and `:187` opens the full report's `TDD Evidence` section
with "every task carries it".

**A `structural` criterion may be settled by located ranges rather than a
command — the basis for AC8 — and a test is never invented to fill such a row —
the basis for AC4 and AC9.** `docs/evidence-model.md:136` and
`docs/evidence-model.md:139-140`:

> `| `structural` | A read-only validator command, or sufficient located ranges |`

> `**No criterion is left without a resolved instrument, and a test is never`
> `invented to fill a `structural` or `negative` row.**`

**Two siblings already handle the non-behavioral case in their own words — why
IR2 keeps them out rather than harmonising them.**
`skills/subagent-driven-development/task-reviewer-prompt.md:96` forbids
inventing a test file to give a `structural` or `negative` criterion something
to point at, and
`skills/subagent-driven-development/re-review-prompt.md:121-122` says that for
those classes the instrument is the read-only validator or command and that
`counts:` reads `—`.

**The gate ignores what is inside each field**, which is why AC6 can name the
literal `—` without touching the script. `scripts/check-evidence-line.sh:17-19`:

> `#   * Whether the text INSIDE each field makes sense for that carrier. It reads`
> `#     field names, never their content: `**exit:** [code]` and`
> `#     `**exit:** [the moon]` are identical to this check.`

**But the gate does compare the chained field names, which is what AC7 answers.**
It opens a form at each `**Command:**` and seeds the name list with `Command`,
`scripts/check-evidence-line.sh:85-86`:

> `    for start in re.finditer(r"\*\*Command:\*\*", norm):`
> `        names = ["Command"]`

and each further chained field is appended before the form becomes a tuple of
names, `scripts/check-evidence-line.sh:97-99`:

> `            names.append(nxt.group(1))`
> `            pos = nxt.end()`
> `        forms.append(tuple(names))`

More than one distinct tuple across the carriers is a failure,
`scripts/check-evidence-line.sh:121-126`, whose message reads "carriers disagree
on the evidence line's fields". So a fourth chained field — a `**Result:**`
appended to the form — would make the carriers disagree and fail the gate, which
would trip IR2's stop-the-work rule. Prose outside the form does not.

**`implementer-prompt.md` is one of that gate's declared carriers**, which is
why AC3 has to keep the historical form intact.
`scripts/check-evidence-line.sh:61-66` opens `CARRIERS = [` and reaches the entry
`"skills/subagent-driven-development/implementer-prompt.md",`.

**Measurement status is orthogonal to the delivery class** — why every criterion
here is `structural` or `negative` and none is `behavioral`.
`docs/evidence-model.md:50-51`:

> `Orthogonal to the class: a rule can be structurally delivered in the artifact`
> `and still never have been measured in execution.`

**Behaviour records are dated case studies, not a rate** — what IR5 encodes.
`tests/skill-behavior/README.md:299` calls them "dated case studies, not a
regression suite".

## Measurement Background / Design Evidence

Live-agent runs on throwaway fixtures motivated this change. **They are
measurement case studies and provenance, not delivery evidence** — the property
IR5 requires the record to state.

- A `structural`-only run over a documentation artifact delivered correctly and
  produced TDD-shaped narrative padding.
- A `structural` + `negative` run over production code reproduced the defect: a
  TDD probe was presented in the short status as the requirement's evidence, in
  a case where the probe was not in the delivered commit.
- Runs under the corrected contract reported the declared instruments.
- The sibling re-reviewer did **not** reproduce the defect.
- The sibling inline executor did **not** reproduce the same defect, and
  revealed a different possible follow-up.

These are case-study observations from live-agent runs, not a replicate series.
No frequency is claimed. The model tier used in a given run is a fact of that
run, not something the flow's model-selection reference determines by name.

## External Dependencies

None. No external service, licence, or runtime requirement is introduced.

## Assumptions to Confirm

None. Every claim in `## Codebase Findings` is a located range in this checkout;
the measurements above are declared non-evidence in their own section rather
than carried as fact.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | AC1–AC11 |
| Domain and data model | Clear | No data model — prose in two skill files |
| Interaction flow | Clear | One flow, implementer→controller; its empty case is AC6 |
| Non-functional attributes | Clear | No runtime, no data, no surface. Legibility of the report is the subject, and AC4–AC7 are it |
| Integrations and external dependencies, with their failure modes | Clear | None; IR7 charges the reachable half and `## External Dependencies` carries the rest |
| Edge cases and failures | Resolved | AC2 mixed class; AC6 the field with no admissible value; AC8 the criterion with no command; AC9 the probe that is not the instrument |
| Constraints and tradeoffs | Resolved | IR2, which stops the work rather than widening the diff |
| Terminology | Resolved | AC10 — "verification evidence" is the flow's existing term; AC11 keeps the detail in the prompt |
| Completion signals | Resolved | Every AC and IR carries a class and an admissible instrument |
| Placeholders and vague adjectives left unquantified | Resolved | AC6 quantifies the field as the literal `—`; IR2 names files, not "siblings" |

### Decision record

**Q1 — Per task or per criterion?** Recommendation: per criterion. Source: a
project pattern — `skills/subagent-driven-development/task-reviewer-prompt.md:93`
against `skills/subagent-driven-development/SKILL.md:288-289`, which supplies a
test command whenever any criterion is behavioural, so a per-task gate leaves
that combination uncovered. Partner decision: accepted; AC1 and AC2 are scoped
to the criterion.

**Q2 — Also correct the sibling carriers?** Recommendation: keep them out.
Source: a project pattern — `docs/review-scopes.md:3-5`, harmonizing the faces
"changes the reach of three gates at once" — plus two measurements in which
neither sibling reproduced the defect. Partner decision: accepted; IR2 lists
them.

**Q3 — `behavioral`, since the motivation is live-agent runs?** Recommendation:
`structural`. Source: a project pattern — `docs/evidence-model.md:50-51`: what
is delivered is the contract text, and whether an agent obeys it is measured
separately. Partner decision: accepted; no criterion here is `behavioral`.

**Q4 — The behaviour record as the source spec?** Recommendation: a source spec
of its own, with the record required by IR3. Source: a project pattern —
`skills/brainstorming/SKILL.md:243` heads the required spec sections, and
`:247-249` lists `## Problem`, `## Acceptance Criteria` and
`## Implicit Requirements`, which a `RESULT-*` does not carry. Partner decision:
accepted.

**Q5 — Which version?** Consequence of leaving it open: none for this spec — the
cut is a separate act with its own gates. Options: defer (no cost now), or name
a version (binds a release before the work lands). Recommendation: defer.
Source: a project pattern — [`CLAUDE.md`](../../../CLAUDE.md), section
"Versioning", which places the cut after the work lands. Partner decision:
defer; the release state is a declared boundary of this work.
