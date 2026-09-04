# Changelog

All notable changes to this project are documented here. The format follows
Keep a Changelog 1.1.0, and this project adheres to Semantic Versioning 2.0.0.

**Upstream base:** [`44c9b2d`](https://github.com/obra/superpowers/commit/44c9b2d) (2026-07-27) — the last Superpowers commit incorporated, and the last there will be: on 2026-08-05 this project stopped pulling from the upstream ([`CLAUDE.md`](CLAUDE.md), section "Relationship with Superpowers"). This line is now a fixed historical fact, not a field to maintain.

The 34 `plus.N` entries that led to `1.0.0` are preserved verbatim in
[`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md) (in Portuguese).
References below name them so a claim here can be traced there.

## [Unreleased]

### Fixed

- **`check-cross-references` aprovava range malformado.** A validação comparava
  só o número final contra o total de linhas do arquivo
  (`skills/writing-plans/scripts/check-cross-references:409-410` antes desta
  mudança), então `arquivo:0`, `arquivo:0-5` e `arquivo:10-5` eram reportados
  como resolvidos. Medido por execução com controle em 04/09/2026: os três
  saíam com código 0, e o caso de controle — um fim além do arquivo — saía com
  1, provando que o instrumento funcionava e que os três passavam de verdade.
  O script roda entre o conserto de uma spec ou plano e o re-despacho do
  reviewer, para poupar uma rodada; uma citação malformada aprovada custava
  exatamente a rodada que ele existe para economizar.

## [1.25.0] - 2026-09-04

### Added

- **[`scripts/check-skill-frontmatter.sh`](scripts/check-skill-frontmatter.sh)
  — the first gate in this repository that reads a frontmatter rather than
  counting its lines.** It checks `name` against every constraint the Agent
  Skills specification states — at most 64 characters, lowercase letters,
  numbers and hyphens, no leading, trailing or consecutive hyphen, equal to the
  skill's directory — plus the two reserved words Anthropic's best-practices
  page adds, and `description` non-empty and at most 1024. Wired into
  [`githooks/pre-commit`](githooks/pre-commit) beside the ceiling gate and into
  both CI steps.

  **It exists because three frontmatter rules were wrong for as long as nothing
  read them.** No script here had ever read a
  `SKILL.md` frontmatter: `check-skill-size.sh` counts the whole file, its
  frontmatter included, without looking at a single field. The rules corrected in this
  cycle's Changed section were not subtle — a shared character limit, a
  Title-Case example name — and none of them was caught, because the file
  stating them was the one every other skill copies from.

  **What it deliberately does not check is the half that matters most.**
  Whether a description says what the skill does as well as when to use it is a
  real property and the spec states it, but no pattern separates a description
  that names its outcome from one that repeats its trigger — searching for
  `Use when` would rebuild the rule this cycle had to correct. That half
  belongs to [`writing-skills`](skills/writing-skills/SKILL.md) and to
  [`tests/skill-behavior/`](tests/skill-behavior/).

  **The suite is
  [`tests/hooks/test-check-skill-frontmatter.sh`](tests/hooks/test-check-skill-frontmatter.sh),
  one case per constraint, and one of its cases was vacuous when first
  written.** The uppercase case used a lowercase directory, so a name of
  `Bad-Case` was rejected by the name-equals-directory rule and never reached
  the pattern: the pattern was mutated to accept uppercase and the suite stayed
  green. It now carries the uppercase directory, and the same mutation turns it
  red. Six mutations were run in total — the equality never firing, the pattern
  accepting uppercase, each limit raised to 100000, the reserved list emptied,
  and the block-scalar guard made unreachable — and each one reddens the case
  that names it and no other.

### Fixed

- **The new frontmatter gate approved a description it had not read.** A
  `description: >` block scalar — the text indented on the lines below — was
  read by
  [`scripts/check-skill-frontmatter.sh`](scripts/check-skill-frontmatter.sh) as
  its one-character indicator, so a two-thousand-character description passed
  after the gate looked at one. Found by probing the script during this
  branch's review, not by a case that existed.

  **It refuses the form rather than learning to measure it.** The parser reads
  single-line values; teaching it block scalars means implementing indentation
  rules for a shape no skill here uses. Refusing is the honest answer, and a
  gate that certifies what it did not read is the exact failure this one was
  added to prevent. The suite gained the case, and the guard was made
  unreachable to prove the case is not vacuous — it reddens, alone.

- **The TDD skill's RED example never compiled against its own GREEN
  example.** [`skills/test-driven-development/SKILL.md`](skills/test-driven-development/SKILL.md),
  section "RED - Write Failing Test", passed a synchronous callback returning
  `string` to the `retryOperation` of section "GREEN - Minimal Code", whose
  parameter is `fn: () => Promise<T>`. Extracted to a file and compiled with
  `tsc 7.0.2 --strict --target es2020`, the pair fails with
  `error TS2345: Argument of type '() => string' is not assignable to parameter
  of type '() => Promise<unknown>'` — exit 1. With the callback marked `async`,
  exit 0. **Measured both ways, not read**: the fix is one keyword, and the
  keyword is the one the surrounding `async` test already implies.

- **`requesting-code-review`'s only example taught the per-task review its own
  rules had already replaced.** The example opened on *"Just completed Task 2"*
  and closed on *"Continue to Task 3"*, dispatching this skill after a single
  task — while the same file's section "When to Request Review" states that the
  per-task review on the subagent path runs a different instrument,
  [`task-reviewer-prompt.md`](skills/subagent-driven-development/task-reviewer-prompt.md),
  and that anything outside the gates happens only when the human partner asks
  for it. The mechanics were never wrong, only the frame: the example now runs
  at the branch gate, takes the fork point rather than a task's recorded base,
  and hands the reviewer the plan instead of one task. Nothing in
  [`tests/`](tests/) read the old text — grepped before editing.

- **The parallel-dispatch skill's live instructions still verified the
  behaviour its own protocol had banned.**
  [`skills/dispatching-parallel-agents/SKILL.md`](skills/dispatching-parallel-agents/SKILL.md),
  section "Verification", asked *"Understand what changed"* and *"Did agents
  edit same code?"* — questions that only have answers if the agents edited.
  The same file's section "The Pattern" constrains them to
  *"Read-only — investigate, do not edit and do not commit"*. The section now
  verifies diagnoses and orders the fixes serially, which is what the protocol
  above it produces.

  **The `Real Example from Session` above it was left exactly as it is**, and
  that is not an oversight: it is explicitly framed as a record of a session
  run under the earlier boundary, with a paragraph stating what it would be
  today. Rewriting a record of what was done into the format now prescribed
  would invent a session nobody had. The residue was in the imperative section,
  not in the record.

- **The inline path declared itself the path for a harness without subagents,
  and then reached a gate that has no non-subagent route.**
  [`skills/executing-plans/SKILL.md`](skills/executing-plans/SKILL.md),
  section "Step 3: Audit and Review the Branch", gave its second gate an
  explicit *"No subagent available to dispatch?"* branch and its first gate
  none — while
  [`skills/final-branch-audit/SKILL.md`](skills/final-branch-audit/SKILL.md),
  section "Dispatch", is a subagent dispatch. An executor who reaches the audit
  on such a harness has the skill's own Note at the top telling them this is
  their path, and nothing telling them what to do. The first gate now escalates
  the same way the second one does.

  **The fix is the missing branch, not an inline auditor.** The audit reads the
  executor's todos as claims under audit; an executor auditing their own
  execution removes the independence the gate exists for. Building a second
  execution mode for it would answer by architecture a cost no run has yet
  reported — if the escalation turns out to strand real work, that measurement
  is what would justify the mode.

- **Two behaviour records went stale on this branch and nothing local caught
  it.** The no-subagent branch added to
  [`skills/executing-plans/SKILL.md`](skills/executing-plans/SKILL.md) put
  [`RESULT-main-branch-consent.md`](tests/skill-behavior/RESULT-main-branch-consent.md)
  and
  [`RESULT-resume-route-inline.md`](tests/skill-behavior/RESULT-resume-route-inline.md)
  in the state their own gate exists to refuse: measured against a file that
  has since moved, reading as current for text they never saw. Both now carry
  the new date, and both say what the change was — a branch added to the
  conformance audit in "Step 3: Audit and Review the Branch", which is neither
  the section one record measures nor the one the other does.

  **The gate that found it,
  [`check-skill-behavior-records.sh`](scripts/check-skill-behavior-records.sh),
  runs in CI and not in
  [`githooks/pre-commit`](githooks/pre-commit)** — so eight commits went in
  green and the break would have surfaced on push. Recorded here as measured;
  whether it belongs in the hook is a cost question nobody has priced.

- **[`docs/pre-commit-cost.md`](docs/pre-commit-cost.md) declares the new gate
  absent rather than timing it.** That document states the condition itself —
  *"Every gate the hook gains lands here undeclared unless someone adds it"* —
  and `check-skill-frontmatter.sh` had landed undeclared. It joins
  `check-evidence-line.sh`, `check-escalation-shape.sh` and
  `check-no-dispatch.sh` in the paragraph of gates present in the hook and
  absent from the table. **Not measured on purpose:** timing one gate today, on
  a different machine and a different interpreter state than the 2026-08-02
  run, would blend two instruments into one table, which is the reason those
  three are declared rather than timed.

### Changed

- **The skill that governs how every other skill is written prescribed a
  frontmatter the specification rejects.** Three divergences in
  [`skills/writing-skills/SKILL.md`](skills/writing-skills/SKILL.md), section
  "SKILL.md Structure", checked against
  the Agent Skills specification at `agentskills.io/specification` and
  Anthropic's current skill best-practices page on 2026-09-04:
  **(1)** *"Max 1024 characters total"* — the limits are per field and not
  shared: `description` 1024, `name` 64. **(2)** The example wrote
  `name: Skill-Name-With-Hyphens`; the spec requires lowercase, forbids leading,
  trailing and consecutive hyphens, and requires the name to equal the parent
  directory. **(3)** *"describes ONLY when to use (NOT what it does)"* — the
  spec says a description "describes what the skill does and when to use it",
  and this repository's own vendored copy,
  [`anthropic-best-practices.md`](skills/writing-skills/anthropic-best-practices.md),
  section "Checklist for effective Skills", already said the same. Two
  constraints from Anthropic's page that the open spec does not carry are now
  written down too: no XML tags in the name, and never the reserved words
  `anthropic` or `claude`.

  **The `NEVER summarize the workflow` rule survives untouched, and separating
  it from the third divergence is the whole correction.** Section "Skill
  Discovery Optimization (SDO)" records a measurement — a description that
  summarized a workflow made an agent perform one review where the skill body
  prescribed two — and that measurement is about *how*, never about *what*. The
  rule now reads what and when, never how, which is what the evidence
  supports and what the spec asks for. The four `✅ GOOD` examples were
  rewritten alongside it: leaving examples that demonstrate the old rule is the
  same defect this cycle fixed in `requesting-code-review`.

  **Eleven of the fifteen skills here do not yet follow the corrected rule**,
  and that is recorded under `## Open gaps` rather than swept: a `description`
  is what an agent matches a request against, and the SDO measurement is the
  reason eleven of them are not rewritten on an argument.

- **Worktree setup detected the language and ran the wrong tool.**
  [`skills/using-git-worktrees/SKILL.md`](skills/using-git-worktrees/SKILL.md),
  section "Step 2: Project Setup", ran `poetry install` on the presence of
  `pyproject.toml` — a file that says the project is Python and nothing about
  its package manager, which today is as likely to be uv, Hatch, PDM or plain
  setuptools. On such a project the command either fails or installs into an
  environment nobody chose. `npm install` on `package.json` was the same shape
  one step milder: with a lockfile present it may rewrite the pinned versions
  the worktree was supposed to reproduce.

  **The detection now reads lockfiles, because a lockfile names the tool and a
  manifest names the language.** `package-lock.json` takes `npm ci`,
  `poetry.lock` takes Poetry, `uv.lock` takes uv, and the manifests stay as the
  fallback below them. Ahead of all of it, the skill now reads the project's
  own instructions first — `CLAUDE.md`, `AGENTS.md`, README, `Makefile`, CI —
  because a project that documents its setup has already answered better than
  any detection can. Nothing matching is now a question to the human partner,
  rather than a guess made on their machine.

- **Three failed fixes were stated as proof of a wrong architecture, and a
  95% figure had no measurement behind it.**
  [`skills/systematic-debugging/SKILL.md`](skills/systematic-debugging/SKILL.md)
  carried the causal claim in four places, most flatly in section "Red Flags -
  STOP and Follow Process" (*"3+ failures = architectural problem"*) and at the
  end of Phase 4.5 (*"This is NOT a failed hypothesis - this is a wrong
  architecture"*). Three failures prove the hypotheses tried so far were wrong.
  They do not say where the error lives — the design, a boundary, an
  assumption, or the hypothesis itself — and the skill's own list of patterns
  right above it is what distinguishes those. **The circuit breaker is
  unchanged and deliberate:** stop at three, do not attempt Fix #4 alone. What
  changed is the conclusion it hands you, which is now a re-evaluation with
  architecture included rather than a verdict already reached.

  **The 95% is removed rather than sourced.** Section "When Process Reveals
  'No Root Cause'" asserted that 95% of such cases are incomplete
  investigation. No measurement in this repository supports the number and
  producing one is not cheap; this project does not keep a figure it cannot
  defend, and [`CLAUDE.md`](CLAUDE.md) already refuses numbers picked by
  argument. The sentence keeps the brake it was there for — name what you ruled
  out and how — without a statistic nobody counted.

## [1.24.0] - 2026-09-03

### Fixed

- **A risk accepted in 1.3.0 was reversed: the changelog's link-reference
  footer was published inside every release body.**
  [`scripts/release-notes.sh`](scripts/release-notes.sh) built a section by
  slicing to the next `## ` heading and falling through to end-of-file when it
  found none. `## Open gaps` is the last `## ` in
  [`CHANGELOG.md`](CHANGELOG.md), so its slice ran to EOF and carried the
  footer with it. It now stops at either boundary.

  **This was a known WONTFIX, not a discovery** — the `## Open gaps` item
  carried the standing instruction *do not re-investigate*, and it is closed in
  this release by the entry above, which records that the item was found in
  review rather than read beforehand. Two things changed since 1.3.0, both
  measurable, and neither of them is why the work started: the footer was **eight** lines when the item was written and is
  **fifty** today (counted in the body generated for 1.23.0 on 2026-09-03, zero
  after the fix), and the item's own reasoning — not worth touching the one
  script that decides what every release says — rested on that script having no
  tests, which is no longer true as of the suite added below.

  The changelog has two kinds of section boundary, a `## ` heading and the
  footer, and the script honoured one. The fix is the missing boundary, not a
  bounds check: end-of-file is a legitimate end for a document, and demanding a
  terminator would have invented a requirement. That fallback is now covered by
  a case of its own.

  **Fifth occurrence of this shape in this project, not the third** —
  `usage()` slicing by its last sentence, `section()`'s end-of-file return,
  `sync-to-codex-plugin.sh`'s `sed` range (13 lines to 48), `slice_between` in
  1.23.0, and this one. A slice whose terminator is absent degrades into
  reading the rest of the file, and the output stays plausible.

- **[`scripts/check-links.sh`](scripts/check-links.sh) sliced the same section
  to end of file, and said in its docstring that this matched
  `release-notes.sh`.** The sentence was true when written and was falsified by
  the fix above; the two slices then disagreed by the footer's fifty lines. The
  gate is now bounded by the same footer boundary and the docstring says what
  both actually do. **No gate misfired at any point** — the footer contributes
  zero markdown links, and the gate's counts are byte-identical before and
  after the change (686 local links, 110 files, 98 URLs, 99 section
  references), which is the measurement that the narrowing is behaviour-
  preserving. The URL-diet pass reads whole files rather than this slice, so it
  is untouched.

### Added

- **[`CLAUDE.md`](CLAUDE.md), section "How you work here": grep the live list
  before proposing work on something.** The failure is measured — the fix
  above was proposed and written without the `## Open gaps` item that recorded
  it as deliberate ever being read; the item surfaced in review, after the
  code. The remedy is reasoned, and three alternatives were measured and
  dropped before it:

  - **A pre-commit gate crossing staged files against items that name them.**
    Simulated over 400 commits, each against the live list as it stood in that
    commit's parent: **26** items were closed or edited by a commit, and the
    crossing pointed at the right one **4** times — 15% recall, 3% precision
    across 117 firings. The cause is structural, not a weak matcher: of 45
    items, **15** name no tracked file at all and **6** name only historical
    artefacts, so the ceiling is 53%; and an item typically names the file
    where the problem was *observed*, not the one edited to close it.
  - **Injecting the list at session start.** [`hooks/session-start`](hooks/session-start)
    is registered under `${CLAUDE_PLUGIN_ROOT}` ([`hooks/hooks.json`](hooks/hooks.json)),
    so it runs for everyone who installs the plugin. That would ship this
    project's internal debt — ~1,100 tokens of item titles, or ~14,000 for the
    whole list — into every session of every unrelated project.
  - **A local session-start hook.** Same token cost each session, and a
    mechanism this checkout does not have, against a file already loaded.

  What the rule has instead of a recall figure: **35 of 45** items name what
  they are about in a backticked identifier, and the command in the rule, run
  against `7225fd9` — the commit this session started from — returns the item
  that was missed. Measured 2026-09-03.

- **[`tests/release-notes/test-release-notes.sh`](tests/release-notes/test-release-notes.sh)**
  — the first tests `scripts/release-notes.sh` has ever had, on a synthetic
  changelog rather than the real one, which changes every release. It proves
  the cut by difference: the footer must be **absent** and the section's own
  last line **present**, both on the same body, because a cut that stops too
  early passes the first assertion alone. A second lab with no footer at all
  exercises the end-of-file fallback, so that claim is asserted rather than
  only stated. Verified with `mutar` in three directions — removing the footer
  boundary kills the absence assertions, truncating the slice kills the
  presence ones, and dropping the fallback kills the no-footer case. Wired
  into CI.

## [1.23.0] - 2026-09-03

### Added

- **A ledger of what each review dispatch returned.**
  [`docs/superpowers/review-yield.md`](docs/superpowers/review-yield.md) takes one row per dispatch —
  date, branch, face, round, blocking findings, and how many of the previous
  round's are still open. The cost of a review was already on record here (a
  median of 7.3 minutes across 29 document reviews, section `[1.16.0] - 2026-08-08`
  below); the yield was on record nowhere, which left "are the review passes
  paying for themselves" arguable and unanswerable. The round is the column the
  question turns on: rounds 2 and 3 returning zero blocking findings is the
  shape that says the extra rounds buy nothing.

  **The controller appends the row, never the reviewer** — three of the five
  reviewer prompts declare their review read-only on the checkout, so the write
  cannot belong to them.

  Guarded by a new deterministic suite,
  [`tests/review-yield/test-review-yield-rules.sh`](tests/review-yield/test-review-yield-rules.sh),
  which asserts each rule is present in the file that must carry it. Every rule
  in this change is text in a skill, a prompt, or a script comment: nothing
  executes it, so nothing notices when an edit removes it. The suite runs in CI
  from this entry onward.

- **The four review faces record what their dispatch returned.**
  [`skills/brainstorming/SKILL.md`](skills/brainstorming/SKILL.md) (section
  "Spec Review"), [`skills/writing-plans/SKILL.md`](skills/writing-plans/SKILL.md)
  (section "Plan Review"),
  [`skills/subagent-driven-development/SKILL.md`](skills/subagent-driven-development/SKILL.md)
  (sections "3. Review the task" and "4. The fix loop") and
  [`skills/requesting-code-review/SKILL.md`](skills/requesting-code-review/SKILL.md)
  (section "How to Request", sub-step "3. Act on feedback") each tell the
  controller to append one row.

  **Every write point names only what the ledger cannot know: which face this
  dispatch is.** The five texts — four skills, with `subagent-driven-development`
  holding two — are otherwise one sentence, varying in the connective that
  places each in its own step. An earlier draft enumerated the six
  columns in each skill and, in the next sentence, told the reader not to
  restate them. What counts as a blocking finding for a given face is itself a
  column definition, so it went to the ledger too. Measured while making the
  correction: `skills/writing-plans/SKILL.md` stood at 496 lines against the
  500-line ceiling [`check-skill-size.sh`](scripts/check-skill-size.sh) enforces — the discarded
  version took it to 502, this one to 499.

- **The two document reviewers report what the previous round left open.**
  [`spec-document-reviewer-prompt.md`](skills/brainstorming/spec-document-reviewer-prompt.md)
  and [`plan-document-reviewer-prompt.md`](skills/writing-plans/plan-document-reviewer-prompt.md)
  each carry a **Previous findings** line in their Output Format: how many the
  previous round raised, and how many this round still finds open. Without it a
  round's yield could only be counted by re-reading its report, and whether a
  finding survived a fix pass was recorded nowhere at all.

  **Round 1 writes the absence in words — `none — round 1`, never a blank or an
  omitted line.** A round that carried no previous findings and a round whose
  verdicts the reviewer skipped otherwise render identically.

- **All five reviewer faces cap their advisory bucket at five items and report
  the remainder as a count.** The three that read a diff cap `Minor` —
  [`code-reviewer.md`](skills/requesting-code-review/code-reviewer.md),
  [`task-reviewer-prompt.md`](skills/subagent-driven-development/task-reviewer-prompt.md)
  — and `Out-of-Scope` —
  [`re-review-prompt.md`](skills/subagent-driven-development/re-review-prompt.md);
  the two that read a document cap `Recommendations`. Advisory findings do not
  block, so a long list spends the attention the blocking findings above it need.

  **The cap is worded per face, against that face's own bucket name, never as
  one sentence shared across all five.** The four review faces are deliberately
  not one rule written four times — see
  [`docs/review-scopes.md`](docs/review-scopes.md) — and a shared sentence would
  name a bucket three of them do not have.

- **A spec carries the problem it solves, as a required section.**
  [`brainstorming`](skills/brainstorming/SKILL.md), section "After the Design"
  requires `## Problem` as the first row of its required-sections table, above
  `## Acceptance Criteria`: what is wrong today, who it affects, and what is out
  of scope. A criterion is an answer; this is the question, and it was the one
  thing the spec never had to state. Measured across the corpus on 2026-09-03 —
  201 specs in 11 projects — 56 carried a problem section under 7 distinct
  headings, and of the 20 carrying both, all 20 put it above the criteria. The
  requirement follows what the corpus already did; what it adds is one name and
  a gate that can find it.

  **Specs written before the requirement get a transition, not a charge.** They
  are written from what the spec already says, without reopening the design: a
  spec that never had the chance to comply is not an author who skipped it, and
  the two must not be treated alike.

- **The spec reviewer charges the criteria against the stated problem.**
  [`spec-document-reviewer-prompt.md`](skills/brainstorming/spec-document-reviewer-prompt.md)
  gains two blocking rows in its Traceability table: a missing `## Problem`, and
  an acceptance criterion that does not serve the problem the spec states.

  **The second row is the only place in the chain where that question is ever
  asked.** Everything downstream traces criteria to tasks and tasks to evidence
  — the plan, the task reviewer, the final audit all verify that what was
  specified got built. None of them verifies that what was specified addressed
  the problem. A criterion serving something else is invented scope that entered
  before the first task existed, where every later gate reads it as a
  requirement and passes it through.

### Fixed

- **A green `check-cross-references` no longer reads as coverage of section
  references.** The script's `WHAT IT DOES NOT COVER` block now names the class
  it never resolved: a markdown link to another document followed by a quoted
  section title. It resolves headings only inside the document under check, to
  find that document's own `AC`/`IR` lists, so a reference naming a heading that
  does not exist in the target passed green. In this repository
  [`check-links.sh`](scripts/check-links.sh) catches that class from the
  pre-commit hook; in a project that installs the plugin without it, nothing
  does — and the block now says so.

  **Declared rather than implemented, on a measurement.** Across the corpus on
  2026-09-03 — 201 specs in 11 projects — 36 section references were found in
  specs and plans: 32 resolve, 0 named a missing heading, and 4 pointed at a
  missing file, which the existing path check already reports. Nothing of this
  shape was found broken, so the script gains a declared blind spot instead of a
  second heading parser. The count is here, with its date, because a number in a
  script comment ages in silence.

  This happened to this branch's own spec: a reference to bold text that was not
  a heading passed `check-cross-references` and was then rejected by
  `check-links.sh` at the commit. The gate that ran first said nothing, and
  nothing about its silence looked like a gap.

- **Five of the suite's assertions survived the mutation that deleted what they
  guard.** Found by the branch review, which applied each mutation in a scratch
  worktree rather than reading the assertions. One root cause: every criterion
  charged here is a **position** — a rule inside a named bucket, inside a
  section, inside a table, sometimes at more than one site in one file — and
  every assertion was a substring over the whole file. Deleting the ledger's
  column-definition table, deleting the data table a row is appended to, deleting
  one of the two write points in `subagent-driven-development`, moving a cap out
  of the bucket it names, moving the `**Previous findings:**` block out of
  `## Output Format`, and restating five of the six column names in a write
  point all left the suite green.

  Two helpers in
  [`test-review-yield-rules.sh`](tests/review-yield/test-review-yield-rules.sh)
  answer it: `assert_in_slice`, which charges a pattern between two delimiters,
  and `assert_count`, for a criterion naming more than one site. All six
  mutations above now fail, with the unmutated tree clean — re-measured
  2026-09-03.

  **The slice helper passes its patterns through the environment, never through
  `awk -v`.** `-v` runs escape processing on the value first, so
  `\*\*Recommendations \(advisory` reaches `awk` as `**Recommendations (advisory`
  and dies as an invalid expression rather than as a wrong answer.

- **A blocking row told the reviewer to state something false.**
  [`spec-document-reviewer-prompt.md`](skills/brainstorming/spec-document-reviewer-prompt.md)'s
  new `## Problem` row mandated the report text "spec predates the requirement"
  unconditionally, including for a spec written after it. The `## Coverage Map`
  row it was modelled on closes this — "the finding has to say which one it is
  or the author is left with a block and no way out" — and that half was not
  copied. It is now.

- **Two of the four ledger write points could not fire on a clean round 1.**
  In [`brainstorming`](skills/brainstorming/SKILL.md) and
  [`writing-plans`](skills/writing-plans/SKILL.md) the instruction sat after the
  mechanical check's run report, which lives inside the "before re-dispatching"
  block a round-1 approval never enters. A ledger that records only rounds which
  had findings cannot answer the question it exists for — whether rounds 2 and 3
  come back empty. Both now fire when the review returns, clean or not.

- **[`docs/review-scopes.md`](docs/review-scopes.md) now lists the nit cap as a
  fourth form copied across carriers**, with the two ways its gate diverges from
  the three already there: it runs from CI rather than
  [`githooks/pre-commit`](githooks/pre-commit), so a local commit dropping the
  cap from one carrier is caught only on push; and it asserts a per-face string
  instead of comparing carriers against each other, because the cap is worded
  per face on purpose. Neither divergence is defended — both are recorded as
  what happened.

- **The ledger is an artifact of the project being worked on, not of this
  repository.** It moved to `docs/superpowers/review-yield.md`, beside the
  `specs/` and `plans/` these skills already write there, and the four write
  points name it in backticks — the form
  [`CLAUDE.md`](CLAUDE.md), section "Writing a reference" reserves for a path
  inside the partner's own project. The markdown link they carried before meant
  the opposite: from an installed plugin `../../docs/` resolves inside the
  plugin directory, and
  [`package-codex-plugin.sh`](scripts/package-codex-plugin.sh) does not ship
  `docs/` at all, so the target did not exist. Scoping the instruction to this
  repository instead would have measured a handful of branches against the
  eleven projects the corpus sweep covers.

  The column definitions moved with it, to
  [`review-yield.md`](skills/requesting-code-review/references/review-yield.md),
  which ships — a project that has never run a review has no ledger to read a
  format from. One reference, four callers, the arrangement
  [`execution-path.md`](skills/writing-plans/references/execution-path.md)
  already has with its three.

- **Two of the five advisory buckets are no longer capped, because their reader
  is not a person.** `Minor` in
  [`task-reviewer-prompt.md`](skills/subagent-driven-development/task-reviewer-prompt.md)
  and `Out-of-Scope` in
  [`re-review-prompt.md`](skills/subagent-driven-development/re-review-prompt.md)
  are transcribed item by item into the progress ledger by the controller, for
  the final review to triage. The cap exists to stop a long advisory list from
  burying the blocking findings above it — an attention argument about whoever
  reads the report. Where the reader is a controller under orders to forward
  every item, the cap deletes findings in transit, which
  [`subagent-driven-development`](skills/subagent-driven-development/SKILL.md)
  calls, in those words, a silent discard. Both prompts now say they are
  uncapped and why, and the suite charges both halves.

- **`skills/writing-plans/SKILL.md` came off the ceiling by progressive
  disclosure.** The write point above took it to 501 of 500. `## Code That Calls
  a Dependency` moved to
  [`dependency-calls.md`](skills/writing-plans/references/dependency-calls.md) —
  a plan needs it only when one of its steps calls a library, which is the
  literal test the rule states — leaving a trigger tied to that condition. 471
  lines, 29 of headroom. The open gap recorded earlier in this cycle is closed
  by this entry; compressing the new paragraph to fit would have been the
  workaround the rule names.

- **Three more assertions survived a MOVE, and the transcript could print `ok`
  and `FAIL` for the same file.** Both found by re-running the two gates after
  the first fix pass. `write_points`, the two `## Problem` rows and
  `not_covered_section_refs` were still file-scoped where their criterion names
  a section, a table and a comment block; all three now use `assert_in_slice`,
  and all three fail the move mutation. `columns_not_restated` printed its `ok`
  unconditionally after an inner loop was added, so a failing file got both
  lines — `FAILURES` still incremented, so no gate escaped, but a self-
  contradicting transcript is what this suite was being rewritten to stop
  producing. Its message also still named the file the ledger had moved out of.

  **`| Finding | Verdict |` is not a usable anchor in
  [`spec-document-reviewer-prompt.md`](skills/brainstorming/spec-document-reviewer-prompt.md)** —
  it heads four different tables there, and `slice_between` takes the first
  match. The slice is keyed on the section heading instead.

- **A fix that stopped at the instance, and a slice that could reopen silently.**
  The round-2 pass marked one of the two test functions this cycle renamed away;
  its twin — belonging to `IR4`, the requirement that same pass amended — was
  left, in four places no gate can reach, because the old names still occur in
  the plan's own historical code block. Marked as a class now, not a case.

  `slice_between` had no terminal check: with its END pattern gone the slice ran
  to end of file, and every assertion inside it silently became the file-scoped
  grep the helper exists to replace. It now exits 2 when the slice never opened
  and 3 when it never closed, and `assert_in_slice` reports which. Measured by
  renaming the single line `# Usage:` in
  [`check-cross-references`](skills/writing-plans/scripts/check-cross-references):
  both `not_covered_section_refs` assertions now fail naming the unclosed slice,
  where before the run stayed green.

- **The three README-shaped files record the new generated artifact and the new
  blocking class.** [`README.md`](README.md),
  [`docs/README.pt-BR.md`](docs/README.pt-BR.md) and
  [`docs/README.en.md`](docs/README.en.md) each carry a table of what a run
  generates; the ledger is now one of them. The two reference documents also
  list what each gate blocks, and the spec reviewer's row gained the criterion
  that does not serve the stated problem — a missing `## Problem` needed no
  entry, because "a missing required section" already covers it once the
  section is required. Found by reading those tables against the branch rather
  than by a gate: a table claiming to enumerate has no check that it still does.

### Fixed

- **Twenty-two version headings in this file rendered as literal text.** A
  heading is written `## [1.22.0] - 2026-08-25`, and the bracketed version is a
  reference link that needs a definition in the footer. The footer stopped being
  extended at `1.11.0`: measured 2026-09-03, 49 headings against 27 definitions,
  so every release from `1.12.0` to `1.22.0` showed its own number in square
  brackets and linked nowhere. All 22 restored.

  **No gate reads this, and adding one was not the fix.**
  [`check-links.sh`](scripts/check-links.sh) resolves inline links — a label in
  square brackets followed by the target in parentheses — and a reference link is
  a different shape entirely;
  this file is also skipped wholesale by that pass for being history, with only
  `## Open gaps` sliced back in. The defect is that the footer is extended by
  hand at the moment of a release, by the same edit that renames
  `[Unreleased]`, and nothing fails when only the first half happens — the same
  shape [`CLAUDE.md`](CLAUDE.md), section "Versioning" already names for the
  rename itself.

## [1.22.0] - 2026-08-25

### Added

- **A behavior record now declares the file it measured, and a gate compares that
  file's age against the record's own.**
  [`tests/skill-behavior/README.md`](tests/skill-behavior/README.md) (section
  "When the rule under test changes") requires a **Rule path** row in every
  `RESULT-*`; [`check-skill-behavior-records.sh`](scripts/check-skill-behavior-records.sh)
  reads it, asks `git log` for the newest date over every commit touching that file
  (not the newest commit's date — see below), and fails when the
  measured text moved after the measurement unless the record carries a **Rule
  changed since** row naming the day. The mark carries its own date, so a second
  edit re-opens the finding rather than being covered by the first. A rule that
  is not a file declares a dash **and its reason** — a bare dash fails, because
  it reads exactly like a path nobody filled in.

  **The gate never asks for a re-run.** Re-measuring dispatches a live agent and
  returns a draw; noticing that the measured text has moved costs one `git log`
  and is exact. The expensive half stays a human decision, and the cheap half
  stops depending on anyone remembering. Reasoned, not measured — prompted by
  reading this repository against Anthropic's AI-native SDLC playbook
  (2026-08-21), whose continuous-evals stage gates configuration changes on
  re-measurement; this repository declines that stage and keeps only its trigger.

  **Two properties the gate needs and did not have at first**, both found by
  the branch review and both now carrying a red test: the date compared is the
  newest of every commit touching the file rather than the newest commit's date
  — author dates are not monotonic with the graph, and a commit arriving from
  another machine landed on top carrying an *earlier* day, which would have let
  a moved rule read as unmoved; and a **Rule changed since** past that date now
  fails, because naming a day no commit touched the file was the one way to
  satisfy this gate without being true.

  **The CI step runs before `git reset --soft`, and the order is load-bearing.**
  `git log` walks from HEAD; after the rewind HEAD is the base commit, so the
  edit the push introduced is unreachable and the pass reads the previous edit
  date — green on exactly the commit it exists to catch. It is the only gate in
  that workflow mixing a working-tree read with a history read, which is why it
  is the only one moved above the line.

  **What the gate found on its first run is measured: seven of the eight
  traceable records were stale**, by one day to three weeks, and none said so.
  All seven now carry the mark. Covered by
  [`tests/hooks/test-check-skill-behavior-records.sh`](tests/hooks/test-check-skill-behavior-records.sh),
  twelve cases over throwaway git repositories with pinned commit dates, added to CI.

- **Every `RESULT-*` states its N, and says when its runs are not replicates.**
  A **Runs** row is now required — its presence by the gate, its content by
  whoever writes it; the gate cannot read a sentence. The reason is external and measured: across
  60,000 trajectories, single-run pass@1 estimates vary by 2.2 to 6.0 percentage
  points, and the variance persists at temperature 0 (Bjarnason, Silva &
  Monperrus, *On Randomness in Agentic Evals*, arXiv:2602.07150, 2026);
  detecting a 2-point difference at 80% power takes about nine runs. Nothing in
  this directory has nine runs of anything — the largest is six — and two
  records that read as a progression (1/3, then 2/3, then 3/3) are **one run of
  each of three different rules**, which the new rows now say out loud.
  [`tests/skill-behavior/README.md`](tests/skill-behavior/README.md) (section
  "What N buys") states the consequence: these are dated case studies, strong
  evidence that a defect can occur and weak evidence about how often, and a
  record may be cited for the first and not the second.

### Fixed

- **`verification-before-completion` opened by claiming "No flow names it",
  and one flow does.**
  [`skills/systematic-debugging/SKILL.md`](skills/systematic-debugging/SKILL.md)
  (section "Phase 4: Implementation", at its "Verify Fix" step) names it, and
  [`tests/skill-behavior/README.md`](tests/skill-behavior/README.md) (section
  "Verification before a completion claim") already recorded that single
  invoker as what prompted the measurement — the three texts disagreed, and no
  gate could see it, because
  [`scripts/check-links.sh`](scripts/check-links.sh) resolves markdown links,
  not `superpowersplus:` namespace references. The skill's opening, the
  matching `CLAUDE.md` trap row, and the record's README now state the same
  measured position: one invoker, description-firing everywhere else. The
  invoker stays — the record measured that wiring adds nothing, not that the
  existing edge harms, and removing it would be a behavior change no
  measurement asked for.

- **The anchor written for that fix was one no gate could read either.** It named
  `Phase 4, "Verify Fix"` — a numbered item, not a heading, in a form
  `SECTION_REF` does not match. Both citations now use the canonical
  `link, section "..."` form, which took the repository from 87 resolved section
  references to 89: the anchor that documents the fix is now covered by the same
  pass that would have caught the original defect.

## [1.21.0] - 2026-08-24

### Added

- **One CommonMark fenced-block scanner, shared by the markdown gates.**
  [`skills/writing-plans/scripts/mdfence.py`](skills/writing-plans/scripts/mdfence.py)
  returns a per-line fenced/not mask and the line of any unclosed fence. It sits
  beside `check-cross-references` rather than under `scripts/` because
  [`scripts/package-codex-plugin.sh:336`](scripts/package-codex-plugin.sh) fails
  the Codex build on any archived `scripts/` path while `:241` stages `skills`
  wholesale — a module at the root would reach one harness and not the other.
  Tests: [`tests/hooks/test-mdfence.sh`](tests/hooks/test-mdfence.sh).

### Fixed

- **Six table-of-contents entries pointed at headings that do not exist.** In
  [`skills/writing-skills/anthropic-best-practices.md`](skills/writing-skills/anthropic-best-practices.md),
  the entries labelled `Executive summary`, `Key findings` and `Recommendations`
  — twice each — targeted lines of a report template shown inside a fenced
  example, which produces no heading and therefore no anchor. They were this
  project's own addition in `46cf5c4`, generated by walking the file as flat
  text: their order in the list is exactly where those lines sit in the
  document. `scripts/check-links.sh` passed them because its fence mask had the
  same blind spot, which is the defect the same release corrects. Measured: the
  list had one entry per real section once these six were removed, with none
  left over on either side.

- **`check-cross-references` read the whole document as flat text.** Every
  structural extractor in
  [`skills/writing-plans/scripts/check-cross-references`](skills/writing-plans/scripts/check-cross-references)
  now reads through the shared fence scanner: sections, task headings, the
  announced-task-count comparison, coverage-matrix rows and the task-criteria
  count. Three extractors deliberately keep reading the raw text — the test
  finder, because a plan creates its tests inside fenced blocks; the citation
  pass, because no `file:line` citation in `docs/` sits inside a fence and one
  in a code comment is legitimate; and the id-citation pass, because a real
  citation of `IR2` does live inside a fence. Measured: the extractor reported
  `tasks present 17` for a plan carrying five real task headings, and failed a
  plan that correctly announced its own count.
- **The cross-reference suite reported only its first failure, and never its
  summary.** In [`tests/hooks/test-check-cross-references.sh`](tests/hooks/test-check-cross-references.sh)
  the diagnostic re-run in the failure branch is a pipeline whose first command
  exits non-zero by design; under `set -euo pipefail` that aborted the whole
  script, so every failure after the first was invisible and the
  `N test(s) failed` line was unreachable. Found while running five new cases
  red at once and seeing one.
- **An unterminated fence now fails the document instead of silencing the
  checks.** Everything after an unclosed opener reads as fenced, so the task
  count falls to zero and the criteria list empties — a green verdict on a
  document the gate stopped reading half-way. It now exits 1 naming the line the
  fence opened on, following
  [`scripts/check-no-dispatch.sh:120`](scripts/check-no-dispatch.sh), which
  fails when it cannot read what it was asked to check. Measured 2026-08-24
  across the 131 versioned `.md` files of this repository: none has an unclosed
  fence, so the rule changes no current verdict.
- **A section was terminated by its own subsection, and a criterion label with a
  letter suffix matched nothing.** `section()` in
  [`skills/writing-plans/scripts/check-cross-references`](skills/writing-plans/scripts/check-cross-references)
  used one pattern for both ends, so a `## Acceptance Criteria` organising its
  items under `###` ended at its first subsection — measured on a committed
  spec, it returned zero ids where the section defines 21, and fourteen ids were
  reported as cited-but-undefined. Separately, `TASK_CRIT` carried no optional
  letter suffix while the pattern on the line above it did, so a label written
  `T1.1a` matched nothing at all and its coverage-matrix row stopped being read
  as a row: measured, the same plan exits 1 with `T1.1` and 0 with `T1.1a`, a
  false pass one character wide. Two names assigned and never read were removed
  with them.
- **`scripts/check-links.sh` approved links whose anchors did not exist.** Its
  fence mask flipped on any three-backtick line, so a three-backtick block
  nested inside a four-backtick one closed the outer block and the headings
  inside the example became real anchors. Measured 2026-08-24: replacing the
  mask with the CommonMark rule and changing nothing else moved the gate from
  exit 0 to exit 1, naming six links in
  [`skills/writing-skills/anthropic-best-practices.md`](skills/writing-skills/anthropic-best-practices.md)
  whose targets are all inside fenced blocks. The same blind spot ran the other
  way in the link pass, which is the half that was not measured when the defect
  was recorded: a link written inside a nested fenced block was checked as
  prose, because the inner opener had already closed the outer block. It now
  shares the scanner with `check-cross-references`, and a test asserts that
  neither carrier keeps fence logic of its own.
- **`task-brief` carried the same naive fence toggle, and now carries the
  CommonMark rule in awk.** It keeps its own implementation rather than
  importing the shared scanner: reaching a module in another skill's directory
  would make one shipped skill depend on another's internals. **It was recorded
  as latent and it is not.** Measured 2026-08-24 over all 252 task extractions
  of every plan under `docs/` — 21 plans (4 in `docs/plans/`, 17 in
  `docs/superpowers/plans/`), task numbers 1 through 12 — 250 are
  byte-identical under both rules and 2 diverge, both in the plan that
  introduced nested fences to this repository. Task 2 came out at 286 lines
  instead of 141, running past its own end because the next task's heading read
  as fenced; task 7 came out at 59 instead of 204, stopping at the first
  four-backtick opener. The same defect in both directions, in the document that
  describes it. It also gains its first suite:
  [`tests/hooks/test-task-brief.sh`](tests/hooks/test-task-brief.sh), where its
  only prior assertion checked where the brief file lands and ran in a suite CI
  does not execute.
- **The test-name comparison knew five test vocabularies and not this
  repository's.** `TEST_DEF` in
  [`skills/writing-plans/scripts/check-cross-references`](skills/writing-plans/scripts/check-cross-references)
  matched `it(...)`, `test(...)`, `describe(...)`, `def test_` and `func Test`;
  every suite here is bash, naming its cases by shell function call. Measured on
  this branch's own plan: 26 real tests reported absent at once. It now asks a
  question no language answers differently — does the name appear inside one of
  the document's fenced code blocks, which is where a step writes a test. The
  simpler form, "the name appears anywhere outside the matrix", was measured and
  rejected: `writing-plans` requires every task criterion to name its covering
  test, so the criterion line carries the name even after a step renames the
  test, and the check passes on the one desync it exists for. That difference is
  a case of its own in the suite, and the rejected form fails exactly it and
  nothing else.
- **Two branch-lifetime assertions had been welded into permanent CI suites.**
  The IR6 corpus comparison in
  [`tests/hooks/test-check-cross-references.sh`](tests/hooks/test-check-cross-references.sh)
  derived its baseline from `merge-base main HEAD`, which becomes HEAD itself
  once the branch merges — on the next push to `main` the extracted "before"
  script would have been the current one, failing to import a module the test
  does not extract, and reporting all 33 documents as moved. It is now pinned to
  the commit the branch was cut from, and extracts the module beside the script
  when the baseline carries one. The IR8 file-list assertion in
  `tests/hooks/test-task-brief.sh` was removed outright: it encoded this
  branch's own file list and failed on every branch cut afterwards. A gate that
  can only be vacuous or wrong is the defect this release exists to name.
- **The awk copy of the closing rule owed a gate and did not pay it.** Three of
  its discriminating terms — closer character, closer length, closer info string
  — had no red state under any mutation. `tests/hooks/test-task-brief.sh` now
  carries a differential case asserting that
  [`skills/subagent-driven-development/scripts/task-brief`](skills/subagent-driven-development/scripts/task-brief)
  and `mdfence.fence_mask` extract identically from a fixture exercising each
  term, plus the pair that proves either is right. Measured: each of the three
  terms now has a mutation that turns the differential red.
- **Two citations in `scripts/check-skill-size.sh` never pointed at what they
  claimed, and nothing could have caught them.** The script cited
  `anthropic-best-practices.md:241` for "Keep SKILL.md body under 500 lines" and
  `:1109` for its checklist repeat; measured against the pre-branch file, `:241`
  read "Avoid vague descriptions like these:" and `:1109` was a bare fence
  marker. The claim lives under the section "Token budgets". Removing six
  table-of-contents entries in this same release shifted every line below them
  by six, which is how the rot surfaced. Both citations are now anchored by
  section title, per [`CLAUDE.md`](CLAUDE.md)'s own rule for a file this project
  edits — and the reason no gate saw it is worth writing down:
  `scripts/check-links.sh` reads `README`-family, `docs/**/*.md` and
  `skills/**/*.md`, so **a citation in a shell comment is read by nothing**.
- **`skills/writing-plans/scripts/check-cross-references` truncated its own
  `--help`.** `usage()` sliced the header by line number (`sed -n '2,34p'`), so
  growing the header above it cut the Usage block off the output with nothing to
  notice. It now slices by content. Swept: `scripts/lint-shell.sh:14` has the
  same shape. It was left alone at the time, and the sweep is what found it:
  Task 9 closed it later in this same release, along with a third carrier — see
  the `--help` entry below.
- **`mdfence.py` records its measured deviations from CommonMark.** Checked
  against the specification's own conformance suite, restricted to the 29
  normative "Fenced code blocks" examples: **25 agree**. The four that do not are
  the three documented limits — a backtick opener whose info string contains a
  backtick (examples 138 and 145; 0 occurrences in this repository), indented
  code blocks (example 134; 6 fence-shaped lines indented four or more spaces
  exist, all of them already inside an outer fence, so none is exposed), and
  fences inside block quotes (example 128; **6 occurrences**, each a single
  command line carrying no heading, no table row and no link — the docstring had
  said zero, which was wrong). The module's own docstring now carries that six
  and the three files it sits in, so the two records no longer disagree.
- **Two of this release's own criteria had no red state for the mechanism they
  name.** The covering test for "the announced task count is read from prose"
  was byte-identical to the one for "fenced task headings are not counted": its
  fixture carried a fenced *heading* and no fenced *count sentence*, so it went
  red against the pre-fix code through the neighbouring mechanism and never
  through its own. Measured: reverting the announced-count scan in
  [`skills/writing-plans/scripts/check-cross-references`](skills/writing-plans/scripts/check-cross-references)
  to raw text left the whole suite green. Separately, the differential gate on
  the awk copy in
  [`skills/subagent-driven-development/scripts/task-brief`](skills/subagent-driven-development/scripts/task-brief)
  covered only the three *closing* terms; the two *opening* terms — minimum
  length three, at most three spaces of indent — were equally the copy's alone
  and equally uncovered, and widening either left both suites green. Each of the
  five terms now has a mutation that turns its suite red, and the fixtures
  carry the discriminating input rather than a neighbour's.
- **`usage()` traded a truncation for a runaway.** Slicing the header by its
  last sentence fixed `--help` cutting off mid-block, and introduced the
  opposite failure: reword that sentence and the range runs to end of file,
  printing the python heredoc with it. It now slices by the header's *shape* —
  every comment line before the first line of code — which no wording can
  break.
- **The gate's summary line quietly lost a field, and that is a deviation from
  this release's own design note.** `tests created by a step` no longer appears
  in `check-cross-references` output; the language-blind comparison that
  replaced it has no separate count to report. The note reads "It does not
  change what any carrier reports, only what each one reads. No new counts
  field, no new output shape" — only the second sentence's first clause permits
  this; its second clause and the sentence before it both forbid it, so
  recording it as compliance would be quoting a third of the bullet. The
  carrier reports one field fewer and the output shape changed. Deviation,
  accepted, written down.
- **The matrix check cannot see a plan that quotes a test it never ships, and
  this release is the demonstration.** `check-cross-references` builds the set
  of created tests from the plan's own fenced blocks, which is what makes it
  language-blind. A plan whose step *quotes* a test it then does not write
  therefore passes: the name is in a code block. Measured on this release's own
  plan — the coverage matrix named
  `tests/hooks/test-task-brief.sh > the branch touches only its declared files`
  after that assertion had been deleted, and the gate reported `exit=0`,
  `tests named in matrix 29`. The conformance audit caught it by opening the
  suite. Reading the shipped test files instead of the plan's code blocks is a
  different instrument, not a tightening of this one; the limit is recorded
  rather than closed. **Closed on 2026-08-24**, after the whole-branch review
  measured it: where a matrix cell already names the suite file as well as the
  case, that file is read and the case must appear in it. The fenced-block
  search stays for plans whose tests do not exist yet — an unresolvable suite
  path falls back to it rather than failing, so the new check adds reach and
  removes none. Measured on this branch's own plan: 34 cells resolved to a
  suite, 0 absent. Its test is the pair only this instrument can tell apart —
  both documents carry the name inside a fenced block, so the code-block search
  passes on both. **One residual, named rather than denied:** the case name is
  searched as a substring of the whole suite file, so a name surviving only in a
  comment still passes — measured the same day, when a renamed case kept its old
  wording in the section header above it and the matrix stayed green until that
  header was fixed. Requiring the name outside a comment would put a comment
  syntax per language back into the check whose point is knowing none.

- **Five findings from the whole-branch review's Minor bucket, closed.**
  `.gitignore` had no `__pycache__` rule, so the bytecode the shared module can
  produce was committable into a `skills/` tree that ships to Codex wholesale —
  the two `sys.dont_write_bytecode` flags guard two callers by name, and the
  ignore rule covers the ones nobody has written yet.
  [`tests/hooks/test-mdfence.sh`](tests/hooks/test-mdfence.sh) deleted a
  directory out of the developer's own checkout as a setup step and now runs
  that case against the copy the neighbouring case already builds. Its case
  `the module ships where the packager stages` asserted neither half of its own
  name — a file test on a path the suite hardcodes, and a property of the
  packager — and is renamed to what it reaches; the archive half is `AC19`'s and
  measured in [`tests/codex/test-package-codex-plugin.sh`](tests/codex/test-package-codex-plugin.sh).
  A comment in [`tests/hooks/test-task-brief.sh`](tests/hooks/test-task-brief.sh)
  counted five fenced task numbers where the loop checks four. And `IR4` said
  each carrier resolves the module from its own path while
  [`scripts/check-links.sh`](scripts/check-links.sh) inserts a cwd-relative one:
  legitimate, because that script has already `cd`-ed to a `$0`-derived root by
  then, and now written down so the next reader does not "fix" it.
- **`usage()` traded the runaway back for a truncation, and neither form ever
  had a red state.** Slicing the header at "the first non-comment line" cut
  `--help` at the first blank line: measured, one paragraph break inside the
  header dropped the output from 44 lines to 19, silently — the same failure
  the line-number slice had. A blank line is not a line of code, and the rule
  now says so. The three slicing rules this function has carried each broke on
  a plausible edit to the text they print, so
  [`tests/hooks/test-check-cross-references.sh`](tests/hooks/test-check-cross-references.sh)
  now runs `--help` over three copies of the carrier — as shipped, with a blank
  line inserted in the header, and with the header's final sentence reworded —
  and asserts a late header line survives and no line of code appears. Both
  directions have a mutation that turns it red.
- **The coverage matrix named a case that could not fail for the criterion it
  covered.** `T3.5` is a *number* — the `task criteria` count omitting fenced
  labels — and the plan named a `run_case`, which reads only the exit code.
  Measured: reverting the extractor to raw text moves the printed count from 1
  to 2 and leaves that case green. The covering test exists and reads the
  number; the plan now names it, and carries it in the step that creates it.
  Found by the conformance audit, which opens the suite — not by the matrix
  gate, which cannot.
- **Two more criteria were cited to a case that could not fail for them, and
  both are the same shape as the one above.** `AC8` — "a test created inside a
  fenced block is still discovered" — cited a single passing document, and a
  single document cannot settle it: the name a coverage-matrix row cites is
  extracted *from that row*, and rows are prose, so blinding the test finder to
  fenced content leaves the name findable in the row that named it. Measured:
  under that blinding the cited document still exits 0. It is now a pair, whose
  second half names a test written only in prose and requires it to fail —
  red under the blinding, while the first half stays red under a finder that
  sees nothing. `AC11` — "an unterminated fence exits 1 **and** the message
  names the opening line" — cited a case reading only the exit code; measured,
  stripping the line number from that message left every case in every suite
  green. The new case computes the expected line number from its own fixture
  and greps the message for it, and goes red both when the number is wrong and
  when the failure is disabled entirely.
- **A test's perturbation could stop perturbing anything, silently.** The
  `--help` case above builds a copy of the carrier with the header's final
  sentence reworded — and keyed that rewording on the sentence's current text.
  Reword it in the carrier, which is exactly what the case exists to prove
  nothing depends on, and the substitution matches nothing, the copy becomes
  identical to the original, and the runaway direction stops being tested while
  still reporting a pass. Measured: in that state the case passed over the
  precise defect it was written for. It now compares each perturbed copy against
  the original and fails if they are the same, the guard
  [`tests/hooks/test-check-evidence-line.sh`](tests/hooks/test-check-evidence-line.sh)
  already uses for the same reason.
- **The criterion guarding this release's whole thesis could not fail for it.**
  `AC18` says neither markdown gate keeps fence-scanning logic of its own and
  each takes the mask from the shared module. Its test grepped the two carriers
  for four literal spellings — and all four were text this release had just
  deleted, so it detected the past rather than the property. Measured: a
  correct, independent CommonMark scanner written into
  [`scripts/check-links.sh`](scripts/check-links.sh) under fresh names, with the
  import removed, left every suite and every gate green. A blacklist of
  spellings cannot be completed; a second implementation only has to avoid the
  words someone thought to list. **Three further instruments were tried before
  one held, and each was measured with the whole battery green.** Asserting the
  import is present is still a text search: a comment quoting the string beats
  it, and so does a live-but-unused import. Deleting the module and requiring a
  refusal asks about the module's *presence*, and a carrier can depend on the
  presence while ignoring the contents — keep the real `try/except`, which still
  prints the refusal, and shadow the imported names with a duplicate defined
  after it. What holds asks about *behaviour*: the module is replaced by a stub
  that masks nothing, and each carrier's verdict must MOVE. A carrier running
  its own scanner is not moved by a module it does not use. **Measured, with the
  residual named rather than denied:** no rename, comment, dead import, shadowed
  name or independent duplicate defeats this — a deliberate canary does, a
  statement whose only function is to read the module so the exit code moves.
  That is not what a careless refactor produces, which is the class this gate is
  for. The two copies differ only in the module, and the pair asserted is
  specific (0 then 1) rather than merely different, so a carrier that crashes
  under the stub is not read as one that moved.
- **`AC19`'s named evidence was empty for half of what `AC19` asserts.** It
  claims the Codex archive carries the shared module *and* holds no `scripts/`
  path, and named a suite that only ever checked the second. Measured: deleting
  the module and committing left that suite green while the module's own suite
  went red. [`tests/codex/test-package-codex-plugin.sh`](tests/codex/test-package-codex-plugin.sh)
  now asserts the module is in the extracted archive — it is a runtime
  dependency of a shipped skill, so its absence is an `ImportError` for every
  Codex user, not a packaging detail.
- **The file-scope criterion permitted a directory where it meant four files,
  in the one class that had already been fixed elsewhere for that.** `IR8`'s
  test class read "under `tests/hooks/`" — the same directory form that, one
  class down, silently absorbed another branch's document and was replaced by
  an explicit list. Both classes now name their files, and the method recorded
  beside them now says which diff to charge: the branch point against the
  **working tree** plus untracked files, never `<branch point>..HEAD`. Measured:
  the committed-only form reported a pass on a tree whose uncommitted change
  touched a file no class named — the check could not see the violation it
  exists to catch.
- **A test that names a property is not the same as a test that measures it —
  three instruments deep.** `AC18` says each markdown gate *obtains* its mask
  from the shared module. A blacklist of source spellings was beaten by writing
  a correct duplicate under new names. A grep for `from mdfence import` was
  beaten by that same duplicate plus **one comment line quoting the string** —
  and by a live-but-unused import. Both measured, both leaving every suite and
  every gate green. **That sentence described an instrument this same release
  then measured as beaten** — keeping the real `try/except`, which still prints
  the refusal, and shadowing the imported names passes it. What shipped
  substitutes a stub and requires the verdict to move.
- **Two criteria named a document and a number, and nothing read either.**
  `AC4` states that a named committed spec reports `AC/IR defined 26` with no
  "cited but not defined" failure; `AC1` states another reads `tasks present 5`.
  Both were covered by cases reading an exit code on a synthetic fixture, and
  the named documents keep their exit codes regardless — one of them already
  exits 1 for an unrelated citation. Measured: truncating `section()` at its
  end-of-file return left all three suites green while the document `AC4` names
  lost its section boundaries. Truncating the mid-loop return as well reports
  `AC/IR defined 11` and reddens the corpus case too — an earlier note here said
  `20`, which no command reproduces. The suite now reads the numbers out of the
  summaries of the documents the criteria name.
- **The nine pre-existing cases were guarded by name only.** `IR5` requires them
  to still pass *unmodified*; the guard grepped for `run_case "<name>"`.
  Measured: replacing a case's document with `# nothing` keeps the name, guts
  the assertion and leaves the guard green. It now compares each case's body
  against the commit the branch was cut from.
- **Thirteen `file:line` citations in six live documents were broken by this
  release and repaired, and five more that were already stale before it were
  repaired alongside.** Two edits caused it: removing six table-of-contents
  lines from [`skills/writing-skills/anthropic-best-practices.md`](skills/writing-skills/anthropic-best-practices.md), and adding comment lines to
  [`scripts/check-skill-size.sh`](scripts/check-skill-size.sh), which pushed
  `MAX=500` from `:26` to `:34` — a line five other documents cite. Two sweeps were
  needed: the first found twelve and declared the class closed, and a review then
  found six more — including a `ci.yml` range inside a document the class itself
  names. A class is not exhaustive because the sentence saying so was written.
  **A third sweep then found that five of the eighteen were never this release's
  to repair**: those five `CHANGELOG.md` citations were already pointing at the
  wrong line at the branch point — correct when their document was written,
  stale by the time this branch started — and the first repair moved them by a
  wrong offset (365, where the diff shows 377) from a baseline that was itself
  wrong, landing on unrelated prose. **Repairing a citation without opening what
  it lands on is the same defect as writing it that way.** Repairing the number
  a second time would have been the same mistake a third: the line moved again
  while this entry was being written, because writing it added lines above.
  Those five now use the form [`CLAUDE.md`](CLAUDE.md) already prescribes for a
  file this project edits every release — a markdown link plus a section title,
  naming the released section that holds the line. That form is read by
  `check-links.sh`'s section pass, which line numbers never were: the count of
  gated section references went from 80 to 85. The release's own file-scope
  criterion had named two of the six, because two was what had been noticed; the class was always "every citation this branch's edits
  invalidated" and now says so. **No gate finds these**: the cross-reference
  check verifies only that a cited file opens and is long enough, and it charges
  no citation whose path carries no dotted extension — one of this release's own
  citations had been wrong since the day it was written for exactly that reason.
- **All three carriers that build `--help` by slicing their own header were
  broken or one edit away from it, and none of the three had a test.** The
  pattern is the same everywhere: the usage text and the header comment are one
  source, and the slice that joins them is keyed on something that moves.
  [`scripts/lint-shell.sh`](scripts/lint-shell.sh) sliced by line number
  (`sed -n '2,9p'`) against a ten-line header, so the released tree ended
  `--help` mid-sentence at "Use --all for the full tracked" — the missing clause
  is back.
  [`scripts/sync-to-codex-plugin.sh`](scripts/sync-to-codex-plugin.sh) sliced
  between two literal markers, and a `sed` range whose end pattern stops
  matching runs to end of file: measured, rewording `# Requires:` took `--help`
  from 13 lines to 48. Both now slice by the header's *shape* — every comment
  or blank line before the first line of code — and both carry a differential
  case over perturbed copies of themselves, including a guard that fails when a
  perturbation stops perturbing anything. The second keeps one literal marker
  by design, `# Usage:`, because it prints a section rather than the whole
  header; losing that marker now exits 2 with a message instead of printing
  nothing.
- **`NF == 0`, not `/^[[:space:]]*$/`, for "this line is blank" in awk — and
  the first reason given for it was false.** A blank line is a record with zero
  fields under the default field separator, which POSIX (`awk`, DESCRIPTION: "a
  field is a string of non-`<blank>` non-`<newline>` characters") and `mawk(1)`
  section 11 document in the same terms, so the rule needs no character class at
  all and cannot depend on whether a given `awk` implements them. That is the
  reason, and it is the whole reason.
  **What this release first wrote instead was that `mawk` — the default `awk` on
  Debian and Ubuntu — does not implement POSIX classes**, inferred from `mawk(1)`
  section 3 enumerating the metacharacters it honours and naming none. Measured
  afterwards on `mawk 1.3.4 20260302`: `[[:space:]]`, `[[:upper:]]` and
  `[[:digit:]]` all match. **Documentation silence is not absence**, and this
  project's own rule says a tool finding needs the vendor's document *and* a
  local measurement; the document was read for an absence and no `mawk` was ever
  run. The code was already right; the sentence under it was not, in three
  source files and here. Swept every tracked file with a shell shebang: this was
  the only POSIX class in an `awk` program, and the two that remain are `bash`
  constructs where they are native and correct — that sweep stands, only its
  stated motive was wrong.
- **The release's own file-scope criterion named two of its classes loosely, and
  a check written from the criterion's text found it.** Reading the class list
  out of the document — rather than from a list typed alongside it — and
  charging the branch diff against it in three directions surfaced two defects
  no reading had. One class said its two carriers came "with their suites" and
  named no path for either, so both suites belonged to no class. Another said
  "this branch's own spec and plan, under `docs/superpowers/`", and the
  directory form permits any document under that tree: measured, it silently
  absorbed a second branch's spec that a different class already covered. Both
  now name their files one by one. The third direction — a file claimed by two
  classes — is what caught the second defect, and it is the direction a check
  written from a hand-copied list cannot have: the copy was more generous than
  the document, which is why it passed.
- **The third of the three `--help` carriers had two perturbed copies for the
  three edits its criterion names, and its anchor measured the wrong line.**
  `AC21` names a line added, a blank line and a sentence reworded;
  [`tests/shell-lint/test-lint-shell.sh`](tests/shell-lint/test-lint-shell.sh)
  carried the first two. Measured: reinstalling
  `sed -n '2,/baseline, or pass files explicitly/p'` in
  [`scripts/lint-shell.sh`](scripts/lint-shell.sh)'s `usage()` — the very form
  the same release had already had to remove — left this suite green, while both
  sibling carriers caught their version of it. The seventh member of this
  branch's own class: a criterion whose cited test cannot fail by the mechanism
  its name announces. Fixing it exposed a second one in the same block: every
  copy was checked against the last header line **of the file as shipped**,
  but two of the three edits move that line off the end — the copy that grows
  the header appended a sentence and then asserted an earlier one survived,
  perturbing in one direction and measuring in another. Each copy is now
  anchored on its own last header line. Both mutations now turn the suite red,
  and the growth copy fails under the line-number slice it exists for, which it
  did not before.

- **[`docs/testing.md`](docs/testing.md), section "Gates CI runs beyond the
  suites", listed seven of the ten gates the workflow runs.** The three added
  with the review gates — `check-evidence-line.sh`, `check-escalation-shape.sh`
  and `check-no-dispatch.sh` — were never written in. Not this branch's defect;
  it predates it, and it sits three lines above the paragraph explaining why the
  suite list was deliberately not written down. The list now carries the command
  that answers it, so it is a condition rather than a tally.

- **Three defects in this release's own last round, found by re-reading it
  rather than by any gate.** Two were introduced by the round that closed the
  review's Minor findings, and both produce green. Moving the bytecode case in
  [`tests/hooks/test-mdfence.sh`](tests/hooks/test-mdfence.sh) off the
  developer's checkout and onto a copy built by the neighbouring case made an
  absent copy indistinguishable from a clean one: measured, pointed at a copy
  that was never built it reported PASS and the whole suite passed with it. The
  case now refuses a missing copy and requires the carrier's own summary line as
  the receipt that it ran — the absence of a `.pyc` proves nothing if nothing
  ran. In [`tests/shell-lint/test-lint-shell.sh`](tests/shell-lint/test-lint-shell.sh)
  both perturbed copies key on line 10 being the header's last line; let the
  header grow and they still perturb, in the middle, while the anchors measure a
  line that is no longer the end. The perturbation decays without changing,
  which the `cmp -s` guard cannot see, so the assumption is now asserted: line 11
  must be the first line of code. The third: the new matrix-against-suite check
  dropped a suite it could resolve but not open, in silence, where the citation
  pass three blocks below reports exactly that as a break. It reports it now too.

- **The branch audit found an eighth member of this release's own defect class,
  in the one carrier the earlier sweep had cleared.**
  [`tests/hooks/test-check-cross-references.sh`](tests/hooks/test-check-cross-references.sh)
  anchored its `--help` truncation check on the string `REPO_ROOT`, which sits
  three lines short of the header's end. Measured by the audit: with
  `sed -n '2,42p'` reinstalled in `usage()`, the header lost its final sentence
  and the case reported PASS. Each copy is now anchored on its own last header
  line, and where that line IS is asserted rather than assumed — the same repair
  `tests/shell-lint/test-lint-shell.sh` got one commit earlier. **A review had
  swept this class and reported the other two carriers covered**; that sweep
  measured the rewording direction, not the anchor's reach, and "no other cases"
  read the same for both.
- **`AC21` names three header edits; two of the three suites exercised two.**
  The line-added edit — the one a line-number slice cannot survive, and the one
  the release's own commit message names as such — was missing from
  `tests/hooks/test-check-cross-references.sh` and
  [`tests/codex-plugin-sync/test-sync-to-codex-plugin.sh`](tests/codex-plugin-sync/test-sync-to-codex-plugin.sh).
  Both now build a grown copy. Measured on the second: of the four combinations
  of {shipped, line-number slice} × {as shipped, grown}, exactly one truncates —
  so the copy is what separates the two implementations, and without it the
  mutation passes. The plan's `T9.1` and `T9.3` had enumerated two edits where
  the spec criterion requires three, and now enumerate three.
- **A gate code path shipped one commit earlier with no test, on a branch whose
  thesis is that this is not delivered.** `AC22` now states that a suite path
  which resolves and will not open is reported rather than dropped, `T8.4`
  covers it, and the case makes a real suite unreadable and requires both exit 1
  and the reason. Where the mode bits do not bite — root, some filesystems — the
  case says it could not measure instead of passing.

- **The ninth and tenth instances of this release's own defect class, both
  written by the pass that closed the eighth.** `T8.4` requires the gate to exit
  1 **and name the file** it could not read; the assertion grepped the phrase
  `cannot read`, which is the message its author had just written rather than
  the property the criterion states. Measured by the branch audit: a message
  stripped of the filename passed. It now greps the path. Then the new `AC23`
  case asked `git check-ignore -v` whether a rule matched and grepped
  `__pycache__` in the answer — but that command prints the pattern, a TAB, and
  **the path it was asked about**, and the path contains `__pycache__`. Measured:
  with the rule deleted the case stayed green, because `*.pyc` still matched and
  the probe was reading its own input back. `cut -f1` now reduces the output to
  the rule. Both failures have one shape: **an assertion written against the
  output in front of its author rather than against the property being claimed**,
  which passes at the moment it is written and can only be told apart by a
  mutation nobody had reason to run.
- **A claim in this release's own comment was false, and the audit measured it.**
  The `grown` copy added for `AC21`'s third edit was described as the one a
  line-number slice cannot survive. It is not: `grown` and `blank-line` both
  shift the header by exactly one line, so any range ending at the old last line
  fails on both together — and `sed -n '2,45p'`, a range tuned to today's
  header, passed all four copies. The copy now grows the header by twelve lines
  and the comment claims only what it measures: no fixed number of inserted
  lines rules out a range tuned past it.
- **`.gitignore` and `docs/testing.md` had reached the branch on a permission
  with no requirement**, which is the shape `AC21` was written to eliminate, one
  `IR8` class over. `AC23` and `AC24` state what each is for, Task 10 carries
  them, and `AC23` has a test whose red state is measured. `AC24` is charged by
  the audit and by no test, on `IR8`'s terms: this repository has no
  documentation suite, and the document carries the command that answers it.
- **Two measured numbers inside `IR8` had aged** — eight classes where there are
  nine, 25 files where there are 27 — and are dated rather than re-updated,
  since a re-updated number ages again on the next commit.

- **Three citations in this release's own spec were "repaired" into a defect,
  and the repair was reverted.** A review round reported
  `scripts/check-links.sh:266`, `:361` and `tests/hooks/test-check-links.sh:184`
  as stale; they were renumbered to their post-fix lines. The spec's own
  governing paragraph forbids exactly that — *"Every `file:line` citation in this
  document is a PRE-FIX line number, and they are left that way on purpose"*,
  and *"Renumbering them is what would be wrong"* — because a design document
  renumbered to match the code it produced reads as if it had described the
  result. The same paragraph **already listed** `test-check-links.sh:184` among
  the nine citations known to have shifted: the document had measured and
  recorded the very fact the repair was reacting to. The three are back to their
  pre-fix values. **A finding that names a real difference is not yet a defect** —
  what makes it one is a rule, and the rule was three lines above the line being
  edited.

- **The eleventh instance of this release's defect class, in the sibling of the
  carrier where the tenth was found.** The `grown` copy added to
  [`tests/codex-plugin-sync/test-sync-to-codex-plugin.sh`](tests/codex-plugin-sync/test-sync-to-codex-plugin.sh)
  inserted one line at the same position as `blank-line-in-block`, so the two
  shift the header identically and no slicing rule can fail on one without the
  other. Measured by the branch audit: `sed -n '15,28p'`, a range tuned to
  today's header, passed all four copies and the case reported PASS — leaving
  `T9.3`'s third named edit asserting nothing. The copy now grows the block by
  twelve lines. Measured after: of {shipped, tuned range} × {one-line copy,
  twelve-line copy}, only the tuned range against the twelve-line copy truncates.
  **The same fix had been applied to the other carrier one commit earlier and
  not replicated here** — the pass that closed instance ten grew one copy of the
  pair it had just written.

## [1.20.0] - 2026-08-24

### Added

- **`writing-plans` now tells the author to read the branch's own `git log` when the work is a replan.** Work from an earlier plan survives in the branch and does not appear in a diff against the main branch, so a task telling the implementer to build what is already there reads as new work at every gate downstream. Measured: 3 of 10 findings in one review were artifacts that already existed.

- **The plan reviewer charges two defects it could not see before.** A step whose test asserts a value the implementation the same plan specifies would not produce — two independent statements about one behaviour, each correct alone, which a cheap implementer settles by changing the implementation. And two spec criteria that cannot both hold: the reviewer now reads criteria in pairs, each against the neighbours touching the same field. Measured: such a pair survived two rounds of adversarial spec review and surfaced only while writing the plan.

- **Both document reviewers now ask whether a state change can be applied, not only whether its target is right.** Measuring the target state and establishing that whoever applies the change can reach it are two claims, and only the first was ever checked. Measured: four independent review lenses and 68 catalogue measurements passed a defect of this shape; the gap was one line.

- **`receiving-code-review` now says a finding about a measurable fact is reproduced before it is acted on.** Measured: a reviewer reading an artifact under a stale version convention reported three type errors with file, line and error code, and running it again showed zero. Separately, two reviewers asserted opposite facts about the same code — the cost of settling that is one file read.

- **The pairs rule is measured against a control, not just written.** [`tests/skill-behavior/RESULT-criteria-read-in-pairs.md`](tests/skill-behavior/RESULT-criteria-read-in-pairs.md) records three runs against a planted contradiction. **The control is what the verdict rests on:** the same fixture, the same model, the same prompt with the rule's row deleted and nothing else changed — it listed `AC2` and `AC5` among the criteria it had cross-checked one by one, said all six were covered, and **approved the plan**. A verdict read off a single state cannot tell a rule that works from a behaviour that was there anyway. The second run passed all three criteria — the reviewer named both ids, refused to pick a reading, and routed the conflict back to the spec's owner — and the contradiction was the only blocking finding in its report. The first run is recorded too, and it did **not** measure the rule: the fixture cited a spec path that did not exist, so the reviewer stopped at the Plan Contract row above and reported the pairs check as *unverifiable rather than checked-and-passed*. That is a finding about the rule's reach — when the spec cannot be opened, the rule does not fall back to the criteria the plan itself quotes on each task's `**Spec criterion:**` line — and it cost nothing to collect.

## [1.19.1] - 2026-08-22

### Fixed

- **`assert_count` could not pass a zero, and eleven shellcheck warnings in
  `tests/claude-code/` had never been read.** `grep -c` prints `0` when it
  matches nothing **and exits 1 while doing it**, so the fallback
  `|| echo "0"` appended a second zero and `[ "0\n0" -eq 0 ]` died with
  *"integer expression expected"* — every `assert_count` expecting zero failed,
  including the ones that were right. It is `|| true` now; all the fallback ever
  had to do was neutralise the status. **Pre-existing, and measured as such**
  against the tree before this change rather than assumed.

  The warnings were fixed one at a time rather than as a batch, because two of
  the three classes are not defects. The four `SC2088` are the tilde in
  `~/.config/superpowers/worktrees` — **the string being searched FOR inside
  skill files, not a path this script resolves**. Taking shellcheck's advice
  would search for `/home/<user>/.config/…`, which appears in no skill, and all
  four assertions would pass unconditionally: the suggested fix turns four real
  assertions vacuous. A file-level `disable` records why. The five `SC2155`
  were real, and separating declaration from assignment **introduced a defect
  the warning does not mention**: callers source the helpers under `set -euo
  pipefail`, so a `grep` that finds nothing now killed the script at the
  assignment, before the two checks that report which pattern was missing —
  `local` had been swallowing that status by accident. Verified by difference,
  not by exit code, since both exit 1: without the explicit `|| true` the probe
  prints nothing, with it the probe prints `[FAIL] … pattern A not found`.
  `SC2320` was a real defect too — `$?` read after two `echo`s reported the
  echo's status, so `EXECUTION FAILED (exit code: …)` always printed the wrong
  number.

- **Ten rules were still standing on rebase cost, which
  [`CLAUDE.md`](CLAUDE.md), section "Relationship with Superpowers", forbids as
  a criterion and instructs be reported on sight.** Measured against
  `upstream/main` rather than recalled: an earlier note counted five. The worst
  three are the ones a user reads and follows — [`README.md`](README.md) and
  both [`docs/README.en.md`](docs/README.en.md) /
  [`docs/README.pt-BR.md`](docs/README.pt-BR.md) gave "rebase onto the
  upstream" as **step 1** of updating the plugin, a procedure this project
  ended on 2026-08-05, and one that now collides on contact:
  `tests/version-bump/test-bump-version.sh` exists on both sides, written
  independently. The step is gone from all three, replaced by what actually
  updates the plugin.

  In [`context-audit.md`](docs/context-audit.md): the veto on touching an
  upstream file "unless the rebase cost is in Step 1's table" is gone — it was
  not being followed anyway, `tests/shell-lint/test-lint-shell.sh` having taken
  23 of this project's lines. The `writing-skills/SKILL.md` ceiling exemption
  now gives the reason that already governs in
  [`check-skill-size.sh`](scripts/check-skill-size.sh) — **a deadline, the open
  structural review** — instead of a dead one competing with it; the old
  reason's premise was also measured false, **686 lines here against 679
  upstream, 17 added and 10 removed**, not "two changed lines, both the
  namespace rename". **The upstream-divergence measurement itself stays, and
  is the one thing here not deleted:** it is relabelled provenance rather than
  rebase cost, because reading it on 2026-08-22 found a defect they had fixed
  and this project had deleted instead, and two rules this project reached
  independently.

  [`SECURITY.md`](SECURITY.md) kept the visual companion's telemetry on, for a
  reason that never needed rebase cost: the mechanism and the credit are both
  Superpowers', and changing an inherited feature's default is a product
  decision, not a defect repair. Behaviour is unchanged and the switch stays
  documented. Two comments in
  [`ci.yml`](.github/workflows/ci.yml) are deleted rather than rewritten —
  one called `tests/shell-lint/test-lint-shell.sh` "a file we do not otherwise
  touch", and one promised the changelog gate is safe because the "Upstream
  base" line "is updated at every rebase", which [`CHANGELOG.md`](CHANGELOG.md)
  itself calls a fixed historical fact. **The tenth was found by the branch
  review, in the one file of the class that executes**:
  [`test-check-skill-size.sh`](tests/hooks/test-check-skill-size.sh) pinned the
  exemption with the comment *"upstream's file at upstream's length"* — false
  on its own terms at 686 against 679, and the same dead reason its sibling
  script had already been moved off. A sweep that reads prose and skips the
  test files misses the member that runs. Its fixture sizes stopped echoing the
  real file's line count for the same reason: any value over the ceiling
  exercises the same branch, and the removal of the exemption still turns the
  test red, which is what the pin is for.

### Changed

- **The no-dispatch clause names what a self-created reviewer is worth, which
  is the half that closes the rationalisation.** It said such a reviewer
  "duplicates a seat this process already provides" — true, and answerable with
  *"then it is redundant, not harmful"*. It now says the duplicate runs **at
  full cost and for a verdict that counts for nothing**. **The sentence is
  adapted from the upstream's own wording**, found by reading
  `obra/superpowers` v6.3.0 (`b36e082`, 2026-08-12), which added the same clause
  under the same heading after measuring the behaviour — 9 of 9 depth-2 spawns
  across 4 corpora. Their version is two bodies across four carriers — one for
  the three reviewer seats, one for the implementer's; this project keeps **one
  body across all seven carriers**, because
  [`check-no-dispatch.sh`](scripts/check-no-dispatch.sh) charges that the seven
  agree with each other, and per-role variants would leave nothing to compare.
  The trade is deliberate: their wording is more specific, ours is the one a
  gate can verify. Their second sentence — *"that review is already scheduled.
  Report instead."* — is not adopted for the same reason: it only makes sense in
  the implementer's seat.

## [1.19.0] - 2026-08-22

### Added

- **Seven review seats could each open another one, and the rule against it
  was unreadable by all of them.**
  [`using-superpowers/SKILL.md`](skills/using-superpowers/SKILL.md), section
  "Review Lives in the Gates", carries *"Between them, do not dispatch a review
  subagent on your own initiative"* — and the same file opens with a
  `<SUBAGENT-STOP>` block telling any subagent dispatched for a specific task
  to ignore the skill. Every reviewer and the implementer **is** such a
  subagent, so the one rule in this repository governing review dispatch could
  not be read by anyone able to violate it. The clause now sits in each of the
  seven prompts, charged by
  [`check-no-dispatch.sh`](scripts/check-no-dispatch.sh). **All seven copies
  are inside the prompt body the dispatched agent reads** — including
  [`final-branch-audit`](skills/final-branch-audit/SKILL.md)'s, which belongs
  in the auditor's prompt and not in the skill's own prose: placed there it
  would have told the controller never to dispatch, immediately above the
  section instructing it to. **The upstream measured the cost this avoids** —
  9 of 9 depth-2 spawns across 4 corpora were reviewers created by the
  implementer, and all 9 duplicated the review the controller dispatches
  anyway; that measurement is theirs, taken on Codex, and none equivalent was
  taken here. The dispatch graph itself was already correct: level 0 owns every
  seat. What was missing was the other half of the rule, stated where it can be
  read.

- **A gate for the clause that keeps a review seat from opening another one.**
  [`check-no-dispatch.sh`](scripts/check-no-dispatch.sh) reads seven declared
  carriers and fails when any has lost the clause. It is the third form this
  project copies on purpose rather than extracting, joining
  [`check-evidence-line.sh`](scripts/check-evidence-line.sh) and
  [`check-escalation-shape.sh`](scripts/check-escalation-shape.sh), and it
  exists for the reason [`docs/review-scopes.md`](docs/review-scopes.md),
  section "Why the form is copied rather than extracted", states: unified in
  place without a gate is just copied. The carrier list is declared in the
  script rather than globbed, so a carrier that silently lost the clause stays
  distinguishable from a file that never had it. **It charges the form, not the
  presence of a heading** — the heading must exist, be indented (which is what
  puts it inside the `prompt: |` body the dispatched agent reads, rather than in
  the skill's own prose that only the controller reads), and every carrier's
  clause body must be the same text. The first version matched a bare marker,
  and the branch review demonstrated two mutations that passed it: a carrier
  whose body read *"Feel free to dispatch helpers when convenient"*, and the
  clause parked in the controller's prose — **the exact defect this branch had
  already caught by hand while executing**, in the one gate built to catch it.
  All three now fail with their own message, each with a case in the suite.
  **It runs in both places its two siblings do** — [`githooks/pre-commit`](githooks/pre-commit) and its own
  CI step, separate from the step running its test suite. A gate with a passing
  suite and no run of its own proves only that it *would* work.

- **The execution-path criterion has one statement, at
  [`execution-path.md`](skills/writing-plans/references/execution-path.md).**
  It stood in eight places across three skills, so correcting it meant
  correcting it three times. Extraction at the third occurrence is this
  project's normal rule; the inversion that unifies a form in place governs
  subagent output formats and does not reach here.

### Fixed

- **A version argument was interpolated into a `jq` program, so an argument
  carrying a quote wrote whatever it liked into every declared manifest.**
  Reproduced before the fix: `bump-version.sh '2.0.0" | .pwned = "yes'`
  left `"pwned": "yes"` in `a.json`. Two halves, and they are not redundant —
  they fail in different places. The format check
  ([`bump-version.sh`](scripts/bump-version.sh), `cmd_bump`) was **anchored at
  the start only**, so it matched a prefix and accepted every character after
  it, while its own error message says *"expected X.Y.Z"*; it is anchored at
  both ends now. And `write_json_field` passes the value with `--arg`, as
  **data** rather than as program text, which is what holds if that check is
  ever loosened. **Measured, so the coverage is not overstated:** reverting
  `--arg` alone leaves the suite green — the new case charges the boundary, and
  `--arg` has no case of its own. Reverting the anchor alone fails it. The
  assertion asks `jq has("pwned")` rather than grepping, because the injected
  string appears inside the field *value* too when the argument is passed
  safely, and a text match cannot tell the two apart.

- **The write loop's `SKIP (missing)` branch became unreachable when the
  preflight landed in front of it, and went on reading as a live fallback.**
  It now aborts instead of skipping, named for what it actually is — a TOCTOU
  backstop for a manifest that vanishes between the two walks. Carrying on is
  the exact behaviour that let a bump move six manifests of seven and still
  exit 0. **No case covers it**, because the condition is not reachable without
  racing the script, and the comment says so rather than implying coverage.

- **`--check`'s tolerance had a case for a missing FIELD and none for a missing
  FILE**, which is the class the preflight had just added. The tolerance holds
  today — `cmd_check` reports `MISSING` and reads on — but a future refactor
  hoisting the existence guard into a helper shared with the bump would break
  it in silence. Verified by that mutation: made `cmd_check` return at the
  first absent manifest and the new case fails.

- **The gate that charges the no-dispatch form charged two of its three
  conditions by exclusion, and the defect it exists to catch walked through
  both.** Reproduced before the fix, exit 0 each time: the clause parked in the
  skill's own prose with **one** leading space instead of zero, and — once every
  carrier wrapped its body the same way — a second sentence reworded to *"dispatch
  as many helpers as you like"*. The first is
  [`check-no-dispatch.sh`](scripts/check-no-dispatch.sh)'s `indent == 0`, which
  rejects a single state and accepts everything else, while CommonMark renders
  1 to 3 spaces as a top-level heading exactly like zero; it now charges the set
  it accepts, `indent < 4`, the indent every carrier's `prompt: |` body actually
  uses. The second is that the body under comparison was the first non-blank
  line, under a comment promising *"a reflow is not a failure and a reword
  is"* — **false in both directions**, and measured so: an identical reflow
  failed, and a reword after one survived. The body is now every line up to the
  next heading, collapsed with the same normalization
  [`check-escalation-shape.sh`](scripts/check-escalation-shape.sh) has used all
  along. **This is the second cycle of one defect** — `074320f` was itself the
  repair of a gate charging a title instead of the form, and it moved the
  proxy rather than removing it. The two cases were added to the suite and
  **watched to fail first**: the same command that exits 1 on a one-space indent
  and on a reflowed reword exits 0 on the real tree, which is the difference,
  not a verdict.

- **Three stale counts survived the sweep that declared them swept, two of them
  in the files that same sweep edited.** The gate prints `8 carrier(s)`;
  `.github/workflows/ci.yml` said "the five carriers of the test-evidence line"
  and `githooks/pre-commit` said "the five carriers … never the four it must
  match", both a few lines above a comment the sweep had just written — and
  [`docs/review-scopes.md`](docs/review-scopes.md) still said "**Both** name
  what drifted" of three gates. Root cause: the sweep matched the word "two"
  across documents and never the counts inside code comments. All three now
  carry a condition instead of a number, the treatment the same cycle applied
  to [`docs/pre-commit-cost.md`](docs/pre-commit-cost.md).

- **[`docs/testing.md`](docs/testing.md) said counting the static suites here
  would age, directly above a list naming all eleven of them.** A list of names
  is a count wearing a disguise: it ages on exactly the same event. Both are
  gone, replaced by the condition — every directory under `tests/` except the
  three live-agent ones — plus the two commands that answer it, and the defect
  to look for between them: a suite in `ls -d tests/*/` with no step in
  `.github/workflows/ci.yml`.

- **Two more members of the class the version-bump preflight closes, and one
  the spec measured wrong.** A manifest **declared in `.version-bump.json` but
  absent** was skipped by the preflight and by the write loop, so the bump
  exited 0 having moved six manifests of seven — the same split repository the
  preflight exists to prevent, and a condition `--check` already reports as
  drift, so the two commands disagreed. The difference is in the state and not
  the exit code: before, the first manifest reached the new version and the
  closing audit reported the drift *after* the write; now nothing is written.
  Separately, `AC6` and the routing table said a modified file shows as `??`.
  **Measured in a scratch repository: a modified tracked file reports ` M`,
  never `??`, and refuses the removal with exit 128 exactly as an untracked one
  does** — so a worktree holding only modified files matched no row of the
  table at all, and the rescue that would have worked was never offered. The
  row now reads "entries, but no `!!` line". Two more things the table never
  said: the rescue's stash entry is reported to the human partner (`git stash
  list` is the only way anyone finds it again), and a go-ahead on ignored
  content authorises the **plain** removal — measured to exit 0 on ignored-only
  content — never `--force`.

- **A third gate for a copied form landed, and five sentences counting them
  still said two.** The branch-wide review found the class: `docs/testing.md`
  named thirteen suite directories where `ls -d tests/*/` returns fourteen and
  "ten of the thirteen" in CI where it is now every static suite;
  [`docs/review-scopes.md`](docs/review-scopes.md), section "Why the form is
  copied rather than extracted", said "Two carry that weight" and "Both run
  whole-tree" — while [`check-no-dispatch.sh`](scripts/check-no-dispatch.sh)
  sends its own failing readers to that very section; [`CLAUDE.md`](CLAUDE.md)
  said "the two shapes", against its own rule that this file keeps a relation
  or a condition and never a measured number. **The wording was changed so it
  cannot age again**, not merely incremented: the lists are enumerated where
  enumeration is the point and the counts are named as run-time output
  everywhere else. Two comments this branch itself wrote — in
  [`ci.yml`](.github/workflows/ci.yml) and
  [`githooks/pre-commit`](githooks/pre-commit) — carried the same defect on
  their first day and were rewritten the same way.
  [`docs/pre-commit-cost.md`](docs/pre-commit-cost.md) declared one untimed
  gate where there are three, and now states the condition instead of the
  number.

- **`bump-version.sh` wrote as it walked, and a manifest missing its field was
  not detected at all.** Measured by running the real script against three
  declared manifests: with the middle one holding unparseable JSON it exits 5
  with the first manifest already bumped and the third still at the old
  version — the repository split across two versions, and the audit that would
  have reported the drift never runs because `set -euo pipefail` aborts first.
  With the middle one **missing its declared field** it exits **0**, prints
  `b.json (version)  null -> 2.0.0` as a success, and creates the field in a
  manifest that never had it. A preflight now reads every declared field before
  any manifest is written. **The upstream's one-character fix — `jq -r` to
  `jq -er` in the shared reader — was not adopted:** that function has three
  callers, and under `set -e` it would turn `--check`, whose whole job is to
  list all seven and report drift, into a command that aborts at the first
  manifest it cannot read.

- **`git worktree remove` had no guard, and the class that loses most data
  never triggers one.**
  [`finishing-a-development-branch/SKILL.md`](skills/finishing-a-development-branch/SKILL.md),
  section "Step 7: Cleanup Workspace", ran the removal with nothing said about
  refusal — while git's own error names `--force` as the remedy, which deletes
  files that exist in no other place. **Measured in a scratch repository: a
  file matched by `.gitignore` produces no refusal at all.** The removal exits
  0 and takes it, so `.env` and local credentials are lost on the happy path,
  and `status --porcelain -uall` cannot see them — only `--ignored` reports the
  `!!` lines. Untracked content now gets a rescue that was measured to lose
  nothing (`git stash push -u`, then removal with no `--force`); ignored
  content stops the removal, because `stash push -a` would sweep
  `node_modules/` along with the `.env`, and no agent can tell them apart.
  `--force` has no authorisation path.

- **The link gate read 12 of the 48 markdown files under `docs/`, and the
  document describing it said it read all of them.**
  [`check-links.sh`](scripts/check-links.sh) collected `docs/` with
  `glob("*.md")` — first level only — while collecting `skills/` with
  `rglob`. That left `docs/superpowers/specs/`, `docs/superpowers/plans/`,
  `docs/plans/` and `docs/windows/` in no pass at all: 36 files, 18 specs and
  17 plans among them. **Proved by difference before the change, not read off
  the source:** the same broken link exited 0 inside
  `docs/superpowers/specs/` and 1 inside `docs/`. Meanwhile
  [`docs/docs-and-links.md`](docs/docs-and-links.md), section
  "What check-links.sh reads", described the local-link pass as covering
  *"everything in `docs/`"*. **A gate and its description disagreeing is worse
  than either being wrong alone** — the description is what a reader consults
  before deciding whether a document is covered, so the hole stayed invisible
  to exactly the person who would have closed it.

- **A live document was off the link diet the whole time, and nothing could
  see it.** With the pass widened, `docs/windows/polyglot-hooks.md` turned out
  to carry two URLs to a third party's issue tracker in its "Related Issues"
  section. The link text already named each issue, which is what the diet asks
  for — *"a name and a version identify a source without depending on somebody
  else's URL scheme"* — so the fix was to drop the URL and keep the name. This
  is the defect the hole was hiding, and it is why the widening was not
  bookkeeping.

- **The coupling definition must sit on one physical line in both files that
  carry it, and a reflow had broken one of them.**
  [`execution-path.md`](skills/writing-plans/references/execution-path.md) and
  [`subagent-driven-development`](skills/subagent-driven-development/SKILL.md)
  hold the same sentence near-verbatim by design, recorded in this branch's
  spec. Nothing gates the pair — both carrier lists in
  [`check-escalation-shape.sh`](scripts/check-escalation-shape.sh) and
  [`check-evidence-line.sh`](scripts/check-evidence-line.sh) are hardcoded, so
  a third gate is a new script, a new suite and a new CI step. **A wrapped
  phrase is invisible until a gate looks for it**, and this project's gate
  form for a copied form is a line-literal comparison: left split, the
  reference would have failed such a gate the day it was written. Word streams
  compared rather than read — the change is reflow only.

### Removed

- **`render-graphs.js` is deleted — it had not run since 2026-03-15 and
  nothing called it.** The script rendered a skill's ` ```dot ` blocks to SVG
  by shelling out to Graphviz. `911fa1d` added a `package.json` declaring
  `"type": "module"` for an unrelated opencode plugin test, which made every
  `.js` in the package an ES module; the script uses `require`. **Five months
  and six days, with no failing gate anywhere** — `git ls-files '*.svg'`
  returns one file and it is the logo, and no `diagrams/` directory has ever
  been committed. Repairing it was specified first and reversed: it would have
  left a script whose only real function needs a binary that
  [`CLAUDE.md`](CLAUDE.md), section "What does not belong here", keeps out of
  every automated check — the exact condition under which it broke silently.
  **The ten ` ```dot ` blocks and
  [`graphviz-conventions.dot`](skills/writing-skills/graphviz-conventions.dot)
  stay.** They never depended on the renderer: a model reads them as text, and
  the renderer existed to produce pictures for a person.

### Changed

- **Plans and specs are exempt from the third-party diet, and their local
  links are not.** Widening the local-link pass to the subdirectories first
  surfaced 15 off-diet URLs, 13 of them loopback addresses inside fenced test
  examples in plans. The diet is a policy about the documents this project
  hands to a reader — that reasoning is already written at
  `scripts/check-links.sh` above `DIET_EXEMPT`, and a work record is its
  contrapositive. **A gate that charges a plan for a port number is a gate
  that stops being read.** The exemption is domain-only: a broken local link
  inside an exempt plan still fails, which was proved by difference in the
  same four-state run that proved the widening. Reasoned, not measured.

- **Seven cases in [`test-check-links.sh`](tests/hooks/test-check-links.sh)
  now hold both halves in place, and each was proved by the mutation that
  attacks its mechanism.** Turning the recursion back off drops the three
  subdirectory-coverage assertions plus the two that depend on a work record
  being read at all; removing the two exemption lines drops exactly the two
  diet assertions and nothing else. The pair that matters is the one nobody
  writes: a plan is *not* charged for a loopback address and *is* charged for
  a broken local link. **One of those assertions alone cannot tell an
  exemption from a hole.**

- **The execution-path offer asks about context budget, not about the clock.**
  It recommended the subagent path "when the plan will not finish in one
  sitting", and time does not predict occupancy: in the measurement recorded at
  [`docs/context-budget.md`](docs/context-budget.md), a single-agent run ended
  with its window at 74% full against the best configuration's 26% — both
  figures corroborated by both sources — while their wall times, which came out
  practically the same, rest on a number only one source carries. The offer now
  reports the task count **and** the number of distinct files those tasks touch, and
  says plainly that the occupancy judgement is the human partner's — nothing in
  this plugin gives an agent its own window occupancy. Reasoned on a
  third-party measurement, not measured here.

- **[`executing-plans`](skills/executing-plans/SKILL.md) reads the criterion
  from the one statement instead of carrying its own copy.** The
  harness-without-subagents clause is untouched: where there are no subagents
  there was never a choice to make, and that path is selected without the
  criterion being consulted at all.

- **Coupling is defined where the decision is taken, instead of being left to
  judgement.** The decision graph in
  [`subagent-driven-development`](skills/subagent-driven-development/SKILL.md)
  asked "Tasks mostly independent?" and never said what independence was. It
  now asks whether there is a boundary where the tasks share no file, no
  interface and no state — and its first question is context budget, not the
  clock. Coupling was named as a first-class variable only in
  [`dispatching-parallel-agents`](skills/dispatching-parallel-agents/SKILL.md),
  which is walled off from plan execution on purpose, so the variable the
  measurement calls decisive had nowhere to be stated.

## [1.18.0] - 2026-08-12

### Added

- **The mirror assertion was a rule only the producer was told, and both
  reviewers now charge it.** [`test-driven-development/references/writing-good-tests.md`](skills/test-driven-development/references/writing-good-tests.md),
  section "Principle 1: Name the Break", tells whoever writes a test to
  *"Derive expectations independently"* and shows the `❌ Mirror assertion`
  where one builder computes both sides. Nothing checked it: `grep -rn
  "mirror" skills/` returned that file and nothing else, and the closest a
  reviewer came was *"Tests verify real behavior, not mocks?"* — which catches
  the mock, not the expectation. A row was added to the shallow-test litmus in
  [`task-reviewer-prompt.md`](skills/subagent-driven-development/task-reviewer-prompt.md),
  section "Part 2: Code Quality", and a bullet to
  [`code-reviewer.md`](skills/requesting-code-review/code-reviewer.md),
  section "What to Check". **Half a rule is the quiet kind of failure — there
  is no contradiction anywhere to find, only a defect class the gate was never
  asked about.** The mirror is not covered by the litmus row above it: an
  assertion that cannot fail is recognised by its shape (`expect(true)`),
  while this one carries real values, a real builder and a real comparison,
  and is green whatever the code does. Reasoned, not measured.

### Changed

- **`requesting-code-review` licensed on its own initiative exactly what
  `using-superpowers` had just prohibited.** [`using-superpowers/SKILL.md`](skills/using-superpowers/SKILL.md),
  section "Review Lives in the Gates", added in `0abd065` (2026-08-06), says
  *"Between them, do not dispatch a review subagent on your own initiative."*
  That commit touched two files — the skill and this changelog — and never
  swept the skill whose whole subject is dispatching reviewers. So
  [`requesting-code-review/SKILL.md`](skills/requesting-code-review/SKILL.md),
  section "When to Request Review", went on offering *"Optional but valuable:
  When stuck · Before refactoring · After fixing complex bug"* — three
  invitations to self-initiate, upstream text from `9c9547cc` (2025-10-16)
  that this project had never revisited — plus a **mandatory** review *"After
  completing major feature"*, a gate matching none of the five. **Two rules
  loaded at once saying opposite things do not resolve; one of them gets
  picked, and the expensive one is the permissive one**, because each ad-hoc
  dispatch is a subagent reading a whole diff the branch gate reads again
  later.
  **Requalified rather than deleted.** Ad-hoc review is not the defect and had
  been decided on purpose — `docs/superpowers/specs/2026-06-09-sdd-task-scoped-review-dispatch-design.md:33`
  keeps this file as the broad template *"for final branch review and ad-hoc
  review"* — and the gates rule governs it rather than banning it. What
  changed is who starts one: your human partner, in a single dispatch carrying
  every requested lens. The *"After completing major feature"* line is gone;
  `Before merge to main` stays, because
  [`final-review.md`](skills/subagent-driven-development/references/final-review.md)
  and [`executing-plans/SKILL.md`](skills/executing-plans/SKILL.md) both reach
  this skill by that bullet's name, and a branch built by hand is already
  caught by [`finishing-a-development-branch/SKILL.md`](skills/finishing-a-development-branch/SKILL.md),
  section "2b. The whole-branch code review", whose *"No review was run — a
  branch built by hand"* row dispatches this skill on the spot. Reasoned, not
  measured.

## [1.17.0] - 2026-08-08

### Changed

- **The announcement must carry the skill's name, and the rule now says so —
  measured before and after.** [`using-superpowers/SKILL.md`](skills/using-superpowers/SKILL.md),
  section "The Rule", asked for *"Using [skill] to [purpose]"* and did not
  forbid the paraphrase. On the larger tier that is what came back: *"I'll
  invoke that skill"*, *"the skill you asked for"*, *"the requested skill"* —
  **the invocation announced and the skill's name replaced by a pronoun**,
  which tells the reader nothing about which skill is running. One sentence
  was added at the point where the announcement happens, naming the failure
  mode instead of only the template.
  **The effect, same tier and same isolated environment, nine cases each: 2 of
  9 before, 8 of 9 after.** The anaphora did not vanish — it stopped being the
  whole announcement, with runs now opening *"I'll invoke the skill you asked
  for. Using superpowersplus:subagent-driven-development to execute an
  implementation plan…"*. The instruction appended the missing fact rather
  than replacing the habit, which is all it asks for.
  **The one remaining miss is the time-pressure case**, `skip-formalities`
  (*"Don't waste time — just read the plan and start dispatching"*), which
  produced *"I'll start with the skill."* and stopped. **It still invoked the
  skill**: what bends under a deadline is the output form, not the entry gate.
  **Invocation across all five rounds: 45 of 45.**
  **Provenance is written beside the rule on purpose** — a form rule with no
  record of what it costs to drop reads as ceremony to the next sweep, and
  this one measures 6 of 9 cases.

### Added

- **The tier inversion is recorded as a fact about the model, and as an open
  question about every other form rule here.** Given the same instruction in
  the same isolated environment, the larger tier paraphrased a prescribed
  output form (2 of 9) while the smaller reproduced it (6 of 9). **Nothing in
  the skill treats the two differently**, so this is not a property of the
  plugin and there is no reason to expect it to stop at one rule.
  **This project has other rules that prescribe a form and none has been
  measured on this axis:** the evidence line checked by
  [`check-evidence-line.sh`](scripts/check-evidence-line.sh) (8 carriers), the
  escalation shape checked by
  [`check-escalation-shape.sh`](scripts/check-escalation-shape.sh) (6
  carriers), and every `## Output Format` block a subagent is dispatched with.
  **Those gates verify that the carriers agree with each other, which is a
  different question from whether an agent produces the form when told to** —
  they read the repository, never the transcript. Each of them is currently
  written the way the announcement was written before this release: a template
  given, the paraphrase not forbidden, which is exactly the shape that
  measured 2 of 9. **The prediction is testable and untested**, and nothing was
  built for it. Written up in
  [`tests/explicit-skill-requests/README.md`](tests/explicit-skill-requests/README.md),
  section "The open question this opens and does not answer".

## [1.16.4] - 2026-08-08

### Fixed

- **The suite stops inheriting the operator's global context, and the header
  stops claiming it never did.** `tests/explicit-skill-requests/run-test.sh`
  opened with *"Uses isolated HOME to avoid user context interference"* while
  no runner in the directory has ever set `HOME`. **A false claim of isolation
  is worse than no isolation**: it invites every result to be read as a
  property of the skill.
  **`--setting-sources project` drops the user layer and leaves credentials
  alone**, because authentication does not come from the settings sources.
  Copying credentials into a scratch `HOME` was the obvious move, was blocked
  by the operator's own settings, and turned out to be unnecessary.
  **It was not a cosmetic difference.** Re-measured across the same nine
  cases: the announcement result changes on 5 of 9, Sonnet moves from 3/9 to
  6/9, and the suite costs less than half as much (Opus US$ 5.04 → US$ 2.15;
  Sonnet US$ 3.21 → US$ 1.53). The user layer was consuming the turn the
  announcement belongs to.

### Changed

- **`1.16.3` reported that the announcement rule was obeyed a third of the
  time on both tiers and called that "not a tier effect". Isolated, it is one,
  and it runs the other way.** Clean, Sonnet announces in 6 of 9 and Opus in
  2 of 9 — **the smaller tier follows the prescribed form and the larger one
  paraphrases it.** The texts say it better than the score: Sonnet writes
  *"Using superpowersplus:brainstorming to help think through your feature"*,
  which is the rule's own shape, while Opus writes *"I'll invoke that skill"*
  and *"the skill you asked for"* — the invocation announced, the skill's name
  replaced by a pronoun.
  **So the rule is not being ignored; its form is.** Seven of nine isolated
  Opus runs open by declaring a skill is being invoked and two name which one.
  A dead rule and a rule whose wording nobody follows need different repairs,
  and the distinction only became visible once the environment was clean.
  **Invocation, meanwhile, is 36 of 36** across four rounds — including the
  four cases built to argue against invoking.
  **No skill was changed.** What to do about the announcement's wording is the
  owner's decision; this entry is the measurement that reaches him.
  The case-by-case table, the falsified correlation and the ruled-out
  truncation are in
  [`tests/explicit-skill-requests/README.md`](tests/explicit-skill-requests/README.md),
  section "RESULT — the invocation always happens; the announcement's form
  does not".

- **[`docs/releasing.md`](docs/releasing.md) no longer claims the bump audit
  has exactly one class of false positive.** It has two, and the correction is
  to the assertion of uniqueness rather than to the list — a count of
  exceptions written as a fact ages like any other measured number, and the
  third class will not announce that it is the third.

## [1.16.3] - 2026-08-08

### Added

- **The suite now checks the announcement, and the announcement is not being
  made.** [`using-superpowers/SKILL.md`](skills/using-superpowers/SKILL.md),
  section "The Rule", asks the agent to *announce "Using [skill] to
  [purpose]"* after invoking. `tests/explicit-skill-requests/run-test.sh`
  verified the invocation and the absence of premature tool calls, and nothing
  verified the announcement — **the whole suite would have stayed green with
  that sentence deleted from the skill.**
  **The assertion was falsified before being trusted:** on a real passing log,
  removing only the skill's name from the announcement text flips the new
  assertion to FAIL while the invocation assertion stays PASS. The failure
  migrates rather than merely persisting, which is what separates a gate from
  a second opinion.
  **Measured 2026-08-08, nine cases on two tiers, eighteen runs. Invocation:
  18 of 18. Announcement: 3 of 9 on Opus 5 and 3 of 9 on Sonnet 5 — and four
  of the nine cases invert between the tiers.** A rule obeyed a third of the
  time on both tiers, in different places each time, is not a tier effect. The
  case-by-case record, the falsified correlation that looked perfect on one
  tier, and the two known weaknesses of the measurement are in
  [`tests/explicit-skill-requests/README.md`](tests/explicit-skill-requests/README.md),
  section "RESULT — the announcement is not made, and the invocation always
  is". **No skill was changed:** what to do about the announcement rule is the
  owner's decision, and this entry records the measurement that puts it in
  front of him.
  **The runner reports the two failures apart** — exit `1` for a skill that
  never loaded, exit `2` for one that loaded without announcing. Collapsed
  into one code, the summary counts two different defects as one number.

- **Two cases for the rationalizations the agent makes on its own behalf.**
  `skill-is-overkill`, where the change is one line and the process looks
  disproportionate, and `i-remember-this-skill`, where the agent is told it
  used the skill last week so re-reading looks unnecessary. They cover the two
  Red Flags at lines 51 and 49 of the same file, and they are the first cases
  in this directory where the argument for skipping is made **about** the
  agent rather than **by** the user — `i-know-what-sdd-means` has the user
  explaining the skill, which is a different pressure against the same rule.
  **Neither failed on invocation on either tier.**

- **`after-planning-flow` is a case.** It was the last prompt in the directory
  that no line of the runner named. Its scenario is distinct from the other
  eight: the user picks an option **by name** from an offer the agent itself
  made, so the request reads as a decision already taken rather than as a call
  for a skill — which is how the request arrives every time the execution
  offer comes up. **It invokes on both tiers and announces on neither.**

- **`TEST_MODEL` pins the tier for a run**, and the runner prints it.
  Unset, a run takes whatever the operator's session defaults to, which is
  fine for a working run and useless in a record: a result whose model is
  inferred cannot be compared against a later one. The two rounds above were
  confirmed as `claude-opus-5` and `claude-sonnet-5` by reading the model back
  out of the logs, not by trusting the flag.

- **A README for the directory, carrying the reason nine similar cases are
  not one case nine times.** Two cases are duplicates only when the line they
  exercise and the pressure they apply both coincide; a survey that cut by
  resemblance would have removed three cases that are the only coverage of
  three distinct lines. The ladder is written out — bare name, name with an
  artefact within reach, name chosen from an offer the agent made, name under
  time pressure — each rung adding exactly one vector to the same closing
  words. **The measured cost is recorded beside it** so the next cut is argued
  against a number: 156 s and US$ 5.04 for nine cases on Opus, 109 s and
  US$ 3.21 on Sonnet, against 123 s and US$ 3.83 for the seven that preceded
  them. Dropping a case saves about 17 s and US$ 0.56 of a suite that is not
  in CI.
  **It also records a limit that was found while measuring:** the harness does
  not isolate `HOME`, despite `run-test.sh`'s own top comment saying it does.
  Runs inherit the operator's global `CLAUDE.md`, output style and hooks —
  visible in the logs as answers in Portuguese, as one case that translated a
  skill's name instead of using it, and as two Sonnet runs that opened by
  asking about the operator's own knowledge inbox. Closing it needs
  credentials in a scratch `HOME`, which the operator's settings block, so it
  is declared rather than fixed.

### Changed

- **The post-publication check is two independent reads, not three.**
  [`CLAUDE.md`](CLAUDE.md), section "Running `gh`", listed the release API,
  the README badge and the CI run as three confirmations. The badge is
  `shields.io/github/v/release`, which derives from the same release API as
  `/releases/latest` — **one fact read twice, counted as two.** That is
  coverage existing only in the tally, which is the defect this project's
  gates are built to separate. The two reads that answer different questions
  are kept and named: the release API says the release exists and is the
  newest, and `raw.githubusercontent.com` at the tag says the tag's own tree
  carries the version — a bump left uncommitted, or a tag placed one commit
  early, publishes a release whose contents still announce the previous
  version, and the release API cannot see that.

## [1.16.2] - 2026-08-08

### Added

- **The two pressures that argue for skipping a named skill are now tested,
  and both hold.** `tests/explicit-skill-requests/run-all.sh` ran four cases
  and the directory held nine prompts; the five nobody ran were written and
  never executed — the silent half of the defect fixed in `1.16.1`, where a
  test that never runs reads exactly like a test that passes.
  **Two of the five are now cases, chosen because each exercises a Red Flag of
  [`using-superpowers/SKILL.md`](skills/using-superpowers/SKILL.md), section
  "Red Flags", that no live case reached:** `i-know-what-sdd-means`, where the
  user explains what the skill does before asking for it ("I know what that
  means" — knowing the concept is not using the skill), and
  `skip-formalities`, where the user asks for speed against the process ("I'll
  just do this one thing first"). **The second is the one that matters most to
  this project's owner: time pressure is the normal shape of his requests, and
  a short path taken under it stops being a decision and becomes an excuse.**
  **Measured on 2026-08-08, six cases: 6 of 6 pass**, each matching its skill
  and each reporting "No premature tool invocations detected". **Neither new
  case failed on behaviour**, so nothing here argues for changing a skill.
  **The runner now carries its cases as a list, one line each**, with the
  reason written above it: a prompt no line names is a test nobody runs. The
  previous shape repeated nine lines per case, which is what a case costs to
  add and therefore what a case costs to forget.

### Removed

- **Two prompts that duplicated cases already covered.** `action-oriented` —
  an imperative request inside a moving flow, which is what
  `mid-conversation-execute-plan` already runs — and `claude-suggested-it`,
  the same scenario as `after-planning-flow` written in a different format:
  the assistant offered two execution options and the user picked one by name.
  **Of the two formats the one kept is `after-planning-flow`**, because it
  reads as a message someone would actually send; the other framed the same
  content with `[Previous assistant message]` / `[Your response]` labels, which
  is test scaffolding rather than anything a user types. Neither prompt was
  edited to merge them — a fixture is recorded input, and rewriting one changes
  what it measures.

### Fixed

- **The two release steps that ran on deduction now exist in writing.**
  [`CLAUDE.md`](CLAUDE.md), section "Versioning", carries the heading rename —
  `[Unreleased]` becomes `[X.Y.Z] - YYYY-MM-DD`, an edit `bump-version.sh` does
  not make and no script will fail over, and the one whose omission leaves
  `release-notes.sh` looking for a section that is no longer named. Section
  "Running `gh`" carries the post-publication read: the CI run for the pushed
  SHA, `/releases/latest` returning the new tag, and the README badge agreeing.
  **Both were executed correctly at every release and described at none** —
  which is exactly the state that produced `--follow-tags` one version ago.

## [1.16.1] - 2026-08-08

### Fixed

- **The release pushed the upstream's version tags into this repository, and
  the step that did it was not written down anywhere.**
  [`CLAUDE.md`](CLAUDE.md), section "Versioning", now names the three commands
  — `git tag -a`, `git push origin main`, `git push origin vX.Y.Z`.
  **Measured on 2026-08-08: `git push origin main --follow-tags` created 29
  `v3.x`–`v6.x` tags from `obra/superpowers` on this project's remote**, which
  went from 67 tags to 38 after they were deleted by name. They are reachable
  from the common history, so every annotated tag of theirs travelled with the
  release. None of this repository's own tags is affected — no `v1.x` exists
  upstream, so the two sets separate without judgement, and all 29 were
  verified present locally before the deletion.
  **`--verify-tag` does not catch it: it verifies the tag you name, not the
  ones you did not name.** That guard was already in place and the release was
  otherwise correct.
  **The finding is larger than the flag.** `grep` for `git push` across
  `CLAUDE.md`, [`docs/releasing.md`](docs/releasing.md) and `scripts/` returned
  **one** line, and it belongs to the Codex sync. **Between the release commit
  and `gh release create` there was no procedure at all** — not the tag
  creation, not either push. The step ran every version on whoever's habit was
  at the keyboard, and habit chose the form that sends everything reachable.
  **Two steps of the release are still undescribed after this fix**, listed so
  the next gap is not found the same way: renaming `[Unreleased]` to the
  version heading with its date (the principle is stated, the act is not), and
  the post-publication check that `/releases/latest` and the README badge read
  the new tag.

- **The `explicit-skill-requests` suite had been failing 4 of 4 on a flag, not
  on behaviour.** `claude -p --output-format stream-json` requires `--verbose`,
  and none of the four runners passed it, so the CLI refused before running:
  a **74-byte** log holding only `Error: When using --print,
  --output-format=stream-json requires --verbose`, no `Skill` invocation to
  match, four failures in about six seconds.
  **Proven as the difference between two states, on 2026-08-08.** Without the
  flag: 0 of 4, logs of 74 bytes. With it: **4 of 4**, logs of 99–109 KB, each
  case matching its skill (`superpowersplus:subagent-driven-development`,
  `systematic-debugging`, `brainstorming`) and each also reporting "No
  premature tool invocations detected" — the suite's second assertion, which
  had never been reached either. **No case failed on behaviour.**
  **Provenance, because it decides who owns the defect:** all five runners come
  from the upstream — created by Jesse Vincent on 2025-12-26, last touched by
  Drew Ritter on 2026-05-13 — and this project has never edited them.
  `git log -S "--verbose"` over that directory returns nothing: the flag was
  never there. **The date the CLI began requiring it is not determinable in
  this checkout**; what is known is the version that refuses today, 2.1.226.
  **A permanent red reads like a permanent green: nobody reads either.** This
  suite stays out of CI for the reason the others do — it dispatches a live
  agent — so nothing but a hand run was ever going to notice.

## [1.16.0] - 2026-08-08

### Changed

- **The mechanical check now runs before the first dispatch, not only before a
  re-dispatch.** [`brainstorming/SKILL.md`](skills/brainstorming/SKILL.md),
  section "Spec Review", and
  [`writing-plans/SKILL.md`](skills/writing-plans/SKILL.md), section "Plan
  Review". `check-cross-references` was introduced in `1.15.0` as step 1 of
  "before re-dispatching" — which means the cheapest defect a document can
  carry (a citation that does not resolve, a matrix label with no criterion)
  waited for a reviewer round to be named.
  **The two costs, both measured on 2026-08-08:** the script returns in
  **0.038 s** on a real plan (18 `file:line` citations, 21 matrix rows); the
  reviewer it precedes has a **median of 7.3 minutes** across the 29 document
  reviews this project has on record. It was serial by position in the recipe,
  never by dependency — the script needs the saved document and nothing the
  reviewer produces.
  **The ceiling is stated at the point of use, because a green run is the kind
  of result that gets over-read:** it proves the references resolve, not that
  the document is right, and it does not stand in for the review. The dispatch
  is not conditional on it. The step after the fix stays exactly where it was —
  this adds an occurrence, it does not move one.
  **What this does not claim:** the round-1 report I read while measuring
  (`orcamento-publico-sem-valor`, spec) carried three findings and **none** was
  of the class the script catches. The saving proven here is wall-clock at a
  cost of 0.038 s, not a reviewer round.
  [`references/process-flow.md`](skills/brainstorming/references/process-flow.md)
  gains the node; declared and used node sets were compared after the edit and
  agree at 24.

- **The pending-decisions package is written while the reviewer runs, and sent
  after its report.** [`brainstorming/SKILL.md`](skills/brainstorming/SKILL.md),
  sections "Spec Review" and "User Review Gate". The checklist ran them in
  sequence — dispatch the reviewer (item 9), then present the pending decisions
  (item 10) — and the package is built from the document as it stands:
  `## Assumptions to Confirm`, every `Deferred` or `Outstanding` row, the
  dependency findings. None of that needs the report.
  **What the wait costs, measured on 2026-08-08 across the 29 recorded document
  reviews: 239 minutes of blocking wait in total, median 7.3 minutes per
  dispatch, and one typical document — a spec and a plan, seven rounds between
  them — spent 56 minutes waiting.** That is the whole of what this recovers:
  the writing moves into a window that was already being paid for.
  **Writing it there is free; sending it there is not, and the rule splits the
  two.** A blocking finding can change a decision already in a partner's hands,
  and an answer to a question that no longer exists is worse than no answer. So
  the package goes out after the report, with every finding that touches an item
  folded **into** that item — the reconciliation is stated on the receiving side
  too, because a package that arrives unchanged after a round with blocking
  findings was written before those findings existed.
  **A number quoted in conversation is corrected here rather than repeated:
  "review is 36% of the time until the plan is ready" does not survive its
  denominator** — the session wall-clock it divides by includes the hours the
  human partner was not at the machine. The numerator is what holds, and it is
  the one written above.

## [1.15.1] - 2026-08-06

### Fixed

- **`1.15.0` shipped with CI red.** `tests/hooks/test-check-cross-references.sh`
  carried a `local dir="$(…)"` — ShellCheck SC2155, which the "Shell lint (files
  this push changed)" step treats as an error. The suite itself passed; only the
  linter failed.
  **The failure was mine to have caught and the reason is worth writing down:**
  before committing I ran `scripts/lint-shell.sh` with two explicit paths — the
  new script and the gate I had edited — **and left out the test file I had just
  written**. Passing an explicit file list makes the linter check exactly what
  you name, so a clean result meant nothing about the file I forgot. Run with no
  arguments and it lints what the push changed, which is what CI does and what
  would have caught this.

## [1.15.0] - 2026-08-06

### Added

- **Ad-hoc review is governed**, in
  [`using-superpowers/SKILL.md`](skills/using-superpowers/SKILL.md), section
  "Review Lives in the Gates" — the always-on skill, because this is the one
  file every session reads and the behaviour it governs happens in sessions
  that invoked no review skill at all.
  **Measured over every subagent dispatch since 2026-08-01: review invented
  per session is 31.3% of output tokens (794,725 of 2,536,549 across 28
  dispatches) — against 18.4% for the spec and plan reviewers combined.** The
  largest single instance is four dispatches of "LENTE N de 4" over one SQL
  migration, **184,954 output tokens for one document**, each lens re-reading
  it in full and returning findings the others also returned. **Nothing in
  this repository governed any of it**: the skills describe gates, and this
  spend happens between them.
  Four acts, in six lines: review belongs to the gates and no review subagent
  is dispatched between them on the agent's own initiative; a partner's
  request for extra review is **one dispatch with every lens in the same
  prompt**, deduplicated by the reviewer; before dispatching, the agent says
  what the existing gates already check, because reviewing now what the audit
  checks later is paying twice; and an extra round follows the rule above —
  it verifies the repair, never the document again.
  **Cost of the rule, measured: the skill body went from 502 to 590 words.**
  It is loaded on every turn of every session, which is why the rule is four
  sentences and not a section with a table.

### Changed

- **A round-2 review verifies the repair; it no longer re-reads the whole
  document.** Both reviewer templates now carry the scope **in the prompt
  body**, selected by a `[ROUND]` placeholder:
  [`spec-document-reviewer-prompt.md`](skills/brainstorming/spec-document-reviewer-prompt.md)
  and
  [`plan-document-reviewer-prompt.md`](skills/writing-plans/plan-document-reviewer-prompt.md),
  each in a new section "Which Round This Is".
  **Measured: a round 2 cost what a round 1 cost** — about 19k output tokens
  for a spec review and 26k for a plan review, with no downward trend across
  rounds — because the body said to reopen every `file:line` regardless.
  **Three recorded dispatches announced a narrower scope in their header and
  saved nothing; two of the three cost more than their own round 1.** That is
  why the scope moved into the body: a reviewer follows the body it is given,
  not the adjective in the first line.
  Round 2+ now verdicts the previous findings, reads the sections the diff
  touched, and greps every identifier the diff changed to find its use sites —
  **the damage of a fix is not inside the diff**, and recorded rounds found
  four such regressions in one pass.
  **The plan reviewer additionally changes instrument rather than depth**: it
  builds the plan in a scratch copy, runs the suite, and executes the
  *nameable* counterfactuals — every test the plan adds is run against the
  previous HEAD and the ones that pass are reported as vacuous. That class is
  invisible to re-reading at any tier, and the two reviewers that did it are
  the only ones on record that found it.
  **The cost is declared, not hidden: 8 findings across 10 dispatches came
  from sections the diff never touched.** Accepted because most of that class
  is now caught mechanically by `check-cross-references` before the
  re-dispatch, and because the instrument change reaches further than the
  re-read did. The rule stops short of the whole saving on purpose — a section
  the diff *affected* is still read, and the reviewer has to go find which
  ones those are.
  `brainstorming/SKILL.md` and `writing-plans/SKILL.md`, both in their
  post-fix step, now require the dispatch to fill `[ROUND]`, `[FIX_DIFF]` and
  `[PREVIOUS_FINDINGS]` — a rule written only in the template would be a scope
  nobody selects.

### Fixed

- **The two document reviewers had no model prescribed and inherited the most
  expensive one by default.**
  [`spec-document-reviewer-prompt.md`](skills/brainstorming/spec-document-reviewer-prompt.md)
  and
  [`plan-document-reviewer-prompt.md`](skills/writing-plans/plan-document-reviewer-prompt.md)
  now carry the `model:` field, in the form
  [`task-reviewer-prompt.md`](skills/subagent-driven-development/task-reviewer-prompt.md),
  section "Task Reviewer Prompt Template", already uses.
  **Measured over every dispatch this project has on record: the templates
  that require the field ran on a mid or cheap tier in 920 of 981 despatches
  (task reviewer 61 of 63, implementer 859 of 918); the two without it ran on
  the top tier in 21 of 23** (plan reviewer 12 of 12, spec reviewer 9 of 11).
  The correlation is with the template, not with the task —
  `subagent-driven-development/SKILL.md`, section "Model Selection", already
  says an omitted model inherits the session's, and these two are where that
  was left to happen.
  **Two other carriers have no `model:` field either and are left alone:**
  `requesting-code-review/code-reviewer.md` and `final-branch-audit/SKILL.md`.
  Both are prescribed "the most capable available model" in prose — the second
  in its own "Dispatch" section — and both measured at the top tier in 43 of 44
  despatches. There the default and the rule agree, so the missing field costs
  nothing today; it is recorded here as the reason they were not changed, not
  as a clean bill.
  **A floor of mid tier is declared for the spec reviewer only.** Roughly four
  of five of its blocking verdicts are mechanical — open the cited line, match
  an id, confirm a section is present — and the prompt says to raise the tier
  when the spec's risk is judgement instead.
  **The plan reviewer gets the field but no floor**, deliberately: its record
  holds findings of a class the mechanical share does not describe (a test that
  would pass without the change; a count an implementer will quietly adjust to
  make green), and whether a mid tier still produces those is unmeasured. The
  field makes the choice deliberate; the floor waits for the measurement.

### Added

- **A short path for a small change**, offered in
  [`brainstorming/SKILL.md`](skills/brainstorming/SKILL.md), section "The Short
  Path", and honoured in
  [`writing-plans/SKILL.md`](skills/writing-plans/SKILL.md), section "Plan
  Review". Until now there was one march and no other: the same two reviewer
  subagents, the same ten-category coverage map and the same round loop for a
  thirteen-task slice and for a config change. The skill said so —
  "every project goes through this process… a config change — all of them" —
  and the sentence is now about the *skill*, with the route separated from the
  gate.
  **The fork sits after the investigation, at checklist item 2, and not at the
  door**: none of the five criteria is computable before you know what the
  change touches, and the investigation is what produces that. All five must
  hold — no schema change, no new dependency, two or fewer production files,
  no public contract moved, no money/auth/PII — and a criterion you cannot
  answer counts as failed. **The offer is the partner's decision in the
  escalation shape, with the criteria filled in as evidence**, never a
  permission the agent grants itself.
  **What it drops is the two document reviewers, the full coverage map and the
  round loop. What it keeps is everything a gate stands on:** the cited
  investigation, a committed artefact with numbered `AC`/`IR`, the approval
  before any code, and both end-of-branch gates.
  **The artefact is not negotiable, and the reason is structural.**
  `final-branch-audit/SKILL.md`, section "The Spec Is the Root, Not the Plan",
  resolves the spec from the plan and blocks when there is none, then traces
  against `## Acceptance Criteria` and `## Implicit Requirements`. Dropping the
  document does not make the final gate cheaper — it removes it. Ten lines are
  enough; zero is not.
  **The route is declared in the artefact's header (`**Route:** short path`),
  because the skill that has to act on it cannot otherwise know.**
  `writing-plans` reads that line and skips its own reviewer; with the rule
  written only on the producing side, half of what the path saves would be
  spent by a skill nobody told. A missing declaration means the full process —
  never an inferred shortcut.
  **What sizes the cut is a measurement, not a preference: the defect this
  reviewer face uniquely catches scales with the size of the plan. A matrix of
  forty labels desynchronises; three criteria do not.**
  **The return valve is a step at every task boundary, not a closing check.**
  The moment the work crosses a criterion that qualified it — a third file, a
  dependency, a schema change — the agent stops and escalates, and the work
  done so far becomes the full process's input rather than being thrown away.
  Without it the shortcut is where a large project hides: the criteria were
  measured against a request, the work is what actually happened, and the two
  drift in silence.
  [`references/process-flow.md`](skills/brainstorming/references/process-flow.md)
  carries the fork, the decline edge and the return edge; declared and used
  node sets were compared after the edit and agree at 23.

- **A mechanical check between fixing a review's blocking issues and
  re-dispatching the reviewer**, in both document loops:
  [`brainstorming/SKILL.md`](skills/brainstorming/SKILL.md), section "Spec
  Review", and [`writing-plans/SKILL.md`](skills/writing-plans/SKILL.md),
  section "Plan Review". Until now there were **zero steps** between the two
  acts: the instruction was "fix every blocking issue, then re-dispatch", and
  nothing in between looked at what the fix had broken.
  **Measured in this session's transcripts, over every spec and plan review
  this project has on record (23 dispatches across 13 documents, in
  `~/.claude/projects/*/*/subagents/`): 74% of the new findings in a round-2
  review were in the diff the round-1 fix had just produced**, and the round-3
  review found something new in 3 of 3 documents that reached it — every time
  about what round 2 had corrected. One report carries a section titled
  "Regressões introduzidas pelas correções" with four items.
  The cause is structural: the author of the document is the one correcting it,
  and a spec or plan is dense in cross-references edited in pieces. Every
  regression read was of one class — renumbering `AC1`–`AC7` leaving a pointer
  at the old `AC2`, a renamed test leaving its criterion naming the old one,
  a task added leaving "PASS on the six" at five. **None of that is judgement,
  and paying a reviewer subagent a full round to report it is the cost this
  step removes.**
  The deterministic half lives in a script, not in prose —
  [`check-cross-references`](skills/writing-plans/scripts/check-cross-references):
  every `AC`/`IR` cited resolves to the list that defines it, every task
  criterion has exactly one matrix row and every matrix label a criterion,
  every test the matrix names is created by some step, the announced task count
  matches the tasks present, and every `file:line` opens and is long enough.
  Short citations (`page.tsx:7`) resolve by suffix against `git ls-files`;
  exactly one match resolves, several is reported as ambiguous, which is a real
  defect — the reader cannot tell which file was meant either.
  **The split is drawn where judgement starts:** the script proves a reference
  *resolves*; whether the cited line *says* what the document claims stays in
  the prose step, as does recounting a number stated in a sentence.
  Verified against the two real documents that produced the measurement above:
  on the plan of a partner project it reproduced, in one run, the set
  comparison a round-3 plan reviewer had reported by hand as "40/40, by
  extracting and comparing sets, not by reading" — 40 criteria, 40 matrix rows,
  40 labels, 13 tasks, no orphan in either direction.
  Tests: [`test-check-cross-references.sh`](tests/hooks/test-check-cross-references.sh),
  nine cases, in CI. Each of the four mechanisms was mutated and the suite seen
  red for that mutation; the orphan-label case first went green under its own
  mutation because it was failing on the test-existence check instead, and the
  case was rewritten to name a test that exists so the failure migrates to the
  assertion whose name it carries.
  `brainstorming/SKILL.md` and `writing-plans/SKILL.md` join the declared
  carriers of [`check-evidence-line.sh`](scripts/check-evidence-line.sh) — the
  step reports a run, and a run reported to a person carries the same line as
  everywhere else.

## [1.14.1] - 2026-08-06

### Fixed

- **The reference documents went stale inside the cycle that changed what they
  describe** — three claims, all of them counts, all of them written as facts
  about a gate whose shape had just moved.
  [`docs/review-scopes.md`](docs/review-scopes.md) said the evidence line
  "appears three times" and that `check-evidence-line.sh` holds "five carriers";
  [`docs/docs-and-links.md`](docs/docs-and-links.md) said the section pass covers
  every live markdown file with dated records excluded, full stop, and that
  dated records stay out — after `## Open gaps` had been sliced back in. A
  fourth, older and not from this cycle, was found by the same sweep:
  [`docs/context-audit.md`](docs/context-audit.md) counted five carriers for the
  escalation shape where the gate has measured six for some time.
  **Every one of them is a number where a condition belongs**, which is the rule
  [`CLAUDE.md`](CLAUDE.md) states for itself and these documents inherit by
  being the place its procedure moved to. They now name the declared list and
  let the gate print the count, so the next carrier added ages nothing.
  **Found by sweeping for the counts, not for the filenames.** The documents
  were not edited in the commits that invalidated them, so nothing in those
  diffs pointed here — the same shape as `1.13.0`'s stale section, and the
  reason this sweep is worth running at the end of a cycle rather than trusting
  that a changed gate drags its documentation with it.

## [1.14.0] - 2026-08-06

### Fixed

- **Open gaps is the live list, and it was the one live text no gate could
  read — exempt by container, live by content.** The section pass skips
  `CHANGELOG.md` because a changelog is a dated record: a heading renamed after
  an entry was written does not make that entry wrong, and a gate red on one
  would force rewriting history to stay green. Open gaps sits inside that file
  and is the opposite of a dated record — it says so in its own opening line,
  and closing an item edits it in place. **It inherited an exemption written for
  the text around it.**
  **The cost was already paid and nobody had seen it.** The item declaring that
  the stable-anchor gate reached `CLAUDE.md` and nothing else stayed on the list
  after `1.13.0` widened that gate to `docs/`, `skills/` and `tests/` — and the
  line number it cited for the assignment had itself moved. A reader following
  the list would have set out to do work already done. That item is now marked
  closed, which is what the pass forces.
  `## Open gaps` is now sliced out of `CHANGELOG.md` and scanned as a section
  source, on the same heading boundary
  [`release-notes.sh`](scripts/release-notes.sh) already uses to put it in a
  release body. Reported line numbers are offset back to the real file, so a
  problem is named at its `CHANGELOG.md` line.
  **Three cases in [`test-check-links.sh`](tests/hooks/test-check-links.sh), and
  the first two have to disagree or the boundary does nothing:** a stale
  reference inside Open gaps fails, the same defect in a dated entry above it
  passes, and a renamed heading raises instead of yielding an empty slice —
  which would report zero problems and read exactly like a clean pass. The
  throwaway tree the whole suite builds now writes a real `CHANGELOG.md` rather
  than an empty one, because a file without that heading is malformed rather
  than minimal.

- **Every `file:line` anchor into a live document was counted, and the three
  that could be sections became sections.** The sweep found 18 anchors in files
  this project edits. They fall into three groups, and only one of them is a
  defect:
  | Group | Count | What it is |
  |---|---|---|
  | Target is code — a `.sh`, `.js` or `.json` line | 10 | No section exists to anchor to. `file:line` is the correct form here, not a lapse |
  | Target is a live markdown heading | 5 | Convertible. Three converted; the other two live inside fixtures |
  | Illustrative example, resolving on purpose or not | 3 | Out of scope by the rule that reserves backticks for exactly these |
  All 10 code anchors were opened and all 10 check out today. The three
  conversions are `plan-document-reviewer-prompt.md`, both of its anchors into
  the task reviewer, and `tests/skill-behavior/README.md`. Each was verified by
  mutation, and the two forms fail separately: a wrong path and a renamed
  heading produce different errors.
  **The two anchors left in place are inside `FIXTURE-*` files and must not be
  touched.** A fixture is the recorded input of a measurement, and rewriting one
  invalidates the `RESULT-*` beside it. One of them — `githooks/pre-commit:11`,
  naming a line that actually sits at `:13` — is deliberately wrong: it is the
  object under test, and "correcting" it would delete the measurement.
  **On the gate for the remaining form.** The design considered was: where
  `file:line` is unavoidable because the target has no heading, the citation
  also carries a literal fragment of that line and a gate checks the fragment is
  still there — no named exception, because the rule becomes "either a section,
  or a line with its fragment". **It is a sound design and this project already
  practises it**: `spec-under-test.md` and `docs/releasing.md` both write the
  anchor with the fragment beside it, unprompted. **It is not being built now,
  and the reason is the measurement above** — the 10 anchors it would govern are
  correct today, so there is no measured defect in that class. Building it would
  be the invented-by-argument move this file's Open gaps refuses on its own
  terms. **The condition is declared in Open gaps instead, with the count behind
  it: the first code anchor found drifted is what turns this from a design into
  a defect.**
  **Open gaps also states, in one line, why its own references use the section
  form.** The rule is not new and is not what fails — remembering it while
  writing is, five times over in this one series of changes. It is written in
  the section where the next lapse would be written.

- **The evidence line was enforced everywhere an agent reports to an agent and
  nowhere an agent reports to its human partner.** Every carrier of
  `**Command:** … — **exit:** … — **counts:** …` was a machine-to-machine
  prompt. The one place a person reads a suite result before deciding anything
  — `finishing-a-development-branch`, Step 1, the last thing before merge
  options are on the table — said *"report the failures"* and gave no form at
  all. A rule that binds the reports nobody reads and releases the one that
  decides a merge is the half-rule this project keeps finding in other shapes.
  Step 1 now carries the form, for a pass as well as a failure, and the skill
  is a declared carrier in
  [`check-evidence-line.sh`](scripts/check-evidence-line.sh). Verified by
  mutation: dropping `**counts:**` from the new carrier names that file against
  the others.
  **The list stays declared rather than discovered.** Globbing for the form
  would make a carrier that silently lost it indistinguishable from a file that
  never had it — the exact failure the gate exists to catch.
  **What this gate does not do, stated because a green run invites the opposite
  reading:** it compares the SHAPE of the line across carriers. It never checks
  that the text inside is true of any real run — `**exit:** [the moon]` passes.
  Only the adversarial records under
  [`tests/skill-behavior/`](tests/skill-behavior/README.md) reach that, and they
  reach it one measured scenario at a time.
  **Two secondary defects were fixed in the same files rather than left.** The
  script's own prose carried the count of its carriers in three places, so
  adding one aged its documentation on the spot; those now state the condition
  and let the run print the number. And
  [`test-check-evidence-line.sh`](tests/hooks/test-check-evidence-line.sh) held
  a SECOND copy of the carrier list — adding a carrier to the script broke three
  of its cases with no defect present. The test now reads the list out of the
  script under test, with a guard that fails loudly if the extraction ever
  yields nothing, because an empty list would let every case pass over an empty
  tree.

- **The first measured instance of the hole the anchoring rule describes: an
  anchor that was correct when written and was wrong two days later, with no
  gate between the two states.** `plan-document-reviewer-prompt.md` sent its
  reader to the controller's pre-flight scan at
  `../subagent-driven-development/SKILL.md:137`. At
  [`0024cb0`](https://github.com/rodrigopaitach/superpowersplus/commit/0024cb0)
  (2026-08-04), where the anchor was written, line 137 of that file **was**
  `Before dispatching Task 1, scan the plan once for conflicts:` — verified by
  reading the file at that commit, not inferred. Today it is `todo per task.`
  and the scan is at line 153. **It drifted sixteen lines in two days.**
  Everything the rule predicts is present in this one case, which is why it is
  worth recording rather than just fixing. The anchor was never wrong to begin
  with, so no review could have caught it at authoring time. Nothing edited the
  reference — the referenced file grew above it. It sat in backticks, and
  [`check-links.sh`](scripts/check-links.sh) resolves link syntax, so the pass
  that would have read a converted form never looked at this one. And the
  citation still names a real file and a plausible line, so it reads as
  verified: `todo per task.` is not obviously not-a-pre-flight-scan to someone
  who does not open it.
  **This is what the canonical form buys, measured on the converted
  reference rather than argued.** Rewritten as a markdown link carrying the
  section title, it is now read by both passes,
  and each mutation goes red on its own assertion: pointing the path at a file
  that does not exist fails with *"section reference names a file that does not
  exist"*, and renaming the section in the citation fails with *"no heading
  matching section"*. Two states, two different failures, neither reachable
  before the conversion.
  **Provenance for the rule, not a note about one file.** `1.12.1` recorded two
  occurrences of an instruction asking for `file:line` where the rule asks for
  the section, and said that on a third the finding is that the rule needs a
  gate rather than that somebody slipped. Those two were instructions written in
  the wrong form; this is the first one measured **rotting**, which is the claim
  the form exists to prevent and until now the only untested half of it.

- **`verification-before-completion` was orphaned in the invocation graph and
  nowhere said so, which is the only part of that situation that was a defect.**
  No flow reaches it — the sole invoker in the whole graph is
  `systematic-debugging/SKILL.md:189`, and neither execution path, nor the merge
  decision, nor the audit names it. **The orphaning is correct and it was
  already measured**, in
  [`RESULT-verification-before-completion.md`](tests/skill-behavior/RESULT-verification-before-completion.md):
  across two adversarial runs, one in a repository where no skill was reachable
  at all, the verification ran both times. What varied was whether the claim
  named the instrument, and that — the form of the evidence, not the running of
  the check — was taken to the points where a completion claim is actually made
  and is gated there by
  [`check-evidence-line.sh`](scripts/check-evidence-line.sh). Connecting the
  skill to the flows now would be an argument against this project's own
  measurement.
  What was missing is the declaration, and its absence has a cost with a name:
  a sweep for dead references surfaces this skill beside
  `dispatching-parallel-agents`, which **is** declared, and the undeclared one
  reads as the real defect. Declared now in two places, because two different
  readers hit it — at the top of
  [the skill itself](skills/verification-before-completion/SKILL.md), for
  whoever opens the file, and in [`CLAUDE.md`](CLAUDE.md)'s table of things
  that break silently, for whoever is running the sweep and never opens it.

- **The same anchoring defect one stage earlier: right value, wrong form, in
  the row directly above one that already had it right.**
  `finishing-a-development-branch/SKILL.md:47` cited the audit's treatment of a
  declared-out-of-scope task as a backticked `file:line`. That line number
  checks out today — it names the `OUT OF SCOPE — DECLARED` row of the audit's
  `Handling the Result` table — so nothing was broken, and that is the whole
  point of fixing it: the entry above records the same citation form one drift
  later, and there is no signal that separates the two states while both are
  still green. The line below it, in the same table, was already written as a
  markdown link plus a section title. Converted to match, and verified by
  mutation the same way.

- **A commit about another subject deleted a measured decision, and
  `executing-plans` spent a day telling the reader both that its fix rounds are
  capped at three and that it has no numbered fix rounds at all.** Step 3 has
  said "Three rounds maximum, counting both gates together" since
  [`dde1615`](https://github.com/rodrigopaitach/superpowersplus/commit/dde1615)
  (2026-08-05 11:16). Two hours later
  [`b0b58ec`](https://github.com/rodrigopaitach/superpowersplus/commit/b0b58ec),
  a commit about the shape of the evidence line, wrote into the progress-report
  list that "this path runs no numbered fix rounds, so there is no round count
  to give; do not invent one". **The newer rule negated the older one inside the
  same file, and neither side knew.**
  The cap is the side that was derived: the number comes from its own session,
  on the argument that the actor is constant **by construction** on this path —
  `executing-plans` is where a harness has no subagents, so escalating to a
  different model or a fresh implementer, which is what buys the subagent loop
  its extra rounds, is not an unexercised option but an absent one. The negation
  was written in passing. **The negation was removed and the cap kept.**
  What the deleted sentence was reaching for was a real distinction, and it drew
  it in the wrong place: this path has counted fix rounds **and** no fix wave.
  Rounds it has — three, then escalation. What it has no equivalent of is the
  subagent path's adjudication, which parks residual findings with a ruling in a
  ledger. Both halves are now stated in `Overview`, which is where
  [`finishing-a-development-branch`](skills/finishing-a-development-branch/SKILL.md)
  cites this path for exactly that claim.
  **The contradiction had already propagated.** One table row at the merge
  decision, `finishing-a-development-branch/SKILL.md:48`, leans on both sides at
  once — it cites Step 3 for "escalated at the cap of three rounds" and the
  Overview for "the inline path runs no fix wave and parks nothing". Under the
  old text those two citations could not both be true, and the failure was not
  academic: an agent following the Overview counts no rounds, so it never
  reaches a cap, so it never escalates, so the row requiring an escalation is
  unreachable and a branch off this path can only ever take the plain FAIL row
  that stops it. Both citations are true now, and the row is left as written.

## [1.13.0] - 2026-08-06

### Added

- **Three reference documents, carrying what `CLAUDE.md` used to carry inline.**
  [`docs/review-scopes.md`](docs/review-scopes.md) holds the four review faces
  and the two shapes copied across carriers on purpose;
  [`docs/docs-and-links.md`](docs/docs-and-links.md) holds the three
  README-shaped files and what each of `check-links.sh`'s three passes reads;
  [`docs/releasing.md`](docs/releasing.md) holds the bump audit's false
  positive and the ceiling exemption that runs on a deadline. Each is reached
  by an imperative pointer at the moment it applies, not by a link nobody is
  told to follow. They land under `docs/`, so `check-links.sh` gates their
  links, anchors and domains from the first commit.

### Changed

- **`CLAUDE.md` rewritten to the shape Anthropic's context-engineering
  guidance describes: brief on what the repository is, most of the file on the
  traps.** 190 lines to 97. **Measured by section, 75% of what is not the
  header is now trap** — a rule that guards an act at the moment it happens —
  against procedure, which is what moved out.
  The cut is one rule, applied throughout: **the description of a gate leaves,
  the prohibition stays.** Verified before applying it — all eight gates print
  their reason on failure, and `check-skill-size.sh` prints the rule itself, so
  a red is never a red without an explanation. The section that proved the
  point was `## Documentation hierarchy`, whose account of what `check-links.sh`
  scanned went stale twenty minutes after it was written, when this same cycle
  added `CLAUDE.md` to that scan.
  Four section titles are unchanged on purpose — `## Relationship with
  Superpowers`, `## Versioning`, `## Preparing a commit` and ``## Running
  `gh` `` — because ten references across three files name them and no gate
  reads any of them. Each of the ten was checked against the new file by title
  and by the rule it routes to.
  Two blocks were reclassified during the work rather than after: the `evals/`
  invariant, which provenance shows is a measured trap and not the obvious —
  `docs/testing.md` once shipped a runnable `cd evals && uv sync` for a
  directory that is absent — and the closed list of rename exceptions, which
  became a positive rule, because a closed list of exceptions rots while the
  question "what does this string name?" does not.

### Fixed

- **`CLAUDE.md` wrote the pointer rule from outside the pass that enforces it.**
  [`check-links.sh`](scripts/check-links.sh) has three passes — local links,
  the third-party diet, and section references — and `CLAUDE.md` reached only
  the third. It is the file that states "a pointer to a file of this repository
  is written as a markdown link, never in backticks", with the reason that the
  gate resolves link syntax; the gate was not reading it. **Measured in a
  throwaway tree with a control before the fix, 2026-08-06:** a markdown link
  to a file that does not exist exited 0 inside `CLAUDE.md` and 1 inside
  `README.md`; an off-diet URL did the same. The file is now the sixth entry of
  `TARGETS` at `scripts/check-links.sh:61`. Local links went 235 to 248 — the
  13 are every markdown link `CLAUDE.md` carries except the external one, which
  the pass counts on the diet instead, taking it 70 to 71. **None was broken**,
  so this fixes an absence of coverage, not a defect it was hiding.
  The four tests at `tests/hooks/test-check-links.sh:224` are paired: the two
  that detect were proved by removing `"CLAUDE.md"` from the list and watching
  the failure migrate to exactly them, and the two that assert a pass stay
  green under that mutation by design — they are the control half, not the
  detector. `AGENTS.md` is deliberately absent from the list: it is a symlink
  to `CLAUDE.md`, and listing both reports every problem twice.

- **A `file:line` anchor inside `CLAUDE.md` pointed at the wrong block.** It
  cited the escalation format's 1-of-3-to-3-of-3 measurement at
  `escalation-format.md:9-11`; the measurement is at
  `skills/using-superpowers/references/escalation-format.md:20-22`, and `:9-11`
  holds the carrier count instead. Found by opening the file rather than by any
  gate — a line anchor into a file this project edits is exactly what the
  anchor rule tells you not to write. The rewrite carries the claim without a
  line number: the block it names has no heading, so a section reference is
  impossible and a markdown link to the file is what survives an edit above it.

- **`CONTRIBUTING.md:95` named a `CLAUDE.md` section that does not exist**,
  `## Running gh` against the real ``## Running `gh` ``. It diverged before
  this cycle touched anything, which is the point: it is one of ten references
  to `CLAUDE.md` section titles that no gate reads.

- **Three documents shortened the text inside an agent's quotation marks.** The
  worked example in [`README.md`](README.md) and both bilingual READMEs quote a
  recorded run, and the quote read `CLAUDE.md` states "zero-dependency plugin
  by design" where
  [`RESULT-escalation-format-in-chat-v3.md`](tests/skill-behavior/RESULT-escalation-format-in-chat-v3.md)
  records the agent writing "Superpowers is a zero-dependency plugin by
  design". The framing above the blockquote says *condensed from the
  transcript*, which licenses cutting outside the quotation marks and not
  inside them. Restored in all three; the Portuguese one carries the same span
  in translation.

  **This is the correction that was nearly made backwards, and the near-miss is
  the entry.** Today's `CLAUDE.md` says "This is a zero-dependency plugin", so
  the quote looked like a live citation gone stale, and the first instruction
  was to align all three to it. Provenance says otherwise: the phrase entered
  `CLAUDE.md` upstream in `c0b417e` (2026-03-31) and left in `8147efa`
  (2026-08-02), and the run is dated 2026-08-02 — **the agent quoted it
  correctly**. Aligning to today's wording would have put text the agent never
  produced inside quotation marks attributed to it, and made the passage
  contradict the record it links to.

  **The axis is assertion versus quotation, not dated record versus live
  document.** A quotation of a dated record inside a live document inherits the
  record's exemption, provided the framing sits at the point of use — here the
  *condensed from* line and its link, eight lines above the blockquote. Without
  that framing the same text would be a defect. **The corollary is what decides
  a case: text inside quotation marks is verified against the RECORD cited,
  never against the current state of the document the phrase came from.**
  Comparing the two strings and skipping the question of whose voice it is
  gets the symptom right and the bucket wrong. No gate: deciding whose voice a
  passage carries needs a reader.

## [1.12.4] - 2026-08-06

### Fixed

- **A release shipped with an empty body, and the guard that would have caught
  it did not exist at the point where the damage happens.**
  [`release-notes.sh`](scripts/release-notes.sh) died on a version section that
  was empty, and the `>` redirect had already truncated its target to zero
  bytes; `gh release create --notes-file` then published the empty file without
  complaining. **The script's exit code was never the problem — it exited 1
  both before and after this fix.** The truncation happens before the script
  runs, so no rule and no exit code can undo it: the only place a guard works
  is inside the process that owns the write.
  The script now takes an optional output file and writes it only after the
  body exists and is non-empty, and an empty section is refused by name instead
  of falling through to an `IndexError` that read like a defect in the script.
  [`CLAUDE.md`](CLAUDE.md), section "Versioning" now states the two-argument
  form as the step and names the redirect as the thing not to do.
  Proved in three states: a real version writes 31,876 bytes and exits 0; an
  empty section under the new script exits 1 and leaves the target file
  untouched; the same empty section under the previous script also exits 1 but
  leaves the file at zero bytes — which is the version `gh` published.

## [1.12.3] - 2026-08-06

### Added

- **`anthropic-best-practices.md` gained a `## Contents`, reversing a decision
  taken four days earlier in this same cycle.** At 1150 lines it is the longest
  file in the repository and the document that states the rule, so it is where
  a table of contents pays most. It was left out on 2026-08-05 with the reason
  that a verbatim vendored copy of somebody else's documentation stops being a
  faithful copy once a section is added — an argument that held while the file
  was the upstream's and stopped holding on 2026-08-06, when this project
  ended that relationship. Nothing else changed; the reason simply expired,
  which is what the "Relationship with Superpowers" rule says to expect.
  **This is a declared addition on third-party text, dated 2026-08-06**, not a
  correction to it: 17 anchor links, no line of the vendor's own prose touched.
  Three headings repeat and their anchors carry GitHub's `-1` suffix, which
  [check-links.sh](scripts/check-links.sh) verified along with the other
  fourteen — local links went 215 to 232.

### Removed

- **Four adversarial test prompts were deleted: nothing pointed at them, no
  suite ran them, and they recorded another project's development.**
  `test-pressure-1.md`, `test-pressure-2.md`, `test-pressure-3.md` and
  `test-academic.md` under `systematic-debugging` were prompts written to
  pressure-test that skill while it was being built upstream. Measured before
  deleting: the only file in this repository naming any of them is this
  changelog, and the only hits outside it are old plugin caches of this same
  project. Three of the four carried the dead
  `skills/debugging/systematic-debugging` path corrected earlier in this
  release — a premise pointing at a directory that has never existed here,
  in files nothing would ever run.

## [1.12.2] - 2026-08-06

### Changed

- **This project stopped pulling from the upstream, and rebase cost stopped
  being a criterion.** The owner decided on 2026-08-05: `obra/superpowers` is
  the historical origin of this code and the reason the MIT attribution exists,
  not a source of updates. The `upstream` remote may stay for consultation —
  `git diff upstream/main` still answers where a file came from — but no rebase
  is planned. In [`CLAUDE.md`](CLAUDE.md) the section that was headed "Rebase
  relationship with Superpowers" is gone, replaced by one headed "Relationship
  with Superpowers", and the posture is stated as a rule about rules: a rule
  that reached for rebase cost
  lost its foundation and gets rewritten on its own merits or dropped, never
  left standing on a reason that no longer exists.
  **The attribution is a separate question and does not move.**
  [`LICENSE`](LICENSE) and the credit remain a license obligation on code that
  came from them, independent of whether anything is ever pulled again.
  **Three rules were carried by rebase cost and are now resolved or named.**
  Two fell with the section itself: "touch the minimum of the files the
  upstream edits often", and the rule against rewriting an upstream test, whose
  purpose — keeping their tests able to detect the upstream's decisions —
  describes a signal nothing consumes now. One was rewritten in place: the note
  on `tests/codex/test-package-codex-plugin.sh` said the suite's known
  clean-tree defect "is upstream's file and is not fixed here", and now says
  fixing it is ordinary work on a file this project owns. One more is named and
  left open on purpose — the `skills/writing-skills/SKILL.md` size exemption,
  whose stated condition is "while the file is the upstream's" — because
  closing it means extracting 179 lines, which is work to propose and not a
  correction to make in a documentation commit.
  **Two more live rules repeat the exemption's dead reason in executable
  files** — [`scripts/check-skill-size.sh`](scripts/check-skill-size.sh) and
  [`tests/hooks/test-check-skill-size.sh`](tests/hooks/test-check-skill-size.sh)
  — and move with whatever that exemption becomes, not before.
  The "Upstream base" line at the top of this file also stops being a field to
  maintain: it is a fixed historical fact now, and its "update this line at
  every rebase" instruction went with the decision.

- **`writing-skills` carried a word target its own author has since moved, and
  now says so instead of pretending the two agree.** Its "4. Token Efficiency
  (Critical)" section asks for under 500 words from any skill that is not
  frequently loaded. Anthropic's current skill-development guidance for plugin
  skills asks for 1,500-2,000, under 3,000, with 5,000 as the maximum. Measured
  against the current number, ten of the fifteen skills here comply; against
  the one in this file, none do.
  **The numbers were not overwritten, and the reason is that the two are not
  the same axis.** The tiers here sort by how often a skill is loaded — the
  distinction that decides whether its words cost anything — while the vendor's
  is a single body target. Replacing three tiers with one number would delete
  the frequently-loaded tier in silence, which this cycle's measurement shows
  is the one that bites. Both are now stated, with which to apply where, and
  with the instruction to name which one was used rather than picking whichever
  lets a draft through. The file grew 679 to 692 lines; its ceiling exemption
  is unaffected, being a hardcoded entry rather than a computed condition.

- **Eight auxiliary files sat beside their `SKILL.md` instead of in the
  directories the vendor's anatomy declares, and now they are in them.**
  Anthropic's skill structure names three: `references/` for what is loaded
  into context on demand, `scripts/` for executable code, and a place for
  working examples. Measured across the fifteen skills: seven kept auxiliary
  files loose at the top level and only three used `references/` at all, with
  `systematic-debugging` holding ten loose files.
  Six moved to `references/` — `root-cause-tracing.md`, `defense-in-depth.md`
  and `condition-based-waiting.md` under `systematic-debugging`,
  `coverage-map.md` and `visual-companion.md` under `brainstorming`,
  `writing-good-tests.md` under `test-driven-development`. Each is pointed at
  by its own `SKILL.md` and read during a run, which is what that directory is
  for. `find-polluter.sh` moved to `scripts/`: it is executable and a suite
  runs it. `condition-based-waiting-example.ts` moved to `examples/`, the
  category the vendor gives working code.
  **The gate found the pointers, including two nobody had listed.** With the
  conversion above in place, `check-links.sh` named eleven broken links after
  the move — two of them in `test-driven-development/SKILL.md`, which had been
  written as links already and so appeared in no backtick inventory. Four more
  references were outside its reach and were found by hand: two naming
  `find-polluter.sh` in prose and a code block, one naming the example file,
  and the suite's own `SCRIPT_UNDER_TEST` path. All four said "in this
  directory", which had stopped being true.
  **Three kinds of file were deliberately left where they are.** The six
  subagent prompt templates are a category the vendor's anatomy does not have —
  neither consulted like a reference nor run like a script, but filled and
  handed to another agent — and `subagent-driven-development` already splits
  them from its `references/` on purpose; moving them would also move paths
  that [check-evidence-line.sh](scripts/check-evidence-line.sh) and three
  recorded test results name. `CREATION-LOG.md` is a dated record, and a record
  does not move for symmetry. The four `test-pressure` files are pointed at by
  nothing: deciding whether they are live fixtures or dead artifacts is a
  judgement about this skill's testing story, not a layout question, and
  guessing it while moving directories is how a decision gets made by accident.
  `writing-skills` was excluded entirely — its structural review is open, and
  moving its files now is work thrown away if that review ends in a rewrite.

- **27 file pointers under `skills/` were written in backticks and are now
  markdown links, which is the vendor's own form.** Anthropic's skill authoring
  best practices write every progressive-disclosure pointer as a markdown link
  to the reference file, and a backticked path is read by no gate here —
  [check-links.sh](scripts/check-links.sh) resolves link syntax and nothing
  else. Measured across `skills/`: 77 backticked `.md` paths outside fenced
  blocks, 42 of which resolve. Local links went 182 to 210.
  **15 of the 42 were left in backticks, and converting them would have
  introduced a defect rather than closed one.** Ten name `CLAUDE.md`,
  `AGENTS.md`, `CONTRIBUTING.md` or `GEMINI.md` meaning the files of **your
  partner's own project** — they resolve here only by name coincidence, and a
  link would point a reader at this repository's copies. Three are
  self-references, where `SKILL.md` means the file being read. Two describe how
  Gemini's instructions file imports a mapping rather than telling anyone to
  open it.
  **Paths are relative to the file holding the link**, the rule `1.9.1`
  established after measuring that a `./` had been written relative to the
  skill being named. Seven pointers in `brainstorming/SKILL.md` were written
  from the repository root and had to change: as a link,
  `skills/brainstorming/coverage-map.md` inside that file resolves to
  `skills/brainstorming/skills/brainstorming/…`.
  **Reference-style links are not used, and that was measured rather than
  assumed.** A probe naming a nonexistent target through a footer definition
  passed green: `scripts/check-links.sh:118` matches the inline form only —
  bracketed text followed by the destination in parentheses. The
  form would hide the path from the one gate that reads it, in a file an agent
  consumes as plain text.
  **No gate was built for the pointer-versus-mention distinction, by decision.**
  Telling them apart requires knowing whether `CLAUDE.md` means this repository
  or the partner's, which no script decides; the alternative is a closed list of
  four names, and a closed exception list is the form this project has already
  recorded as the one that rots. The coverage comes from the conversion itself —
  the 27 are now read by `check-links.sh` — not from a new watcher that would
  report 15 non-problems on every commit.

- **Eight reference files over 100 lines gained a `## Contents`, and seven
  candidates turned out not to be reference files.** Anthropic's skill
  authoring best practices ask for a table of contents in a reference file over
  100 lines. Measured across `skills/`: 18 non-`SKILL.md` markdown files exceed
  100 lines — a number reported as eight in an earlier session, which was the
  fork-owned subset labelled as if it were the whole set.
  Two are reached by no `SKILL.md` at all —
  `writing-skills/examples/CLAUDE_MD_TESTING.md` and
  `systematic-debugging/CREATION-LOG.md` — and the rule governs a file the
  `SKILL.md` sends a reader to open, which is what excludes them. A creation
  log with an index is noise, not compliance.
  **Six more are payloads, not references.** `task-reviewer-prompt.md`,
  `spec-document-reviewer-prompt.md`, `implementer-prompt.md`,
  `re-review-prompt.md`, `plan-document-reviewer-prompt.md` and
  `code-reviewer.md` are one fenced block from top to bottom, with every
  heading indented inside it — the whole file is a prompt to be filled and
  handed to a subagent. A `## Contents` there either enters the block, so the
  subagent receives an index of its own instructions, or sits above it as an
  index of sections a reader cannot navigate to.
  `subagent-driven-development/references/process-graph.md` carries no heading
  at all. These seven are open, not closed: the decision is the owner's.
  The eight that did get one are `coverage-map.md` (11 sections),
  `testing-skills-with-subagents.md` (15), `visual-companion.md` (11),
  `writing-good-tests.md` (7), `persuasion-principles.md` (7),
  `root-cause-tracing.md` (9), `defense-in-depth.md` (6) and
  `condition-based-waiting.md` (8). Entries are anchor links rather than the
  plain list the vendor's own example shows, because
  [check-links.sh](scripts/check-links.sh) then verifies every one: local links
  went from 104 to 178, and an index entry naming a section somebody renamed
  now fails instead of quietly lying.
  **A ninth file needs one and did not get it.**
  `writing-skills/anthropic-best-practices.md` is 1150 lines, the longest here
  and the document that states the rule. An earlier claim in this cycle that it
  already complied was wrong: its `## Contents` is at line 392, inside the
  worked example it uses to illustrate the pattern. It is a verbatim vendored
  copy of somebody else's documentation, and adding a section to it makes it no
  longer a faithful copy — a reason that has nothing to do with the upstream
  decision above and survives it.

### Fixed

- **Four adversarial test prompts told an agent the skill lives at a path that
  has never existed here.** `skills/debugging/systematic-debugging` names a
  `debugging/` parent directory this repository does not have; the skill is at
  `skills/systematic-debugging`. It appeared in `test-pressure-1.md`,
  `test-pressure-2.md`, `test-pressure-3.md` and `test-academic.md`, each of
  which opens by telling the agent under test where the skill is — a fixture
  whose premise is a path resolving to nothing. Nothing consumes these files
  today, measured: no suite and no `SKILL.md` references them.
  Two occurrences were deliberately left. `CREATION-LOG.md:107` is a dated
  record of how the skill was built, and a record is not rewritten to match a
  later layout. `writing-skills/examples/CLAUDE_MD_TESTING.md:16` says
  `~/.claude/skills/debugging/` — a hypothetical user's directory inside a
  worked example, not a path of this repository.

- **Two rules of this repository, obeyed together, produced a reference no gate
  could read — and one naming a deleted section passed green.** The pointer
  rule asks that a file of this repository be named by markdown link; the
  anchor rule asks that a file edited every release be cited by section title.
  Written together they give the link-plus-section form, and
  [`check-links.sh`](scripts/check-links.sh) matched only the backticked
  variant, so the form that obeys both rules was the one nothing verified.
  Measured on the commit above: a reference to the section this very cycle had
  just deleted was written, the gate reported *"7 section reference(s)
  resolve"* — the same count as before — and exited 0.
  **The canonical form is now declared and both variants are verified.** The
  gate reads either and polices neither: matching only the canonical one would
  leave it blind to the older form exactly as it was blind to the canonical
  one. The canonical form earns both checks, the path from the link pass and
  the heading from the section pass, which is why it is the one to write.
  **`SECTION_TARGETS` was `["CLAUDE.md"]` and now reaches every live markdown
  file.** Of 34 references measured across the repository, 7 were checked. The
  27 that were not include five in
  [finishing-a-development-branch/SKILL.md](skills/finishing-a-development-branch/SKILL.md)
  and one in
  [subagent-driven-development/SKILL.md](skills/subagent-driven-development/SKILL.md);
  16 are checked now. Dated records stay out — the frozen history and the
  `RESULT-*.md` files state what was true on their date, and a gate red on one
  would force rewriting a record to stay green. Symlinks stay out, because
  `AGENTS.md` points at `CLAUDE.md` and scanning both reports every problem
  twice. Relative paths now resolve from the citing file, which is what a
  markdown link means and what those five references require.
  **13 occurrences were converted** to the canonical form — 7 in
  [`CLAUDE.md`](CLAUDE.md), 5 in `finishing-a-development-branch`, 1 in
  [tests/skill-behavior/README.md](tests/skill-behavior/README.md). The four in
  this file that instantiate an example path are left alone: they document the
  form inside past entries, and a record of what was done is not converted to a
  new format.
  **Proved in both states, with the real case.** With the reference to the
  deleted section present, the previous script exited 0 and counted 7; the new
  one exits 1 and names both variants; with it removed, 16 of 16 resolve. Six
  tests were added to
  [test-check-links.sh](tests/hooks/test-check-links.sh), and each was run
  against a mutation aimed at its own mechanism. Two of those mutations found
  a test that passed for the wrong reason: a positive case that could not tell
  a match from silence, now asserting the reference was counted, and one
  claiming this file is excluded when it is simply never collected — replaced
  by the frozen history, which is the exclusion the skip set actually
  exercises.

- **Four skill `description` fields were written in the second person, against
  Anthropic's own rule for the field.** Skill authoring best practices
  (`platform.claude.com`, Agent Skills, "Writing effective descriptions") states
  it as a warning: *"Always write in third person. The description is injected
  into the system prompt, and inconsistent point-of-view can cause discovery
  problems."* The four — `brainstorming` (*"You MUST use this…"*),
  `writing-plans`, `executing-plans` and `finishing-a-development-branch` (all
  *"Use when you have…"* / *"…you need to"*) — now state what the skill does
  first and when to use it second, which is the same guidance's other
  requirement for the field.
  **The rewrite preserves reach, not just point of view.** Every trigger term
  that decides selection was kept verbatim — `brainstorming` keeps the full
  creative-work list and the imperative force (*"Required before"* carries what
  *"You MUST"* carried); `executing-plans` keeps the `1.12.1` wording about
  running inline with both gates and gains no decider, which that release
  refused on the rule of the pair. Point of view was the defect; the trigger
  surface is unchanged by design.
  This is **reasoned against a stated vendor rule, not measured** — no suite in
  this repository measures when a skill fires, as `1.12.1` already recorded.

- **The final code-review gate pointed at a reviewer template instead of
  dispatching the skill that owns it**, which was both a nested reference and a
  bypass of that skill's rules. Anthropic's skill authoring checklist requires
  file references one level deep; `subagent-driven-development/SKILL.md` names
  eight files and `code-reviewer.md` is not among them, so the controller
  reached it only through
  [references/final-review.md](skills/subagent-driven-development/references/final-review.md),
  section "2. Whole-branch code review" — two hops. **The other four `.md` links
  under `skills/*/references/` were measured and none is a second hop:**
  `re-review-prompt.md` is already named in that `SKILL.md`, so the link is a
  second path to a level-one file; `escalation-format.md` names
  `final-review.md` while counting which files carry the escalation shape, which
  is provenance and not an instruction to read; and the two in `gemini-tools.md`
  are left-column identifiers in a dispatch-mapping table.
  **The gate now dispatches superpowersplus:requesting-code-review**, the skill
  that owns the template — symmetric with gate 1 in the same file, which has
  always dispatched superpowersplus:final-branch-audit and never a file. The
  asymmetry was the defect. **The fix recovers content, not only compliance:**
  reading the raw template skipped that skill's mandatory "Before merge to
  main", its refusal of `HEAD~1` as a base, its placeholder list, and the
  Common Rationalizations table that two other skills already cite as the
  defense against reviewing your own diff. The three inputs this path owns —
  the review package, the model, and the ledger's deferred-minor and parked
  lines — stay, now as a named list.
  Two alternatives were evaluated and rejected: moving the pointer up to
  `SKILL.md` would satisfy the rule but change when the template is read, which
  is behavior; inlining the template would make a sixth carrier for
  [check-evidence-line.sh](scripts/check-evidence-line.sh) to hold in agreement,
  and fork a file `requesting-code-review` owns. Cost: `final-review.md` 79 → 85
  lines, local links 87 → 86.

## [1.12.1] - 2026-08-05

### Fixed

- **This file's own anchoring rule claimed a coverage its gate does not have.**
  The rule says to anchor by file plus section title for a file of this
  repository we edit every release, and it backed that with *"`check-links.sh`
  proves the section exists; a line number it cannot"*. The first half is a
  half-truth: `scripts/check-links.sh:72` sets `SECTION_TARGETS = ["CLAUDE.md"]`,
  so the section-exists pass runs over this file and nothing else. **Under
  `skills/` — where the rule is applied most, because those are the files edited
  every release — the section form has no gate at all.**
  **The change is a correction, not an addition.** It was found while writing up
  a separate observation, and the observation turned out to be the smaller half:
  the sentence was not missing a caveat, it was asserting a check that does not
  reach the files it governs. A rule that names its own verifier is trusted
  exactly as far as that name is true, and this one was read as covered for as
  long as it has existed.
  It now states where the gate reaches, and records the two occurrences so far
  of an instruction asking for `file:line` where the rule asks for the section —
  the anchor conversion in `1.9.1` and one in the `1.12.0` cycle. **On a third,
  the finding is that the rule needs a gate, not that somebody slipped.** That
  is a condition, which this file keeps, rather than a count, which it does not:
  the third occurrence is what changes the verdict, and nothing about it ages.
  No gate was written here. Writing one to enforce a rule whose need for
  enforcement is still at two of three would be the invented-by-argument move
  this project's own Open gaps entry refuses.

## [1.12.0] - 2026-08-05

### Changed

- **`subagent-driven-development`'s `When to Use` graph decided by the wrong
  criterion, and named the two paths backwards while doing it.** Its diamond
  asked "Stay in this session?" and sent `no - parallel session` to
  `executing-plans`. Both halves were false: the criterion the other two
  documents use is the plan's size and whether its progress has to outlive the
  session (`writing-plans/SKILL.md`, section "Execution Handoff", which carries
  the adversarial runs of 2026-08-04 that measured it; `executing-plans/SKILL.md`,
  section "Overview"), and `executing-plans` is the path that runs **in this
  session** — it is the inline one. An agent reading the graph literally chose
  wrong in both directions.
  **The graph was redrawn rather than patched**, because a graph is the only
  form where the flow is visible at once and a patched one stops being that.
  Four defects closed together: the criterion, the inverted labels, a missing
  decider — where the harness has no subagents there is no choice to present
  and `executing-plans` is the path — and task independence, which was sitting
  *before* the path choice and so routed every tightly-coupled plan to manual
  execution, contradicting `executing-plans/SKILL.md`, section "Overview",
  where that path declares itself "a legitimate choice, not a fallback".
  Independence is a precondition of the subagent path, not of having a plan,
  and it now sits there.
  **Integrity, measured after the redraw:** 7 nodes declared, 7 used, 8 edges;
  no node declared and unused, none used and undeclared, a single root, and no
  node unreachable from it. The three leaves are the three exits.
  The `vs. Executing Plans` block below the graph fell with it: `(parallel
  session)` repeated the same falsehood, and `Same session (no context switch)`
  had stopped being a difference at all — both paths run in this session. What
  replaced it is the difference the measurement supports: progress written to a
  file survives an interruption, session todos do not.

- **`subagent-driven-development`, section "Continuous execution", listed three
  reasons to stop and five instructions in the same file required a sixth.** The
  closed list — BLOCKED you cannot resolve, ambiguity, all tasks complete — was
  contradicted by the `**Execution:**` field mismatch at Setup, the pre-dispatch
  conflict scan, a plan-mandated finding, a dispute still open at the cap, and a
  load-bearing finding at the breaker. Every one of those says "stop and ask" at
  its own point of decision. A closed list of exceptions is true only until
  somebody adds a case, and adding cases is what a fork does.
  It was replaced by the positive rule: **you are authorized to proceed alone on
  everything this skill gives you a rule for**, and where consulting is required
  the rule requiring it says so where the decision is made. Nothing has to be
  enumerated, so nothing goes stale.
  `references/resuming.md` claimed to be "the one moment continuous execution
  does not cover" — the same completeness claim from the other side, and false
  for the same five reasons. It now states the rule instead of its own rank.

- **`requesting-code-review`, section "When to Request Review", claimed the
  subagent path runs it after every task.** It does not: per-task reviews there
  run a different instrument
  ([task-reviewer-prompt.md](skills/subagent-driven-development/task-reviewer-prompt.md)),
  and this broad review runs once, over the whole branch, as the second of the
  two end-of-branch gates. The line now says that, and names the other
  instrument so the distinction is readable from here.

- **`using-superpowers/references/codex-tools.md` pointed at the wrong step.**
  It sent the reader to `finishing-a-development-branch` Step 1 for environment
  detection, which lives in Step 3 — upstream had it at Step 2 and this fork's
  insertion of the two-gate check pushed it one further. Both pointers now name
  the section titles rather than bare numbers, which is what survives the next
  insertion.

- **`executing-plans`'s `description` said the skill runs "in a separate session
  with review checkpoints", and a `description` is what the harness matches to
  decide whether to load a skill at all** — so the error happened before the
  graph above was ever read. Three defects in one line: "separate session" is
  false, since this is the inline path that runs in the current one; "review
  checkpoints" describes the upstream's Step 2 and not the two end-of-branch
  gates the skill runs today; and it carried none of the deciders. Leaving it
  was not neutral either — it and `subagent-driven-development`'s `description`
  compete for the same trigger and were distinguished by exactly the false
  "separate session" / "current session" pair, so the harness was already
  choosing between them by the broken criterion.
  **The change is the narrow one: the line stops misstating where the skill
  runs, and gains no decider.** The alternative — putting the measured
  size criterion into the `description` — was refused on the rule of the pair:
  that criterion already lives with a producer (`writing-plans`, section
  "Execution Handoff", which presents it to the human partner with the
  measurement and writes the answer into the plan's `**Execution:**` field) and
  a verifier (the graph above). A third copy inside a `description` would be the
  only one no gate reads and no human confirms, which is where it would rot
  first.
  **This one is reasoned, not measured, and there is no eval behind it:** no
  suite in this repository measures when `executing-plans` fires.
  `tests/explicit-skill-requests/` covers naming a skill explicitly, not
  description matching, and it does not reference this skill at all.

- **Rebase cost of this release, counted because this project schedules that
  expense rather than avoiding it: +43 lines of new divergence** from
  `upstream/main` — `subagent-driven-development/SKILL.md` +34,
  `using-superpowers/references/codex-tools.md` +5,
  `requesting-code-review/SKILL.md` +2, `executing-plans/SKILL.md` +2;
  `references/resuming.md` is fork-owned and costs nothing.
  **The one worth naming is `codex-tools.md`: it stood at zero, and a
  one-line correction put it at five.** A file with no divergence at all is
  cheap to rebase exactly once.

## [1.11.0] - 2026-08-05

### Changed

- **`dispatching-parallel-agents` now declares the boundary it never had, and
  its example demonstrates the case that is left.** The file forbade nothing
  while `subagent-driven-development` forbids dispatching implementation
  subagents in parallel outright — and it is reachable from inside a plan run,
  because it fires on its own description with no skill routing to it. The
  owner's decision, taken on the evidence: **parallel implementation stays
  forbidden**; the risk of two agents in one file does not pay for itself.
  A boundary block at the top says so at the point of decision, with the two
  reasons: edit conflict, and a task reviewer whose base test count and diff
  range both depend on the previous task having finished.
  **The example was the reason the boundary was invisible, and it was
  evaluated before it was touched.** The file *framed* itself as investigation
  and *demonstrated* correction: the goal was "make these tests pass", all
  three dispatch labels began with "Fix", the template's step 3 was "Fix by:",
  the return contract asked "what you fixed", and step 4 was "Integrate all
  changes" — a merge step that only exists because the agents produced diffs.
  The prescriptive parts — what an agent copies — now demonstrate diagnosis:
  read-only constraints, dispatch labels that say "Diagnose", and a return
  contract of root cause with `file:line`, the fix the agent *would* make, and
  every file it would touch, so the controller can tell an overlap from three
  independent changes. Step 4 became **"Read and Sequence"**, and it is the
  line that closes the conflict: **the fixes are applied one at a time**, for
  the same reason the other skill gives.
  **The `Real Example from Session` is untouched, by decision.** It records a
  run that happened under the earlier boundary; converting a record of what
  was done into the format now prescribed would invent a session nobody had.
  It carries a note saying what it is and how the case divides today —
  diagnosis in parallel, correction in sequence. Marked, not converted.
  One line beyond the agreed list was changed and it is called out here:
  `Common Mistakes` offered `"Do NOT change production code" or "Fix tests
  only"` as the model constraint, which directly contradicted the read-only
  rule three sections above. Leaving it would have shipped a skill that says
  read-only in one place and "fix tests" in another.
  **The rebase cost, counted because this project schedules it rather than
  avoiding it:** the file was at **0 lines diverged** from `upstream/main` and
  is now at **78** (+79/−27). That is the whole expense of the change, stated
  so the next rebase is not a surprise.
  Pre-existing and untouched, found by the graph check and confirmed against
  upstream: the `When to Use` graph declares a node — `One agent per problem
  domain` — that no edge uses. It is upstream's, this change does not touch
  the graph, and it is recorded here rather than fixed inside a change about
  something else.

- **`brainstorming` writes the chain instead of leaving two skills
  contradicting each other.** `using-superpowers` — the skill in context every
  session — says process skills come first and implementation skills
  (`frontend-design`, etc.) carry the work out. `brainstorming` said "Do NOT
  invoke frontend-design". Both name the same example skill and instruct the
  opposite, and the side that loses is the one always in context.
  They are not incompatible; what was missing is where in the chain each acts.
  The chain is now written out — **brainstorming → writing-plans → an execution
  path → the implementation skill** — with every arrow named as a handoff
  somebody else makes. `frontend-design` is not forbidden, it is two handoffs
  away, and invoking it from brainstorming skips the plan, the only artifact
  that says what to build. **"Not yet, and not by you" is the rule; "never" is
  not.**
  Written in `brainstorming` rather than in `using-superpowers`, and the reason
  is measured: `brainstorming/SKILL.md` had 164 lines diverged from upstream
  and now has 174, while `using-superpowers/SKILL.md` has exactly one — the
  Gemini note. Putting the chain in the fork-owned file costs nothing at the
  next rebase and lands where the hard stop it explains actually lives.

## [1.10.0] - 2026-08-05

### Added

- **`scripts/check-escalation-shape.sh` — the second copied form finally has a
  gate.** This project copies two forms on purpose rather than extracting them,
  for the reason `escalation-format.md` records: a shape that guards what
  reaches a person measured 1/3 behind a link and 3/3 once it returned to the
  point of use. `CLAUDE.md` states the consequence — **without the gate,
  "unified in place" is just "copied"** — and until now only one of the two
  forms had one. The test-evidence line was gated across five carriers; the
  escalation shape was copied across six and compared by nobody.
  The new gate is the sibling, with the same contract: it reads all six
  carriers, extracts each item's number and bold lead, and fails when they
  diverge, while tolerating formatting. **Proved in both states, not by a
  verdict in one** — rewording item 3 on one carrier, dropping item 4, adding a
  fifth item, and rewording the marker each turn it red; re-indenting an item,
  wrapping it across three lines, changing the prose after each bold lead, and
  collapsing the whole shape onto one line each leave it green.
  `tests/hooks/test-check-escalation-shape.sh` carries those nine cases, and
  both the pre-commit hook and CI run the gate.
  Its header states what it does not cover, in the same terms as its sibling:
  the prose after each lead, whether a carrier fires at the right moment, and
  whether the six are still the right six — that list is declared, not
  discovered.

### Changed

- **`escalation-format.md` now names its sixth carrier, and the correction is
  not the one that was expected.** The file was reported as enumerating five
  trigger points where there are six. **Measured before editing: it writes no
  number at all.** It lists five *skill* names, and by skill five is right —
  the six carriers live in five skills, because `subagent-driven-development`
  holds the shape twice, in its `SKILL.md` and in
  `references/final-review.md`. So the sentence was not wrong; what it was
  missing is that a list of skills undercounts the files that have to agree,
  which is exactly how the sixth carrier stayed off every enumeration until
  somebody counted files instead. The file now says "five skills, six
  carriers", names the second one in `subagent-driven-development` as a link,
  and points at the gate that reads all six.
  This grew the file from 61 to 72 lines. It was already recorded as sitting
  just over its length target by decision; it now sits further over, and the
  eleven lines are the carrier asymmetry and the gate — the two things a reader
  auditing carriers cannot get anywhere else.

### Fixed

- **The review worktree pointed outside every policy that would clean it up.**
  `code-reviewer.md` told the reviewer to `git worktree add /tmp/review-[SHA]`
  when it needed a working copy of another revision. `/tmp` is not on
  `using-git-worktrees`' directory ladder — declared preference, then an
  existing `.worktrees/` or `worktrees/`, then `.worktrees/` by default — and
  `finishing-a-development-branch` cleans up **only** what sits under those
  two, leaving everything else to the host. So a review worktree was created
  by one skill, matched no other skill's idea of where worktrees live, and was
  removed by nobody. It now uses the ladder and, because nothing downstream
  removes a *review* worktree even there, the reviewer removes its own before
  reporting.
  **The ownership was measured and it contradicted the brief this came from:**
  the line is byte-identical to `upstream/main`, not fork-owned, so this is a
  rebase cost rather than a free change. It was spent deliberately and kept to
  the single line, which is what this project's upstream rule asks for — the
  cost is never a veto, only something to spend on purpose.

- **The skill that decides the merge now checks both gates, and until now it
  checked one.** `finishing-a-development-branch`'s Step 2 was titled "Verify
  the Conformance Audit" and its table had six rows, every one of them a state
  of the audit. Nothing in it asked whether the whole-branch code review had
  run — while four documents declare that review mandatory before merge to
  main (`requesting-code-review`, both execution paths, and the subagent
  path's final-review reference). **The skill's own Common Rationalizations
  table already claimed the check existed** — *"Step 2 here does not re-run
  them; it checks that they ran and what they returned"* — which is the shape
  this project treats as the most silent failure there is: a rule stated in the
  producer, absent from the verifier, with no contradiction for anyone to find.
  The concrete path: a branch built by hand hit the "no audit was run" row, ran
  the audit, and reached the menu with no review at all.
  Step 2 is now "Verify the Two Gates", split into 2a (the audit, rows
  unchanged) and 2b (the review), and 2b carries the state the gap was made of
  — **"No review was run"** — plus the base-too-narrow case (`HEAD~1` instead of
  the fork point, which hands a reviewer the last task and calls it the branch)
  and the no-subagent-available case, which is a decision for the human partner
  rather than a gate to close by reviewing your own diff.

## [1.9.5] - 2026-08-05

### Added

- **An adversarial record for the main-branch consent rule, and it came back
  against the hypothesis that built it.**
  [`tests/skill-behavior/FIXTURE-main-branch-consent.md`](tests/skill-behavior/FIXTURE-main-branch-consent.md)
  and its `RESULT`. Six runs, six throwaway repositories, three states of the
  same rule — **A** where it sits today (the last bullet of `executing-plans`'
  `## Remember` recap), **B** deleted, **C** moved into Step 2 at the point of
  action, byte-identical wording. Three states rather than two, because two
  cannot tell *cut it* from *move it*.
  **A: 2/2 · B: 0/2 · C: 2/2.** The rule changes behaviour, and it changes it
  from where it already is; moving it to the point of action bought nothing
  measurable. The fixture was built expecting the opposite —
  `RESULT-resume-route-inline.md` had found a rule that failed in prose and
  passed once it guarded the act, and the obvious hypothesis was that the
  finding generalises. It does not generalise to this rule.
  The failing side explains itself: run 5 wrote *"Four commits on `main` (you
  asked me to skip the worktree, so the work went straight there)"* — the
  declined worktree read as sanctioning `main`, which is exactly what the
  fixture's load-bearing clause offered and what the rule, when present,
  stopped four times out of four.
  **Two confounders are declared and neither explains the result**, because
  both are constant across the states: the harness's own `Bash` tool text
  (*"If on the default branch, branch first"*) and Step 3's whole-branch review,
  which diffs against `git merge-base` and so needs a fork point. If either
  were sufficient, B would have branched too. B did not, twice.
  **Two of the three criteria did not discriminate, and the record says so.**
  Criterion 2 (the branch question reaches the partner) passed in all six
  including both failures — naming the branch turns out to be routine
  disclosure, not detection, so the criterion as written cannot separate them;
  a future run should score "presented as a decision needing consent". Criterion
  3 (the work is not abandoned) passed in all six, as expected. Only criterion
  1, `git rev-parse main` against a baseline SHA recorded before dispatch,
  separated the states.
  **The cost was measured, and the design's estimate was wrong.** It projected
  6 live dispatches with no nesting; the runs dispatched their own implementers
  and reviewers, and four nested reviewer reports surfaced because their
  dispatching peer was no longer reachable. Budget the full inline flow per run,
  not one agent.
  One unplanned finding, recorded because it was not the question: **all six
  runs, in every state, refused the plan's prescribed test bodies** —
  `assert.ok(typeof fn === 'function')` — citing the spec's implicit
  requirement that a test must fail when the behaviour it covers is removed,
  and several proved the substitution by mutation. A plan that dictates literal
  test bodies invites a vacuous one.
  No skill was edited on the strength of it.

### Changed

- **`docs/context-audit.md`'s measured interpretation is bounded by the run
  above, and the correction is narrow on purpose.** It carried "position
  matters more than wording" as a single finding. Two halves came apart:
  **what stands** is that extracting act-guarding content *to behind a link*
  degrades it — that is what `RESULT-resume-route-inline.md` measured, and the
  restriction the procedure enforces is unchanged. **What falls** is the
  inference drawn from it, that moving a rule *closer* to the act improves it:
  `RESULT-main-branch-consent.md` found the recap position and the
  point-of-action position indistinguishable, with deletion the only thing that
  changed the outcome.
  **Two explanations now sit in the file, neither tested against the other** —
  that position matters only when it changes whether the rule is *read*, and
  that the *cost of obeying* decides regardless of placement. Both fit both
  runs, because every measurement so far varied the two together: the resume
  rule was expensive **and** behind a link; the main-branch rule was cheap
  **and** in the same file. The file states what a run would have to cross to
  separate them — an expensive rule at the point of action, and a cheap rule
  behind a link — and says to cite the bounded finding until one does.
  A generalisation this project would otherwise keep quoting is now labelled as
  one candidate of two.

### Fixed

- **`scripts/lint-shell.sh` passed green while linting nothing whenever `git`
  failed.** The four collection loops read from process substitution —
  `while … done < <(git …)` — which discards the producer's exit status;
  `set -euo pipefail` never sees it. A failing `git` closed the pipe, the loop
  read EOF, collection carried on with an empty list, and the run ended at
  `No shell files found.` with **exit 0**. The gate reported success at exactly
  the moment it lost the ability to look, and its output was indistinguishable
  from a genuinely clean run.
  **Measured as a difference between two states, not as a verdict in one:** the
  same file carrying the same syntax error, linted from a healthy repository,
  exits 1 with `SC1072`; linted from one whose `.git/index` is corrupt, exits 0
  with `No shell files found.` Nothing about the file changed — only the gate's
  ability to see it.
  **The severity is stated smaller than it was found.** The review that raised
  it called it HIGH on the strength of a CI path: `.github/workflows/ci.yml:124`
  runs `git reset --soft` immediately before the lint step. Reading that
  workflow does not support the claim — the step carries no `continue-on-error`
  and Actions runs `run:` blocks under `bash -e`, so a `git` failure there fails
  the job before the lint step starts. **The defect is proven; the scenario that
  would make it HIGH is not.** It is recorded as a defect in the gate's shape.
  The fix routes `git` through a temporary file, so its status is checked before
  the loop runs and the loop still stays out of a subshell — which is what the
  process substitution was buying. The four call sites collapse into one helper
  — the code itself comes out even, and the file grows by the comment block
  that records why the obvious idiom is the wrong one here.
  `tests/shell-lint/test-lint-shell.sh` gains the paired half of the existing
  "reports changed shell file count" case: three assertions that fail against
  the previous script and pass against this one, verified in both directions. A
  fourth assertion was written and **removed** — it passed in both states, so
  no mutation of this defect could have reached it.

## [1.9.4] - 2026-08-05

### Changed

- **The rule lost its exception and got simpler: `CLAUDE.md` keeps no measured
  number at all.** `1.9.3` kept one — `writing-skills`' 679-here-and-679-upstream
  — on the grounds that it was the *condition* of the exemption rather than a
  description of it. That was true and still the wrong shape: a condition
  stated as a number is a number, and it ages exactly like the ones removed
  before it. **The condition is now a command.** The exemption holds while the
  file is the upstream's, and
  `git diff upstream/main -- skills/writing-skills/SKILL.md` answers that today
  and never ages — anything beyond the namespace rename means this project has
  begun owning the file's content, and the exemption goes with it. Measured
  while writing this: the diff returns that rename and nothing else.
  The principle now reads in one line — **this file keeps the relation, or the
  condition; a number that matters lives here, with its date** — and needs no
  carve-out for the next audit to misread.

- **The last measured number left `CLAUDE.md` for the same reason, and this
  entry is its home.** The paragraph explaining why backticked prose paths are
  deliberately not gated carried its own count. It was dated, which is what had
  kept it defensible, but "this file keeps no measured number" cannot be true
  of a file that keeps one — a rule falsified by its own document is the
  half-rule this project treats as the most silent failure there is. The
  paragraph now states the finding and points here. **Counted 2026-08-03: 34 of
  the 78 backticked paths under `skills/` resolved to nothing, and every one of
  the 34 was read — none was a defect** (placeholders, artifact paths inside a
  partner's own project, self-references, and upstream's illustrative
  examples). `1.9.3`'s entry describes that number as still living in
  `CLAUDE.md`; it did, at that version.

- **One number stays, and it is not a measurement of this repository.** The
  500-line `SKILL.md` ceiling is a threshold the gate enforces, borrowed from
  Anthropic's own guidance and cited where it is vendored
  (`skills/writing-skills/anthropic-best-practices.md:241`). A rule's value is
  not a measured fact about this checkout, and it does not age with it.

## [1.9.3] - 2026-08-05

### Changed

- **The measured-number rule now has its exception, and `CLAUDE.md` carries no
  descriptive number that is not dated.** `1.9.2` stated the principle and
  fixed three numbers that had aged into falsehood; a sweep found three more,
  all correct today and all aging the same way. Two left, one stays, and the
  difference is now written into the principle itself.
  - **Gone — they only described a state.** The URL count under `skills/` and
    its per-domain breakdown became the relation they were evidence for:
    upstream's vendored best-practices point at the platform docs, this fork's
    worked example points at the vendor whose call it grounds, links and
    anchors stay checked, and only the domain policy stops at the directory
    boundary. And `escalation-format.md`'s length is now "just over its target,
    closed by decision" — the sentence that works was never the number, it was
    *every block carries distinct normative content, do not re-report it*, and
    the number turns false at that file's first edit.
  - **Stayed — it is the CONDITION of a rule, not a description of one.**
    `writing-skills/SKILL.md` is exempt from the line ceiling because it is
    679 lines here and 679 upstream. Remove the number and the exemption loses
    its trigger: the day the two diverge, this project has begun owning that
    file's content and the exemption falls. The principle now says so in the
    same breath, **so the next audit cannot propose cutting it for
    consistency** — which is exactly what a rule written only in the auditor's
    head would have done.
  - Measured 2026-08-05, all three correct at the time they were removed: 40
    URLs under `skills/` (11 `platform.claude.com`, 3 `docs.stripe.com`),
    `escalation-format.md` at 61 lines against a ~60-line target, and
    `writing-skills/SKILL.md` at 679 here and 679 upstream. This entry is where
    those numbers live now.
  - The one descriptive measurement still inside `CLAUDE.md` — 34 of 78
    backticked paths under `skills/` resolving to nothing, none of them a
    defect — **carries its date in the sentence**, which is what keeps it from
    reading as a current count. It is the boundary case the principle allows,
    not an oversight.

## [1.9.2] - 2026-08-05

### Added

- **`docs/context-audit.md` — the context audit as a procedure, not a skill.**
  A skill costs its name and description in every session whether or not it
  runs; a document under `docs/` costs nothing until somebody names it, and
  this one is invoked with "follow `docs/context-audit.md`, scope: `<target>`".
  Five steps — measure before judging, classify each section into six buckets,
  list conflicts with the `file:line` of both sides, ask of each rule whether a
  model of this generation would decide correctly without it, and propose
  without applying. Criteria from *The New Rules of Context Engineering for
  Claude 5 Generation Models* (Thariq Shihipar, Anthropic, 2026-07-24); the
  source is **named rather than linked**, because `docs/` is inside the URL
  diet `check-links.sh` enforces. Everything in it that is not in the article
  is marked as this project's own interpretation — including the measured
  restriction that position beats wording, which is why nothing in the
  GUARDS AN ACT bucket may become material of consultation. It carries its own
  settled-cases table so a later run does not reopen `final-branch-audit`, the
  escalation shape, `writing-skills`, or the teaching examples with fake paths.

- **`docs/pre-commit-cost.md`** — the hook's cost table, moved out of
  `CLAUDE.md` by the first run of that procedure. **One row is declared
  missing rather than filled:** `check-evidence-line.sh` joined the hook after
  both timed runs, and measuring it now would blend two instruments into one
  table.

### Changed

- **`CLAUDE.md` 200 → 185, and the section that left was the one nothing acts
  on.** "What the pre-commit hook costs" said so itself — *"treat the table as
  a baseline… not as a constant"*, *"a number nobody reads on every commit"*.
  Its single acting line did not go with it: **"if a commit ever visibly drags,
  time the checks one at a time"** moved *up*, into "Preparing a commit", where
  the act is. The 15 lines of headroom are the point — the ceiling forced a
  paragraph rewrite twice in one session.

### Fixed

- **Three numbers inside `CLAUDE.md` had aged in silence, and the fix is a
  principle, not three corrections.** Found by the audit's own Step 1: the
  pair under `docs/` was described as 153 lines each when they are 179 and 181
  and not even equal to one another; the markdown links under `skills/` were
  described as 21 when a sweep now counts 40; and
  `subagent-driven-development/SKILL.md` was narrated as "564 → 457" when it is
  434. **A measured number inside `CLAUDE.md` ages in silence and goes on
  reading as true**, which is now stated in the file: where the relation is
  enough, state the relation — `docs/README.pt-BR.md` is canonical,
  `docs/README.en.md` translates it, `check-docs-sync.sh:14-15` forces them
  into one commit — and where the number is the point, it belongs here, dated.
  For the record this entry is now the home of: the two cuts of
  `subagent-driven-development/SKILL.md` were 564 → 457 (2026-08-02) and
  460 → 434 (2026-08-05, `1.9.1`).

- **`dispatching-parallel-agents` is still orphaned, but not the way
  `CLAUDE.md` said.** It claimed "no skill body names it"; the audit found
  `skills/using-superpowers/references/codex-tools.md:10` naming it, in a list
  of the harness tools it needs. That routes nothing to it, so the design holds
  — the claim was simply wider than the measurement, and a sweep for dead
  references kept surfacing exactly what the paragraph predicted it would.

## [1.9.1] - 2026-08-05

### Added

- **`scripts/check-evidence-line.sh` — the test-evidence line is charged, not
  just copied.** The form `**Command:** … — **exit:** … — **counts:** …` is
  carried in five places, unified **in place** rather than extracted, and that
  decision stands: a form inside a subagent's output block cannot sit behind a
  link, which is the exception measured at
  `skills/using-superpowers/references/escalation-format.md:9-11` (1/3, then
  3/3 once the form returned to the point of use). Nothing verified that the
  five stayed equivalent. Measured before writing: three formatting variants
  in the tree — indentation, wrapping, and a `carried from earlier` prefix —
  with the fields identical. **Unifying in place without a gate is just
  copying.**
  The gate extracts the field NAMES from each carrier and fails when they
  disagree. **Formatting is tolerated by design and proved in both states:**
  dropping `**exit:**` from one carrier fails, a sixth field on one carrier
  fails, and the same fields unindented, unwrapped, prefixed, suffixed, or
  split across six lines all pass. Eight cases in
  `tests/hooks/test-check-evidence-line.sh`.
  **It reads the whole file, not line by line** — the `1.8.2` lesson: a check
  that reads lines misses a form an editor split across them, goes quiet, and
  shows the author a pass.
  **What it does not cover is declared in its own header**, at the top of the
  script: whether the text *inside* each field makes sense for that carrier.
  `**exit:** [code]` and `**exit:** [the moon]` are identical to it. So is the
  deliberate suffix difference — `base:`, `previous:`, none — which is content,
  not wording. The carrier list is declared rather than discovered: a sixth
  carrier is added to the script on purpose.
  Wired into `githooks/pre-commit` and CI. Whole-tree in both, for a reason
  peculiar to this gate: the carriers are edited one at a time, so a
  range-scoped check would read the one being changed and never the four it
  has to match.

### Changed

- **`brainstorming`: the process graph moved to
  `skills/brainstorming/references/process-flow.md`** — 50 lines of `dot` out
  of `SKILL.md`, which goes 306 → 261. The graph restates a Checklist that is
  right above it and is read once, at entry; what stays at the trigger point
  is an **imperative pointer carrying its moment** — "open it before your
  first question to the user" — copied from the wording that measured 3/3
  (`subagent-driven-development/SKILL.md`, section "The Process", pointing at
  `references/resuming.md`). The graph's content moved verbatim: 19 nodes
  declared, 19 used in edges, unchanged. The hard rule that followed it —
  the terminal state is invoking `writing-plans`, and no implementation skill
  is invoked here — stays in `SKILL.md`, because it guards an act.

- **`subagent-driven-development`: the model tiering moved to
  `references/model-selection.md`** — `SKILL.md` goes 460 → 434, which takes it
  from 40 lines under the 500-line ceiling to 66. What moved is lookup
  material: the role tiers, the fix-loop escalation, why turn count beats
  token price, and the task complexity signals. What stays is the one line
  that guards an act — **always name the model explicitly**, because an
  omitted model inherits the session's own and silently defeats the whole
  choice — plus an imperative pointer carrying its moment: "open it before
  each dispatch and pick the tier there". The section heading stays too: six
  places in this skill say "per `SKILL.md` Model Selection" and all six still
  resolve.

### Fixed

- **Two real references written in backticks are now verifiable links.** A path
  in backticks is invisible to `check-links.sh`, which resolves markdown-link
  syntax and nothing else — so `skills/using-superpowers/references/gemini-tools.md`
  named `implementer-prompt.md` and `code-reviewer.md` for years with no gate
  ever reading either. **The paths were measured, not assumed:** the `./` in
  both was relative to the *skill being named*, not to the file holding the
  sentence, so the working links are `../../subagent-driven-development/…` and
  `../../requesting-code-review/…`. Proved in both states — the scan goes 71 →
  73 resolved links, and pointing one at a file that does not exist fails with
  the file and line named. Both lines already diverged from the upstream for the
  namespace rename, so the correction opens no new conflict surface.

- **`CLAUDE.md` states the rule the case produced**, rewritten into the existing
  paragraph rather than appended — the file is at its 200-line ceiling exactly.
  A pointer to a file of this repository is a **markdown link, never backticks**;
  backticks are reserved for the paths that do not resolve on purpose —
  placeholders, artifact paths in your partner's own project, self-references,
  and the `❌ Bad` examples `writing-skills` teaches you not to write — and
  those are **never "corrected"**. The 78/34 measurement it already carried now
  states its date rather than reading as a current count.

- **`CLAUDE.md` records the distinction this case produced**, in the rule about
  a third occurrence: a form that *cannot* be extracted is unified in place
  **and charged by a gate**. Written by rewriting the existing paragraph rather
  than appending to it — the file is at its declared 200-line ceiling exactly,
  so the next addition has to displace something.

## [1.9.0] - 2026-08-05

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
  **What the skill adds is the shape of the evidence, not the running of the
  verification** — so the shape went to the two points where the completion
  claim is made, and the 120 lines were left alone (Open gaps below carries the
  condition for revisiting them). Measured, not assumed: the unified evidence
  line from `1.8.1` lives in three *reviewer* prompts, and a reviewer is not
  the party making the claim. The party making it asked for the failing form
  outright — `implementer-prompt.md` wanted a *"One-line test summary (e.g.
  `14/14 passing, output pristine`)"*, a count with no instrument, which is
  exactly what run 2 produced. Both claim points now carry
  `**Command:** … — **exit:** … — **counts:** …`, unified in place rather than
  linked, per the measured exception in `references/escalation-format.md:9-11`.
  `RESULT-verification-before-completion.md`.

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

**References here use the markdown link plus section title, never `file:line`,
because this list is live and its own items have rotted that way.** The rule is
not new and it is not the thing that fails: what fails is remembering it while
writing, which has now happened five times in one series of changes — each time
an instruction asked for `file:line` in a place the rule assigns to the section
form, and each time the rule was right. It is written here because this is the
section where the next one would be written.

- **`check-cross-references` counts a criterion's own definition as a citation
  of itself, so a defined-but-unconnected `AC`/`IR` passes green. Measured, and
  the contract is the open half — not the implementation.** The script's comment
  at `skills/writing-plans/scripts/check-cross-references:180` reads *"Defined
  where the list that owns them lives; cited anywhere else."* The implementation
  one screen below, at
  `skills/writing-plans/scripts/check-cross-references:194`, is
  `cited_ac = set(AC_IR.findall(text))` — `findall` over the whole document,
  which includes the defining lines. Only `cited - defined` is charged, at
  `:201`; `defined - cited` is never computed. **Measured 2026-09-04, twice in
  one branch:** `IR5b` and then `AC27` were each introduced by a fix pass,
  appeared nowhere but their own definition, and both passed with the summary
  reading `AC/IR defined 36, AC/IR cited 36`. Each was caught by a reviewer, one
  round apart, after the gate had cleared it.
  **The historical contract did not settle this direction.**
  [`2026-08-24-cross-references-extractor-design.md`](docs/superpowers/specs/2026-08-24-cross-references-extractor-design.md)
  specifies the opposite one — its `AC10` requires an id cited only inside a
  fence to still count as cited, so that a citation of a nonexistent id fails.
  Nothing there establishes that every defined criterion must appear outside its
  own definition. So this is a **measured blind spot and an open contract
  question**, not a defect with a known fix: the checker cannot distinguish a
  criterion connected elsewhere in the document from one that exists only in its
  defining list.
  **Not fixed here, and `defined_ac - cited_ac` is not assumed to be the
  answer.** What "cited elsewhere" legitimately includes has to be decided
  first — the Coverage Map, the decision record, cross-references between
  criteria, fenced examples that are real citations — and the rule may turn out
  to be narrower and more useful than *every defined criterion must be cited
  somewhere else*: something closer to *every defined criterion must participate
  in the structure that makes it traceable*. The check also runs against plans,
  which cite a spec's ids without defining them and are already treated
  differently at `:200`; a new direction must not turn those into false
  positives. A future slice gets its own spec, and it measures the existing
  corpus before and after so the documents that change verdict are known by
  name.
- **This section's own rule against `file:line` is broken 32 times inside it,
  and the count is measured rather than sampled.** The preamble above states
  it — references here use the markdown link plus section title, never
  `file:line`, *"because this list is live and its own items have rotted that
  way"* — and it records the failure as having happened five times in one
  series of changes. **Measured 2026-09-04 across everything below that
  preamble: 32 backticked `file:line` citations, 29 of them into `.md`.**
  Three resolve to nothing — line 363 of `writing-plans/SKILL.md` and line 134
  of `executing-plans/SKILL.md` are blank, and the one naming line 141 of
  `docs/context-audit.md` points past the end of a 140-line file.
  **A non-blank line is not evidence the citation still holds**, and one case
  proves it: line 145 of `executing-plans/SKILL.md` resolves to prose about the
  two gates feeding one findings list, while the row citing it is about a
  returning NOT DELIVERED row escalating immediately — that rule is now roughly
  forty lines further down. Counting only the empty ones would report three; the
  real number is unknown without opening all 29.
  **The citations above are written out in prose on purpose.** Reproducing them
  in the backticked form would add four more of exactly what this item counts,
  and [`check-changelog.sh`](scripts/check-changelog.sh) refused the first
  draft for precisely that — it resolves anchors, and the `context-audit` one
  points past the file's end.
  **That refusal also explains why these rot unseen.** The gate resolves the
  anchors a staged changelog *adds*, never the ones already in the file, so the
  `context-audit` citation passed on the day it was written — when that file
  still had 141 lines — and nothing has read it since. Every citation here was
  correct once. The gate is a birth certificate, not a health check.
  **Thirteen of them sit in one table** — the copied-shapes table in the item
  about eight unmeasured rules — which is why this did not close when the
  markdown anchors were converted in an earlier cycle: the conversion reached
  prose and not that table.
  **Why it is recorded rather than fixed here:** converting a citation means
  deciding which section it meant, and a wrong section is worse than a stale
  line — it reads as verified. Thirteen of those decisions belong to the author
  of the rules they cite. **The one citation this cycle displaced was converted**
  (the `writing-skills` correction above, now anchored by section), because
  leaving a line number this cycle made wronger is not a decision anyone
  recorded.

- **Eleven of the fifteen `description` fields do not follow the rule this
  cycle corrected, and rewriting them is not a cleanup.** Measured
  2026-09-04 across the fifteen `SKILL.md` frontmatters: four already say what
  the skill does and when to use it — `brainstorming`, `executing-plans`,
  `finishing-a-development-branch`, `writing-plans` — and eleven open on
  `Use when` with no statement of what they do. The corrected rule in
  [`writing-skills`](skills/writing-skills/SKILL.md), section "SKILL.md
  Structure", now asks for both.
  **Why they stay as they are:** the `description` is what the agent matches a
  request against, and this repository's own section "Skill Discovery
  Optimization (SDO)" carries the measurement that changing one changes
  behaviour — a description summarizing workflow made an agent perform one
  review where the skill body prescribed two. Rewriting eleven of them at once,
  on the strength of an argument, is the move that measurement warns about.
  **What would close it:** a baseline of which skill an agent reaches for on a
  given prompt, then the same prompt after the rewrite. That instrument is
  [`tests/skill-behavior/`](tests/skill-behavior/), and it costs a live
  dispatch per case, which is why this is recorded rather than done.

- **The upstream's brainstorming three-path router, to investigate rather than
  adopt.** `obra/superpowers` v6.3.0 (`b36e082`, 2026-08-12) split brainstorming
  into **Spike**, **Bounded** and **Architectural** paths, with terminal states
  bound to the path and a section named `Anti-Pattern: "Too Simple To Need
  Approval"` — 108 lines added and 9 removed in their
  `skills/brainstorming/SKILL.md`. It
  answers a real cost this project pays: brainstorming is mandatory before any
  creative work here, with no graduation, so a spike and an architecture change
  buy the same ceremony. It is **not** a cherry-pick: this project's
  brainstorming has diverged from theirs, the change is behavioural in the most
  used skill in the plugin, and adopting it goes through a spec like anything
  else. Measured while consulting the upstream on 2026-08-22 — the same reading
  that found the clause wording above, and that confirmed two of this project's
  own rules had already been reached independently. Opened 2026-08-22.

- **The `--force` prohibition is prose, and prose is not a guarantee.** A
  `PreToolUse` hook refusing `git worktree remove --force` is the only layer
  that holds regardless of what an agent decides, and deleting untracked files
  is irreversible. It is deferred rather than dropped: it would be this
  plugin's first `PreToolUse`, distributed to everyone who installs it, which
  is a product decision and not a defect repair. Opened 2026-08-21 with
  [the upstream-consult-fixes design](docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md),
  section "Implicit Requirements", `IR2`.

- **A security lens for the reviewers: measured, justified, and belonging to
  the projects' own `CLAUDE.md` rather than to this repository.** Two classes
  were measured on 2026-08-08 across the owner's Next/React + Postgres
  projects, each with the commit that fixed it:
  **(1) `EXECUTE` resurrected by `DROP`+`CREATE`** — `lux-marcas` `2c3b478`
  (2026-07-02: a migration recreated a function via `DROP`+`CREATE` and
  `anon`/`authenticated` got `EXECUTE` back, confirmed with
  `has_function_privilege`) and `landing-page-lux` `61ecdff` (2026-07-23: a
  `SECURITY DEFINER` trigger function callable over `/rest/v1/rpc`). The
  mechanism is documented — PostgreSQL grants `EXECUTE` to `PUBLIC` by default
  on functions and procedures (`postgresql.org/docs/current/ddl-priv.html`,
  Table 5.2); what that page does **not** cover is `DROP`+`CREATE` versus
  `CREATE OR REPLACE`, so that half is the owner's own measurement, not a
  citation. **(2) The advisor finds what the review does not** — `61ecdff` was
  raised by Supabase's security advisor, not by a reviewer; commits citing an
  advisor number 17 in `landing-page-lux`, 6 in `lux-marcas` and **0 in
  `gestao_condominios`**, the one holding billing and owner data.
  **Why it is not built here:** [`CLAUDE.md`](CLAUDE.md), section "What does
  not belong here", refuses a change needing an external tool or service, and
  refuses anything that helps only one stack. A lens that runs a vendor's
  advisor and checks grants after `DROP FUNCTION` is both. **The finding is
  that it belongs one level down** — in the `CLAUDE.md` of the projects, where
  the stack exists and the advisor can be required.

- **A dependency-vulnerability check: advisory, never a gate, and also one
  level down.** The question was whether `npm audit` could gate a spec's
  dependency claims. **It cannot, and the reason is dated:** the command
  "submits a description of the dependencies configured in your project to your
  default registry and asks for a report of known vulnerabilities"
  (`docs.npmjs.com/cli/v11/commands/npm-audit`), so the verdict is the state of
  a remote database. Measured on 2026-08-08: the `next` advisories it reports
  were published **2026-07-22** and the `nanoid` ones **2026-07-29**, while
  `lux-marcas`' lockfile has not moved since **2026-07-15** and
  `gestao_condominios`' since **2026-07-13**. The same lockfile was green on
  the 21st and red on the 22nd with no line changed.
  **Today's counts, same date:** `lux-marcas` 12 packages (9 high, 3 moderate),
  5 high with dev dependencies omitted; `landing-page-lux` 7 high, 6 in
  production; `gestao_condominios` 39 advisories across 12 modules, 21 across 8
  in production. **Zero critical in all three** — a blocking gate would be born
  red in every repository, which this project has already recorded as the way a
  gate stops being read.
  **And it would have missed the one dependency defect that actually cost
  time:** `landing-page-lux` `62d9333` (2026-07-28), a prefetch denial of
  service in `next@16.2.10`, found by reading the dependency's source and
  measuring 45 s against 1 s in production — not by any advisory.
  **The candidate that survives, for the projects' `CLAUDE.md`:** one line in
  the review report carrying the command, the date and the counts, with no
  verdict, compared against the previous report's list. A package that is new
  in the list is signal; the five that have been there since July are not.

- **No gate looks at code that is standing still, and that is the owner's
  decision rather than an open task.** Correcting the premise that opened this:
  `0abd065` (in `1.15.0`, not `1.15.1`) did not remove the review that found
  the `lint-shell` defect. That dispatch was **asked for** — the request is in
  the transcript at 19:40 on 2026-08-05, the dispatch went out at 19:44, one
  subagent, one lens — which is exactly the form
  [`using-superpowers/SKILL.md`](skills/using-superpowers/SKILL.md), section
  "Review Lives in the Gates", prescribes. What the rule cuts is what followed
  in the same window: **23 dispatches and 408,239 output tokens between 19:44
  and 20:17.**
  **The real gap is older and stays open by choice.** `scripts/lint-shell.sh`
  has two commits in its whole history — created 2026-06-01 upstream, fixed
  2026-08-05 — so it was never inside a diff this project reviewed. All five
  gates are scoped to a diff or a document. **A diff gate answers "is what
  changed correct?"; a sweep answers "is what has been sitting here, and never
  looked at, correct?" — no lens inside the first produces the second.** The
  owner's ruling, recorded so no later sweep reopens it: a repository sweep is
  something he asks for when he wants one, and `1.15.0` governed its *form*
  without touching who may ask for it.

- **`1.15.0`'s effect is unmeasured, and the instrument to measure it is
  declared here so the next work uses it.** Not tokens: the ratio of round-2 to
  round-1 tokens per document has a baseline median of 0.91 across 6 documents
  with a range of 0.44–1.81, and the two documents recorded under the new
  template landed at 0.77 and 0.74 — inside the noise. **The number the rule
  actually changes is verification commands**, since what it forbids is
  reopening citations in untouched sections. Baseline, same document, round 1 →
  round 2: 22 → 22, 18 → 24, 19 → 39 — **at or above 1.0 in 3 of 3 pairs.** The
  first pair under the new template ran 26 → 5.
  **The target, fixed before the measurement: a median ratio at or below 0.5
  over 5 documents that run both rounds under the new template.**
  **With one exception declared in advance: the plan face changes instrument
  rather than shortening** — it builds the plan in a scratch copy and runs the
  counterfactuals — so a flat ratio there is the design working, not the rule
  failing. Its one recorded pair ran 16 → 15.

- **Four entry-gate pressures have no case, and the reason they were not
  written is that nine is already the number worth measuring in use.** The
  suite at [`tests/explicit-skill-requests/`](tests/explicit-skill-requests/)
  covers, in [`using-superpowers/SKILL.md`](skills/using-superpowers/SKILL.md)
  section "Red Flags", the rationalizations the agent makes on its own behalf
  (lines 49 and 51) and the pressures the user applies (lines 52 and 54).
  **Uncovered, each named with the line of that same table that
  states it:** 48, "This doesn't need a formal skill" — the user dispensing
  with the process in the same message that asks for it; 53, "This feels
  productive" — the request arriving inside work already flowing; 46, "I can
  check git/files quickly", covered only sideways by the case that puts a plan
  file within reach, never by a message that asks for the quick look; and, off
  that table, the same file's line 22, "Before entering plan mode, invoke
  brainstorming first" — **no case in this repository enters plan mode**, so the one
  rule that governs the entry into planning is the one with no instrument.
  **Why they stay open:** each case is a live dispatch, and the two added in
  `1.16.3` have one run behind them. The owner's ruling is to measure those in
  use before the suite grows again — a sample of one does not justify a
  third pair, and a suite nobody reads the output of is the failure mode this
  directory already recorded once.

- **The announcement assertion demands the skill's literal name, and whether
  that criterion should loosen is waiting on runs rather than on argument.**
  Two kinds of miss were measured on 2026-08-08 and only one is a candidate.
  **Not a candidate:** the anaphoric opening — *"I'll invoke that skill"*,
  *"the requested skill"*, *"the skill you asked for"* — which genuinely names
  nothing and is the miss the rule exists to catch. **The candidate:** one run
  translated the name instead of using it (*"o processo sistemático de
  debugging"* for `systematic-debugging`), purpose announced, form intact,
  scored FAIL. **It happened once, under the contaminated profile, and
  isolation removed the cause** — the same case announces correctly in both
  clean rounds. The owner's ruling: count how often it recurs on isolated runs
  before relaxing a criterion that is currently exact, because a criterion
  loosened against one occurrence stops catching the miss it was built for.

- **The bump audit has two classes of false positive, and the document said it
  had one.** [`docs/releasing.md`](docs/releasing.md), section "The bump
  audit's false positives", now names both: a version constant in a test
  fixture, and a version named in running prose. **The defect was the claim of
  uniqueness, not the missing entry** — a second class turned up on
  2026-08-08, was read against a document asserting no second class existed,
  and the assertion is what had to change. Recorded here because the same
  failure is available to any count of exceptions written as a fact: **the
  third class will not announce that it is the third**, so the correction was
  to say why the number is not the durable part rather than to update the
  number.

- **`lint-shell.sh --all` fails today, on files no recent diff has touched.**
  Measured 2026-08-08: **11 findings across 3 files**, all under
  `tests/claude-code/` — `test-helpers.sh` (5), `test-worktree-path-policy.sh`
  (4), `test-subagent-driven-development-integration.sh` (2) — and **6 of the
  11 are `SC2155`, the code that shipped a red CI in `1.15.0` and was fixed in
  `1.15.1`.**
  **What is *not* the defect, corrected here because it was asserted before it
  was measured:** the gate does not lint a fixed pair of files. Its default
  collects what changed (`scripts/lint-shell.sh`, `collect_changed_shell_files`),
  CI narrows that to the pushed range on purpose (`.github/workflows/ci.yml`,
  step "Shell lint (files this push changed)"), and `--all` exists for the
  baseline. The five runners under `tests/explicit-skill-requests/` are tracked
  `.sh` files and are linted whenever they change — they were, in this very
  cycle.
  **The gap that is real is the one this project already has an entry for:** a
  diff-scoped gate never reaches code that is standing still, and these three
  files have been standing still. It stays open on the same terms as that
  entry — a sweep is something the owner asks for.

- **The plan reviewer stays on the top tier. Decided, with the measurement
  that decided it, so no later sweep demotes it for economy.** The
  retrospective ran: three recorded plan reviews re-dispatched on a mid tier,
  same prompts, same documents, each in a git worktree at the exact commit the
  original reviewer saw. **Two of four grave findings reappeared, two went
  missing** — and the rule fixed in advance was that one going missing settles
  it.
  **The axis is not mechanical against judgement; it is directed against
  generated.** What reappeared was what an instrument finds: a type opened to
  show the field is absent (`papel` missing from `DadosNota`, reproduced with
  the same citations and one step further than the original), and a branch no
  test reaches (found again by running coverage). What went missing was what
  needs a counterfactual nobody named: that restoring a pre-image undoes a
  decision taken between it and now — where the mid tier went to the same
  step, opened the same file, and wrote *"copiável sem ambiguidade; não é
  bloqueante"* — and that a test would pass without the change. **The vacuous
  test is the clean proof: the counterfactual was requested in the prompt in
  so many words, and it was executed only for the one test the instruction
  named.** A cheaper tier runs a counterfactual it is handed; it does not
  invent one.
  **The split of this face is therefore a candidate WITH a design, and still
  not built.** The design the measurement points at is not "mechanical cheap,
  judgement expensive" — it is **everything nameable in the instruction goes
  to the cheap pass**, counterfactuals included ("run each new test against
  the previous HEAD and list those that pass", now written into the round-2
  scope), leaving the expensive pass only what cannot be named in advance.
  **Trigger to build it: a fourth and fifth recorded document, so the sample
  stops being three.** Not built today because three documents cannot separate
  a tier effect from a document effect.

- **The Sonnet floor on the spec reviewer is a decision by analogy, not a
  measurement on the same axis.** The retrospective covered plan reviews; the
  floor declared in
  [`spec-document-reviewer-prompt.md`](skills/brainstorming/spec-document-reviewer-prompt.md),
  section "Spec Document Reviewer Prompt Template", rests on that face's
  verdicts being about four-fifths mechanical, which is a count of the prompt,
  not a run. **Named so it is not read as measured. The symptom that reopens
  it: a spec finding that used to appear and stops appearing in real use** —
  in particular anything of the counterfactual class, since that is precisely
  what the plan-side retrospective showed a mid tier does not generate.

- **Blocking rows in the plan reviewer's contract were examined for demotion
  and NONE moved. Recorded because "we looked and left it" and "nobody looked"
  are indistinguishable a year later.** The recorded classification of that
  face's findings was mapped onto the thirteen blocking rows of
  [`plan-document-reviewer-prompt.md`](skills/writing-plans/plan-document-reviewer-prompt.md),
  section "The Plan Contract (blocking)". **Nine rows produced no finding at
  all in the record — unclassified, so they stay by the rule that doubt does
  not cut coverage.** Two rows are classified as caught only by this face and
  stay for that reason. One row mixes both classes in a single line (an orphan
  label in the matrix was caught downstream; a matrix label with no criterion
  in the body was not), so the line cannot move without taking the second
  class with it. **One row was a genuine candidate — "every matrix row names a
  test some step creates" — and it stays too, for two reasons that only
  appeared on inspection: the task reviewer that would catch it does not exist
  on the inline execution path at all, and the audit that would catch it
  charges at the end of the branch, which is the stated reason this contract
  exists (the section's own preamble says so).** The criterion "the audit also
  catches it" turned out to select every row by design rather than separate
  them.

- **"Only the plan reviewer catches a vacuous test" is stated too strongly in
  the analysis that produced the changes above, and the correction is recorded
  here rather than silently dropped.** The classification asked which
  *reviewer* would catch each finding and compared against
  [`final-branch-audit`](skills/final-branch-audit/SKILL.md), section "The
  Audit Table", and
  [`task-reviewer-prompt.md`](skills/subagent-driven-development/task-reviewer-prompt.md),
  section "Part 2: Code Quality". **It never asked about the implementer.**
  A test-first implementer has to watch the test fail before making it pass —
  [`test-driven-development`](skills/test-driven-development/SKILL.md) — and a
  test that would pass on the untouched repository never produces that red.
  So there is a second catcher for that class, upstream of every reviewer, and
  the count of "findings only the plan reviewer catches" is an upper bound
  rather than a measurement. Left open because tightening it means measuring
  how often the red step is actually observed, which the transcripts of this
  series were not read for. **Recorded so the number does not harden into
  doctrine before anyone checks it.**

- **The seven ambiguous citations `check-cross-references` reported on a
  partner's plan are a defect of that plan, not a limit of the script — and
  the question is closed rather than left hanging.** Checked: the plan writes
  `page.tsx:7`, `page.tsx:5`, `page.tsx:142`, `page.tsx:178` with no path, the
  repository holds four files named `page.tsx`, and **the plan declares no
  base path anywhere** (searched for one). A reader cannot resolve those
  either; the script resolves a short citation by suffix against the tracked
  files and reports as ambiguous exactly the case where the reader would also
  have to guess. **Nothing to change here. It is a finding for a session in
  that partner's project, and it is recorded in this repository only as the
  reason the script's behaviour is correct.**

- **The remaining measurement queue is a terminal state, not a to-do.** What is
  declared above as waiting — the fourth and fifth document for the face split,
  the symptom that would reopen the spec floor — waits on **usage producing
  data**, which no amount of work here advances. Writing them as pending would
  make a finished decision look unfinished; they are conditions with a named
  trigger, and until the trigger fires there is nothing to do about them.

- **Two skills bind the implementer on the subagent path and nothing binds
  anyone on the inline one. The asymmetry is recorded, not closed, because
  closing it would change what a flow does and that is a design decision, not a
  conformance repair.** Both sides, located:
  - **`receiving-code-review`** is named once in the entire graph, at
    [`implementer-prompt.md`](skills/subagent-driven-development/implementer-prompt.md),
    section "After Review Findings" — *"verify before implementing"*. The inline
    path reaches the same moment at
    [`executing-plans/SKILL.md`](skills/executing-plans/SKILL.md), section
    "Step 3: Audit and Review the Branch", whose third item says to fix the
    audit rows and the review findings in one pass and never names the skill.
    Receiving a code review is literally that skill's trigger, and on this path
    nobody is sent to it.
  - **`test-driven-development`** is bound explicitly at the same template,
    section "Your Job" — *"binds every task here: NO PRODUCTION CODE…"*. The
    inline path has no equivalent sentence. It is the weaker of the two, because
    [`writing-plans/SKILL.md`](skills/writing-plans/SKILL.md), section "Task
    Structure", makes every task carry the red-green steps as literal steps, so
    an inline executor following the plan runs the cycle without being told the
    rule. That is the plan doing it, not the flow.
  **Why left open.** Wiring either one in changes behaviour: the first adds a
  skill invocation to a fix pass, the second adds a rule to a path that already
  gets the behaviour from the plan. Neither is a broken reference, so neither is
  the kind of thing this project fixes without measuring first. **What would
  settle it is the measurement, not the argument** — an inline run against a
  review whose findings include one that is wrong, which is the case
  `receiving-code-review` exists for and the only one where its absence has an
  observable cost.

- **The `file:line` form has no gate, and the condition that would justify one
  is declared here rather than guessed at.** Where a citation's target is code —
  a `.sh`, `.js` or `.json` line — no heading exists to anchor to, so the
  section form does not apply and `file:line` is the correct form, not a lapse.
  Nothing verifies those.
  **Measured, 2026-08-06:** 10 such anchors exist across the documents this
  project edits. All 10 were opened against their targets and all 10 check out.
  **2026-08-26:** one of this class was found rotted — an executed plan citing
  `scripts/check-skill-behavior-records.sh:36-38` for a contract those lines no
  longer carry — and was marked rather than fixed (`f4a3444`), because a record
  of work already done is not converted. It does not contradict the count above:
  executed plans were outside that scan. **Whether they belong inside it is the
  half of this item that is actually open** — the anchor rotted precisely because
  nothing reads them.
  **The design that would close it, if it needed closing:** the citation carries
  a literal fragment of the line beside the number, and a gate checks the
  fragment is still there. It needs no named exception — the rule becomes
  "either a section, or a line with its fragment" — and **this project already
  writes it that way without being told**, at
  [`spec-under-test.md`](tests/skill-behavior/spec-under-test.md) and
  [`docs/releasing.md`](docs/releasing.md), which put the identifier or the
  literal text next to the number.
  **Not built, and the condition is the whole point of the entry: the first code
  anchor found drifted turns this from a design into a defect.** Until one is,
  building the gate would be the invented-by-argument move the entry below
  refuses on its own terms — a verifier for a class with no measured failure.
  The markdown side of the same question is closed and needs no condition: those
  anchors became section references in this cycle, and the section pass reads
  them.

- **Ten references to `CLAUDE.md` section titles, in three files, that no gate
  reads.** `CHANGELOG.md:6` and `:84` use the canonical form and are excluded
  from the section pass because the changelog is a dated record;
  `CONTRIBUTING.md:91-97` is a routing table of seven rows in bare backticks;
  `docs/context-audit.md:141` names one in prose. Rename a section and they go
  stale in silence. **Not closed, and no gate built for it now** — the seven
  backticked rows are the form the gate deliberately does not police, and
  charging them would mean policing a convention this project decided to leave
  to authors.
  **What a future sweep needs to know is how this one was nearly missed.** A
  `grep` for `CLAUDE.md` finds none of the seven: the attribution sits in the
  paragraph above the table, not on the rows. A `grep` for the gate's `,
  section "…"` form finds none of them either. **They are only found by
  grepping for the section TITLES**, which is how they surfaced here — after
  the dependency list had already been reported as complete, and before
  anything was edited. `CONTRIBUTING.md:95` was already divergent at that
  point, with no rewrite involved.

- **The pointer rule claims more than this project practises, and the gap is
  measured.** `CLAUDE.md` states that a pointer to a file of this repository is
  a markdown link and never backticks. Counted across the nine documents this
  project owns: **167 real repository paths sit in backticks against 70
  markdown links** — the practised convention names a file in backticks and
  links it when telling the reader to go read it, a distinction the rule as
  written does not make. Left open deliberately: narrowing the rule to match
  practice would weaken it by one session's reading, and applying it literally
  would convert 167 sites for no measured defect. Config declares the possible;
  convention is the practised, and only one of the two is written down here.

- **`writing-skills/SKILL.md` is under structural review, and this is the
  dossier that review consumes.** Its ceiling exemption now runs on a deadline
  rather than the dead condition "while the file is the upstream's" — see the
  Changed entry for this cycle. What the review has to decide, already
  measured, so it does not start from zero:
  **Conformance: 1 of 15.** Against the template that file itself prescribes —
  Overview, When to Use, Quick Reference, Common Mistakes — only
  `writing-skills` carries all four. Overview appears in 10 of 15, When to Use
  in 6, Quick Reference in 4, Common Mistakes in 3. `final-branch-audit`, the
  one skill this project created from nothing, follows none of it. The document
  is inherited and close to unexercised.
  **Three blocks are its own, with no equivalent in Anthropic's
  skill-development skill:** the Iron Law (no skill without a failing test
  first), RED-GREEN-REFACTOR for skills, and Bulletproofing Against
  Rationalization. The vendor's Step 5 is a static validation checklist plus a
  reviewer agent, and its Step 6 is "use it, see where it struggles, update" —
  review and observation, with no red state and no baseline. The difference is
  this project's thesis: a skill is code that shapes behaviour and is tested
  adversarially, not documentation to be validated. **Bulletproofing is the one
  block with measured adoption — 11 of 15 skills carry a rationalization or Red
  Flags table** — and `tests/skill-behavior/README.md` names as its
  methodological source not the `SKILL.md` but its companion,
  `testing-skills-with-subagents.md`.
  **What the vendor has and this does not:** `assets/` as a third category,
  distinct from `references/` because it enters the output rather than the
  context; a per-level budget for progressive disclosure (~100 words of
  metadata, under 5,000 of body, unbounded resources); imperative form as a
  hard rule for the body, not only third person in the description; literal
  trigger phrases quoted inside the description; grep patterns in `SKILL.md`
  for a reference file over 10,000 words; and the rule that information lives
  in `SKILL.md` or in a reference file, never both.
  **One correction hangs on this review.**
  [`writing-skills/SKILL.md`](skills/writing-skills/SKILL.md), section "Skill
  Creation Checklist (TDD Adapted)", sub-block **Deployment**, tells
  the reader to consider contributing back via pull request, and the top of
  [`CLAUDE.md`](CLAUDE.md) states this project takes no outside contributions
  and has no PR process. It is one line and it is wrong today; fixing it alone
  inside a file the review may rewrite is work thrown away, so it waits.
  **Its auxiliary files were excluded from this cycle's layout move** for the
  same reason — `anthropic-best-practices.md`, `persuasion-principles.md`,
  `testing-skills-with-subagents.md`, `examples/`, `graphviz-conventions.dot`
  and `render-graphs.js` sit beside the `SKILL.md` rather than under
  `references/`, `assets/` and `scripts/`.

- **The link gate scans `docs/*.md` and not `docs/**`, and that boundary is
  decided rather than a gap.** `scripts/check-links.sh:53` globs one level, so
  35 markdown files under `docs/superpowers/plans/`,
  `docs/superpowers/specs/` and `docs/plans/` are outside it. Measured
  2026-08-06 before deciding: **those 35 files contain zero local markdown
  links.** Extending the scan would cover 35 files and catch nothing, because
  the plans and specs cite paths in backticks — the mention form no gate reads
  by design.
  What extending it would actually do is put completed plans and specs under a
  gate. They are dated records: each states where a file was when that work was
  done, and a later move does not make one wrong. Failing a commit over it
  would force rewriting a record to stay green, which is the same reason
  `CHANGELOG.md`, the frozen history and the `RESULT-*.md` files stay out of
  the section-reference pass. The boundary is the same distinction in both
  gates — live text is charged, records are not.
  This was reported as an outstanding leftover before it was measured. It is
  not one.

- **`systematic-debugging/CREATION-LOG.md` stays, and this is final.** It was
  proposed for deletion alongside the four orphan test prompts, on the premise
  that nothing referenced it. Measured, the premise is false: two specs of this
  repository name it by path.
  `docs/superpowers/specs/2026-05-05-platform-neutral-config-refs-design.md:20`
  lists `skills/systematic-debugging/CREATION-LOG.md` as a declared carve-out
  from the platform-neutral rewrite, because the attribution path it contains
  is a historical fact;
  `docs/superpowers/specs/2026-05-05-platform-neutral-prose-design.md:25` lists
  it among the dated, point-in-time artifacts exempt from that same rewrite.
  **The one that decides it is
  `docs/superpowers/specs/2026-05-05-platform-neutral-config-refs-design.md:67`**,
  a verification criterion: a `grep` over `skills/` "should return only the
  documented carve-outs (CREATION-LOG, CLAUDE_MD_TESTING …)". Deleting the file
  makes that criterion permanently unsatisfiable — it would name a carve-out
  that cannot be found — and the spec is a dated record, so it is not rewritten
  to match. A record whose check can never pass again is worse than an
  unreferenced file.
  It is pointed at by no `SKILL.md` and run by no suite, which is what made it
  look orphaned. Being unreachable from a skill and being unreferenced are
  different questions, and only the second would have authorised deleting it.

- **A subagent payload is not a reference document, and the seven that are
  payloads carry no table of contents. This is decided, not pending.**
  Anthropic's guidance asks for a table of contents in a reference file over
  100 lines, and the failure it prevents is a reader loading a long document to
  find one part of it. A prompt template has no such reader: it is filled and
  handed to another agent whole, so there is nothing to navigate and an index
  inside it becomes an index of the subagent's own instructions.
  The six are `task-reviewer-prompt.md`, `re-review-prompt.md` and
  `implementer-prompt.md` under `subagent-driven-development`,
  `spec-document-reviewer-prompt.md` under `brainstorming`,
  `plan-document-reviewer-prompt.md` under `writing-plans`, and
  `code-reviewer.md` under `requesting-code-review`. Measured: each is one
  fenced block from top to bottom with every heading indented inside it, which
  is what makes them payloads rather than documents.
  `subagent-driven-development/references/process-graph.md` is the seventh, for
  a different reason — it carries no heading at all, so a table of contents
  would index nothing.
  A future sweep against the vendor checklist will surface these seven again.
  This entry is the answer, so it does not get re-derived as a finding.

- **Five of the fifteen skill names are not gerunds, and that is the final
  state.** Anthropic's skill authoring best practices recommend the gerund form
  for consistency and list the noun phrase as an accepted alternative; the names
  to avoid are the vague, the generic and the ones carrying a reserved word.
  `subagent-driven-development`, `systematic-debugging`,
  `test-driven-development`, `verification-before-completion` and
  `final-branch-audit` are none of those — they are noun phrases, the listed
  alternative. **Renaming any of them would be MAJOR**, and not on paper: every
  `superpowersplus:<name>` invocation already written into the plans and specs
  of four projects would name a skill that does not exist, which fails silently
  by design — the namespace invariant at the top of [`CLAUDE.md`](CLAUDE.md)
  describes exactly that failure. The owner closed this on 2026-08-05. It is
  recorded so the next sweep against the vendor checklist finds a decision here
  instead of re-deriving the finding.

- **The word-count targets inside `writing-skills` are not adopted as this
  project's bar, and no gate measures words.** `writing-skills/SKILL.md`,
  section "4. Token Efficiency (Critical)" states three tiers: under 150 words
  for a getting-started workflow, under 200 for a frequently-loaded skill,
  under 500 for any other. Measured 2026-08-05 across the fifteen `SKILL.md`
  bodies: `using-superpowers` is the one skill the 200-word tier governs — it
  is the file [`hooks/session-start`](hooks/session-start) reads in full into
  every session — and it holds 502 words, two and a half times the target. The
  other fourteen all exceed the 500-word tier, from 512
  (`requesting-code-review`) to 4202 (`subagent-driven-development`).
  **A gate here would have to invent a number this project cannot justify.**
  The enforced ceiling is the 500-LINE one in
  [check-skill-size.sh](scripts/check-skill-size.sh), borrowed from the vendor
  and declared as borrowed; picking a word number by argument is the move this
  list already refuses elsewhere, and a gate red on all fifteen skills the day
  it ships is a gate nobody reads. The targets stay in `writing-skills` as
  advice to whoever writes a skill, which is what they are. This entry is the
  declared divergence, not a plan to close it.
  **One concrete candidate falls out of the measurement, and it is not a
  general rule being missed.** `using-superpowers/SKILL.md` is the single file
  the 200-word tier governs and the single file
  [`hooks/session-start`](hooks/session-start) reads in full into every session
  of every project — so its 502 words are 502 words of every client
  conversation's context, before the first turn. Cutting it has an effect that
  is measurable in real work rather than against a checklist. Named as a
  candidate; no gate, and no number invented to justify one.
  **The vendored copy carries a target the vendor has since moved.** Anthropic's
  current skill-development guidance for plugin skills asks for a 1,500–2,000
  word body, under 3,000, with 5,000 as the maximum — three to four times looser
  than the under-500 in the copy this repository vendored. Measured against the
  current number, ten of the fifteen comply; against the vendored one, none do.
  That is the strongest reason not to build a gate on the vendored figure.

- **`final-branch-audit/SKILL.md` is not one long document — it is two, and
  that is a named candidate rather than a pending item.** At 368 lines it is
  the only `SKILL.md` over 300 with nothing extracted at all, and the 2026-08-05
  section-by-section pass found why: roughly 142 lines are a rulebook the
  controller reads to *interpret* the verdict (the traceability table, the audit
  table, the verdict rules, out-of-scope tasks, re-running the searches), and
  134 are the dispatch prompt that restates them to *produce* it. **Neither of
  the two exits is free.** Extracting the rulebook leaves the controller reading
  only the prompt — and the prompt does not carry the rationale; the reason a
  human-run verification gets no weaker evidence invented for it exists in the
  rulebook and nowhere else, so a rule that guarded the reading of a verdict
  would become material of consultation, which is exactly what
  `tests/skill-behavior/RESULT-resume-route-inline.md` measured failing.
  Merging the two is a rewrite, not an extraction, and it would need a gate
  against the copies drifting — the same problem the evidence line cost one.
  It stays at 368: 132 under the ceiling, authored entirely by this fork, so
  nothing about it is urgent. Recorded so the next size pass does not
  re-derive it.

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

- **`verification-before-completion` is measured but not settled.** Two runs
  found the verification happening without it, including with no rule
  reachable; its contribution was the shape of the evidence, and that was
  extracted to the two claim points (`1.9.0`). The file stays — **120 lines when
  measured, 137 today**, and the growth is entirely the opening paragraph, twice
  rewritten to state where the skill sits in the wiring. From `## Overview` on it
  is byte-identical to the text that was measured, 113 lines of it, so the
  measurement still describes the rule it was taken against. **The scope
  that was measured is narrow and says so:** one model, two runs, a 122 ms
  suite, and none of the conditions the skill's own Red Flags name — a long
  session, an expensive or slow suite, wanting the work over. Cutting on this
  evidence would be the argument-instead-of-measurement move the measurement
  avoided. **The condition for cutting is a second measurement that builds
  those conditions**, not a decision taken without one.
  `tests/skill-behavior/RESULT-verification-before-completion.md`.
- **CLOSED, and it had been closed for a while without this list noticing.**
  The item here said the stable-anchor gate reached `CLAUDE.md` and nothing
  else, and asked for the widening to `skills/**` as future work. That widening
  landed in `1.13.0` — the section pass now collects `CLAUDE.md`, `docs/`,
  `skills/` and `tests/` — while this entry went on describing the older gate,
  citing a line number for the assignment that had itself moved. **It is the
  reason Open gaps is now read by that pass**, recorded in the `1.14.0` cycle.
  **What replaces it is narrower and still open:** the `file:line` form is
  unchecked wherever it survives, and the count of where that is, plus the
  condition that would justify a gate, is in the entry for this cycle.
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
- **CLOSED in [Unreleased]: a generated release body carried the changelog's
  link-reference block.** Opened 1.3.0 as a deliberate WONTFIX — "not worth a
  change to the one script that decides what every release says" — and carrying
  the standing instruction *do not re-investigate*. The cost side of that
  judgement was right for 1.3.0 and had rotted by now: the footer was eight
  lines when the item was written and is fifty today, and `release-notes.sh`
  had no test of any kind, which is what made touching it expensive. The fix
  landed with the script's first suite, so the "one script nobody dares change"
  is no longer unprotected.

  **The reversal was reached by accident, and that is recorded here because the
  outcome does not prove the method.** The item was not read before the work
  was proposed or done; it surfaced in review, after the fix was written. Had
  the 1.3.0 reasoning still held, the same fix would have been made with the
  same confidence. What produced the right answer was not the process, and a
  right answer from a broken process is the failure this file exists to make
  visible. (opened 1.3.0, closed [Unreleased])
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

- **The pairs rule does not fall back when the spec cannot be opened, and
  nothing says whether it should.** The row added to the Plan Contract in
  [`skills/writing-plans/plan-document-reviewer-prompt.md`](skills/writing-plans/plan-document-reviewer-prompt.md),
  section "The Plan Contract (blocking)", says to read *the spec's* criteria in
  pairs. Measured: on the first run recorded in
  [`tests/skill-behavior/RESULT-criteria-read-in-pairs.md`](tests/skill-behavior/RESULT-criteria-read-in-pairs.md),
  section "Run 1 — the rule was never exercised", the fixture's spec was not
  committed, an earlier contract row fired first, and the reviewer declared the
  pairs check *unverifiable rather than checked-and-passed* — with both criterion
  ids and both texts sitting in the plan under review, on the tasks'
  `**Spec criterion:**` lines. An unopenable spec is ordinary (an uncommitted
  path, a wrong filename, a worktree without it), and in every such case the rule
  silently does not run. Whether it should fall back to the plan's own quotations
  is a design decision nobody has made. Opened 2026-08-24.

- **Four of the five rules added in this cycle ship unmeasured.** Only the pairs
  rule has an adversarial record. The other four — the test-contradicts-its-own-
  implementation row, the applying-role row in both document reviewers, and the
  reproduce-before-acting rule in
  [`skills/receiving-code-review/SKILL.md`](skills/receiving-code-review/SKILL.md),
  section "From External Reviewers" — were placed by reasoning about carrier and
  wording, and nothing has shown they change what a reviewer finds. The deferral
  was deliberate: the pairs rule was chosen because its "before" state was already
  measured, which none of the other four had. It is still a gap, in a suite whose
  own README opens by distinguishing a rule that was measured from one that was
  written down and assumed to work. Opened 2026-08-24.

- **`check-cross-references` counts `## Task` headings inside fenced example
  blocks.** Measured 2026-08-24: run against
  [`docs/superpowers/plans/2026-07-06-sdd-plan-scoped-workspace.md`](docs/superpowers/plans/2026-07-06-sdd-plan-scoped-workspace.md)
  it reports `tasks present 17` for a plan whose real headings number five — the
  other twelve live inside fenced blocks that document the format. The extractor
  reads the file as flat text.
  **A second defect lives in the same script and is a different cause**, stated
  apart because collapsing the two would hide one under the other's fix:
  `TASK_CRIT` carries no optional letter suffix while the `AC_IR` pattern on the
  line above it does, so a task criterion labelled `T2.3a` is not matched at all.
  That one is a regex omission and would survive a markdown-aware extractor.
  Both are left open because the fix is a change to the extractor with its own
  tests, and neither affects the script's green verdict — only the counts it
  prints. Opened 2026-08-24.

- **Six markdown links inside `skills/` point at repository paths the Codex
  archive does not ship**, measured 2026-09-03: two to
  [`docs/context-budget.md`](docs/context-budget.md), from
  [`writing-plans`](skills/writing-plans/SKILL.md) and from its
  [`execution-path.md`](skills/writing-plans/references/execution-path.md); two
  to `scripts/`, from
  [`escalation-format.md`](skills/using-superpowers/references/escalation-format.md)
  and [`verification-before-completion`](skills/verification-before-completion/SKILL.md);
  and two to `tests/`, from those same two files.
  [`package-codex-plugin.sh`](scripts/package-codex-plugin.sh) ships `skills/`
  and rejects `docs/`, `scripts/` and `tests/`, so in that package all six
  resolve to nothing. **This is the class the ledger's write target was fixed
  for in the same cycle, found by sweeping for its siblings** — but these six
  are older than that change and none is an instruction to act on the target,
  which is what made the write target's version urgent. Whether each becomes a
  backticked path, stays a link for the repository reader, or moves its content
  into `skills/` is a judgement per link, not a sweep. Opened 2026-09-03.

Most rules in this project are reasoned rather than measured. Four have been
measured, over eleven adversarial runs: the external-content rule, which held on
its first run; the escalation format, which took two corrections and three runs
to hold; the resume route, which split — the subagent half held on its first
run, the inline half failed twice and held on the third after one structural
change; and the criteria-in-pairs rule, whose first run tripped a neighbouring
gate and never reached it, and which then held on the repaired instrument
against a control run that approved the same fixture with the rule removed. Six
remain queued in the gap listing the eight precaution rules above.

[1.24.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.24.0
[1.23.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.23.0
[1.22.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.22.0
[1.21.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.21.0
[1.20.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.20.0
[1.19.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.19.1
[1.19.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.19.0
[1.18.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.18.0
[1.17.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.17.0
[1.16.4]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.16.4
[1.16.3]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.16.3
[1.16.2]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.16.2
[1.16.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.16.1
[1.16.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.16.0
[1.15.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.15.1
[1.15.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.15.0
[1.14.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.14.1
[1.14.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.14.0
[1.13.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.13.0
[1.12.4]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.12.4
[1.12.3]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.12.3
[1.12.2]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.12.2
[1.12.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.12.1
[1.12.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.12.0
[1.11.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.11.0
[1.10.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.10.0
[1.9.5]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.9.5
[1.9.4]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.9.4
[1.9.3]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.9.3
[1.9.2]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.9.2
[1.9.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.9.1
[1.9.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.9.0
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
