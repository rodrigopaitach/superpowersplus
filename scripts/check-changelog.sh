#!/usr/bin/env bash
#
# check-changelog.sh — pre-commit hook: content changes ship with their entry.
#
# The rule already existed in CLAUDE.md and failed inside the same cycle that
# wrote it: ab1cf41 shipped the commit-preparation rule and
# check-skill-behavior-records.sh with no CHANGELOG.md line at all, and nobody
# noticed until the version was cut and the entry had to be reconstructed from
# the diff. A rule nothing enforces is a rule that holds until the first busy
# commit. This is the gate.
#
# Scope: what a reader of the changelog would expect to find named there —
# skills (agent behavior), scripts and githooks (the checks that guard it),
# .github (what CI enforces), hooks (what loads at session start). Commits that
# touch only docs/, tests/ or fixtures are exempt by not matching, which is why
# the list is a small allowlist of prefixes rather than an exclusion list.
#
# Usage:
#   check-changelog.sh    Exit 1 if content is staged without CHANGELOG.md
#
set -euo pipefail

CHANGELOG="CHANGELOG.md"

CONTENT_PREFIXES=(skills/ scripts/ githooks/ .github/ hooks/)

staged="$(git diff --cached --name-only --diff-filter=ACMRD)"

grep -qxF "$CHANGELOG" <<<"$staged" && exit 0

touched=()
while IFS= read -r file; do
    [ -n "$file" ] || continue
    for prefix in "${CONTENT_PREFIXES[@]}"; do
        # Anchored by construction: only a path starting with the prefix
        # matches, so vendor/skills/ is not a skills/ change.
        case "$file" in
            "$prefix"*) touched+=("$file"); break ;;
        esac
    done
done <<<"$staged"

[ "${#touched[@]}" -gt 0 ] || exit 0

cat >&2 <<EOF
check-changelog: content is staged and $CHANGELOG is not.

Staged under a content prefix (${CONTENT_PREFIXES[*]}):

$(printf '  %s\n' "${touched[@]}")

Every one of those changes something a reader of the changelog would expect to
find named there. Write the entry now, while you still remember why the change
was made — reconstructed later from a diff, it describes what changed and not
what it fixes.

  git add $CHANGELOG

A change genuinely not worth an entry — a typo in a comment, a whitespace
fix — is the case this gate cannot tell apart: git commit --no-verify
EOF
exit 1
