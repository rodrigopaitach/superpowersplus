# Three defects found by consulting the upstream — Design

**Date:** 2026-08-21
**Route:** full process — three production files are touched, and the short
path allows two.

## The request

Consulting `obra/superpowers` at `v6.3.0` surfaced three defects in this
repository. None of them is an upstream feature being adopted: each is a fault
in code this project already ships, which reading their diff made visible.
Their fixes are used as evidence that a fix exists, never as the reason to
make one.

**One premise was tested and rejected during this design.** The first draft
proposed installing Graphviz, adding it to CI, and porting the upstream's
113-line suite. Measurement killed it: the tool has been broken for over five
months with nothing calling it, and `CLAUDE.md:52` forbids depending on an
external tool. What survives is the minimal repair, with no external tool
added to any automated check.

## Problem 1 — `render-graphs.js` does not load

`skills/writing-skills/render-graphs.js` extracts ` ```dot ` blocks from a
skill's markdown and renders them to SVG. It cannot start: the file uses
CommonJS `require` while `package.json` declares the package an ES module.

Two further faults sit in the same file and are repaired in the same pass
because they are one edit apart and both are correctness, not taste: the
Graphviz probe uses `which`, which does not exist on Windows, and the renderer
passes its command through a shell for no reason.

**Scope decided 2026-08-21: repair, do not resurrect.** The script keeps
requiring a Graphviz installation the project does not ship. It gains no CI
Graphviz step and no dependency. Its test asserts what can be asserted with no
Graphviz present, which is exactly the half that proves this defect.

## Problem 2 — a destructive command with no guard

`skills/finishing-a-development-branch/SKILL.md` instructs an agent to run
`git worktree remove`. Git refuses that command when the worktree holds
modified or untracked files, and the obvious next move — `--force` — destroys
files that exist in no other place. The skill says nothing about the refusal,
so the guard exists nowhere.

## Problem 3 — a version bump that writes before it reads

`scripts/bump-version.sh` walks seven declared manifests and writes each one
as it goes. A manifest it cannot read is discovered mid-write, leaving the
repository holding two different versions. A manifest missing its declared
field is not discovered at all.

## Acceptance Criteria

- **AC1** — Running `skills/writing-skills/render-graphs.js` under `node`
  produces no `ReferenceError: require is not defined`; the file loads as an
  ES module.
- **AC2** — With no `dot` on `PATH`, the script exits non-zero and prints its
  Graphviz install guidance.
- **AC3** — The Graphviz probe does not invoke `which`.
- **AC4** — `dot` is invoked with an argument array and no shell.
- **AC5** — `tests/writing-skills/test-render-graphs.sh` exists and asserts
  `AC1` and `AC2`, and passes on a machine with no Graphviz installed.
- **AC6** — When `dot` is present, that suite additionally asserts an SVG file
  is written and contains SVG markup. When `dot` is absent, the suite prints
  that it skipped that assertion and why.
- **AC7** — `.github/workflows/ci.yml` gains a step running that suite, and no
  step installing Graphviz.
- **AC8** — `skills/finishing-a-development-branch/SKILL.md` states what to do
  when `git worktree remove` is refused, and that `--force` is never used on
  the agent's own initiative.
- **AC9** — That passage names the command listing what is at stake and offers
  the human partner an explicit set of outcomes to choose from.
- **AC10** — The `## Common Rationalizations` table in that file carries a row
  for treating the refusal as cleanup to be forced through.
- **AC11** — `scripts/bump-version.sh` reads every declared manifest field
  before writing to any manifest, and exits non-zero having written nothing
  when a read fails.
- **AC12** — A manifest whose declared field is absent fails that preflight,
  not only a manifest that cannot be parsed.
- **AC13** — `tests/version-bump/test-bump-version.sh` exists and proves
  `AC11` and `AC12` by difference: with one manifest broken, no declared
  manifest's version changes, and with every manifest well formed the bump
  still succeeds.
- **AC14** — `.github/workflows/ci.yml` gains a step running that suite.
- **AC15** — `scripts/check-skill-size.sh` exits 0 after the edit to
  `skills/finishing-a-development-branch/SKILL.md`.
- **AC16** — Every commit touching `skills/` or `scripts/` carries its
  `CHANGELOG.md` entry in the same commit.

## Implicit Requirements

- **IR1** — No project dependency is added. `package.json` gains nothing, no
  lockfile changes, and no automated check requires Graphviz.
- **IR2** — The skipped assertion in `AC6` announces itself in the suite's
  output. A suite that silently covers less than it appears to is the failure
  this requirement exists to prevent.
- **IR3** — The `AC8` guard is prose in a skill, not a hook. This is a
  decision, not an oversight, and the spec records it: a hook is the only
  layer that holds regardless of what the agent decides, and building one is a
  project of its own.
- **IR4** — The upstream's YAML manifest support is not adopted. All seven
  manifests declared in `.version-bump.json` are JSON.
- **IR5** — No reviewer prompt and no skill body other than
  `skills/finishing-a-development-branch/SKILL.md` is modified.
- **IR6** — The existing gates stay green: `scripts/check-links.sh`,
  `scripts/check-changelog.sh`, `scripts/check-docs-sync.sh`,
  `scripts/check-skill-size.sh`, `scripts/check-escalation-shape.sh`,
  `scripts/check-evidence-line.sh`.

## Codebase Findings

Every claim below was measured in this checkout on 2026-08-21, at `f575958`.

1. **The script cannot start.** `skills/writing-skills/render-graphs.js:16` —
   `const fs = require('fs');` — against `package.json:5` — `"type": "module"`.
   Measured: `node skills/writing-skills/render-graphs.js ../subagent-driven-development`
   exits `1` with `ReferenceError: require is not defined in ES module scope`.

2. **The Windows-hostile probe.** `skills/writing-skills/render-graphs.js:112`
   — `execSync('which dot', { encoding: 'utf-8' });`. `which` is not a command
   on Windows, so the probe reports Graphviz missing where it is installed.

3. **The needless shell.** `skills/writing-skills/render-graphs.js:72` —
   `return execSync('dot -Tsvg', {`.

4. **How long it has been broken, and who noticed.** `render-graphs.js` was
   added on 2025-12-11 (`28ba020`) and has not been modified since;
   `"type": "module"` arrived on 2026-03-15 in `911fa1d`, a commit about the
   opencode plugin test. Nothing invokes the script — a search across `.sh`,
   `.yml`, `.json`, `.js` and `.mjs` finds only its own documentation at
   `skills/writing-skills/SKILL.md:331-334` — and no SVG it produced is under
   version control.

5. **The unguarded removal.**
   `skills/finishing-a-development-branch/SKILL.md:225-226` —
   `git worktree remove "$WORKTREE_PATH"` followed by `git worktree prune`,
   with no text anywhere in the file about the refusal or about `--force`.

6. **That file has room.** `skills/finishing-a-development-branch/SKILL.md` is
   258 lines; `scripts/check-skill-size.sh:26` sets `MAX=500`, and
   `scripts/check-skill-size.sh:35` exempts only
   `skills/writing-skills/SKILL.md`.

7. **The bump writes as it walks.** `scripts/bump-version.sh:178-189` — the
   `while` loop reads a field and writes it inside the same iteration, with no
   pass over the manifests beforehand. `scripts/bump-version.sh:11` sets
   `set -euo pipefail`.

8. **Measured: a broken manifest leaves the repository split.** Running the
   real script in a temporary repository declaring three manifests, with the
   middle one holding unparseable JSON: exit `5`, the first manifest at the new
   version, the third still at the old one, and the audit that would have
   reported the drift never runs because the shell aborts first.

9. **Measured: a missing field is not detected at all.** Same harness, middle
   manifest missing its declared field: exit `0`, the line
   `b.json (version)  null -> 2.0.0` printed as though it had succeeded, and
   the field created in a manifest that never had it.

10. **Measured: the one-character fix.** `jq -r '.version'` on a manifest
    lacking the field prints `null` and exits `0`; `jq -er '.version'` on the
    same file exits `1`, and on a manifest that has the field exits `0`.

11. **The dependency policy this design obeys.** `CLAUDE.md:52` —
    "**Third-party dependencies.** This is a zero-dependency plugin. A change
    needing an external tool or service belongs in its own plugin."

12. **The rule that puts the suites in CI.** `CLAUDE.md` states, in the
    "Where the rest lives" section, "**Add a suite, add its CI step.**" The
    static suites are declared as steps in `.github/workflows/ci.yml`.

## External Dependencies

**Graphviz — a pre-existing runtime requirement of one script, not added by
this change.** `skills/writing-skills/render-graphs.js` shells out to the
`dot` binary; the repository does not vendor it, does not declare it in
`package.json`, and after this change no automated check requires it. The
version present on the machine where this design was measured is
`graphviz version 14.1.4 (20260321.0153)`, reported by `dot -V`.

`jq` — already required by `scripts/bump-version.sh` before this change
(`scripts/bump-version.sh:31`, `jq -r "$jq_path" "$file"`). The `-e` flag
behaviour was measured in this checkout rather than cited from documentation;
see Codebase Findings 10.

No library, package, or service is added.

## Assumptions to Confirm

1. **Nobody uses `render-graphs.js` today.** The evidence is strong but
   negative: nothing in the repository invokes it, no SVG it produced is
   committed, and it has not run successfully since 2026-03-15. What cannot be
   searched is whether a human has been running it by hand from a checkout and
   silently working around the failure. Searched: `grep -rn 'render-graphs'`
   across `.sh`, `.yml`, `.json`, `.js`, `.mjs`; `find . -name '*.svg'`;
   `git log` on the file. **This assumption is why the design repairs rather
   than deletes** — deletion was the measured recommendation and the human
   partner chose repair on 2026-08-21.

2. **The happy path is verified only where Graphviz is installed.** On this
   machine it can be run; in CI it cannot, by `IR1`. A regression in SVG
   generation that a Graphviz-less run cannot see would reach `main`.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope | Resolved — cut once, from "fix and resurrect" to "repair only", after the five-month measurement | `AC1`–`AC14`, and the scope line under Problem 1 |
| Data and schema | Clear — no data store, no schema in this repository | — |
| Concurrency | Clear — three single-shot scripts, no shared state, no parallelism | — |
| Error handling | Resolved — the whole of Problems 2 and 3 is error handling that was missing | `AC2`, `AC8`, `AC11`, `AC12` |
| Observability | Resolved — the skipped assertion must announce itself, and the bump must fail loudly rather than half-succeed | `IR2`, `AC11` |
| Limits and edge cases | Resolved — Graphviz absent, manifest unparseable, manifest field missing | `AC2`, `AC11`, `AC12` |
| Security | Clear — the shell removal at `AC4` is defence in depth; the arguments are literals, so no injection path exists today | `AC4` |
| Dependencies | Resolved — no dependency added, and the design was rewritten once to keep it that way | `IR1`, `IR4`, `## External Dependencies` |
| Testing | Resolved — one suite per repaired script, each with a CI step, each proving its defect by difference | `AC5`, `AC6`, `AC7`, `AC13`, `AC14` |
| Terminology | Clear — no new term is introduced | — |

### Decision record

| Question | Answer | Recommendation given | Source |
|---|---|---|---|
| Why install Graphviz at all? | Do not. Repair the script without adding it anywhere automated | Delete the script entirely | `CLAUDE.md:52`, plus Codebase Finding 4 |
| Repair or delete? | Repair, minimally | Delete, on the same source | Human partner's decision, 2026-08-21 |
| Adopt the upstream's YAML manifest support? | No | No — all seven manifests are JSON | `.version-bump.json`, Codebase Finding 7 |
| Fix the missing-field case the upstream's preflight misses? | Yes | Yes — one character, and it closes the silent case | Codebase Findings 9 and 10 |
| Guard the worktree removal in prose or in a hook? | Prose now, hook recorded as a separate project | Prose | `IR3` |
| Does the new suite get a CI step? | Yes | Yes | Codebase Finding 12 |
