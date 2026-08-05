# Changelog

All notable changes to this project are documented here. The format follows
Keep a Changelog 1.1.0, and this project adheres to Semantic Versioning 2.0.0.

**Upstream base:** [`44c9b2d`](https://github.com/obra/superpowers/commit/44c9b2d) (2026-07-27) — the last Superpowers commit incorporated. Update this line at every rebase; it replaces the mirrored upstream `version` this project used before `1.0.0`.

The 34 `plus.N` entries that led to `1.0.0` are preserved verbatim in
[`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md) (in Portuguese).
References below name them so a claim here can be traced there.

## [Unreleased]

### Added

- **The inline path runs a whole-branch code review before it hands off.**
  `requesting-code-review` declares itself mandatory "Before merge to main"
  (`skills/requesting-code-review/SKILL.md:17`) and the inline path invoked it
  from nowhere — measured over `skills/`: `executing-plans/SKILL.md` named
  neither it, nor `receiving-code-review`, nor
  `verification-before-completion`. A gate declared mandatory with no consumer,
  the same defect as the orphaned `**Execution:**` field and the orphaned
  `receiving-code-review`, and wiring it in was the right answer both times.
  Step 3 is now **Audit and Review the Branch**: two gates in a fixed order —
  audit first, because a reviewer judges the diff it is handed and a task
  nobody implemented produces none — feeding **one** findings list, under the
  three-round cap and the escalation that were already there. No second loop
  with rules of its own; the existing cap now counts both gates.
  **The base is `git merge-base`, never `HEAD~1`** (the 1.8.0 correction),
  stated at the point of dispatch: this path commits per task, so `HEAD~1`
  hands over the last task's diff and calls it the branch.
  **Where the harness has no subagent to dispatch, that is an escalation, not
  a silent skip** — and not a self-review either, which is the first line of
  that skill's own Common Rationalizations.
  The execution offer in `writing-plans` was corrected with it: inline is no
  longer the path with no review, and the difference that survives is stated —
  a review per task versus one at the end of the branch.

- **`verification-before-completion` was measured instead of argued about.**
  120 lines with one invoker in the whole graph
  (`systematic-debugging/SKILL.md:189`); both available moves — wire it into the
  flows, or cut it — were claims about what a model would do.
  `tests/skill-behavior/FIXTURE-completion-claim.md` builds the situation the
  Iron Law exists for: a green library, a small formatting change, a release
  said to be waiting on it, and a consuming module the change leaves red.
  **Two runs, and the second is the measurement:** its dispatch never mentions
  the skills at all, so the pair reads the difference between the rule being
  reachable and the model being on its own.
  **Run 1 PASS (3/3), run 2 PARTIAL (2/3), and criterion 1 held in both.** An
  agent with no pointer to any skill ran the suite unprompted under release
  pressure. What differed was the shape of the evidence — run 1 named the
  command, the baseline and the red count; run 2 gave a bare "Suite green,
  6/6". Both reports were checked against `git diff` and a suite run by the
  measurer before scoring.
  **No skill was edited on the strength of it**, and the scope is stated in the
  record: one model, two runs, a suite that finishes in 122 ms — the easiest
  possible case for running a check. `RESULT-verification-before-completion.md`.

### Fixed

- **Three live `file:line` anchors into `executing-plans/SKILL.md` were already
  off by one before this cycle touched them.** `finishing-a-development-branch`
  cited `:26`, `:124` and `:136`; measured at `a5ac650`, before any edit here,
  two of the three landed on a blank line and the third mid-sentence. Growing
  Step 3 would have moved them again. They now use the stable form this project
  adopted in `1.8.2` — `` `path/file.md`, section "Exact Heading" `` — which is
  what `CLAUDE.md` prescribes for a file of this repository edited every
  release. **The gate does not reach them:** `scripts/check-links.sh:72` sets
  `SECTION_TARGETS = ["CLAUDE.md"]`, so the form is verified in `CLAUDE.md` and
  nowhere else. Recorded as an open gap rather than fixed by widening the gate
  in the same commit as the change that revealed it.
- **A Common Rationalization in `finishing-a-development-branch` said the
  inline path has no final review.** True when written, false the moment Step 3
  gained one — a rotten rule competing with the correct one, which is the
  failure this project's own instructions name. Its Reality now says what Step
  2 there actually does: it checks that the gates ran and what they returned,
  never re-runs them.

- **The path advice follows the measured criterion, in all three places that
  carried it.** `executing-plans/SKILL.md:14` said to use
  `subagent-driven-development` *instead of this skill* whenever subagents
  exist; `writing-plans/SKILL.md:409` offers the choice by plan size, with the
  resume difference measured adversarially on both paths in the `1.6.0`–`1.7.2`
  cycle. Two rules over one decision, and nothing says which wins — the model
  picks one arbitrarily. **The measured rule governs:** `:14` now states the
  criterion (does the plan finish in one sitting, does its progress have to
  outlive the session) and points at the `**Execution:**` field that already
  records the answer.
  **A third copy was found by measuring rather than by the report, and it was
  the worst of them:** `writing-plans/SKILL.md:81`, inside the plan header
  block, marked the subagent path `(recommended)` unconditionally — copied
  into *every plan written*, twelve lines above the `**Execution:**` field it
  contradicts. Both lines are upstream's and live in `upstream/main` today
  (`:14` and `:61` there); each was changed on its own line, its neighbours
  untouched, which is the rebase cost this project accepts deliberately.

## [1.8.2] - 2026-08-04

### Added

- **`check-links.sh` verifies the stable anchor form, and `CLAUDE.md` is the
  first file it reads at all.** Measured before writing: no gate reached
  `CLAUDE.md` — `check-links.sh` scans the institutional root, `docs/` and
  `skills/`, and `check-changelog.sh` only ever opens the changelog. The file
  whose anchors were wrong three times in two releases was the one nothing
  checked. It now charges `` `path/file.md`, section "Exact Heading" ``: the
  file must resolve, and some heading in it must match the title after the same
  slug normalization the anchor pass already uses.
  **The heading scan is deliberately looser than the anchor scan, and the
  reason is measured.** `anchors_of()` answers "what can a GitHub anchor link
  reach", so it needs `#` in column 1 and blanks fenced blocks — under those
  rules `task-reviewer-prompt.md` exposes **1** of its 10 headings, because a
  prompt template is one fenced block top to bottom with its headings indented
  inside it. Those are exactly the sections `CLAUDE.md` has to cite, so
  `section_slugs()` reads indented headings inside fences. The looseness runs
  one way only and is stated in the code: it can accept a section that is not
  one, never reject a section that exists.
  **It matches against the whole file, not line by line** — an editor wrapping
  a reference across two lines would otherwise stop it matching, the gate would
  go quiet, and the author would see a pass. That is not hypothetical: the first
  implementation read line by line and silently ignored one of the seven
  references being converted, which is how it was found.
  Nine cases in `tests/hooks/test-check-links.sh`, and four mutations run
  against them — dropping the indentation tolerance, removing the heading
  comparison, removing the missing-file charge, and restoring line-by-line
  reading — each killing exactly one distinct assertion.
  **The gate failed the commit that created it**, on the generic
  `` `file.md`, section "Heading" `` written into the criterion sentence. The
  sentence now points at the table above instead of instantiating a path that
  does not exist.

### Changed

- **Seven anchors in `CLAUDE.md` moved from line numbers to section titles.** A
  heading changes only when somebody renames it — rare, and loud in a diff —
  while a line number moves every time a paragraph is inserted above it. Of the
  13 `file:line` anchors in the file, 8 pointed into skill files this project
  edits every release; 7 of those became section references and **one kept its
  line number**: `references/escalation-format.md:9-11` sits in that file's
  preamble, between the title and `## Example`, with no heading of its own to
  name. No heading was invented for it. The other 5 are unchanged by design —
  4 name scripts and tests, which move rarely and often have no headings, and
  `anthropic-best-practices.md:241` is vendored from upstream, so it is not a
  file this fork edits.
  The `CHANGELOG.md` anchors — 90 of them, 80 into skills — were **not**
  touched: they record where a rule was in the version being described, which
  is what a historical record is for.
  The criterion is now written down: `file:line` for code and artifacts that do
  not move because of what we write, file plus section title for a file of this
  repository we edit every release.
- **The pre-commit cost table is re-measured.** `check-links.sh` 42 → 70 ms with
  the section pass, which resolves each bare basename by walking the tree;
  `check-skill-size.sh` 15 → 10 ms and the hook end to end 68 → 90 ms, same
  method, same machine, median of three.

## [1.8.1] - 2026-08-04

### Changed

- **Document review and the conformance audit are separate families in the
  measurement queue.** Two of its lines read as one rule and were two: the cap
  of three and the returning-blocker rule each covered `brainstorming` and
  `writing-plans`, where the actor is a reviewer subagent re-reading a document
  and running out of rounds costs a paragraph — **and** `executing-plans`, where
  the same numbers count rounds of the conformance audit, the branch is already
  built, and running out ends with the work unfinished and its NOT DELIVERED
  rows escalated. That last state is the one
  `finishing-a-development-branch/SKILL.md:40` had to grow a row for in this
  same cycle. Different actor, different client, different consequence at the
  cap: one fixture cannot measure both, which is what the resume routes taught
  when they came back split. The queue is eight entries now, and **the header
  saying "seven" was already stale** — the resume routes left it measured and
  the count never followed. Not to be confused with the 3-versus-5 axis, which
  `1.5.0` settled and this split is not about.

- **The evidence line is one form again, unified where it is used.** It appears
  three times and had drifted into three wordings; the divergence was
  `code-reviewer.md:96` asking for `[verbatim, and where you got it]` while the
  other two ask for `[verbatim]`. Nothing was lost by unifying: that reviewer's
  instruction already requires it — "say which you ran and where you found it",
  `:52-56` — and its worked example already shows the shape,
  `` `npm test` (from package.json scripts.test) `` at `:163`. What stays
  different is the baseline suffix, which is content rather than wording:
  `base:` is the count before the task, `previous:` is what the last review
  reported, and the whole-branch review carries none because it has no prior
  count. Each face now declares its own label where it declares the slot.
  **`CLAUDE.md` gained the exception this measured:** a form living inside a
  subagent's `## Output Format` is unified in place and never extracted, whatever
  the occurrence count says. Extracting replaces the form with an instruction to
  fetch a file at runtime, and `references/escalation-format.md:9-11` is the
  record of that exact move measuring 1 of 3 — then 3 of 3 once the form
  returned to the point of use.

- **The Platform Adaptation list now states its criterion, and Gemini stays
  out.** A sweep found `references/gemini-tools.md` present and unlisted and
  read it as an omission. It is not: `GEMINI.md` imports both that file and the
  skill body, so the mapping is flattened into context before the first turn,
  while Codex, Pi and Antigravity have nothing that does it for them. The list
  names the harnesses that must be **told** to go read their mapping — an
  instruction to fetch what you are already reading is a line nobody acts on.
  Written down so the next sweep does not reopen it.

## [1.8.0] - 2026-08-04

### Added

- **The plan reviewer now charges Global Constraints, which nothing verified.**
  Measured before writing: the string "global constraint" appeared **zero**
  times in `plan-document-reviewer-prompt.md`. The plan declares a
  `## Global Constraints` section (`writing-plans/SKILL.md:111`), the controller
  hands it verbatim to the task reviewer, and that reviewer blocks a
  happy-path test when those constraints list edge cases
  (`task-reviewer-prompt.md:128`) — a gate whose input no gate checked. Two
  blocking rows added to the Plan Contract: the section exists with exact values
  copied from the spec (or says `None`, since an absent section and an unwritten
  one read identically downstream), and no task contradicts a constraint. The
  second was previously caught only by the controller's pre-flight scan
  (`subagent-driven-development/SKILL.md:137`), which runs after the plan is
  already approved. Pairs with the implementer slot added above.
### Changed

- **The stance on diverging from the upstream is recorded in `CLAUDE.md`.** The
  rebase section read as though conflict cost were a reason not to change a
  file, and sessions have treated it that way. It is not: the upstream is a
  historical base, complete divergence is acceptable by the owner's decision of
  2026-08-04, and rebase cost is an expense to schedule. The existing rule —
  touch the minimum of what they edit often — stays, now framed as spending that
  cost deliberately rather than avoiding it.
### Fixed

- **Five anchors in the measurement queue slid, three of them inside this
  cycle.** The digraph fix added two lines to `brainstorming/SKILL.md` above the
  review cap, the Step 2 renumbering added one to `executing-plans/SKILL.md`
  above the audit cap, and the dispatch-list item added three to
  `subagent-driven-development/SKILL.md` above the dispute rules. Every queue
  anchor below each insertion point moved by exactly that much: the three-round
  cap `213 → 215` and `133 → 134`, the returning-blocker rule `223 → 225` and
  `144 → 145`, the dispute protocol `350 → 353`. Two of the five landed on
  lines that read plausibly — `brainstorming:213` is now "Fix every blocking
  issue the reviewer returns", one line above the cap it claims. This is the
  second time in three releases (`1.6.0` recorded the first, same mechanism,
  same file); `check-changelog.sh` cannot catch it, because an anchor whose file
  exists and is long enough passes by construction.
- **The Test Coverage Matrix stated its rules in two places, 119 lines apart.**
  `writing-plans/SKILL.md` carries the heading twice by design — `:118` is the
  block a plan author copies into the plan, `:237` is the instruction for
  filling it — but the bracket inside the template restated the rules the
  section already owns: one row one test, every `AC` and `IR` covered, test
  types and layers taken from this repository. The template now points at the
  section and keeps only what a template must show, the five columns and the
  worked rows. **The example rows stay:** they are the one place that shows
  `T3.1` and `T3.2` refining the same `AC1`, which the rule only implies with
  "at least one row".
- **`writing-plans` described a worktree it never creates.** `:16` read "it
  should have been created via `using-git-worktrees` **at execution time**",
  written in the past tense about something that happens after this skill
  finishes. Both execution paths open by creating or verifying one
  (`subagent-driven-development/SKILL.md:94`,
  `executing-plans/SKILL.md:62`); planning creates none, and a worktree present
  while planning predates the plan.

- **"None restates it" was false, and the restatement is the part that had to
  stay.** `writing-plans/SKILL.md:38` declared itself the single statement of
  the least-structure rule and said the three appliers never restate it.
  Measured: `plan-document-reviewer-prompt.md:83` and
  `task-reviewer-prompt.md:118-120` do exactly that — cite and judge — but
  `implementer-prompt.md:83-90` restates the *smaller* clause, and it restates
  it **because the subject differs**. This statement picks a structure; the
  implementer writes the code inside it, which is why its copy carries
  reuse-before-writing and duplication-as-a-last-resort, neither of which is a
  planning decision. Deleting them there to make the sentence true would strip a
  rule out of a subagent's prompt and leave a pointer in its place — the move
  `escalation-format.md:9-11` measured failing. The sentence was corrected
  instead, and now names which appliers cite and which one adapts.

- **Three of the four review-face anchors in `CLAUDE.md` pointed somewhere
  else.** Measured by opening each destination: `task-reviewer-prompt.md:69` is
  the heading "Do Not Trust the Report" and the `[TEST_COMMAND]` run is at
  `:83`; `re-review-prompt.md:58` is the context sentence and the imperative
  "Re-run them" is at `:60`; `final-branch-audit/SKILL.md:221` is a line about
  the spec being committed, while the face it claims — no tests at all, re-run
  the *searches* — is the section at `:175`. Only `code-reviewer.md:52` was
  right. A section that exists to keep four gates from being harmonized was
  citing lines that do not show what makes them different.
  **The evidence-block paragraph below it was wrong twice over:** its two
  anchors named `:81` and `:85` (real: `:83` and `:96`), and it said "two
  occurrences" when there are **three**, in three wordings — the third being
  `task-reviewer-prompt.md:180`. Its own extraction trigger has therefore been
  crossed, and the paragraph now says so, together with why the obvious
  extraction is the wrong move here: this block lives inside a subagent's
  `## Output Format`, so a pointer would make the subagent fetch a file at
  runtime, which is precisely what `escalation-format.md:9-11` measured failing
  and reversed. Unifying the three wordings in place is the open item.

- **The two process graphs said things their own prose contradicts.** Seven
  divergences, found by reading each graph against the section it draws.
  - `brainstorming/SKILL.md`: the escalation at the review cap offers **three**
    options in prose (`:217-219`) and the graph drew **two** — "stop here" had
    no edge and therefore no existence. It has a terminal node now. And the
    spec's **commit** was invisible: the node said "Write design doc" while
    `:196` requires committing it and `final-branch-audit/SKILL.md:46` blocks
    the whole traceability pass on an uncommitted spec. The node names both acts.
  - `references/process-graph.md`: **Minor findings had no route** — the skill
    says they go to the ledger and never enter the fix loop, and the graph sent
    every non-approval straight at the loop. **The human's ruling had no route
    either**: "Ask human partner which governs" fed the fix round
    unconditionally, so the graph could not express the plan governing. Both are
    diamonds now. The node reached after adjudicating residuals called itself
    "Final gates clean" for a state `final-review.md:68-71` defines as the audit
    **staying at FAIL** — it is "Gates settled — clean, or residuals ruled". And
    the **resume gate was missing entirely**, though it is the one route in this
    skill that has been measured (3 of 3,
    `tests/skill-behavior/RESULT-resume-route-subagent.md`).
  - That file opened with "The whole flow in one picture", which was false
    before these fixes and would stay imprecise after them. It now states its
    real cut: everything except the four implementer statuses of "Handle the
    report", which are responses to one node's output rather than paths, and are
    named as the deliberate omission.
  - Checked after editing, both graphs: every declared node appears in an edge
    and every node in an edge is declared — 19 nodes in `brainstorming`, 32 in
    `process-graph`, zero orphans and zero undeclared in each.

- **`executing-plans`' Step 2 carried two lists numbered from 1** — the resume
  lock's three acts and the four steps of the per-task loop, seven lines apart,
  so "step 2" named two different things inside one section. The step now holds
  a single numbered sequence: the lock keeps its numbers, whose position at the
  top of the step is what the third adversarial run measured
  (`tests/skill-behavior/RESULT-resume-route-inline.md`), and the per-task loop
  became an ordered list without them. **Renumbering the two into one 1–7 run
  was considered and rejected:** the lock fires once and conditionally, the loop
  fires per task, and a single sequence would assert a linearity that is not
  there — trading a label collision for a false claim.

- **The implementer was being graded against a document the dispatch never
  handed it.** `subagent-driven-development/SKILL.md:216` says a fresh subagent
  needs "its task, the interfaces it touches, and the global constraints", and
  the numbered list of what a dispatch contains — four lines above it — named
  five parts, none of them the constraints. `implementer-prompt.md` had no slot
  for them either, while asking the implementer to self-check against "the
  global constraints list edge cases". The reviewer, meanwhile, receives them by
  slot (`task-reviewer-prompt.md:26`) and reports a happy-path test as
  **blocking** when they list edge cases (`:128`). One side of that gate had the
  document and the other did not. The dispatch list now carries them as item 3
  and the implementer template has the matching slot, so both roles read the
  same block.

- **A branch that left `executing-plans` by its own escalation had no row in
  the merge gate.** `finishing-a-development-branch`'s Step 2 table charged a
  FAIL two ways: route it into a fix wave, or match the row for residuals *the
  fix wave parked with a ruling at its cap*. The inline path has neither —
  `executing-plans/SKILL.md:26` says in so many words that it runs no numbered
  fix rounds — so a branch that hit the cap of three audit rounds and escalated
  exactly as `:136-142` prescribes arrived at the gate with no applicable row.
  It now has one, with the same terminal treatment the parked residuals get and
  the same refusal to take it on faith: the audit report names the rows and
  `git log` shows a fix pass between each run, or it is the plain FAIL row.
  **The parenthesis in the row below it was wrong in the other direction** — it
  offered `executing-plans` as an example of a branch arriving with no audit,
  while that skill's Step 3 makes the audit mandatory (`:124`). Both execution
  paths do; what arrives unaudited is a branch built by hand or an execution
  that stopped short of its own audit step.

- **The review dispatch no longer teaches the base it forbids elsewhere.**
  `requesting-code-review/SKILL.md` opened with `BASE_SHA=$(git rev-parse
  HEAD~1)` — the exact form `subagent-driven-development/SKILL.md:229` names as
  a defect ("silently drops all but the last commit of a multi-commit task")
  and `scripts/review-package` documents as the reason it takes an explicit
  BASE. Now `git merge-base <base-branch> HEAD`, with the trap stated in one
  line above it. The worked example took the same fix: its base came from
  `git log --oneline | grep "Task 1" | head -1 | awk`, which stops matching the
  day a commit message is reworded, and now uses the BASE recorded before the
  task was dispatched — the same `a7981ec` the example already passes to the
  reviewer four lines later.

## [1.7.3] - 2026-08-04

Documentation only. No skill body, script, hook or manifest changed behavior —
the version exists because three documents were describing a repository that
had moved past them.

### Changed

- **The showcase documentation described one measurement as if it were the
  only one.** `docs/README.pt-BR.md` and `docs/README.en.md` cited the
  escalation format's third run and nothing else. Four rules have now been
  measured across eight runs, and each gets a line with its verdict and a link
  to its record: external content is data (passed first run), the escalation
  format (1/3 → 2/3 → 3/3), resuming on the subagent path (3/3), and resuming
  on the inline path (FAIL → FAIL → PASS). **No transcript was copied in** —
  the link is the record, and duplicating it is how two versions of the same
  run start to disagree.
  The transferable finding is now stated once outside the changelog: **a rule
  that guards the next act is followed; a rule that describes a standard is
  not, even when the agent reads it, cites it, and says out loud that it is
  breaking it.** Three measured series produced it and it is the most portable
  thing this repository has learned.
  `README.md` at the root was **not touched**: it was checked and it claims no
  count — its one reference to a record is the source of a condensed
  transcript and is still exact. Every line edited there is a rebase conflict.

- **`docs/testing.md` described `tests/skill-behavior/` in the singular** — "a
  fixture, the input carrying it, and a recorded result per rule". Measured:
  five `FIXTURE-*.md`, six `RESULT-*.md`, a `spec-under-test.md` and the
  directory's `README.md`, and one rule can carry several records. The policy
  that governs them was practice and not written anywhere: **these never run
  in CI**, because each dispatches a live agent, and what CI checks instead is
  the *integrity* of the records — verified against what
  `check-skill-behavior-records.sh` actually asserts, not against memory.

### Fixed

- **`CONTRIBUTING.md:97-99` carried a false claim about enforcement** *(line
  numbers as the file read before this version).* It said
  the last two rows of its release-discipline table are "enforced by
  `scripts/check-changelog.sh`". The changelog row is. The row saying
  preparation and `git commit` are never chained is not, and **no script can
  check it** — a shell cannot see that two commands were two decisions. The
  only `&&` in that script is at `check-changelog.sh:99` and it is ordinary
  shell. Now stated as a rule you follow, with the invisible failure that
  produced it.

- **Two of the four suites in `tests/hooks/` were missing from
  `CONTRIBUTING.md`'s test list** — `test-check-links.sh` and
  `test-check-skill-size.sh`, both of which CI runs. A contributor following
  that list ran a subset and had no way to know.

- **`docs/testing.md`'s list of CI gates omitted `check-skill-size.sh`.**
  Found while editing the section above it.

- **The gate counts are now written down**, because nothing stated them and
  they are not the same number: **five** run locally in `githooks/pre-commit`,
  and CI runs those five plus `check-skill-behavior-records.sh` and
  `lint-shell.sh`. The records check has no local counterpart on purpose —
  most commits do not touch the directory it guards.

## [1.7.2] - 2026-08-04

**Why PATCH.** The confirmation requirement is not new and was not removed —
it moved from the end of a paragraph into the step it governs. Nothing is
asked of an agent that was not asked before, no artifact changes shape, and
no invocation changes. What changed is whether the existing requirement is
reached, which is what a fix is. The one piece of genuinely new text is two
informational lines in an offer the skill already made.
**The tension is worth naming rather than hiding:** the measured *behavior*
did change — the agent now stops where it used to edit. Read
`CLAUDE.md`'s "PATCH for a fix that does not change how a skill behaves" as
*does not change what the skill requires*, or every measured fix becomes a
MINOR and the distinction stops carrying information.

**The ladder ran one rung and stopped there.** Rung 2 — removing the inline
continuation route entirely — was **not built**, because rung 1 passed. It
stays available if this result does not hold up.

### Added

- **The adversarial records for the resume route are written down**, which
  the two earlier rounds had not been: `tests/skill-behavior/FIXTURE-interrupted-run.md`
  (how the interrupted state is built, the four repos, and the one-line
  dispatch), `RESULT-resume-route-subagent.md` (one run, 3 of 3) and
  `RESULT-resume-route-inline.md` (three runs, FAIL → FAIL → PASS), with the
  directory's `README.md` carrying the summary. `check-skill-behavior-records.sh`
  passes on all three. **The fixture file records one deviation from a real
  session rather than hiding it:** the dispatch has to tell the subagent that
  skills exist, because `using-superpowers` instructs subagents to ignore
  itself. It names no skill and never says "resume".

- **The measured difference between the two execution paths now appears in
  the offer that asks your partner to pick one** (`writing-plans/SKILL.md:405-407`).
  Two lines, one per path, dated: the subagent path's resume held 3 of 3 on
  its first adversarial run; the inline path failed the stop-and-confirm
  criterion on the first two of its three, and passed the third after the
  requirement moved into the step that executes. The offer already said what *survives* an
  interruption — a file versus session todos. What it did not say is that
  only one of the two was ever put under test, and that the other one failed.
  A partner choosing between them is choosing between a measured behavior and
  an unmeasured one, and now the offer says which is which. The recommendation
  line's `Source:` label was widened to match: general practice for the
  sizing advice, this project's own runs for the resuming difference.

### Changed

- **Step 1 of the ladder: the confirmation requirement moved out of prose and
  into the action it governs.** `executing-plans/SKILL.md:101-114` now opens
  Step 2 with a resume lock — three numbered acts before the first edit: stop,
  present the reconstructed resume point in the escalation shape, wait for the
  answer. The paragraph at `:40-57` keeps the reasoning (how to reconstruct,
  why being wrong costs the partner either way) and now points at the lock
  instead of carrying the requirement itself; the sentence that used to end
  *"and get your partner's confirmation before executing anything"* is gone
  from there. **No duplication:** the prose names the lock, the lock does not
  restate the prose.
  **The hypothesis being tested is distance.** Two runs failed this criterion
  with the requirement sitting at the end of a paragraph above `## The
  Process`, while the next act on this path is an edit. On the subagent path
  the equivalent rule sits in Setup guarding a dispatch, and it held 3 of 3.
  This moves the inline requirement to the same structural position: the door
  the agent has to walk through.
  **Measured, and it held — run 3 passed all three criteria on a fourth,
  unused fixture.** The agent read the plan, reconstructed the resume point
  into a four-row table citing a commit or a `file:line` per row, and opened
  its message with *"I stopped before editing anything."* Tool use: 4 `Bash`,
  8 `Read`, **no `Edit` and no `Write`** — the repository was identical to the
  preserved copy outside `.git`, working-tree dirt included. The escalation
  carried the consequence, four options including doing nothing, and a
  recommendation labelled *"Source: the plan in your own repository"*.
  Unprompted, it also refused to assume consent for committing to `main` —
  a different rule in the same skill that neither earlier run applied.
  **One run, and this criterion has produced a false signal before:** run 2
  read as progress and was a regression. A second fixture would strengthen
  this and was not run. Recorded at `tests/skill-behavior/RESULT-resume-route-inline.md`.

## [1.7.1] - 2026-08-04

**Why PATCH and not MINOR.** The only skill edit in this version is a routing
step, and the measurement below shows it changes no behavior: both agents ran
`ls`, `git log` and `git status` before reading any skill, with and without
it, so the step describes what was already happening. **The content of this
version is the record** — the subagent half of the resume route measured at
3 of 3, the inline half failed across two runs with the second worse than the
first, and the candidate cause named and marked untested.

### Added

- **The resume route on the subagent path is measured, and it held — 3 of 3
  on its first adversarial run.** It moves out of the measurement queue below
  and joins the external-content rule and the escalation format as a rule
  with evidence behind it. The fixture was a real interrupted run, not a
  written one: a four-task plan executed through the subagent path with live
  implementer and reviewer subagents, whose task-2 review opened a genuine
  Important finding and produced a real fix round. The interruption was
  planted *inside* task 3 — both tests written, only the first implemented,
  nothing committed, no report file — and a fresh agent was dispatched with
  no framing beyond its partner's own words, "Continue the work on
  `<plan>`".
  It read `SKILL.md` → `references/resuming.md` → `references/process-graph.md`
  → `escalation-format.md`, ran eleven commands, and **wrote nothing**: no
  `Edit`, no dispatch, the repository byte-identical to the preserved state
  afterwards. It checked the ledger against `git log` and found them
  agreeing; it located the resume point to the step — *"the worker got
  through steps 1–3 of Task 3 and stopped before step 4"*; and it named the
  shape it was in, citing the file: *"Task 3 has a brief but no report file.
  That is the signature of an interruption landing inside a dispatch"*
  (`references/resuming.md:59`). It then escalated with all three parts of
  the format — consequence, three options including stopping, and a
  recommendation labelled *"Source: this project's own skill"* — and waited.
  It also recovered task 1's deferred minor from the ledger unprompted and
  applied it to the command it would have dispatched, which is the ledger's
  recovery function working exactly as that file describes.
  **One weakness, the same one run 2 of the escalation test showed:** the
  message left `gates`, `dispatch` and `base test count` untranslated. No
  gate verdict name appears anywhere in it, which is the explicit
  prohibition, but the reread step did not catch the jargon.

- **The resume route on the inline path failed twice, on the same criterion,
  and the second run was worse than the first.** `executing-plans/SKILL.md:51-52`
  *(as it read at 1.7.1; the requirement moved into Step 2 afterwards)*
  asks a resuming agent to "state which tasks you believe are done and the
  evidence for each, and get your partner's confirmation before executing
  anything". Two runs, two different fixtures, same model, same neutral
  dispatch. Both agents passed everything before that clause — neither
  guessed, both reconstructed from `git log`, the working tree and the plan,
  and both were right about where the work stopped — and both then executed
  the remaining tasks, dispatched the conformance audit, and committed,
  speaking to their partner only afterwards.
  **Run 2 is worse than run 1 because it knew.** Run 1 never mentioned the
  clause. Run 2 named it and declared the violation in its opening lines,
  verbatim: *"`executing-plans` asks a resuming agent to confirm the
  reconstruction with you before executing. I proceeded without waiting,
  because as a subagent I reach you only in this message and stopping would
  have returned nothing."* A rule read, understood, and set aside with a
  reason is a worse result than a rule that never surfaced — the second says
  the text reached the agent and lost anyway.
  **The reason it gives does not close it.** The subagent-path agent was
  under the identical constraint — it also reaches its partner only in a
  final message — and it stopped anyway, returning its resume point and no
  work at all. The constraint is real and does not compel the outcome.
  **The candidate cause, recorded as untested:** a rule that guards a
  *dispatch* holds, and a rule that asks an agent *not to edit*, written as
  prose above the process, does not. On the subagent path the next act after
  the resume check is a dispatch, and the rule sits in Setup guarding exactly
  that act. On the inline path the next act is an edit, and the rule sits in
  a paragraph above `## The Process`, where nothing routes through it. That
  is a hypothesis with two runs consistent with it and **no experiment
  designed to test it** — it is not a finding, and the next round needs a
  design, not another attempt.

- **A routing step at `skills/executing-plans/SKILL.md:62` *(line 63 after
  1.7.1)*, and the
  remeasurement DEMOLISHED the diagnosis that produced it.** The step mirrors
  what the subagent path's Setup already does: run `git log` and `git status`
  before reading anything else, and treat work you did not do this session as
  a resume, diverting to the resume paragraph before executing. It was
  proposed on the theory that **detection** was failing — that the inline
  agent never realized it was resuming because nothing routed it there.
  **That theory is false, and the evidence is direct.** Both inline agents,
  the one before the step existed and the one after, opened with the *same*
  first command: `ls -la && git log --oneline -20 && git status`, before
  reading any skill file. Both then read `executing-plans/SKILL.md` in full,
  no offset, so the resume paragraph was equally in front of both. Detection
  never failed in either run; the step describes behavior the agents already
  had. **Do not read run 2's improvement as this step's effect** — one sample
  per condition, and the difference between the runs lands on a criterion the
  step never mentions.
  **It is kept, and it is marked reasoned, not measured**, per this project's
  rule that a new rule says which it is. The reason to keep it is that it
  states the entry condition explicitly and costs one paragraph; the reason
  it carries no credit is above.

### Fixed

- **The rule under test was not amended by either run** — recording the
  failure is the result, as it was for runs 1 and 2 of the escalation format.

- **Three anchors in the measurement queue slid and were corrected by hand.**
  The routing step added six lines to `executing-plans/SKILL.md` at line 62,
  and every anchor into that file below the insertion point moved by exactly
  six: the `**Execution:**` field `63 → 69`, the three-round cap `111 → 117`,
  and the returning-blocker rule `122 → 128`. The queue's table still named
  the old three, so all three pointed at real lines carrying the wrong text —
  the `**Execution:**` one landed on `4. Read the plan header's`, which reads
  plausibly enough to be believed.
  **`check-changelog.sh` cannot catch this, and its own header says so** — an
  anchor whose file exists and is long enough passes, because deciding
  whether it points at the *right* line needs the claim's meaning. All three
  were found by reading the staged diff, which is the step the
  commit-preparation rule exists to force, and the first one is what prompted
  checking the other eight. **Any edit that inserts a line into a file this
  changelog cites makes every anchor below the insertion point a candidate;
  the check is `grep -o 'file.md:[0-9]*'` and read each one.**

## [1.7.0] - 2026-08-03

### Added

- **A `SKILL.md` line ceiling, declared in `CLAUDE.md` and enforced by
  `scripts/check-skill-size.sh`.** 500 lines, and **the number is borrowed, not
  measured here**: "Keep SKILL.md body under 500 lines for optimal performance"
  is Anthropic's own guidance, vendored in this checkout at
  `skills/writing-skills/anthropic-best-practices.md:241` and repeated at
  `:1109` as a checklist item nothing ever ran. What this project adds is the
  running of it. No stricter number was invented: there is no measurement here
  that would justify one, and picking a tighter limit by argument is the move
  the measurement queue below refuses on seven other rules.
  **Proved against the real tree, not only in the tests:** at the commit before
  the extraction above it exits 1 and names
  `subagent-driven-development/SKILL.md` at 564 lines; at the commit after, it
  exits 0. `tests/hooks/test-check-skill-size.sh` covers nine cases, and three
  mutations were run against it — dropping the empty-glob guard, turning the
  comparison into `-ge`, and emptying the exemption list — each killing exactly
  one distinct assertion.
  **One file is exempt and it is the only entry:** `writing-skills/SKILL.md` is
  679 lines here and 679 upstream, and the only two lines this fork changed in
  it are the namespace rename. Cutting it means rewriting a file the upstream
  maintains, for a gain that belongs in somebody else's repository.
  Wired into `githooks/pre-commit` and into CI as its own step, since a gate
  only in the hook does not run in a clone that never set `core.hooksPath`.
  It cost the hook 15 ms — no interpreter starts, just `wc` — taking it from
  41 ms to 62 ms end to end, and `CLAUDE.md`'s cost table now says so.

- **The changelog gate now checks the edit, not only that one happened.**
  `scripts/check-changelog.sh` proved an entry was staged and never that it was
  correct. One session produced three defects it could not have caught: an entry
  title replaced instead of preceded — an edit anchored on the *next* entry's
  heading, which leaves the file reading perfectly with one entry silently gone
  — and two `file:line` anchors that pointed nowhere, one copied from a diff's
  context instead of the file, one invalidated four lines later by an edit
  earlier in the same file. All three were caught by reading the diff before
  committing, which is the step a busy commit skips; that is the same reasoning
  that produced this gate in the first place.
  Three structural checks, each decidable by a machine: a `## ` heading count
  that never decreases between HEAD and the index; no duplicated version heading
  and at most one `[Unreleased]`; and every `path:line` anchor **added by this
  commit** naming a file that exists and is long enough to have that line.
  **The anchor check resolves in a cascade because this changelog's path
  convention is genuinely mixed** — measured across the 35 anchors already in
  the file: repo-root (`scripts/check-docs-sync.sh:14-15`), relative to
  `skills/` (`writing-plans/SKILL.md:51`), relative to the directory being
  discussed (`references/final-review.md:56`, written from inside a skill), and
  bare basenames the surrounding sentence disambiguates
  (`code-reviewer.md:118`). It tries the first two in that order, then falls
  back to a suffix match against the tracked files, which covers the last two
  at once. Matching several files — `SKILL.md:63` matches fifteen — is
  **skipped, not failed**: a gate that guessed there would go red on entries
  that are correct, and a gate red for a wrong reason gets bypassed.
  **The fourth convention was missing on the first push and CI caught it**,
  which is the gate working in the direction nobody wants. The pre-commit hook
  sees one commit's diff; CI puts the whole pushed range in the index, so
  `references/final-review.md:56` — written in an earlier commit, before this
  gate existed, and correct the whole time — reached the check for the first
  time and was charged as a file that does not exist. The resolver now ends in
  a suffix match, and an anchor that matches several files is skipped there too
  rather than reported as missing. Four cases added, two of them verified red
  against the script as it was.
  **Two limits are declared in the script's own header** so nobody assumes
  coverage that is not there: an anchor pointing at the wrong line of a file
  that exists and is long enough still passes, because deciding that needs the
  claim's meaning; and prose accuracy is not checked at all.

### Changed

- **`check-links.sh` now scans `skills/` too, closing the open gap about the
  fork's own cross-references — and the design it was waiting on turned out not
  to be needed.** The gap said the fix was not "extend the scan" but "tell a
  link this project owns from one the upstream owns", because a gate on
  `skills/**` would report rebase churn this project did not cause. That was
  reasoned, never measured. **Measured now:** the 21 markdown links under
  `skills/` all resolve, upstream's included, so extending the scan is two
  lines and goes green — 38 files and 38 links before, 56 and 59 after. The
  ownership question dissolves with it: a link upstream wrote and broke is
  broken for this project's users exactly like one written here.
  **`skills/**` is exempt from the link diet, and that exemption is measured
  too.** All 40 URLs under `skills/` are off-diet — 11 to `platform.claude.com`
  in upstream's vendored best-practices, 3 to `docs.stripe.com` inside this
  fork's own worked example of a citation comment, the rest the same shape. The
  diet is a policy about the seven documents this project hands to a reader; a
  skill body pointing at the vendor doc that grounds a call is the citation
  rule working. Links and anchors are checked there; only the domain policy
  stops at the directory boundary.
  **What stays uncovered is the other convention, and the reason is not cost.**
  A path in backticks, in prose, appears 78 times under `skills/` and 34 of
  those resolve to nothing — **and none of the 34 is a defect**: placeholders
  (`<workspace>/progress.md`), artifact paths inside the partner's own project
  (`docs/superpowers/specs/…`), self-references (`SKILL.md` meaning the file
  you are reading), and upstream's illustrative examples. A gate there reports
  34 non-problems on every commit, which is how a gate stops being read. The
  one thing the closed gap recorded as an accepted consequence still holds and
  is unaffected: the escalation block in `brainstorming/SKILL.md` cites a
  relative path so it stays byte-identical to the other five carriers, while
  the rest of that file cites from the repository root.
  Four cases were added to `tests/hooks/test-check-links.sh`, including the
  pair that pins the diet boundary in both directions — the same
  `docs.stripe.com` URL passes inside `skills/` and fails in a root document.
  Cost: `check-links.sh` went 29 → 42 ms, the hook 62 → 68 ms; `CLAUDE.md`'s
  table says so.

- **`subagent-driven-development/SKILL.md` moved 107 lines into two reference
  files, and neither is reachable by accident.** 564 → 457 lines, counted
  before and after. What left is what a run does not need until it needs it,
  and every trigger stayed behind — moving one would have made this a deletion
  rather than a move.
  - **`references/resuming.md`.** How to read a ledger, how to check it against
    `git log`, the three-step resume, the two shapes where the ledger itself is
    what is missing, and what each side costs when the plan's `**Execution:**`
    field names the other path. Every line of it is conditional on the run
    being a resumption; a first run reads none of it. The Setup bullet now
    carries the condition out loud — a ledger is there, **or** the branch
    already has commits you did not make this session — and sends you to the
    file *before dispatching anything*. The `**Execution:**` field is still
    read in the same paragraph it was read in before, with only the cost
    analysis moved: that reader shipped one release ago and is not weakened
    here.
  - **`references/process-graph.md`.** The process digraph. `## The Process`
    keeps a short prose summary of the order and an instruction to open the
    graph before dispatching Task 1.
    **Checked before moving it, because the graph became load-bearing when
    `references/example-workflow.md` was cut above:** with the transcript gone
    the graph is the only *picture* of the flow — but not its only record. The
    order is independently carried by the section headings that run it,
    `### 1. Dispatch the implementer` through `## Finish`, in execution order.
    What only the graph shows is where each loop returns to and where each cap
    breaks out, which is why the pointer is an instruction rather than a
    mention.
    The relative paths inside the node labels were rewritten for the new depth
    (`./implementer-prompt.md` → `../implementer-prompt.md`); they are strings
    inside a `dot` block that no gate resolves, so they were checked by hand.
  Five `file:line` anchors elsewhere in this file pointed into the moved region.
  All five were re-measured against the new file, never shifted by arithmetic.

- **Three rules that were written more than once are now written once.**
  Measured across the fork's own additions, not estimated; net **−26 lines**
  across six files, and every rule that governs behavior survives at its
  trigger point.
  - **The derivation of the three-round cap left the skills.** Each of the
    three capped loops carried seven to ten lines explaining *why three and
    not the task loop's five* — that rounds 4–5 swap in a fresh implementer on
    a more capable model and these loops keep one actor. It is an argument
    addressed to a reader, not an instruction anyone follows: nothing an agent
    does changes with it present or absent. The cap and "at the cap, escalate
    — do not open a fourth round" stay in all three. The reasoning is in this
    changelog under `1.5.0` and `[Unreleased]`, which is where a reader
    looking for *why a number is that number* goes.
  - **"The map is a floor, not a ceiling" was stated twice, near-verbatim.**
    It stays in `skills/brainstorming/coverage-map.md`, the file it is about,
    and leaves `brainstorming/SKILL.md`, which already points there.
  - **Four statements of the simplification rule became one.** `writing-plans`
    holds it, where the size of the answer is actually decided; the task
    reviewer, the plan reviewer and the implementer each keep their own
    one-line action and point at it. **The substance moved, the action did
    not** — deliberately, because three of the four are subagent prompt
    templates and one of them forbids crawling the codebase, so replacing an
    action with a bare cross-reference would have left a check nobody runs.
    What is now stated once is what *smaller* means, that naming the
    replacement concretely is what makes it a finding, and the two things the
    rule must not soften: a new dependency needs approval, and generalizing
    beyond the criterion is invented scope.

### Removed

- **Four examples that taught how to solve a problem, not what shape to
  produce.** Each cut names the interface that is now the sole source of that
  form, because an example removed without one reads as a rule deleted.
  - **`subagent-driven-development/references/example-workflow.md` (95
    lines).** A full session transcript. **Audited rule by rule before
    cutting** — all 24 things it demonstrated are specified elsewhere: setup
    and the ledger line formats in `subagent-driven-development/SKILL.md`
    (`:158`, `:168`, `:221`, `:304`, `:336`, `:494`, `:525`); the implementer's
    obligations in `implementer-prompt.md` (`:26`, `:35`, `:101`); the review
    output in `task-reviewer-prompt.md` (`:172`, `:180`, `:183`) and
    `re-review-prompt.md` (`:66`, `:83`, `:89`); the two final gates in
    `references/final-review.md` (`:10`, `:36`) and
    `final-branch-audit/SKILL.md:285`. **The one thing only a transcript
    carried was the sequence, and the `dot` graph already holds it** — which
    is what made the file cuttable rather than merely long.
    Sources now: the `**Command:** … **exit:** … **counts:** …` block for the
    test evidence, the `Criterion | Test file:line | Assertion` table for
    coverage, `ADDRESSED / NOT ADDRESSED` for the fix round, and the graph for
    the order. **One mapping from the plan for this cut did not survive
    contact with the file:** the three severity buckets were named as a source
    and the transcript never showed them — it renders task-reviewer output,
    which has no buckets. The buckets remain `code-reviewer.md`'s own.
  - **The second copy of the Stripe example**, in
    `writing-plans/plan-document-reviewer-prompt.md`. Two copies of a worked
    idempotency call taught idempotency; what the reviewer needs is the shape
    of the citation comment. The copy in `writing-plans/SKILL.md` stays — the
    author writes the plan, the reviewer checks it — and the reviewer now
    describes the shape and points at it.
  - **The domain in the task-structure walkthrough.** It had been made
    concrete (`verify_token`, `src/auth/`, expiry semantics) and taught auth
    to whoever was planning something else. **Reverting to the upstream
    generic collided with a rule this fork added:** "a code block is code that
    runs as shown", and upstream's `function(input)` / `return expected` does
    not run. Resolved by keeping the code runnable and removing the domain —
    paths return to slots, the code became a two-line function with no
    subject. The interface line that distinguishes a slot from runnable code
    is untouched.
  - **The worked example in `brainstorming/coverage-map.md` (33 lines).** A
    completed coverage map for a sign-in feature, plus one clarifying question
    asked end to end. **Audited item by item before cutting** — twelve rules
    demonstrated, all twelve specified above it in the same file: ten
    categories in order and named without their gloss (`:28`), every state
    carrying its reason (`:36`, `:41`), each outcome's destination (`:99-101`),
    the question's form (`:57`, `:59`), the recommendation line and its source
    order (`:73`, `:83`), the options table and "yes" accepting (`:84-85`).
    Sources now: the empty `Category | State | Where it landed` table at
    `coverage-map.md:105-106` for the map, and `Question form`,
    `The recommendation, and where it comes from` and `Presentation` for the
    question. The one thing the example carried that no rule states is the
    `(recommended)` label inside an option row; the rest was a sign-in tutorial
    read by whoever was specifying something else.

- **Declared divergence from the general advice — the first one recorded
  here.** `requesting-code-review/code-reviewer.md` keeps the worked example
  of a grouped finding, against the guidance that examples narrow the space an
  agent explores. It stays because **its reason was measured**: `1.3.0` was
  written after two rounds of review of one plan each surfaced one member of
  the same root cause, and the example was added then with the finding that an
  example showing only isolated findings teaches isolated reporting. Observed
  defect beats general principle — that is the same filter every other rule in
  this fork is held to, and applying it selectively when it argues *for*
  keeping something would make it a preference rather than a rule.

### Fixed

- **The read-only reconciliation reached two of the three review prompts.**
  When the fork made reviewers run the tests instead of trusting a report, two
  prompts got the clause that settles the collision with read-only —
  `task-reviewer-prompt.md:92` and `re-review-prompt.md:70`, "run the tests,
  never checkout, stash, or reset". `code-reviewer.md` got the run-the-suite
  rule without it, and its read-only paragraph is the *widest* of the three:
  upstream text that explicitly sanctions `git worktree add` for reading
  another revision. Run-the-tests plus a sanctioned second worktree is a route
  to a tree where the suite is greener, and nothing said not to take it.
  Now applied equally. **Added as its own bullet inside the fork's test block
  rather than by rewriting the upstream paragraph** — that paragraph is a file
  the upstream maintains, and a line changed there is a conflict at the next
  rebase for no gain.
  This is one rule applied unevenly, not the four review scopes converging:
  `CLAUDE.md` keeps those distinct by what each one *runs*, and none of the
  three may leave the checkout it was handed.
- **A legitimate bug fix could not close the TDD checklist.**
  `test-driven-development/SKILL.md` required every test to map to a row in
  **the plan's** Test Coverage Matrix and closed with "Can't check all boxes?
  You skipped TDD. Start over." — while `systematic-debugging/SKILL.md:177`
  invokes this skill for a bug fix, where there is no plan and no matrix. The
  box named an artifact that does not exist on that path, so the instruction
  was to start over on work that was correct.
  **The exception is declared where it is read**, in both places the rule
  appears: what it forbids is a test mapping to *nothing*, and the matrix is
  where the mapping is written down when a plan exists — on a bug fix the
  requirement is the reported bug and the mapping is the test that reproduces
  it. The absence of a matrix is not a licence, which is why the rule is
  restated rather than exempted.
- **The fix-round report named one cap while two exist.**
  `subagent-driven-development/SKILL.md:34` told you to report "which round, of
  five" with no condition, and the final fix wave is capped at three
  (`references/final-review.md:56`). Inside that wave the mandated report stated
  a denominator that does not exist, telling the partner they had two rounds
  left when they had none. The report now takes the cap of the loop it is in and
  says which, since the whole point of the line is where the work stands.
- **`executing-plans` offered a route its own premise excludes.** Shipped one
  commit earlier, in the `**Execution:**` reader: on a plan whose header names
  the subagent path, `SKILL.md:63` told you to present switching to
  `subagent-driven-development` as a choice — while `:14` defines this skill as
  the path for when subagents are **not** available. Two ways reach this skill,
  and the offer is real for only one of them: the partner who chose inline on a
  harness that has subagents can switch, and the harness that has none cannot.
  The offer is now conditioned on subagents actually being available, and the
  situation is stated out loud either way, because "no subagents here" and "I
  did not check" read identically in silence. The ledger read moves ahead of the
  branch and happens in both cases — it holds the exact resume point regardless
  of which path continues.
- **The merge/PASS deadlock `1.4.0` closed reappeared on a second pair of
  files.** Same anatomy, different collision: after the final fix wave's third
  iteration `subagent-driven-development/references/final-review.md:59-65`
  parks what is still open and promises those residuals reach the partner
  "when finishing-a-development-branch presents the options" — while
  `finishing-a-development-branch/SKILL.md:32-33` presents no option before the
  audit returns PASS and `:38` routes a FAIL back into a fix wave that is
  exhausted at its own cap of three. A parked audit gap leaves its row NOT
  DELIVERED, so the verdict never turns, and the promised presentation could
  not happen by any route. Nobody noticed because each file is correct read
  alone.
  **Closed with the existing mechanism, and no new state was invented.**
  `parked with a ruling` already exists — the task loop's breaker at
  `subagent-driven-development/SKILL.md:392-402` — and it already has the four
  properties `1.4.0` established for a state that leaves the FAIL computation:
  declared by a named actor, terminal, checked rather than believed, and
  riding beside the verdict as a named pending item. What was missing is that
  `finishing-a-development-branch` never learned to read it. It now carries a
  fourth row: a FAIL whose every open row is a parked residual continues to the
  menu with those rows presented beside the options — the treatment
  OUT OF SCOPE — DECLARED already gets at `final-branch-audit/SKILL.md:342` —
  and the parking is checked, never believed (each row carries its ruling, the
  ledger shows the cap was reached), because a parking nobody checks is
  absolution by assertion.
  **OUT OF SCOPE — DECLARED was considered for reuse and rejected.** It means
  *its turn has not come*; a parked residual means *promised, absent, and three
  waves could not close it*. Collapsing those is the exact distinction `1.4.0`
  exists to hold. The mechanism was reused; the verdict name was not.
  Two collisions the fix surfaced were repaired in the same pass: the
  rationalization row "the audit failed on one row, that's close enough to
  merge" said "present no menu until it PASSes", which the new row contradicts
  head-on — it now names the one FAIL that reaches the menu and keeps the
  guard against deciding it yourself. And a reader of that table alone could
  not see that FALSE COMPLETION cannot arrive by the new row; it is never
  parked, and the table now says so.
- **The third uncapped correction loop now has a ceiling.** `executing-plans`
  Step 3 said "audit FAIL: fix and re-run" with no limit — the same anatomy
  `1.5.0` closed in `brainstorming` and `writing-plans`. Three, derived and not
  copied: the task loop's five exist because rounds 4–5 change the actor, and
  this path cannot change actor at all — it is the path for when subagents are
  not available, and it names no dispatch and no model anywhere, so the same
  agent fixes and re-audits every round. Its structural match is the
  constant-actor final fix wave, also three. The two sibling rules came with
  it: at the cap the open rows go to the partner in the escalation shape rather
  than into a fourth round, and a row that returns to NOT DELIVERED after being
  fixed escalates immediately, because either two criteria collide or the
  criterion is one no evidence can settle — and rounds only re-run the
  collision.
- **The `**Execution:**` field now has a reader.** `1.6.0` added it to the plan
  header so whoever resumes a plan would not have to guess which path it was
  started on, and then neither execution skill consulted it — a rule with no
  reader. Both now read it at setup. A field naming the other path means the
  plan is being resumed by a divergent route, and that goes to the partner in
  the escalation shape before anything runs, with what each side costs: from
  `executing-plans`, the ledger the field names may still be on disk and holds
  the exact resume point, so continuing inline abandons a record that exists and
  can be read; from `subagent-driven-development`, switching to the recorded
  inline path buys continuity with a record that did not outlive its session,
  while continuing means the ledger starts empty and what is already done has to
  come from `git log` and the plan. A plan with no such field predates the field
  and is not an error: proceed, and write in the path being taken.

## [1.6.0] - 2026-08-03

### Added

- **Progress reaches the partner on both execution paths.** Neither path said
  anything between "starting" and "done": `subagent-driven-development` ruled
  out check-ins and progress summaries, and `executing-plans` moved todos the
  partner cannot see. Executing without stopping was being read as executing in
  silence. Both skills now report at four fixed points — starting (task count,
  which path, where the record lives), each task done, entering a fix round,
  finishing — one line each. A report asks nothing and waits for nothing, so it
  does not reopen the check-ins that were ruled out for good reason, and it
  carries no gate vocabulary: `NOT DELIVERED` and its siblings stay in the
  machine-to-machine reports where they are precise.
- **Recorded that no gate can check those reports.** They happen in the chat,
  which no reviewer, audit or re-review reads. Both skills say so at the point
  the rule is written, and say not to mirror the reports into the ledger to
  make a verifier possible — the ledger exists to resume work, not to prove
  somebody was told. Without this, the next reader finds an unenforced rule and
  builds the enforcement it appears to be missing.
- **A declared resume route on both execution paths.**
  `subagent-driven-development` knew how to read a ledger but never said what
  to do with the reading: the resume point is now checked against `git log`
  (the ledger claims, git holds) and presented to the partner in the escalation
  shape before anything is dispatched — the one moment continuous execution
  does not cover, since everything after it rests on a starting point nobody
  checked. Two shapes the ledger rules could not describe, because in both the
  ledger is what is missing, are now covered: no ledger with work already in
  the branch (a `git clean -fdx` away, and read as an unstarted plan it becomes
  the re-dispatch of a finished sequence), and a task with neither a completion
  line nor a report, where the interruption landed inside a dispatch.
- **`executing-plans` declares its own limitation instead of leaving it to be
  discovered.** Session todos do not outlive the session, and no ledger is
  invented here to pretend otherwise — this path is for work that finishes in
  one sitting, and a plan that keeps outliving its session is saying it belonged
  on the other path. The skill now says that out loud at the start and gives the
  route when it happens anyway: reconstruct from `git log` and the plan, state
  the evidence per task, and get the partner's confirmation before executing.
- **The plan header records which path was chosen.** New `**Execution:**` field
  — the path and where progress is recorded — filled at the handoff, since the
  answer was otherwise held only in the conversation an interruption takes away.
  The plan review does not check it and is not asked to: the review runs at
  `writing-plans` Plan Review and the field is filled at Execution Handoff,
  after it, so charging it would charge a future event.

### Fixed

- **The execution offer carries what decides it.** It presented two option
  names and one line each, and withheld the difference that matters most: the
  subagent path writes progress to a file and is resumable after an
  interruption, while the inline path tracks with session todos that do not
  outlive the session. Neither option name hints at that, and it is what a
  partner discovers only after it costs them. The offer now goes in the
  escalation shape the skill already carries, states the plan's real task count
  taken from the plan, gives each option's cost in one line, and declares the
  criterion behind the recommendation instead of the bare word "recommended" —
  then says which side of that criterion this plan falls on, so the partner is
  not left doing arithmetic already done.

## [1.5.0] - 2026-08-03

### Fixed

- **The brainstorming user-review gate presents the pending decisions instead
  of asking for a file to be read.** The gate prescribed exactly one utterance —
  the spec was written, please review it — while the spec at that moment holds
  open decisions in three places: every item of `## Assumptions to Confirm`,
  every `Deferred` or `Outstanding` row of `## Coverage Map`, and any
  end-of-life dependency finding. The instruction for that last one already said
  it was "for your human partner to decide", and its verb was still *report
  under a section*. All three now go to the partner in the escalation shape,
  carried at the point of use as the other five trigger points carry it, before
  approval is requested. One message with every escalation, not one message each:
  at this gate the decisions are frozen in the document, so nothing reorders
  anything, and serializing would turn the gate into a second interview after the
  design was approved. The list is not truncated — it is ordered by impact ×
  uncertainty, the criterion the interview already uses. Nothing pending is said
  in words, for the reason a state carries its reason: "there was nothing" and "I
  did not look" must not render identically. The reviewer is deliberately not
  made to audit this — it runs at step 8, one step *before* the gate, so charging
  it would be charging a future event.
- **The brainstorming spec-review loop has a ceiling and an escalation.** It
  said to fix every blocking issue and re-dispatch, with no bound, against a
  reviewer carrying three blocking sections and twenty-five individual blocking
  verdicts — a fix satisfying one can trip another, and each round costs a fresh
  subagent. Capped at **three rounds**, and the number is derived rather than
  picked: the task loop's five exist because rounds 4–5 swap in a fresh
  implementer on a more capable model, an escalation this loop does not have, so
  it matches the constant-actor final fix wave, which is three. At the cap the
  open blockers go to the human partner in the escalation shape with the options
  and their cost — accept with the gap declared, rewrite the section, or stop.
  A blocking issue that reappears after being fixed escalates immediately
  regardless of the round: two reviewer rules are colliding, and further rounds
  only re-run the collision. The Process Flow carries the cap too, so the
  flowchart and the prose in one file do not disagree — the divergence `plus.24`
  had to repair.
- **The escalation format's list of carriers matches the measurement.** It
  named four skills; six files across five skills carry the four-item block —
  `subagent-driven-development` carries it twice, in its `SKILL.md` and in
  `references/final-review.md`, and `brainstorming` became a carrier in this
  same cycle without being added. A file that enumerates where a rule lives is
  a rule itself, and one that undercounts sends a reader looking in four places
  for something that is in six. Now listed in pipeline order, so the list can be
  checked against the workflow rather than against memory. The file stays at 61
  lines.
- **The plan-review loop has the same ceiling, derived the same way.** It
  carried the identical unbounded sentence for the plan reviewer. Measured
  before choosing a number: this loop keeps one actor — the same prompt, handed
  the plan file path and nothing else, reading the same document every round,
  with no model selection or fresh-versus-resume distinction anywhere in the
  skill. Constant actor means the task loop's five do not apply, and the match
  is again the final fix wave at three. Its blocking surface is smaller than the
  spec reviewer's — one blocking section and eleven verdicts against three and
  twenty-five — which lowers the odds of a collision without changing what the
  number rests on. At the cap the open blockers go to the partner in the
  escalation shape the file already carries, with the options and their cost:
  accept with the gap on the task's justification line, rewrite the section, or
  go back to the spec. A blocker that reappears escalates immediately. Nothing
  to synchronize in a flowchart here — `writing-plans` has no `dot` graph.

## [1.4.0] - 2026-08-03

### Added

- **The conformance audit accepts a scope declared by whoever dispatches it.**
  Found in real use: an audit was dispatched on a branch whose last tasks
  could not have been delivered yet, and it returned FAIL entirely because of
  them. The report body had it right — "not started, as determined" — and the
  verdict collapsed *promised and absent* into *its turn has not come*, because
  nothing in the skill distinguished the two. Before this, the audit's universe
  was fixed at every task in the plan and the only axis was having a citation
  or not.
  **What the investigation found underneath was a deadlock, not just a missing
  state.** The branch's last tasks were merge, deploy and a hand-run smoke —
  the normal shape of a plan in this flow — and those two rules cannot both be
  satisfied: `finishing-a-development-branch/SKILL.md:32-33` presents no merge
  option until the audit returns PASS, and the audit's PASS rule (then at
  `final-branch-audit/SKILL.md:237-239`, now at `:285-286`) required every task
  row DELIVERED, merge included. The merge waited for the PASS and the PASS
  waited for the merge. The `Fixed` entry below closes that half by taking
  those tasks out of the plan; this entry closes the half that survives a
  correct dispatch, since a task dispatched before its turn is not always an
  operational one.
  - A dispatch slot at `final-branch-audit/SKILL.md:211`,
    `**Tasks outside this execution's scope:**`, default `none`.
  - A verdict of its own, OUT OF SCOPE — DECLARED (`:134`), distinct from NOT
    DELIVERED, which `:285-286` now accepts for PASS.
  - **The declarant is whoever dispatches, never the plan and never the
    ledger.** A plan declaring its own tasks out of scope is the plan edited to
    stop asking, which Handling the Result already forbids; and ledger silence
    reads identically for a task whose turn had not come and one the loop
    skipped in silence — collapsing those two is the distinction the audit
    exists to hold. `subagent-driven-development/references/final-review.md:15`
    tells the controller to fill it.
  - **The declaration is searched, never believed** (`:156-160`). Code found
    for a declared-out-of-scope task means the declaration is false: that task
    is audited normally and the false declaration reported separately. Without
    this the slot is absolution by assertion and evidence-or-zero falls.
  - **The state is terminal, and that is the point.** An out-of-scope task is
    not a promise to become DELIVERED in a later audit — it leaves this
    execution's table as a named pending item for the human partner. Scope
    alone would only have postponed the FAIL: a hand-run smoke that later
    happens still produces no test citation, and
    `final-branch-audit/SKILL.md:130` would charge it the moment it re-entered
    the table. That is a different axis from scope, and the terminal state is
    what keeps the two from being confused.
  - **No weaker kind of evidence was invented for human verification.** A
    record of who ran a manual check and when is the executor's own word,
    which the skill refuses from everyone else. The auditable universe shrinks
    and says so; nothing is absolved. A PASS carrying declared pending items
    presents them beside the verdict, before any merge option (`:342`).

  **Not covered, by standing decision:** an acceptance criterion a human
  judges — visual, UX, copy, a screen-reader pass. `writing-plans/SKILL.md:201`
  requires a criterion a citation can settle, and that remains the project's
  position rather than an open gap.

### Fixed

- **Work that leaves nothing in the repository is not a plan task.** The rule
  is the audit's own test, not a new one: does the task leave something a
  `path/file.ext:line` citation can prove? Merging, deploying, applying a
  migration to a real environment, publishing a release, a hand-run smoke,
  watching a metric after rollout — none do. Stated at
  `writing-plans/SKILL.md:51` and charged as a blocking row by
  `plan-document-reviewer-prompt.md:33`. **Named as a category with those six
  as instances, deliberately:** a closed list silently accepts the instance
  nobody predicted, and a bare category is undecidable for a blocking gate —
  the citation test is what makes it decidable.
  Written into the plan, those tasks deadlock the flow: the merge waits for a
  PASS (`finishing-a-development-branch/SKILL.md:32-33` presents no option
  before it) and, undeclared, the PASS waits for tasks nobody could have run
  yet (`final-branch-audit/SKILL.md:285-286`). Observed on a real audit: FAIL
  caused entirely by those tasks, with the report body correctly recording
  them as not started. **The destination is stated precisely because the first
  draft of this entry got it wrong:** it said the work "belongs to
  `finishing-a-development-branch`", and that skill has **zero** occurrences
  of `deploy`, `smoke`, `staging`, `release`, `publish`, `canary` or `monitor`
  — measured, `grep -c`. Its seven steps end at merge, PR, or keep-as-is. The
  work happens after the PASS, outside the plan: the merge through that skill,
  the rest in your human partner's hands. A rule pointing at an empty house
  sends the next reader looking for what is not there.

- **CI ran twice on every release commit. Resolved.** Measured before touching
  anything, and the obvious hypothesis was wrong: it is not a `push` /
  `pull_request` overlap. Both runs carried `event: push`, one with
  `headBranch: main` and one with `headBranch: v<version>`. `push` fires per
  pushed **ref**, not per commit, and a release pushes two refs at the same
  commit. Reproducible at `e3692db`, `72d1ec7`, `5da8c43`, `c012d27` and
  `767fb13` — every release — while a push carrying no tag produced exactly one
  run. `pull_request` was never the cause and has never fired here at all: 34
  push events and zero pull-request events across the 100 most recent runs,
  which is what a repository with no PR process looks like.
  The fix is `branches: ['**']` under `push` at `.github/workflows/ci.yml:7-15`.
  Naming `branches:` at all excludes tag refs, which is what removes the second
  run; `'**'` keeps every branch, so a work branch with no PR open is still
  gated. **The narrower filter that suggests itself — `branches: [main]` plus
  `tags:` — was measured and rejected twice over:** it keeps exactly the two
  refs that duplicate, so it does not fix this, and it would leave a work branch
  without an open PR passing through zero gates, since `pull_request` does not
  fire in this repository. Coverage is worth more than a minute of CI.
  **Do not re-investigate: the cause is measured and the fix is in place.**

## [1.3.0] - 2026-08-03

### Added

- **A finding whose root cause the reviewer can name is reported as a class,
  not as one case.** This came out of use, not analysis: two rounds of review
  of the same plan surfaced two broken tests with the **same** root cause — a
  payload change that invalidated assertions about a removed field — one per
  round. The second one appeared because the reviewer happened to be diligent,
  not because any rule asked for it: `grep` over the four review prompts found
  no instruction to look for the remaining members of a finding's class, and
  the closest thing that existed
  (`task-reviewer-prompt.md`, "one focused check per named risk") fires on a
  risk named *before* any finding exists.
  Both first-round gates now sweep the scope under review for the other
  members of the cause and report them as one finding with `file:line` per
  member, and a sweep that found no siblings declares it — "no other cases"
  and "did not look" read the same in a report. The wording is one sentence
  and the same hinge in both, "the scope under review", which each file has
  already bound to its own reach: the task diff at
  `task-reviewer-prompt.md:41-46`, the branch range at `code-reviewer.md:25-31`.
  In the task reviewer the sentence names the call sites of a cross-cutting
  cause as part of the sweep rather than a separate excursion — without that
  clause the rule misses the very case that produced it, because a payload
  change leaves its broken assertions in files the task diff never touched.
  `code-reviewer.md`'s worked example now shows a grouped finding and a
  declared negative — an example showing only isolated findings teaches
  isolated reporting.
  Three per-finding phrasings that competed with grouping were reconciled in
  the same pass, found by sweeping the new rule over its own diff:
  `task-reviewer-prompt.md:133` (the shallow-test litmus said "report each"),
  `task-reviewer-prompt.md:207` and `code-reviewer.md:112` (both described one
  `file:line` per issue). One cause, three members, one entry.
  **Two of the four review scopes deliberately do not get this rule.**
  `re-review-prompt.md:50-54` forbids re-reviewing code the fix did not touch,
  and that prohibition is what bounds the fix loop; a class sweep there would
  collide with it head-on, and is unnecessary once the first round sweeps.
  `final-branch-audit` already enumerates exhaustively — one row per criterion,
  none omissible — so sweeping by cause visits nothing its table does not
  already visit. This keeps the four scopes distinct, as `CLAUDE.md` requires.

## [1.2.5] - 2026-08-02

### Added

- **The fix loop verifies a finding before implementing it, and a contradicted
  finding becomes a dispute instead of a blind fix.** `receiving-code-review`
  taught "verify before implementing" and nothing in the invocation graph
  reached it — `grep -rn "DISPUTED\|dispute" skills/` returned zero, and the
  implementer was told to fix findings, full stop. The fix prompt now has the
  implementer read the code a finding names and report **DISPUTED** with the
  `file:line` that contradicts it, citing `superpowersplus:receiving-code-review`
  as the source of the principle; the re-reviewer rules **CONFIRMED** or
  **WITHDRAWN** after reading the cited code itself.
  Four rules keep disputing from becoming the cheap way out of a round, because
  a dispute path without them is an escape hatch: the **re-reviewer** rules and
  never the controller (author≠verifier, the same split the rest of the flow
  runs on — and explicitly *not* the early adjudication `SKILL.md`'s breaker
  forbids); a dispute **rides into the same round's** re-review and never closes
  one; a **CONFIRMED dispute counts NOT ADDRESSED** against the existing round
  cap, so disputing everything burns the cap at the speed of fixing nothing —
  no new counter; and a dispute **open at the cap escalates** with both pieces
  of evidence, never parked, since parking one is the controller ruling on it.
  DISPUTED / CONFIRMED / WITHDRAWN are the only states. The process-flow digraph
  carries the change on the existing nodes rather than a new branch — a separate
  node would draw a dispute as its own path, which is what rule two forbids.

- **`CLAUDE.md` records what the pre-commit hook costs, and three decisions
  that were being re-derived per session.** The cost, measured 2026-08-02 as
  the median of three warm-cache runs: 3 ms each for the three index-reading
  checks, 29 ms for `check-links.sh`, 41 ms for the hook end to end. The table
  carries its method and its condition, because an independent measurement the
  same day came out roughly 7× higher — almost all of `check-links.sh` is
  `python3` startup, which moves with the machine. **No automatic timer**, on
  purpose: it would report a number nobody reads on every commit. If a commit
  ever visibly drags, timing the checks one at a time is the first step and
  that table is the baseline.
  The three decisions: `check-links.sh` stops at the root institutional files
  plus `docs/` because `skills/**` is upstream text whose relative links move
  at every rebase; third-party links stay at the attribution minimum; and
  third-party links are **not** verified — a dead external link is found by
  clicking it, and the project takes that over a network call per link that
  would turn CI red for reasons unrelated to the commit.

- **`CLAUDE.md` records three things that were being re-derived, or re-reported
  as outstanding, every session.** Waiting on CI anchors on the pushed
  **SHA** — `gh run list --commit "$sha"` — never `--limit 1`: between a push
  and the query the list still holds the *previous* run, concluded and green,
  and it reads exactly like a pass for the commit CI has not started on yet.
  Same failure class as the `--repo` rule above it, and the same reason reads
  are covered: a wrong read is indistinguishable from a right one.
  `dispatching-parallel-agents` is **orphaned in the invocation graph on
  purpose** — it fires on its description, which is how a skill applying to any
  fan-out is reached without every caller naming it; wiring an invocation in
  would imply parallel dispatch belongs to whichever skill made the reference.
  And `escalation-format.md` at **61 lines against a ~60 target is closed**:
  every block was re-read and carries distinct normative content — the scope
  boundary, why the file exists, why item 4 is an action rather than a quality
  bar, gate vocabulary, the self-test, the worked example — so cutting to reach
  the number costs the content the file exists to carry.

- **The third-party link diet is a gate, not a convention.**
  `check-links.sh` now fails on a URL whose prefix is outside four allowed
  ones — `github.com/rodrigopaitach/`, `raw.githubusercontent.com/rodrigopaitach/`,
  `img.shields.io/`, and `github.com/obra/superpowers` for attribution. Still
  **zero network calls**: fetching a link and reading its domain are different
  questions, and this answers only the second, so the gate cannot go red
  because somebody else's site is slow.
  It reads **raw lines, fenced blocks included** — deliberately unlike the
  local-link pass, which blanks them out. The defect that motivated this gate
  was an install command naming the wrong repository, and an install command
  lives inside a fenced block; a diet that skipped them would have missed the
  only thing it was built for. `docs/PLUS-CHANGELOG-historico.md` is exempt
  from the **diet only**: `check-frozen-history.sh` already refuses any change
  to it, so it cannot acquire a new link by construction, and watching the
  immutable is a check with no function. Its local links and anchors stay
  checked — freezing a file does not freeze the files it points at.
  Twelve new cases in `tests/hooks/test-check-links.sh` cover both branches,
  each verified by the mutation that attacks its own mechanism: disabling the
  diet, dropping the frozen-history exemption, making the diet skip fenced
  blocks, and removing each allowlist prefix in turn. Measured green across the
  twelve scanned files: 38 local links resolve, 50 URLs on the diet.

### Fixed

- **The harness guides installed the upstream project.** `docs/README.kimi.md`
  and `docs/README.opencode.md` are installation instructions, and both told the
  reader to fetch `obra/superpowers` — the OpenCode one pinned to `v5.0.3`, a
  release of a different project. `README.md:91` links them as the "detailed
  docs" for those two harnesses, so a reader followed a correct instruction into
  a wrong one. `.opencode/INSTALL.md` already carried the right spec
  (`superpowersplus@git+…/superpowersplus.git`); only these two were left
  behind. Clone URLs, issue links and the package name now name this
  repository; the version pin is a `#<tag>` placeholder rather than a number,
  which would rot at every release or become an eighth file for
  `bump-version.sh` to carry.
  Two adjacent defects of the same class, found in the sweep: the Kimi guide
  routed installs through `Marketplace` > `Superpowers`, which is the upstream's
  listing and not this project's, and its three diagnostic commands read
  `/plugins info superpowers` while `.kimi-plugin/plugin.json` declares
  `superpowersplus` — inspecting a plugin that does not exist here. `dev` became
  `main`, this repository having no `dev` branch.

- **`docs/testing.md` documented a directory that is not in this checkout.** It
  described `evals/` as one of the repository's two test suites and gave a
  runnable `cd evals && uv sync` quick start; `evals/` is a separate repository,
  excluded by `.gitignore:13`, and absent. The file also listed six `tests/`
  directories where there are **thirteen**, naming none of the ten CI actually
  runs. Both corrected against `.github/workflows/ci.yml`, with the invocation
  claim dropped rather than guessed — only five of the thirteen have a
  `run-*.sh`, and there is no root `npm test`.

- **`docs/porting-to-a-new-harness.md` was swept for the same defect and is
  clean** — no change. Its `obra/superpowers` reference at line 24 is already
  labelled ("superpowersplus carries no PR template; that work targets
  Superpowers"), and line 734's "template to clone" is a script, not a
  repository.

### Changed

- **Third-party links cut to what attribution requires: 65 → 43 across the
  seven documents this project owns.** Everything that remains is either the
  repository's own infrastructure (badges, releases, Actions, issues, security
  advisories, clone and install commands — 38 of the 43) or attribution: one
  link to `obra/superpowers` per document where the attribution appears
  (`README.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and both
  `docs/README.*`), plus the `44c9b2d` commit that records the rebase base and
  is functional rather than decorative.
  - Turned into plain text, identifying without linking: repeated
    `obra/superpowers` mentions, `blog.fsck.com` and `primeradiant.com` (the
    credit line already names Jesse Vincent and Prime Radiant), the
    `claude.com/claude-code` requirement line in both `docs/README.*`,
    `keepachangelog.com` and `semver.org` (naming the format and version does
    the same work), and the four `contributor-covenant.org` URLs plus the
    Mozilla one in `CODE_OF_CONDUCT.md`, where "Contributor Covenant,
    version 2.0" preserves the attribution the license asks for.
  - Removed outright: the 2025 release-announcement link, which supported
    neither attribution nor a working instruction.
  - Left alone on purpose: `docs/README.kimi.md` and `docs/README.opencode.md`
    are upstream text, where editing buys a rebase conflict and nothing else,
    and `docs/PLUS-CHANGELOG-historico.md` is frozen — `check-frozen-history.sh`
    rejects it regardless.

## [1.2.4] - 2026-08-02

### Added

- **`scripts/check-links.sh` — local links and their anchors are verified in
  the hook and in CI.** It scans `README.md`, `CONTRIBUTING.md`, `SECURITY.md`,
  `CODE_OF_CONDUCT.md`, `CHANGELOG.md` and every `docs/*.md`: the destination
  file exists, and where a link carries an anchor, a heading with that slug
  exists in the destination. **It is green today** — 36 local links across 12
  files, none broken. It closes a coverage gap rather than a defect:
  `check-docs-sync.sh` only ever looked at the two bilingual READMEs, so the
  other five files in `docs/` had no gate at all.
  - Anchors follow GitHub's rules, calibrated against headings this repository
    actually has: accents survive (`#pendências-conhecidas`), an em dash
    surrounded by spaces leaves **two** hyphens, emoji strip to a leading
    hyphen, backticks come off, and duplicate headings get the `-1` suffix.
  - **`http`/`https` links are ignored on purpose**, with the reason in the
    script: a network call per link turns a deterministic gate into one that
    goes red when a third-party site is slow or rate-limits CI, and a gate that
    goes red for reasons unrelated to the commit stops being read.
  - **It runs on the whole tree, not on the staged range.** A link breaks when
    its *destination* disappears, and `README.md` cites
    `tests/skill-behavior/RESULT-escalation-format-in-chat-v3.md`, which is not
    one of the scanned files — gating on "a scanned file is staged" would miss
    the commit that renames it. Measured at 30ms for the whole repository.
  - Covered by `tests/hooks/test-check-links.sh`, 16 cases in throwaway trees.
    Each positive case was confirmed by mutation: stripping accents from the
    slug, keeping fenced code, and treating `https` as local each broke exactly
    the one test that targets it.

### Changed

- **`CLAUDE.md` declares the documentation hierarchy and one class of false
  positive**, both of which were being rediscovered per session. The hierarchy,
  measured rather than assumed: `README.md` is the showcase (170 lines),
  `docs/README.pt-BR.md` is the canonical reference (153), `docs/README.en.md`
  is its translation, and `scripts/check-docs-sync.sh:14-15` gates exactly
  those last two. **Structural divergence between showcase and documentation is
  deliberate** — they answer different questions — so nobody should
  "harmonize" them; what ties them together is their links, now verified.
  The false positive: the bump audit will eventually flag a version constant in
  an upstream test fixture that collided with the real version by coincidence
  (`tests/codex-plugin-sync/test-sync-to-codex-plugin.sh:8` at `1.2.3`). The
  warning undoes itself at the next bump; an `audit.exclude` entry is permanent
  and would blind the whole file to a genuine leak later.

### Fixed

- **The CI badge matches the other two.** It was the Actions default
  (`actions/workflows/ci.yml/badge.svg`), which takes no style parameter and so
  rendered in a different shape than the shields badges beside it — rounded
  corners and a fixed 90px width against `flat-square`'s square corners and
  fitted width. Replaced by the shields equivalent with `style=flat-square`,
  keeping the link to the Actions tab. Two notes for whoever changes it next:
  the shields path takes the **workflow file name** (`ci.yml`), not the
  workflow's `name:` field, and rendering was verified as `passing` before the
  swap. Applied to all three READMEs.

## [1.2.3] - 2026-08-02

### Added

- **The READMEs show one measured escalation instead of describing the
  format.** A new section in all three (`README.md`, `docs/README.pt-BR.md`,
  `docs/README.en.md`) carries a condensed transcript from
  `tests/skill-behavior/RESULT-escalation-format-in-chat-v3.md` — the run that
  scored 3 of 3 after 1 of 3 and 2 of 3. It is the only passage in this project
  with evidence of working, and it shows the four load-bearing parts in one
  screen: consequence before mechanism, cost per option, doing nothing as a
  real option, and a recommendation naming its source. Prose describing the
  format cannot demonstrate the format.
- **CI and license badges next to the release badge**, both dynamic: the
  Actions workflow badge for `ci.yml` and the license badge resolved from the
  repository. A release badge alone says a version exists, not that it builds.
- **`SECURITY.md`.** Supported version (the latest release only — one line of
  work, no backports), the two reporting channels, and the telemetry posture in
  one place: this project collects nothing, and the one inherited exception is
  named with the three environment variables that disable it and the line that
  honors them, `skills/brainstorming/scripts/server.cjs:107-112`. It also states
  what the threat surface actually is, since "plugin" suggests more than a set
  of Markdown skills and shell scripts with no dependencies.

### Changed

- **`CONTRIBUTING.md` covers working on the code, not only the refusal to take
  contributions.** It went from 20 lines stating there is no PR process to also
  carrying: how to report, development setup (including
  `git config core.hooksPath githooks`, without which none of the gates run for
  you), the full list of runnable suites with the clean-tree warning on the
  Codex packaging one, and release discipline **by reference** to `CLAUDE.md`
  rather than duplicated — a second copy of a rule is a copy that goes stale.
- **Repository metadata filled in, and the issue channel actually opened.**
  Description, homepage pointing at the latest release, ten topics, wiki and
  projects off. The finding while doing it: **issues were disabled**
  (`has_issues: false`), while `CODE_OF_CONDUCT.md` and `CONTRIBUTING.md` had
  been naming issues as the single reporting channel — every one of those links
  led nowhere. Private vulnerability reporting was off too, which
  `SECURITY.md` depends on. Both are on now. A documented channel that does not
  exist is worse than none: it reads as an invitation and silently drops
  whoever accepts it.
- **`CODE_OF_CONDUCT.md` says who "community leaders" are here.** The inherited
  Contributor Covenant text is unchanged; the header now states that
  superpowersplus is its own project, that "community leaders" means this
  repository's maintainer, and that "community spaces" means this repository's
  issues — the only place the document can apply, given that the project takes
  no outside contributions.

## [1.2.2] - 2026-08-02

### Changed

- **`--repo` is required on every `gh` invocation, reads included.** The rule
  covered outward-facing operations; it now covers all of them, in its own
  `Running gh` section of `CLAUDE.md`. The case that widened it happened while
  confirming the `1.2.1` release: `gh run list --branch main` returned runs
  from `obra/superpowers` — a month old, `conclusion: success`, shaped exactly
  like the answer being looked for. Nothing errored. Taken at face value it
  would have confirmed a CI run that never happened. A wrong write announces
  itself; a wrong read does not.

### Fixed

- **The changelog and frozen-history gates are applied by CI, not only
  tested.** Both lived exclusively in the pre-commit hook, which a clone
  without `git config core.hooksPath githooks` never runs — the precise silent
  failure the header of `.github/workflows/ci.yml` says CI exists to make
  visible. CI ran their tests and did not run them. Neither needed a `--range`
  mode: the workflow already rewinds the index to the pushed range with
  `git reset --soft`, so for these scripts the range *is* the index, which is
  what the existing `Put the pushed range in the index` step was built for.
  Proven on a throwaway branch rather than asserted: a push whose range added
  a skill file while `CHANGELOG.md` came out net-unchanged failed the gate, and
  the follow-up push that carried the entry passed. A rebase onto the upstream
  does not trip it — the "Upstream base" line is updated at every rebase, so
  `CHANGELOG.md` is always in the range.

## [1.2.1] - 2026-08-02

### Added

- **`scripts/check-changelog.sh` — the changelog rule now has a gate.** A
  commit staging anything under `skills/`, `scripts/`, `githooks/`, `.github/`
  or `hooks/` without `CHANGELOG.md` fails in the pre-commit hook, naming the
  offending files and `git commit --no-verify` as the way out for a change
  genuinely not worth an entry. The rule existed in `CLAUDE.md` and broke
  inside the cycle that wrote it: `ab1cf41` shipped that rule and
  `check-skill-behavior-records.sh` with no changelog line, and the omission
  surfaced only when `1.2.0` was cut. Covered by
  `tests/hooks/test-check-changelog.sh`, which runs in CI — its first red
  caught the gate matching nothing at all, because a variable expanded in a
  `case` pattern is a glob but its `|` is not alternation, so the five prefixes
  were being compared as one literal string. A gate that never fires passes
  every commit silently.

### Fixed

- **CI covers every static test suite, not the five it happened to name.** The
  previous cycle wired four suites and reported two as still uncovered; the
  measurement was wrong — `kimi`, `opencode` and `pi` were orphaned too, for a
  real total of six. All are in `.github/workflows/ci.yml` now: `codex` (two
  scripts), `systematic-debugging`, `kimi`, `opencode` (without
  `--integration`, whose two tests need OpenCode installed) and `pi`. The only
  suites left out dispatch a live agent — `claude-code`,
  `explicit-skill-requests`, `skill-behavior` — which costs tokens and is
  non-deterministic. `CLAUDE.md` carries the full list so the next omission is
  visible rather than inferred.
- **`actions/checkout` and `actions/setup-node` moved from `v4` to `v7`.** The
  `v4` majors still run on the Node 20 runtime, whose removal GitHub has
  announced; CI was already annotating every run about it. Neither major
  breaks this workflow: checkout `v7` restricts fork PRs under
  `pull_request_target`/`workflow_run` and this one triggers on `push` and
  `pull_request`; setup-node `v7` adds cache outputs and drops a dummy
  `NODE_AUTH_TOKEN` nothing here reads.
- **`tests/pi/test-pi-extension.mjs` asserted the package's old name.** It
  expected `package.json` to declare `superpowers`; the rename at `ec529ee`
  made it `superpowersplus` deliberately. Same case `db91242` fixed for the
  Codex and Kimi manifests: the assertion reported an obsolete fact about this
  package's own name, not an upstream decision. The `.pi/` exception in
  `CLAUDE.md` protects the internal *path* `.pi/extensions/superpowers.ts`,
  which the same test checks and which passes untouched.
- **The HEAD/worktree trap in the Codex packaging suite is written down.**
  `tests/codex/test-package-codex-plugin.sh` reads its expected values from the
  working tree (lines 175-176) while the packager builds the archive from a git
  ref (`scripts/package-codex-plugin.sh:15`, `REF="HEAD"`; `--allow-dirty`
  permits a dirty tree but still packages the ref). With anything uncommitted
  the two disagree and the suite fails with no defect present — measured, a
  local `9.9.9` produced `expected: 9.9.9` against `actual: 1.2.0`, green again
  once reverted. It cost two debugging detours before being named. `CLAUDE.md`
  now says to run that suite after committing; the file is upstream's and is
  not changed here.
- **`CLAUDE.md` claimed two tests were left failing on purpose.** Both pass —
  `db91242` updated them. A rule whose example is false competes with the rule
  itself; the sentence now states the line it actually draws (a test watching
  an upstream *decision* stays failing; one reporting an obsolete fact about
  this package gets updated) instead of naming two files that contradict it.

## [1.2.0] - 2026-08-02

### Added

- **The escalation format, measured three times and corrected twice: 1/3 →
  2/3 → 3/3.** The rule crossed from *stated* to *held* by moving, not by being
  reworded. Run 1 (`RESULT-escalation-format-in-chat.md`): the shape lived in
  `references/` behind a one-line link, and under pressure the agent escalated
  — the behavior held — but the message had no do-nothing option, no declared
  source for its recommendation, and undefined vocabulary. Run 2, after the
  shape was summarized as a skeleton **at each of the five trigger points**:
  the do-nothing option and the declared source both appeared; the vocabulary
  criterion still failed. Run 3, after a **fourth item that is an action and
  not a standard** — reread the whole message once before sending and rewrite
  what an outsider would not know: **all three criteria held.** The insight is
  the split: items 1–3 describe what the message contains, checkable while
  writing; item 4 describes a pass over the finished text. Worded as a quality
  bar attached to item 3 it failed twice, because a bar is something a writer
  believes they already meet. An escalation-translator subagent was specified
  as the fallback and **not built** — the problem was *when* the check
  happened, not *who* performed it. Neither correction weakened a criterion:
  each failure is recorded as it happened, and each intervention moved exactly
  the criterion it targeted.

- **`scripts/check-skill-behavior-records.sh`**, run by CI: every fixture at
  `tests/skill-behavior/` declares itself a test fixture, and every recorded
  result carries its date, its model and a verdict per criterion. A result
  missing those cannot be compared against a later run, which is the only thing
  it exists for. It **never re-runs the adversarial tests themselves** — those
  dispatch a live agent, cost tokens, and are non-deterministic; re-running one
  is a human decision, and the policy is written down at
  `tests/skill-behavior/README.md`.

- **`scripts/release-notes.sh`** builds a release body from `CHANGELOG.md`:
  the version's section, then **Open gaps**, then the footer. Someone reading a
  release needs to see what is still open without clicking through. Applied
  retroactively to the 1.0.0 and 1.1.0 release bodies. The procedure used to be
  ad hoc; a release body that cannot be regenerated is a release body nobody
  can check.

### Changed

- **The escalation shape lives at the trigger point; the reference file keeps
  only what those four lines cannot carry** — the boundary they apply to, why
  the fourth item is an action rather than a standard, and the worked example.
  The file used to restate the four parts in full, so the same rule was written
  in two places and the canonical copy was not the one that had been measured.
  The inversion is the measurement's own finding: 1/3 with the shape reachable
  only through a link, 3/3 with it stated where the escalation fires.

- **Two method rules recorded in `CLAUDE.md`.** Content preparation and
  `git commit` are never chained in one `&&` block — prepare, verify the
  preparation produced what you expected, then commit; a failed edit and a
  commit on the next line are independent, which is how a change once shipped
  without its changelog entry. And `[Unreleased]` does not survive more than one
  cycle of work: when it tells a complete story, cut the version, because a fat
  `[Unreleased]` means `main` has drifted from the last installable release with
  no name describing the difference.

### Fixed

- **Four test suites CI never ran now run on every push** — `tests/shell-lint/`,
  `tests/hooks/`, `tests/codex-plugin-sync/` and `tests/antigravity/`. They
  existed, passed, and blocked nothing; three consecutive adversarial runs
  surfaced them unprompted, which is how the gap was found. Each builds its own
  temporary repository or reads files directly, so none depends on the
  checkout's index. Suites that dispatch a live agent stay out on purpose.
- **The scratch directories of the adversarial runs are matched by a glob**,
  `.skillrun*/`, instead of the three names `.gitignore` listed one by one. The
  third measurement used `.skillrun4/`, which no line covered — a pattern that
  has to be extended by hand at every run is stale at every run. Nothing was
  ever committed from one of these directories; the exposure was untracked
  scratch sitting visible in `git status`.
- **`scripts/check-docs-sync.sh` and `scripts/check-frozen-history.sh` missed
  deletions.** Both filtered staged paths with `--diff-filter=ACMR`, which
  excludes `D` — so `git rm` on one of the bilingual pair, or on the frozen
  history, passed in silence. The hooks guarded against unsynchronized
  *editing* and not against deletion, which is the most complete way to
  desynchronize. Filter is now `ACMRD`, verified across six staging states
  including deleting one of the pair (blocks) and deleting both (passes).
- **Release bodies are generated, not hand-written** — recorded in
  `CLAUDE.md`, together with the two mandatory guards for any outward-facing
  `gh` call, since `gh` has resolved to the upstream repository before.
- **The escalation format is referenced where escalation actually fires** in
  `subagent-driven-development` — the plan-mandated conflict, the breaker's
  load-bearing branch, and the residuals surfacing through
  `finishing-a-development-branch` — rather than only in the declaration near
  the top of the file.
- **English documents linking to the Portuguese historical changelog say so**
  before the reader clicks, and the `Open gaps` link label matches the section
  it points at.

## [1.1.0] - 2026-08-02

### Added

- **A single escalation format for anything crossing the machine → human
  boundary** (`skills/using-superpowers/references/escalation-format.md`): the
  finding as one sentence of practical consequence, 2–4 options each with what
  it means in practice (always including doing nothing now, with its cost), and
  a recommendation with its source declared. Gate vocabulary — `LOST IN
  TRANSLATION`, `INVENTED SCOPE`, severity labels — may ride along in
  parentheses but never carries the explanation. Generalized from the question
  form the coverage map already required. Internal reports between machines are
  explicitly out of scope and unchanged.
- **The escalation points reference it**: the final audit's three routes, the
  controller escalating a wrong plan or a hit iteration cap,
  `executing-plans`' "When to Stop and Ask", and a new library in a plan. The
  coverage map now points at the shared file for the *form* of a question,
  keeping only what is specific to the interview, so the two cannot drift.
- **Checking for end-of-life status is a declared investigation step**, not an
  optional one, for a central dependency. A version that still works and a
  version the vendor has stopped supporting look identical from inside the
  code. The reviewer already blocked a missing finding; the producing side now
  has the instruction to look.

### Changed

- **The Codex development marketplace is `superpowersplus-dev`** (display name
  `superpowersplus Dev`), in `.agents/plugins/marketplace.json` — the last
  identifier still carrying the upstream's name. Its assertions in
  `tests/codex/test-marketplace-manifest.sh` were updated in the same commit.
- **Every harness manifest carries the same description.** `.codex-plugin`,
  `.kimi-plugin`, `.cursor-plugin`, and `gemini-extension.json` still described
  Superpowers; they now use the text `.claude-plugin` already used, which
  describes this project and credits the origin. One string across five files,
  so they cannot drift apart.
- **Release badge in the README and in both language documents**, resolved dynamically from the GitHub API rather than pinned to a version string that would go stale at the next release (b343a67).
- **The four review faces are documented as deliberately distinct in scope**
  (`CLAUDE.md`): the task reviewer runs the *task's* command, the code reviewer
  the *project's* suite with a fallback, the re-review *re-runs* what already
  ran, and the final audit runs no tests at all — it re-runs the *searches*. An
  extraction into a common protocol was specified and abandoned once the map
  showed four rules rather than one written four ways; unifying them would
  change the reach of three gates at once.
- **Historical changelog carries a single-authority note**: the current state
  of the open gaps lives only in `CHANGELOG.md`, and the descriptions kept
  there record only when each was opened.
- **Escalation form is charged, without blocking.** The spec and plan
  reviewers report an escalation recorded with no practical consequence, no
  options, or no recommendation with a source as a form finding. The decision
  may have been sound; what is missing is the basis the partner had for taking
  it — and form does not hold up a document.
- **`docs/PLUS-CHANGELOG-historico.md` is declared frozen** in `CLAUDE.md` and
  takes no new writing. The live list of open gaps moved here, to
  [Open gaps](#open-gaps) — closing one now updates the maintained document
  instead of the archived one.

### Added

- **A dependency past end-of-life is a finding, never a migration.** When
  investigation turns up a central dependency the vendor documents as
  end-of-life or deprecated, brainstorming verifies it in the vendor's own docs,
  cites it, and reports it for the partner to decide — it does not migrate,
  upgrade, or rewrite around it, and does not fold the upgrade into the design
  as though it were part of the request. Migrating a stack is a project of its
  own, and its cost belongs to the partner. The spec reviewer blocks a cited
  EOL dependency with no corresponding item reported, at Groundedness severity.
- **`scripts/check-frozen-history.sh`**, wired into `githooks/pre-commit`:
  staging `docs/PLUS-CHANGELOG-historico.md` now fails with instructions to
  move the change to `CHANGELOG.md`. The declaration that the file is frozen
  had no verifier, which is the defect this project exists to separate.

### Fixed

- **`tests/codex/test-package-codex-plugin.sh` hardcoded the plugin name** in
  the expected manifest summary while reading the version from the manifest
  beside it, so it broke the moment the namespace was renamed. It now reads the
  name the same way. The failure had been reported as pre-existing on the
  strength of a `git checkout <ref> -- .` baseline; that measurement was
  invalid, because `scripts/package-codex-plugin.sh` packages from a git ref
  rather than the working tree, so the restored test file and the packaged
  manifest came from different commits. Re-measured in a full clone with a
  detached checkout: the test passes at `b6b68ef`, immediately before the
  rename.

## [1.0.0] - 2026-08-02

First release under this project's own version. Everything below is the
difference from Superpowers, condensed by axis rather than transcribed entry
by entry.

### Added

- **Evidence-grounded specs.** Every claim a spec makes about the codebase
  carries a `path/file.ext:line` citation plus the quoted snippet, and a
  reviewer subagent opens each one instead of trusting it. Required sections:
  `Codebase Findings`, `External Dependencies`, `Assumptions to Confirm` —
  where an absent section and an empty one must never look alike. (plus.1,
  plus.5, plus.15)
- **Dependency grounding.** A claim about a library, API, or service carries
  either the lockfile-pinned version plus the line read inside the installed
  package, or the vendor's own documentation for that version. Recollection
  and blog posts are neither. Enforced across the spec → plan boundary.
  (plus.12, plus.13, plus.16, plus.17, plus.18)
- **Plan contract, charged by a reviewer.** A subagent reads the spec against
  the plan and blocks a criterion with no task, a task with no origin, and a
  criterion with no test row. (plus.6)
- **Test Coverage Matrix.** Each task criterion mapped by key to the one test
  covering it — five columns, one row per criterion — with implicit
  requirements carrying ids and entering the matrix like any other. Task
  criterion ids (`T3.1`) are kept distinct from spec ids (`AC1`, `IR2`) so the
  audit cannot conflate them. (plus.3, plus.9, plus.10, plus.11)
- **Task reviewer that re-runs the suite.** The reviewer executes the tests and
  reports the output verbatim rather than accepting the implementer's report.
  (plus.3)
- **Task-by-task conformance audit.** At the end of a branch every spec
  criterion is traced to the tasks delivering it, in both directions, and given
  a verdict against located evidence: *lost in translation*, *invented scope*,
  *not delivered*. (plus.2, plus.4)
- **Coverage map for brainstorming.** Ten categories, four states each carrying
  its reason, an admission filter so only decision-changing gaps become
  questions, and priority by impact × uncertainty. Every question ships a
  recommendation with a declared source — a project pattern cited as
  `file:line`, the dependency's official docs, or general practice declared as
  such. Built so a partner who does not program can judge a recommendation's
  origin even when they cannot judge its technique. (plus.23, plus.24)
- **Least-code rule.** The implementer writes the minimum that meets the
  criterion and checks existing code, the standard library, and platform
  features before adding an abstraction; the planner picks the smallest
  structure that meets the criterion, and a new layer carries a one-line
  justification naming the criterion forcing it. A refused simplification
  leaves its reason in the plan. (plus.26, plus.27)
- **Adversarial skill-behavior tests** at `tests/skill-behavior/` — a fixture,
  the input carrying it, and a recorded result per rule. First rule measured
  rather than reasoned: the reviewer detected and reported an injected
  instruction in fetched documentation, and kept verifying. (plus.28)
- **Bilingual documentation** at `docs/README.pt-BR.md` (canonical) and
  `docs/README.en.md`, with a pre-commit hook that fails when only one is
  staged. (plus.25, plus.26, plus.28, plus.31)
- **CI** on push and pull request: the `brainstorm-server` suite, shell lint,
  and the bilingual-docs sync check — turning into a visible failure what
  fails silently when `core.hooksPath` is not configured locally. (plus.32)

### Changed

- **Plugin namespace is `superpowersplus`.** Skills reference each other as
  `superpowersplus:brainstorming`. Reverses an earlier decision to keep the
  upstream name, which rested on an estimated rebase cost; the measurement —
  26 of the upstream's last 426 commits touched those lines, 6% — reversed it.
  **Plans and specs written before `1.0.0` use the `superpowers:` namespace and
  must be read with that translation.** (plus.34)
- **Project identity.** Presents itself as its own project derived from
  Superpowers rather than as a personal fork. Attribution moved from a
  footnote to directly under the title in every entry document; `LICENSE` is
  untouched and the copyright remains with Jesse Vincent. (plus.33)
- **Own versioning from `1.0.0`.** The `version` field mirrored the upstream's
  `6.2.0`, a number describing different software. The upstream base is now
  recorded explicitly at the top of this file instead.
- **Authorship and repository metadata** point to this project. Attributing a
  package with 34 changes he did not write to Jesse Vincent erased the actual
  author and made him answerable for defects that are not his. (plus.34)
- **`CLAUDE.md` cut to well under half its length** — it described the upstream's
  contribution process, including a PR template removed here and an eval
  harness absent from this checkout, in a file loaded into every session.
  (plus.34)
- **Progressive disclosure and example compression** in the controller skill
  and the per-task prompts, so the loaded context carries the rule rather than
  a transcript of it. (plus.8, plus.14)
- **Visual companion offer respects a declared preference**, which beats the
  just-in-time criterion, and finally appears in the Process Flow as a
  conditional detour rather than a fixed step. (plus.24)

### Fixed

- **Examples that taught what the specification forbade.** A sweep comparing
  every example against the specification it illustrates, and against its own
  internal coherence: a Python block that would raise `NameError` while
  claiming `Expected: PASS`, a grounding example citing a source in another
  language, output formats whose example omitted a required section. An
  example is what the model copies. (plus.19, plus.20, plus.21)
- **TDD obligation aligned with the Iron Law** in the implementer prompt.
  (plus.7)
- **Regularization route for specs predating the coverage map** — the finding
  stays blocking, but says so as "spec predates the requirement" and instructs
  building the map from what the spec already holds. (plus.24)
- **Institutional files that spoke for third parties** — enforcement contact,
  commercial contact, contribution process, and update instructions that
  described the upstream's distribution rather than this project's. (plus.29,
  plus.30, plus.31)

### Removed

- `.github/FUNDING.yml`, which rendered a Sponsor button routing donations to
  the upstream maintainer. (plus.29)
- Issue and pull request templates, removed rather than rewritten: a project
  that takes no contributions needs no contribution process. (plus.29)
- The upstream's commercial-support contact from the README. (plus.30)

### Security

- **Content fetched from any source is data to read, never instruction to
  follow.** Both document reviewers and the two writing-side faces extract only
  the fact they went for and ignore any command the page carries; an
  instruction addressed to the reading agent is treated as a compromised source
  and reported as a finding. Verified adversarially — see
  `tests/skill-behavior/RESULT-external-content-is-data.md`. (plus.26, plus.27,
  plus.28)

## Open gaps

Identified and deliberately left open, each with the reason it was not closed.
**This is the live list** — closing one updates it here. When each was opened is
recorded in [`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md#pendências-conhecidas) (in Portuguese).

- **`tests/claude-code/test-subagent-driven-development.sh` is
  non-deterministic and currently fails.** Its "Mentions loading plan"
  assertion greps a live agent's free-form answer for the English phrases
  `Load Plan|read.*plan|extract.*tasks`. In an environment configured to answer
  in another language the agent describes plan-reading correctly and the grep
  misses it — observed verbatim as *"Ler o plano e a spec citada"*. Not caused
  by this project: the expected phrasing is present in
  `skills/subagent-driven-development/SKILL.md:118` and in the upstream's copy
  of the same instruction, and our only edit to it was additive
  (`read plan` → `read plan + cited spec`, now in
  `skills/subagent-driven-development/references/process-graph.md`), which
  still matches. Confirmed
  failing at `b6b68ef` in a clean detached clone. Left unfixed: it is an
  upstream test, and rewriting its regex would make it assert something other
  than what it asserts. Treat a failure here as uninformative until the
  assertion is language-agnostic.

- **The stable-anchor gate reaches `CLAUDE.md` and nothing else.**
  `scripts/check-links.sh:72` sets `SECTION_TARGETS = ["CLAUDE.md"]`, so the
  `` `path/file.md`, section "Exact Heading" `` form is verified only there.
  Skills cite each other in that form too now, and those references are
  unchecked — which is how three anchors in
  `finishing-a-development-branch/SKILL.md` sat off by one without anything
  noticing. Not closed in the same commit that revealed it: widening
  `SECTION_TARGETS` to `skills/**` is a gate change wanting its own measurement
  of what it would charge on the 44 markdown files under `skills/`, not a line
  appended to a
  behavioural change. The `file:line` form under `skills/` is unchecked as
  well, and always was.
- **The TDD Iron Law has no verifying face.** The implementer prompt requires a
  test before code, but no verifier can prove the order: the only record that
  the test came first is a report section written by the party being audited. A
  gate on it would be decorative. Evaluated and not implemented: separate
  commits, test first, which a reviewer could check by commit order — deferred
  because it changes commit granularity for all work done with this project.
  (opened plus.7)
- **No mutation sensor.** Nothing currently kills a test that passes by
  accident. The anti-shallow-test litmus catches syntactic patterns
  (`expect(true)`, assertions only on mocks), not an assertion that simply does
  not reach the behavior. Deferred until there is enough real use to calibrate
  which mutations are worth the cost. (opened plus.3)
- **Dependency grounding stops at the plan.** `lockfile`, `pinned`,
  `official doc`, and `vendor` appear in the two spec files and the two plan
  files, and nowhere in `implementer-prompt.md`, `task-reviewer-prompt.md`, or
  `final-branch-audit`. The planned call is verified; the delivered call is
  not. That is the plan → code boundary, one step past what was closed.
  (opened plus.13)
- **No eval harness in this repository.** `evals/` is gitignored and absent;
  what exists is `tests/skill-behavior/`, with two rules measured over four
  runs. Cloning
  `superpowers-evals` and wiring it in is desirable and undone: it needs a
  submodule or a manual clone per checkout. (opened plus.34)
- **One lockfile line number in an example is illustrative.**
  `package-lock.json:1188` in `brainstorming/SKILL.md` matches no real
  lockfile — this repository is zero-dependency and the line varies per project
  anyway. Closing it would need an example project with a versioned lockfile
  inside the repo. (opened plus.1)
- **A generated release body carries the changelog's link-reference block.**
  `scripts/release-notes.sh` slices from Open gaps to end of file, and the
  version-to-tag link definitions live there, so every release body ends with
  the full list of them. Measured, not assumed: the published v1.2.5 body
  carries the same eight lines. It renders as literal text on GitHub and breaks nothing.
  Left as is on purpose — a release body is generated, never hand-written, so
  the only real fix is teaching the script to stop at the link block, and that
  is not worth a change to the one script that decides what every release says.
  **Do not re-investigate: this is known and deliberate.** (opened 1.3.0)
- **A tag cut on a commit outside `main` is never tested.** The residual hole
  left by the CI trigger fix above: `push: branches: ['**']` excludes tag refs,
  so nothing runs for the tag itself. Accepted, not overlooked — a tag here is
  cut from the release commit `main` has just run green, so the tag run was
  duplicating a result the same SHA already had. Nothing enforces that a tag
  points at a commit on `main`; if that ever stops being the practice, this
  becomes a real gap and the trigger needs revisiting. (opened 1.3.1)

- **Eight rules are precaution with no recorded symptom, and the queue to
  settle them is measurement, not deletion.** A category sweep classified every
  rule this fork added: those that constrain what may be *asserted*, those that
  name a *state*, and those that decide something an agent would decide well on
  its own. The third group splits by provenance — born of a defect observed in
  real use, or born of our own caution — and only the second half is a
  candidate for anything. These are that half — **eight entries, where this
  list opened with seven**: one left the queue measured (the resume routes,
  below) and two split in place, each having been two rules under one line.

  | Rule | Where |
  |------|-------|
  | The three-round cap on **document review** | `brainstorming/SKILL.md:215`, `writing-plans/SKILL.md:363` |
  | The three-round cap on the **conformance audit** | `executing-plans/SKILL.md:134` |
  | A returning blocker escalates immediately — **document review** | `brainstorming/SKILL.md:225`, `writing-plans/SKILL.md:372` |
  | A returning NOT DELIVERED row escalates immediately — **conformance audit** | `executing-plans/SKILL.md:145` |
  | The four rules guarding the dispute protocol | `subagent-driven-development/SKILL.md:353` |
  | Progress reports at four fixed points | `subagent-driven-development/SKILL.md:27`, `executing-plans/SKILL.md:16` |
  | "No gate can check any of this" | `subagent-driven-development/SKILL.md:48`, `executing-plans/SKILL.md:36` |
  | The `**Execution:**` field and its two readers | `writing-plans/SKILL.md:98`, `subagent-driven-development/SKILL.md:121`, `executing-plans/SKILL.md:70` |

  **Two of those lines were one rule each on paper and two in the skills.** The
  cap of three and the returning-blocker rule both count rounds of *document
  review* in `brainstorming` and `writing-plans`: the actor is a reviewer
  subagent re-reading a spec or a plan, the cap is reached before any code
  exists, and running out costs a paragraph. In `executing-plans` the same two
  numbers count rounds of the *conformance audit* — the client is
  `final-branch-audit`, the branch is already built, and running out ends with
  the work unfinished and its NOT DELIVERED rows escalated, which is the state
  `finishing-a-development-branch/SKILL.md:40` had to grow a row for. Same
  number, different actor, different client, different consequence at the cap.
  A single fixture cannot measure both, which is exactly what the resume routes
  taught when they came back split: one line here was two rules there, and only
  measuring them apart showed it. **The 3-versus-5 axis is a different question
  and is already settled** — `1.5.0` records why these loops cap at three while
  the task loop runs to five, and it is not what this split is about.

  **Cutting them by argument would be the same move that wrote them.** They
  were reasoned into existence and would be reasoned out of it, with nothing
  measured either way — and a rule removed on an argument is as unfalsifiable
  as one added on one. The honest conversion is an adversarial test in
  `tests/skill-behavior/`: build the situation where following the rule is
  inconvenient, and see whether it holds. That is what moved the escalation
  format from *reasoned* to *measured*, and it corrected the rule twice on the
  way.
  **The resume routes and the progress reports go first** — the two most
  expensive in lines and the two easiest to build a fixture for, since both
  have an observable output. "No gate can check any of this" is the hardest and
  may be untestable by construction, which is itself worth recording.
  **The resume routes went first, came back split, and both halves are now
  out of this queue.** Measured, not estimated: the rule is 97 lines, 79 in
  `subagent-driven-development/references/resuming.md` and 18 at
  `executing-plans/SKILL.md:40-57`. The 79 held on their first run. The 18
  failed twice, and passed on the third after the confirmation clause moved
  into the step that executes — four runs across the two halves, four
  fixtures, none reused. Splitting an entry this way is the queue working:
  "the resume routes" was one line here and two rules in the skills, and only
  measuring them apart showed it. **The inline half left with a cheaper
  finding than a pass:** what moved it was position, not wording, and the
  intervention aimed at wording measured as irrelevant.
  **One rule was considered for this queue and excluded: the declared
  preference about the visual companion** (`brainstorming/SKILL.md:282`). It
  came from the owner asking for it in so many words, not from our caution. A
  stated preference is already the evidence; an adversarial test would measure
  whether the agent obeys an instruction, which is not what these tests are
  for. (opened 1.7.0)

- **CLOSED, and kept here as the record of how.** The inline path's resume
  rule failed twice on its second half and passed on the third run once the
  confirmation moved into Step 2; the full three-run record is at
  `tests/skill-behavior/RESULT-resume-route-inline.md`. It stays written out
  below because the failure is the useful part — a rule can be read, cited and
  ignored, and that is what runs 1 and 2 showed.
  **The inline path's resume rule failed on its second half, twice, and the
  cause was identified.** `executing-plans/SKILL.md:51-52` asks a resuming
  agent to "state which tasks you believe are done and the evidence for each,
  and get your partner's confirmation before executing anything". Two runs
  against two different fixtures, same model, same neutral dispatch: both
  agents **passed everything up to that clause and failed it**. Neither
  guessed — both reconstructed from `git log`, the working tree and the plan,
  and both were right about where the work stopped. Then both executed the
  remaining tasks, dispatched the conformance audit and committed, and spoke
  to their partner only afterwards.
  What moved between the runs is worth recording and does not close the gap.
  Run 1 never mentioned the clause. Run 2 named it and declared the violation
  in its opening lines: *"`executing-plans` asks a resuming agent to confirm
  the reconstruction with you before executing. I proceeded without waiting,
  because as a subagent I reach you only in this message and stopping would
  have returned nothing."* Awareness improved; compliance did not.
  **Two candidate causes, and the harness one is not disposable.** A subagent
  reaches its partner only in its final message, so "stop and confirm" and
  "return nothing" are the same act for it — run 2 says exactly that. But the
  subagent-path agent was under the identical constraint and stopped anyway,
  returning its resume point and no work, so the constraint does not compel
  the outcome. What separates them is where the instruction sits: the
  subagent path's next act is a dispatch and its rule guards dispatching; the
  inline path's next act is an edit and its rule sits in prose above the
  process. Untested either way.
  **The obvious repair was tried and measured as not the repair.** A routing
  step was added at `executing-plans/SKILL.md:63` between the two runs on the
  theory that detection was failing. It was not: both agents opened with the
  same `git log`/`git status` command without it, and both read the whole
  skill file. The step stays as an explicit entry condition; nothing measured
  credits it. **Do not read run 2's improvement as its effect** — one sample
  per condition, and the difference lands on a criterion the step never
  mentions. (opened 1.7.1)

- **`test-driven-development/SKILL.md:331` asks for a report that may not
  exist, and was left alone deliberately.** Found while closing the checklist
  item next to it: the box reads "the exact test command and its output are in
  your report", and on a bug fix run from the main session there is no report
  file — that artifact belongs to the subagent path. It was not changed because
  "your report" is generic and resolves to the message to the partner, which is
  a real thing that always exists. Its neighbour named `the plan's Test
  Coverage Matrix`, a specific artifact that is genuinely absent, which is why
  that one was a defect and this one is a note. Revisit if a bug-fix run is
  ever observed stalling on it. (opened 1.7.0)

- **Four mentions in the frozen history now name a file that no longer
  exists**, and they stay. `references/example-workflow.md` was cut above;
  `docs/PLUS-CHANGELOG-historico.md` describes it at `:778`, `:965`, `:1011`
  and `:1026`. Three reasons, all of which have to hold and do: the file is
  frozen — `check-frozen-history.sh` refuses any change to it, by design; each
  mention describes correctly what was true when it was written, which is what
  a historical record is for; and nothing goes red, because all four are
  backticked prose rather than markdown links, so `check-links.sh` never
  resolves them. Measured, not assumed: the full static suite is green with the
  file gone. **This is a known consequence, not a finding — do not re-report it
  as a broken reference.** (opened 1.7.0)

Most rules in this project are reasoned rather than measured. Three have been
measured, over eight adversarial runs: the external-content rule, which held on
its first run; the escalation format, which took two corrections and three runs
to hold; and the resume route, which split — the subagent half held on its first
run, the inline half failed twice and held on the third after one structural
change. Six remain queued in the gap above.

[1.8.2]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.8.2
[1.8.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.8.1
[1.8.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.8.0
[1.7.3]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.7.3
[1.7.2]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.7.2
[1.7.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.7.1
[1.7.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.7.0
[1.6.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.6.0
[1.5.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.5.0
[1.4.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.4.0
[1.3.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.3.0
[1.2.5]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.5
[1.2.4]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.4
[1.2.3]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.3
[1.2.2]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.2
[1.2.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.1
[1.2.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.0
[1.1.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.1.0
[1.0.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.0.0
