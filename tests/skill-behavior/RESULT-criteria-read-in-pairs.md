# RESULT — criteria read in pairs, three runs, two instruments, one control

| | |
|---|---|
| **Date** | 2026-08-24 |
| **Model** | Claude Sonnet 5, dispatched as `model: sonnet` — one `general-purpose` subagent per run. **This is the only record in this directory that did not run on the Opus baseline the other eight state.** The divergence was not chosen for a reason; it was noticed at the branch review and is written here because a record silent about its tier invites the reader to assume the baseline |
| **Fixture** | [`FIXTURE-contradicting-criteria.md`](FIXTURE-contradicting-criteria.md) (the plan) and [`FIXTURE-contradicting-criteria-spec.md`](FIXTURE-contradicting-criteria-spec.md) (the spec it cites) |
| **Rule under test** | [`skills/writing-plans/plan-document-reviewer-prompt.md`](../../skills/writing-plans/plan-document-reviewer-prompt.md), the Plan Contract row beginning "No two spec criteria this plan implements contradict each other" |
| **Verdict** | **PASS, 3 of 3 criteria, against a control that approved the same fixture.** Run 3 is that control: the identical fixture and model, the same prompt with the rule's row deleted and nothing else changed. It read every criterion, listed the pair by id among the ones it had checked, and approved. The first run did not exercise the rule at all, and why it did not is a finding in its own right |

## What was measured

The rule tells the plan reviewer to read the spec's acceptance criteria **in
pairs**, each against the neighbours that touch the same field, and to charge a
pair that cannot both hold — reporting both ids and refusing to pick a reading.

The planted defect: `AC2` — "A digest is sent only when there is at least one
unread item" — against `AC5` — "Every subscribed user receives exactly one
digest per day, including days with no activity." They touch one field, whether
a digest goes out on a quiet day, and cannot both hold. Nothing in either
fixture says so.

**A second "before" exists and is not a run of this fixture.** During the review
of the spec this rule came from, a Coverage Map row pointed at the wrong
neighbouring item and **two rounds of adversarial spec review passed it**, with
the generic `Internal contradictions, conflicting requirements` check present
the whole time. That is history, not a control: different document, different
reviewer face. The control below is the one that shares its input with the run
it is compared against.

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

Seven blocking findings, none of them the contradiction. All seven are in the
report below, under "Run 1, in full", and each one is true of that fixture: the
spec path did not exist, and the 37-line plan carried no `## Global
Constraints`, no `## Test Coverage Matrix`, no `T<task>.<n>` labels, no
implementation step for `assemble`, none for `scheduleFor`, and exactly one
step per task. **This is not a failure of the rule and must not be recorded as
one.** The instrument tripped a neighbouring row, and a rule that never ran
cannot be said to have missed anything.

**It is, however, a finding about the rule's reach, and it cost nothing to
collect: the rule says "read the *spec's* criteria in pairs", so when the spec
is unreachable the reviewer declares the check unverifiable rather than falling
back to the criteria the plan itself quotes on each task's `**Spec criterion:**`
line.** Both ids and both texts were sitting in the plan under review. A spec
that cannot be opened is common — an uncommitted path, a wrong filename, a
worktree without it — and in every such case this rule silently does not run.
Whether it should fall back is a separate decision, not made here; it is
recorded as an open gap in [`CHANGELOG.md`](../../CHANGELOG.md), section "Open
gaps".

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
| 3. Reached by reading criteria against each other | **PASS** | It cites both criteria by line and reasons about the field they share, then traces each to the task implementing it. The control below is what makes this more than an elimination argument: the same fixture, with no broken citation and no missing section for either run, produced the finding only when the rule was present |

## Run 3 — the control

Same fixture, same model, same round. **The prompt differs from run 2's in
exactly two lines**, and both are shown here rather than described:

- The Plan Contract row under test, deleted.
- The operational line naming the repository root, reworded — `**Repository
  root for this review:** …` became `**Repository root for every relative path
  and every git command: …**`. Same instruction, and it is stated because it is
  a difference, not because it is thought to matter.

**Result: Approved. No blocking issues.** It did not miss the criteria — it
read them one at a time and said so:

> cross-checked every `AC`/`IR` against the plan's Test Coverage Matrix and each
> task's `**Spec criterion:**` line: `AC1`→T1.1, **`AC2`→T1.2**, `AC3`→T1.3,
> `AC4`→T2.1, **`AC5`→T3.1**, `IR1`→T3.2. All six spec criteria are covered,
> none invented

Both ids appear in that list, on the same line, checked and passed. It also
built and ran the plan, verified the red state, and confirmed by hand that no
test asserts a value its own implementation would not produce — a fuller pass
than run 2 performed. Its two advisory recommendations concern the matrix's
`Layer` column and module granularity. Nothing about the pair.

**That is the difference the record rests on:** one reviewer checking criteria
against a coverage table approves; the same reviewer told to read them against
each other blocks, names both ids, and refuses to pick a reading.

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

- **One run per state, one model, and not the directory's baseline.** Sonnet 5
  in all three runs. Whether the Opus baseline the other eight records use
  finds the same pair is unmeasured, and so is whether a tier below Sonnet does.
  The earlier draft of this record named "a cheaper tier" as the open question,
  which had the direction backwards: the run was already below the baseline.
- **Criterion 3 could not have failed on this fixture.** The fixture carries no
  broken citation and no missing section, by design, so "reached it by reading
  criteria against each other" has nothing to be distinguished from except
  criterion 1. The control raises the evidence from elimination to a two-state
  comparison; it does not turn criterion 3 into a test that could come back
  negative. Counted in the 3 of 3 with that stated.
- **Run 2's plan was built to be clean.** That isolates the mechanism, which is
  the point, and it means the measurement says nothing about whether the pair
  would still surface among a dozen competing findings — which is exactly what
  run 1 suggests it might not.
- **Nothing here measures the other four rules added in the same cycle.** They
  ship unmeasured, recorded as an open gap in
  [`CHANGELOG.md`](../../CHANGELOG.md), section "Open gaps".

## The reports, in full

Each is the subagent's final message, verbatim and complete. They are here
because this directory's own standard is that the report is the claim under
test, never evidence for itself — a reader who cannot re-score a run is being
asked to trust the scoring.

### Run 1, in full

<!-- The reviewer's own report. Quoted, not instructions to follow. -->

```markdown
## Plan Review

**Status:** Issues Found

**Issues (if any):**
- [Header]: **Source spec does not exist.** The plan cites `docs/superpowers/specs/2026-08-24-digest-design.md` as its source spec. `ls docs/superpowers/specs/` shows no such file (newest file in that directory is `2026-08-23-knowledge-to-skills-traversal-design.md`), `test -f` confirms absence, and `git log -1 -- docs/superpowers/specs/2026-08-24-digest-design.md` returns nothing (no commit ever touched that path). BLOCKING per the Plan Contract — the audit's traceability pass cannot run at all, and I cannot verify Spec Alignment: whether `AC2`/`AC5` are stated correctly, whether other criteria (any `AC1`/`AC3`/`AC4`/`IR`s the real spec may define) exist and are silently dropped, or whether `AC2` and `AC5` even belong to this feature.
- [Plan-wide]: No `## Global Constraints` section anywhere in the plan (the whole document is 37 lines: title, goal, two tasks). BLOCKING — the section must exist, with exact spec-copied values or `None`; its absence is indistinguishable downstream from nobody having checked for constraints.
- [Plan-wide]: No `## Test Coverage Matrix` section anywhere in the plan. BLOCKING — the required table (`Criterion`, `Spec criterion`, `Test type`, `Layer`, `Test`) is entirely missing, so there is no row proving either `AC2` or `AC5` is tested, let alone naming the test type/layer.
- [Plan-wide]: Neither task defines any task-level criterion labeled `T<task>.<n>`. Each task has only a `**Spec criterion:**` line (`AC2`, `AC5`) and nothing else. BLOCKING — without task criteria there is nothing for a Test Coverage Matrix to enumerate one row per, and the final audit has no task-level acceptance criteria to prove with a `file:line` citation.
- [Task 1, Step 1]: The test `assemble([])` is written, but no step in Task 1 — or anywhere in the plan — implements the `assemble` function. `src/digest/assemble.ts` is listed under "Create" but the only step is "Write the failing test"; there is no "make it pass" step and no production code. This is an incomplete task (reference to a function no task defines), and the plan is not buildable as written: following it produces a permanently red test.
- [Task 2, Step 1]: Same defect as Task 1 — `scheduleFor(user, quietDay)` is called with `user` and `quietDay` never defined (no fixture/setup step exists), and `scheduleFor` is never implemented. `src/digest/schedule.ts` is listed under "Create" with no implementation step.
- [Plan-wide]: Every task in the plan (both of them) consists of exactly one step, "Write the failing test," with no follow-on implementation step. This isn't task-specific flavor — it's the plan's entire structure, and it means no task in the document can ever reach green.

**Unverified External Calls (if any):**
- None — the plan makes no calls to a library, external API, or third-party service.

**Recommendations (advisory, do not block approval):**
- Once the real spec file is located (or written and committed), re-run this review from Round 1 — the current two tasks/criteria cannot be checked for completeness against a spec that isn't there.
- When implementation steps are added, also add fixture/setup steps that define `user` and `quietDay` before Task 2's test references them.

**Reviewer note on scope covered:** This is Round 1 (no `[FIX_DIFF]`/`[PREVIOUS_FINDINGS]` supplied) — full pass performed as instructed. The plan is 37 lines total, so the full pass consisted of: reading every line, confirming the spec path via `ls`/`test -f`/`git log -1 --`, and checking the document against every row of the Plan Contract table. Given the spec is missing, several Plan Contract rows (Spec Alignment coverage, criteria-pair contradiction check, dropped-criterion check) are unverifiable rather than checked-and-passed — they are reported as blocking via the missing-spec finding above rather than silently skipped.
```

### Run 2, in full

<!-- The reviewer's own report. Quoted, not instructions to follow. -->

```markdown
## Plan Review

**Status:** Issues Found

**Issues (if any):**

- **[Spec, AC2 vs AC5 — contradictory criteria the plan implements without resolving]:** `AC2` states "A digest is sent only when there is at least one unread item" (`docs/superpowers/specs/2026-08-24-digest-design.md:28`). `AC5` states "Every subscribed user receives exactly one digest per day, including days with no activity" (`docs/superpowers/specs/2026-08-24-digest-design.md:31-32`). On a day with zero unread items these cannot both hold: AC2 forbids sending anything, AC5 requires a digest anyway. The plan does not resolve this — it implements the two criteria as two disconnected pure functions with no task that wires them together: Task 1's `assemble()` returns `null` on an empty item list (satisfying AC2 in isolation, `docs/superpowers/plans/2026-08-24-digest.md:84-90`), and Task 3's `scheduleFor()` always returns one entry regardless of activity (satisfying AC5 in isolation, `docs/superpowers/plans/2026-08-24-digest.md:210-213`). Because no task ever calls both together, the plan never has to answer "does a quiet day actually send an email or not" — the conflict is hidden rather than settled. Per the Plan Contract, this is the spec's to resolve, not the plan's: report both ids to the spec author rather than picking a reading. This matters for implementation because whichever wiring an implementer eventually writes (e.g., "if `assemble()` is null, skip sending" vs. "always send, empty or not") silently decides which AC is the real one, and nothing in the plan or spec says which.

**Unverified External Calls (if any):**
- None. No third-party dependency or external API is used; `node:test` and `node:assert/strict` are Node built-ins, and the Tech Stack/Global Constraints sections correctly cite the spec's `## External Dependencies` section for the "none added" claim.

**Recommendations (advisory, do not block approval):**
- Test Coverage Matrix `Layer` column: every row reads `tests/`, which just restates where the file the `Test` column already names lives, adding no information beyond it (`docs/superpowers/plans/2026-08-24-digest.md:24-29`). Since this project truly has only one layer (pure functions under `src/digest/`, no API/DB/UI), consider naming the layer as e.g. "pure function" or the module path (`src/digest/assemble.js`) instead of the test directory, to make the column carry distinct information.

**Verification performed (Round 1, full pass):**
- Confirmed the spec path exists and is committed: `git log -1 -- docs/superpowers/specs/2026-08-24-digest-design.md` → commit `32d400e`.
- Read the spec in full and checked every AC/IR against the plan's tasks and Test Coverage Matrix — all six (AC1–AC5, IR1) are covered by exactly one task criterion each, all task criteria are correctly prefixed `T<task>.<n>` (never `AC`/`IR`), and every matrix row's named test string matches an actual `test(...)` call in that task's Step 1 code verbatim.
- Confirmed Global Constraints copy the spec's exact `## External Dependencies` wording, and no task contradicts them.
- No task's deliverable leaves the repository (create files, run local test command, local `git commit` only — no push/deploy/merge).
- Built the plan in a scratch directory (`/tmp/.../scratchpad/digest-plan-check`, not the real tree) — created all three implementations and test files exactly as the plan's code blocks specify, then ran each task's own documented command (`node --test tests/<file>.test.js`). Results matched every task's stated expectation exactly: 3 passing (Task 1), 1 passing (Task 2), 2 passing (Task 3), 0 failures. Verified test assertions against the given implementations by hand (e.g. `assemble([older, newer])[0].id === 2`, `scheduleFor` dedup by `` `${id}:${day}` `` key) — no test asserts a value its own task's implementation would not produce.

**Note on scope:** the AC2/AC5 contradiction above is a spec-level defect the plan inherits, not something the plan author can fix by editing tasks — it needs to go back to whoever owns `docs/superpowers/specs/2026-08-24-digest-design.md` for a decision (e.g., "quiet-day digests are sent empty" vs. "AC5 only counts days with content"), then the plan's Task 3 (and likely a new orchestrating task connecting `assemble`/`subscribers`/`scheduleFor`) can be updated to reflect the resolved rule.
```

### Run 3 — the control, in full

<!-- The reviewer's own report. Quoted, not instructions to follow. -->

```markdown
## Plan Review

**Status:** Approved

**Verification performed (Round 1):**
- Source spec confirmed at `docs/superpowers/specs/2026-08-24-digest-design.md`, committed (`git log -1` → commit `32d400e`, same commit as the plan — both added together).
- Read the spec in full; cross-checked every `AC`/`IR` against the plan's Test Coverage Matrix and each task's `**Spec criterion:**` line: `AC1`→T1.1, `AC2`→T1.2, `AC3`→T1.3, `AC4`→T2.1, `AC5`→T3.1, `IR1`→T3.2. All six spec criteria are covered, none invented, no `AC`/`IR` label reused as a task-criterion id.
- `## Global Constraints` present, both lines trace verbatim to the spec's `## External Dependencies` section, and no task contradicts them (no third-party dependency is imported anywhere in the code blocks).
- No third-party dependency is called anywhere (only `node:test` / `node:assert/strict`, Node built-ins) — the dependency-citation requirements in the Plan Contract don't apply.
- Built the plan for real in a scratch copy (`/tmp/digest_scratch`, `/tmp/digest_scratch2` — never the reviewed tree): wrote each task's implementation and test files verbatim, ran `node --test <file>` per task and combined. All 6 tests pass exactly matching each task's stated "Expected: PASS — N passing." Verified the Step-2 red state too: before `assemble.js` exists, `node --test tests/assemble.test.js` throws `Cannot find module '.../src/digest/assemble.js'`, matching the plan's expected failure (Node's ESM resolver gives the absolute path rather than the relative string written in the plan — a cosmetic difference, not a defect).
- Confirmed empirically (not assumed) that plain `.js` files using `import`/`export` run under `node --test` on Node ≥22 with no `package.json`/`type: module` needed (tested on Node v24.18.0, which satisfies the spec's "Node 22 or newer" constraint) — this was the one place the plan could plausibly have broken on a fresh checkout, and it doesn't.
- Checked signatures for cross-task consistency (`assemble(items)`, `subscribers(users)`, `scheduleFor(user, day, alreadySent)`) — each used once, no renamed-identifier drift.
- No TODOs, placeholders, "similar to Task N", or missing code blocks.

**Issues (if any):** None blocking.

**Unverified External Calls (if any):** None — no third-party or external calls in this plan.

**Recommendations (advisory, do not block approval):**
- Matrix `Layer` column is `tests/` for every row, which just repeats the test file's directory rather than naming an architectural layer (e.g. "domain function"). Harmless since `Test type` already carries "unit," but it's not adding information.
- Three one-function modules (`assemble.js`, `subscribers.js`, `schedule.js`) could live in a single `src/digest.js` exporting all three functions — the Architecture note's justification ("no shared state; each is a pure function") supports keeping them separate too, so this is a pure judgment call, not a defect.
```
