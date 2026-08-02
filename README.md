# Superpowers

> **Fork pessoal.** Este repositório é um fork de
> [obra/superpowers](https://github.com/obra/superpowers) (Jesse Vincent, MIT)
> com alterações próprias — não é uma cópia do upstream. Não tem vínculo com o
> autor, com a Prime Radiant ou com a Anthropic, e não fala por eles. As
> alterações próprias estão registradas em
> [PLUS-CHANGELOG.md](PLUS-CHANGELOG.md); o restante deste README é texto do
> upstream.
>
> **📖 Documentação do fork:** [![Português](https://img.shields.io/badge/doc-Portugu%C3%AAs-009C3B?style=flat-square)](docs/README.pt-BR.md) [![English](https://img.shields.io/badge/doc-English-012169?style=flat-square)](docs/README.en.md)

Superpowers is a complete software development methodology for your coding agents, built on top of a set of composable skills and some initial instructions that make sure your agent uses them.

## O que muda neste fork

Cinco eixos, sob um mesmo fio condutor: afirmação sobre o código exige citação
`arquivo:linha`, e quem verifica reexecuta a busca em vez de aceitar a palavra
de quem escreveu.

- **Spec fundamentada em evidência** — critérios ancorados no código real e nas
  dependências externas já presentes no projeto, não no que o modelo supõe.
- **Contrato do plano cobrado por revisor** — um subagente lê a spec contra o
  plano e bloqueia critério sem tarefa, tarefa sem origem e critério sem teste.
- **Matriz de cobertura de testes** — cada critério mapeado por chave ao teste
  que o cobre, em vez de cobertura afirmada em prosa.
- **Revisor de task que reexecuta a suíte** — o revisor roda os testes, em vez
  de aceitar o relatório de quem implementou.
- **Auditoria de conformidade tarefa a tarefa** — no fim da branch, cada
  critério da spec é rastreado até as tarefas que o entregam e vereditado
  contra evidência localizada.

O detalhe de cada mudança, entrada por entrada, está em
[PLUS-CHANGELOG.md](PLUS-CHANGELOG.md). Os buracos identificados e
deliberadamente não fechados estão em
[Pendências conhecidas](PLUS-CHANGELOG.md#pendências-conhecidas).

## Quickstart

Give your agent Superpowers: [Claude Code](#claude-code), [Antigravity](#antigravity), [Codex App](#codex-app), [Codex CLI](#codex-cli), [Cursor](#cursor), [Factory Droid](#factory-droid), [Gemini CLI](#gemini-cli), [GitHub Copilot CLI](#github-copilot-cli), [Kimi Code](#kimi-code), [OpenCode](#opencode), [Pi](#pi).

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do. 

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest. 

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY. 

Next up, once you say "go", it launches a *subagent-driven-development* process, having agents work through each engineering task, inspecting and reviewing their work, and continuing forward. It's not uncommon for your agent to work autonomously for a couple hours at a time without deviating from the plan you put together.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Superpowers.

## Installation

Installation differs by harness. If you use more than one, install Superpowers separately for each one.

### Claude Code

Superpowers is available via the [official Claude plugin marketplace](https://claude.com/plugins/superpowers)

#### Este fork (superpowersplus)

As duas subseções seguintes instalam o upstream. Para instalar **este fork**:

- Registre o marketplace:

  ```bash
  /plugin marketplace add rodrigopaitach/superpowersplus
  ```

- Instale o plugin:

  ```bash
  /plugin install superpowers@superpowersplus
  ```

O marketplace se chama `superpowersplus`, mas o plugin continua se chamando
`superpowers` porque as skills se referenciam entre si por esse prefixo
(`superpowers:brainstorming`, `superpowers:writing-plans`, …) — renomear o
plugin quebraria todas essas referências.

#### Official Marketplace

- Install the plugin from Anthropic's official marketplace:

  ```bash
  /plugin install superpowers@claude-plugins-official
  ```

#### Superpowers Marketplace

The Superpowers marketplace provides Superpowers and some other related plugins for Claude Code.

- Register the marketplace:

  ```bash
  /plugin marketplace add obra/superpowers-marketplace
  ```

- Install the plugin from this marketplace:

  ```bash
  /plugin install superpowers@superpowers-marketplace
  ```

### Antigravity

Install Superpowers as a plugin from this repository:

```bash
agy plugin install https://github.com/obra/superpowers
```

Antigravity runs the plugin's session-start hook, so Superpowers is active from
the first message. Reinstall with the same command to update.

### Codex App

Superpowers is available via the [official Codex plugin marketplace](https://github.com/openai/plugins).

- In the Codex app, click on Plugins in the sidebar.
- You should see `Superpowers` in the Coding section.
- Click the `+` next to Superpowers and follow the prompts.

### Codex CLI

Superpowers is available via the [official Codex plugin marketplace](https://github.com/openai/plugins).

- Open the plugin search interface:

  ```bash
  /plugins
  ```

- Search for Superpowers:

  ```bash
  superpowers
  ```

- Select `Install Plugin`.

### Cursor

- In Cursor Agent chat, install from marketplace:

  ```text
  /add-plugin superpowers
  ```

- Or search for "superpowers" in the plugin marketplace.

### Factory Droid

- Register the marketplace:

  ```bash
  droid plugin marketplace add https://github.com/obra/superpowers
  ```

- Install the plugin:

  ```bash
  droid plugin install superpowers@superpowers
  ```

### Gemini CLI

- Install the extension:

  ```bash
  gemini extensions install https://github.com/obra/superpowers
  ```

- Update later:

  ```bash
  gemini extensions update superpowers
  ```

### GitHub Copilot CLI

- Register the marketplace:

  ```bash
  copilot plugin marketplace add obra/superpowers-marketplace
  ```

- Install the plugin:

  ```bash
  copilot plugin install superpowers@superpowers-marketplace
  ```

### Kimi Code

Superpowers is available in Kimi Code's plugin marketplace.

- Open Kimi Code's plugin manager:

  ```text
  /plugins
  ```

- Go to `Marketplace` > `Superpowers` and install it.

- Or install directly from this repository:

  ```text
  /plugins install https://github.com/obra/superpowers
  ```

- Detailed docs: [docs/README.kimi.md](docs/README.kimi.md)

### OpenCode

OpenCode uses its own plugin install; install Superpowers separately even if you
already use it in another harness.

- Tell OpenCode:

  ```
  Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
  ```

- Detailed docs: [docs/README.opencode.md](docs/README.opencode.md)

### Pi

Install Superpowers as a Pi package from this repository:

```bash
pi install git:github.com/obra/superpowers
```

For local development, run Pi with this checkout loaded as a temporary package:

```bash
pi -e /path/to/superpowers
```

The Pi package loads the Superpowers skills and a small extension that injects the `using-superpowers` bootstrap at session startup and again after compaction. Pi has native skills, so no compatibility `Skill` tool is required. Subagent and task-list tools remain optional Pi companion packages.

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Investigates the real code first, refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves a spec with numbered acceptance criteria, then a reviewer subagent opens every `file:line` it cites and blocks on any claim the code doesn't back.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps, and the spec criterion it delivers. A reviewer subagent then reads the spec against the plan and blocks on a missing spec path, a task nothing motivated, or a criterion with no test row.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **final-branch-audit** - Activates when all plan tasks are done, before the final code review. Traces every spec criterion to the tasks covering it, then verdicts every acceptance criterion against `file:line` evidence. A requirement no task covers is lost in translation; a task no criterion motivated is invented scope; no citation, not delivered.

8. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests and the audit verdict, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration** 
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **final-branch-audit** - Spec-to-task traceability plus task-by-task conformance audit against located evidence
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-superpowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

Read [the original release announcement](https://blog.fsck.com/2025/10/09/superpowers/).

## Contributing

This fork is personal and does not take contributions. Contributing to the original project happens at [obra/superpowers](https://github.com/obra/superpowers), under its own process — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Updating

Superpowers updates are somewhat coding-agent dependent, but are often automatic.

## License

MIT License - see LICENSE file for details

## Visual companion telemetry

Because skills and plugins don't provide any feedback to creators, we have no idea how many of you are using Superpowers. By default, the Prime Radiant logo on brainstorming's optional visual companion feature is loaded from our website. It includes the version of Superpowers in use. It does not include any details about your project, prompt, or coding agent. We don't see your clicks or anything about what you're building. This helps us have a rough idea of how many folks are using Superpowers and which version of Superpowers they're using. It's 100% optional. To disable this, set the environment variable `SUPERPOWERS_DISABLE_TELEMETRY` to any true value. Superpowers also honors Claude Code's `DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` opt-outs.

**This fork's guidance:** turn it off. `export SUPERPOWERS_DISABLE_TELEMETRY=1` in your environment — `DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` are honored too, since this fork does not change that code. **The code default is still the upstream's: on.** This fork does not ship it disabled and does not modify `server.cjs`; turning it off is an action you take in your own environment. The paragraph above is the upstream's, and the credit in it is theirs.

## Community

Superpowers is built by [Jesse Vincent](https://blog.fsck.com) and the rest of the folks at [Prime Radiant](https://primeradiant.com).

- **Discord**: [Join us](https://discord.gg/35wsABTejz) for community support, questions, and sharing what you're building with Superpowers
- **Issues**: https://github.com/obra/superpowers/issues
- **Release announcements**: [Sign up](https://primeradiant.com/superpowers/) to get notified about new versions
