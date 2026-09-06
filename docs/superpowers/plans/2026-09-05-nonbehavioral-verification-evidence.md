# Non-behavioral Verification Evidence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowersplus:subagent-driven-development or superpowersplus:executing-plans to implement this plan task-by-task — the `**Execution:**` field below names which of the two this plan was handed to, and that is the one to follow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/2026-09-05-nonbehavioral-verification-evidence-design.md`

**Goal:** Make the implementer's short status report requirement verification per criterion, by that criterion's declared evidence class and instrument.

**Architecture:** No new structure. The work is markdown inside carriers that already exist, across **six implementation paths**: two carrier edits (the implementer prompt's `## Report Format` evidence bullet, and one descriptive line in the controller `SKILL.md`), one changelog entry, and three behaviour-record artifacts under `tests/skill-behavior/` (a fixture, a `RESULT-*`, and the directory README that registers it). Nothing is created or modified under `scripts/`. `docs/superpowers/review-yield.md` is process metadata of the review flow, not implementation surface, and is not a task here.

**Tech Stack:** None. The spec's `## External Dependencies` is None. The work is markdown in `skills/subagent-driven-development/`, in `tests/skill-behavior/`, and in `CHANGELOG.md`, verified by read-only commands that already exist in `scripts/`, by `git` itself, and by located ranges the auditor resolves against `HEAD`.

**Execution:** `inline` — progress recorded in session todos (not persisted). Chosen by the human partner on 2026-09-05, after the plan was approved. The IR7 baseline this execution depends on is taken at Task 1 Step 0 and its path is recorded in this session's report; it is a run-local artifact under `${TMPDIR:-/tmp}`, never versioned.

**Escalation shape** (detail and a worked example: `../using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know.

## Global Constraints

- No new dependency, external service, licence, runtime requirement, or file under `scripts/` enters this branch.
- These seven files stay out of the diff: `skills/subagent-driven-development/task-reviewer-prompt.md`, `skills/subagent-driven-development/re-review-prompt.md`, `skills/executing-plans/SKILL.md`, `skills/writing-plans/SKILL.md`, `skills/final-branch-audit/SKILL.md`, `docs/evidence-model.md`, `scripts/check-evidence-line.sh`.
- The TDD Iron Law, its three exceptions, the full-report `TDD Evidence` section, and `skills/test-driven-development/SKILL.md` are not altered.

## How the criteria are verified

Every criterion of the source spec is `structural` or `negative`, so no row here
carries a test. **Claims about the contract text are settled by located
structural evidence** — the smallest sufficient range in the artifact, which the
auditor resolves against `HEAD` — because a criterion like AC4 asserts more than
any sentinel phrase proves, and counting a phrase would answer a narrower
question than the row asks. That covers AC1–AC11, T1.11 included. Two rows carry
a second half: **AC7** adds `scripts/check-evidence-line.sh` as a regression
guard on the absence of a fourth chained field, and **AC3** carries the same gate
as a supporting check on the form's shape. The `negative` rows and `IR3` are
read-only commands, each scoped in its own row.

**A `grep` in a step is a locator, never the instrument.** It prints where to
open; the evidence is the range you read there. If an anchor stops matching
because wording moved during implementation, open the block and cite the range
directly.

## Verification Matrix

| Criterion | Spec criterion | Evidence class | Verification instrument | Test type | Layer |
|-----------|----------------|----------------|-------------------------|-----------|-------|
| T1.1 The contract states routing is per criterion | AC1 | structural | The criterion-level routing rule opening the rewritten evidence block in `skills/subagent-driven-development/implementer-prompt.md`, read as the smallest sufficient located range: the sentence stating that each criterion is reported by that criterion's own declared evidence class and instrument, resolved criterion by criterion and not once for the task | — | — |
| T1.2 The contract states mixed-class independence | AC2 | structural | The mixed-class paragraph of the same block, read as the smallest sufficient located range, showing all three readings of the invariant — a `behavioral` criterion beside a `structural` or `negative` one does not replace its declared instrument, does not let it be omitted, and does not turn it into test evidence | — | — |
| T1.3 The behavioral path still asks for the test command, its real exit and its passed/failed/skipped counts | AC3 | structural | The `behavioral` routing bullet of the same block, read as a located range and shown to name all three of test command, real exit code, and counts of passed/failed/skipped. `scripts/check-evidence-line.sh` exiting 0 is a supporting check on the form's shape, never the proof of this row — it reads field names and never their content (`scripts/check-evidence-line.sh:17-19`) | — | — |
| T1.4 The contract forbids substituting the declared instrument | AC4 | structural | The declared-instrument paragraph of the same block, read as a located range covering the whole rule: that the instruments are the brief's, reported as run, and none of a wider, a narrower, a differently-scoped equivalent, or another criterion's test command may stand in | — | — |
| T1.5 The contract asks for the real exit code of a non-behavioral instrument | AC5 | structural | The `structural`-or-`negative`-with-a-command bullet of the same block, read as the smallest sufficient located range, showing it asks for the real exit code of that instrument | — | — |
| T1.6 The contract fixes `counts:` as the literal dash | AC6 | structural | The same bullet, read as the smallest sufficient located range covering the `counts:` clause: the literal em-dash and nothing else, never a verdict, an output, or a description of what passed | — | — |
| T1.7 Extra facts stay outside the form, and the form gains no fourth chained field | AC7 | structural | Two halves, both required: the prose-placement rule of the same block, read as a located range; **and** `scripts/check-evidence-line.sh` exiting 0 with its declared carriers agreeing on exactly `Command — exit — counts`, which is the regression guard on the absence of a fourth chained field | — | — |
| T1.8 The contract asks for the smallest sufficient located range | AC8 | structural | The located-evidence bullet of the same block, read as a located range, showing it asks for the smallest semantically sufficient located range in place of a command and forbids inventing a test or command to fill the shape | — | — |
| T1.9 The contract separates a TDD probe from the declared instrument | AC9 | structural | The TDD-probe separation paragraph of the same block, read as a located range covering the whole rule: a probe is not requirement verification merely by having been the TDD evidence, the declared instrument occupies the slot, and where the declared instrument is itself the test the cycle ran it serves both roles | — | — |
| T1.10 The controller names the return verification evidence | AC10 | structural | The return sentence of the `**Report file:**` bullet in `skills/subagent-driven-development/SKILL.md`, read as the smallest sufficient located range, naming the implementer's return as verification evidence rather than a test summary | — | — |
| T1.11 The controller does not restate the detailed contract | AC11 | structural | The `**Report file:**` bullet of `skills/subagent-driven-development/SKILL.md`, read as the smallest range containing the whole sentence that describes the implementer's return, shown to end there — no evidence field name, no `counts` field, no per-class routing | — | — |
| T1.12 The TDD contract is unchanged in all four places IR1 names | IR1 | negative | A read-only byte comparison between BASE and the working tree of `skills/test-driven-development/SKILL.md` in full, together with the two protected blocks of `skills/subagent-driven-development/implementer-prompt.md` — the Iron Law block opening at `**Step 1 is not conditional on the task asking for it.**` and closing at `Work from:`, and the full-report block opening at `- **TDD Evidence**` and closing at `- Files changed` — producing empty output. The blocks are located by those anchor strings, never by line number, because Task 1 edits this same file | — | — |
| T1.13 No sibling carrier changed | IR2 | negative | `git diff --name-only "$BASE" -- skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/re-review-prompt.md skills/executing-plans/SKILL.md skills/writing-plans/SKILL.md skills/final-branch-audit/SKILL.md docs/evidence-model.md scripts/check-evidence-line.sh` produces empty output | — | — |
| T1.14 The changelog records this scope and no sibling fix | IR6 | structural | The `## [Unreleased]` section of `CHANGELOG.md`, read as a located range | — | — |
| T1.15 No manifest, lockfile or script surface added, tracked, untracked or ignored | IR7 | negative | The complete change set against BASE contains no path outside the nine this delivery declares, **and** the ignored set is unchanged in both membership and content since the snapshot Step 0 took before any edit. The change set is tracked changes from `git diff --name-only "$BASE"` plus untracked files from `git ls-files --others --exclude-standard`; the ignored set is `git ls-files --others --exclude-standard --ignored` over the **whole tree**, by full path, with a `sha256sum` per file, so a modification of a file that was already ignored is caught as well as an addition. This is an allowlist, not a catalogue of forbidden filenames: a change set that is a subset of nine known paths cannot have added or modified a manifest, a lockfile or a script, whatever such a file would have been named. The baseline is resolved through a pointer keyed by the worktree, so it survives commits and resumes and is not shared between clones. A pointer or baseline that is missing, unreadable, taken in another worktree, or newer than the edited carrier, and a failure of any collecting command, each fail the row and reach the block's exit code — none of them may read as clean | — | — |
| T2.1 The delivery carries the behaviour-record package this directory's convention requires | IR3 | structural | All of these together, and the row fails if any one is missing. **(1) Existence** — `test -f` on `tests/skill-behavior/FIXTURE-structural-production-task.md` and on `tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md`, each reported by name and carried into the step's exit code. **(2) The fixture and its input** — the delivered fixture read as located ranges showing it declares itself a test fixture and carries the input the convention names, the v2 spec and the plan below its `---` separators. **(3) The record's required content** — the delivered record read as located ranges showing its `**Date**`, its `**Model**`, its per-criterion verdicts, and each run's agent material in full. **(4) The directory entry** — the registration section this task adds to `tests/skill-behavior/README.md`, read as a located range naming the live carrier, the fixture and the result. **(5) The gate** — `scripts/check-skill-behavior-records.sh` exiting 0. Ranges (2)–(4) are read on the delivered artifacts at `HEAD`; the `cmp` against `d021ef6` in Step 1 is provenance and settles none of them | — | — |
| T2.2 No run claims a verdict it did not measure | IR4 | structural | Every per-run section of `tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md`, and the `**Verdict**` metadata row, read as located ranges, each verdict compared against what that run's historical record from `d021ef6` shows it measured | — | — |
| T2.3 The record declares runs as measurement, not delivery evidence | IR5 | structural | The provenance paragraph of `tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md`, read as a located range | — | — |

All eighteen spec criteria appear above. `Test type` and `Layer` read `—`
throughout because no criterion of this spec is `behavioral`: the delivery is
contract text and absence over the diff, and `docs/evidence-model.md` admits a
read-only validator **or sufficient located ranges** for `structural`, and a
read-only command over a declared scope for `negative`.

**A located range whose line numbers do not exist yet is resolved, not
unresolved.** At plan time the rewritten block has not been written; the row
names the artifact and the semantic location inside it, and the auditor resolves
the exact range against `HEAD`. Plans locate work; audits locate evidence.

`$BASE` in the `negative` rows is `fc80701587525bd3714e2e33d68c70a2c1a046bb`, the
branch point. The two-dot `git diff --name-only "$BASE" -- <paths>` form compares
the **working tree** against that base, so it includes changes not yet committed.
That is what makes it runnable as a pre-commit check inside the task. The final
branch audit re-runs the same claims in its own canonical form once the commits
exist.

---

## Tasks

### Task 1: The short-status contract and its controller description

**Spec criterion:** `AC1 [structural]`, `AC2 [structural]`, `AC3 [structural]`, `AC4 [structural]`, `AC5 [structural]`, `AC6 [structural]`, `AC7 [structural]`, `AC8 [structural]`, `AC9 [structural]`, `AC10 [structural]`, `AC11 [structural]`, `IR1 [negative]`, `IR2 [negative]`, `IR6 [structural]`, `IR7 [negative]`

**Files:**
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/subagent-driven-development/SKILL.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the short-status contract text, and the commit that carries it — Task 2 needs that commit's date and short SHA for the record's `**Rule changed since**` row. Task 2 imports no symbol from it.

**Acceptance criteria:**
- T1.1: The contract states routing is per criterion — `[structural]`, instrument: the criterion-level routing rule opening the rewritten evidence block in `skills/subagent-driven-development/implementer-prompt.md`, read as the smallest sufficient located range: the sentence stating that each criterion is reported by that criterion's own declared evidence class and instrument, resolved criterion by criterion and not once for the task
- T1.2: The contract states mixed-class independence — `[structural]`, instrument: the mixed-class paragraph of the same block, read as the smallest sufficient located range, showing all three readings of the invariant — a `behavioral` criterion beside a `structural` or `negative` one does not replace its declared instrument, does not let it be omitted, and does not turn it into test evidence
- T1.3: The behavioral path still asks for the test command, its real exit and its passed/failed/skipped counts — `[structural]`, instrument: the `behavioral` routing bullet of the same block, read as a located range and shown to name all three of test command, real exit code, and counts of passed/failed/skipped. `scripts/check-evidence-line.sh` exiting 0 is a supporting check on the form's shape, never the proof of this row — it reads field names and never their content (`scripts/check-evidence-line.sh:17-19`)
- T1.4: The contract forbids substituting the declared instrument — `[structural]`, instrument: the declared-instrument paragraph of the same block, read as a located range covering the whole rule: that the instruments are the brief's, reported as run, and none of a wider, a narrower, a differently-scoped equivalent, or another criterion's test command may stand in
- T1.5: The contract asks for the real exit code of a non-behavioral instrument — `[structural]`, instrument: the `structural`-or-`negative`-with-a-command bullet of the same block, read as the smallest sufficient located range, showing it asks for the real exit code of that instrument
- T1.6: The contract fixes `counts:` as the literal dash — `[structural]`, instrument: the same bullet, read as the smallest sufficient located range covering the `counts:` clause: the literal em-dash and nothing else, never a verdict, an output, or a description of what passed
- T1.7: Extra facts stay outside the form, and the form gains no fourth chained field — `[structural]`, instrument: two halves, both required: the prose-placement rule of the same block, read as a located range; **and** `scripts/check-evidence-line.sh` exiting 0 with its declared carriers agreeing on exactly `Command — exit — counts`, which is the regression guard on the absence of a fourth chained field
- T1.8: The contract asks for the smallest sufficient located range — `[structural]`, instrument: the located-evidence bullet of the same block, read as a located range, showing it asks for the smallest semantically sufficient located range in place of a command and forbids inventing a test or command to fill the shape
- T1.9: The contract separates a TDD probe from the declared instrument — `[structural]`, instrument: the TDD-probe separation paragraph of the same block, read as a located range covering the whole rule: a probe is not requirement verification merely by having been the TDD evidence, the declared instrument occupies the slot, and where the declared instrument is itself the test the cycle ran it serves both roles
- T1.10: The controller names the return verification evidence — `[structural]`, instrument: the return sentence of the `**Report file:**` bullet in `skills/subagent-driven-development/SKILL.md`, read as the smallest sufficient located range, naming the implementer's return as verification evidence rather than a test summary
- T1.11: The controller does not restate the detailed contract — `[structural]`, instrument: the `**Report file:**` bullet of `skills/subagent-driven-development/SKILL.md`, read as the smallest range containing the whole sentence that describes the implementer's return, shown to end there — no evidence field name, no `counts` field, no per-class routing
- T1.12: The TDD contract is unchanged in all four places IR1 names — `[negative]`, instrument: a read-only byte comparison between BASE and the working tree of `skills/test-driven-development/SKILL.md` in full, together with the two protected blocks of `skills/subagent-driven-development/implementer-prompt.md` — the Iron Law block opening at `**Step 1 is not conditional on the task asking for it.**` and closing at `Work from:`, and the full-report block opening at `- **TDD Evidence**` and closing at `- Files changed` — producing empty output. The blocks are located by those anchor strings, never by line number, because Task 1 edits this same file
- T1.13: No sibling carrier changed — `[negative]`, instrument: `git diff --name-only "$BASE" -- skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/re-review-prompt.md skills/executing-plans/SKILL.md skills/writing-plans/SKILL.md skills/final-branch-audit/SKILL.md docs/evidence-model.md scripts/check-evidence-line.sh` produces empty output
- T1.14: The changelog records this scope and no sibling fix — `[structural]`, instrument: the `## [Unreleased]` section of `CHANGELOG.md`, read as a located range
- T1.15: No manifest, lockfile or script surface added, tracked, untracked or ignored — `[negative]`, instrument: the complete change set against BASE contains no path outside the nine this delivery declares, **and** the ignored set is unchanged in both membership and content since the snapshot Step 0 took before any edit. The change set is tracked changes from `git diff --name-only "$BASE"` plus untracked files from `git ls-files --others --exclude-standard`; the ignored set is `git ls-files --others --exclude-standard --ignored` over the **whole tree**, by full path, with a `sha256sum` per file, so a modification of a file that was already ignored is caught as well as an addition. This is an allowlist, not a catalogue of forbidden filenames: a change set that is a subset of nine known paths cannot have added or modified a manifest, a lockfile or a script, whatever such a file would have been named. The baseline is resolved through a pointer keyed by the worktree, so it survives commits and resumes and is not shared between clones. A pointer or baseline that is missing, unreadable, taken in another worktree, or newer than the edited carrier, and a failure of any collecting command, each fail the row and reach the block's exit code — none of them may read as clean

- [ ] **Step 0: Snapshot the ignored set under `scripts/`, before any edit**

```bash
set -uo pipefail                      # this block sets its own options
BASE=fc80701587525bd3714e2e33d68c70a2c1a046bb
rc=0

WT="$(git rev-parse --show-toplevel)" || { echo "not inside a git worktree"; WT=""; rc=1; }
if [ -n "$WT" ]; then
  KEY="$(printf '%s' "$WT" | sha256sum | cut -c1-16)"
  PTR="${TMPDIR:-/tmp}/ir7-run-$KEY.id"

  if [ -e "$PTR" ]; then
    printf 'REFUSING: this worktree already has a baseline — %s names %s\n' \
      "$PTR" "$(cat -- "$PTR" 2>/dev/null)"
    echo "Remove it only to restart this task from an unedited tree."
    rc=1
  else
    RUNID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
    SNAP="${TMPDIR:-/tmp}/ir7-baseline-$KEY-$RUNID.txt"
    if {
         printf '# ir7-baseline worktree=%s base=%s head=%s branch=%s run=%s taken=%s\n' \
           "$WT" "$BASE" "$(git rev-parse HEAD)" "$(git branch --show-current)" \
           "$RUNID" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
         git ls-files --others --exclude-standard --ignored -z | sort -z | xargs -0 -r sha256sum
       } > "$SNAP" && printf '%s\n' "$SNAP" > "$PTR"
    then
      echo "IR7 baseline: $SNAP"
      echo "IR7 pointer:  $PTR"
      wc -l -- "$SNAP"
    else
      echo "FAILED to write the baseline"
      rm -f -- "$SNAP" "$PTR"
      rc=1
    fi
  fi
fi

echo "Step 0 exit: $rc"
test "$rc" -eq 0                      # the block's own exit carries the result
```

**The baseline is found through a pointer, never recomputed.** Its identity is
the **worktree**, not `HEAD`: `HEAD` moves the moment Task 1 commits, and two
clones of this branch share the same `HEAD` and branch name while being different
executions. So the pointer file is keyed by a hash of
`git rev-parse --show-toplevel`, it names the baseline written beside it, and
Step 6 reads the name out of it rather than deriving one. The baseline's own
header repeats the worktree path, and Step 6 refuses a baseline whose header
names a different one.

**Record both printed paths in your report file and in your short status.** The
final audit takes them from your report; a baseline nobody can find makes the
ignored half of T1.15 NOT DELIVERED, never clean.

**Step 0 refuses to run twice and says so with a non-zero exit.** A second
baseline taken after the edits would record the very state it exists to detect a
change against, so the pointer's existence is the guard, and re-running is a
failure rather than a silent overwrite.

Three things this step is shaped by, each measured rather than assumed:

- **An ignored file has no BASE to be compared against.** Git does not record it,
  so the only way to tell a file that was already there from one this task added
  is to write the set down first — before any edit.
- **It records content, not just names.** A `sha256sum` per file is what makes
  *modified* detectable; a list of names only ever catches *added*, and IR7 says
  "added or modified".
- **It covers the whole tree by full path, not a name pattern.** The ignore rules
  here match whole directories — `node_modules/` (`.gitignore:6`) and
  `__pycache__/` (`.gitignore:33`) — so a manifest inside one is ignored by its
  *directory*, not by its name. Confirmed:
  `git check-ignore -v --no-index scripts/__pycache__/package.json node_modules/package.json`
  reports both as ignored. A check scoped to `scripts/`, or to a list of manifest
  names, would miss `node_modules/package.json` entirely. Measured on this branch
  the whole ignored set is 6 files, all under `.ruff_cache/`, so hashing it is
  cheap; if it has grown large by the time you run this, say so in your report
  rather than narrowing the scope.

The snapshot lives in `/tmp`, carries the run's identity in its name, and is
never versioned — a file inside the repository would itself be a path outside the
nine this row allows.

- [ ] **Step 1: Replace the short-status evidence bullet in `implementer-prompt.md`**

Find this block (it begins at line 202 of the file at BASE) and replace it entirely:

```
    - The test evidence, one line, from the run you made after your last
      edit — never a count you are carrying from earlier:
      **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/
      failed/skipped]. A bare count ("6/6 green") does not say which
      instrument produced it, and the controller cannot tell a fresh run
      from a remembered one.
```

with:

```
    - The verification evidence, from the run you made after your last
      edit — never a count you are carrying from earlier. **Each criterion
      is reported by that criterion's own declared evidence class and
      instrument**, resolved criterion by criterion and not once for the
      task. A task may carry criteria of more than one class: a
      `behavioral` criterion beside it does not replace a `structural` or
      `negative` criterion's declared instrument with the test command,
      does not let you leave that criterion out, and does not turn it into
      test evidence.
      - A `behavioral` criterion carries the test command, the real exit
        code of that run, and its counts of passed, failed and skipped:
        **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/
        failed/skipped]. A bare count ("6/6 green") does not say which
        instrument produced it, and the controller cannot tell a fresh run
        from a remembered one.
      - A `structural` or `negative` criterion whose declared instrument
        is a command carries that command, the real exit code of that
        instrument, and `counts:` as **the literal `—` and nothing else** — never a verdict,
        an output, or a description of what passed.
      - A `structural` criterion settled by located evidence rather than a
        command carries the **smallest semantically sufficient located
        range** in place of a command, and no test or command is invented
        to fill the shape.
      Any further fact goes in a short phrase after the line, outside the
      form: the form is these three fields and takes no fourth one
      chained into it with an em-dash.
      **The instruments are the ones your brief declares, reported as you
      ran them** — never a wider, narrower or differently-scoped check that
      would have answered the same question, and never another criterion's
      test command. A probe is not requirement verification **merely by
      having been** your TDD evidence: what occupies a criterion's slot is
      the instrument that criterion declares. Where the declared instrument
      is itself the test your TDD cycle ran, it serves both roles; what is
      forbidden is a probe other than the declared instrument occupying
      that slot. That run belongs in the report file under TDD Evidence.
```

Four things about this replacement, each of which a reviewer will check:

- **It leads with the routing, not with a form.** The old bullet opened with
  `Command` / `exit` / `counts` and admitted the other classes only afterwards,
  so the behavioural shape read as the default. Here the per-criterion routing
  comes first and the three shapes hang off it as peers.
- **It introduces no cardinality.** There is no "one line per criterion":
  nothing in the source spec asks for it, and the surrounding contract caps the
  whole short status at *under 15 lines*. That cap is not changed. **Routing by
  criterion does not require one physical output line per criterion** — the two
  are different things, and this delivery settles only the first.
- **It keeps the same three field names.** `Command`, `exit` and `counts` are
  the only chained fields, which is what `scripts/check-evidence-line.sh`
  compares across its eight declared carriers. No fourth field is added — and
  the sentence forbidding one deliberately does not write a fourth field name in
  the `**Name:**` form, because that form is itself what the gate's field regex
  matches. The script is not modified.
- **It is outside both protected TDD blocks.** The Iron Law block and the
  full-report `TDD Evidence` section sit elsewhere in this same file, and T1.12
  compares them byte for byte against BASE.

- [ ] **Step 2: Verify the nine contract-text criteria by reading their located ranges**

Locate the block, then read it. `grep -n` here is a locator; the evidence is the
range.

```bash
P=skills/subagent-driven-development/implementer-prompt.md
grep -n 'The verification evidence, from the run you made' -A 38 "$P"
scripts/check-evidence-line.sh
```

Open what the first command prints and record one located range per criterion,
as `implementer-prompt.md:<first>-<last>`, each the smallest range that carries
the whole claim without leaning on an uncited neighbour:

- **T1.1** AC1 — the opening sentence: each criterion reported by that criterion's own declared evidence class and instrument, resolved criterion by criterion and not once for the task
- **T1.2** AC2 — the mixed-class sentence, all three readings — instrument not replaced, criterion not omitted, not turned into test evidence
- **T1.3** AC3 — the `behavioral` bullet, naming test command, real exit code, and counts of passed/failed/skipped
- **T1.4** AC4 — the declared-instrument paragraph in full: the brief's instruments as run, and none of wider, narrower, differently-scoped, or another criterion's test command
- **T1.5** AC5 — the command-instrument bullet's clause asking for the real exit code of that instrument
- **T1.6** AC6 — the same bullet's `counts:` clause: the literal `—` and nothing else, never a verdict, an output, or a description
- **T1.7** AC7 — the prose-placement rule: further facts go in a short phrase outside the form, and the form takes no fourth chained field. The gate is the row's *second* half and runs here, in this repository; the carrier no longer names it (I4)
- **T1.8** AC8 — the located-evidence bullet: the smallest semantically sufficient located range in place of a command, nothing invented to fill the shape
- **T1.9** AC9 — the TDD-probe separation paragraph in full, including the both-roles case

Then `scripts/check-evidence-line.sh` exits 0, reporting its declared carriers
agreeing on `Command — exit — counts`. That is the **second half of T1.7** — the
regression guard showing no fourth field was chained in — and a **supporting
check only** for T1.3, because the gate reads field names and never their
content (`scripts/check-evidence-line.sh:17-19`).

- [ ] **Step 3: Align the controller's one descriptive line in `SKILL.md`**

At line 224 of the file at BASE, replace:

```
  returns only status, commits, a one-line test summary, and concerns.
```

with:

```
  returns only status, commits, the verification evidence, and concerns.
```

Change nothing else in this file. The detailed contract stays in the prompt —
that is AC11, and it is why this is one word-level edit rather than a
restatement of the routing.

- [ ] **Step 4: Verify the two controller criteria by reading the bullet**

```bash
S=skills/subagent-driven-development/SKILL.md
grep -n 'Report file:' -A 5 "$S"
wc -l "$S"
```

Open the `**Report file:**` bullet and record:

- **T1.10** — the smallest range containing the return sentence, showing it now
  names *the verification evidence* rather than *a one-line test summary*.
- **T1.11** — the smallest range containing that whole sentence, showing it ends
  at "and concerns." with no evidence field name, no `counts` field, and no
  per-class routing after it. Record both as `SKILL.md:<first>-<last>`.

`wc -l` prints `499`, unchanged, under the 500-line ceiling
`scripts/check-skill-size.sh` enforces. This edit replaces four words with four
words and adds no line.

- [ ] **Step 5: Add the `## [Unreleased]` changelog entry**

Insert a new `## [Unreleased]` section immediately above `## [1.26.0] - 2026-09-05`, with a `### Changed` entry that records, factually: the measured defect (a TDD probe reported in the short status as the requirement's evidence, in a run where it was absent from the delivered commit); that requirement verification is now resolved per criterion and per evidence class, including in a task of mixed classes; that the `behavioral` path's `Command`/`exit`/`counts` form is unchanged and `scripts/check-evidence-line.sh` is untouched; and that the sibling carriers were measured and did **not** reproduce the defect, so they are out of scope rather than fixed.

Do not claim any sibling carrier was corrected. Do not cut a version.

- [ ] **Step 6: Verify the changelog entry and the three negative criteria, before committing**

```bash
set -uo pipefail                      # this block sets its own options
BASE=fc80701587525bd3714e2e33d68c70a2c1a046bb
A=skills/test-driven-development/SKILL.md
B=skills/subagent-driven-development/implementer-prompt.md
PROT='/\*\*Step 1 is not conditional/,/^    Work from:/; /- \*\*TDD Evidence\*\*/,/^    - Files changed/'

rc=0
fail() { printf 'FAIL: %s\n' "$1"; rc=1; }

grep -n '^## \[Unreleased\]' CHANGELOG.md || fail "T1.14: no ## [Unreleased] heading in CHANGELOG.md"

# T1.12 / IR1 — the four protected places, byte for byte
if ! ir1="$(diff <(cat <(git show "$BASE:$A") <(awk "$PROT" <(git show "$BASE:$B"))) \
                 <(cat "$A" <(awk "$PROT" "$B")))"; then
  fail "T1.12: protected TDD content changed:"$'\n'"$ir1"
fi

# T1.13 / IR2
if ! ir2="$(git diff --name-only "$BASE" -- skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/re-review-prompt.md skills/executing-plans/SKILL.md skills/writing-plans/SKILL.md skills/final-branch-audit/SKILL.md docs/evidence-model.md scripts/check-evidence-line.sh)"; then
  fail "T1.13: could not read the sibling-carrier diff"
elif [ -n "$ir2" ]; then
  fail "T1.13: sibling carriers changed:"$'\n'"$ir2"
fi

# T1.15 / IR7 — the whole change set against the nine declared paths
ALLOWED='^(skills/subagent-driven-development/implementer-prompt\.md'
ALLOWED="$ALLOWED"'|skills/subagent-driven-development/SKILL\.md'
ALLOWED="$ALLOWED"'|CHANGELOG\.md'
ALLOWED="$ALLOWED"'|tests/skill-behavior/FIXTURE-structural-production-task\.md'
ALLOWED="$ALLOWED"'|tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence\.md'
ALLOWED="$ALLOWED"'|tests/skill-behavior/README\.md'
ALLOWED="$ALLOWED"'|docs/superpowers/specs/2026-09-05-nonbehavioral-verification-evidence-design\.md'
ALLOWED="$ALLOWED"'|docs/superpowers/plans/2026-09-05-nonbehavioral-verification-evidence\.md'
ALLOWED="$ALLOWED"'|docs/superpowers/review-yield\.md)$'
CARRIER=skills/subagent-driven-development/implementer-prompt.md

# The artifacts the identified tools actually produce, BY SHAPE — never by the
# directory they sit in. A whole-directory dispensation would admit a manifest
# or a lockfile written inside that directory, which is precisely what IR7
# forbids; naming the shapes keeps the allowlist while closing that door.
# Measured on this tree, one instance of each shape present:
#   ruff (run by the formatter hook, resolving its cache dir from the cwd)
#     writes .ruff_cache/.gitignore, .ruff_cache/CACHEDIR.TAG, and
#     content-addressed entries .ruff_cache/<version>/<digits>
#   `sdd-workspace` creates the workspace and writes .superpowers/sdd/.gitignore
#   `review-package` writes the per-plan packages review-<sha>..<sha>.diff
# Read from the sources, NOT measured here — this plan ran inline, so the
# subagent path's workspace files were never created and no instance exists
# on this tree:
#   task-<n>-brief.md   — `scripts/task-brief`
#   task-<n>-report.md  — written by the implementer subagent (SKILL.md)
#   the progress ledger — written by the controller (references/resuming.md)
# `sdd-workspace` writes no .md itself; the three above have other writers.
# Anything else under either root is NOT demonstrated tool output and fails as
# unclassified — including a file named like a manifest or a lockfile.
PROCESS_ARTIFACTS='^\.ruff_cache/\.gitignore$'
PROCESS_ARTIFACTS="$PROCESS_ARTIFACTS"'|^\.ruff_cache/CACHEDIR\.TAG$'
PROCESS_ARTIFACTS="$PROCESS_ARTIFACTS"'|^\.ruff_cache/[0-9]+(\.[0-9]+)*/[0-9]+$'
PROCESS_ARTIFACTS="$PROCESS_ARTIFACTS"'|^\.superpowers/sdd/\.gitignore$'
PROCESS_ARTIFACTS="$PROCESS_ARTIFACTS"'|^\.superpowers/sdd/[^/]+/review-[0-9a-f]+\.\.[0-9a-f]+\.diff$'
PROCESS_ARTIFACTS="$PROCESS_ARTIFACTS"'|^\.superpowers/sdd/[^/]+/[A-Za-z0-9._-]+\.md$'

ir7=0
ir7fail() { printf 'IR7 FAIL: %s\n' "$1"; ir7=1; }

# --- resolve the baseline through the pointer, never by recomputing from HEAD
SNAP=""
if ! WT="$(git rev-parse --show-toplevel)"; then
  ir7fail "not inside a git worktree"
else
  PTR="${TMPDIR:-/tmp}/ir7-run-$(printf '%s' "$WT" | sha256sum | cut -c1-16).id"
  if [ ! -r "$PTR" ]; then
    ir7fail "no baseline pointer at $PTR — Step 0 never ran in this worktree, or it was removed"
  elif ! SNAP="$(cat -- "$PTR")" || [ -z "$SNAP" ]; then
    ir7fail "the baseline pointer at $PTR is unreadable or empty"
    SNAP=""
  fi
fi

# --- half 1: the change set against the allowlist
if ! changed="$({ git diff --name-only "$BASE" && git ls-files --others --exclude-standard; } | sort -u)"; then
  ir7fail "could not collect the change set — git diff or git ls-files failed"
else
  extra="$(printf '%s\n' "$changed" | grep -Ev "$ALLOWED")"
  [ -n "$extra" ] && ir7fail "paths outside the nine declared:"$'\n'"$extra"
fi

# --- half 2: the ignored set, membership AND content, against the pre-edit
#     baseline. A difference is not a verdict: it is CLASSIFIED, and only two
#     outcomes are clean — a path under a declared process root, or no
#     difference at all. Everything else, and every failure to look, fails.
if [ -n "$SNAP" ]; then
  if [ ! -r "$SNAP" ]; then
    ir7fail "baseline missing or unreadable at $SNAP — the ignored half cannot be evaluated"
  elif ! grep -q "^# ir7-baseline worktree=$WT " -- "$SNAP"; then
    ir7fail "the baseline at $SNAP was taken in a different worktree"
  elif [ -n "$(find "$SNAP" -newer "$CARRIER" -print -quit)" ]; then
    ir7fail "baseline at $SNAP is newer than $CARRIER — it was taken after the edits and proves nothing"
  else
    now="$(mktemp)"
    drift="$(mktemp)"
    if ! ( set -o pipefail
           git ls-files --others --exclude-standard --ignored -z \
             | sort -z | xargs -0 -r sha256sum > "$now" ); then
      ir7fail "could not read the ignored set"
    else
      diff -- <(tail -n +2 -- "$SNAP") "$now" > "$drift"
      d=$?
      if [ "$d" -gt 1 ]; then
        ir7fail "could not compare the ignored set against the baseline (diff exit $d)"
      elif [ "$d" -eq 1 ]; then
        # Full inventory preserved: every differing path is printed, then classified.
        paths="$(sed -n 's/^[<>] [0-9a-f]\{64\}  //p' -- "$drift" | sort -u)"
        n="$(printf '%s\n' "$paths" | grep -c '[^[:space:]]')"
        printf 'IR7: the ignored set differs from the Step 0 baseline — %s path(s), each classified below\n' "$n"
        if [ "$n" -eq 0 ]; then
          ir7fail "the ignored set differs but no path could be parsed from the comparison:"$'\n'"$(cat -- "$drift")"
        fi
        while IFS= read -r p; do
          [ -z "$p" ] && continue
          if printf '%s\n' "$p" | grep -qE '(^|/)scripts/'; then
            ir7fail "IR7 forbidden class — file under scripts/: $p"
          elif printf '%s\n' "$p" | grep -qE "$PROCESS_ARTIFACTS"; then
            printf '  demonstrated tool artifact: %s\n' "$p"
          else
            ir7fail "unclassified ignored difference — not a demonstrated artifact of any identified tool: $p"
          fi
        done <<EOF
$paths
EOF
      fi
    fi
    rm -f -- "$now" "$drift"
  fi
fi

[ "$ir7" -eq 0 ] && echo "IR7: clean — change set within the nine declared; every ignored difference matched a demonstrated tool artifact, none in a forbidden class"
[ "$ir7" -eq 0 ] || rc=1

echo "Step 6 exit: $rc                 (T1.12, T1.13, T1.14 and T1.15 all feed it)"
test "$rc" -eq 0                      # last statement, so the block's exit carries every failure
```

Expected: `Step 6 exit: 0`, and the block itself returns 0. **That exit
aggregates the block's mechanical checks and nothing more.** It settles
**T1.12** and **T1.13** on its own, and it settles **T1.15** together with the
baseline Step 0 took. Along the way you should see the `## [Unreleased]` heading
printed, no output from the protected-block `diff`, no path from the
sibling-carrier check, and `IR7: clean …`.

**T1.14 is not settled by this exit.** The block only asks whether the
`## [Unreleased]` heading exists; a section whose body says nothing, or says
something false, passes that check. What IR6 claims is about the section's
*content*, and it is settled by reading the range, as the Verification Matrix
declares and as the paragraph below prescribes.

Any failure prints a `FAIL:` line naming the criterion and sets `rc=1`; read that
line to know which check failed. **Do not read the printed lines as the verdict —
check the block's exit code.** Two earlier forms of this block printed a failure
and still returned 0, and the message is the part that is easy to get right.

**Why T1.12 is written this way.** IR1 protects four things, and three of them —
the Iron Law, its three exceptions, and the full-report `TDD Evidence` section —
live inside `implementer-prompt.md`, **the file this task edits**. A path-scoped
`git diff` over `skills/test-driven-development/` reaches only the fourth. The
`awk` ranges extract the two protected blocks by their anchor strings from BASE
and from the working tree and compare them character for character, so any edit
inside either one fails the check. Anchors rather than line numbers, because
Step 1 moves every line number below it.

**The half-2 rule changed in the closing fix wave, and the paragraphs below
describe the form Tasks 1 and 2 were verified with.** Read them as the record
of what ran; the classification the block now performs, why it replaced
freezing the ignored set, and what it does not reach are in
"Closing fix wave" at the end of this plan.

**Why T1.15 is an allowlist and not a list of forbidden filenames.** A
catalogue of manifest names is never finished. Two were measured and found blind:
`package.json` as a bare pathspec matches only the file at the root, `*.lock`
matches `yarn.lock` but **not** `package-lock.json` or `pnpm-lock.yaml` — the
canonical npm and pnpm lockfiles — and even a twelve-entry list left `go.mod`,
`go.sum`, `Pipfile`, `Gemfile`, `Cargo.toml`, `composer.json`, `setup.py` and
`setup.cfg` outside its reach. Every such list is one ecosystem behind.

The allowlist inverts it and the argument closes. If the complete change set is a
subset of the nine paths this delivery declares, then **no** dependency manifest,
**no** lockfile and **no** file under `scripts/` was added or modified, whatever
it would have been named — because none of those nine is one. The nine are the
six implementation paths, plus the source spec, this plan, and the review ledger,
which are the delivery's own paperwork.

**Three halves, because each sees what the others cannot.** `git diff` compares
tracked content, so a brand new unstaged file is invisible to it.
`git ls-files --others --exclude-standard` sees untracked additions but hides
anything an ignore rule matches. And an ignored file has no BASE to be compared
against at all — which is why Step 0 records the whole ignored set, by full path
and with a hash per file, before any edit.

**The ignored half covers full paths, because the rules here ignore whole
directories.** `node_modules/` (`.gitignore:6`) and `__pycache__/`
(`.gitignore:33`) match a directory, so every manifest inside one is ignored by
where it sits rather than by what it is called —
`git check-ignore -v --no-index scripts/__pycache__/package.json node_modules/package.json`
reports both. A check scoped to `scripts/`, and equally a check driven by a list
of manifest names, would pass over `node_modules/package.json` without looking at
it. The comparison is over the whole tree, and it is by content, so it answers
*added or modified* rather than only *added*.

**Nothing here may read as clean on a failure to look, and the failure has to
reach the exit code.** Two forms of this block were measured and both passed on a
defect. The first put the comparison inside a command substitution: with the
baseline path unavailable, `comm` wrote its error to stderr, the variable came
back empty, and the block printed `IR7: clean` and exited 0 — a false pass
produced by the check being unable to run. The second reported the failure
correctly and *still* returned 0, because `echo "IR7 exit: $?"` ran after the
`test` and replaced its status with its own.

Both are closed the same way. Every branch sets `ir7=1` — an absent pointer, an
unreadable or foreign or post-edit baseline, a failure of the change-set
collection, or a failure of the hash pass — and the message is printed from
`$ir7` rather than from `$?`, so no command runs between the verdict and its
report.

`ir7` then folds into `rc`, the block-wide accumulator that `T1.12`, `T1.13` and
`T1.14` also write to, and **`test "$rc" -eq 0` is the last statement in the
block**, so nothing runs after it to overwrite the status. The accumulator is why
the four criteria share one exit: before it, a regression of the Iron Law or of a
sibling carrier printed its diff and the block still returned 0 — the same defect
as the IR7 one, sitting in the three checks above it. The same shape closes
T2.1's block, where `test "$missing" -eq 0 && test "$gate" -eq 0` is likewise
last.

**These run before the commit, and the two-dot form is why they can.**
`git diff --name-only "$BASE" -- <paths>` compares the *working tree* against
BASE, so the edits made in Steps 1, 3 and 5 are already inside its scope. The
`"$BASE"..HEAD` form compares two commits and would be blind to everything not
yet committed — run here it would pass on an empty diff and prove nothing. The
final branch audit runs that canonical form later, after the commits exist.

Then open the `## [Unreleased]` section and read it: **T1.14 is settled by
reading that range**, confirming it records this scope and does not state that
any sibling carrier was fixed. Record it as `CHANGELOG.md:<first>-<last>`.

- [ ] **Step 7: Commit**

This commit stages files under `skills/`, so `CHANGELOG.md` must be staged with
them — `scripts/check-changelog.sh` in the pre-commit hook enforces it, and Step
5 produced the entry. That is an operational rule of this repository's hook, not
a requirement carried by the source spec.

```bash
git add skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/SKILL.md CHANGELOG.md
git commit -m "fix(sdd): a evidencia do short status passa a ser resolvida por criterion"
```

Then record the two facts Task 2 needs, and put them in your report:

```bash
git log -1 --format='%ad %h' --date=short -- skills/subagent-driven-development/implementer-prompt.md
```

---

### Task 2: The versioned behaviour record

**Spec criterion:** `IR3 [structural]`, `IR4 [structural]`, `IR5 [structural]`

**Files:**
- Create: `tests/skill-behavior/FIXTURE-structural-production-task.md`
- Create: `tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md`
- Modify: `tests/skill-behavior/README.md`

**Interfaces:**

- Consumes, as **provenance input**: the two artifacts committed on the closed
  experimental branch at `d021ef6207bfd258dc96b60ee58a0490ba7dc87d`. The
  live-agent runs this record describes were made **there**, against that
  branch's experimental wording of the contract — not against the text Task 1
  writes.
- Consumes, from Task 1: **the carrier's name**,
  `skills/subagent-driven-development/implementer-prompt.md`, and **the date and
  short SHA of Task 1's commit**, which the `**Rule changed since**` row names.
  No symbol is imported.
- Produces: nothing later tasks rely on.

**The formal spec is wider than what was measured.** `AC2` — mixed-class
independence, the routing of a `structural` or `negative` criterion inside a task
that also carries a `behavioral` one — was added during the formal spec round and
**was not exercised by any of the historical runs**. The record must say so rather
than let a reader infer coverage from a PASS.

**`d021ef6` is provenance, never delivery evidence.** A commit-pinned reference
is a record of what once was; the delivery evidence for every criterion of this
plan is resolved against `HEAD` at audit time. The experimental commit is not
cherry-picked, not merged, and not cited as satisfying anything.

**Acceptance criteria:**
- T2.1: The delivery carries the behaviour-record package this directory's convention requires — `[structural]`, instrument: all of these together, and the row fails if any one is missing. **(1) Existence** — `test -f` on `tests/skill-behavior/FIXTURE-structural-production-task.md` and on `tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md`, each reported by name and carried into the step's exit code. **(2) The fixture and its input** — the delivered fixture read as located ranges showing it declares itself a test fixture and carries the input the convention names, the v2 spec and the plan below its `---` separators. **(3) The record's required content** — the delivered record read as located ranges showing its `**Date**`, its `**Model**`, its per-criterion verdicts, and each run's agent material in full. **(4) The directory entry** — the registration section this task adds to `tests/skill-behavior/README.md`, read as a located range naming the live carrier, the fixture and the result. **(5) The gate** — `scripts/check-skill-behavior-records.sh` exiting 0. Ranges (2)–(4) are read on the delivered artifacts at `HEAD`; the `cmp` against `d021ef6` in Step 1 is provenance and settles none of them
- T2.2: No run claims a verdict it did not measure — `[structural]`, instrument: every per-run section of `tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md`, and the `**Verdict**` metadata row, read as located ranges, each verdict compared against what that run's historical record from `d021ef6` shows it measured
- T2.3: The record declares runs as measurement, not delivery evidence — `[structural]`, instrument: the provenance paragraph of `tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md`, read as a located range

- [ ] **Step 0: Confirm the provenance commit, then copy its exact bytes**

```bash
git cat-file -e d021ef6207bfd258dc96b60ee58a0490ba7dc87d^{commit}
echo "exit: $?"
```

Expected: `exit: 0`, and no other output.

**If this exits non-zero, stop the task and report NEEDS_CONTEXT.** The runs this
record describes exist only in that commit. Reconstructing them from memory would
be inventing a measurement record, which is the exact failure the record exists to
prevent.

Then create both files from the historical bytes — not from a rewrite:

```bash
git show d021ef6207bfd258dc96b60ee58a0490ba7dc87d:tests/skill-behavior/FIXTURE-structural-production-task.md > tests/skill-behavior/FIXTURE-structural-production-task.md
git show d021ef6207bfd258dc96b60ee58a0490ba7dc87d:tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md > tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md
```

- [ ] **Step 1: Leave the fixture byte-identical, and prove it**

No current rule requires a change to the fixture: it already opens by saying it is
a `test fixture`, which is what `scripts/check-skill-behavior-records.sh` greps
for, and its one markdown link resolves. So change nothing, and verify:

```bash
cmp tests/skill-behavior/FIXTURE-structural-production-task.md <(git show d021ef6207bfd258dc96b60ee58a0490ba7dc87d:tests/skill-behavior/FIXTURE-structural-production-task.md)
echo "cmp exit: $?"
```

Expected: `cmp exit: 0`, no output.

If some current mandatory rule does force a change, make only that change and say
in your report which rule forced it. "It would read better" is not such a rule.

- [ ] **Step 2: Edit the result record — only what is required, and nothing else**

Start from the byte-identical copy Step 0 produced and make **only** these
changes. Do not rewrite the raw transcripts, the run-by-run observations, or the
analysis sections to read better.

1. **The false Run 4 claim (IR4).** The `**Verdict**` metadata row says
   *"Run 4, against the shipped wording, PASS on all four"*. The run table in the
   section `## Four runs, three TDD behaviours, one tier` records Run 4's reviewer
   as `not dispatched`, and `C4 — Delivery unchanged` is a criterion the task
   reviewer settles. Correct the row so Run 4 carries a verdict only for the
   criteria that run measured, and says C4 was not measured because no reviewer
   was dispatched in it. Fix any heading or summary that this makes false; leave
   the ones it does not.
2. **Provenance framing (IR5).** Add a short paragraph stating that these are
   live-agent runs on throwaway fixtures — measurement case studies and
   provenance — that they are **not delivery evidence** the final branch audit
   re-runs, and that they were made on the closed experimental branch
   `d021ef6207bfd258dc96b60ee58a0490ba7dc87d`, against that branch's wording of
   the contract.
3. **The unmeasured extension, named.** State that the formal contract this record
   points at additionally carries the mixed-class routing clarification (`AC2` of
   the source spec) and that **no historical run measured it**.
4. **`**Rule changed since**` — required, and its value comes from git.** Add the
   row immediately after `**Rule path**`, in the same one-line table form the
   other metadata rows use, with the **date first in the cell** and no `|` inside
   it. The date is the one Task 1's Step 7 printed — the author date of the commit
   that edited `implementer-prompt.md` — and the cell also names that commit's
   short SHA, says the formal carrier changed after these runs were measured, and
   says the runs did not exercise the mixed-class routing.

**Why this row is required even when the dates coincide.** The gate compares the
record's `**Date**` against the newest author date on the rule path
(`scripts/check-skill-behavior-records.sh`, the `ruledate` comparison). Both are
`2026-09-05` if Task 1 commits the same day, so the gate is silent — **the pass is
a coincidence of the calendar, not a statement that the record is current**. The
row is what makes the record true on its own terms; it also keeps the gate green
if execution slips past midnight.

**Do not adjust the date to satisfy the gate.** The gate also fails a row naming a
day *after* the newest commit — "names X, but no commit touched … after Y". If the
gate objects, open `git log -1 --format='%ad' --date=short -- <rule path>`, explain
the difference in your report, and use only the factual value.

Do not run a new live-agent experiment in this task. Do not state a frequency or a
pass rate.

- [ ] **Step 3: Verify the record against its provenance, hunk by hunk**

```bash
diff -u <(git show d021ef6207bfd258dc96b60ee58a0490ba7dc87d:tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md) tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md
```

Read **every hunk** and confirm each one is one of the four changes Step 2
authorises. A hunk that is none of them is a rewrite: revert it.

This diff is **supporting provenance verification, not delivery evidence**. It
shows what was changed relative to the historical artifact; it says nothing about
whether the criteria are met, which is what the rows above settle.

- [ ] **Step 4: Register the record in the directory README**

Add one section to `tests/skill-behavior/README.md` under `## Tests in this
directory`, following the **section and table structure** already used there: a
`###` heading, a `**Rule under test:**` paragraph naming the live carrier, a
`| File | What it is |` table with one row for the fixture and one for the result,
and the approval criteria.

**Reference the live carrier with a markdown link.** That is this project's rule
for a pointer to one of its own files, stated in
[CLAUDE.md](../../../CLAUDE.md), section "Writing a reference", at `CLAUDE.md:55`:
*"A pointer to a file of this repository is a markdown link, never backticks"* —
because `check-links.sh` resolves link syntax and nothing else, so a reference in
backticks is one no gate has ever read.

**Take the form from that rule, not from the neighbouring entries.** Do not
survey how they write theirs — nothing about IR3 needs the answer, and two
attempts to characterise them were wrong. The filenames inside the table stay in
backticks, as filenames rather than pointers.

- [ ] **Step 5: Verify T2.1 and T2.3**

```bash
set -uo pipefail                      # this block sets its own options
missing=0
for f in tests/skill-behavior/FIXTURE-structural-production-task.md \
         tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md; do
  if [ -f "$f" ]; then echo "OK      $f"; else echo "MISSING $f"; missing=1; fi
done
test "$missing" -eq 0
echo "existence exit: $?"

gate=0
scripts/check-skill-behavior-records.sh || gate=1
echo "gate exit: $gate"

# locators for the ranges (2)-(4) — not the instrument
grep -n '^---$' tests/skill-behavior/FIXTURE-structural-production-task.md
grep -nE '^\| \*\*(Date|Model|Runs|Verdict|Rule path|Rule changed since)\*\*' tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md
grep -nE '^#+ .*[Rr]un|verbatim' tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md
grep -n '^### ' tests/skill-behavior/README.md
grep -n 'not delivery evidence' -B 3 -A 6 tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md

# the block itself ends non-zero if either artifact is missing OR the gate failed
test "$missing" -eq 0 && test "$gate" -eq 0
```

**T2.1 has five parts and fails if any one is missing.** IR3 does not ask only
that a `RESULT-*` exists; it asks that the record follow "that directory's
existing convention", and
[README.md](../../../tests/skill-behavior/README.md), section "Adding a test",
states that convention as a set: *"One directory entry per rule: a fixture, the
input that carries it, and a `RESULT-*.md` with date, model, criteria, and the
full agent report."* Every clause of that sentence has a part here:

- **(1) Existence.** The loop prints `OK` or `MISSING` for each of the two files
  and `test "$missing" -eq 0` carries the result into an exit code. A step that
  prints `MISSING` and still ends green is not a check — the earlier form ran
  both `test -f` bare, and with the fixture deleted its output was
  indistinguishable from a clean pass. The gate's verdict is captured the same
  way, in `gate`, because the two failures are independent: the files can both be
  present and the record still be malformed, and the block's closing
  `test "$missing" -eq 0 && test "$gate" -eq 0` is what keeps either one from
  being lost behind the locators that run after it.
- **(2) The fixture and its input.** Open the fixture and record two ranges: the
  header declaring it a test fixture, and the material below the `---` separators
  — the v2 spec and the plan. That second range is *"the input that carries it"*;
  the convention does not require it to be a separate file, and here it is not.
- **(3) The record's required content.** Open the record and record ranges for
  `**Date**`, `**Model**`, the per-criterion verdicts, and each run's agent
  material in full. *"The full agent report"* is the convention's own phrase; in
  this directory it is satisfied by the agent's returned material reproduced in
  full for what the run measured, which is what the neighbouring records carry.
  **If a run's material is not in the historical record, say so and leave the gap
  named — do not write a report that was never returned.**
- **(4) The directory entry.** The registration section this task added to
  `tests/skill-behavior/README.md`, read as a located range naming the live
  carrier, `FIXTURE-structural-production-task.md` and
  `RESULT-nonbehavioral-short-status-evidence.md`.
- **(5) The gate.** `scripts/check-skill-behavior-records.sh` exits 0.

Record (2), (3) and (4) as `<file>:<first>-<last>`. **The `grep -n` calls above
are locators, not the instrument**: they print where to open, and the evidence is
the range you read there. They run against the delivered artifacts at `HEAD`; the
`cmp` against `d021ef6` in Step 1 is provenance and settles none of (2)–(4).

**Why five parts, measured on this branch rather than assumed.** With the record
absent, `scripts/check-skill-behavior-records.sh` alone exits **0** — it validates
the records that exist and never asks for this one, so the gate alone was no
evidence for IR3 at all. With the fixture moved out of the tree the gate emits
**no new note** (it iterates the `FIXTURE-*.md` that exist,
`scripts/check-skill-behavior-records.sh:54-56`); with the README section removed
the gate is silent and `scripts/check-links.sh` still exits **0**. And the gate
reads metadata *rows*, never their content — it cannot tell a record carrying four
agent reports from one carrying none.

For **T2.3** the `grep -n` is a locator. Open the range it prints and read it:
confirm the paragraph states the runs are measurement case studies and provenance,
that they are not delivery evidence the audit re-runs, and that they were made on
the experimental branch. Record it as
`RESULT-nonbehavioral-short-status-evidence.md:<first>-<last>`.

- [ ] **Step 6: Verify T2.2 by opening every per-run section and the verdict row**

A single `grep -n 'not dispatched'` locates the one case that is already known. It
cannot show that *no other* run carries an unmeasured verdict, which is what IR4
claims. So:

```bash
grep -n '^#\+ .*[Rr]un' tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md
grep -n '| \*\*Verdict\*\* |' tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md
```

Then, for **each** run section the first command lists, and for the `**Verdict**`
row the second one finds:

- Open its verdict table or verdict prose in the new record.
- Compare every verdict in it against what the historical record from `d021ef6`
  shows that run actually measured — the diff from Step 3 is beside you.
- Confirm explicitly, and record it in the report, that the run whose reviewer was
  never dispatched carries **no** reviewer verdict, in the per-run section *and* in
  the `**Verdict**` metadata row.

Record the located range of each per-run section and of the verdict row. **T2.2 is
settled by the set of those ranges**, not by any single search.

- [ ] **Step 7: Verify the links this task adds**

`scripts/check-links.sh` runs two passes with **different reach**:

- The ordinary markdown-link pass walks the README family, `docs/**` and
  `skills/**` — `scripts/check-links.sh:61-72`. It does **not** walk `tests/`, so
  the local links inside the two new files and the new README section are read by
  nothing.
- The stable section-reference pass walks `CLAUDE.md`, `docs/`, `skills/` **and
  `tests/`** — `scripts/check-links.sh:175-182` — while skipping `CHANGELOG.md`,
  `PLUS-CHANGELOG-historico.md` and any file whose name starts with `RESULT-`.

The gap is the first pass, and it is small enough to close by naming the targets.
**Measured on the historical artifacts this task copies:** the fixture carries one
markdown link, the result carries four, and the new README section adds one — six
links over five distinct targets, all plain relative paths, **no `#fragment` and
no external URL among them**. A general-purpose link parser would be answering
questions these files do not ask.

```bash
scripts/check-links.sh
cd tests/skill-behavior
for t in FIXTURE-structural-production-task.md \
         ../../skills/test-driven-development/SKILL.md \
         ../../skills/subagent-driven-development/implementer-prompt.md \
         ../../skills/writing-plans/references/verification-matrix.md \
         ../../skills/subagent-driven-development/task-reviewer-prompt.md; do
  test -e "$t" && echo "OK   $t" || echo "BROKEN $t"
done
cd ../..
```

Expected: `scripts/check-links.sh` exits 0, and all five lines read `OK`.

Step 4's README section adds one markdown link, to the live carrier
`../../skills/subagent-driven-development/implementer-prompt.md`, which is already
the third target in this loop — so the inventory is unchanged by it, and the
filenames in that section's table are backticked filenames rather than links.

If Step 2's edits or Step 4's section introduce a target that is not in this list
— or any `#fragment` — add it to the loop and say so in your report. The list is
the measured inventory of what these artifacts contain, not a permanent ceiling.

- [ ] **Step 8: Commit**

```bash
git add tests/skill-behavior/FIXTURE-structural-production-task.md tests/skill-behavior/RESULT-nonbehavioral-short-status-evidence.md tests/skill-behavior/README.md
git commit -m "docs(skill-behavior): o registro dos runs que mediram o contrato do short status"
```

---

## Closing fix wave

The branch's two gates ran after Task 2: the conformance audit returned PASS,
and the whole-branch code review returned *With fixes* — no Critical, five
Important, four Minor. This section records what the wave changed and why. **It
does not rewrite the steps above.** Tasks 1 and 2 were executed and verified
with the text and the instrument the steps prescribed at the time; where this
wave replaced either, the step now carries the corrected version and the reason
is here.

### The carrier

- **The fix round still asked for counts an instrument may not have.**
  `## After Review Findings` closed with *"Report the command exactly as you ran
  it, and the counts it printed"*, and the next sentence sent the implementer to
  the short-status contract, whose `structural` / `negative` bullet fixes
  `counts:` at the literal `—`. For a read-only validator there are no counts,
  so the two sentences could not both be obeyed. It now reports each instrument
  and what it returned, and defers to `Report Format` for what each criterion
  carries. **The original prescription did not cover this sentence at all** —
  no criterion of the source spec points at it, and the delivery did not meet
  it before this wave.
- **The dispatched body named a gate that exists only in this repository.** The
  prescribed replacement text ended by saying a fourth chained field *"makes the
  carriers disagree and fails `scripts/check-evidence-line.sh`"*. The fenced
  prompt body of that file — everything between its two fence lines — is
  pasted verbatim into an implementer working in **your partner's** project,
  where neither that script nor the notion of carriers exists — and cannot:
  `scripts/package-codex-plugin.sh` refuses any
  archive path matching `^scripts/`, so the gate is source-only. Measured: at
  BASE this file named no `scripts/` path at all, so the reference was a
  regression this delivery introduced. The sentence now states the rule without
  the internal name. **`AC7` is preserved in both halves** — further facts go in
  prose outside the form, and the form takes no fourth chained field — and the
  gate itself is untouched and still runs here, which is the second half of
  `T1.7` and the only thing that ever verified the absence of a fourth field.

### The record and the ledger

- **Run 1's verdict was settled against the original reviewer report**, not
  reconciled by reading. The record's C4 cell said the reviewer *"approved with
  zero findings"* while its run table said *"Approved, one Minor"*. The
  reviewer's own report for that run — dispatched over `93cd7cf..b1df353`, the
  SHAs the record names — returns `Critical: None`, `Important: None`,
  `Minor: None`, `Task quality: Approved`. The cell was right and the table was
  wrong, which is the opposite of the reconciliation that suggested itself.
- **The dangling `## Open gaps` pointer is provenance, not a new decision.** The
  record's sentence about the open item pointed at a `## Open gaps` entry that
  exists in the **experimental** branch's changelog at `d021ef6`, not in this
  one. The record now says so. No item was added to `## Open gaps` to make a
  reference resolve — inventing a decision to satisfy a pointer is the failure
  the section exists to prevent.
- **The review ledger's round-3 cell.** It read `1` in *Still open from the
  previous round*, and round 2 of that face returned **zero** blocking findings,
  so no such finding could have been found unfixed. The source of the `1` is
  real and recoverable — round 3's report says *"10 received — 1 still open"* —
  but those ten were advisory and human-review items, not the previous round's
  blocking findings, which is the only quantity that column holds.

### The IR7 instrument

**What the requirement says, and what the instrument was asking.** `IR7` forbids
adding or modifying a dependency manifest, a lockfile, or a file under
`scripts/`. Half 2 of the instrument asked for something wider: that the
**entire ignored set** be unchanged in membership and content. It failed twice
during this branch, both times on activity that was not the delivery — the
formatter hook running `ruff`, which resolves its cache directory from the cwd
and rewrote `.ruff_cache/`; and the review protocol's own `review-package`,
which writes into `.superpowers/`. Neither is a manifest, a lockfile or a file
under `scripts/`. **An instrument whose scope exceeds its claim fails on things
the claim permits**, which is the same defect class as an instrument whose scope
falls short, in the other direction.

**What replaced it.** A difference in the ignored set is no longer a verdict; it
is **classified**, and only two outcomes are clean:

| Case | Outcome |
|---|---|
| Path is under `scripts/`, at any position, in any root | **IR7 forbidden class** — fails |
| Path matches the shape of an artifact an identified tool produces, and is not the case above | Tool artifact — reported by name, does not fail |
| Anything else | **Unclassified** — fails |

**The second row admits shapes, not directories, and that distinction is the
whole of it.** The rule shipped in `d23f51d` admitted *any* path under
`.ruff_cache/` or `.superpowers/`, which handed those two directories a
dispensation IR7 never granted: a `package.json` or a `package-lock.json`
written inside either one was reported as process output and the row passed.
**Reproduced before it was replaced** — all four of
`.ruff_cache/package.json`, `.ruff_cache/package-lock.json` and the same two
under `.superpowers/sdd/<plan>/` exited **0** under that rule. A limitation
recorded in a plan is not an authorisation to ship a weaker requirement.

What the row admits now is the set of artifacts the identified tools were
**measured** to produce: `ruff`'s `.gitignore`, its `CACHEDIR.TAG` and its
content-addressed `<version>/<digits>` entries; the review protocol's
`.gitignore` and its `review-<sha>..<sha>.diff` packages. **Two evidence
classes, and the comment keeps them apart:** those four shapes have an
instance on this tree, while the subagent path's `.md` files — the brief from
`scripts/task-brief`, the report from the implementer, the progress ledger
from the controller — are read from those sources and have none here, because
this plan was executed inline and that workspace was never created.
`sdd-workspace` makes the directory and its `.gitignore`; it writes no `.md`.
Everything else under either root is not demonstrated tool output and **fails
as unclassified** — a file named like a manifest included, because nothing
about being inside a cache directory makes a path one of those shapes.

**This is still not a catalogue of manifest names**, and the round-3 blocker
that such a catalogue can never be finished is not reopened. Nothing here
enumerates what is forbidden; it enumerates what two named tools were observed
to write, and everything outside that fails closed. A `node_modules/`, a
`vendor/` or a `.venv/` matches no shape and is under no root at all, so an
ignored manifest or lockfile appearing in one fails without anybody having had
to name it.

**The scope, stated:** the full inventory is preserved — every differing path is
printed with its classification, none is suppressed — and the baseline is still
taken before any edit, still resolved through the worktree-keyed pointer, and
still never recomputed after the fact. Collection failure, a missing or foreign
or post-edit baseline, an unparseable comparison, and any unclassifiable
difference each fail the row and reach the block's exit code.

**What this still does not reach, stated rather than left to be discovered.**
The shapes are the ones two tools were measured to produce on this tree. A
third tool writing into an ignored directory, or either of these two changing
its output format, produces paths that match no shape — so the row **fails**
rather than passing, and the fix is to measure the new shape and add it, never
to widen the rule back to a directory. Failing closed on an unrecognised
artifact is the intended cost; it is what the earlier rule traded away.

**Demonstrated in isolated scratch clones, asserting on the process exit code
and never on printed text.** For the shape rule the demonstration is a RED
first: the four manifest-and-lockfile paths above exit 0 under the superseded
rule and exit 1 under this one, while a new `ruff` cache entry, a new review
package and a workspace `.md` brief all still exit 0. For the half-1 allowlist
and the failure modes, the earlier demonstration stands: a `.ruff_cache/`
content change and a `.superpowers/` addition are clean; an ignored
`node_modules/package.json`, an ignored `node_modules/package-lock.json`, an
ignored file under `scripts/__pycache__/`, a script inside a declared root, an
untracked root lockfile and a modification to a tracked file under `scripts/`
are each caught; and a missing baseline, a missing pointer and an unavailable
`git` each still fail. **Every baseline this branch took is preserved**, and
the comparison over the full window — from the first, taken before any edit
and before `ruff` ran, to the delivered tree — classifies every differing path
as declared process output, with none in a forbidden class. **The count is
deliberately not written here.** It grows whenever the review protocol writes
another package under `.superpowers/`, and a number in this file would go on
reading as true after the next one: the first version of this sentence said
*four*, and was overtaken within the same session by the review package built
to check it. Run the comparison; the block prints every path it classifies.

**One more limit, from the re-audit.** The baseline is taken at Task 1 Step 0,
which runs after the spec and the plan are committed — so the ignored-set window
opens at that commit, not at BASE. An ignored file added by one of those two
commits would sit *inside* the baseline rather than appear as a difference. What
bounds it here is that `.gitignore` is not in the change set, so the ignore rules
are identical to BASE, and both commits are documentation only.
