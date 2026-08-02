#!/usr/bin/env bash
#
# check-docs-sync.sh — pre-commit hook: the bilingual fork docs move together.
#
# docs/README.pt-BR.md is canonical and docs/README.en.md is its translation.
# Staging exactly one of them opens a divergence nobody can see afterwards:
# both versions stay plausible, and nothing marks which one went stale.
#
# Usage:
#   check-docs-sync.sh    Exit 1 if exactly one of the pair is staged
#
set -euo pipefail

PT="docs/README.pt-BR.md"
EN="docs/README.en.md"

staged="$(git diff --cached --name-only --diff-filter=ACMRD)"

staged_pt=0
staged_en=0
grep -qxF "$PT" <<<"$staged" && staged_pt=1
grep -qxF "$EN" <<<"$staged" && staged_en=1

if [ "$staged_pt" -eq "$staged_en" ]; then
  exit 0
fi

if [ "$staged_pt" -eq 1 ]; then
  staged_file="$PT"; missing_file="$EN"
else
  staged_file="$EN"; missing_file="$PT"
fi

cat >&2 <<EOF
check-docs-sync: the bilingual docs are out of sync.

  staged:      $staged_file
  NOT staged:  $missing_file

$PT is canonical; $EN is its translation. Editing one requires
editing the other in the same commit — otherwise both versions stay
plausible and nothing marks which one went stale.

Apply the matching change to $missing_file and stage it, then commit again.
To commit anyway (you own the consequence): git commit --no-verify
EOF
exit 1
