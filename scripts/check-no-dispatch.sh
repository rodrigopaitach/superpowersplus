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

# Declared, not discovered — a new carrier is added here on purpose.
# subagent-driven-development carries it once per dispatched role, which is why
# a list of skill names is not a list of carriers. The count is printed at run
# time and written down nowhere: it ages every time the list grows.
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
