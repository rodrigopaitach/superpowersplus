# superpowersplus

A development methodology for coding agents, where every claim the agent makes about your code carries a `file:line` citation — and whoever verifies re-runs the search instead of taking the writer's word for it.

> **Based on [Superpowers](https://github.com/obra/superpowers), by Jesse Vincent (Prime Radiant), under the MIT license.** superpowersplus is a derivative work: it keeps Superpowers' skills and workflow and adds its own verification layer on top. It is not affiliated with Jesse Vincent, Prime Radiant, or Anthropic, and speaks for none of them.
>
> **📖 Documentation:** [![Português](https://img.shields.io/badge/doc-Portugu%C3%AAs-009C3B?style=flat-square)](docs/README.pt-BR.md) [![English](https://img.shields.io/badge/doc-English-012169?style=flat-square)](docs/README.en.md)

## Why it exists

The problem is not the agent writing bad code. It is the agent writing correct code against an invented spec.

An agent that cannot find the answer in your code does not go quiet. It produces the most plausible answer — the one that holds for software in general, not for yours. Written into the spec, that sentence is indistinguishable from one somebody verified: it passes review, becomes a task in the plan, becomes code, and fails at integration, where fixing it costs the most.

The same goes for tests. A green suite proves the tests passed, not that they test anything. A report saying "all tests pass", written by whoever implemented the thing, is the only evidence most workflows have — and it is produced by the party being audited.

Both have the same shape: **an unverified claim looks exactly like a verified one.** superpowersplus exists to tell them apart.

## Who it is for

Anyone using a coding agent with real work at stake — developers, enthusiasts, and explicitly **including people who do not program**.

That last part is design, not accident. Someone who does not program cannot judge whether a technical decision is right, but can judge **where it came from**: open the cited line and see that it exists and says what was claimed. So:

- **Every question ships a recommendation.** No exception. A question without one hands a technical decision to someone with no basis to take it.
- **The recommendation's source is declared** — a pattern already in your project (cited as `file:line`), the official documentation of the dependency involved, or general good practice. When it is general practice, the agent says so, so you know no verification against your code happened there.
- **Questions are written as practical consequence**: what breaks, what gets slow, what gets expensive later. Not the mechanism. A technical term appears only if it is defined in the same sentence.
- **The options table carries a consequence column**, so you recognize what you are accepting without having to become an architect.

## What it adds

Five axes on top of Superpowers, under one thread: a claim about the code requires a citation, and the verifier re-runs the search.

- **Evidence-grounded spec** — criteria anchored in the real code and in the external dependencies already present in the project, not in what the model assumes.
- **Plan contract charged by a reviewer** — a subagent reads the spec against the plan and blocks a criterion with no task, a task with no origin, and a criterion with no test.
- **Test coverage matrix** — each criterion mapped by key to the test covering it, instead of coverage asserted in prose.
- **Task reviewer that re-runs the suite** — the reviewer runs the tests, instead of accepting the implementer's report.
- **Task-by-task conformance audit** — at the end of the branch, each criterion is traced to the tasks delivering it and given a verdict against located evidence.

Every change, entry by entry, is in [PLUS-CHANGELOG.md](PLUS-CHANGELOG.md). Gaps deliberately left open are in [Pendências conhecidas](PLUS-CHANGELOG.md#pendências-conhecidas).

## Installation

### Claude Code

```bash
/plugin marketplace add rodrigopaitach/superpowersplus
```

```bash
/plugin install superpowers@superpowersplus
```

The marketplace is `superpowersplus`, but the plugin is still named `superpowers`: the skills cross-reference each other by that prefix (`superpowers:brainstorming`, `superpowers:writing-plans`, …) across the skill files, and renaming the plugin would break every one of those references.

### Other harnesses

Claude Code is the path this project actually exercises. The harnesses below are supported by the underlying Superpowers and install from a git URL, so pointing them at this repository uses the same mechanism — but none of them is tested here, and problems with them belong in [this repository's issues](https://github.com/rodrigopaitach/superpowersplus/issues), not the upstream's.

| Harness | Command |
|---------|---------|
| Antigravity | `agy plugin install https://github.com/rodrigopaitach/superpowersplus` |
| Gemini CLI | `gemini extensions install https://github.com/rodrigopaitach/superpowersplus` |
| Factory Droid | `droid plugin marketplace add https://github.com/rodrigopaitach/superpowersplus` |
| Kimi Code | `/plugins install https://github.com/rodrigopaitach/superpowersplus` — [detailed docs](docs/README.kimi.md) |
| Pi | `pi install git:github.com/rodrigopaitach/superpowersplus` |
| OpenCode | Tell it to fetch and follow `https://raw.githubusercontent.com/rodrigopaitach/superpowersplus/refs/heads/main/.opencode/INSTALL.md` — [detailed docs](docs/README.opencode.md) |

Antigravity runs the session-start hook, so skills are active from the first message. Pi loads the skills plus a small extension injecting the `using-superpowers` bootstrap at startup and after compaction.

Codex, Cursor, and GitHub Copilot CLI install from their own marketplaces, which carry the upstream Superpowers rather than this project.

## How it works

It starts the moment you fire up your coding agent. As soon as it sees you are building something, it does *not* jump to writing code. It steps back and asks what you are really trying to do — and, before asking anything, it reads your actual code.

Once it has teased a spec out of the conversation, it shows it to you in chunks short enough to actually read. Then a reviewer subagent opens every `file:line` the spec cites and blocks on any claim the code does not back.

After you sign off, the agent builds an implementation plan clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI, and DRY — and a second reviewer charges the plan against the spec.

Then it works through the tasks with a fresh subagent each, reviewing as it goes. It is not uncommon for it to work autonomously for a couple of hours without deviating from the plan you approved.

**The skills trigger automatically.** You do not invoke anything.

### The workflow

1. **brainstorming** — Activates before writing code. Investigates the real code first, builds a ten-category coverage map to decide what to ask, refines through questions that each carry a recommendation and its source, presents the design in sections. Saves a spec with numbered acceptance criteria; a reviewer subagent then opens every `file:line` it cites.
2. **using-git-worktrees** — Activates after design approval. Isolated workspace on a new branch, project setup, clean test baseline.
3. **writing-plans** — Breaks work into bite-sized tasks (2–5 minutes each). Every task has exact file paths, complete code, verification steps, and the spec criterion it delivers. A reviewer blocks on a missing spec path, a task nothing motivated, or a criterion with no test row.
4. **subagent-driven-development** or **executing-plans** — Fresh subagent per task with two-stage review (spec compliance, then code quality), or batches with human checkpoints.
5. **test-driven-development** — Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.
6. **requesting-code-review** — Between tasks. Reviews against the plan, reports issues by severity. Critical issues block progress.
7. **final-branch-audit** — When all plan tasks are done. Traces every spec criterion to the tasks covering it, then verdicts each one against `file:line` evidence. A requirement no task covers is lost in translation; a task no criterion motivated is invented scope; no citation, not delivered.
8. **finishing-a-development-branch** — Verifies tests and the audit verdict, presents options (merge/PR/keep/discard), cleans up the worktree.

## What gets generated

| Artifact | Where |
|----------|-------|
| Spec | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` |
| Implementation plan | `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` |
| Coverage map | A `## Coverage Map` section inside the spec — one row per category with its state and destination, and below it the decision record: each question, the answer, the recommendation given, and its source |

All of it is git-versioned files, readable without any tooling. The decision record is what lets you audit later **what** you agreed to and **on what basis** — including once the conversation is gone.

## Skills library

**Testing** — `test-driven-development` (RED-GREEN-REFACTOR, includes testing anti-patterns reference)

**Debugging** — `systematic-debugging` (4-phase root cause, includes root-cause-tracing, defense-in-depth, condition-based-waiting) · `verification-before-completion`

**Collaboration** — `brainstorming` · `writing-plans` · `executing-plans` · `dispatching-parallel-agents` · `requesting-code-review` · `receiving-code-review` · `final-branch-audit` · `using-git-worktrees` · `finishing-a-development-branch` · `subagent-driven-development`

**Meta** — `writing-skills` · `using-superpowers`

## Philosophy

- **Evidence over claims** — a claim with no located citation is not delivered
- **Test-Driven Development** — write tests first, always
- **Systematic over ad-hoc** — process over guessing
- **Complexity reduction** — simplicity as the primary goal

## Contributing

superpowersplus does not take contributions. Contributing to Superpowers itself happens at [obra/superpowers](https://github.com/obra/superpowers), under its own process — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Updating

Not on the official marketplace, so nothing updates itself: rebase onto Superpowers to pick up its improvements, then refresh the plugin from this marketplace. Full procedure in [Português](docs/README.pt-BR.md#atualizando) / [English](docs/README.en.md#updating).

## Visual companion telemetry

Brainstorming's optional visual companion loads the Prime Radiant logo from their site, with the Superpowers version in the URL. Nothing about your project, prompt, or agent goes with it — it is a rough usage count, and the mechanism and the credit are Superpowers'.

**Turn it off:** `export SUPERPOWERS_DISABLE_TELEMETRY=1`. `DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` are honored too. **The code default is still on** — superpowersplus does not ship it disabled and does not modify that code, so turning it off is an action you take in your own environment.

## Origin and credit

superpowersplus is a derivative work of [Superpowers](https://github.com/obra/superpowers), built by [Jesse Vincent](https://blog.fsck.com) and the folks at [Prime Radiant](https://primeradiant.com). The methodology, the skills, and the workflow are theirs; the verification layer described under "What it adds" is this project's. Read [the original release announcement](https://blog.fsck.com/2025/10/09/superpowers/).

Superpowers' own community — Discord, issues, release announcements — is at [obra/superpowers](https://github.com/obra/superpowers). Anything about superpowersplus goes to [this repository's issues](https://github.com/rodrigopaitach/superpowersplus/issues).

## License

MIT — see [LICENSE](LICENSE). Copyright remains with Jesse Vincent; this derivative work is distributed under the same terms.
