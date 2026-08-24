# Four defects found by consulting the upstream — Design

**Date:** 2026-08-21
**Route:** full process — production files across seven skills, two scripts and
one gate are touched.

## The request

Consulting `obra/superpowers` at `v6.3.0` surfaced four defects in this
repository. None of them is an upstream feature being adopted: each is a fault
in code this project already ships, which reading their diff made visible.
Their fixes are used as evidence that a fix exists, never as the reason to
make one.

**Three premises were tested during this design, and none of them survived as
first written.**

The first draft proposed installing Graphviz, adding it to CI, and porting the
upstream's 113-line suite. Measurement killed that outright — the tool has been
broken for over five months with nothing calling it, and
[`CLAUDE.md`](../../../CLAUDE.md), section "What does not belong here", forbids
depending on an external tool.

The second was keep-or-delete on that same script. Measurement recommended
deleting it; an earlier version of this document recorded the human partner
choosing repair, and that decision was **reversed on 2026-08-21** after the
evidence was reviewed item by item. This document now specifies deletion, which
is what the measurement recommended in the first place.

The third was the fix for the version bump. The upstream's `jq -er` was
adopted here without checking who else calls the function it changes; there are
three callers, and two of them want the tolerant behaviour. The correction is a
preflight local to the bump, not a change to the shared reader.

## Problem 1 — `render-graphs.js` does not load, and nothing uses it

`skills/writing-skills/render-graphs.js` — a path that no longer resolves,
because `AC1` below deletes it — extracts
` ```dot ` blocks from a skill's markdown and renders them to SVG by shelling
out to Graphviz. It cannot start: the file uses CommonJS `require` while
`package.json` declares the package an ES module (Codebase Finding 1). It has
been in that state since 2026-03-15 (Codebase Finding 2).

**Scope decided 2026-08-21: delete the script, do not repair it.** Nothing
invokes it, no output it would produce is under version control, and repairing
it would leave the project holding a script whose only real function requires
an external binary that no automated check may exercise — which is the exact
condition under which it broke silently for five months.

**What this deliberately does not touch.** The ten ` ```dot ` blocks across six
skills are not part of this problem and are not removed. They never depended on
the renderer: a model reads them as text, and the renderer existed to produce
SVG for a human to look at.
[`graphviz-conventions.dot`](../../../skills/writing-skills/graphviz-conventions.dot)
stays for the same reason — it is the style guide those blocks obey, read and
never executed. The measurement that questions whether the four graph-carrying
reference files earn their place is recorded in Codebase Finding 5 and is a
separate question from this one.

## Problem 2 — a destructive command with no guard, and a silent loss beside it

[`finishing-a-development-branch/SKILL.md`](../../../skills/finishing-a-development-branch/SKILL.md),
section "Step 7: Cleanup Workspace", instructs an agent to run
`git worktree remove`. Two distinct failures live there.

**The loud one.** Git refuses that command when the worktree holds modified or
untracked files, **and its own error message names `--force` as the remedy**
(Codebase Finding 6).
The skill says nothing about the refusal, so the only instruction on screen at
that moment is git's, and it points at the destructive option. `--force`
deletes files that exist in no other place — including a run's
`<workspace>/progress.md` ledger, which
[`resuming.md`](../../../skills/subagent-driven-development/references/resuming.md)
calls the recovery map.

**The silent one, which no part of the original finding covered.** A file
ignored by `.gitignore` produces **no refusal at all**: `git worktree remove`
exits 0 and takes it. `.env` files, local credentials and build output are lost
on the happy path, with no error and no `--force` involved. The detection
command the first draft of this spec proposed — `status --porcelain -uall` —
cannot see that class.

**Scope decided 2026-08-21.** `--force` is prohibited outright, with no
authorisation path. Untracked content gets a rescue that costs nothing; ignored
content gets a report, because no agent can tell `.env` from `node_modules`.

## Problem 3 — a version bump that writes before it reads

[`bump-version.sh`](../../../scripts/bump-version.sh) walks seven declared
manifests and writes each one as it goes. A manifest it cannot read is
discovered mid-write, leaving the repository holding two different versions. A
manifest missing its declared field is not discovered at all — the bump creates
the field and exits 0.

**Scope decided 2026-08-21: a preflight local to the bump, not `jq -er` in the
shared reader.** The upstream's one-character fix works, and it also reaches
`--check` and `--audit`, which are diagnostics and must stay tolerant. The root
is not the permissive read; it is the loop that interleaves reading and
writing.

## Problem 4 — every review seat can spawn another one

No reviewer prompt and no worker prompt in this repository says that dispatch
is not its job. The rule exists — `using-superpowers/SKILL.md`, section "Review
Lives in the Gates", carries *"Between them, do not dispatch a review subagent
on your own initiative"* — and the same file opens with a `<SUBAGENT-STOP>`
block telling any subagent dispatched for a specific task to ignore the skill.

Every reviewer and the implementer **are** subagents dispatched for a specific
task. The one rule in this repository governing review dispatch is, by
construction, unreadable by everyone who can violate it.

**This is a reach failure, not an architecture failure.** The dispatch graph is
already correct: level 0 owns every seat (Codebase Finding 11). What is missing
is the other half of the rule — that whoever is inside a gate does not open
another one — stated where it can be read.

## Acceptance Criteria

### Problem 1 — deletion

- **AC1** — `skills/writing-skills/render-graphs.js` does not exist, and the
  **"Visualizing for your human partner" passage** that documents it — the last
  paragraph of
  [`writing-skills/SKILL.md`](../../../skills/writing-skills/SKILL.md), section
  "Flowchart Usage" — is gone with it.
- **AC2** — No file outside the historical record references the script. The
  two changelog lines that do ([`CHANGELOG.md`](../../../CHANGELOG.md), section "[1.0.0] - 2026-08-02", `RELEASE-NOTES.md:860`) are
  a record of past decisions and are not edited.
- **AC3** — `graphviz-conventions.dot`, the ten ` ```dot ` blocks, and the
  **rest of "Flowchart Usage"** — the when-to-use-a-flowchart rules and the
  pointer to the style guide, which are a different part of the same section
  from the passage `AC1` removes — are unchanged.

### Problem 2 — the worktree guard

- **AC4** — Before running `git worktree remove`, the skill runs
  `git -C "$WORKTREE_PATH" status --porcelain -uall --ignored` and reads the
  result. The `--ignored` flag is required: without it the silent class is
  invisible.
- **AC5** — The skill states that `--force` is never passed to
  `git worktree remove` on the agent's own initiative, in any circumstance, and
  offers no authorisation path that would make it permissible.
- **AC6** — Where the listing shows entries but none of them ignored (`??` for
  untracked, ` M` for modified — **corrected during execution: a modified
  tracked file reports ` M`, never `??`, measured in a scratch repository, and
  it refuses the removal with exit 128 exactly as an untracked one does; this
  criterion originally wrote "untracked or modified entries (`??`)", which left
  a worktree holding only modified files matching no row of the table at all**),
  the skill offers the rescue —
  `git -C "$WORKTREE_PATH" stash push -u -m "<branch> <date>"` — and states that
  the removal proceeds without `--force` once it is taken, with nothing lost.
- **AC7** — Where the listing shows ignored entries (`!!`), the skill does
  **not** stash them and does not remove: it presents the list and waits. The
  stated reason is that an agent cannot distinguish `.env` from `node_modules`,
  and `stash push -a` would sweep both.
- **AC8** — If `git worktree remove` is refused for any reason, the skill stops,
  reports, and leaves the worktree in place. That is a valid outcome, not a
  failure to work around.
- **AC9** — The `## Common Rationalizations` table in that file carries a row
  for treating the refusal as cleanup to be forced through.

### Problem 3 — the version bump

- **AC10** — `cmd_bump` validates every declared manifest's field before writing
  to any manifest, and exits non-zero having written nothing when validation
  fails.
- **AC11** — A manifest whose declared field is absent fails that preflight, not
  only a manifest that cannot be parsed.
- **AC12** — `read_json_field` is not modified, and `--check` and `--audit`
  continue to report every manifest rather than aborting at the first one that
  cannot be read.
- **AC13** — `tests/version-bump/test-bump-version.sh` exists and proves `AC10`
  and `AC11` by difference: with one manifest broken, no declared manifest's
  version changes, and with every manifest well formed the bump still succeeds.

### Problem 4 — the dispatch prohibition

- **AC14** — Each of the seven carriers listed in Codebase Finding 12 states
  that the agent reading it performs its own work and dispatches no subagent,
  naming the mechanism: the controller owns every review seat, so a seat this
  agent creates duplicates one of them.
- **AC15** — `scripts/check-no-dispatch.sh` exists and fails when any declared
  carrier has lost the clause. Its carrier list is declared in the script, not
  discovered by globbing — a carrier that silently lost the form has to be
  distinguishable from a file that never had it.
- **AC16** — The clause does not alter what any face reviews. The four scopes in
  [`docs/review-scopes.md`](../../../docs/review-scopes.md), section "What each
  face runs", are untouched.

### Shared

- **AC17** — `.github/workflows/ci.yml` gains a step for each suite this change
  creates: `tests/version-bump/` and `scripts/check-no-dispatch.sh` (Codebase
  Finding 16).
- **AC18** — [`lint-shell.sh`](../../../scripts/lint-shell.sh) passes over the
  shell files this change creates. It runs in CI over the pushed range and fires
  here **because** this change adds its inputs — a different assertion from the
  gates in `IR5`, which the change merely must not break.
- **AC19** — [`CHANGELOG.md`](../../../CHANGELOG.md) gains an entry under
  "Open gaps" recording the deferred `PreToolUse` hook of `IR2`, naming what it
  would guard and why it was deferred.

## Implicit Requirements

- **IR1** — No project dependency is added, and after this change no automated
  check requires Graphviz (Codebase Finding 3 measures that nothing invokes the
  script; Codebase Finding 15 is the policy that makes it a requirement). (There is no lockfile in this checkout, so "the
  lockfile is untouched" would be a criterion that cannot fail; it is
  deliberately not stated.)
- **IR2** — **The `AC5` prohibition is prose in a skill, which is mitigation
  with a known ceiling, not a closed case.** A hook is the only layer that holds
  regardless of what an agent decides, and deleting untracked files is
  irreversible. Building one is deferred deliberately: it would be this
  plugin's first `PreToolUse`, distributed to everyone who installs it, which is
  a product decision rather than a defect repair. **The gap is not recorded
  yet** — `AC19` is what records it, under "Open gaps" in
  [`CHANGELOG.md`](../../../CHANGELOG.md), so this requirement is delivered by
  the work rather than asserted by this document.
- **IR3** — The clause of `AC14` is copied into each carrier rather than
  extracted into one file with pointers. This inverts the ordinary rule and the
  inversion is measured, not preferred: see
  [`docs/review-scopes.md`](../../../docs/review-scopes.md), section "Why the
  form is copied rather than extracted". `AC15` is what keeps "unified in place"
  from being merely "copied".
- **IR4** — The upstream's YAML manifest support is not adopted. All seven
  manifests declared in `.version-bump.json` are JSON.
- **IR5** — The gates this change must not break stay green:
  [`check-links.sh`](../../../scripts/check-links.sh),
  [`check-changelog.sh`](../../../scripts/check-changelog.sh),
  [`check-docs-sync.sh`](../../../scripts/check-docs-sync.sh),
  [`check-skill-size.sh`](../../../scripts/check-skill-size.sh),
  [`check-escalation-shape.sh`](../../../scripts/check-escalation-shape.sh),
  [`check-evidence-line.sh`](../../../scripts/check-evidence-line.sh),
  [`check-frozen-history.sh`](../../../scripts/check-frozen-history.sh),
  [`check-skill-behavior-records.sh`](../../../scripts/check-skill-behavior-records.sh).
  Two gates fire *because* this change feeds them and carry their own criteria
  instead of hiding inside this one: `lint-shell.sh` is `AC18`, and
  `check-changelog.sh` — whose `CONTENT_PREFIXES` are
  `(skills/ scripts/ githooks/ .github/ hooks/)` (`scripts/check-changelog.sh:49`),
  three of which this change stages — is `IR6`.
- **IR6** — Every commit that stages a path under `skills/`, `scripts/` or
  `.github/` carries its `CHANGELOG.md` entry in the same commit. This is a
  property of how the work is committed, checked against the index at commit
  time and evidenced by a green commit, not settled by opening a line of the
  tree.
- **IR7** — Deleting `render-graphs.js` removes the only *executable* consumer
  of Graphviz in this repository. One optional manual `dot -Tsvg` step survives
  in a frozen plan document
  (`docs/superpowers/plans/2026-07-15-sdd-fix-loop-redesign.md:816`); it is a
  historical record, runs nothing, and is not edited. No criterion asks for a
  Graphviz step anywhere, and none should be added later on the grounds that the
  binary is present on a developer's machine.

## Codebase Findings

Every claim below was measured in this checkout on 2026-08-21, at `f575958`,
unless it is marked as a third party's measurement.

1. **The script cannot start.** `skills/writing-skills/render-graphs.js:16` —
   `const fs = require('fs');` — against `package.json:5` — `"type": "module"`.
   Measured from the repository root:
   `node skills/writing-skills/render-graphs.js skills/subagent-driven-development`
   exits `1` with `ReferenceError: require is not defined in ES module scope`.
   The module fails to load before any argument is read, so any argument
   reproduces it.

2. **How long, and who noticed.** `render-graphs.js` was added in `28ba020` and
   has not been modified since; `"type": "module"` arrived on 2026-03-15 in
   `911fa1d`, a commit about the opencode plugin test whose author had no reason
   to open this file. `git ls-files '*.svg'` returns exactly one file,
   `assets/superpowers-small.svg`, which is the project logo and not `dot`
   output. `git ls-files | grep -c 'diagrams/'` returns `0` — the output
   directory the script creates has never been committed.

3. **Nothing invokes it.** `grep -rn 'render-graphs' --exclude-dir=.git .`
   returns the script's own usage text, its documentation at
   `skills/writing-skills/SKILL.md:331-334`, two historical changelog lines
   ([`CHANGELOG.md`](../../../CHANGELOG.md), section "[1.0.0] - 2026-08-02", `RELEASE-NOTES.md:860`), and this specification. A
   search restricted to `tests/`, `scripts/`, `.github/`, `hooks/` and
   `githooks/` returns nothing.

4. **Two further faults in the same file, recorded because deletion makes them
   moot rather than because they are being fixed.**
   `skills/writing-skills/render-graphs.js:112` probes with
   `execSync('which dot')`, and `which` is not a command on Windows;
   `:72` passes `dot -Tsvg` through a shell for no reason. Neither is a
   vulnerability — the arguments are literals.

5. **The graph-carrying reference files are read far less than the inline
   blocks, and this is why they are not part of Problem 1.** Ten ` ```dot `
   blocks exist across six skills. Five are inline in a `SKILL.md` and reach the
   model whenever the skill loads. Four sit in reference files that only reach it
   if something opens them, and a count of `Read` calls across this machine's
   Claude Code transcripts shows, for the user's own project directories:
   `brainstorming/references/process-flow.md` **2**;
   `subagent-driven-development/references/process-graph.md` **0**;
   `systematic-debugging/references/root-cause-tracing.md` **0**;
   `systematic-debugging/references/condition-based-waiting.md` **0**. Every
   read of `process-graph.md` on this machine is inside this repository or a
   `/tmp/superpowers-tests-*` fixture. **The denominator is not trustworthy** —
   a session count keyed on the string `superpowersplus:brainstorming` counts
   every session, because the bootstrap contains it — so the zeros are the
   finding and the ratio is not. Whether those four files earn their place is a
   separate question with its own evidence, deliberately not decided here.

6. **The refusal, and the remedy git itself suggests.** Measured in a scratch
   repository: a worktree holding one untracked file makes
   `git worktree remove` exit `128` with
   `fatal: '../wt' contains modified or untracked files, use --force to delete it`.
   The file survives. The refusal is safe; the message names the unsafe way
   past it.

7. **The silent class.** Same harness, one file matched by `.gitignore` and
   nothing else: `git worktree remove` exits `0` and the file is gone. Measured
   in the same repository, `git status --porcelain -uall` reports only
   `?? notas.md` while `git status --porcelain -uall --ignored` reports
   `?? notas.md` and `!! ignorado.log`.

8. **The rescue works, and its limit is measured too.**
   `git stash push -u` in the worktree, then `git worktree remove`, exits `0`,
   and `git stash show -p --include-untracked stash@{0}` returns the file
   afterwards — the stash lives in the common repository, not in the removed
   directory. `stash push -u` leaves ignored files behind; `stash push -a`
   takes them, which is why `AC7` does not use it: in a real checkout `-a`
   would sweep `node_modules/`, `.venv/` and `dist/` into a stash.

9. **The bump writes as it walks, and both failures were reproduced with the
   real script.** `scripts/bump-version.sh:178-188` reads a field and writes it
   inside the same iteration; `:11` sets `set -euo pipefail`. In a scratch
   repository declaring three manifests: with the middle one holding
   unparseable JSON, exit `5`, the first manifest at the new version and the
   third at the old one. With the middle one missing its declared field, exit
   `0`, the line `b.json (version)  null -> 2.0.0` printed as a success, and the
   field created in a manifest that never had it. (An exit code of `141` in an
   earlier run of this measurement was `SIGPIPE` from a `head` in the measuring
   command, not the script.)

10. **`read_json_field` has three callers, which is why the upstream's fix is
    not adopted verbatim.** `scripts/bump-version.sh:71` inside `cmd_check`,
    `:104` inside `cmd_audit`, `:185` inside `cmd_bump`. `jq -r '.version'` on a
    manifest lacking the field prints `null` and exits `0`; `jq -er` prints
    `null` and exits `1`. Under `set -euo pipefail` that turns `--check` — whose
    job is to list all seven and report drift — into a command that aborts at
    the first unreadable manifest.

11. **The dispatch graph, and where the rule stops.**
    Level 0 dispatches every review seat: `brainstorming/SKILL.md:40` and `:255`
    the spec reviewer, `writing-plans/SKILL.md:372` the plan reviewer,
    `subagent-driven-development/SKILL.md` the implementer, the task reviewer and
    the re-review, `final-branch-audit/SKILL.md:27` the auditor (dispatched by
    that skill), `requesting-code-review/SKILL.md` the code reviewer. Level 1 is
    the implementer and six reviewers. `using-superpowers/SKILL.md:6-8` is a
    `<SUBAGENT-STOP>` block; `:37` is the dispatch rule. A grep for
    `do not dispatch|no subagent|not dispatch` across the six prompt files
    returns **nothing at all** — exit 1, zero matches. **An earlier revision of
    this finding reported that it returned the files' own "Use this template
    when dispatching…" headers, which is false**: those headers match only a
    broader pattern (`dispatch.*subagent`) that was run during exploration and
    then narrowed when written down. Two searches described as one — the same
    fault this document's Problem 4 is about, committed inside the finding that
    reports it.

12. **The seven carriers of `AC14`.**
    `skills/subagent-driven-development/implementer-prompt.md` — whose
    `## Before Reporting Back: Self-Review` at `:109` is the phrase the upstream
    measured being reified into a subagent —
    `task-reviewer-prompt.md`, `re-review-prompt.md`,
    `skills/requesting-code-review/code-reviewer.md`,
    `skills/brainstorming/spec-document-reviewer-prompt.md`,
    `skills/writing-plans/plan-document-reviewer-prompt.md`, and
    `skills/final-branch-audit/SKILL.md`. The last three have no counterpart in
    the upstream's four-file change.

13. **The upstream's measurement, which is theirs and not this project's.**
    `b36e082`, `docs/superpowers/specs/2026-07-30-codex-efficiency-fixes-design.md`:
    9 of 9 depth-2 spawns across 4 corpora were implementer-issued reviewers,
    and all 9 duplicated the review the controller dispatches anyway. They
    describe their wording as harness-agnostic and a no-op where children cannot
    spawn; their corpus is Codex. This plugin packages for Codex
    (`.codex-plugin/`), so the measured harness is one it supports — but no
    equivalent measurement was taken here.

14. **Room in the files being edited.**
    `skills/finishing-a-development-branch/SKILL.md` is 258 lines and
    `scripts/check-skill-size.sh:34` sets `MAX=500`, with `:43` exempting only
    `skills/writing-skills/SKILL.md`. The seven carriers of `AC14` run from 140
    to 368 lines — `re-review-prompt.md` at 140 and
    `final-branch-audit/SKILL.md` at 368, the rest between — room that `AC9` and
    `AC14` need, with the largest still 132 lines under the ceiling. **An
    earlier revision of this finding said "140 to 250", which was the range of
    five carriers measured before the list grew to seven; the count was not
    re-taken when it did.** No gate reads the body of a
    skill for literal phrases, so new
    prose breaks nothing: the only scripts doing literal `grep` over tracked
    content are `check-changelog.sh`, `check-frozen-history.sh` and
    `check-docs-sync.sh`, none of which reads a skill body.

15. **The dependency policy this design obeys.**
    [`CLAUDE.md`](../../../CLAUDE.md), section "What does not belong here" —
    "**Third-party dependencies.** This is a zero-dependency plugin. A change
    needing an external tool or service belongs in its own plugin."

16. **The rule that puts the suites in CI.**
    [`CLAUDE.md`](../../../CLAUDE.md), section "Where the rest lives" —
    "**Add a suite, add its CI step.**"

## External Dependencies

**None after this change.** Deleting `render-graphs.js` removes the only file in
this repository that shells out to Graphviz. `jq` was already required by
`scripts/bump-version.sh` before this change (`scripts/bump-version.sh:31`) and
that does not change: the preflight of `AC10` uses the `jq` already in use. Its
`-e` behaviour was measured in this checkout rather than cited from
documentation; see Codebase Finding 10.

No library, package, or service is added.

## Assumptions to Confirm

1. **Nobody runs `render-graphs.js` by hand.** The evidence is negative but
   consistent and set out in Codebase Findings 2 and 3: no caller, no committed
   output, and no successful run possible since 2026-03-15. What no search
   reaches is whether a human has been running it from a checkout and working
   around the failure in silence. Its falsification is the only thing that would
   argue against deletion.

2. **`git stash push -u` is available and behaves the same across the git
   versions this plugin's users run.** Measured on this machine only. The
   rescue of `AC6` degrades safely if it is not — the stash fails, nothing is
   removed, and `AC8` takes over.

3. **The clause of `AC14` is a no-op on harnesses where a subagent cannot
   dispatch.** Taken from the upstream's own description of their wording
   (Codebase Finding 13), not measured here. If it is wrong, the cost is a few
   lines of prose that never fire.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope | Resolved — cut twice: from "fix and resurrect" to "repair only", then from repair to deletion once the five-month measurement was reviewed item by item. Problem 4 delivers one clause in seven carriers (`AC14`), bounded so it changes no face's scope (`AC16`) and copied rather than extracted for a measured reason (`IR3`) | `AC1`–`AC3`, `AC14`, `AC16`, `IR3`, and the scope lines under each Problem |
| Data and schema | Clear — no data store, no schema in this repository | — |
| Concurrency | Clear — two single-shot scripts and prose changes, no shared state, no parallelism | — |
| Error handling | Resolved — Problems 2 and 3 are entirely error handling that was missing, and the refusal gets a rationalization row so the pressure case is answered where it is felt (`AC9`) | `AC4`–`AC11` |
| Observability | Resolved — the bump fails loudly instead of half-succeeding, the worktree listing is shown to the human partner rather than inferred, the diagnostics keep reporting every manifest instead of aborting at the first (`AC12`), and the one thing this change decides not to build is written down where it will be found (`AC19`) | `AC4`, `AC8`, `AC10`, `AC12`, `AC19` |
| Limits and edge cases | Resolved — refusal, the ignored class that produces no refusal, manifest unparseable, manifest field missing | `AC4`, `AC7`, `AC10`, `AC11` |
| Security | Resolved by deletion — the needless shell of Codebase Finding 4 leaves with the file. `AC7` keeps `.env` out of a stash and out of a deletion | `AC1`, `AC7` |
| Dependencies | Resolved — the last Graphviz consumer is deleted and no dependency is added | `IR1`, `IR4`, `IR7` |
| Testing | **Partly resolved, and the gaps are named.** Problem 3 gets a suite proving its defect by difference (`AC13`); Problem 4 gets a gate (`AC15`). **Problems 1 and 2 carry no test.** Problem 1 is a deletion — its evidence is a grep, and a suite asserting a file's absence would pass for the wrong reason forever after. Problem 2 adds prose no gate reads: `check-skill-size.sh` measures length and `check-evidence-line.sh` reads a different form in the same file. This repository has `tests/skill-behavior/` for the "does the rule hold under pressure" question, and no criterion here asks for one — a deliberate omission, recorded rather than left to be discovered. **`IR2` names the ceiling this leaves on Problem 2** — prose is mitigation, not a guarantee, and `AC19` is what keeps the deferred hook findable | `AC13`, `AC15`, `AC17`, `AC18`, `IR2`, `AC19`; Problems 1 and 2: no suite |
| Terminology | Clear — no new term is introduced | — |

**`IR5` and `IR6` are in no row above, and that is not an omission.** The map
has one row per design category; those two are process guardrails — what must
stay green, and how the work is committed. No design category owns them.

### Decision record

| Question | Answer | Recommendation given | Source |
|---|---|---|---|
| Why install Graphviz at all? | Do not | Delete the script entirely | [`CLAUDE.md`](../../../CLAUDE.md), section "What does not belong here", plus Codebase Findings 2 and 3 |
| Repair or delete `render-graphs.js`? | **Delete** | Delete, on the same evidence | Measurement and human partner agree, 2026-08-21; an earlier revision of this document recorded repair and was reversed |
| Delete the ` ```dot ` blocks too? | No — they never depended on the renderer, and five of the ten load with their skill | Keep; the four reference-file blocks are a separate question with its own evidence | Codebase Finding 5 |
| Guard the worktree removal in prose or in a hook? | Prose now, hook deferred and **recorded as an open gap** | Hook, on the "irreversible error belongs in a hook" rule; prose accepted because a first `PreToolUse` is a product decision | `IR2` |
| Rescue untracked files, or just refuse to remove? | Rescue with `stash push -u`, then remove without `--force` | Rescue — measured to lose nothing | Codebase Finding 8 |
| Rescue ignored files the same way? | No — report and wait | Report; `stash push -a` would sweep `node_modules` | Codebase Findings 7 and 8, `AC7` |
| Adopt `jq -er` in `read_json_field`? | **No** — preflight local to `cmd_bump` | Preflight; `-er` would make `--check` abort at the first bad manifest | Codebase Finding 10 |
| Adopt the upstream's YAML manifest support? | No | No — all seven manifests are JSON | `.version-bump.json` |
| The upstream's six-line dispatch section, or one line? | **One line**, in seven carriers | One line — the rule is absolute, and what makes a model obey is the clause being in the prompt it is reading, not the paragraph justifying it | `AC14`, Codebase Finding 12 |
| Four carriers like the upstream, or seven? | Seven | Seven — the marginal cost is one line each, and the defect being fixed is a rule that failed to reach someone | Codebase Finding 12 |
| Does the dispatch clause need a gate? | Yes | Yes — without one, "unified in place" is "copied" | [`docs/review-scopes.md`](../../../docs/review-scopes.md), section "Why the form is copied rather than extracted" |
