# Upstream Consult Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowersplus:subagent-driven-development or superpowersplus:executing-plans to implement this plan task-by-task — the `**Execution:**` field below names which of the two this plan was handed to, and that is the one to follow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md`

**Goal:** Repair four defects that consulting `obra/superpowers` at `v6.3.0` made visible in this repository — a dead script, an unguarded destructive command, a version bump that writes before it reads, and a review-dispatch rule that cannot be read by anyone who can violate it.

**Architecture:** Four independent repairs sharing no state. One deletion, one prose guard in a skill, one shell preflight with its own suite, and one clause copied into seven carriers with a gate that charges it. The gate is built and proven failing before the clause exists, so its pass is a difference and not an assertion.

**Tech Stack:** No new technology. `bash` and `python3` for the gate, matching [`check-escalation-shape.sh`](../../../scripts/check-escalation-shape.sh) which is bash wrapping a `python3` heredoc; `jq`, already required by `scripts/bump-version.sh:31`. No entry is new to this repository — the spec's `## External Dependencies` states none is added.

**Execution:** `inline` — superpowersplus:executing-plans, in this session. Progress is recorded in session todos (not persisted); the durable record is the per-task commit, so a plan picked up after an interruption is resumed by reading `git log` against the task list below.

**Escalation shape** (detail and a worked example: `../../../skills/using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it. A gate verdict name (`LOST IN TRANSLATION`, `INVENTED SCOPE`, …) appears only in parentheses, never carrying the explanation.

## Global Constraints

- **Zero dependencies.** No library, package, or service is added (`IR1`). `package.json` gains nothing.
- **No Graphviz anywhere automated** (`IR7`). Task 1 removes this repository's only executable consumer of it; no criterion may reintroduce one.
- **`read_json_field` is not modified** (`AC12`). `--check` and `--audit` keep reporting every manifest rather than aborting at the first unreadable one.
- **The four review scopes do not move** (`AC16`). What each face runs, in [`docs/review-scopes.md`](../../../docs/review-scopes.md) section "What each face runs", is untouched.
- **No YAML manifest support** (`IR4`). All seven manifests in `.version-bump.json` are JSON and stay so.
- **Every commit staging `skills/`, `scripts/`, `githooks/`, `.github/` or `hooks/` carries its `CHANGELOG.md` entry in the same commit** (`IR6`), enforced by `scripts/check-changelog.sh:49`.
- **These gates stay green** (`IR5`): `check-links.sh`, `check-changelog.sh`, `check-docs-sync.sh`, `check-skill-size.sh`, `check-escalation-shape.sh`, `check-evidence-line.sh`, `check-frozen-history.sh`, `check-skill-behavior-records.sh`.
- **`CHANGELOG.md:4280` and `RELEASE-NOTES.md:860` are never edited** (`AC2`). They are historical record.

## Test Coverage Matrix

**Conventions read from this repository, not imported.** Gate scripts are tested by `tests/hooks/test-check-*.sh` (seven of them, each its own CI step at `.github/workflows/ci.yml:60-77`); a non-gate script is tested by its own directory, the pattern of `tests/shell-lint/test-lint-shell.sh` (`.github/workflows/ci.yml:54-55`). Every suite is a separate CI step — `CLAUDE.md`, section "Where the rest lives": "Add a suite, add its CI step." There is no coverage tool and no unit-test framework in this repository; suites are bash scripts that build throwaway trees and assert on exit codes.

**Two criteria carry no automated test, and both are declared in the spec rather than discovered here.** The spec's Coverage Map, row "Testing", records that Problem 1 is a deletion whose evidence is a grep — a suite asserting a file's absence would pass for the wrong reason forever after — and that Problem 2 adds prose no gate reads. They are marked `grep` and `none` below, and `T2` rows carry the ceiling `IR2` names.

| Criterion | Spec criterion | Test type | Layer | Test |
|-----------|----------------|-----------|-------|------|
| T1.1 The script and its documentation are gone | AC1 | grep | — | Step 5 of Task 1: `grep -rn 'render-graphs' --exclude-dir=.git .` returns only the two historical lines and this plan |
| T1.2 The historical record is untouched | AC2 | gate | `scripts/` | Step 6 of Task 1: `git diff --cached --name-only` contains neither `CHANGELOG.md:4280`'s file as a content edit to that line nor `RELEASE-NOTES.md` |
| T1.3 The style guide and every `dot` block survive | AC3 | grep | — | Step 5 of Task 1: `grep -rc '```dot' skills/` totals 10, and `graphviz-conventions.dot` exists |
| T1.4 No automated check requires Graphviz | IR7, IR1 | grep | — | Step 5 of Task 1: `grep -rn 'dot -T\|graphviz' scripts/ tests/ .github/ hooks/ githooks/` returns nothing |
| T2.1 The listing command includes `--ignored` | AC4 | none — prose | `skills/` | No test. Declared in the spec's Coverage Map, row "Testing" |
| T2.2 `--force` is prohibited with no authorisation path | AC5 | none — prose | `skills/` | No test. Same declaration |
| T2.3 The untracked rescue is named and its outcome stated | AC6 | none — prose | `skills/` | No test. Same declaration |
| T2.4 Ignored entries stop the removal instead of being stashed | AC7 | none — prose | `skills/` | No test. Same declaration |
| T2.5 A refusal leaves the worktree in place | AC8 | none — prose | `skills/` | No test. Same declaration |
| T2.6 The rationalization table carries the row | AC9 | none — prose | `skills/` | No test. Same declaration |
| T2.7 The deferred hook is recorded under "Open gaps" | AC19 | gate | `scripts/` | Step 7 of Task 2: `scripts/check-links.sh` passes with the new entry, and `grep -n 'PreToolUse' CHANGELOG.md` finds it under `## Open gaps` |
| T3.1 A manifest that cannot be parsed leaves every version unchanged | AC10 | unit (shell) | `tests/version-bump/` | `tests/version-bump/test-bump-version.sh` — case "unparseable manifest writes nothing" |
| T3.2 A manifest missing its declared field fails the same way | AC11 | unit (shell) | `tests/version-bump/` | `tests/version-bump/test-bump-version.sh` — case "missing field writes nothing" |
| T3.3 A well-formed run still bumps every manifest | AC13 | unit (shell) | `tests/version-bump/` | `tests/version-bump/test-bump-version.sh` — case "all well formed still succeeds" |
| T3.4 `--check` still reports every manifest when one is unreadable | AC12 | unit (shell) | `tests/version-bump/` | `tests/version-bump/test-bump-version.sh` — case "check stays tolerant" |
| T3.5 The suite has a CI step | AC17 | gate | `.github/` | Step 9 of Task 3: `grep -n 'tests/version-bump' .github/workflows/ci.yml` |
| T3.6 The new shell passes the lint | AC18 | gate | `scripts/` | Step 8 of Task 3: `scripts/lint-shell.sh` over the new file |
| T4.1 The gate fails when a declared carrier lacks the clause | AC15 | unit (shell) | `tests/hooks/` | `tests/hooks/test-check-no-dispatch.sh` — case "a carrier missing the clause fails" |
| T4.2 The gate passes when every declared carrier has it | AC15 | unit (shell) | `tests/hooks/` | `tests/hooks/test-check-no-dispatch.sh` — case "all carriers present passes" |
| T4.3 The carrier list is declared, not globbed | AC15, IR3 | unit (shell) | `tests/hooks/` | `tests/hooks/test-check-no-dispatch.sh` — case "an undeclared file with the clause is ignored" |
| T4.4 The gate and its suite have CI steps | AC17 | gate | `.github/` | Step 10 of Task 4: `grep -n 'check-no-dispatch' .github/workflows/ci.yml` |
| T4.5 The new shell passes the lint | AC18 | gate | `scripts/` | Step 9 of Task 4: `scripts/lint-shell.sh` over the two new files |
| T5.1 All seven carriers carry the clause | AC14 | unit (shell) | `tests/hooks/` | `tests/hooks/test-check-no-dispatch.sh` run against the real tree — the same suite from Task 4, now passing where it failed |
| T5.2 No review scope changed | AC16 | grep | — | Step 5 of Task 5: `git diff` touches no line of the four sections named in `docs/review-scopes.md` "What each face runs" |
| T5.3 No manifest gained a YAML entry | IR4 | grep | — | Step 5 of Task 5: `jq -r '.files[].path' .version-bump.json` returns seven paths, all ending `.json` |

**`IR5` and `IR6` are in no row, and neither is an omission.** Both are properties of how each task commits rather than behaviors to test, and the same mechanism evidences them: `githooks/pre-commit` runs `check-docs-sync.sh`, `check-frozen-history.sh`, `check-changelog.sh`, `check-links.sh`, `check-skill-size.sh`, `check-evidence-line.sh` and `check-escalation-shape.sh` on every commit, so a task that commits green has run them. `check-skill-behavior-records.sh` is the one gate of `IR5` outside that hook; no task in this plan touches `tests/skill-behavior/`, which is what it reads. Every task's commit step stages `CHANGELOG.md`, which is `IR6`.

---

### Task 1: Delete the dead renderer

**Spec criterion:** `AC1`, `AC2`, `AC3`, `IR7`

**Files:**
- Delete: `skills/writing-skills/render-graphs.js`
- Modify: `skills/writing-skills/SKILL.md:331-335`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing. No later task depends on this one; it is first because it is the smallest.

**Acceptance criteria:**
- T1.1: `skills/writing-skills/render-graphs.js` does not exist, and the "Visualizing for your human partner" paragraph is gone from `skills/writing-skills/SKILL.md` — test: Step 5's grep
- T1.2: `CHANGELOG.md:4280` and `RELEASE-NOTES.md:860` are unedited — test: Step 6's staged-file check
- T1.3: `graphviz-conventions.dot` exists and `skills/` still holds ten ` ```dot ` blocks — test: Step 5's counts
- T1.4: No script, test, workflow or hook references Graphviz — test: Step 5's grep

- [ ] **Step 1: Confirm the file is dead before deleting it**

```bash
node skills/writing-skills/render-graphs.js skills/subagent-driven-development; echo "exit=$?"
git ls-files '*.svg'
git ls-files | grep -c 'diagrams/'
```

Expected: `ReferenceError: require is not defined in ES module scope` and `exit=1`; one SVG, `assets/superpowers-small.svg`; `0` for `diagrams/`.

- [ ] **Step 2: Delete the script**

```bash
git rm skills/writing-skills/render-graphs.js
```

- [ ] **Step 3: Remove the passage that documents it**

Open `skills/writing-skills/SKILL.md`. Delete these five lines, which are the last paragraph of the "Flowchart Usage" section, immediately before `## Code Examples`:

````markdown
**Visualizing for your human partner:** Use `render-graphs.js` in this directory to render a skill's flowcharts to SVG:
```bash
./render-graphs.js ../some-skill           # Each diagram separately
./render-graphs.js ../some-skill --combine # All diagrams in one SVG
```
````

**Leave the line above it untouched** — `See \`graphviz-conventions.dot\` in this directory for graphviz style rules.` is the pointer `AC3` preserves.

**Delete the blank line that preceded the passage along with it.** Lines 330 and 336 are both blank; removing only 331–335 leaves the two adjacent, so `## Code Examples` ends up after a double blank. Delete 330–335 and the section closes with one blank line, as it does everywhere else in the file.

- [ ] **Step 4: Write the changelog entry**

Add under `### Removed` in `[Unreleased]` in `CHANGELOG.md` (create the subsection if it is absent, after `### Fixed`):

```markdown
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
```

- [ ] **Step 5: Verify the deletion and what it must not have touched**

```bash
grep -rn 'render-graphs' --exclude-dir=.git . | grep -v '^./docs/superpowers/'
echo "--- dot blocks (expect 10) ---"
grep -rc '```dot' skills/ --include='*.md' | awk -F: '{s+=$2} END {print s}'
echo "--- style guide present ---"
ls skills/writing-skills/graphviz-conventions.dot
echo "--- no automated Graphviz consumer (expect empty) ---"
grep -rn 'dot -T\|graphviz' scripts/ tests/ .github/ hooks/ githooks/
```

Expected: the first grep returns only `CHANGELOG.md` lines (the historical one at `:4280` and the new entry) and `RELEASE-NOTES.md:860`; the block count is `10`; the style guide lists; the last grep returns nothing.

- [ ] **Step 6: Stage and confirm the historical record is untouched**

```bash
git add skills/writing-skills/SKILL.md CHANGELOG.md
git diff --cached --stat
git diff --cached CHANGELOG.md | grep -c '^-' 
```

Expected: three files in the stat (`render-graphs.js` deleted, `SKILL.md`, `CHANGELOG.md`); the count of removed lines in `CHANGELOG.md` is `0` — the entry is added, nothing is edited. `RELEASE-NOTES.md` must not appear at all.

- [ ] **Step 7: Commit**

```bash
git commit -m "remove(writing-skills): o renderizador não carregava desde março e ninguém percebeu"
```

---

### Task 2: Guard the worktree removal, and record what prose cannot hold

**Spec criterion:** `AC4`, `AC5`, `AC6`, `AC7`, `AC8`, `AC9`, `AC19`, `IR2`

**Files:**
- Modify: `skills/finishing-a-development-branch/SKILL.md:216-226` and its `## Common Rationalizations` table
- Modify: `CHANGELOG.md` — the entry, and one line under `## Open gaps`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing.

**Acceptance criteria:**
- T2.1: The skill runs `git -C "$WORKTREE_PATH" status --porcelain -uall --ignored` before removing — test: none, declared
- T2.2: The skill states `--force` is never the agent's own initiative, with no authorisation path — test: none, declared
- T2.3: The rescue `git -C "$WORKTREE_PATH" stash push -u -m "<branch> <date>"` is named, with its outcome — test: none, declared
- T2.4: Ignored entries stop the removal and are not stashed — test: none, declared
- T2.5: A refusal leaves the worktree in place as a valid outcome — test: none, declared
- T2.6: The `## Common Rationalizations` table carries the row — test: none, declared
- T2.7: `CHANGELOG.md`'s `## Open gaps` records the deferred `PreToolUse` hook — test: Step 7's grep plus `check-links.sh`

- [ ] **Step 1: Reproduce both failures so the text you write is grounded**

```bash
cd /tmp && rm -rf wtguard && mkdir wtguard && cd wtguard
git init -q repo && cd repo
git config user.email t@t && git config user.name t
echo tracked > a.txt && git add a.txt && git commit -qm base
printf 'ignored.log\n' > .gitignore && git add .gitignore && git commit -qm ign
git worktree add -q ../w1 -b b1 && echo secret > ../w1/ignored.log
echo "--- ignored only ---"; git worktree remove ../w1; echo "exit=$?"
git worktree add -q ../w2 -b b2 && echo keep > ../w2/notes.md
echo "--- untracked ---"; git worktree remove ../w2; echo "exit=$?"
```

Expected: the ignored-only case exits `0` and the file is gone with no message; the untracked case exits `128` with `fatal: '../w2' contains modified or untracked files, use --force to delete it`.

- [ ] **Step 2: Rewrite the cleanup block**

In `skills/finishing-a-development-branch/SKILL.md`, section "Step 7: Cleanup Workspace", replace the block that currently reads:

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

with:

````markdown
**Look before you remove — the loss you cannot see is the one that does not
refuse.** A file matched by `.gitignore` produces no refusal at all:
`git worktree remove` exits 0 and takes it, which is how a `.env` disappears
on the happy path. `--ignored` is what makes that class visible:

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall --ignored
```

| What the listing shows | What to do |
|---|---|
| Nothing | Remove and prune, below |
| Only `??` entries (untracked or modified) | Offer the rescue. `git -C "$WORKTREE_PATH" stash push -u -m "<branch> <date>"` moves them into the common repository's stash, where they survive the worktree's removal; the removal then succeeds with no `--force` and nothing is lost. Take it, then remove |
| Any `!!` entry (ignored) | **Stop.** Show the list and wait for your human partner. Do not stash them: `stash push -a` is what would take them, and in a real checkout it sweeps `node_modules/`, `.venv/` and `dist/` along with the `.env` that actually matters. You cannot tell those apart, and they cannot both be right |

**`--force` is never yours to pass.** Git's own refusal message names it —
`use --force to delete it` — and that is the one instruction on the screen at
the moment you want to move on. It deletes files that exist in no other place:
a run's `<workspace>/progress.md` ledger among them. There is no authorisation
path for it here, and asking for one is the rationalization below. If the
removal is refused for any reason, stop, report what the listing showed, and
leave the worktree standing. **A worktree left in place is a finished outcome,
not a task you failed to complete.**

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```
````

- [ ] **Step 3: Add the rationalization row**

In the same file's `## Common Rationalizations` table, after the row beginning `| "This other worktree looks stale`, add:

```markdown
| "`git worktree remove` refused — `--force` is what it says to use" | The refusal is the guard working, and the remedy git prints destroys files that exist nowhere else. Run the listing with `--ignored`, stash the untracked, and take anything ignored to your human partner. A worktree left standing costs a directory; `--force` costs whatever was in it. |
```

- [ ] **Step 4: Verify the file still fits its ceiling**

Run: `scripts/check-skill-size.sh`
Expected: PASS. The file was 258 lines against `MAX=500` (`scripts/check-skill-size.sh:26`) before this task; the additions are roughly 30 lines.

- [ ] **Step 5: Write the changelog entry**

Add under `### Fixed` in `[Unreleased]`:

```markdown
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
```

- [ ] **Step 6: Record the ceiling this leaves**

Add one line under `## Open gaps` in `CHANGELOG.md`:

```markdown
- **The `--force` prohibition is prose, and prose is not a guarantee.** A
  `PreToolUse` hook refusing `git worktree remove --force` is the only layer
  that holds regardless of what an agent decides, and deleting untracked files
  is irreversible. It is deferred rather than dropped: it would be this
  plugin's first `PreToolUse`, distributed to everyone who installs it, which
  is a product decision and not a defect repair. Opened 2026-08-21 with
  `docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md`, `IR2`.
```

- [ ] **Step 7: Verify and commit**

```bash
grep -n 'PreToolUse' CHANGELOG.md
scripts/check-links.sh
git add skills/finishing-a-development-branch/SKILL.md CHANGELOG.md
git commit -m "fix(finishing-a-development-branch): a perda que importa é a que não recusa"
```

Expected: the grep finds the line under `## Open gaps`; `check-links.sh` exits 0.

---

### Task 3: Make the version bump read before it writes

**Spec criterion:** `AC10`, `AC11`, `AC12`, `AC13`, `AC17`, `AC18`

**Files:**
- Create: `tests/version-bump/test-bump-version.sh`
- Modify: `scripts/bump-version.sh` — `cmd_bump`, around `:177`
- Modify: `.github/workflows/ci.yml`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing. `read_json_field` keeps its current signature `read_json_field <file> <dotted-field>` returning the value on stdout — unchanged on purpose (`AC12`).

**Acceptance criteria:**
- T3.1: An unparseable manifest leaves every declared manifest's version unchanged, exit non-zero — test: `tests/version-bump/test-bump-version.sh`, case "unparseable manifest writes nothing"
- T3.2: A manifest missing its declared field fails the same way — test: same file, case "missing field writes nothing"
- T3.3: With every manifest well formed, the bump still succeeds — test: same file, case "all well formed still succeeds"
- T3.4: `--check` still reports every manifest when one cannot be read — test: same file, case "check stays tolerant"
- T3.5: The suite has a CI step — test: Step 9's grep
- T3.6: The new shell passes `scripts/lint-shell.sh` — test: Step 8

- [ ] **Step 1: Write the failing suite**

Create `tests/version-bump/test-bump-version.sh`:

```bash
#!/usr/bin/env bash
#
# Tests for scripts/bump-version.sh — the preflight that makes the bump
# all-or-nothing.
#
# Each case builds a throwaway repository with the real script installed and
# its own .version-bump.json declaring three manifests. That exercises the real
# walk over declared files, not a parameterized variant.
#
# The two states that matter are proven BY DIFFERENCE: with one manifest
# broken, NO declared manifest changes version; with all of them well formed,
# the bump still succeeds. A gate that only checks the exit code cannot tell a
# preflight from a script that aborted halfway.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/bump-version.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

# Build a lab: three declared manifests, the middle one given by the caller.
# $1 = directory name, $2 = contents of the middle manifest
build_lab() {
    local dir="$TEST_ROOT/$1" middle="$2"
    mkdir -p "$dir/scripts"
    cp "$SCRIPT_UNDER_TEST" "$dir/scripts/bump-version.sh"
    cat > "$dir/.version-bump.json" <<'CONFIG'
{ "files": [
    { "path": "a.json", "field": "version" },
    { "path": "b.json", "field": "version" },
    { "path": "c.json", "field": "version" } ],
  "audit": { "exclude": [".git"] } }
CONFIG
    printf '{ "version": "1.0.0" }\n' > "$dir/a.json"
    printf '%s' "$middle" > "$dir/b.json"
    printf '{ "version": "1.0.0" }\n' > "$dir/c.json"
    printf '%s' "$dir"
}

# $1 = label, $2 = file, $3 = expected version substring
assert_version() {
    if grep -q "$3" "$2"; then
        printf '  ok: %s\n' "$1"
    else
        printf '  FAIL: %s — %s does not contain %s\n' "$1" "$2" "$3"
        printf '        actual: %s\n' "$(cat "$2")"
        FAILURES=$((FAILURES + 1))
    fi
}

printf 'unparseable manifest writes nothing\n'
lab="$(build_lab unparseable '{ "version": ')"
set +e
(cd "$lab" && ./scripts/bump-version.sh 2.0.0 >/dev/null 2>&1)
status=$?
set -e
if [ "$status" -ne 0 ]; then
    printf '  ok: exits non-zero (%s)\n' "$status"
else
    printf '  FAIL: expected non-zero exit, got 0\n'; FAILURES=$((FAILURES + 1))
fi
assert_version "a.json untouched" "$lab/a.json" '1.0.0'
assert_version "c.json untouched" "$lab/c.json" '1.0.0'

printf 'missing field writes nothing\n'
lab="$(build_lab missingfield '{ "other": "x" }')"
set +e
(cd "$lab" && ./scripts/bump-version.sh 2.0.0 >/dev/null 2>&1)
status=$?
set -e
if [ "$status" -ne 0 ]; then
    printf '  ok: exits non-zero (%s)\n' "$status"
else
    printf '  FAIL: expected non-zero exit, got 0\n'; FAILURES=$((FAILURES + 1))
fi
assert_version "a.json untouched" "$lab/a.json" '1.0.0'
assert_version "c.json untouched" "$lab/c.json" '1.0.0'
if grep -q 'version' "$lab/b.json"; then
    printf '  FAIL: the field was created in a manifest that never had it\n'
    FAILURES=$((FAILURES + 1))
else
    printf '  ok: no field invented\n'
fi

printf 'all well formed still succeeds\n'
lab="$(build_lab wellformed '{ "version": "1.0.0" }')"
set +e
(cd "$lab" && ./scripts/bump-version.sh 2.0.0 >/dev/null 2>&1)
set -e
assert_version "a.json bumped" "$lab/a.json" '2.0.0'
assert_version "b.json bumped" "$lab/b.json" '2.0.0'
assert_version "c.json bumped" "$lab/c.json" '2.0.0'

printf 'check stays tolerant\n'
lab="$(build_lab tolerant '{ "other": "x" }')"
set +e
out="$(cd "$lab" && ./scripts/bump-version.sh --check 2>&1)"
set -e
if printf '%s' "$out" | grep -q 'c.json'; then
    printf '  ok: --check reported past the unreadable manifest\n'
else
    printf '  FAIL: --check stopped before the third manifest\n'
    printf '        output: %s\n' "$out"
    FAILURES=$((FAILURES + 1))
fi

if [ "$FAILURES" -eq 0 ]; then
    printf '\nAll cases passed.\n'
else
    printf '\n%s case(s) failed.\n' "$FAILURES"
    exit 1
fi
```

- [ ] **Step 2: Run it and watch it fail for the right reason**

Run: `chmod +x tests/version-bump/test-bump-version.sh && tests/version-bump/test-bump-version.sh`
Expected: FAIL. Specifically — "unparseable manifest writes nothing" reports `a.json` at `2.0.0` when `1.0.0` was expected, and "missing field writes nothing" reports both a zero exit and an invented field. **If it fails any other way, stop: the suite is not reproducing the defect.**

- [ ] **Step 3: Add the preflight**

In `scripts/bump-version.sh`, inside `cmd_bump`, between the `echo ""` that follows `"Bumping all declared files to $new_version..."` and the `while` loop that writes, insert:

```bash
  # Preflight: read every declared field before writing any manifest. Without
  # this the loop below discovers an unreadable manifest mid-walk and leaves
  # the repository split across two versions. `jq -e` fails on both classes
  # that matter — a file it cannot parse, and a field that is absent — which
  # is why one check covers them.
  local preflight_failed=0
  while IFS=$'\t' read -r path field; do
    local fullpath="$REPO_ROOT/$path"
    [[ -f "$fullpath" ]] || continue
    local jq_path
    jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./' | sed 's/\.\././g')
    if ! jq -e "$jq_path" "$fullpath" >/dev/null 2>&1; then
      echo "error: $path: cannot read field '$field'" >&2
      preflight_failed=1
    fi
  done < <(declared_files)

  if [[ "$preflight_failed" -ne 0 ]]; then
    echo "error: no file was modified" >&2
    exit 1
  fi
```

**Do not touch `read_json_field`** (`AC12`). The preflight calls `jq -e` directly so `--check` and `--audit` keep the tolerant reader they need.

**The three-line `jq_path` conversion is duplicated here on purpose, and the smaller version was considered and refused.** Factoring it into a shared helper would be a smaller diff — the same chain already sits in `read_json_field` and `write_json_field` (`scripts/bump-version.sh:29-30`, `:37-38`). It is not taken because that refactor edits two functions this change otherwise leaves alone, one of which `AC12` exists to protect, and it trades a three-line duplication for a diff touching the reader whose behaviour must be proven unchanged. The duplication is the cheaper thing to review.

- [ ] **Step 4: Run the suite and watch it pass**

Run: `tests/version-bump/test-bump-version.sh`
Expected: PASS, all cases.

- [ ] **Step 5: Prove the real script still bumps this repository**

Run: `scripts/bump-version.sh --check`
Expected: all seven declared manifests reported, in sync at the current version. **This is a read-only command — do not run a real bump.**

- [ ] **Step 6: Write the changelog entry**

Add under `### Fixed` in `[Unreleased]`:

```markdown
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
```

- [ ] **Step 7: Add the CI step**

In `.github/workflows/ci.yml`, after the `Tests (shell lint script)` step, add:

```yaml
      - name: Tests (version bump preflight)
        run: tests/version-bump/test-bump-version.sh
```

- [ ] **Step 8: Lint the new shell**

Run: `scripts/lint-shell.sh tests/version-bump/test-bump-version.sh scripts/bump-version.sh`
Expected: PASS.

- [ ] **Step 9: Verify the CI step and commit**

```bash
grep -n 'tests/version-bump' .github/workflows/ci.yml
git add tests/version-bump/test-bump-version.sh scripts/bump-version.sh .github/workflows/ci.yml CHANGELOG.md
git commit -m "fix(bump-version): o manifesto sem o campo saía com sucesso e inventava o campo"
```

---

### Task 4: Build the dispatch gate, and prove it fails first

**Spec criterion:** `AC15`, `AC17`, `AC18`, `IR3`

**Files:**
- Create: `scripts/check-no-dispatch.sh`
- Create: `tests/hooks/test-check-no-dispatch.sh`
- Modify: `.github/workflows/ci.yml`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: `scripts/check-no-dispatch.sh`, run with no arguments, exit 0 when every declared carrier holds the clause and exit 1 otherwise. Task 5 depends on this exact contract.

**Acceptance criteria:**
- T4.1: The gate exits 1 when a declared carrier lacks the clause — test: `tests/hooks/test-check-no-dispatch.sh`, case "a carrier missing the clause fails"
- T4.2: The gate exits 0 when every declared carrier has it — test: same file, case "all carriers present passes"
- T4.3: A file with the clause that is not on the declared list changes nothing — test: same file, case "an undeclared file with the clause is ignored"
- T4.4: The gate and its suite have CI steps — test: Step 10's grep
- T4.5: Both new shells pass `scripts/lint-shell.sh` — test: Step 9

**The gate is built before the clause exists so that its first run is a
failure against the real tree.** That is what makes Task 5's pass a difference
rather than an assertion.

- [ ] **Step 1: Write the gate**

Create `scripts/check-no-dispatch.sh`:

```bash
#!/usr/bin/env bash
#
# check-no-dispatch.sh — a review seat does not open another one.
#
# The sibling of check-evidence-line.sh and check-escalation-shape.sh, for the
# third form this project copies on purpose. Every reviewer and the implementer
# is a subagent, and skills/using-superpowers/SKILL.md opens with a
# <SUBAGENT-STOP> block telling subagents to ignore it — so the dispatch rule at
# its line 37 cannot be read by anyone able to violate it. The clause is
# therefore carried IN each prompt rather than pointed at, for the reason
# docs/review-scopes.md records: a subagent reads its own block and does not
# follow a pointer out of it.
#
# Unifying in place without a gate is just copying. This is that gate.
#
# WHAT IT DOES NOT COVER — read this before trusting a pass:
#   * Whether the clause is worded well. It matches a marker, not an argument.
#   * Whether an agent obeys it. That is what tests/skill-behavior/ measures,
#     and no criterion in this change asks for such a record.
#   * Whether the carriers are still the right ones. The list below is
#     declared, not discovered: an eighth carrier means adding it here.
#
# Usage:
#   check-no-dispatch.sh    Exit 1 when a declared carrier has lost the clause
#
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$repo_root" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])

# Declared, not discovered — an eighth carrier is added here on purpose. Six
# skills, seven files: subagent-driven-development carries it three times, once
# per dispatched role, which is why a list of skill names is not a list of
# carriers.
CARRIERS = [
    "skills/subagent-driven-development/implementer-prompt.md",
    "skills/subagent-driven-development/task-reviewer-prompt.md",
    "skills/subagent-driven-development/re-review-prompt.md",
    "skills/requesting-code-review/code-reviewer.md",
    "skills/brainstorming/spec-document-reviewer-prompt.md",
    "skills/writing-plans/plan-document-reviewer-prompt.md",
    "skills/final-branch-audit/SKILL.md",
]

MARKER = "You Do Not Dispatch Subagents"

missing = []
unreadable = []
for rel in CARRIERS:
    path = root / rel
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        unreadable.append(f"{rel}: {exc}")
        continue
    if MARKER not in text:
        missing.append(rel)

if unreadable:
    print("check-no-dispatch: declared carrier could not be read:", file=sys.stderr)
    for line in unreadable:
        print(f"  {line}", file=sys.stderr)
    sys.exit(1)

if missing:
    print(
        f"check-no-dispatch: {len(missing)} of {len(CARRIERS)} carrier(s) have lost "
        f'the "{MARKER}" clause:',
        file=sys.stderr,
    )
    for rel in missing:
        print(f"  {rel}", file=sys.stderr)
    print(
        "\nThe clause is carried in each prompt on purpose — a subagent reads its\n"
        "own block and does not follow a pointer out of it. See\n"
        "docs/review-scopes.md, section \"Why the form is copied rather than\n"
        "extracted\". Restore it, or remove the file from CARRIERS in this script\n"
        "if it is genuinely no longer a dispatched role.",
        file=sys.stderr,
    )
    sys.exit(1)

print(f"check-no-dispatch: {len(CARRIERS)} carrier(s) carry the clause")
PY
```

- [ ] **Step 2: Run it against the real tree and watch it fail**

Run: `chmod +x scripts/check-no-dispatch.sh && scripts/check-no-dispatch.sh; echo "exit=$?"`
Expected: FAIL, `exit=1`, listing **all seven** carriers as missing the clause. **This is the difference Task 5 closes.** If fewer than seven are listed, stop — a carrier already holds the marker and the list is wrong.

- [ ] **Step 3: Write the gate's suite**

Create `tests/hooks/test-check-no-dispatch.sh`:

```bash
#!/usr/bin/env bash
#
# Tests for scripts/check-no-dispatch.sh.
#
# The script resolves its repository root from its own location and reads a
# hardcoded carrier list, so each case builds a throwaway tree with the script
# installed and all seven carrier files present. That exercises the real
# script — its real carrier list — rather than a parameterized variant that
# only exists for tests.
#
# The third case is the one that matters most: a file carrying the clause that
# is NOT on the declared list must change nothing. A gate that globbed for the
# marker instead of declaring its carriers would pass that case wrongly, and a
# carrier that silently lost the clause would then be indistinguishable from a
# file that never had it.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-no-dispatch.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

CARRIERS=(
    "skills/subagent-driven-development/implementer-prompt.md"
    "skills/subagent-driven-development/task-reviewer-prompt.md"
    "skills/subagent-driven-development/re-review-prompt.md"
    "skills/requesting-code-review/code-reviewer.md"
    "skills/brainstorming/spec-document-reviewer-prompt.md"
    "skills/writing-plans/plan-document-reviewer-prompt.md"
    "skills/final-branch-audit/SKILL.md"
)

CLAUSE='## You Do Not Dispatch Subagents'

# $1 = lab name. Builds a tree with every carrier holding the clause.
build_lab() {
    local dir="$TEST_ROOT/$1"
    mkdir -p "$dir/scripts"
    cp "$SCRIPT_UNDER_TEST" "$dir/scripts/check-no-dispatch.sh"
    local rel
    for rel in "${CARRIERS[@]}"; do
        mkdir -p "$dir/$(dirname "$rel")"
        printf '# A carrier\n\n%s\n\nBody.\n' "$CLAUSE" > "$dir/$rel"
    done
    printf '%s' "$dir"
}

# $1 = label, $2 = expected exit, $3 = actual exit
assert_exit() {
    if [ "$2" -eq "$3" ]; then
        printf '  ok: %s\n' "$1"
    else
        printf '  FAIL: %s — expected exit %s, got %s\n' "$1" "$2" "$3"
        FAILURES=$((FAILURES + 1))
    fi
}

printf 'all carriers present passes\n'
lab="$(build_lab allpresent)"
set +e
(cd "$lab" && ./scripts/check-no-dispatch.sh >/dev/null 2>&1); status=$?
set -e
assert_exit "exits 0" 0 "$status"

printf 'a carrier missing the clause fails\n'
lab="$(build_lab onemissing)"
printf '# A carrier\n\nBody with no clause.\n' > "$lab/${CARRIERS[3]}"
set +e
out="$(cd "$lab" && ./scripts/check-no-dispatch.sh 2>&1)"; status=$?
set -e
assert_exit "exits 1" 1 "$status"
if printf '%s' "$out" | grep -q "${CARRIERS[3]}"; then
    printf '  ok: names the carrier that lost it\n'
else
    printf '  FAIL: the failure does not name %s\n' "${CARRIERS[3]}"
    FAILURES=$((FAILURES + 1))
fi

printf 'an undeclared file with the clause is ignored\n'
lab="$(build_lab undeclared)"
printf '# Not a carrier\n\n%s\n' "$CLAUSE" > "$lab/skills/decoy.md"
printf '# A carrier\n\nBody with no clause.\n' > "$lab/${CARRIERS[0]}"
set +e
(cd "$lab" && ./scripts/check-no-dispatch.sh >/dev/null 2>&1); status=$?
set -e
assert_exit "the decoy does not rescue a missing carrier" 1 "$status"

if [ "$FAILURES" -eq 0 ]; then
    printf '\nAll cases passed.\n'
else
    printf '\n%s case(s) failed.\n' "$FAILURES"
    exit 1
fi
```

- [ ] **Step 4: Run the suite and watch it pass**

Run: `chmod +x tests/hooks/test-check-no-dispatch.sh && tests/hooks/test-check-no-dispatch.sh`
Expected: PASS, all cases. The suite builds its own trees, so it passes even though the real tree still fails Step 2 — that failure is Task 5's job to close.

- [ ] **Step 5: Write the changelog entry**

Add under `### Added` in `[Unreleased]`:

```markdown
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
  distinguishable from a file that never had it.
```

- [ ] **Step 6: Add the CI steps**

In `.github/workflows/ci.yml`, after the `Tests (escalation shape gate)` step, add:

```yaml
      - name: Tests (no-dispatch gate)
        run: tests/hooks/test-check-no-dispatch.sh
```

- [ ] **Step 7: Lint the new shells**

Run: `scripts/lint-shell.sh scripts/check-no-dispatch.sh tests/hooks/test-check-no-dispatch.sh`
Expected: PASS.

- [ ] **Step 8: Verify and commit**

```bash
grep -n 'check-no-dispatch' .github/workflows/ci.yml
tests/hooks/test-check-no-dispatch.sh
git add scripts/check-no-dispatch.sh tests/hooks/test-check-no-dispatch.sh .github/workflows/ci.yml CHANGELOG.md
git commit -m "feat(gates): o portão da cláusula existe antes da cláusula, para que o verde seja diferença"
```

**Note for the reviewer of this task:** `scripts/check-no-dispatch.sh` fails against the real tree at this commit, by design. Task 5 is what turns it green.

---

### Task 5: Carry the clause into all seven prompts

**Spec criterion:** `AC14`, `AC16`

**Files:**
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md`
- Modify: `skills/subagent-driven-development/re-review-prompt.md`
- Modify: `skills/requesting-code-review/code-reviewer.md`
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md`
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md`
- Modify: `skills/final-branch-audit/SKILL.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `scripts/check-no-dispatch.sh` from Task 4 — run with no arguments, exit 0 when every declared carrier holds the clause.
- Produces: nothing.

**Acceptance criteria:**
- T5.1: All seven carriers hold the clause, and `scripts/check-no-dispatch.sh` exits 0 where it exited 1 — test: `tests/hooks/test-check-no-dispatch.sh` plus the real-tree run in Step 4
- T5.2: No review scope changed — test: Step 5's diff check
- T5.3: `.version-bump.json` still declares seven JSON manifests — test: Step 5's `jq`

- [ ] **Step 1: Confirm the gate is red before you start**

Run: `scripts/check-no-dispatch.sh; echo "exit=$?"`
Expected: `exit=1`, seven carriers listed. **This is the before half of the difference. If it is already green, stop — the clause is somewhere it should not be.**

- [ ] **Step 2: Add the clause to each of the seven files**

The same block in all seven, at the anchor named below. Place it **inside the
prompt body the subagent reads** — for the six templates, that is inside the
fenced block.

**Match the surrounding indentation, and do not skip this.** Six of the seven
carriers indent their whole body by four spaces — the convention of the fenced
`prompt: |` template they sit in — and only
`skills/final-branch-audit/SKILL.md` is flush-left. A flush-left heading
dropped into an indented body renders wrong and reads as a mistake. The gate
matches the string either way, so nothing will tell you.

| Carrier | Indent | Insert immediately before |
|---|---|---|
| `skills/subagent-driven-development/implementer-prompt.md` | 4 spaces | `## Your Job` |
| `skills/subagent-driven-development/task-reviewer-prompt.md` | 4 spaces | `## Do Not Trust the Report` |
| `skills/subagent-driven-development/re-review-prompt.md` | 4 spaces | `## Scope` |
| `skills/requesting-code-review/code-reviewer.md` | 4 spaces | `## What to Check` |
| `skills/brainstorming/spec-document-reviewer-prompt.md` | 4 spaces | `## What to Check` |
| `skills/writing-plans/plan-document-reviewer-prompt.md` | 4 spaces | `## What to Check` |
| `skills/final-branch-audit/SKILL.md` | 4 spaces | `## Step 1: Resolve the Spec`, inside the auditor's prompt |

**This row was wrong when the plan was written, and executing it proved so.**
It read `none` / `## Dispatch`, which puts the clause in the skill's own
prose — read by the **controller**, whose very next section instructs it to
dispatch the auditor. The clause would have told the one agent that must
dispatch never to, and told the auditor nothing. Corrected during execution
to the anchor above; the sentence opening this step already said the clause
goes inside the prompt body the subagent reads, and the table contradicted
it. All seven carriers therefore share one indentation, not six plus one.

```markdown
## You Do Not Dispatch Subagents

Do all of this yourself. Never dispatch a subagent — the controller owns every review seat, and one you create duplicates a seat this process already provides. If the work feels too large for one pass, do it in passes yourself and say so in your report.
```

**The clause is one sentence of mechanism plus one of remedy, and it is
identical in all seven.** The gate matches the heading; the body is what a
model reads when it is deciding. Do not reword it per file — `IR3` is the
measured reason this form is copied rather than pointed at, and seven
variations are seven forms, not one.

**Change nothing else in these files.** `AC16` holds the four review scopes
still: what each face runs, in `docs/review-scopes.md` section "What each face
runs", must read identically before and after this task.

- [ ] **Step 3: Verify the size ceiling still holds**

Run: `scripts/check-skill-size.sh`
Expected: PASS. The largest carrier is `skills/final-branch-audit/SKILL.md` at 368 lines against `MAX=500` (`scripts/check-skill-size.sh:26`); the clause adds about six.

- [ ] **Step 4: Run the gate and watch the failure migrate to a pass**

```bash
scripts/check-no-dispatch.sh; echo "exit=$?"
tests/hooks/test-check-no-dispatch.sh
```

Expected: `check-no-dispatch: 7 carrier(s) carry the clause`, `exit=0`; the suite still passes. **The same command that exited 1 in Step 1 exits 0 here — that difference is `T5.1`, and a green run alone would not prove it.**

- [ ] **Step 5: Verify what must not have changed**

```bash
echo "--- the four review scopes (expect no diff in these sections) ---"
git diff --unified=0 skills/subagent-driven-development/task-reviewer-prompt.md \
  skills/requesting-code-review/code-reviewer.md \
  skills/subagent-driven-development/re-review-prompt.md \
  skills/final-branch-audit/SKILL.md \
  | grep -E '^\+' | grep -vE '^\+\+\+' | grep -vE '^\+[[:space:]]*$' \
  | grep -viE 'You Do Not Dispatch Subagents|do all of this yourself|controller owns every review seat|too large for one pass'
echo "--- manifests stay JSON ---"
jq -r '.files[].path' .version-bump.json
echo "--- the other gates ---"
scripts/check-evidence-line.sh && scripts/check-escalation-shape.sh && scripts/check-links.sh
```

Expected: the first grep returns nothing; seven paths, all ending `.json`; all three gates pass.

**The two filters before the clause filter are not decoration.** `^\+\+\+` drops
the diff's own file headers, and `^\+[[:space:]]*$` drops the blank lines the
clause itself inserts for markdown spacing — two per carrier. Without the
second one this step reports eight bare `+` lines and an implementer has no way
to tell that noise from a real scope violation.

- [ ] **Step 6: Write the changelog entry**

Add under `### Added` in `[Unreleased]`:

```markdown
- **Seven review seats could each open another one, and the rule against it
  was unreadable by all of them.** `skills/using-superpowers/SKILL.md`, section
  "Review Lives in the Gates", carries *"Between them, do not dispatch a review
  subagent on your own initiative"* — and the same file opens with a
  `<SUBAGENT-STOP>` block telling any subagent dispatched for a specific task
  to ignore the skill. Every reviewer and the implementer **is** such a
  subagent, so the one rule in this repository governing review dispatch could
  not be read by anyone able to violate it. The clause now sits in each of the
  seven prompts, charged by
  [`check-no-dispatch.sh`](scripts/check-no-dispatch.sh). **The upstream
  measured the cost this avoids** — 9 of 9 depth-2 spawns across 4 corpora were
  reviewers created by the implementer, and all 9 duplicated the review the
  controller dispatches anyway; that measurement is theirs, taken on Codex, and
  none equivalent was taken here. The dispatch graph itself was already
  correct: level 0 owns every seat. What was missing was the other half of the
  rule, stated where it can be read.
```

- [ ] **Step 7: Commit**

```bash
git add skills/subagent-driven-development/implementer-prompt.md \
  skills/subagent-driven-development/task-reviewer-prompt.md \
  skills/subagent-driven-development/re-review-prompt.md \
  skills/requesting-code-review/code-reviewer.md \
  skills/brainstorming/spec-document-reviewer-prompt.md \
  skills/writing-plans/plan-document-reviewer-prompt.md \
  skills/final-branch-audit/SKILL.md CHANGELOG.md
git commit -m "feat(prompts): a regra existia num arquivo que os workers são mandados ignorar"
```
