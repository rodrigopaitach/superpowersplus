# Superpowers+ — English documentation

> **This is a translation.** The canonical text is the Portuguese one, [`README.pt-BR.md`](README.pt-BR.md) — on any divergence, that file is the one that holds.
>
> **Editing one requires editing the other in the SAME commit.** A commit that changes only one of the two opens a divergence nobody can see afterwards: both versions stay plausible, and nothing marks which one went stale.

## What it is

A personal fork of [obra/superpowers](https://github.com/obra/superpowers), by Jesse Vincent, licensed MIT.

The original Superpowers is a development methodology for coding agents: a set of skills that trigger on their own and make the agent stop before writing code, understand what you actually want, write a spec, plan, and only then implement — with real TDD.

This fork keeps all of that and adds one axis: **evidence-or-zero**. Every claim the agent makes about your code requires a `file:line` citation, and whoever verifies re-runs the search instead of taking the writer's word for it.

## Why it exists

The problem is not the agent writing bad code. It is the agent writing correct code against an invented spec.

An agent that cannot find the answer in your code does not go quiet. It produces the most plausible answer — the one that holds for software in general, not for yours. Written into the spec, that sentence is indistinguishable from one somebody verified: it passes review, becomes a task in the plan, becomes code, and fails at integration, where fixing it costs the most.

The same goes for tests. A green suite proves the tests passed, not that they test anything. A report saying "all tests pass", written by whoever implemented the thing, is the only evidence most workflows have — and it is produced by the party being audited.

Both have the same shape: **an unverified claim looks exactly like a verified one.** This fork exists to tell them apart.

## Who it is for

Anyone using a coding agent with real work at stake — developers, enthusiasts, and explicitly **including people who do not program**.

That part is design, not accident. A partner who does not program cannot judge whether a technical decision is right, but can judge **where it came from**: open the cited line and see that it exists and says what was claimed. So:

- **Every question ships a recommendation.** No exception. A question without one hands a technical decision to someone with no basis to take it.
- **The recommendation's source is declared**, in one of three forms: a pattern that already exists in your project (cited as `file:line`), the official documentation of the dependency involved, or general good practice — and when it is general practice, the agent says so, so you know no verification against your code happened there.
- **Questions are written as practical consequence**: what breaks, what gets slow, what gets expensive later. Not the mechanism. A technical term appears only if it is defined in the same sentence.
- **The options table carries a consequence column per option**, so you recognize what you are accepting without having to become an architect.

## Installation

Requires [Claude Code](https://claude.com/claude-code).

```bash
/plugin marketplace add rodrigopaitach/superpowersplus
```

```bash
/plugin install superpowers@superpowersplus
```

**Why the plugin is called `superpowers` while the marketplace is `superpowersplus`:** the skills cross-reference each other by that prefix — `superpowers:brainstorming`, `superpowers:writing-plans`, `superpowers:final-branch-audit`, and so on, across dozens of points scattered through the skill files. Renaming the plugin would break every one of those references. It is the marketplace that needs its own name, so it does not collide with the upstream one.

## How it works

The flow is **spec → plan → tasks → audit**. You invoke nothing: the skills trigger on their own when you ask for something that involves building.

1. **Spec.** The agent investigates your code before any question, builds a ten-category coverage map to decide what to ask, asks one thing at a time with a recommendation and its source, and writes the spec with numbered acceptance criteria.
2. **Plan.** Each spec criterion becomes one or more tasks, and each task declares which criterion it delivers. A coverage matrix ties criterion to test.
3. **Tasks.** A fresh subagent per task, with mandatory TDD: test before code.
4. **Audit.** At the end of the branch, every criterion is traced to the tasks delivering it, in both directions, and given a verdict against located evidence.

There is a gate between each stage. None of them is the agent grading itself — all are independent subagents:

| Gate | What it blocks | Where it lives |
|------|----------------|----------------|
| Spec reviewer | A `file:line` citation that does not hold up when opened; a dependency claim without the lockfile-pinned version or the official docs; a criterion bundling several behaviors; a requirement that exists only in prose; a missing required section | `skills/brainstorming/spec-document-reviewer-prompt.md` |
| Plan reviewer | A task with no spec criterion motivating it; a spec criterion no task covers; a coverage matrix missing any of its five columns; a matrix row pointing at a test no step creates | `skills/writing-plans/plan-document-reviewer-prompt.md` |
| Task reviewer | **Re-runs the task's suite and reports the output verbatim** — it does not accept the implementer's report | `skills/subagent-driven-development/task-reviewer-prompt.md` |
| Final branch audit | A criterion no task delivered (*lost in translation*); a task no criterion motivated (*invented scope*); a criterion with no citation (*not delivered*) | `skills/final-branch-audit/SKILL.md` |

## What gets generated

| Artifact | Where |
|----------|-------|
| Spec | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` |
| Implementation plan | `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` |
| Coverage map | A `## Coverage Map` section inside the spec itself — one row per category with its state and destination, and below it the decision record: each question, the answer, the recommendation given, and its source |

All of it is git-versioned files, readable without any tooling. The decision record is what lets you audit later **what** you agreed to and **on what basis** — including once the conversation is gone.

## Differences from upstream

Five axes. The detail of each change, entry by entry, is in [`PLUS-CHANGELOG.md`](../PLUS-CHANGELOG.md) (written in Portuguese).

- **Evidence-grounded spec** — criteria anchored in the real code and in the external dependencies already present in the project, not in what the model assumes.
- **Plan contract charged by a reviewer** — a subagent reads the spec against the plan and blocks a criterion with no task, a task with no origin, and a criterion with no test.
- **Test coverage matrix** — each criterion mapped by key to the test covering it, instead of coverage asserted in prose.
- **Task reviewer that re-runs the suite** — the reviewer runs the tests, instead of accepting the implementer's report.
- **Task-by-task conformance audit** — at the end of the branch, each criterion is traced to the tasks delivering it and given a verdict against located evidence.

## Known gaps

Gaps identified and deliberately left open are recorded in [Pendências conhecidas](../PLUS-CHANGELOG.md#pendências-conhecidas) (in Portuguese), each with the reason it was not closed. A gap with no record comes back as a discovery.

## License and credit

MIT — see [`LICENSE`](../LICENSE).

Superpowers is the work of [Jesse Vincent](https://blog.fsck.com) and the folks at [Prime Radiant](https://primeradiant.com). This fork is personal and **has no affiliation with the author, with Prime Radiant, or with Anthropic**, and speaks for none of them. Problems caused by this fork are not their problem: report them here, not on the original repository.
