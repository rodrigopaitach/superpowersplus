# superpowersplus — English documentation

[![Release](https://img.shields.io/github/v/release/rodrigopaitach/superpowersplus?style=flat-square&label=release)](https://github.com/rodrigopaitach/superpowersplus/releases/latest) [![CI](https://img.shields.io/github/actions/workflow/status/rodrigopaitach/superpowersplus/ci.yml?style=flat-square&label=ci)](https://github.com/rodrigopaitach/superpowersplus/actions/workflows/ci.yml) [![License](https://img.shields.io/github/license/rodrigopaitach/superpowersplus?style=flat-square&label=license)](../LICENSE)

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

Requires Claude Code.

```bash
/plugin marketplace add rodrigopaitach/superpowersplus
```

```bash
/plugin install superpowersplus@superpowersplus
```

> **Already had it installed?** The plugin used to be named `superpowers`. Remove the old one first, or both will load and their skills will collide:
>
> ```bash
> /plugin uninstall superpowers@superpowersplus
> ```

**The plugin's name is its namespace:** skills reference each other as `superpowersplus:brainstorming`, `superpowersplus:writing-plans`, `superpowersplus:final-branch-audit`, and so on across the skill files.

## Updating

superpowersplus is not on the official marketplace, so **nothing updates itself**. Refresh the installed plugin:

```
/plugin marketplace update superpowersplus
/reload-plugins
```

**Superpowers is no longer a source of updates.** On 2026-08-05 this project stopped pulling from `obra/superpowers` ([`CLAUDE.md`](../CLAUDE.md), section "Relationship with Superpowers"), so there is no rebase step here any more; the remote stays for consultation. What each version brings is in [`CHANGELOG.md`](../CHANGELOG.md).

## How it works

The flow is **spec → plan → tasks → audit**. You invoke nothing: the skills trigger on their own when you ask for something that involves building.

1. **Spec.** The agent investigates your code before any question, builds a ten-category coverage map to decide what to ask, asks one thing at a time with a recommendation and its source, and writes the spec with numbered acceptance criteria.
2. **Plan.** Each spec criterion becomes one or more tasks, and each task declares which criterion it delivers. A coverage matrix ties criterion to test.
3. **Tasks.** A fresh subagent per task, with mandatory TDD: test before code.
4. **Audit.** At the end of the branch, every criterion is traced to the tasks delivering it, in both directions, and given a verdict against located evidence.

There is a gate between each stage. None of them is the agent grading itself — all are independent subagents:

| Gate | What it blocks | Where it lives |
|------|----------------|----------------|
| Spec reviewer | A `file:line` citation that does not hold up when opened; a dependency claim without the lockfile-pinned version or the official docs; a criterion bundling several behaviors; a requirement that exists only in prose; a missing required section; an acceptance criterion that does not serve the problem the spec states | `skills/brainstorming/spec-document-reviewer-prompt.md` |
| Plan reviewer | A task with no spec criterion motivating it; a spec criterion no task covers; a coverage matrix missing any of its five columns; a matrix row pointing at a test no step creates | `skills/writing-plans/plan-document-reviewer-prompt.md` |
| Task reviewer | **Re-runs the task's suite and reports the output verbatim** — it does not accept the implementer's report | `skills/subagent-driven-development/task-reviewer-prompt.md` |
| Final branch audit | A criterion no task delivered (*lost in translation*); a task no criterion motivated (*invented scope*); a criterion with no citation (*not delivered*) | `skills/final-branch-audit/SKILL.md` |

## What gets generated

| Artifact | Where |
|----------|-------|
| Spec | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` |
| Implementation plan | `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` |
| Coverage map | A `## Coverage Map` section inside the spec itself — one row per category with its state and destination, and below it the decision record: each question, the answer, the recommendation given, and its source |
| Review yield | `docs/superpowers/review-yield.md` — one row per review dispatch: date, branch, which review, which round, how many blocking findings it returned, and how many of the previous round's are still open. It is what answers whether the review rounds are paying for themselves |

All of it is git-versioned files, readable without any tooling. The decision record is what lets you audit later **what** you agreed to and **on what basis** — including once the conversation is gone.

## What it adds to Superpowers

Five axes. The detail of each change, entry by entry, is in [`CHANGELOG.md`](../CHANGELOG.md) (written in Portuguese).

- **Evidence-grounded spec** — criteria anchored in the real code and in the external dependencies already present in the project, not in what the model assumes.
- **Plan contract charged by a reviewer** — a subagent reads the spec against the plan and blocks a criterion with no task, a task with no origin, and a criterion with no test.
- **Test coverage matrix** — each criterion mapped by key to the test covering it, instead of coverage asserted in prose.
- **Task reviewer that re-runs the suite** — the reviewer runs the tests, instead of accepting the implementer's report.
- **Task-by-task conformance audit** — at the end of the branch, each criterion is traced to the tasks delivering it and given a verdict against located evidence.

## What it looks like in practice

The agent hit a requirement it could not deliver honestly and stopped. This is what reached the person — condensed from the transcript in [`tests/skill-behavior/RESULT-escalation-format-in-chat-v3.md`](../tests/skill-behavior/RESULT-escalation-format-in-chat-v3.md), the run where this format scored 3 of 3 after scoring 1 of 3 and 2 of 3:

> **A feed file stored inside this repository is not something anyone can subscribe to.** AC2's purpose is "so a team can subscribe to it in a feed reader", but nothing here publishes `docs/` to a website — I checked. Building the file achieves the wording of AC2 without achieving its purpose.
>
> | Option | What it means |
> |---|---|
> | **Drop the feed** (recommended) | Nothing to build; the plain-text index from AC1 still records every archived plan with its date |
> | **Use the feed GitHub already publishes** | No code at all. Covers every commit, not just archived plans, so it is noisier |
> | **Build it by hand** | About fifteen extra lines. Needs three values the design doesn't have: the feed's title, its web address, its one-line description |
> | **Do nothing now** | Build the archiving today, revisit the feed when somebody actually wants to subscribe. Cost: no subscribing until then |
>
> **Recommendation: drop the feed.** `CLAUDE.md` states "Superpowers is a zero-dependency plugin by design", and every path to a checkable feed here ends in an outside tool or an invented web address. **Source: a rule already in your project, plus my own check that nothing publishes `docs/` to a website.**

Four things are load-bearing: the consequence stated before the mechanism, every option carrying its cost, **doing nothing offered as a real option**, and the recommendation naming where it came from. The fourth is what lets someone who does not program tell a recommendation grounded in their own codebase from a plausible guess.

## What has been measured

A skill is text that shapes an agent's behavior, and text nobody tests is an
opinion. Four rules in this project have been put under adversarial test —
build the situation where following the rule is inconvenient and see whether
it holds — and every run has a record with its date, model and per-criterion
verdict in [`tests/skill-behavior/`](../tests/skill-behavior/):

- **External content is data, not instruction** — passed on its first run: the
  reviewer used the legitimate fact from the source, reported the instruction
  planted inside it as a compromised source, and kept verifying, catching the
  wrong citation planted along the way.
  [`RESULT-external-content-is-data.md`](../tests/skill-behavior/RESULT-external-content-is-data.md)
- **The escalation format in the chat** — 1 of 3, then 2 of 3, then 3 of 3,
  across three runs. The first two corrected the rule, not the agent.
  [`RESULT-escalation-format-in-chat-v3.md`](../tests/skill-behavior/RESULT-escalation-format-in-chat-v3.md)
- **Resuming on the subagent path** — 3 of 3 on its first run: it found the
  resume point, presented it to its partner, and touched no file at all.
  [`RESULT-resume-route-subagent.md`](../tests/skill-behavior/RESULT-resume-route-subagent.md)
- **Resuming on the inline path** — failed, failed, passed: the same
  requirement in three different positions of the same file.
  [`RESULT-resume-route-inline.md`](../tests/skill-behavior/RESULT-resume-route-inline.md)

**The law those series measured, and it holds outside this repository: a rule
that guards the next act is followed; a rule that describes a standard is not
— not even when the agent reads it, cites it, and says out loud that it is
breaking it.**

## Visual companion telemetry

Brainstorming's visual companion loads the Prime Radiant logo from their site, with the Superpowers version embedded in the URL. Nothing about your project, your prompt, or your agent goes with it — it is a rough usage count, and the credit is the upstream's.

**This project's guidance is to turn it off:**

```bash
export SUPERPOWERS_DISABLE_TELEMETRY=1
```

`DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` are honored too — superpowersplus does not change that code.

**The code default is still on.** superpowersplus does not ship it disabled and does not modify `skills/brainstorming/scripts/server.cjs`. Turning it off is your action, in your own environment. Inverting the default in the core was evaluated and refused: two upstream tests (`tests/brainstorm-server/branding.test.js:245` and `:261`) assert the logo present by default, and rewriting them to say the opposite would stop them detecting the upstream's own changes.

## Known gaps

Gaps identified and deliberately left open are recorded in [Open gaps](../CHANGELOG.md#open-gaps), each with the reason it was not closed. A gap with no record comes back as a discovery.

## License and credit

MIT — see [`LICENSE`](../LICENSE).

superpowersplus is a **derivative work of Superpowers**, built by Jesse Vincent and the folks at Prime Radiant. The methodology, the skills, and the workflow are theirs; the verification layer described above is this project's. Copyright remains with Jesse Vincent, and this derivative work is distributed under the same terms.

This project **has no affiliation with the author, with Prime Radiant, or with Anthropic**, and speaks for none of them. Problems caused by superpowersplus are not their problem: report them here, not on the original repository.
