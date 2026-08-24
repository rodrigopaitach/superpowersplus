# Markdown read as flat text, in three carriers — design

**Date:** 2026-08-24

## The request

This repository detects fenced code blocks in two places, and both are wrong. A third detector is about to be written, because [`skills/writing-plans/scripts/check-cross-references`](../../../skills/writing-plans/scripts/check-cross-references) has none at all. The request that opened this spec named four defects in that one script; measuring the other two carriers turned one of them from a suspicion into a firing defect with visible damage, and that damage is a fifth item — a broken table of contents this repository publishes.

**The cause is one thing: fence detection written per carrier, ad hoc.** Fixing three symptoms and leaving three implementations is what put the fourth carrier on the table.

## What was measured

| Carrier | Status | Evidence |
|---|---|---|
| `check-cross-references` | **Firing, both directions** | A correct plan is failed; a defective plan is passed. Defects A and B below |
| [`scripts/check-links.sh`](../../../scripts/check-links.sh) | **Firing** | Six links pass today whose anchors exist only inside fenced examples. Defect E |
| [`skills/subagent-driven-development/scripts/task-brief`](../../../skills/subagent-driven-development/scripts/task-brief) | **Firing** (recorded as latent; falsified during execution) | 2 of 252 task extractions diverge. Defect F |

`check-links.sh` runs in CI at [`.github/workflows/ci.yml:156`](../../../.github/workflows/ci.yml). `task-brief`'s only assertion is at [`tests/claude-code/test-sdd-workspace.sh:123`](../../../tests/claude-code/test-sdd-workspace.sh), it checks where the brief file lands rather than what it contains, and that suite is not in CI.

## The defects

### A — `check-cross-references` reads the document as flat text

Every extractor scans `lines` or `text` with no idea that a fenced code block is not prose. A plan documenting the plan format — which this repository's plans routinely do — carries `## Task N` headings inside fenced examples, and they are counted as real tasks.

**Measured 2026-08-24.** Against [`docs/superpowers/plans/2026-07-06-sdd-plan-scoped-workspace.md`](../plans/2026-07-06-sdd-plan-scoped-workspace.md) the script reports `tasks present 17` for a plan whose real headings number five; the other twelve are inside fences. Against [`docs/superpowers/specs/2026-07-06-sdd-plan-scoped-workspace-eval-results.md`](2026-07-06-sdd-plan-scoped-workspace-eval-results.md) it reports `tasks present 10` for a document with **no** task headings at all. Across `docs/`, 27 fenced task headings and 131 fenced `##` headings live in 16 documents. **That second figure reads 182 under the naive toggle two of the carriers use, and the gap between the two readings is the defect measured on this corpus** — it is recorded because the first draft of this spec stated 182 as though it were the CommonMark count, having been produced by a scanner that normalised every opener to three characters.

**The record that called this cosmetic is wrong.** [`CHANGELOG.md:5007`](../../../CHANGELOG.md) states of both A and B: *"neither affects the script's green verdict — only the counts it prints."* Falsified by construction: a plan with five real tasks that correctly announces `This plan has 5 tasks.` exits **1** with `the document announces 5 tasks and carries 17`.

### B — `TASK_CRIT` carries no letter suffix and goes blind

`AC_IR` accepts an optional letter suffix; `TASK_CRIT` on the line below does not. Anchored with `\b`, a label written `T1.1a` matches **nothing at all** — not even the `T1.1` prefix.

**Measured, two states, one character apart.** A plan whose coverage matrix names a test no step creates exits **1** when the criterion is `T1.1`. The same document with `T1.1a` exits **0**: the row stops being recognised as a matrix row, so the three checks that depend on it — test exists, orphan label, duplicate row — stop running, silently.

**The direction was open and the measurement settled it.** No skill sanctions a letter suffix in either id space ([`skills/writing-plans/SKILL.md:210`](../../../skills/writing-plans/SKILL.md), [`skills/brainstorming/SKILL.md:234`](../../../skills/brainstorming/SKILL.md)), so "remove the suffix from `AC_IR`" was a live option. It is the wrong one: blindness is what produces the false green, and removing the suffix from `AC_IR` would open the identical hole for a spec id written with one. Policing id form already has an owner, a reviewer — [`skills/writing-plans/plan-document-reviewer-prompt.md:88`](../../../skills/writing-plans/plan-document-reviewer-prompt.md), a BLOCKING row.

### C — a section is terminated by its own subsection

`section()` uses one pattern for both ends: it starts on `^#{2,3}\s+<title>$` and returns at the next `^#{2,3}\s` of any depth. A `## Acceptance Criteria` organising its criteria under `###` subsections therefore ends at its own first subsection.

**Measured.** In [`docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md:118`](2026-08-21-upstream-consult-fixes-design.md), `## Acceptance Criteria` is terminated by `### Problem 1 — deletion` at `:120`. The section returns a body of zero lines and zero ids where it holds 21 — nineteen `AC` ids it defines, plus `IR2` and `IR5` cited inside it, which is the set the script's own pattern extracts. It then reports fourteen ids as *"cited but not defined"*: a fabricated failure on a committed document.

### D — dead code in the lines the others touch

`body_only` and `matrix_only` are assigned and never read, and `matrix_only`'s expression ends in `- set()`.

### E — `check-links.sh` approves links whose anchors do not exist

`strip_fences` toggles on any line matching `^\s*(```|~~~)`, so a three-backtick block nested inside a four-backtick block closes the outer one. Headings inside the example become real anchors, and links pointing at them resolve.

**Measured.** Replacing the mask with the CommonMark rule and running the gate unchanged otherwise moves it from `exit 0` to `exit 1` naming six links — the durable fact is that difference, not the corpus total, which every commit adding a link changes: [`skills/writing-skills/anthropic-best-practices.md:16`](../../../skills/writing-skills/anthropic-best-practices.md) through `:21`. Their targets are at `:634`–`:664`, and every one of the six is inside a fenced block — lines of a report template shown as an example. A fenced block produces no heading, so it produces no anchor.

### F — `task-brief` carries the same naive toggle, and it HAS fired

[`task-brief:28`](../../../skills/subagent-driven-development/scripts/task-brief) opens an awk program whose fence rule is `/^```/ { infence = !infence }`.

**This section said "measured two ways, both zero" and it was wrong. Corrected 2026-08-24, during execution.** The original measurement ran before this branch's own plan existed, and that plan is the first document in this repository to carry a three-backtick block nested inside a four-backtick one — the shape the naive toggle gets wrong. Re-measured over all 252 task extractions of every plan under `docs/` (21 plans, task numbers 1 through 12): 250 are byte-identical under both rules and **2 diverge**, both in [`docs/superpowers/plans/2026-08-24-cross-references-extractor.md`](../plans/2026-08-24-cross-references-extractor.md). Task 2 came out at 286 lines instead of 141 — it ran past its own end, because the next task's heading read as fenced. Task 7 came out at 59 instead of 204 — it stopped at the first four-backtick opener. The same defect in both directions, in the document that describes it.

The correction does not change what this spec asks for. It changes why: `AC15` was justified as "the cause is shared, not because a defect was found", and a defect was found.

### G — the table of contents the broken gate approved

[`skills/writing-skills/anthropic-best-practices.md:16`](../../../skills/writing-skills/anthropic-best-practices.md)–`:21` are six entries pointing at headings that exist only inside fenced examples. **They were added by this project**, not inherited: commit `46cf5c4` (2026-08-06) inserted the whole `## Contents` section in one go, with the six defects present from birth — the insertion is cited under `## Codebase Findings`. The `## Contents` that upstream's copy carries is different content — an illustrative list inside an example, naming `Authentication and setup` and `Core methods`.

**The generator was fence-blind in exactly the way the gate is.** The six sit between `Common patterns` and `Evaluation and iteration` in the table of contents, which is precisely where their headings sit in the document — the list was produced by walking the file as flat text. The `-1` suffixes are GitHub's duplicate-anchor disambiguation, so the generator emulated GitHub's slugger while ignoring fenced blocks.

**Measured, and it resolves exactly:** seventeen entries, eleven real sections, the six above with no section, and no section without an entry. Removing the six leaves eleven, one per section.

### H — the test-name comparison knows every test vocabulary but this repository's

`TEST_DEF` recognises `it(...)`, `test(...)`, `describe(...)`, `def test_` and `func Test`. Every suite in this repository is bash, naming its cases by shell function call: **68 `assert_run` and 9 `run_case`** across `tests/hooks/`. The check that every test named in a coverage matrix is created by some step therefore reports every one of them as absent.

**Measured 2026-08-24, on the plan for this branch:** 26 matrix-named tests, all real, all reported missing. Any plan this repository writes about its own suites hits it.

**Two designs were measured, and the obvious one is vacuous.** Asking whether the name appears anywhere outside the matrix rows fails the defect that matters: `writing-plans` requires every task criterion to name its covering test, so the criterion line carries the name and the check passes even when a step renamed the test. Proved by mutation — a step renamed with the matrix left stale exits 0. Searching the document's **fenced code blocks** catches both mutations, and is language-blind for the same reason a plan creates its tests inside code blocks in the first place.

## The design

### One scanner, and where it has to live

A single CommonMark fence scanner, in a module the python carriers import. `task-brief` keeps its own, in awk, because a cross-skill import inside the shipped plugin would be worse than one small copy in a carrier measured at zero defects.

**The module's location is forced by packaging, not chosen.** [`scripts/package-codex-plugin.sh:241`](../../../scripts/package-codex-plugin.sh) stages `skills` wholesale, and `:336` fails the build if the archive contains any `^scripts/` path. So a module under the repository's root `scripts/` would ship to Claude Code — whose plugin cache is a full checkout — and not to Codex, where `check-cross-references` still ships and would fail to import at runtime. The module goes beside it, under `skills/writing-plans/scripts/`, and [`tests/codex/test-package-codex-plugin.sh:183`](../../../tests/codex/test-package-codex-plugin.sh) is the existing proof that `skills/*/scripts/*` arrives in the archive. `check-links.sh` reaches into it: it is repository-only, always runs from a full checkout, and already reads `skills/**/*.md` as its corpus.

**Each carrier resolves the module from its own path, never from the working directory.** `check-cross-references` is a plugin script run against an arbitrary repository; `check-links.sh` cds to the repository root at [`scripts/check-links.sh:42`](../../../scripts/check-links.sh).

### Which extractors become fence-aware

Structural extractors read the document's shape; content extractors read what the document contains. Only the first kind consults the mask, and which is which was decided by measuring the corpus.

| Extractor | Fence-aware | Why, measured |
|---|---|---|
| `section()` `:72` | **yes** | The fenced `##` headings counted under Defect A; a fenced `## Acceptance Criteria` would define or truncate the id list |
| `task_headings` `:158` | **yes** | The fenced task headings counted under Defect A; the false red above |
| the `has N tasks` scan `:161` | **yes** | Same class — a fenced example reading "has 4 tasks" fires the comparison |
| `matrix_rows` `:117`, `outside_matrix` `:129` | **yes** | Zero occurrences today, but a fenced example table is what a plan documenting the format carries |
| `all_task_crit` `:114` | **yes** | It is the `task criteria` count the script prints |
| `TEST_DEF` `:172` | **no** | Tests are *created* inside fenced code blocks. That is the point of the check |
| `CITATION` `:243` | **no** | Measured: **zero** `file:line` citations inside fences across `docs/`. A citation in a code comment is legitimate and required by `writing-plans` |
| `cited_ac` `:99` | **no** | Measured: **one** id inside a fence, a real citation of `IR2` at [`docs/superpowers/plans/2026-08-21-upstream-consult-fixes.md:299`](../plans/2026-08-21-upstream-consult-fixes.md). Fence-awareness would discard it |

`check-links.sh` uses the mask for both of its existing calls, at [`:266`](../../../scripts/check-links.sh) and `:361` — the heading collection that builds anchors, and the link scan.

### The closing rule, and why the naive one does not survive

A fence closes only on the same fence character, at a length greater than or equal to the opener's, with no info string; an opener may be indented up to three spaces. **This is measured, not rigour for its own sake:** the naive toggle and the CommonMark rule classify 77 structural headings differently, across 6 documents. Confirmed by hand at [`skills/writing-skills/anthropic-best-practices.md:626`](../../../skills/writing-skills/anthropic-best-practices.md): a four-backtick block opens, a three-backtick block opens inside it at `:631`, and the naive toggle leaves the fence there — exposing `## Executive summary` at `:634` as a real heading. This repository holds 44 four-backtick fences, 2 five-backtick fences, indented openers in 6 files, and no tilde fence at all — `~` is accepted because CommonMark defines it and it costs one character, not because anything here uses it.

**An unterminated fence fails the document.** Everything after an unclosed opener stops being read as structure, which turns the checks off rather than failing them — a green verdict on a document the script stopped reading. The project already answers this: [`scripts/check-no-dispatch.sh:120`](../../../scripts/check-no-dispatch.sh) fails when it cannot read what it was asked to check, and `check-cross-references` already treats an unreadable file as a failure at `:264`.

## Acceptance Criteria

- **AC1** — Task headings inside fenced code blocks are not counted. Run against [`docs/superpowers/plans/2026-07-06-sdd-plan-scoped-workspace.md`](../plans/2026-07-06-sdd-plan-scoped-workspace.md), the summary reads `tasks present 5`.
- **AC2** — The announced-count comparison reads prose only. A plan with five real task headings, twelve fenced ones, and the sentence `This plan has 5 tasks.` exits 0.
- **AC3** — `section()` does not match a section heading inside a fence. A document whose only `## Acceptance Criteria` is fenced defines no ids, and the dangling-id check stays off.
- **AC4** — `section()` ends a section only at a heading of the same or shallower level. Run against [`docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md`](2026-08-21-upstream-consult-fixes-design.md), the summary reads `AC/IR defined 26` and no "cited but not defined" failure is reported.
- **AC5** — Coverage-matrix rows and task-body criteria are read from prose only. A fenced example table naming `T9.9` produces no orphan-label failure.
- **AC6** — The printed `task criteria` count is read from prose only.
- **AC7** — A criterion label carrying a letter suffix is matched. A plan whose matrix row is `T1.1a` and whose named test no step creates exits 1.
- **AC8** — A test created inside a fenced code block is still discovered. The existing case `clean plan passes` in [`tests/hooks/test-check-cross-references.sh`](../../../tests/hooks/test-check-cross-references.sh) still exits 0.
- **AC9** — A `file:line` citation inside a fenced code block is still resolved and checked. A document whose only citation is fenced and points past the end of the file exits 1.
- **AC10** — An `AC`/`IR` id cited inside a fenced code block still counts as cited. A spec defining `AC1` and citing `AC9` only inside a fence exits 1.
- **AC11** — A document that opens a fence and never closes it exits 1, and the message names the line the fence opened on.
- **AC12** — `body_only` and `matrix_only` no longer exist in the file.
- **AC13** — `check-links.sh` treats a heading inside a fenced code block as producing no anchor. A fixture whose only `## Heading` is inside a four-backtick block containing a three-backtick block, linked as `#heading`, exits 1.
- **AC14** — `check-links.sh` still ignores links written inside fenced code blocks. The existing case at [`tests/hooks/test-check-links.sh:184`](../../../tests/hooks/test-check-links.sh) still passes.
- **AC15** — `task-brief` does not treat a `## Task N` heading inside a fenced block as a task. A fixture plan whose only `## Task 2` is inside a four-backtick example yields an empty brief for task 2.
- **AC16** — The table of contents of [`skills/writing-skills/anthropic-best-practices.md`](../../../skills/writing-skills/anthropic-best-practices.md) has one entry per real section and no entry without one: eleven entries, eleven sections.
- **AC17** — `scripts/check-links.sh` exits 0 over the repository once AC13 and AC16 are both delivered.
- **AC18** — Neither `check-cross-references` nor `check-links.sh` contains fence-scanning logic of its own; each obtains the mask from the shared module.
- **AC20** — A coverage matrix naming a test that no code block of the plan contains exits 1, whatever language the test is written in. A plan whose matrix names a bash case its steps create exits 0.
- **AC19** — The Codex archive carries the shared module and still contains no `^scripts/` path: [`tests/codex/test-package-codex-plugin.sh`](../../../tests/codex/test-package-codex-plugin.sh) passes on a clean tree.

## Implicit Requirements

- **IR1** — A fence closes only on the same fence character, at a length greater than or equal to the opener's, with no info string. A four-backtick block containing a three-backtick block keeps the inner content fenced.
- **IR2** — A fence opener indented by up to three spaces is recognised.
- **IR3** — A tilde fence is recognised on the same terms as a backtick fence.
- **IR4** — Each carrier resolves the module from its own path, not from the working directory. `check-cross-references` run from an unrelated directory against an unrelated repository still works.
- **IR5** — Every one of the nine existing cases in [`tests/hooks/test-check-cross-references.sh`](../../../tests/hooks/test-check-cross-references.sh) still passes, unmodified, and so does every case of [`tests/hooks/test-check-links.sh`](../../../tests/hooks/test-check-links.sh).
- **IR6** — No document under `docs/` changes `check-cross-references` verdict except as AC4 requires. Measured against the committed specs and plans that predate this branch, before and after.
- **IR7** — Each acceptance criterion's test is shown to fail against the pre-fix code. A test that never went red asserts nothing.
- **IR8** — Every file the branch changes belongs to one of the classes below. **The evidence is the audit's own `git diff --name-status <branch point>..HEAD` read against this list, never a test** — a permanent suite cannot assert a branch's file list: once the branch merges, `merge-base main HEAD` is HEAD and the diff is empty, and on the next branch anyone cuts the assertion charges someone else's files. A gate that can only be vacuous or wrong is not the instrument for this criterion. Reasoned, not measured.
  - **The three carriers and the shared module** — [`skills/writing-plans/scripts/check-cross-references`](../../../skills/writing-plans/scripts/check-cross-references), [`scripts/check-links.sh`](../../../scripts/check-links.sh), [`skills/subagent-driven-development/scripts/task-brief`](../../../skills/subagent-driven-development/scripts/task-brief), and [`skills/writing-plans/scripts/mdfence.py`](../../../skills/writing-plans/scripts/mdfence.py).
  - **Their tests**, under [`tests/hooks/`](../../../tests/hooks/).
  - **[`skills/writing-skills/anthropic-best-practices.md`](../../../skills/writing-skills/anthropic-best-practices.md)** — no prose of the vendor's document is touched beyond the six table-of-contents lines this project itself added.
  - **[`CHANGELOG.md`](../../../CHANGELOG.md)**.
  - **[`.github/workflows/ci.yml`](../../../.github/workflows/ci.yml)** — this branch adds two suites, and [`CLAUDE.md`](../../../CLAUDE.md), section "Where the rest lives", requires a CI step with each one. Leaving this file alone would break that rule rather than honour this one.
  - **This branch's own spec and plan**, under `docs/superpowers/` — the process writes them, and the plan carries its `**Execution:**` field and its progress as the branch runs.
  - **The `file:line` citations the `anthropic-best-practices.md` edit above invalidated** — [`scripts/check-skill-size.sh`](../../../scripts/check-skill-size.sh) and [`docs/superpowers/specs/2026-08-21-execution-path-context-budget-design.md`](2026-08-21-execution-path-context-budget-design.md). Removing six lines shifts every citation below them by six, and no gate here reads line numbers: `check-cross-references` confirms only that a cited file opens and is long enough, and `check-links.sh` reads no `.sh` file at all. Repairing what a permitted edit broke is the tail of that edit, not new scope.
- **IR9** — Zero dependencies: `python3` standard library and `git`, both already required by the carriers.

## Codebase Findings

- **`section()` uses one pattern for both ends of a section** — [`skills/writing-plans/scripts/check-cross-references:72`](../../../skills/writing-plans/scripts/check-cross-references): `def section(title_re):`, and the loop below returns at the next `re.match(r"^#{2,3}\s", line)` of any depth.
- **The two id patterns are asymmetric** — `:86` reads `AC_IR = re.compile(r"\b((?:AC|IR)\d+[a-z]?)\b")`; `:87` reads `TASK_CRIT = re.compile(r"\b(T\d+\.\d+)\b")`.
- **Task headings are matched over raw lines** — `:158`: `task_headings = [ln for ln in lines if re.match(r"^#{2,3}\s+Task\s+\d+\b", ln)]`.
- **The announced count is scanned over raw text** — `:161`: `for m in re.finditer(r"\b(?:has|with)\s+(\d+)\s+tasks?\b", text, re.I):`.
- **Matrix rows and body criteria are read over raw lines** — `:119`: `if ln.lstrip().startswith("|") and TASK_CRIT.search(ln)`; `:129`: `for ln in lines:`.
- **Two names are assigned and never read** — `:125`: `body_only = all_task_crit - matrix_labels`; `:126`: `matrix_only = matrix_labels - (all_task_crit - matrix_labels) - set()`.
- **Tests are found by scanning the whole text, fences included** — `:172`: `TEST_DEF = re.compile(`. This is required: a plan creates its tests inside fenced code blocks.
- **An unreadable file is already a failure, not a skip** — `:264`: `unresolved.append(f"`{rel}:{first}` — cannot read: {exc}")`.
- **A gate in this project fails when it cannot read its input** — [`scripts/check-no-dispatch.sh:120`](../../../scripts/check-no-dispatch.sh): `fail("declared carrier could not be read:", unreadable)`.
- **`check-links.sh`'s fence pattern matches a prefix and toggles** — [`scripts/check-links.sh:74`](../../../scripts/check-links.sh): `FENCE = re.compile(r"^\s*(```|~~~)")`, and `:232`: `out, in_fence = [], False`, flipped on every match.
- **It masks for two different passes** — `:266`: `for line in strip_fences(text):` collects headings for anchors; `:361`: `for number, line in enumerate(strip_fences(raw), 1):` scans links. A wrong mask moves both.
- **It runs from the repository root** — `:42`: `cd "$REPO_ROOT"`.
- **`task-brief`'s awk toggles on any three-backtick prefix** — [`skills/subagent-driven-development/scripts/task-brief:28`](../../../skills/subagent-driven-development/scripts/task-brief): `awk -v n="$n" '`, and `:29`: `/^```/ { infence = !infence }`.
- **Its only assertion checks placement, not content** — [`tests/claude-code/test-sdd-workspace.sh:123`](../../../tests/claude-code/test-sdd-workspace.sh): `brief_out="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-a.md 1)"`.
- **The Codex archive stages `skills` wholesale** — [`scripts/package-codex-plugin.sh:241`](../../../scripts/package-codex-plugin.sh): `  skills \`.
- **…and forbids root `scripts/`** — `:336`: a `grep -E` whose alternation includes `^scripts/`, feeding `die "archive contains source-only paths"`.
- **`skills/*/scripts/*` provably reaches the archive** — [`tests/codex/test-package-codex-plugin.sh:183`](../../../tests/codex/test-package-codex-plugin.sh): `if [[ -x "$extracted/skills/subagent-driven-development/scripts/task-brief" ]]; then`.
- **`check-links.sh` gates CI** — [`.github/workflows/ci.yml:156`](../../../.github/workflows/ci.yml): `run: scripts/check-links.sh`.
- **The six table-of-contents entries** — [`skills/writing-skills/anthropic-best-practices.md:16`](../../../skills/writing-skills/anthropic-best-practices.md) through `:21`, each a list item whose label is `Executive summary`, `Key findings` or `Recommendations` and whose anchor is the same slug, twice over, the second run carrying GitHub's `-1` disambiguation. **Their link syntax is not reproduced here on purpose:** `check-links.sh` resolves link syntax wherever it appears, inline backticks included, so quoting them verbatim makes this spec carry the very defect it describes — measured, it did, and the gate failed on line 156 of this file. Their targets begin at `:634`: `## Executive summary`.
- **They are this project's own addition** — `git show 46cf5c4` inserts the whole `## Contents` block, twenty lines, six of them these.
- **The suite's stated rule is pairs** — [`tests/hooks/test-check-cross-references.sh:10`](../../../tests/hooks/test-check-cross-references.sh): "The cases that matter are the pairs: a clean document must PASS and the same".
- **`check-links.sh` already has fence cases to preserve** — [`tests/hooks/test-check-links.sh:184`](../../../tests/hooks/test-check-links.sh): `assert_run 0 "links inside fenced code are ignored" "$T"`.
- **The record that understated defects A and B** — [`CHANGELOG.md:4995`](../../../CHANGELOG.md) opens the gap; `:5007` carries the claim this spec falsifies.
- **Id forms are declared without a letter suffix** — [`skills/writing-plans/SKILL.md:210`](../../../skills/writing-plans/SKILL.md) and [`skills/brainstorming/SKILL.md:234`](../../../skills/brainstorming/SKILL.md).
- **Id form is policed by a reviewer** — [`skills/writing-plans/plan-document-reviewer-prompt.md:88`](../../../skills/writing-plans/plan-document-reviewer-prompt.md), a BLOCKING row.

## External Dependencies

None. The carriers use `python3`'s standard library, `awk`, and `git`, all already required by the files under change. No lockfile exists in this repository and none is added.

**Every `skills/writing-skills/anthropic-best-practices.md:NN` citation in this document is a PRE-FIX line number**, and they are left that way on purpose: this spec records the state the defect was found in. `AC16` removes six lines from the top of that file, so every line below them shifted up by six and `:16`–`:21` no longer exist at all. That shift is the reason [`scripts/check-skill-size.sh`](../../../scripts/check-skill-size.sh) now anchors that file by section title instead of by line — the rule [`CLAUDE.md`](../../../CLAUDE.md) already states for a file this project edits, and one nothing enforces: `check-links.sh` reads no `.sh` file and no line number.

## Assumptions to Confirm

- **Whether GitHub renders those six anchors as broken was not verified against GitHub itself.** Searched: read the fence structure of [`skills/writing-skills/anthropic-best-practices.md`](../../../skills/writing-skills/anthropic-best-practices.md) line by line under the CommonMark closing rule and confirmed all six targets sit inside fenced blocks; did not fetch the rendered page. The conclusion follows from CommonMark's rule that fenced content is literal, which is the specification GitHub Flavored Markdown extends — but it is inference from a specification, not an observation of the renderer.
- **No fourth carrier needs the scanner today, and two more read markdown structure with no fence handling at zero exposure.** Searched twice. First `grep -nE 'fence|infence|in_fence'` over `scripts/`, `skills/*/scripts/`, `githooks/` and `hooks/`, which returns three files — the two carriers named here plus [`scripts/check-no-dispatch.sh`](../../../scripts/check-no-dispatch.sh), whose hits are the word "fenced" inside prose comments rather than fence-tracking logic; both were opened to classify them. That search cannot find a script with no fence handling at all, which is exactly what `check-cross-references` was, so a second pass grepped the same tree for structural markdown reading — heading anchors, `startswith("#")`, table-row prefixes — and opened every hit. It found two: [`scripts/check-changelog.sh:97`](../../../scripts/check-changelog.sh) counts `^## ` in the staged CHANGELOG, and **0 of that file's 48 such headings are inside a fence**; and `check-no-dispatch.sh:98` ends a carrier's body at a line that is exactly three backticks, which would over-run a four-backtick block — **all seven carriers wrap the clause in a plain three-backtick fence**, so it terminates correctly. Both are recorded rather than fixed: neither is exposed today, and each would be its own commit.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved — the request named four defects in one script; measuring the other two carriers found a fifth firing with visible damage and a sixth latent, the damage itself is a seventh item, and running the gate over this branch's own plan found an eighth | AC1–AC20 |
| Domain and data model | Resolved — the entities are the document structures each carrier extracts, and which of them is structural was decided by measuring what lives inside fences today rather than by symmetry | The table in `### Which extractors become fence-aware` |
| Interaction flow | Resolved — the states are pass, fail, and unreadable input; the missing one was an unterminated fence, which turned the checks off instead of failing them | AC11 |
| Non-functional attributes | Clear — the mask is a single O(n) pass over lines each carrier already reads, on documents of a few hundred lines; no new output field is added to any carrier | `## The design` |
| Integrations and external dependencies | Resolved — the one real integration constraint is the Codex packager, which forbids root `scripts/` in the archive and forced the module's location | AC19, IR4, and `### One scanner, and where it has to live` |
| Edge cases and failures | Resolved — nested fences, indented openers and tilde fences, each measured in `### The closing rule, and why the naive one does not survive`; and unterminated fences, of which the repository has none today | IR1, IR2, IR3, AC11 |
| Constraints and tradeoffs | Resolved — zero dependencies means a hand-rolled scanner; `task-brief` keeps a second implementation in awk because a cross-skill import inside the shipped plugin costs more than one copy in the carrier measured at zero defects | IR8, IR9, and `### One scanner, and where it has to live` |
| Terminology | Resolved — "structural extractor" (reads document shape) versus "content extractor" (reads what the document contains). The split is what the design turns on | `### Which extractors become fence-aware` |
| Completion signals | Resolved — every criterion is settled by running a carrier against a named document or fixture and reading its exit code and output, and each test must first be seen red | AC1–AC20, IR5, IR7 |
| Placeholders and vague adjectives | Resolved — "fix it the best way" and "attack the cause" were quantified by measuring each carrier's status and each extractor against the corpus | `## What was measured` |

### Decision record

| Question | Answer | Recommendation given, and its source |
|---|---|---|
| Does defect C — a section terminated by its own subsection — enter this spec? | All four defects of the script, and broaden A as far as the evidence supports | Recommended all of them in one spec: same file, same nature, one test pass, and C is the only one failing a committed document. Source: order 1, measured here — `2026-08-21-upstream-consult-fixes-design.md:118` against `:120` |
| Which route — the short path or the full process? | Full process | Recommended the full process. The five short-path criteria ([`skills/brainstorming/SKILL.md:78`](../../../skills/brainstorming/SKILL.md) and the rows around it) held at the time, on these answers: one production file, no migration directory in the repository, no lockfile in the checkout, no public contract moved, nothing touching money, auth or PII. But they measure blast radius, not what is being edited. The scope has since grown to four carriers and a document, so the criteria no longer hold either. Source: order 1 — `skills/brainstorming/SKILL.md:78` for the criteria themselves, and `skills/writing-plans/plan-document-reviewer-prompt.md:97` for the Plan Contract row the short path would drop |
| When a document opens a fenced block and never closes it, should the script fail or continue? | Fail, naming the opening line | Recommended failing. The alternatives either read the document against a shape that disagrees with how it renders, or print green for a document the script stopped checking half-way. Source: order 1, `scripts/check-no-dispatch.sh:120` fails when it cannot read its input |
| Given the cause is duplication, what form should the fix take? | A shared module for the python carriers, `task-brief` fixed in place | Recommended it over three independent copies and over rewriting `task-brief` in python. Three copies leave the cause standing; rewriting `task-brief` trades a defect measured at zero for regression risk on a script whose only assertion checks file placement. **The location was not part of the recommendation and was forced afterwards** by `scripts/package-codex-plugin.sh:336`, which fails the Codex build on any `^scripts/` path — so the module lives under `skills/`, not at the root. Source: order 1, the packager and `tests/codex/test-package-codex-plugin.sh:183` |
| What about the six broken table-of-contents entries? | Investigate before deciding, then remove them | The investigation settled it: the entries are this project's own, added whole by `46cf5c4`, and the arithmetic in Defect G closes exactly, leaving one entry per section and no section unlisted. Source: order 1, measured in this repository |

| Does the test-name comparison's blindness to this repository's own test vocabulary enter the branch? | Yes, with the language-blind form | Recommended replacing the question rather than adding bash to the pattern: teaching it one more syntax bakes this project's shell function names into a public skill script and buys the next language nothing. **The first language-blind form offered was wrong and the measurement caught it**: "the name appears outside the matrix" passes the realistic desync, because the task criterion line names the test too. The form that survived both mutations searches the fenced code blocks. Source: order 1, measured on this branch's own plan |

## What this design does not do

- It does not unify the awk scanner with the python one. Two languages, and `task-brief` would need a cross-skill import inside the shipped plugin to reach the module.
- It does not police id form. A label the skills do not sanction is a reviewer's finding, and it already has a BLOCKING row.
- It does not change what any carrier reports, only what each one reads. No new counts field, no new output shape.
- It does not touch the vendor's prose in `anthropic-best-practices.md`. Six lines of a table of contents this project added are the whole edit.
