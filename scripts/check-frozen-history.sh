#!/usr/bin/env bash
#
# check-frozen-history.sh — pre-commit hook: the historical changelog is frozen.
#
# docs/PLUS-CHANGELOG-historico.md records the 34 plus.N entries as they were
# written, plus the moment each open gap was opened. It is not maintained.
# Everything new — including closing an open gap — belongs in CHANGELOG.md, so
# there is one document that is current and one that is a record, and no way to
# confuse them.
#
# Usage:
#   check-frozen-history.sh    Exit 1 if the frozen file is staged
#
set -euo pipefail

FROZEN="docs/PLUS-CHANGELOG-historico.md"

staged="$(git diff --cached --name-only --diff-filter=ACMRD)"

grep -qxF "$FROZEN" <<<"$staged" || exit 0

cat >&2 <<EOF
check-frozen-history: $FROZEN is a frozen record and takes no new writing.

Everything new goes in CHANGELOG.md — including closing an open gap, whose
live list lives there under "Open gaps". This file keeps only the text as it
was written when each entry was made.

Move the change to CHANGELOG.md and unstage this file:

  git restore --staged $FROZEN

Genuinely editing the record itself — a header note about its own status, for
instance — is the rare legitimate case: git commit --no-verify
EOF
exit 1
