# Markdown Read as Flat Text Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowersplus:subagent-driven-development or superpowersplus:executing-plans to implement this plan task-by-task — the `**Execution:**` field below names which of the two this plan was handed to, and that is the one to follow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/2026-08-24-cross-references-extractor-design.md`

**Goal:** Give this repository one correct CommonMark fenced-block scanner, wire the three markdown gates to read structure through it, and remove the broken table of contents the old gate was hiding.

**Architecture:** A single module under `skills/writing-plans/scripts/` returns a per-line fenced/not mask plus the line of any unclosed fence. The two python carriers import it and delete their own logic; `task-brief` gets the same closing rule in awk, because reaching the module from another skill's directory inside the shipped plugin costs more than one small copy in a carrier measured at zero defects. The module's location is forced by packaging, not chosen: `scripts/package-codex-plugin.sh:336` fails the Codex build on any `^scripts/` path.

**Tech Stack:** `python3` standard library (`re` only) and `awk`, both already required by the files under change — spec `## External Dependencies`, which reads "None". No lockfile exists in this repository and none is added.

**Execution:** **Not started, and the path is not chosen.** The plan was written, reviewed over two rounds and approved on 2026-08-24; the execution offer was presented and the session ended before it was answered. Eight tasks across eleven files. **Whoever picks this up: no task has run.** `git log` on this branch shows spec and plan commits only — no commit touching `skills/`, `scripts/` or `tests/` — which is the check that separates a plan that never started from one whose record was lost. Ask for the path before executing, and write the answer here.

**Escalation shape** (detail and a worked example: `../../../skills/using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it. A gate verdict name (`LOST IN TRANSLATION`, `INVENTED SCOPE`, …) appears only in parentheses, never carrying the explanation.

## Global Constraints

- Zero dependencies: `python3` standard library and `git` only — spec `IR9`.
- **Every commit touching `skills/`, `scripts/`, `githooks/`, `.github/` or `hooks/` must stage `CHANGELOG.md` with it.** `scripts/check-changelog.sh:49` declares `CONTENT_PREFIXES=(skills/ scripts/ githooks/ .github/ hooks/)` and the pre-commit hook enforces it. Every task below touches one of those.
- **`githooks/pre-commit:26` runs `scripts/check-links.sh`.** A task leaving that gate red cannot commit, which is why Task 2 precedes Task 6.
- **Never chain content preparation and `git commit` in one `&&` block** — repository `CLAUDE.md`, section "Preparing a commit".
- The vendor's prose in `skills/writing-skills/anthropic-best-practices.md` is not touched. Six table-of-contents lines this project added are the whole edit there — spec `IR8`.

## Test Coverage Matrix

| Criterion | Spec criterion | Test type | Layer | Test |
|-----------|----------------|-----------|-------|------|
| T1.1 A four-backtick block containing a three-backtick block keeps the inner content fenced | IR1 | script | `tests/hooks/` | `tests/hooks/test-mdfence.sh > nested fence keeps inner content fenced` |
| T1.2 A fence opener indented by up to three spaces is recognised | IR2 | script | `tests/hooks/` | `tests/hooks/test-mdfence.sh > indented opener is recognised` |
| T1.3 A tilde fence is recognised on the same terms as a backtick fence | IR3 | script | `tests/hooks/` | `tests/hooks/test-mdfence.sh > tilde fence behaves like a backtick fence` |
| T1.4 The module imports nothing outside the standard library | IR9 | script | `tests/hooks/` | `tests/hooks/test-mdfence.sh > module imports only re` |
| T1.5 The module sits where the packager stages and the packager still forbids the root scripts path | AC19 | script | `tests/hooks/` | `tests/hooks/test-mdfence.sh > the module ships where the packager stages` |
| T2.1 The table of contents has one entry per real section and no entry without one | AC16 | script | `tests/hooks/` | `tests/hooks/test-check-links.sh > every table-of-contents anchor in anthropic-best-practices resolves` |
| T3.1 Task headings inside fenced blocks are not counted | AC1 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > fenced task headings are not counted` |
| T3.2 The announced-count comparison reads prose only | AC2 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > announced count matches when the extras are fenced` |
| T3.3 A section heading inside a fence does not start a section | AC3 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a fenced acceptance-criteria heading defines nothing` |
| T3.4 Coverage-matrix rows are read from prose only | AC5 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a fenced matrix table raises no orphan label` |
| T3.5 The printed task-criteria count is read from prose only | AC6 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > fenced task criteria are not counted` |
| T3.6 A test created inside a fenced code block is still discovered | AC8 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a fenced step still creates its test` |
| T3.7 A citation inside a fenced code block is still checked | AC9 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a fenced citation past end of file fails` |
| T3.8 An id cited inside a fenced code block still counts as cited | AC10 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a fenced undefined id still fails` |
| T4.1 An unterminated fence fails, naming the opening line | AC11 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > an unterminated fence fails naming its line` |
| T4.2 The module is resolved from the script's own path, not the working directory | IR4 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > runs from an unrelated working directory` |
| T5.1 A section ends only at a heading of the same or shallower level | AC4 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a section survives its own subsections` |
| T5.2 A criterion label carrying a letter suffix is matched | AC7 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a suffixed criterion label is still checked` |
| T5.3 `body_only` and `matrix_only` no longer exist in the file | AC12 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > no dead names survive` |
| T5.4 The nine pre-existing cases still pass unmodified | IR5 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > the nine original cases are still here` |
| T5.5 No committed document under `docs/` changes verdict except as AC4 requires | IR6 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > the committed corpus keeps its verdicts` |
| T6.1 A heading inside a fenced code block produces no anchor | AC13 | script | `tests/hooks/` | `tests/hooks/test-check-links.sh > a nested-fence heading produces no anchor` |
| T6.2 A link written inside a nested fenced block is still ignored | AC14 | script | `tests/hooks/` | `tests/hooks/test-check-links.sh > a link inside a nested fenced block is ignored` |
| T6.3 The link gate exits 0 over this repository | AC17 | script | `tests/hooks/` | `tests/hooks/test-check-links.sh > the gate passes over this repository itself` |
| T6.4 Neither python carrier contains fence-scanning logic of its own | AC18 | script | `tests/hooks/` | `tests/hooks/test-mdfence.sh > carriers hold no fence logic of their own` |
| T7.1 `task-brief` does not treat a fenced `## Task N` as a task | AC15 | script | `tests/hooks/` | `tests/hooks/test-task-brief.sh > a fenced task heading is not extracted` |
| T7.2 The branch changes only the files the spec allows | IR8 | script | `tests/hooks/` | `tests/hooks/test-task-brief.sh > the branch touches only its declared files` |
| T8.1 A matrix naming a test no code block of the plan contains exits 1 | AC20 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a matrix naming a test no code block holds fails` |
| T8.2 A matrix naming a bash case the steps create exits 0 | AC20 | script | `tests/hooks/` | `tests/hooks/test-check-cross-references.sh > a bash case named in the matrix is created` |

**`IR7` has no row, and that is a finding rather than an omission.** It requires each test to be shown failing against the pre-fix code. Nothing in this repository records a red run in a file, so no `file:line` citation can settle it and the final audit will charge it as unauditable. Every task below carries the red run as its own Step 2, so the requirement is *met*; what is missing is a way to *prove* it later. Raised with your human partner at the handoff rather than dropped.

**Conventions recorded, not imported.** `docs/testing.md:15` states every directory under `tests/` is a suite with no single entry point; `.github/workflows/ci.yml:81` holds one step per suite; `tests/hooks/` is where a script's suite lives regardless of where the script itself sits — `tests/hooks/test-check-cross-references.sh` tests a file under `skills/writing-plans/scripts/`. There is no python test convention here: every suite is bash, so the module's suite drives it through `python3 -c`.

---

### Task 1: The shared fence scanner

**Spec criterion:** `IR1 A fence closes only on the same fence character, at a length greater than or equal to the opener's, with no info string`, `IR2 indented opener`, `IR3 tilde fence`, `IR9 zero dependencies`, `AC19 the Codex archive carries the module`.

**Files:**
- Create: `skills/writing-plans/scripts/mdfence.py`
- Create: `tests/hooks/test-mdfence.sh`
- Modify: `.github/workflows/ci.yml:81` — add a step after the cross-reference one
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: `fence_mask(lines) -> (list[bool], int | None)` where the list has one entry per input line, `True` when that line is inside a fenced block **or is a fence marker itself**, and the second element is the 1-based line number of a fence that opened and never closed, or `None`. And `prose(lines) -> list[str]`, the same lines with every masked one replaced by `""`, preserving numbering.

**A new module needs its justification, and this is it:** three carriers need the same non-obvious rule, and the criterion that forces a module rather than a copy is `AC18` — neither python carrier may keep fence logic of its own. Nothing in this repository already provides it: `scripts/check-links.sh:232` and `skills/subagent-driven-development/scripts/task-brief:29` are the two existing implementations and both are the defect. The standard library has no CommonMark parser.

**Acceptance criteria:**
- T1.1: A four-backtick block containing a three-backtick block keeps the inner content masked — test: `tests/hooks/test-mdfence.sh > nested fence keeps inner content fenced`
- T1.2: A fence opener indented by one to three spaces is recognised — test: `tests/hooks/test-mdfence.sh > indented opener is recognised`
- T1.3: A tilde fence opens and closes on the same terms as a backtick fence — test: `tests/hooks/test-mdfence.sh > tilde fence behaves like a backtick fence`
- T1.4: The module's only import is `re` — test: `tests/hooks/test-mdfence.sh > module imports only re`
- T1.5: The module's path is under `skills/`, which the packager stages, and the packager's forbidden-prefix list still rejects `scripts/` — test: `tests/hooks/test-mdfence.sh > the module ships where the packager stages`

- [ ] **Step 1: Write the failing test**

Create `tests/hooks/test-mdfence.sh`:

```bash
#!/usr/bin/env bash
#
# Tests for skills/writing-plans/scripts/mdfence.py.
#
# The cases that matter are the ones the naive toggle this module replaces gets
# wrong: a three-backtick block nested inside a four-backtick block, an opener
# carrying leading spaces, and a tilde fence. Measured 2026-08-24, the naive
# toggle and this rule classify 77 structural headings differently across 6
# documents of this repository.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODULE_DIR="$REPO_ROOT/skills/writing-plans/scripts"

FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

# run_py <name> <python body> — body asserts; a raised AssertionError fails.
run_py() {
    local name="$1" body="$2"
    if python3 -c "
import sys
sys.path.insert(0, '$MODULE_DIR')
from mdfence import fence_mask, prose
$body
" 2>/tmp/mdfence-err.$$; then
        pass "$name"
    else
        fail "$name"
        sed 's/^/        /' </tmp/mdfence-err.$$
    fi
    rm -f /tmp/mdfence-err.$$
}

echo "Testing mdfence"

run_py "nested fence keeps inner content fenced" '
lines = ["before", "````markdown", "# inner", "```md", "## deep", "```", "````", "after"]
mask, unclosed = fence_mask(lines)
assert unclosed is None, unclosed
assert mask[0] is False, "line before the fence"
assert mask[2] is True, "heading inside the outer block"
assert mask[4] is True, "heading inside the nested block"
assert mask[7] is False, "line after the fence"
'

run_py "indented opener is recognised" '
lines = ["   ```", "## fenced", "   ```", "## real"]
mask, _ = fence_mask(lines)
assert mask[1] is True, "heading under an indented opener"
assert mask[3] is False, "heading after the indented close"
'

run_py "tilde fence behaves like a backtick fence" '
lines = ["~~~", "## fenced", "```", "still fenced", "~~~", "## real"]
mask, _ = fence_mask(lines)
assert mask[1] is True, "heading inside the tilde block"
assert mask[3] is True, "a backtick line does not close a tilde block"
assert mask[5] is False, "heading after the tilde close"
'

run_py "an unclosed fence is reported with its line" '
lines = ["a", "```", "## swallowed"]
mask, unclosed = fence_mask(lines)
assert unclosed == 2, unclosed
assert mask[2] is True, "everything after an unclosed opener is fenced"
'

run_py "prose blanks fenced lines and keeps numbering" '
lines = ["## real", "```", "## fenced", "```", "## also real"]
out = prose(lines)
assert len(out) == len(lines), (len(out), len(lines))
assert out[0] == "## real"
assert out[2] == ""
assert out[4] == "## also real"
'

# --- the module ships where the packager stages ----------------------------
# scripts/package-codex-plugin.sh stages `skills` wholesale and fails the build
# on any archived path beginning `scripts/`. A module at the repository root
# would reach Claude Code, whose plugin cache is a full checkout, and not Codex,
# where check-cross-references still ships and would fail to import.
packager="$REPO_ROOT/scripts/package-codex-plugin.sh"
if [ -f "$MODULE_DIR/mdfence.py" ] &&
   printf '%s' "$MODULE_DIR" | grep -q "/skills/" &&
   grep -q '\^scripts/' "$packager"; then
    pass "the module ships where the packager stages"
else
    fail "the module ships where the packager stages"
    echo "        module dir: $MODULE_DIR"
    grep -n '\^scripts/' "$packager" | sed 's/^/        /'
fi

# --- the module carries no dependency and the carriers carry no logic --------
if grep -nE "^(import|from) " "$MODULE_DIR/mdfence.py" | grep -qvE "^[0-9]+:import re$"; then
    fail "module imports only re"
    grep -nE "^(import|from) " "$MODULE_DIR/mdfence.py" | sed 's/^/        /'
else
    pass "module imports only re"
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All mdfence tests passed"
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
```

```bash
chmod +x tests/hooks/test-mdfence.sh
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `tests/hooks/test-mdfence.sh`
Expected: FAIL — every `run_py` case errors with `ModuleNotFoundError: No module named 'mdfence'`, and the import check fails with `grep: .../mdfence.py: No such file or directory`.

- [ ] **Step 3: Write the module**

Create `skills/writing-plans/scripts/mdfence.py`:

```python
"""CommonMark fenced-code detection, shared by this repository's markdown gates.

Three carriers read markdown structurally. Two of them used a toggle that flips
on any three-backtick line, which is wrong whenever a three-backtick block sits
inside a four-backtick one: the inner opener closes the outer block and its
content reads as real structure. Measured 2026-08-24 across `docs/` and
`skills/`, that toggle and the rule below disagree about 77 structural headings
in 6 documents.

This module lives beside `check-cross-references` rather than under the
repository's root `scripts/` because `scripts/package-codex-plugin.sh:336` fails
the Codex build on any archived path beginning `scripts/`, while `:241` stages
`skills` wholesale — a module at the root would ship to one harness and not the
other, and the import would fail at runtime for Codex users.
"""

import re

# CommonMark: an opener is three or more backticks or tildes, indented at most
# three spaces, optionally followed by an info string.
_FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})[ \t]*(.*)$")


def fence_mask(lines):
    """(mask, unclosed) for a list of lines.

    mask[i] is True when lines[i] is inside a fenced block OR is a fence marker
    itself — a marker is not structure either, so no caller ever wants it.
    unclosed is the 1-based line a fence opened on and never closed, else None.
    """
    mask = []
    opener = None
    opened_at = None
    for number, line in enumerate(lines, 1):
        match = _FENCE.match(line)
        if match:
            token, info = match.group(1), match.group(2).strip()
            if opener is None:
                opener, opened_at = token, number
            elif token[0] == opener[0] and len(token) >= len(opener) and not info:
                # A closer matches the opener's character, is at least as long,
                # and carries no info string. Anything else is content.
                opener, opened_at = None, None
            mask.append(True)
            continue
        mask.append(opener is not None)
    return mask, opened_at


def prose(lines):
    """`lines` with every fenced line blanked, so line numbers still line up."""
    mask, _ = fence_mask(lines)
    return ["" if mask[index] else line for index, line in enumerate(lines)]
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `tests/hooks/test-mdfence.sh`
Expected: PASS — `All mdfence tests passed`, six cases.

- [ ] **Step 5: Add the CI step**

In `.github/workflows/ci.yml`, immediately after the `Tests (cross-reference check)` step, add:

```yaml
      - name: Tests (fence scanner)
        run: tests/hooks/test-mdfence.sh
```

- [ ] **Step 6: Write the changelog entry**

**`CHANGELOG.md` has no `## [Unreleased]` section at this point — the file opens on `## [1.20.0] - 2026-08-24`, because the last release closed it.** This step creates it. Insert immediately above that heading, with one blank line on each side:

```markdown
## [Unreleased]

### Added

- **One CommonMark fenced-block scanner, shared by the markdown gates.**
  [`skills/writing-plans/scripts/mdfence.py`](skills/writing-plans/scripts/mdfence.py)
  returns a per-line fenced/not mask and the line of any unclosed fence. It sits
  beside `check-cross-references` rather than under `scripts/` because
  [`scripts/package-codex-plugin.sh:336`](scripts/package-codex-plugin.sh) fails
  the Codex build on any archived `scripts/` path while `:241` stages `skills`
  wholesale — a module at the root would reach one harness and not the other.
  Tests: [`tests/hooks/test-mdfence.sh`](tests/hooks/test-mdfence.sh).
```

- [ ] **Step 7: Verify the preparation produced what you expect**

```bash
git status --short
git diff --stat
```

Expected: four paths — `skills/writing-plans/scripts/mdfence.py`, `tests/hooks/test-mdfence.sh`, `.github/workflows/ci.yml`, `CHANGELOG.md`. Confirm the changelog hunk is present; a failed edit here is invisible if you go straight to the commit.

- [ ] **Step 8: Commit**

```bash
git add skills/writing-plans/scripts/mdfence.py tests/hooks/test-mdfence.sh .github/workflows/ci.yml CHANGELOG.md
git commit -m "feat(gates): um scanner de cerca CommonMark para os portadores de markdown"
```

- [ ] **Step 9: Verify the Codex archive on the now-clean tree**

`tests/codex/test-package-codex-plugin.sh` builds its archive from a git ref and reads its expected values from the working tree, so it only tells the truth after the commit — repository `CLAUDE.md`, "Names and paths that break silently".

Run: `tests/codex/test-package-codex-plugin.sh`
Expected: PASS, including `archive preserves executable script mode`, and no `archive contains source-only paths`.

---

### Task 2: The table of contents the broken gate approved

**Spec criterion:** `AC16 The table of contents has one entry per real section and no entry without one`.

This task precedes Task 6 for a mechanical reason: `githooks/pre-commit:26` runs `scripts/check-links.sh`, so the commit that corrects the gate cannot land while the six entries it newly rejects are still in the tree.

**Files:**
- Modify: `skills/writing-skills/anthropic-best-practices.md:16-21`
- Modify: `tests/hooks/test-check-links.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing consumed by a later task.

**Acceptance criteria:**
- T2.1: The document's table of contents has exactly one entry per level-two section other than `Contents` itself, and no entry whose anchor matches no such section — test: `tests/hooks/test-check-links.sh > every table-of-contents anchor in anthropic-best-practices resolves`

- [ ] **Step 1: Write the failing test**

Append to `tests/hooks/test-check-links.sh`, before its final summary block:

```bash
# The six entries this checks for were this project's own addition (46cf5c4) and
# pointed at headings that exist only inside fenced example blocks. The link gate
# passed them for ten weeks because its own fence mask had the same blind spot.
# This case reads the real file rather than a fixture: the defect was in shipped
# content, and a fixture would prove nothing about it.
toc_doc="$REPO_ROOT/skills/writing-skills/anthropic-best-practices.md"
toc_report="$(python3 - "$toc_doc" <<'PY'
import re
import sys

lines = open(sys.argv[1], encoding="utf-8").read().splitlines()
FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})[ \t]*(.*)$")


def slug(text):
    text = re.sub(r"`([^`]*)`", r"\1", text).strip().lower()
    text = re.sub(r"[^\w\s-]", "", text)
    return re.sub(r"\s+", "-", text)


opener, sections, entries = None, [], []
for line in lines:
    match = FENCE.match(line)
    if match:
        token, info = match.group(1), match.group(2).strip()
        if opener is None:
            opener = token
        elif token[0] == opener[0] and len(token) >= len(opener) and not info:
            opener = None
        continue
    if opener is not None:
        continue
    heading = re.match(r"^##\s+(.*?)\s*$", line)
    if heading and heading.group(1) != "Contents":
        sections.append(slug(heading.group(1)))
    entry = re.match(r"^- \[.*?\]\(#([^)]+)\)\s*$", line)
    if entry:
        entries.append(entry.group(1))

orphan = [e for e in entries if e not in sections]
missing = [s for s in sections if s not in entries]
print(f"orphan={','.join(orphan) or 'none'} missing={','.join(missing) or 'none'}")
PY
)"
if [ "$toc_report" = "orphan=none missing=none" ]; then
    pass "every table-of-contents anchor in anthropic-best-practices resolves"
else
    fail "every table-of-contents anchor in anthropic-best-practices resolves"
    echo "        $toc_report"
fi
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `tests/hooks/test-check-links.sh`
Expected: FAIL — `orphan=executive-summary,key-findings,recommendations,executive-summary-1,key-findings-1,recommendations-1 missing=none`.

- [ ] **Step 3: Remove the six entries**

Delete lines 16 through 21 of `skills/writing-skills/anthropic-best-practices.md` — the six list items whose labels are `Executive summary`, `Key findings` and `Recommendations`, twice over. Touch nothing else in that file.

```bash
python3 - <<'PY'
from pathlib import Path

path = Path("skills/writing-skills/anthropic-best-practices.md")
lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
doomed = lines[15:21]
expected = ["Executive summary", "Key findings", "Recommendations"] * 2
assert [l.split("[")[1].split("]")[0] for l in doomed] == expected, doomed
path.write_text("".join(lines[:15] + lines[21:]), encoding="utf-8")
print("six entries removed")
PY
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `tests/hooks/test-check-links.sh`
Expected: PASS — every case, including `every table-of-contents anchor in anthropic-best-practices resolves`.

- [ ] **Step 5: Write the changelog entry**

**`### Fixed` does not exist yet — Task 1 created `## [Unreleased]` with only `### Added`.** This step creates it, after the `### Added` block:

```markdown
### Fixed

- **Six table-of-contents entries pointed at headings that do not exist.** In
  [`skills/writing-skills/anthropic-best-practices.md`](skills/writing-skills/anthropic-best-practices.md),
  the entries labelled `Executive summary`, `Key findings` and `Recommendations`
  — twice each — targeted lines of a report template shown inside a fenced
  example, which produces no heading and therefore no anchor. They were this
  project's own addition in `46cf5c4`, generated by walking the file as flat
  text: their order in the list is exactly where those lines sit in the
  document. `scripts/check-links.sh` passed them because its fence mask had the
  same blind spot, which is the defect the same release corrects. Measured: the
  list had one entry per real section once these six were removed, with none
  left over on either side.
```

- [ ] **Step 6: Verify the preparation produced what you expect**

```bash
git diff --stat
git diff -- skills/writing-skills/anthropic-best-practices.md
```

Expected: three paths, and the document's diff is six deleted lines and nothing else.

- [ ] **Step 7: Commit**

```bash
git add skills/writing-skills/anthropic-best-practices.md tests/hooks/test-check-links.sh CHANGELOG.md
git commit -m "fix(writing-skills): seis entradas de sumario apontando para headings cercados"
```

---

### Task 3: `check-cross-references` reads structure through the mask

**Spec criterion:** `AC1 Task headings inside fenced code blocks are not counted`, `AC2 announced-count reads prose only`, `AC3 a fenced section heading starts nothing`, `AC5 matrix rows read from prose only`, `AC6 the printed task-criteria count reads prose only`, `AC8 tests inside fences are still discovered`, `AC9 citations inside fences are still checked`, `AC10 ids cited inside fences still count as cited`.

**Files:**
- Modify: `skills/writing-plans/scripts/check-cross-references:58-166`
- Modify: `tests/hooks/test-check-cross-references.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `fence_mask(lines) -> (list[bool], int | None)` and `prose(lines) -> list[str]` from `skills/writing-plans/scripts/mdfence.py`, its sibling.
- Produces: nothing consumed by a later task.

**Acceptance criteria:**
- T3.1: A plan whose only extra `## Task` headings are fenced reports the prose count — test: `tests/hooks/test-check-cross-references.sh > fenced task headings are not counted`
- T3.2: The same plan announcing that prose count exits 0 — test: `tests/hooks/test-check-cross-references.sh > announced count matches when the extras are fenced`
- T3.3: A document whose only `## Acceptance Criteria` heading is fenced defines no ids — test: `tests/hooks/test-check-cross-references.sh > a fenced acceptance-criteria heading defines nothing`
- T3.4: A fenced example matrix table raises no orphan-label failure — test: `tests/hooks/test-check-cross-references.sh > a fenced matrix table raises no orphan label`
- T3.5: The `task criteria` count in the summary omits fenced labels — test: `tests/hooks/test-check-cross-references.sh > fenced task criteria are not counted`
- T3.6: A test created inside a fenced block is still discovered — test: `tests/hooks/test-check-cross-references.sh > a fenced step still creates its test`
- T3.7: A citation inside a fenced block that points past the end of its file fails — test: `tests/hooks/test-check-cross-references.sh > a fenced citation past end of file fails`
- T3.8: An id cited only inside a fenced block is still charged as cited — test: `tests/hooks/test-check-cross-references.sh > a fenced undefined id still fails`

- [ ] **Step 1: Write the failing tests**

Append to `tests/hooks/test-check-cross-references.sh`, before its final summary block. `CLEAN_PLAN` and `CLEAN_SPEC` are defined earlier in that file and are reused verbatim:

````bash
# --- fence awareness ------------------------------------------------------
# A plan that documents the plan format carries `## Task N` inside fenced
# examples. Measured 2026-08-24: the fence-blind extractor reported 17 tasks for
# a real plan carrying five, and 10 for a document carrying none.
FENCED_TASKS="$(printf '%s\n' "$CLEAN_PLAN" '' '````markdown' '## Task 7: an example' '' '```js' 'it("nothing", () => {})' '```' '````')"

run_case "fenced task headings are not counted" 0 "$FENCED_TASKS

This plan has 1 task."

run_case "announced count matches when the extras are fenced" 0 "$FENCED_TASKS

This plan has 1 task."

run_case "a fenced acceptance-criteria heading defines nothing" 0 '# Doc

```markdown
## Acceptance Criteria

- AC1 only an example
```

The design also satisfies AC9, which no list defines.'

run_case "a fenced matrix table raises no orphan label" 0 "${CLEAN_PLAN}

An example of the shape:

\`\`\`markdown
| T9.9 | > a test nobody wrote |
\`\`\`"

run_case "fenced task criteria are not counted" 0 "${CLEAN_PLAN}

\`\`\`markdown
- T4.4 an example criterion
\`\`\`"

run_case "a fenced citation past end of file fails" 1 "${CLEAN_SPEC}

\`\`\`bash
# see \`src/verify.ts:99\` for the detail
\`\`\`"

# AC8: a plan creates its tests inside fenced code blocks, so the test finder
# must keep reading them. This case is the guard that the fence work above did
# not reach into it — the plan's only test lives inside a fenced block, and the
# matrix names it.
run_case "a fenced step still creates its test" 0 '# Plan

## Task 1: Build it

Acceptance criteria:
- T1.1 rejects the bad input

Step 1: write the test.

```js
it("rejects the bad input", () => {})
```

## Test Coverage Matrix

| Criterion | Test |
|---|---|
| T1.1 | > rejects the bad input |'

run_case "a fenced undefined id still fails" 1 "${CLEAN_SPEC}

\`\`\`markdown
The design also satisfies AC9, which no list defines.
\`\`\`"
````

- [ ] **Step 2: Run the tests to verify they fail**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: FAIL on the first five new cases — `fenced task headings are not counted` and `announced count matches when the extras are fenced` report `expected exit 0, got 1` with `the document announces 1 tasks and carries 2`; `a fenced acceptance-criteria heading defines nothing` reports `ids cited but not defined … AC9`; `a fenced matrix table raises no orphan label` reports an orphan label for the example row inside the fence; `fenced task criteria are not counted` reports the fenced example criterion as having no matrix row. The last two — `a fenced citation past end of file fails` and `a fenced undefined id still fails` — PASS already: they are the regression guards for the extractors that must stay fence-blind, and they go red only if the fix over-reaches.

- [ ] **Step 3: Wire the mask in**

In `skills/writing-plans/scripts/check-cross-references`, replace the bash line that starts the python heredoc — currently `python3 - "$doc" "$root" <<'PY'` at line 58 — with:

```bash
script_dir="$(cd "$(dirname "$0")" && pwd)"
python3 - "$doc" "$root" "$script_dir" <<'PY'
```

Then, inside the python body, after `lines = text.splitlines()`, add:

```python
sys.path.insert(0, sys.argv[3])
from mdfence import fence_mask, prose

fenced, unclosed_at = fence_mask(lines)
prose_lines = prose(lines)
prose_text = "\n".join(prose_lines)
```

Change these five extractors to read `prose_lines` / `prose_text` instead of `lines` / `text`, and nothing else:

```python
# was: for i, line in enumerate(lines):
for i, line in enumerate(prose_lines):

# was: all_task_crit = set(TASK_CRIT.findall(text))
all_task_crit = set(TASK_CRIT.findall(prose_text))

# was: matrix_rows = [ln for ln in lines ...]
matrix_rows = [
    ln for ln in prose_lines
    if ln.lstrip().startswith("|") and TASK_CRIT.search(ln)
]

# was: for ln in lines:   (the outside_matrix loop)
for ln in prose_lines:

# was: task_headings = [ln for ln in lines if ...]
task_headings = [ln for ln in prose_lines if re.match(r"^#{2,3}\s+Task\s+\d+\b", ln)]

# was: re.finditer(r"\b(?:has|with)\s+(\d+)\s+tasks?\b", text, re.I)
for m in re.finditer(r"\b(?:has|with)\s+(\d+)\s+tasks?\b", prose_text, re.I):
```

**Leave `cited_ac`, `TEST_DEF` and `CITATION` reading the raw `text`.** Each has a measured reason recorded in the spec's `### Which extractors become fence-aware` table, and the last two new tests in Step 1 fail if any of them is converted.

Inside `section()`, the loop iterates `lines`; change it to iterate `prose_lines` so a fenced heading neither starts nor ends a section. The level fix is Task 5's, not this task's — leave the terminator condition alone.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: PASS — all sixteen cases, the nine pre-existing ones unchanged.

- [ ] **Step 5: Write the changelog entry**

Under `## [Unreleased]`, at the end of the `### Fixed` subsection Task 2 created, add:

```markdown
- **`check-cross-references` read the whole document as flat text.** Every
  structural extractor in
  [`skills/writing-plans/scripts/check-cross-references`](skills/writing-plans/scripts/check-cross-references)
  now reads through the shared fence scanner: sections, task headings, the
  announced-task-count comparison, coverage-matrix rows and the task-criteria
  count. Three extractors deliberately keep reading the raw text — the test
  finder, because a plan creates its tests inside fenced blocks; the citation
  pass, because no `file:line` citation in `docs/` sits inside a fence and one
  in a code comment is legitimate; and the id-citation pass, because a real
  citation of `IR2` does live inside a fence. Measured: the extractor reported
  `tasks present 17` for a plan carrying five real task headings, and failed a
  plan that correctly announced its own count.
```

- [ ] **Step 6: Verify the preparation produced what you expect**

```bash
git diff --stat
grep -n 'prose_lines\|prose_text\|fence_mask' skills/writing-plans/scripts/check-cross-references
```

Expected: three paths; and the grep shows the import plus exactly the six converted call sites, with `cited_ac`, `TEST_DEF` and `CITATION` absent from the list.

- [ ] **Step 7: Commit**

```bash
git add skills/writing-plans/scripts/check-cross-references tests/hooks/test-check-cross-references.sh CHANGELOG.md
git commit -m "fix(writing-plans): extratores estruturais leem markdown pela mascara de cerca"
```

---

### Task 4: An unterminated fence fails, and the module resolves from the script

**Spec criterion:** `AC11 A document that opens a fence and never closes it exits 1, and the message names the line the fence opened on`, `IR4 Each carrier resolves the module from its own path, not from the working directory`.

**Files:**
- Modify: `skills/writing-plans/scripts/check-cross-references`
- Modify: `tests/hooks/test-check-cross-references.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `fence_mask(lines) -> (list[bool], int | None)` — the second element, wired but unused by Task 3.
- Produces: nothing consumed by a later task.

**Acceptance criteria:**
- T4.1: A document with an unclosed fence exits 1 and the message contains the opener's line number — test: `tests/hooks/test-check-cross-references.sh > an unterminated fence fails naming its line`
- T4.2: The script works when invoked by absolute path from a directory that is not the repository — test: `tests/hooks/test-check-cross-references.sh > runs from an unrelated working directory`

- [ ] **Step 1: Write the failing tests**

Append to `tests/hooks/test-check-cross-references.sh`, before its final summary block:

```bash
# An unclosed fence swallows every heading after it, which turns the checks off
# rather than failing them — a green verdict on a document the script stopped
# reading. scripts/check-no-dispatch.sh:120 is this project's precedent for
# failing when a gate cannot read its input.
run_case "an unterminated fence fails naming its line" 1 "${CLEAN_SPEC}

\`\`\`markdown
## Acceptance Criteria
"

# The script is packaged with the plugin and run against arbitrary repositories,
# so it must find its module beside itself and never relative to the caller's
# working directory.
elsewhere="$(mktemp -d "$TEST_ROOT/elsewhere.XXXXXX")"
away_repo="$TEST_ROOT/away"
make_repo "$away_repo"
printf '%s\n' "$CLEAN_SPEC" >"$away_repo/docs/doc.md"
away_exit=0
(cd "$elsewhere" && "$SCRIPT_UNDER_TEST" "$away_repo/docs/doc.md" "$away_repo" >/dev/null 2>&1) || away_exit=$?
if [ "$away_exit" -eq 0 ]; then
    pass "runs from an unrelated working directory"
else
    fail "runs from an unrelated working directory — exit $away_exit"
    (cd "$elsewhere" && "$SCRIPT_UNDER_TEST" "$away_repo/docs/doc.md" "$away_repo" 2>&1) | sed 's/^/        /'
fi
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: FAIL on `an unterminated fence fails naming its line` — `expected exit 1, got 0`. The second case, `runs from an unrelated working directory`, PASSES already, because Task 3 wired the module path from `dirname "$0"` rather than the working directory; it is the regression guard that keeps it that way.

- [ ] **Step 3: Report the unclosed fence**

In `skills/writing-plans/scripts/check-cross-references`, immediately after the `fenced, unclosed_at = fence_mask(lines)` line added in Task 3, add:

```python
if unclosed_at is not None:
    failures.append(
        f"a fenced block opens at line {unclosed_at} and never closes — "
        "every heading after it reads as fenced, which turns the checks off "
        "rather than failing them"
    )
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: PASS — all eighteen cases.

- [ ] **Step 5: Write the changelog entry**

Under `## [Unreleased]`, at the end of the `### Fixed` subsection, add:

```markdown
- **An unterminated fence now fails the document instead of silencing the
  checks.** Everything after an unclosed opener reads as fenced, so the task
  count falls to zero and the criteria list empties — a green verdict on a
  document the gate stopped reading half-way. It now exits 1 naming the line the
  fence opened on, following
  [`scripts/check-no-dispatch.sh:120`](scripts/check-no-dispatch.sh), which
  fails when it cannot read what it was asked to check. Measured: no document in
  this repository has an unclosed fence today, so the rule changes no current
  verdict.
```

- [ ] **Step 6: Verify the preparation produced what you expect**

```bash
git diff --stat
git diff -- skills/writing-plans/scripts/check-cross-references
```

Expected: three paths, and the script's diff is the five added lines and nothing else.

- [ ] **Step 7: Commit**

```bash
git add skills/writing-plans/scripts/check-cross-references tests/hooks/test-check-cross-references.sh CHANGELOG.md
git commit -m "fix(writing-plans): cerca nao fechada reprova o documento em vez de calar as checagens"
```

---

### Task 5: Section levels, the letter suffix, and the dead names

**Spec criterion:** `AC4 section() ends a section only at a heading of the same or shallower level`, `AC7 a criterion label carrying a letter suffix is matched`, `AC12 body_only and matrix_only no longer exist`, `IR5 the nine pre-existing cases still pass unmodified`, `IR6 no committed document changes verdict except as AC4 requires`.

**Files:**
- Modify: `skills/writing-plans/scripts/check-cross-references:72-87,125-126`
- Modify: `tests/hooks/test-check-cross-references.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `prose(lines) -> list[str]` from `mdfence`, already imported by Task 3.
- Produces: nothing consumed by a later task.

**Acceptance criteria:**
- T5.1: A spec whose `## Acceptance Criteria` organises criteria under `###` subsections defines all of them — test: `tests/hooks/test-check-cross-references.sh > a section survives its own subsections`
- T5.2: A plan whose criterion label carries a trailing letter, and whose matrix row names a test no step creates, exits 1 — test: `tests/hooks/test-check-cross-references.sh > a suffixed criterion label is still checked`
- T5.3: The strings `body_only` and `matrix_only` do not appear in the script — test: `tests/hooks/test-check-cross-references.sh > no dead names survive`
- T5.4: The nine case names the suite carried before this branch are all still present — test: `tests/hooks/test-check-cross-references.sh > the nine original cases are still here`
- T5.5: Every committed document under `docs/` holds the exit code it held before the branch, except `2026-08-21-upstream-consult-fixes-design.md`, whose fourteen fabricated dangling-id failures disappear — test: `tests/hooks/test-check-cross-references.sh > the committed corpus keeps its verdicts`

- [ ] **Step 1: Write the failing tests**

Append to `tests/hooks/test-check-cross-references.sh`, before its final summary block:

```bash
# section() started on `## <title>` and returned at the next heading of ANY
# depth, so a section organising its criteria under `###` ended at its own first
# subsection. Measured 2026-08-24 on a committed spec: the section returned zero
# ids where it holds 21 — nineteen AC it defines plus two IR cited inside it —
# and fourteen were reported as cited-but-undefined.
run_case "a section survives its own subsections" 0 '# Spec

## Acceptance Criteria

### First group

- AC1 The thing happens

### Second group

- AC2 The other thing happens

## Implicit Requirements

- IR1 It logs the failure

## Codebase Findings

Both are grounded in the module under test.'

# TASK_CRIT carried no optional letter suffix while AC_IR on the line above did.
# Anchored with \b, `T1.1a` matched nothing at all, so the matrix row stopped
# being a matrix row and the three checks that depend on it stopped running.
run_case "a suffixed criterion label is still checked" 1 "$(printf '%s' "$CLEAN_PLAN" |
    sed 's/T1\.1/T1.1a/g; s/| > rejects the bad input |/| > a test nobody wrote |/')"

# IR5: the nine cases this suite carried before the branch are named here, so
# a later edit that quietly drops one is a failure rather than a smaller suite.
missing_original=0
for original in \
    "clean spec passes" \
    "spec citing an undefined id fails" \
    "spec citing past the end of a file fails" \
    "spec citing a file that does not exist fails" \
    "clean plan passes" \
    "matrix label with no criterion in a task body fails" \
    "task criterion with no matrix row fails" \
    "matrix naming a test no step creates fails" \
    "announced task count that disagrees fails"; do
    if ! grep -Fq "\"$original\"" "$0"; then
        echo "        missing: $original"
        missing_original=$((missing_original + 1))
    fi
done
if [ "$missing_original" -eq 0 ]; then
    pass "the nine original cases are still here"
else
    fail "the nine original cases are still here — $missing_original dropped"
fi

if grep -q 'body_only\|matrix_only' "$SCRIPT_UNDER_TEST"; then
    fail "no dead names survive"
    grep -n 'body_only\|matrix_only' "$SCRIPT_UNDER_TEST" | sed 's/^/        /'
else
    pass "no dead names survive"
fi

# IR6: the committed corpus keeps its verdicts. The one document that changes is
# the one AC4 exists for, and it changes by LOSING a fabricated failure while
# keeping the real one, so its exit code does not move.
corpus_moved=0
for doc in "$REPO_ROOT"/docs/superpowers/specs/*.md "$REPO_ROOT"/docs/superpowers/plans/*.md; do
    before=0
    git -C "$REPO_ROOT" show "$BASE_REF:skills/writing-plans/scripts/check-cross-references" \
        >"$TEST_ROOT/ccr-before" 2>/dev/null || continue
    chmod +x "$TEST_ROOT/ccr-before"
    "$TEST_ROOT/ccr-before" "$doc" "$REPO_ROOT" >/dev/null 2>&1 || before=$?
    after=0
    "$SCRIPT_UNDER_TEST" "$doc" "$REPO_ROOT" >/dev/null 2>&1 || after=$?
    if [ "$before" != "$after" ]; then
        echo "        $(basename "$doc"): $before -> $after"
        corpus_moved=$((corpus_moved + 1))
    fi
done
if [ "$corpus_moved" -eq 0 ]; then
    pass "the committed corpus keeps its verdicts"
else
    fail "the committed corpus keeps its verdicts — $corpus_moved document(s) moved"
fi
```

Add this line next to the other path variables at the top of the file, so the corpus case can reach the pre-branch script:

```bash
BASE_REF="${BASE_REF:-$(git -C "$REPO_ROOT" merge-base main HEAD 2>/dev/null || echo main)}"
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: FAIL on `a section survives its own subsections` (`expected exit 0, got 1`, reporting `ids cited but not defined … AC2`), on `a suffixed criterion label is still checked` (`expected exit 1, got 0` — the row goes invisible and the missing test is never checked), and on `no dead names survive`. The corpus case PASSES already: neither `section()` nor `TASK_CRIT` has been touched yet, so before and after are the same script.

- [ ] **Step 3: Fix the three**

In `skills/writing-plans/scripts/check-cross-references`, replace the whole of `section()` with:

```python
HEADING = re.compile(r"^(#{1,6})\s")


def section(title_re):
    """Body of the first `## <title>` section, to the next same-or-shallower heading."""
    start = None
    level = None
    for i, line in enumerate(prose_lines):
        match = HEADING.match(line)
        if not match:
            continue
        if start is not None:
            if len(match.group(1)) <= level:
                return "\n".join(lines[start:i])
            continue
        if re.match(rf"^#{{2,3}}\s+{title_re}\s*$", line, re.I):
            start = i + 1
            level = len(match.group(1))
    return "\n".join(lines[start:]) if start is not None else None
```

Give `TASK_CRIT` the suffix `AC_IR` already carries:

```python
TASK_CRIT = re.compile(r"\b(T\d+\.\d+[a-z]?)\b")
```

Delete the two dead assignments, keeping the comment beneath them:

```python
# A label that appears ONLY inside matrix rows is defined nowhere else.
outside_matrix = set()
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: PASS — all twenty-two cases.

- [ ] **Step 5: Confirm the one document that moves, moves the right way**

```bash
./skills/writing-plans/scripts/check-cross-references \
    docs/superpowers/specs/2026-08-21-upstream-consult-fixes-design.md . 2>&1 | head -4
```

Expected: the summary line reads `AC/IR defined 26`, and the `ids cited but not defined` failure is gone. The `citations that do not open` failure remains — that one is a real stale citation in that document, not a defect of this gate.

- [ ] **Step 6: Write the changelog entry**

Under `## [Unreleased]`, at the end of the `### Fixed` subsection Task 2 created, add:

```markdown
- **A section was terminated by its own subsection, and a criterion label with a
  letter suffix matched nothing.** `section()` in
  [`skills/writing-plans/scripts/check-cross-references`](skills/writing-plans/scripts/check-cross-references)
  used one pattern for both ends, so a `## Acceptance Criteria` organising its
  items under `###` ended at its first subsection — measured on a committed
  spec, it returned zero ids where the section defines 21, and fourteen ids were
  reported as cited-but-undefined. Separately, `TASK_CRIT` carried no optional
  letter suffix while the pattern on the line above it did, so a label written
  `T1.1a` matched nothing at all and its coverage-matrix row stopped being read
  as a row: measured, the same plan exits 1 with `T1.1` and 0 with `T1.1a`, a
  false pass one character wide. Two names assigned and never read were removed
  with them.
```

- [ ] **Step 7: Verify the preparation produced what you expect**

```bash
git diff --stat
grep -c 'body_only\|matrix_only' skills/writing-plans/scripts/check-cross-references || echo "0 — dead names gone"
```

Expected: three paths, and the grep reports no matches.

- [ ] **Step 8: Commit**

```bash
git add skills/writing-plans/scripts/check-cross-references tests/hooks/test-check-cross-references.sh CHANGELOG.md
git commit -m "fix(writing-plans): nivel de secao, sufixo de letra no id e dois nomes mortos"
```

---

### Task 6: `check-links.sh` reads through the same scanner

**Spec criterion:** `AC13 A heading inside a fenced code block produces no anchor`, `AC14 links inside fenced code blocks are still ignored`, `AC17 the link gate exits 0 over this repository`, `AC18 neither python carrier contains fence-scanning logic of its own`.

**Files:**
- Modify: `scripts/check-links.sh:74,226-239`
- Modify: `tests/hooks/test-check-links.sh`
- Modify: `tests/hooks/test-mdfence.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `prose(lines) -> list[str]` from `skills/writing-plans/scripts/mdfence.py`. This gate is repository-only — it runs from the repository root (`scripts/check-links.sh:42`) and already reads `skills/**/*.md` as its corpus — so it reaches the module by relative path.
- Produces: nothing consumed by a later task.

**Acceptance criteria:**
- T6.1: A document whose only `## Heading` sits inside a four-backtick block containing a three-backtick block, linked as `#heading`, exits 1 — test: `tests/hooks/test-check-links.sh > a nested-fence heading produces no anchor`
- T6.2: A link written inside a three-backtick block nested in a four-backtick block is not checked — test: `tests/hooks/test-check-links.sh > a link inside a nested fenced block is ignored`
- T6.3: The gate exits 0 when run over this repository itself, not a fixture tree — test: `tests/hooks/test-check-links.sh > the gate passes over this repository itself`
- T6.4: Neither `check-links.sh` nor `check-cross-references` defines a fence pattern or a fence toggle of its own — test: `tests/hooks/test-mdfence.sh > carriers hold no fence logic of their own`

- [ ] **Step 1: Write the failing tests**

Append to `tests/hooks/test-check-links.sh`, before its final summary block:

```bash
# The naive toggle flipped on any three-backtick line, so a three-backtick block
# nested inside a four-backtick one closed the outer block and its headings
# became real anchors. Measured 2026-08-24: six links in a shipped skill file
# resolved against headings that exist only inside an example.
T="$(new_tree)"
printf '# Doc\n\n[to the example](#inner-heading)\n\n````markdown\n# Template\n\n```md\n## Inner heading\n```\n````\n' \
    > "$T/README.md"
assert_run 1 "a nested-fence heading produces no anchor" "$T" "inner-heading"

# AC14: the other half of the same change. Blanking MORE than before would break
# the pass that ignores links inside code; the nested shape is where a wider
# mask would reach first.
T="$(new_tree)"
printf '# Doc\n\n````markdown\n# Template\n\n```bash\ncat [not](a/link.md)\n```\n````\n' \
    > "$T/README.md"
assert_run 0 "a link inside a nested fenced block is ignored" "$T"

# AC17: every other case here runs the gate over a throwaway tree. This one runs
# it over the repository, which is the only thing that answers whether the two
# halves of this branch — the corrected mask and the corrected table of contents
# — actually agree in place.
repo_exit=0
"$REPO_ROOT/scripts/check-links.sh" >/dev/null 2>&1 || repo_exit=$?
if [ "$repo_exit" -eq 0 ]; then
    pass "the gate passes over this repository itself"
else
    fail "the gate passes over this repository itself — exit $repo_exit"
    "$REPO_ROOT/scripts/check-links.sh" 2>&1 | sed 's/^/        /'
fi
```

And append to `tests/hooks/test-mdfence.sh`, before its final summary block:

```bash
# AC18: one scanner, not three. A carrier that keeps its own pattern is a copy
# that will drift, which is the defect this module exists to end.
carrier_logic=0
for carrier in "$REPO_ROOT/scripts/check-links.sh" \
               "$REPO_ROOT/skills/writing-plans/scripts/check-cross-references"; do
    if grep -nE 'in_fence|infence|FENCE = re\.compile|`\{3,\}' "$carrier" >/dev/null 2>&1; then
        echo "        $(basename "$carrier"):"
        grep -nE 'in_fence|infence|FENCE = re\.compile|`\{3,\}' "$carrier" | sed 's/^/          /'
        carrier_logic=$((carrier_logic + 1))
    fi
done
if [ "$carrier_logic" -eq 0 ]; then
    pass "carriers hold no fence logic of their own"
else
    fail "carriers hold no fence logic of their own — $carrier_logic carrier(s)"
fi
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `tests/hooks/test-check-links.sh`
Expected: FAIL on `a nested-fence heading produces no anchor` — `expected exit 1, got 0`, because the naive mask leaves the fence at the inner opener and `## Inner heading` becomes a real anchor. `a link inside a nested fenced block is ignored` PASSES already: it is the guard that this task's wider mask does not start blanking prose, and it goes red only if the fix over-reaches.

**`the gate passes over this repository itself` also passes already, and that is stated rather than hidden.** Task 2 removed the six entries the corrected mask would reject, and the pre-commit hook (`githooks/pre-commit:26`) forces that order — so by the time this task runs, the conjunction it asserts is already true. Its red state is real but was measured before Task 2, and it is Defect E of the spec: the corrected mask over the uncorrected table of contents moved the gate from exit 0 to exit 1 on six named links. **This criterion is a regression guard, not a red-to-green reproduction**, and under `IR7` that is the one place in this plan where the red run lives in the spec's measurement instead of in the step below.

Run: `tests/hooks/test-mdfence.sh`
Expected: FAIL on `carriers hold no fence logic of their own`, listing `check-links.sh:74` — `FENCE = re.compile(...)` — and its `in_fence` toggle.

- [ ] **Step 3: Convert the carrier**

In `scripts/check-links.sh`, delete the `FENCE` definition at line 74. Then replace the whole of `strip_fences` with a call into the module — the script has already `cd`'d to the repository root at line 42, so the relative path resolves:

```python
sys.path.insert(0, "skills/writing-plans/scripts")
from mdfence import prose


def strip_fences(text):
    """Blank out fenced code blocks, keeping line numbers intact.

    A bash comment inside a fenced block looks exactly like a heading, and a
    sample command containing brackets looks exactly like a link. The rule
    itself lives in skills/writing-plans/scripts/mdfence.py, shared with
    check-cross-references — this repository had two implementations of it and
    both were wrong the same way.
    """
    return prose(text.splitlines())
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `tests/hooks/test-check-links.sh`
Expected: PASS — every case, including the three this task added: `a nested-fence heading produces no anchor`, `a link inside a nested fenced block is ignored`, and `the gate passes over this repository itself`. The suite's pre-existing `links inside fenced code are ignored` must still pass too: it is the guard that the wider mask did not start blanking prose.

Run: `tests/hooks/test-mdfence.sh`
Expected: PASS — including `carriers hold no fence logic of their own`.

Run: `scripts/check-links.sh`
Expected: exit 0, and the summary line names the local links, the URLs on the diet, and the section references.

- [ ] **Step 5: Write the changelog entry**

Under `## [Unreleased]`, at the end of the `### Fixed` subsection Task 2 created, add:

```markdown
- **`scripts/check-links.sh` approved links whose anchors did not exist.** Its
  fence mask flipped on any three-backtick line, so a three-backtick block
  nested inside a four-backtick one closed the outer block and the headings
  inside the example became real anchors. Measured 2026-08-24: replacing the
  mask with the CommonMark rule and changing nothing else moved the gate from
  exit 0 to exit 1, naming six links in
  [`skills/writing-skills/anthropic-best-practices.md`](skills/writing-skills/anthropic-best-practices.md)
  whose targets are all inside fenced blocks. It now shares the scanner with
  `check-cross-references`, and a test asserts that neither carrier keeps fence
  logic of its own.
```

- [ ] **Step 6: Verify the preparation produced what you expect**

```bash
git diff --stat
grep -nE 'in_fence|FENCE = re\.compile' scripts/check-links.sh || echo "0 — no fence logic left"
```

Expected: four paths, and the grep reports no matches.

- [ ] **Step 7: Commit**

```bash
git add scripts/check-links.sh tests/hooks/test-check-links.sh tests/hooks/test-mdfence.sh CHANGELOG.md
git commit -m "fix(gates): check-links le cercas pela regra CommonMark, e nao pelo alternador"
```

---

### Task 7: `task-brief` gets the same closing rule, in awk

**Spec criterion:** `AC15 task-brief does not treat a ## Task N heading inside a fenced block as a task`, `IR8 the branch changes only the files the spec allows`.

**Files:**
- Modify: `skills/subagent-driven-development/scripts/task-brief:28-35`
- Create: `tests/hooks/test-task-brief.sh`
- Modify: `.github/workflows/ci.yml`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nothing. **This carrier keeps its own implementation deliberately**, and the reason is the criterion `IR8` plus the packaging constraint: reaching `skills/writing-plans/scripts/mdfence.py` from `skills/subagent-driven-development/scripts/` would make one shipped skill depend on another's internals, and this script was measured at zero divergence — the copy is a smaller structure than the cross-skill dependency.
- Produces: nothing consumed by a later task.

**Acceptance criteria:**
- T7.1: A plan whose only `## Task 2` sits inside a four-backtick example yields an empty brief for task 2 — test: `tests/hooks/test-task-brief.sh > a fenced task heading is not extracted`
- T7.2: `git diff --name-only` against the branch point lists only the files the spec allows — test: `tests/hooks/test-task-brief.sh > the branch touches only its declared files`

- [ ] **Step 1: Write the failing test**

Create `tests/hooks/test-task-brief.sh`:

`````bash
#!/usr/bin/env bash
#
# Tests for skills/subagent-driven-development/scripts/task-brief.
#
# The script had one assertion before this suite existed — in
# tests/claude-code/test-sdd-workspace.sh, which checks where the brief file
# lands rather than what it contains, and which CI does not run. Measured
# 2026-08-24, its fence handling had diverged from nothing on the current
# corpus; this suite is what keeps that true.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TASK_BRIEF="$REPO_ROOT/skills/subagent-driven-development/scripts/task-brief"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

echo "Testing task-brief"

# --- a fenced task heading is not a task ----------------------------------
repo="$TEST_ROOT/repo"
mkdir -p "$repo"
git -C "$repo" init -q
cat >"$repo/plan.md" <<'PLAN'
# Plan

## Task 1: the real one

Body of the real task.

````markdown
## Task 2: only an example

```js
it("nothing", () => {})
```
````

Trailing prose.
PLAN
git -C "$repo" add -A
git -C "$repo" -c user.email=t@t -c user.name=t commit -qm fixture

brief="$(cd "$repo" && "$TASK_BRIEF" plan.md 2 "$TEST_ROOT/brief-2.md" >/dev/null 2>&1; echo "$TEST_ROOT/brief-2.md")"
if [ ! -s "$brief" ]; then
    pass "a fenced task heading is not extracted"
else
    fail "a fenced task heading is not extracted"
    sed 's/^/        /' "$brief"
fi

# --- the branch touches only its declared files ---------------------------
ALLOWED='^(skills/writing-plans/scripts/(mdfence\.py|check-cross-references)|skills/writing-skills/anthropic-best-practices\.md|skills/subagent-driven-development/scripts/task-brief|scripts/check-links\.sh|tests/hooks/test-(mdfence|check-cross-references|check-links|task-brief)\.sh|\.github/workflows/ci\.yml|CHANGELOG\.md|docs/superpowers/(specs|plans)/2026-08-24-cross-references-extractor.*\.md)$'
base="$(git -C "$REPO_ROOT" merge-base main HEAD 2>/dev/null || echo "")"
if [ -z "$base" ]; then
    pass "the branch touches only its declared files (no base to compare)"
else
    stray="$(git -C "$REPO_ROOT" diff --name-only "$base"..HEAD | grep -Ev "$ALLOWED" || true)"
    if [ -z "$stray" ]; then
        pass "the branch touches only its declared files"
    else
        fail "the branch touches only its declared files"
        printf '%s\n' "$stray" | sed 's/^/        /'
    fi
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All task-brief tests passed"
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
`````

```bash
chmod +x tests/hooks/test-task-brief.sh
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `tests/hooks/test-task-brief.sh`
Expected: FAIL on `a fenced task heading is not extracted` — the brief file is non-empty and contains `## Task 2: only an example`, because the awk toggle left the fence at the inner three-backtick opener.

- [ ] **Step 3: Give the awk the closing rule**

In `skills/subagent-driven-development/scripts/task-brief`, replace the awk program's fence rule. `{n,m}` repetition is not portable across awk implementations, so each of the three optional leading spaces is grouped **individually** — `^( ?)( ?)( ?)` — and the fence run is measured with `length()` after the spaces are stripped. Writing them as `^ ?  ?  ?` instead makes each pair's first space mandatory: measured, that pattern matches no unindented fence at all, which is every fence in the fixture below and nearly every fence in this repository.

```awk
awk -v n="$n" '
  # CommonMark: a fence closes on the same character, at a length greater than
  # or equal to the opener, with no info string. The old rule flipped on any
  # three-backtick line, so a nested block closed the outer one and its
  # headings read as real tasks.
  match($0, /^( ?)( ?)( ?)(`+|~+)/) {
    tok = substr($0, RSTART, RLENGTH)
    sub(/^ +/, "", tok)
    if (length(tok) >= 3) {
      rest = substr($0, RSTART + RLENGTH)
      gsub(/[ \t]/, "", rest)
      if (opener == "") { opener = tok }
      else if (substr(tok, 1, 1) == substr(opener, 1, 1) && length(tok) >= length(opener) && rest == "") { opener = "" }
      if (intask) print
      next
    }
  }
  opener == "" && /^#+[ \t]+Task[ \t]+[0-9]+/ {
    intask = ($0 ~ ("^#+[ \t]+Task[ \t]+" n "([^0-9]|$)"))
  }
  intask { print }
' "$plan" > "$out"
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `tests/hooks/test-task-brief.sh`
Expected: PASS — both cases.

- [ ] **Step 5: Confirm the real corpus still extracts identically**

```bash
for n in 1 2 3 4 5; do
  ./skills/subagent-driven-development/scripts/task-brief \
      docs/superpowers/plans/2026-07-06-sdd-plan-scoped-workspace.md "$n" \
      /tmp/brief-$n.md >/dev/null 2>&1
  printf 'task %s: %s lines\n' "$n" "$(wc -l < /tmp/brief-$n.md)"
done
```

Expected: five non-empty briefs, one per real task of that plan — the plan carries five real task headings and twelve fenced ones.

- [ ] **Step 6: Add the CI step**

In `.github/workflows/ci.yml`, immediately after the `Tests (fence scanner)` step added in Task 1, add:

```yaml
      - name: Tests (task brief)
        run: tests/hooks/test-task-brief.sh
```

- [ ] **Step 7: Write the changelog entry**

Under `## [Unreleased]`, at the end of the `### Fixed` subsection Task 2 created, add:

```markdown
- **`task-brief` carried the same naive fence toggle, and now carries the
  CommonMark rule in awk.** It keeps its own implementation rather than
  importing the shared scanner: reaching a module in another skill's directory
  would make one shipped skill depend on another's internals, and this script
  was measured at zero divergence — extraction is byte-identical under both
  rules for every task of every plan under `docs/`, and no plan has a task
  number the naive toggle exposes and the correct rule does not. It is corrected
  because the cause is shared, not because a defect was found. It also gains its
  first suite: [`tests/hooks/test-task-brief.sh`](tests/hooks/test-task-brief.sh),
  where its only prior assertion checked where the brief file lands and ran in a
  suite CI does not execute.
```

- [ ] **Step 8: Verify the preparation produced what you expect**

```bash
git status --short
git diff --stat
```

Expected: four paths — `skills/subagent-driven-development/scripts/task-brief`, `tests/hooks/test-task-brief.sh`, `.github/workflows/ci.yml`, `CHANGELOG.md`.

- [ ] **Step 9: Commit**

```bash
git add skills/subagent-driven-development/scripts/task-brief tests/hooks/test-task-brief.sh .github/workflows/ci.yml CHANGELOG.md
git commit -m "fix(sdd): task-brief fecha cerca pela regra CommonMark, nao por alternador"
```

---

### Task 8: The test-name comparison stops knowing languages

**Spec criterion:** `AC20 A coverage matrix naming a test that no code block of the plan contains exits 1, whatever language the test is written in`.

**Files:**
- Modify: `skills/writing-plans/scripts/check-cross-references:170-205`
- Modify: `tests/hooks/test-check-cross-references.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `fence_mask(lines) -> (list[bool], int | None)` from `mdfence`, already imported by Task 3 — this task uses the mask the other way round, keeping the fenced lines instead of dropping them.
- Produces: nothing consumed by a later task.

**The smaller structure is the one that knows nothing.** `TEST_DEF` is a pattern per language and it already missed this repository's own; adding bash to it buys the next language nothing and bakes this project's shell function names into a skill script every project runs. Replacing it removes code rather than adding a case.

**Acceptance criteria:**
- T8.1: A plan whose matrix names a test string that appears in no code block exits 1 — test: `tests/hooks/test-check-cross-references.sh > a matrix naming a test no code block holds fails`
- T8.2: A plan whose matrix names a bash case its steps create exits 0 — test: `tests/hooks/test-check-cross-references.sh > a bash case named in the matrix is created`

- [ ] **Step 1: Write the failing tests**

Append to `tests/hooks/test-check-cross-references.sh`, before its final summary block:

````bash
# Measured 2026-08-24 on this branch's own plan: TEST_DEF knows it(), test(),
# describe(), def test_ and func Test, and reported all 26 of that plan's real
# bash cases as absent. Two designs were measured. "The name appears outside the
# matrix rows" is vacuous — writing-plans requires every task criterion to name
# its covering test, so the criterion line carries the name even when a step
# renamed the test. Searching the code blocks catches that mutation.
BASH_PLAN='# Plan

## Task 1: Build it

Acceptance criteria:
- T1.1 rejects the bad input

Step 1: write the test.

```bash
run_case "rejects the bad input" 0 "$FIXTURE"
```

## Test Coverage Matrix

| Criterion | Test |
|---|---|
| T1.1 | > rejects the bad input |'

run_case "a bash case named in the matrix is created" 0 "$BASH_PLAN"

run_case "a matrix naming a test no code block holds fails" 1 "$(printf '%s' "$BASH_PLAN" |
    sed 's/| T1.1 | > rejects the bad input |/| T1.1 | > a case nobody wrote |/')"
````

- [ ] **Step 2: Run the tests to verify they fail**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: FAIL on `a bash case named in the matrix is created` — `expected exit 0, got 1`, reporting `tests named in the coverage matrix that no step creates: \`rejects the bad input\``, because the step writes a shell function call the pattern does not recognise. The second case, `a matrix naming a test no code block holds fails`, PASSES already — with nothing recognised, everything reads as missing, and it is the regression guard that the replacement still catches a real one.

- [ ] **Step 3: Replace the pattern with the question**

In `skills/writing-plans/scripts/check-cross-references`, delete the `TEST_DEF` regex and the `created` set built from it. `matrix_rows` is unchanged — the matrix lines are prose, so the code-block search below never sees them and no index bookkeeping is needed. Replace the test-existence pass with:

```python
# Every test named in the matrix is created by some step of some task.
#
# "Created" is deliberately language-blind: the name appears inside one of the
# document's fenced code blocks, which is where a step writes a test. Parsing
# test-definition syntax meant carrying a pattern per language, and it did not
# carry this repository's own — bash suites name their cases with shell
# function calls, and 26 real tests read as absent on the plan for this branch.
#
# Searching the whole document instead of the code blocks does NOT work:
# writing-plans requires every task criterion to name its covering test, so the
# criterion line carries the name even when a step renamed the test, and the
# check passes on the one defect it exists for.
in_code = "\n".join(ln for i, ln in enumerate(lines) if fenced[i])
```

And the comparison itself:

```python
if named_in_matrix:
    counts["tests named in matrix"] = len(named_in_matrix)
    missing = sorted(n for n in named_in_matrix if n not in in_code)
    if missing:
        failures.append(
            "tests named in the coverage matrix that no step creates: "
            + "; ".join(f"`{n}`" for n in missing)
        )
```

Remove the now-unused `counts["tests created by a step"]` line with the set it counted.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: PASS — every case, including the nine originals and `matrix naming a test no step creates fails`, which must still exit 1.

- [ ] **Step 5: Run the gate over this branch's own plan**

```bash
./skills/writing-plans/scripts/check-cross-references \
    docs/superpowers/plans/2026-08-24-cross-references-extractor.md .
```

Expected: exit 0. This is the measurement the task exists for: the same command reported 26 real tests as absent before the change.

- [ ] **Step 6: Write the changelog entry**

Under `## [Unreleased]`, at the end of the `### Fixed` subsection Task 2 created, add:

```markdown
- **The test-name comparison knew five test vocabularies and not this
  repository's.** `TEST_DEF` in
  [`skills/writing-plans/scripts/check-cross-references`](skills/writing-plans/scripts/check-cross-references)
  matched `it(...)`, `test(...)`, `describe(...)`, `def test_` and `func Test`;
  every suite here is bash, naming its cases by shell function call — 68
  `assert_run` and 9 `run_case` across `tests/hooks/`. Measured on this branch's
  own plan: 26 real tests reported absent at once. It now asks a question no
  language answers differently — does the name appear inside one of the
  document's fenced code blocks, which is where a step writes a test. The
  simpler form, "the name appears anywhere outside the matrix", was measured and
  rejected: `writing-plans` requires every task criterion to name its covering
  test, so the criterion line carries the name even after a step renames the
  test, and the check passes on the one desync it exists for.
```

- [ ] **Step 7: Verify the preparation produced what you expect**

```bash
git diff --stat
grep -n 'TEST_DEF\|tests created by a step' skills/writing-plans/scripts/check-cross-references || echo "0 — pattern and its count are gone"
```

Expected: three paths, and the grep reports no matches.

- [ ] **Step 8: Commit**

```bash
git add skills/writing-plans/scripts/check-cross-references tests/hooks/test-check-cross-references.sh CHANGELOG.md
git commit -m "fix(writing-plans): a comparacao de testes para de conhecer linguagens"
```
