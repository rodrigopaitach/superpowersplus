# `check-cross-references` reads markdown as flat text — design

**Date:** 2026-08-24

## The request

Four defects in [`skills/writing-plans/scripts/check-cross-references`](../../../skills/writing-plans/scripts/check-cross-references), the mechanical gate that runs between fixing a reviewer's blocking issues and re-dispatching the reviewer. Three were found by measurement in this session; the fourth is dead code inside the lines the first three touch. They are stated apart because they have four different causes, and collapsing them would hide one under another's fix.

The script is one file, run by two skills and by CI ([`.github/workflows/ci.yml:81`](../../../.github/workflows/ci.yml)). Nothing outside it changes.

## The four defects

### Defect A — the extractor reads the document as flat text

Every extractor scans `lines` or `text` with no idea that a fenced code block is not prose. A plan that documents the plan format — which this repository's plans routinely do — carries `## Task N` headings inside fenced example blocks, and they are counted as real tasks.

**Measured 2026-08-24.** Against [`docs/superpowers/plans/2026-07-06-sdd-plan-scoped-workspace.md`](../plans/2026-07-06-sdd-plan-scoped-workspace.md) the script reports `tasks present 17` for a plan whose real headings number five; the other twelve are inside fences. Against [`docs/superpowers/specs/2026-07-06-sdd-plan-scoped-workspace-eval-results.md`](2026-07-06-sdd-plan-scoped-workspace-eval-results.md) it reports `tasks present 10` for a document with **no** task headings at all. Across `docs/`, 27 fenced task headings and 182 fenced `##` headings live in 16 documents.

**This is not cosmetic, and the record that said it was is wrong.** [`CHANGELOG.md:5007`](../../../CHANGELOG.md) states of both A and B: *"neither affects the script's green verdict — only the counts it prints."* Falsified by construction: a plan with five real tasks that correctly announces `This plan has 5 tasks.` exits **1** with `the document announces 5 tasks and carries 17`. A correct document is failed for a defect that is not in it.

### Defect B — `TASK_CRIT` carries no letter suffix and goes blind

`AC_IR` accepts an optional letter suffix; `TASK_CRIT` on the line below it does not. Because the pattern is anchored with `\b`, a label written `T1.1a` matches **nothing at all** — not even the `T1.1` prefix.

**Measured 2026-08-24, two states, one character apart.** A plan whose coverage matrix names a test no step creates exits **1** when the criterion is `T1.1`. The same document with `T1.1a` exits **0**. The row stops being recognised as a matrix row, so the three checks that depend on the row — test exists, orphan label, duplicate row — stop running, silently.

**The direction of the fix was open and the measurement settled it.** No skill sanctions a letter suffix in either id space ([`skills/writing-plans/SKILL.md:210`](../../../skills/writing-plans/SKILL.md), [`skills/brainstorming/SKILL.md:234`](../../../skills/brainstorming/SKILL.md)), so "remove the suffix from `AC_IR`" was a live option. It is the wrong one: blindness is what produces the false green, and removing the suffix from `AC_IR` would open the identical hole for a spec id written with one. Policing id form already has an owner, and it is a reviewer — [`skills/writing-plans/plan-document-reviewer-prompt.md:88`](../../../skills/writing-plans/plan-document-reviewer-prompt.md) carries it as a BLOCKING row.

### Defect C — a section is terminated by its own subsection

`section()` uses one pattern for both ends: it starts on `^#{2,3}\s+<title>$` and returns at the next `^#{2,3}\s` of any depth. A `## Acceptance Criteria` that organises its criteria under `###` subsections therefore ends at its own first subsection.

**Measured 2026-08-24.** In [`docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md`](2026-08-21-upstream-consult-fixes-design.md), `## Acceptance Criteria` (line 118) is terminated by `### Problem 1 — deletion` (line 120). The section returns a body of **zero lines and zero ids** where it defines **21**. The script then reports fourteen ids as *"cited but not defined"* — a fabricated failure on a committed document, and the only one of these defects firing on `main` today.

### Defect D — dead code in the lines the others touch

`body_only` and `matrix_only` are assigned and never read anywhere in the file, and `matrix_only`'s expression ends in `- set()`.

## The design

One fence mask, computed once from the document's lines, consulted by the **structural** extractors and by no others. Which extractor is which is decided by measurement, not by symmetry.

| Extractor | Fence-aware | Why, measured |
|---|---|---|
| `section()` `:72` | **yes** | The fenced `##` headings counted under Defect A above; a fenced `## Acceptance Criteria` would define or truncate the id list |
| `task_headings` `:158` | **yes** | The fenced task headings counted under Defect A; the false red above |
| the `has N tasks` scan `:161` | **yes** | Same class — a fenced example reading "has 4 tasks" fires the comparison |
| `matrix_rows` `:117`, `outside_matrix` `:129` | **yes** | Zero occurrences today, but a fenced example table is exactly what a plan documenting the format carries |
| `all_task_crit` `:114` | **yes** | It is the `task criteria` count the script prints |
| `TEST_DEF` `:172` | **no** | Tests are *created* inside fenced code blocks. That is the point of the check |
| `CITATION` `:243` | **no** | Measured: **zero** `file:line` citations inside fences across `docs/`. A citation in a code comment is legitimate and required by `writing-plans` |
| `cited_ac` `:99` | **no** | Measured: **one** id inside a fence, and it is a real citation of `IR2` at [`docs/superpowers/plans/2026-08-21-upstream-consult-fixes.md:299`](../plans/2026-08-21-upstream-consult-fixes.md). Fence-awareness would discard it |

**The fence scanner follows CommonMark's closing rule, and that is a measured requirement rather than rigour for its own sake.** This repository already has two naive implementations — [`skills/subagent-driven-development/scripts/task-brief:29`](../../../skills/subagent-driven-development/scripts/task-brief) and [`scripts/check-links.sh:232`](../../../scripts/check-links.sh) — that toggle on any three-backtick line. Compared against the CommonMark rule over `docs/` and `skills/`, the two algorithms classify **77 structural headings differently**, across 6 documents. (The 16 in the paragraph above is a different measurement — documents carrying any fenced `##` heading at all.) Confirmed by hand at [`skills/writing-skills/anthropic-best-practices.md:626`](../../../skills/writing-skills/anthropic-best-practices.md): a four-backtick block opens, a three-backtick block opens inside it at line 631, and the naive toggle leaves the fence there — exposing `## Executive summary` at line 634 as a real heading when it is inside an example. This repository holds 44 four-backtick fences, 2 five-backtick fences, indented openers in 6 files, and no tilde fence at all — `~` is accepted because CommonMark defines it and it costs one character, not because anything here uses it.

**An unterminated fence fails the document.** Everything after an unclosed opener stops being read as structure, which turns the checks off rather than failing them — a green verdict on a document the script stopped reading. The project already answers this: [`scripts/check-no-dispatch.sh:120`](../../../scripts/check-no-dispatch.sh) fails when it cannot read what it was asked to check, and this script's own citation pass already treats an unreadable file as a failure at `:264`.

**Nothing outside this script changes.** `task-brief` and `check-links.sh` carry the same naive toggle, and the 77-heading divergence covers files `check-links.sh` reads. Whether it changes any verdict of theirs was **not** tested. It is a separate finding, in `## Assumptions to Confirm`, and a separate commit.

## Acceptance Criteria

- **AC1** — Task headings inside fenced code blocks are not counted. Run against [`docs/superpowers/plans/2026-07-06-sdd-plan-scoped-workspace.md`](../plans/2026-07-06-sdd-plan-scoped-workspace.md), the summary reads `tasks present 5`.
- **AC2** — The announced-count comparison reads prose only. A plan with five real task headings, twelve fenced ones, and the sentence `This plan has 5 tasks.` exits 0.
- **AC3** — `section()` does not match a section heading that is inside a fence. A document whose only `## Acceptance Criteria` is inside a fenced block defines no ids, and the dangling-id check stays off.
- **AC4** — `section()` ends a section only at a heading of the same or shallower level. Run against [`docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md`](2026-08-21-upstream-consult-fixes-design.md), the summary reads `AC/IR defined 26` and no "cited but not defined" failure is reported.
- **AC5** — Coverage-matrix rows and task-body criteria are read from prose only. A fenced example table naming `T9.9` produces no "criteria in the coverage matrix with no matching criterion in a task body" failure.
- **AC6** — The printed `task criteria` count is read from prose only.
- **AC7** — A criterion label carrying a letter suffix is matched. A plan whose matrix row is `T1.1a` and whose named test no step creates exits 1.
- **AC8** — A test created inside a fenced code block is still discovered. The existing case `clean plan passes` in [`tests/hooks/test-check-cross-references.sh`](../../../tests/hooks/test-check-cross-references.sh) still exits 0.
- **AC9** — A `file:line` citation inside a fenced code block is still resolved and checked. A document whose only citation is inside a fence and points past the end of the file exits 1.
- **AC10** — An `AC`/`IR` id cited inside a fenced code block still counts as cited. A spec defining `AC1` and citing `AC9` only inside a fence exits 1.
- **AC11** — A document that opens a fence and never closes it exits 1, and the message names the line the fence opened on.
- **AC12** — `body_only` and `matrix_only` no longer exist in the file.

## Implicit Requirements

- **IR1** — A fence closes only on the same fence character, at a length greater than or equal to the opener's, with no info string. A four-backtick block containing a three-backtick block keeps the inner content fenced.
- **IR2** — A fence opener indented by up to three spaces is recognised.
- **IR3** — A tilde fence is recognised on the same terms as a backtick fence.
- **IR4** — Every one of the nine existing cases in [`tests/hooks/test-check-cross-references.sh`](../../../tests/hooks/test-check-cross-references.sh) still passes, unmodified.
- **IR5** — No document under `docs/` changes verdict except as AC4 requires. Measured against the 40 committed specs and plans that predate this branch — `git ls-files` lists 41 including this spec, which is excluded from its own corpus.
- **IR6** — Each acceptance criterion's test is shown to fail against the pre-fix script. A test that never went red asserts nothing.
- **IR7** — No file outside the script and its test suite changes behaviour. `CHANGELOG.md` is the only other file edited.
- **IR8** — The script stays zero-dependency: `python3` and `git`, both already invoked at `:58` and `:219`.

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
- **This repository already reads task headings outside fences, in another script** — [`skills/subagent-driven-development/scripts/task-brief:29`](../../../skills/subagent-driven-development/scripts/task-brief): `/^```/ { infence = !infence }`, and `:30`: `!infence && /^#+[ \t]+Task[ \t]+[0-9]+/ {`. It extracts one task's body and prints no count, so it is a precedent for the *rule*, not a second opinion on the number: run its own awk over the plan above and the fence-aware pass finds 5 headings where `check-cross-references` reports 17.
- **The other naive implementation** — [`scripts/check-links.sh:232`](../../../scripts/check-links.sh): `out, in_fence = [], False`, toggled on any `FENCE.match(line)`.
- **The nested-fence case, by hand** — [`skills/writing-skills/anthropic-best-practices.md:626`](../../../skills/writing-skills/anthropic-best-practices.md) opens ` ````markdown  theme={null} `; line 631 opens ` ```markdown ` inside it; line 645 closes the inner; line 646 closes the outer with ` ```` `.
- **The section that measures defect C** — [`docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md:118`](2026-08-21-upstream-consult-fixes-design.md): `## Acceptance Criteria`, terminated at `:120`: `### Problem 1 — deletion`.
- **The suite's own stated rule is pairs** — [`tests/hooks/test-check-cross-references.sh:10`](../../../tests/hooks/test-check-cross-references.sh): "The cases that matter are the pairs: a clean document must PASS and the same".
- **CI runs this suite** — [`.github/workflows/ci.yml:81`](../../../.github/workflows/ci.yml): `run: tests/hooks/test-check-cross-references.sh`.
- **The record that understated these defects** — [`CHANGELOG.md:4995`](../../../CHANGELOG.md) opens the open gap; `:5007` carries the claim this spec falsifies.
- **Task criterion labels are declared without a letter suffix** — [`skills/writing-plans/SKILL.md:210`](../../../skills/writing-plans/SKILL.md): "Labeled `T<task number>.<n>`, never `AC` or `IR`"; spec ids likewise at [`skills/brainstorming/SKILL.md:234`](../../../skills/brainstorming/SKILL.md): "Numbered and addressable (`AC1`, `AC2`, …)".
- **Id form is policed by a reviewer, not by this script** — [`skills/writing-plans/plan-document-reviewer-prompt.md:88`](../../../skills/writing-plans/plan-document-reviewer-prompt.md), a BLOCKING row.

## External Dependencies

None. The script uses `python3` and `git`, both already invoked by the file under change. No lockfile exists in this repository and none is added.

## Assumptions to Confirm

- **Whether the same naive fence toggle changes any verdict of `task-brief` or `check-links.sh` was not tested.** Searched: implemented both masks and diffed them line by line over `pathlib.Path("docs").rglob("*.md")` and the same for `skills/` — the corpus [`scripts/check-links.sh:71`](../../../scripts/check-links.sh) and `:72` walk, so every document the divergence lands in is one it reads. The result is the divergence stated once in `## The design` and not restated here, because a number written twice is a number that desyncs. What was **not** run is `check-links.sh` itself before and after a corrected mask, so whether any link verdict moves is unknown. Deliberately out of scope: another script, another commit.
- **Whether `## Acceptance Criteria` organised under `###` subsections is the intended spec shape.** Searched: every committed spec under `docs/superpowers/specs/` for a level-2 AC or IR section containing level-3 subsections — exactly one does, `2026-08-21-upstream-consult-fixes-design.md`. Nothing in [`skills/brainstorming/SKILL.md:234`](../../../skills/brainstorming/SKILL.md) forbids or requires subsections, so this spec treats the script as wrong rather than the document. If the convention is meant to be flat sections, AC4 becomes a lint rule for specs instead, and that is a different change.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved — the request named two defects; investigation found a third firing on `main` and a fourth inside the same lines, and the partner chose all four with defect A broadened to whatever the measurement supports | AC1–AC12 |
| Domain and data model | Resolved — the entities are the document structures the script extracts, and which of them is structural was decided by measuring what lives inside fences today rather than by symmetry | The fence-aware / fence-blind table in `## The design`; AC1–AC10 |
| Interaction flow | Resolved — the script's states are pass, fail, and unreadable input; the missing one was an unterminated fence, which turned the checks off instead of failing them | AC11 |
| Non-functional attributes | Clear — the mask is a single O(n) pass over lines the script already reads, on documents of a few hundred lines; the observable output is the existing counts line, whose numbers this change corrects rather than reshapes | `## The design`; no new output field |
| Integrations and external dependencies | Clear — zero-dependency project, no lockfile in the checkout, and the change adds no import beyond `re` and `pathlib`, already used | `## External Dependencies` |
| Edge cases and failures | Resolved — nested fences, indented openers and tilde fences, each measured in `## The design`; and unterminated fences, of which the repository has none today | IR1, IR2, IR3, AC11 |
| Constraints and tradeoffs | Resolved — zero dependencies means a hand-rolled scanner; two naive implementations already exist in this repository and are deliberately not unified with it or corrected here | IR7, IR8, and the first item of `## Assumptions to Confirm` |
| Terminology | Resolved — "structural extractor" (reads document shape: sections, headings, matrix rows, id labels) versus "content extractor" (reads what the document contains: tests, citations, id citations). The split is what the design turns on | The table in `## The design` |
| Completion signals | Resolved — every criterion is settled by running the script against a named document or a fixture and reading its exit code and summary line, and each test must first be seen red | AC1–AC12, IR4, IR6 |
| Placeholders and vague adjectives | Resolved — "fix A the best way" and "broaden if warranted" were quantified into the per-extractor table by measuring each extractor against the corpus | `## The design` |

### Decision record

| Question | Answer | Recommendation given, and its source |
|---|---|---|
| Does defect C — a section terminated by its own subsection — enter this spec? | All three, plus the dead code, and broaden A as far as the evidence supports | Recommended all three in one spec: same file, same nature (structural reading of markdown), one test pass, and C is the only one failing a committed document today. Source: order 1, measured in this repository — `2026-08-21-upstream-consult-fixes-design.md:118` against `:120` |
| Which route — the short path or the full process? | Full process | Recommended the full process. The five short-path criteria all hold (one production file, no migration directory in the repo, no lockfile in the checkout, no public contract moved, no money/auth/PII), but they measure blast radius, not what is being edited. What the short path drops includes the plan reviewer, whose Plan Contract row is precisely "no step's test asserts a value the implementation this plan specifies would not produce" — and this plan is paired test-and-implementation code inside a file that is itself a gate. Source: order 1, `skills/writing-plans/plan-document-reviewer-prompt.md:97` |
| When a document opens a fenced block and never closes it, should the script fail the document or continue? | Fail, naming the opening line | Recommended failing. The alternatives either read the document against a shape that disagrees with how it renders — reintroducing defect A through the back door — or print green for a document the script stopped checking half-way. Source: order 1, `scripts/check-no-dispatch.sh:120` fails when it cannot read its input, and this script already does the same for an unreadable file at `:264` |

## What this design does not do

- It does not correct `task-brief` or `check-links.sh`, and it does not extract a shared fence scanner across the three. Three carriers in two languages, and this repository charges unification that is really duplication.
- It does not police id form. A label the skills do not sanction is a reviewer's finding, and it already has a BLOCKING row.
- It does not change what the script reports, only what it reads. No new counts field, no new output shape.
