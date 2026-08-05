#!/usr/bin/env bash
#
# check-escalation-shape.sh — the escalation shape is the same shape everywhere.
#
# The sibling of check-evidence-line.sh, for the second form this project
# copies on purpose. The four numbered items that cross the machine → human
# boundary are carried in six files, unified IN PLACE rather than extracted,
# for the reason skills/using-superpowers/references/escalation-format.md
# records: the same shape measured 1/3 behind a link and 3/3 once it returned
# to the point of use.
#
# Unifying in place without a gate is just copying. This is that gate. It reads
# every carrier, extracts the ITEM NUMBERS and BOLD LEADS of the shape, and
# fails when they disagree.
#
# WHAT IT DOES NOT COVER — read this before trusting a pass:
#   * The prose after each bold lead. `1. **What breaks or costs** if nothing
#     is decided` and `1. **What breaks or costs** whenever` are identical to
#     this check. It reads the lead, never the sentence it opens.
#   * Whether a carrier fires at the right moment in its own document. Six
#     agreeing copies in six wrong places pass.
#   * Whether the six carriers are still the right six. The list below is
#     declared, not discovered: a seventh carrier means adding it here.
#   * Whether the shape is what a person can act on. That is what the
#     adversarial record measures, not a text gate.
#
# Formatting is explicitly tolerated: indentation, line wrapping inside an
# item, and any prose between the marker and item 1 are normalized away. An
# item that disappears or is reworded is a failure; an item that moves to the
# next line is not.
#
# Usage:
#   check-escalation-shape.sh    Exit 1 when the carriers disagree
#
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$repo_root" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])

# Declared, not discovered — a seventh carrier is added here on purpose.
# Five skills, six files: subagent-driven-development carries it twice, once in
# SKILL.md and once in references/final-review.md, which is why a list of skill
# names is not a list of carriers.
CARRIERS = [
    "skills/brainstorming/SKILL.md",
    "skills/executing-plans/SKILL.md",
    "skills/final-branch-audit/SKILL.md",
    "skills/subagent-driven-development/SKILL.md",
    "skills/subagent-driven-development/references/final-review.md",
    "skills/writing-plans/SKILL.md",
]

MARKER = "**Escalation shape**"
ITEM = re.compile(r"(\d+)\.\s+\*\*(.+?)\*\*")
# How far past the marker the shape may start, and how far apart two items may
# sit. The real gap between the marker and item 1 is the parenthetical pointing
# at escalation-format.md, under 100 characters.
MAX_GAP = 200


def shape(text):
    """The (number, bold lead) pairs of the escalation shape, as one tuple.
    Whitespace is collapsed first, so an item wrapped across three indented
    lines reads the same as one written on a single line."""
    norm = " ".join(text.split())
    at = norm.find(MARKER)
    if at < 0:
        return None
    items = []
    pos = at + len(MARKER)
    expected = 1
    while True:
        nxt = ITEM.search(norm, pos)
        if not nxt or len(norm[pos:nxt.start()]) > MAX_GAP:
            break
        if int(nxt.group(1)) != expected:
            break
        items.append((nxt.group(1), " ".join(nxt.group(2).split())))
        pos = nxt.end()
        expected += 1
    return tuple(items)


failures = []
seen = {}

for rel in CARRIERS:
    path = root / rel
    if not path.is_file():
        failures.append(f"{rel}: declared carrier does not exist")
        continue
    found = shape(path.read_text(encoding="utf-8"))
    if found is None:
        failures.append(
            f"{rel}: carries no escalation shape — the `{MARKER}` marker was "
            f"removed or reworded"
        )
        continue
    if not found:
        failures.append(
            f"{rel}: the marker is there and no numbered item follows it"
        )
        continue
    seen.setdefault(found, []).append(rel)

if len(seen) > 1:
    detail = "; ".join(
        "[" + " | ".join(f"{n}. {lead}" for n, lead in s) + "] in "
        + ", ".join(sorted(set(files)))
        for s, files in sorted(seen.items())
    )
    failures.append(f"carriers disagree on the escalation shape: {detail}")

if failures:
    for line in failures:
        print(f"check-escalation-shape: {line}", file=sys.stderr)
    print(
        "\nThe six carriers hold ONE shape, copied on purpose because a form "
        "that guards what reaches a person cannot live behind a link. When "
        "they stop matching, the copy has drifted and one of them is teaching "
        "a shape nothing else uses.",
        file=sys.stderr,
    )
    sys.exit(1)

only = next(iter(seen))
total = sum(len(v) for v in seen.values())
print(
    f"check-escalation-shape: {len(CARRIERS)} carrier(s), {total} "
    f"occurrence(s), all agreeing on {len(only)} item(s): "
    + ", ".join(n for n, _ in only)
)
PY
