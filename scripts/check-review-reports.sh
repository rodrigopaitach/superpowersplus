#!/usr/bin/env bash
#
# check-review-reports.sh — a report a ledger row links to is really there.
#
# docs/superpowers/review-yield.md carries one row per review dispatch, and its
# `Report` column links the preserved report that dispatch returned. This gate
# charges three things, and only these three, about the destinations those
# links name:
#
#   1. the file exists;
#   2. it is not zero bytes;
#   3. no two rows link the same path.
#
# It is whole-tree rather than staged-diff for a reason particular to it: a
# report is linked from a row written in one commit and can be deleted or
# emptied in any later one, so the ledger being unchanged says nothing about
# whether its links still land on files with bytes in them.
#
# WHAT IT DOES NOT COVER — read this before trusting a pass:
#   * The report's CONTENT, beyond "has bytes". A report truncated in the
#     middle — non-empty and uniquely linked — PASSES. There is no expected
#     header, no terminal marker and no format imposed on any reviewer: the
#     file is a subagent's verbatim text, and a check on its shape would be a
#     check on the reviewer's prose.
#   * Whether the saved bytes are what the subagent actually returned. That is
#     an earlier step; skills/requesting-code-review/scripts/save-review-report.sh
#     states in its own header what its comparison does and does not prove.
#   * A ledger with no `Report` column at all. That is a VALID ledger — the
#     column arrives with the first row written under the rule — and it passes
#     untouched. So does a row whose cell is `—`, which says only that this
#     record links no report, and nothing about any file anywhere.
#   * Reports in a partner's project. This reads THIS repository's ledger, at
#     the path printed on every run, pass or fail.
#
# Two things it does treat as failures, stated here because neither is one of
# the three above:
#   * A missing ledger. A gate that passes when it cannot find its input is
#     indistinguishable from a gate that found nothing wrong.
#   * A cell that is neither `—` nor a markdown link — an empty cell, a plain
#     hyphen, or a backticked path. The reference admits those two forms and no
#     others; the backticked path is the one worth naming, because it looks
#     right to a reader while being read by nothing: scripts/check-links.sh
#     resolves link syntax and nothing else.
#
# Usage:
#   check-review-reports.sh   Exit 1 when a linked report is missing, empty, or
#                             linked from more than one row
#
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$repo_root" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
ledger = root / "docs" / "superpowers" / "review-yield.md"

# The ledger is named on every run. Exit 0 alone cannot tell a correct
# compatibility pass from a run that opened the wrong file: a six-column ledger
# in a scratch tree and this repository's own both exit 0, and a gate that
# resolved its root wrongly would report the second while a test believed it
# was reading the first. The suite asserts on this line.
print(f"check-review-reports: reading {ledger}")

if not ledger.is_file():
    print("check-review-reports: no ledger at that path.", file=sys.stderr)
    sys.exit(1)

lines = ledger.read_text(encoding="utf-8").splitlines()

header_index = None
for index, line in enumerate(lines):
    if line.startswith("| Date |"):
        header_index = index
        break

if header_index is None:
    print("check-review-reports: the ledger has no '| Date |' header row.",
          file=sys.stderr)
    sys.exit(1)


def cells(line):
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


header = cells(lines[header_index])
if "Report" not in header:
    print("check-review-reports: this ledger has no Report column — "
          "a six-column ledger is valid and carries no report link.")
    sys.exit(0)

report_column = header.index("Report")

# The table is the run of pipe-opening lines after the separator. It stops at
# the first line that does not open with a pipe, so the prose below the table
# is never read as a malformed row.
LINK = re.compile(r"^\[[^\]]*\]\(([^)\s]+)\)$")

problems = []
seen = {}
linked = 0
blank = 0

for offset, line in enumerate(lines[header_index + 2:], header_index + 3):
    if not line.startswith("|"):
        break
    row = cells(line)
    label = f"{ledger}:{offset}"
    if len(row) <= report_column:
        problems.append(f"{label}: the row has no Report cell")
        continue
    cell = row[report_column]
    # EXACTLY the em-dash. Not a hyphen, not an empty cell: the reference
    # admits two forms in this cell and nothing else, and a gate that quietly
    # accepted the near-misses would let a row that links nothing look like a
    # row that deliberately links nothing.
    if cell == "—":
        blank += 1
        continue
    match = LINK.match(cell)
    if not match:
        problems.append(
            f"{label}: the Report cell is neither an em-dash nor a markdown "
            f"link: {cell}")
        continue
    target = match.group(1)
    resolved = (ledger.parent / target).resolve()
    if not resolved.is_file():
        problems.append(f"{label}: links {target} -> no such file")
        continue
    if resolved.stat().st_size == 0:
        problems.append(f"{label}: links {target} -> the file is empty")
        continue
    if resolved in seen:
        problems.append(
            f"{label}: links {target}, already linked by {seen[resolved]}")
        continue
    seen[resolved] = label
    linked += 1

if problems:
    print("check-review-reports: ledger rows whose report is not there.",
          file=sys.stderr)
    print("", file=sys.stderr)
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    print("", file=sys.stderr)
    sys.exit(1)

print(f"check-review-reports: {linked} linked report(s) exist, are non-empty "
      f"and are each linked once; {blank} row(s) link none.")
PY
