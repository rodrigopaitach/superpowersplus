# superpowersplus — English documentation

> **This is a translation.** The canonical text is the Portuguese one, [`README.pt-BR.md`](README.pt-BR.md) — on any divergence, that file is the one that holds.
>
> **Editing one requires editing the other in the SAME commit.** A commit that changes only one of the two opens a divergence nobody can see afterwards: both versions stay plausible, and nothing marks which one went stale.
>
> To have the rule enforced rather than merely stated: `git config core.hooksPath githooks`. The hooks are versioned in `githooks/`; activating them is each clone's own call, because `.git/` is not versionable.

## What it is

A development methodology for coding agents, **based on [Superpowers](https://github.com/obra/superpowers), by Jesse Vincent (Prime Radiant), under the MIT license**.

Superpowers is a set of skills that trigger on their own and make the agent stop before writing code, understand what you actually want, write a spec, plan, and only then implement — with real TDD.

superpowersplus is a derivative work: it keeps all of that and adds one axis: **evidence-or-zero**. Every claim the agent makes about your code requires a `file:line` citation, and whoever verifies re-runs the search instead of taking the writer's word for it.

## Why it exists

The problem is not the agent writing bad code. It is the agent writing correct code against an invented spec.

An agent that cannot find the answer in your code does not go quiet. It produces the most plausible answer — the one that holds for software in general, not for yours. Written into the spec, that sentence is indistinguishable from one somebody verified: it passes review, becomes a task in the plan, becomes code, and fails at integration, where fixing it costs the most.

The same goes for tests. A green suite proves the tests passed, not that they test anything. A report saying "all tests pass", written by whoever implemented the thing, is the only evidence most workflows have — and it is produced by the party being audited.

Both have the same shape: **an unverified claim looks exactly like a verified one.** superpowersplus exists to tell them apart.

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

## Updating

superpowersplus is not on the official marketplace, so **nothing updates itself**. Two steps, in this order:

1. **Rebase onto the upstream**, to bring in `obra/superpowers`'s changes. This is where the `plus.N` changes can conflict — and why they were written to touch as little as possible of the files the upstream edits often.
2. **Refresh the installed plugin:**

   ```
   /plugin marketplace update superpowersplus
   /reload-plugins
   ```

If you do not track Superpowers, only step 2 applies.

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

## What it adds to Superpowers

Five axes. The detail of each change, entry by entry, is in [`PLUS-CHANGELOG.md`](../PLUS-CHANGELOG.md) (written in Portuguese).

- **Evidence-grounded spec** — criteria anchored in the real code and in the external dependencies already present in the project, not in what the model assumes.
- **Plan contract charged by a reviewer** — a subagent reads the spec against the plan and blocks a criterion with no task, a task with no origin, and a criterion with no test.
- **Test coverage matrix** — each criterion mapped by key to the test covering it, instead of coverage asserted in prose.
- **Task reviewer that re-runs the suite** — the reviewer runs the tests, instead of accepting the implementer's report.
- **Task-by-task conformance audit** — at the end of the branch, each criterion is traced to the tasks delivering it and given a verdict against located evidence.

## Visual companion telemetry

Brainstorming's visual companion loads the Prime Radiant logo from their site, with the Superpowers version embedded in the URL. Nothing about your project, your prompt, or your agent goes with it — it is a rough usage count, and the credit is the upstream's.

**This project's guidance is to turn it off:**

```bash
export SUPERPOWERS_DISABLE_TELEMETRY=1
```

`DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` are honored too — superpowersplus does not change that code.

**The code default is still on.** superpowersplus does not ship it disabled and does not modify `skills/brainstorming/scripts/server.cjs`. Turning it off is your action, in your own environment. Inverting the default in the core was evaluated and refused: two upstream tests (`tests/brainstorm-server/branding.test.js:245` and `:261`) assert the logo present by default, and rewriting them to say the opposite would stop them detecting the upstream's own changes.

## Known gaps

Gaps identified and deliberately left open are recorded in [Pendências conhecidas](../PLUS-CHANGELOG.md#pendências-conhecidas) (in Portuguese), each with the reason it was not closed. A gap with no record comes back as a discovery.

## License and credit

MIT — see [`LICENSE`](../LICENSE).

superpowersplus is a **derivative work of [Superpowers](https://github.com/obra/superpowers)**, built by [Jesse Vincent](https://blog.fsck.com) and the folks at [Prime Radiant](https://primeradiant.com). The methodology, the skills, and the workflow are theirs; the verification layer described above is this project's. Copyright remains with Jesse Vincent, and this derivative work is distributed under the same terms.

This project **has no affiliation with the author, with Prime Radiant, or with Anthropic**, and speaks for none of them. Problems caused by superpowersplus are not their problem: report them here, not on the original repository.
