# Knowledge-to-skills traversal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowersplus:subagent-driven-development or superpowersplus:executing-plans to implement this plan task-by-task — the `**Execution:**` field below names which of the two this plan was handed to, and that is the one to follow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/2026-08-23-knowledge-to-skills-traversal-design.md`

**Goal:** Carry five measured defect classes into the four skill files that would catch them.

**Architecture:** Each rule lands in exactly one carrier, as prose — with one carve-out the spec itself makes: `AC4` names *both* document reviewers, so its rule is written into two files and nowhere else. Four go into reviewer prompt files, which carry no line ceiling; one goes into `writing-plans/SKILL.md`, which has six lines of headroom. No mechanical gate is added — the spec's `IR1` places these judgements with a reader, on measured grounds. One rule, `AC2`, gets an adversarial behaviour record, because this project already measured its "before" state.

**Tech Stack:** None added. Bash and the existing gate scripts, already in this repo — `scripts/check-skill-size.sh:26`, `scripts/check-links.sh`, `scripts/check-skill-behavior-records.sh`.

**Execution:** `inline` — chosen 2026-08-24, run in the session that wrote this plan. Progress: session todos (not persisted). If that session ended mid-plan, where things stood is rebuilt from `git log` on this branch and the unchecked steps below; the checkboxes here are not updated as it runs.

**Escalation shape** (detail and a worked example: `../../../skills/using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know.

## Global Constraints

- `skills/writing-plans/SKILL.md` is at 494 lines and the ceiling is 500 — `scripts/check-skill-size.sh:26`. If a rule does not fit, move the overflow into `skills/writing-plans/references/` behind a trigger; **never shorten an existing line to make room** (spec `IR7`).
- Each rule lands in exactly one carrier. A rule repeated across carriers is out of scope — this repository charges copied shapes with a gate, and none exists for these (spec `IR4`). **The one carve-out, made by the spec and not by this plan: `AC4` names both document reviewers, so its rule is written into `skills/writing-plans/plan-document-reviewer-prompt.md` and `skills/brainstorming/spec-document-reviewer-prompt.md`, and into no third file.** Task 3 is that rule; no other task may place a phrase in two carriers.
- No rule is added as a non-blocking advisory. A rule that cannot be stated precisely enough to block is not added (spec `IR2`).
- The four review faces in `docs/review-scopes.md` — task reviewer, code reviewer, re-review, final branch audit — are not touched (spec `IR3`).
- Every rule carries the measurement that motivated it as an anonymous session measurement: the effect and its size, never a path a reader outside this repository could not open (spec `AC6`).
- `CHANGELOG.md` is staged with every commit that touches `skills/` — enforced by `scripts/check-changelog.sh` in the pre-commit hook (spec `IR6`).
- "No rule added is enforced by `check-cross-references` or any other mechanical gate" — all five are judgements over prose (spec `IR1`). Operationally: no file under `scripts/` is added or modified, which Task 6 Step 4 measures.
- "Every citation this design introduces into a skill resolves, and `check-links.sh` stays green" (spec `IR5`). A pointer to a file of this repository is written as a markdown link, never in backticks — `check-links.sh` resolves link syntax and nothing else ([`CLAUDE.md`](../../../CLAUDE.md), section "Writing a reference").

## Test Coverage Matrix

**Conventions read from this repository, not imported.** Gate scripts are tested by `tests/hooks/test-check-*.sh`, each its own CI step. Behaviour of a skill rule is measured by an adversarial record in `tests/skill-behavior/`, whose well-formedness CI checks via `scripts/check-skill-behavior-records.sh` and which **CI never re-runs** — `tests/skill-behavior/README.md`, section "What CI does, and does not". There is no unit-test framework here; suites are bash scripts asserting on exit codes.

**Four criteria carry no automated test, and the spec declares it.** `AC1`, `AC3`, `AC4` and `AC5` add prose no gate reads. The spec's Coverage Map, row "Completion signals", states that every `AC` is settled "by opening the named file and reading the rule, or by running the named gate". They are marked `none — prose` below. `AC2` is the exception and carries the behaviour record, on the grounds in Task 5.

| Criterion | Spec criterion | Test type | Layer | Test |
|-----------|----------------|-----------|-------|------|
| T1.1 The replan rule is present and names what the `git log` finds | AC3 | none — prose | `skills/` | No test. Declared in the spec's Coverage Map, row "Completion signals" |
| T1.2 The rule carries its measurement, with no external path | AC6 | grep | — | Step 5 of Task 1: `grep -n '3 of 10' skills/writing-plans/SKILL.md` returns one line, and `grep -c 'knowledge/' skills/writing-plans/SKILL.md` returns 0 |
| T1.3 The file stays under the ceiling | AC7 | gate | `scripts/` | Step 6 of Task 1: `scripts/check-skill-size.sh` exits 0 |
| T1.4 No existing line was shortened to make room | IR7 | grep | — | Step 6 of Task 1: `git diff -U0 -- skills/writing-plans/SKILL.md` shows only added lines, no line both removed and re-added shorter |
| T2.1 A test asserting a value the plan's own implementation would not produce is charged | AC1 | none — prose | `skills/` | No test. Declared in the spec's Coverage Map, row "Completion signals" |
| T2.2 Two spec criteria that cannot both hold are charged | AC2 | behaviour | `tests/skill-behavior/` | `tests/skill-behavior/RESULT-criteria-read-in-pairs.md`, criterion 1 |
| T2.3 Both rules carry their measurement, with no external path | AC6 | grep | — | Step 6 of Task 2: `grep -c 'two rounds of adversarial' skills/writing-plans/plan-document-reviewer-prompt.md` returns 1, and `grep -c '\.claude/' skills/writing-plans/plan-document-reviewer-prompt.md` returns 0 |
| T3.1 A state change measured only at its target is charged, in both document reviewers | AC4 | none — prose | `skills/` | No test. Declared in the spec's Coverage Map, row "Completion signals" |
| T3.2 The four protected review faces are untouched | IR3 | grep | — | Step 5 of Task 3: `git diff --name-only` names neither `task-reviewer-prompt.md`, `code-reviewer.md`, `re-review-prompt.md` nor `final-branch-audit/SKILL.md` |
| T4.1 A reviewer finding about a measurable fact is reproduced before it is acted on | AC5 | none — prose | `skills/` | No test. Declared in the spec's Coverage Map, row "Completion signals" |
| T4.2 The rule states the cost of not reproducing | AC5 | grep | — | Step 5 of Task 4: `grep -n 'one file read' skills/receiving-code-review/SKILL.md` returns one line |
| T5.1 The fixture carries the contradiction and does not announce itself as a test | AC2 | behaviour | `tests/skill-behavior/` | `tests/skill-behavior/FIXTURE-contradicting-criteria.md`, checked by Step 3 of Task 5 |
| T5.2 The record is well formed | IR6 | gate | `scripts/` | Step 7 of Task 5: `scripts/check-skill-behavior-records.sh` exits 0 |
| T5.3 The reviewer catches the contradiction it previously missed | AC2 | behaviour | `tests/skill-behavior/` | `tests/skill-behavior/RESULT-criteria-read-in-pairs.md`, criterion 1 |
| T6.1 Every citation added resolves | IR5 | gate (regression guard — green at the branch point too) | `scripts/` | Step 3 of Task 6: `scripts/check-links.sh` exits 0 |
| T6.2 No rule was added as a non-blocking advisory | IR2 | grep | — | Step 3 of Task 6: every row added to a reviewer table reads `BLOCKING`, checked by `git diff` |
| T6.3 Each rule lands in exactly one carrier, `AC4` in its two | IR4 | grep | — | Step 4 of Task 6: `grep -rlc '68 catalogue measurements' skills/ \| wc -l` returns `2` — the two carriers `AC4` names — and every other rule's identifying phrase returns `1` |
| T6.4 No rule is enforced by a mechanical gate | IR1 | grep (regression guard — empty at the branch point too) | — | Step 4 of Task 6: `git diff main...HEAD --name-only -- scripts/` returns nothing |

---

## Task 1: The replan rule in `writing-plans`

**Spec criterion:** `AC3` — `writing-plans` instructs the author, before writing any task, to read the branch's own `git log` when the work is a replan.

**Files:**
- Modify: `skills/writing-plans/SKILL.md:21-24`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing. No later task depends on this one; it is first because it is the only task that can fail on the line ceiling, and finding that out early is worth more than ordering by topic.

**Acceptance criteria:**
- T1.1: The `## Scope Check` section instructs reading the branch's own `git log` when the work is a replan, and states what that finds — work from an earlier plan that survives in the branch and does not appear in a diff against the main branch — test: none, prose; settled by opening `skills/writing-plans/SKILL.md` and reading the section
- T1.2: The rule carries its measurement and names no path outside this repository — test: Step 5's two greps
- T1.3: `scripts/check-skill-size.sh` exits 0 — test: Step 6
- T1.4: No pre-existing line of that file was shortened — test: Step 6's diff read

- [ ] **Step 1: Record the starting line count**

Run: `wc -l skills/writing-plans/SKILL.md`
Expected: `494`

- [ ] **Step 2: Read the section you are about to extend**

Run: `sed -n '21,24p' skills/writing-plans/SKILL.md`
Expected: the `## Scope Check` heading and its paragraph about independent subsystems.

- [ ] **Step 3: Append the rule to that section**

Insert immediately after the existing `## Scope Check` paragraph, before the `## File Structure` heading:

```markdown
**If this is a replan, read the branch's own `git log` before writing a task.** Work from an earlier plan survives in the branch and does not show up in a diff against the main branch, so a task telling the implementer to build what is already built reads as new work to everyone downstream. Measured: 3 of 10 findings in one review were artifacts that already existed.
```

- [ ] **Step 4: Confirm the ceiling still holds**

Run: `wc -l skills/writing-plans/SKILL.md`
Expected: `497` or fewer. If it is 501 or more, stop and apply `IR7` — move the overflow into `skills/writing-plans/references/` behind a trigger, and do not shorten any existing line.

- [ ] **Step 5: Verify the measurement is present and carries no external path**

Run: `grep -n '3 of 10' skills/writing-plans/SKILL.md`
Expected: exactly one line, inside `## Scope Check`.

Run: `grep -c 'knowledge/' skills/writing-plans/SKILL.md`
Expected: `0`

- [ ] **Step 6: Run the ceiling gate and read the diff**

Run: `scripts/check-skill-size.sh`
Expected: exit 0.

Run: `git diff -U0 -- skills/writing-plans/SKILL.md`
Expected: added lines only. A line appearing as both removed and re-added shorter is an `IR7` violation — revert it.

- [ ] **Step 7: Write the changelog entry**

**`CHANGELOG.md` has no `## [Unreleased]` heading right now** — `1.19.1` was cut and the section was renamed with it. This task creates the whole pair, `## [Unreleased]` followed by `### Added`, between the `References below name them…` paragraph and `## [1.19.1] - 2026-08-22`. Tasks 2 to 5 add under the heading this step creates.

Add there:

```markdown
- **`writing-plans` now tells the author to read the branch's own `git log` when the work is a replan.** Work from an earlier plan survives in the branch and does not appear in a diff against the main branch, so a task telling the implementer to build what is already there reads as new work at every gate downstream. Measured: 3 of 10 findings in one review were artifacts that already existed.
```

- [ ] **Step 8: Commit**

```bash
git add skills/writing-plans/SKILL.md CHANGELOG.md
git commit -m "feat(writing-plans): read the branch's git log when replanning"
```

## Task 2: The two plan-contract rules

**Spec criterion:** `AC1` — the plan reviewer charges a step whose test asserts a value the implementation the same plan specifies would not produce; and `AC2` — it requires the spec's acceptance criteria to be read in pairs and charges a pair that cannot both hold.

**Files:**
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md:82-96`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the two blocking rows Task 5 measures. Task 5's record is written against the `AC2` row exactly as worded here — if the wording changes, the record's criterion changes with it.

**Acceptance criteria:**
- T2.1: The Plan Contract table carries a row charging a test whose asserted value contradicts the implementation the same plan specifies — test: none, prose; settled by opening the file and reading the row
- T2.2: The Plan Contract table carries a row charging two spec criteria that cannot both hold, and instructs reading them in pairs against neighbours touching the same field — test: `tests/skill-behavior/RESULT-criteria-read-in-pairs.md`, criterion 1
- T2.3: Both rows carry their measurement and name no path outside this repository — test: Step 6's two greps

- [ ] **Step 1: Read the table you are extending**

Run: `sed -n '82,83p' skills/writing-plans/plan-document-reviewer-prompt.md`
Expected: the `| Requirement | If it fails |` header and its separator, indented four spaces.

- [ ] **Step 2: Add the `AC1` row**

Append to the Plan Contract table, keeping the four-space indent every row in that block carries:

```markdown
    | No step's test asserts a value the implementation this plan specifies would not produce | BLOCKING — the two are independent statements about the same behaviour and each reads as correct alone. An implementer on a cheap model resolves the disagreement by changing the implementation to match the test, diverging from the spec in silence; it was caught by reading the implementer's report, not its status. Read each test's expected value against the formula or code the same task specifies |
```

- [ ] **Step 3: Add the `AC2` row**

Append immediately after:

```markdown
    | No two spec criteria this plan implements contradict each other | BLOCKING — read the spec's criteria in PAIRS, each against the neighbours that touch the same field, never one at a time. Measured: a pair where one refused a rule and the other taught an example that was that rule survived two rounds of adversarial spec review and surfaced only here, where criteria sit next to each other as code. A contradiction is the spec's to settle: report it, name both ids, and do not pick a reading |
```

- [ ] **Step 4: Confirm both rows are inside the table**

Run: `sed -n '/^    ## The Plan Contract/,/^    ###/p' skills/writing-plans/plan-document-reviewer-prompt.md | grep '^    | ' | tail -2`
Expected: exactly the two rows you just added, in the order you added them. The range ends at `^    ###`, the level-3 heading that follows the table; a range ending at `^    ## ` would run past it to the next level-2 heading and print unrelated prose.

- [ ] **Step 5: Confirm both are BLOCKING**

Run: `git diff -U0 -- skills/writing-plans/plan-document-reviewer-prompt.md | grep '^+' | grep -c 'BLOCKING'`
Expected: `2`

- [ ] **Step 6: Verify the measurements and the absence of external paths**

Run: `grep -c 'two rounds of adversarial' skills/writing-plans/plan-document-reviewer-prompt.md`
Expected: `1`

Run: `grep -c '\.claude/' skills/writing-plans/plan-document-reviewer-prompt.md`
Expected: `0`

- [ ] **Step 7: Write the changelog entry**

Add under `## [Unreleased]`, `### Added`:

```markdown
- **The plan reviewer charges two defects it could not see before.** A step whose test asserts a value the implementation the same plan specifies would not produce — two independent statements about one behaviour, each correct alone, which a cheap implementer settles by changing the implementation. And two spec criteria that cannot both hold: the reviewer now reads criteria in pairs, each against the neighbours touching the same field. Measured: such a pair survived two rounds of adversarial spec review and surfaced only while writing the plan.
```

- [ ] **Step 8: Commit**

```bash
git add skills/writing-plans/plan-document-reviewer-prompt.md CHANGELOG.md
git commit -m "feat(plan-reviewer): charge test-vs-implementation and contradicting criteria"
```

## Task 3: The reachability rule, in both document reviewers

**Spec criterion:** `AC4` — both document reviewers charge a change of state whose target is measured without asking whether whoever applies it can reach that state.

**Files:**
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md` (Plan Contract table, after Task 2's rows)
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md:77-90` (Groundedness table)
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: the Plan Contract table as Task 2 leaves it — this row goes after Task 2's two.
- Produces: nothing.

**Acceptance criteria:**
- T3.1: Both reviewers carry a row charging a state change measured only at its target — test: none, prose; settled by opening both files and reading the rows
- T3.2: No file among the four protected review faces is modified — test: Step 5's `git diff --name-only`

- [ ] **Step 1: Add the row to the plan reviewer**

Append to the Plan Contract table, after Task 2's rows:

```markdown
    | A task changing a permission, privilege, or system state states how the executor reaches it | BLOCKING — measuring that the target state is correct is not the same as establishing that whoever applies the change can get there. Measured: four independent review lenses and 68 catalogue measurements passed a defect where the target was right and nobody asked whether the applying role held the grant. The gap was one line |
```

- [ ] **Step 2: Read the spec reviewer's Groundedness table**

Run: `sed -n '77,78p' skills/brainstorming/spec-document-reviewer-prompt.md`
Expected: the `| Finding | Verdict |` header and its separator, indented four spaces.

- [ ] **Step 3: Add the row to the spec reviewer**

Append to that Groundedness table:

```markdown
    | A claim that a permission, privilege, or system state will be changed, with no statement of how the executor reaches it | BLOCKING — the target state being correct is a different claim from the change being applicable, and only the first is usually checked. Measured: four independent review lenses and 68 catalogue measurements passed a defect of exactly this shape |
```

- [ ] **Step 4: Confirm both rows landed inside their tables**

Run: `grep -c '68 catalogue measurements' skills/writing-plans/plan-document-reviewer-prompt.md skills/brainstorming/spec-document-reviewer-prompt.md`
Expected: `1` for each file.

- [ ] **Step 5: Confirm the four protected faces are untouched**

Run: `git diff --name-only`
Expected: names `skills/writing-plans/plan-document-reviewer-prompt.md`, `skills/brainstorming/spec-document-reviewer-prompt.md` and `CHANGELOG.md`, and none of `task-reviewer-prompt.md`, `code-reviewer.md`, `re-review-prompt.md`, `final-branch-audit/SKILL.md`.

- [ ] **Step 6: Write the changelog entry**

Add under `## [Unreleased]`, `### Added`:

```markdown
- **Both document reviewers now ask whether a state change can be applied, not only whether its target is right.** Measuring the target state and establishing that whoever applies the change can reach it are two claims, and only the first was ever checked. Measured: four independent review lenses and 68 catalogue measurements passed a defect of this shape; the gap was one line.
```

- [ ] **Step 7: Commit**

```bash
git add skills/writing-plans/plan-document-reviewer-prompt.md skills/brainstorming/spec-document-reviewer-prompt.md CHANGELOG.md
git commit -m "feat(reviewers): charge a state change with no path to reach it"
```

## Task 4: Reproducing a finding before acting on it

**Spec criterion:** `AC5` — `receiving-code-review` instructs that a reviewer finding about a gate, a test result or a measurable fact is reproduced before it is acted on, and states the cost of not doing so.

**Files:**
- Modify: `skills/receiving-code-review/SKILL.md:67-87`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing.

**Acceptance criteria:**
- T4.1: The `### From External Reviewers` section instructs reproducing a finding about a gate, a test result or a measurable fact before acting — test: none, prose; settled by opening the file and reading the section
- T4.2: The rule states the cost of not reproducing — test: Step 5's grep

- [ ] **Step 1: Read the section you are extending**

Run: `sed -n '67,72p' skills/receiving-code-review/SKILL.md`
Expected: the `### From External Reviewers` heading and the first lines under it.

- [ ] **Step 2: Add the rule at the end of that section**

Insert immediately before the next `##` heading:

```markdown
**A finding about a gate, a test result, or any measurable fact is reproduced before it is acted on.** Run the command yourself. A reviewer reading an artifact under a stale version convention reported three type errors with file, line and error code; running it again showed zero — the finding was an artifact of the review, formatted exactly like a real one. And when two reviewers assert opposite facts about the same code, the cost of settling it is one file read, not a judgement about which reviewer is more specialized.
```

- [ ] **Step 3: Confirm placement**

Run: `sed -n '/### From External Reviewers/,/^## /p' skills/receiving-code-review/SKILL.md | tail -3`
Expected: the new paragraph, last in the section.

- [ ] **Step 4: Confirm the ceiling is not at risk**

Run: `scripts/check-skill-size.sh`
Expected: exit 0.

- [ ] **Step 5: Verify the cost clause is present**

Run: `grep -n 'one file read' skills/receiving-code-review/SKILL.md`
Expected: exactly one line.

- [ ] **Step 6: Write the changelog entry**

Add under `## [Unreleased]`, `### Added`:

```markdown
- **`receiving-code-review` now says a finding about a measurable fact is reproduced before it is acted on.** Measured: a reviewer reading an artifact under a stale version convention reported three type errors with file, line and error code, and running it again showed zero. Separately, two reviewers asserted opposite facts about the same code — the cost of settling that is one file read.
```

- [ ] **Step 7: Commit**

```bash
git add skills/receiving-code-review/SKILL.md CHANGELOG.md
git commit -m "feat(receiving-code-review): reproduce a measurable finding before acting"
```

## Task 5: The adversarial record for the pairs rule

**Spec criterion:** `AC2` — the behaviour half. Task 2 wrote the rule; this task measures whether it changes what a reviewer does.

**Why this rule and not the other four:** its "before" state is already measured. During the review of the source spec, a Coverage Map row pointed at the wrong neighbouring item and **two rounds of adversarial spec review passed it** — the generic consistency rule was present and did not catch it. That is half of a two-state comparison, collected at no cost. The other four rules have no such "before", so a record of them would measure only the after.

**Files:**
- Create: `tests/skill-behavior/FIXTURE-contradicting-criteria-spec.md`
- Create: `tests/skill-behavior/FIXTURE-contradicting-criteria.md`
- Create: `tests/skill-behavior/RESULT-criteria-read-in-pairs.md`
- Modify: `tests/skill-behavior/README.md`
- Modify: `CHANGELOG.md`

**The fixture is two files, and the reason is a measurement.** The first
version was a single 37-line plan citing a spec path that did not exist. The
reviewer stopped at the Plan Contract row above the rule under test — "The
header cites a source spec path that exists and is committed" — and reported the
pairs check as *unverifiable rather than checked-and-passed*. Seven blocking
findings, none of them the contradiction: the instrument tripped a neighbouring
row and never exercised the mechanism. Both runs are recorded in
[`RESULT-criteria-read-in-pairs.md`](../../../tests/skill-behavior/RESULT-criteria-read-in-pairs.md);
the failed one is a finding about the rule's reach, not about the rule.

**Interfaces:**
- Consumes: the `AC2` row from Task 2, verbatim — the record's criterion quotes it.
- Produces: nothing.

**Acceptance criteria:**
- T5.1: The fixture carries two criteria that cannot both hold, and each fixture file's header sits above a `---` separator so the neutral copy can strip it — test: Step 3's greps
- T5.2: The record carries date, model, and a verdict per criterion — test: `scripts/check-skill-behavior-records.sh` at Step 7
- T5.3: The record states whether the reviewer caught the contradiction — test: the record itself, criterion 1

- [ ] **Step 1: Read the shape a fixture and a record take here**

Run: `sed -n '231,236p' tests/skill-behavior/README.md`
Expected: the "Adding a test" section — one directory entry per rule: a fixture, the input that carries it, and a `RESULT-*.md` with date, model, criteria and the full agent report.

- [ ] **Step 2: Write the two fixture files**

Each opens with a `# Test fixture — …` header explaining itself, then a `---`
separator, then the artifact. The header is what `sed '1,/^---$/d'` strips, so
the subagent never learns it is being measured.

`tests/skill-behavior/FIXTURE-contradicting-criteria-spec.md` carries the spec:
five acceptance criteria and one implicit requirement, where **`AC2` — "A digest
is sent only when there is at least one unread item" — and `AC5` — "Every
subscribed user receives exactly one digest per day, including days with no
activity" — touch one field and cannot both hold.** Nothing in it says so. The
other four criteria are neighbours that do not conflict.

`tests/skill-behavior/FIXTURE-contradicting-criteria.md` carries the plan, and
it is **complete on purpose**: it cites the committed spec, covers every `AC`
and `IR`, labels its own criteria `T<task>.<n>`, carries a five-column Test
Coverage Matrix whose every row names a test its steps actually write, and
carries **no** test asserting a value its own implementation would not produce.
Planting that second defect would make the verdict ambiguous — two defects, one
report, and no way to say which rule fired. The contradiction is the only defect
a reviewer can find.

- [ ] **Step 3: Confirm both fixtures are strippable and self-labelled**

Run: `for f in tests/skill-behavior/FIXTURE-contradicting-criteria*.md; do grep -n -m1 '^---$' "$f"; done`
Expected: a line number below 12 for each — the header block sits above it.

Run: `grep -lc 'test fixture' tests/skill-behavior/FIXTURE-contradicting-criteria*.md | wc -l`
Expected: `2`

- [ ] **Step 4: Build the throwaway repository outside this one**

The spec has to be **committed** where the reviewer will look for it, or the
Plan Contract row above the rule fires first and the measurement is lost. That
is what run 1 proved.

```bash
rm -rf /tmp/skill-behavior-run
mkdir -p /tmp/skill-behavior-run/docs/superpowers/{specs,plans}
sed '1,/^---$/d' tests/skill-behavior/FIXTURE-contradicting-criteria-spec.md \
  > /tmp/skill-behavior-run/docs/superpowers/specs/2026-08-24-digest-design.md
sed '1,/^---$/d' tests/skill-behavior/FIXTURE-contradicting-criteria.md \
  > /tmp/skill-behavior-run/docs/superpowers/plans/2026-08-24-digest.md
git -C /tmp/skill-behavior-run init -q .
git -C /tmp/skill-behavior-run add -A
git -C /tmp/skill-behavior-run commit -q -m "spec and plan"
git -C /tmp/skill-behavior-run log -1 --format=%h -- docs/superpowers/specs/2026-08-24-digest-design.md
```
Expected: a commit hash on the last line. An empty line means the spec is not committed and the run will measure the wrong thing.

- [ ] **Step 5: Run the measurement**

Dispatch one subagent with the contents of `skills/writing-plans/plan-document-reviewer-prompt.md`, `[PLAN_FILE_PATH]` set to `/tmp/skill-behavior-run/docs/superpowers/plans/2026-08-24-digest.md`, `[ROUND]` set to `1`, and **one operational line naming `/tmp/skill-behavior-run` as the repository root** — run 1 resolved relative paths against the wrong repository, and that ambiguity is not what is under test. No other framing. Record the model used, and record that line in the result so the dispatch can be reproduced.

- [ ] **Step 6: Write the record**

Copy the shape of [`RESULT-main-branch-consent.md`](../../../tests/skill-behavior/RESULT-main-branch-consent.md) — `scripts/check-skill-behavior-records.sh:36-38` requires exactly three rows, `| **Date** |`, `| **Model** |` and `| **Verdict** |`, and Step 7 fails without them; the `| **Rule under test** |` row (in all 8 existing records) and the `| **Fixture** |` row (in 4 of the 8) are convention, not gate — write both anyway.

Create `tests/skill-behavior/RESULT-criteria-read-in-pairs.md` with the date, the model, and a verdict per criterion:

1. Reports that `AC2` and `AC5` cannot both hold, naming both ids.
2. Does not pick a reading — routes the contradiction back rather than resolving it.
3. Reaches the finding by reading criteria against each other, not by noticing a broken citation.

Record a failure the same way. A rule measured and found not to hold is the finding.

- [ ] **Step 7: Check the record is well formed**

Run: `scripts/check-skill-behavior-records.sh`
Expected: exit 0.

- [ ] **Step 8: Add the directory entry to the README**

Add a `###` section under `## Tests in this directory`, in the shape the existing five use: the rule under test, the file table, and what approval requires.

- [ ] **Step 9: Write the changelog entry and commit**

Add under `## [Unreleased]`, `### Added`, then:

```bash
git add tests/skill-behavior/FIXTURE-contradicting-criteria.md tests/skill-behavior/RESULT-criteria-read-in-pairs.md tests/skill-behavior/README.md CHANGELOG.md
git commit -m "test(skill-behavior): measure whether the pairs rule changes the reviewer"
```

## Task 6: The cross-cutting checks

**Spec criterion:** `IR1`, `IR2`, `IR4`, `IR5` — the constraints that can only be checked once every rule is in place.

**Files:**
- Modify: `CHANGELOG.md` (only if a check finds something)

**Interfaces:**
- Consumes: every file Tasks 1–5 touched.
- Produces: nothing.

**Acceptance criteria:**
- T6.1: `scripts/check-links.sh` exits 0 — test: Step 3
- T6.2: Every reviewer row added reads `BLOCKING` — test: Step 3's diff read
- T6.3: Each of the five rules' identifying phrases appears in exactly one file under `skills/`, except `AC4`'s, which appears in the two document reviewers the spec names and in no third file — test: Step 4's two greps, one per case
- T6.4: No file under `scripts/` was added or modified — test: Step 4

- [ ] **Step 1: Confirm the branch is clean**

Run: `git status --short`
Expected: empty.

- [ ] **Step 2: Read the whole diff of the branch**

Run: `git diff main...HEAD --stat`
Expected: `skills/writing-plans/SKILL.md`, `skills/writing-plans/plan-document-reviewer-prompt.md`, `skills/brainstorming/spec-document-reviewer-prompt.md`, `skills/receiving-code-review/SKILL.md`, two files under `tests/skill-behavior/`, `tests/skill-behavior/README.md`, `CHANGELOG.md`, and the spec and this plan.

- [ ] **Step 3: Run the link gate and confirm no advisory rows**

Run: `scripts/check-links.sh`
Expected: exit 0.

Run: `git diff main...HEAD -- skills/ | grep '^+.*| BLOCKING' | wc -l`
Expected: `4` — one row for `AC1`, one for `AC2`, two for `AC4`.

- [ ] **Step 4: Confirm single-carrier and no gate added**

Run: `grep -rl '68 catalogue measurements' skills/ | wc -l`
Expected: `2` — `AC4` is the one rule the spec places in two reviewers.

Run: `for ph in '3 of 10' 'diverging from the spec in silence' 'two rounds of adversarial' 'one file read'; do printf '%s: ' "$ph"; grep -rl "$ph" skills/ | wc -l; done`
Expected: `1` for each — the identifying phrase of `AC3`, `AC1`, `AC2` and `AC5` in turn. Each of the four was measured absent from `skills/` before Task 1 ran, so a `1` here is the rule this branch wrote and not one already there.

Run: `git diff main...HEAD --name-only -- scripts/`
Expected: empty. **A regression guard, not a discriminator** — it is empty whether or not the plan was implemented, because no task ever touches `scripts/`. It is here to catch a hand reaching for a gate, which is what `IR1` forbids.

- [ ] **Step 5: Run the content gates whose input this branch changed**

There is no aggregate runner here — `.github/workflows/ci.yml:138-188` invokes each script as its own step. Two gates in that range are deliberately outside the loop: `scripts/lint-shell.sh`, covered by the separate `Run:` at the end of this step, and `scripts/check-changelog.sh`, which reads `git diff --cached` and so has nothing to say in a task that stages nothing — the pre-commit hook already charged it on each of Tasks 1 to 5. `tests/hooks/test-check-*.sh` are absent for a different reason: they test the gate scripts, and `IR1` forbids touching those.

**All eight are regression guards.** Every one exits 0 at the branch point too; they prove the change broke nothing, never that it did something. What this plan built is measured by the phrase greps in Step 4 and by Task 5's record.

Run: `for g in check-links check-skill-size check-evidence-line check-escalation-shape check-no-dispatch check-skill-behavior-records check-docs-sync check-frozen-history; do scripts/$g.sh || echo "FAILED: $g"; done`
Expected: no line starting with `FAILED:`.

Run: `bash tests/shell-lint/test-lint-shell.sh`
Expected: exit 0.

- [ ] **Step 6: Commit only if a check found something**

If every check passed, there is nothing to commit and this task ends. If one failed, fix it, and commit the fix with the check that found it named in the message.
