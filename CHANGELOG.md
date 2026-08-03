# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Upstream base:** [`44c9b2d`](https://github.com/obra/superpowers/commit/44c9b2d) (2026-07-27) — the last [Superpowers](https://github.com/obra/superpowers) commit incorporated. Update this line at every rebase; it replaces the mirrored upstream `version` this project used before `1.0.0`.

The 34 `plus.N` entries that led to `1.0.0` are preserved verbatim in
[`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md) (in Portuguese).
References below name them so a claim here can be traced there.

## [Unreleased]

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
  `skills/subagent-driven-development/SKILL.md:152` and in the upstream's copy
  at the same positions, and our only edit there was additive
  (`read plan` → `read plan + cited spec`), which still matches. Confirmed
  failing at `b6b68ef` in a clean detached clone. Left unfixed: it is an
  upstream test, and rewriting its regex would make it assert something other
  than what it asserts. Treat a failure here as uninformative until the
  assertion is language-agnostic.

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

Most rules in this project are reasoned rather than measured. Two have been
measured, over four adversarial runs: the external-content rule, which held on
its first run, and the escalation format, which took two corrections and three
runs to hold.

[1.2.2]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.2
[1.2.1]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.1
[1.2.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.2.0
[1.1.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.1.0
[1.0.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.0.0
