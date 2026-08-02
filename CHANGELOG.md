# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Upstream base:** [`44c9b2d`](https://github.com/obra/superpowers/commit/44c9b2d) (2026-07-27) — the last [Superpowers](https://github.com/obra/superpowers) commit incorporated. Update this line at every rebase; it replaces the mirrored upstream `version` this project used before `1.0.0`.

The 34 `plus.N` entries that led to `1.0.0` are preserved verbatim in
[`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md).
References below name them so a claim here can be traced there.

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
- **`CLAUDE.md` reduced from 126 to ~55 lines** — it described the upstream's
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
recorded in [`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md#pendências-conhecidas).

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
  what exists is `tests/skill-behavior/`, with one rule measured. Cloning
  `superpowers-evals` and wiring it in is desirable and undone: it needs a
  submodule or a manual clone per checkout. (opened plus.34)
- **One lockfile line number in an example is illustrative.**
  `package-lock.json:1188` in `brainstorming/SKILL.md` matches no real
  lockfile — this repository is zero-dependency and the line varies per project
  anyway. Closing it would need an example project with a versioned lockfile
  inside the repo. (opened plus.1)

Most rules in this project are reasoned rather than measured. Only the
external-content rule has been measured, once.

[1.0.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.0.0
