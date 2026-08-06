#!/usr/bin/env bash
#
# check-evidence-line.sh — the test-evidence line is the same line everywhere.
#
# The form `**Command:** … — **exit:** … — **counts:** …` is carried in every
# file listed in CARRIERS below, unified IN PLACE rather than extracted to one
# file. That decision is deliberate and measured: a form inside a subagent's output block must not sit
# behind a link, because the agent filling the block does not follow it
# (skills/using-superpowers/references/escalation-format.md:9-11, the move
# measured 1/3 then 3/3 once the form came back to the point of use).
#
# Unifying in place without a gate is just copying. This is the gate. It reads
# every carrier, extracts the FIELD NAMES of the evidence line, and fails when
# they disagree.
#
# WHAT IT DOES NOT COVER — read this before trusting a pass:
#   * Whether the text INSIDE each field makes sense for that carrier. It reads
#     field names, never their content: `**exit:** [code]` and
#     `**exit:** [the moon]` are identical to this check.
#   * The suffix that follows the form on purpose — `(base: …)` in
#     task-reviewer-prompt.md, `(previous: …)` in re-review-prompt.md, none in
#     code-reviewer.md. That difference is CONTENT, not wording, and this gate
#     is blind to it by design.
#   * Whether a carrier is reached at the right moment in its own document.
#   * Whether the declared carriers are still the right ones. The list below
#     is declared, not discovered: a new carrier means adding it here. The
#     count is printed at run time and deliberately not written down — a
#     number in this comment ages every time the list grows.
#
# Formatting is explicitly tolerated: indentation, line wrapping inside the
# form, and any prose prefix before `**Command:**` are all normalized away.
# A field that disappears is a failure; a field that moves to the next line
# is not.
#
# Usage:
#   check-evidence-line.sh    Exit 1 when the carriers disagree
#
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$repo_root" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])

# Declared, not discovered — a new carrier is added here on purpose.
#
# finishing-a-development-branch is the only carrier whose reader is a person
# rather than another subagent, and it was the last point of claim without the
# form. Every other carrier is a machine-to-machine prompt, so the shape was
# enforced everywhere an agent reports to an agent and nowhere an agent reports
# to its human partner. That asymmetry is what adding it closes.
CARRIERS = [
    "skills/executing-plans/SKILL.md",
    "skills/finishing-a-development-branch/SKILL.md",
    "skills/requesting-code-review/code-reviewer.md",
    "skills/subagent-driven-development/implementer-prompt.md",
    "skills/subagent-driven-development/re-review-prompt.md",
    "skills/subagent-driven-development/task-reviewer-prompt.md",
]

FIELD = re.compile(r"\*\*([A-Za-z][A-Za-z ]*?):\*\*")
# How far apart two chained fields may sit. The longest real gap is
# code-reviewer.md's filled example, `**Command:** `npm test` (from
# package.json scripts.test) — `, at 46 characters.
MAX_GAP = 80


def evidence_forms(text):
    """Every `**Command:** … — **field:** …` chain in the text, as field-name
    tuples. Whitespace is collapsed first, so a form wrapped across three
    indented lines reads the same as one written on a single line."""
    norm = " ".join(text.split())
    forms = []
    for start in re.finditer(r"\*\*Command:\*\*", norm):
        names = ["Command"]
        pos = start.end()
        while True:
            nxt = FIELD.search(norm, pos)
            if not nxt:
                break
            between = norm[pos:nxt.start()]
            # Chained to this form only if an em-dash joins them and the gap is
            # short. Anything else is the next paragraph, not the next field.
            if "—" not in between or len(between) > MAX_GAP:
                break
            names.append(nxt.group(1))
            pos = nxt.end()
        forms.append(tuple(names))
    return forms


failures = []
seen = {}

for rel in CARRIERS:
    path = root / rel
    if not path.is_file():
        failures.append(f"{rel}: declared carrier does not exist")
        continue
    forms = evidence_forms(path.read_text(encoding="utf-8"))
    if not forms:
        failures.append(
            f"{rel}: carries no evidence line — the form was removed or its "
            f"`**Command:**` marker was reworded"
        )
        continue
    for fields in forms:
        seen.setdefault(fields, []).append(rel)

if len(seen) > 1:
    detail = "; ".join(
        f"{' — '.join(f) or '(empty)'} in {', '.join(sorted(set(files)))}"
        for f, files in sorted(seen.items())
    )
    failures.append(f"carriers disagree on the evidence line's fields: {detail}")

if failures:
    for line in failures:
        print(f"check-evidence-line: {line}", file=sys.stderr)
    print(
        "\nThe declared carriers hold ONE line, copied on purpose because a form "
        "inside a subagent's output block cannot live behind a link. When they "
        "stop matching, the copy has drifted and one of them is teaching a "
        "shape nothing else uses.",
        file=sys.stderr,
    )
    sys.exit(1)

fields = " — ".join(next(iter(seen)))
total = sum(len(v) for v in seen.values())
print(
    f"check-evidence-line: {len(CARRIERS)} carrier(s), {total} occurrence(s), "
    f"all agreeing on: {fields}"
)
PY
