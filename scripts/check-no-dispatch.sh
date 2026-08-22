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
# It charges the FORM, not the presence of a heading. Three things have to hold
# in every declared carrier: the heading exists, it is INDENTED — which is what
# puts it inside the `prompt: |` body the dispatched agent reads, rather than in
# the skill's own prose, which only the controller reads — and the clause body
# is the same text everywhere. A gate that matched the heading alone passes a
# carrier whose body says the opposite of the rule.
#
# WHAT IT DOES NOT COVER — read this before trusting a pass:
#   * Whether the clause is worded well. It compares the bodies to each other,
#     not to an argument: seven carriers agreeing on the wrong sentence pass.
#   * Whether an agent obeys it. That is what tests/skill-behavior/ measures,
#     and no criterion in this change asks for such a record.
#   * Whether the carriers are still the right ones. The list below is
#     declared, not discovered: a new carrier means adding it here.
#   * Whether the indented heading is inside the RIGHT fenced block. It proves
#     the clause is in an indented body, not which one.
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

MARKER = "## You Do Not Dispatch Subagents"

missing = []
unindented = []
unreadable = []
bodies = {}
for rel in CARRIERS:
    path = root / rel
    try:
        lines = path.read_text(encoding="utf-8").split("\n")
    except OSError as exc:
        unreadable.append(f"{rel}: {exc}")
        continue
    hit = next((i for i, l in enumerate(lines) if l.strip() == MARKER), None)
    if hit is None:
        missing.append(rel)
        continue
    indent = len(lines[hit]) - len(lines[hit].lstrip())
    if indent == 0:
        unindented.append(rel)
        continue
    # The body is the first non-blank line under the heading. Normalized so a
    # reflow is not a failure and a reword is.
    body = next((l.strip() for l in lines[hit + 1:] if l.strip()), "")
    bodies.setdefault(" ".join(body.split()), []).append(rel)


def fail(headline, detail):
    print(f"check-no-dispatch: {headline}", file=sys.stderr)
    for line in detail:
        print(f"  {line}", file=sys.stderr)
    print(
        "\nThe clause is carried in each prompt on purpose — a subagent reads its\n"
        "own block and does not follow a pointer out of it. See\n"
        "docs/review-scopes.md, section \"Why the form is copied rather than\n"
        "extracted\". Restore it, or remove the file from CARRIERS in this script\n"
        "if it is genuinely no longer a dispatched role.",
        file=sys.stderr,
    )
    sys.exit(1)


if unreadable:
    fail("declared carrier could not be read:", unreadable)

if missing:
    fail(
        f'{len(missing)} of {len(CARRIERS)} carrier(s) have lost the "{MARKER}" '
        "clause:",
        missing,
    )

if unindented:
    fail(
        f"{len(unindented)} carrier(s) hold the clause flush-left, which puts it "
        "in the skill's own prose rather than in the prompt body the dispatched "
        "agent reads:",
        unindented,
    )

if len(bodies) > 1:
    detail = []
    for body, rels in sorted(bodies.items(), key=lambda kv: -len(kv[1])):
        detail.append(f'{len(rels)} carrier(s): "{body[:70]}..."')
        detail.extend(f"  {rel}" for rel in rels)
    fail(f"the clause body differs across carriers ({len(bodies)} variants):", detail)

print(
    f"check-no-dispatch: {len(CARRIERS)} carrier(s) carry the clause, "
    "indented, all agreeing on one body"
)
PY
