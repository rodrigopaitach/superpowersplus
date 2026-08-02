#!/usr/bin/env bash
#
# check-skill-behavior-records.sh — integrity of tests/skill-behavior/ records.
#
# It checks that the records are WELL FORMED. It never re-runs the adversarial
# tests: those dispatch a live agent, cost tokens, and are non-deterministic.
# Re-running one is a human decision, taken when a rule changes — not something
# CI does on every push.
#
# Usage:
#   check-skill-behavior-records.sh    Exit 1 on a malformed record
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$REPO_ROOT/tests/skill-behavior"

[ -d "$DIR" ] || { echo "check-skill-behavior-records: $DIR not found" >&2; exit 1; }

fail=0

note() {
  echo "check-skill-behavior-records: $1" >&2
  fail=1
}

shopt -s nullglob

for f in "$DIR"/FIXTURE-*.md; do
  grep -qi 'test fixture' "$f" \
    || note "$(basename "$f"): a fixture must say it is a test fixture, so nobody mistakes it for a real document"
done

for f in "$DIR"/RESULT-*.md; do
  base="$(basename "$f")"
  grep -qE '^\| \*\*Date\*\*' "$f"     || note "$base: no **Date** row"
  grep -qE '^\| \*\*Model\*\*' "$f"    || note "$base: no **Model** row"
  grep -qE '^\| \*\*Verdict\*\*' "$f"  || note "$base: no **Verdict** row"
  grep -qE '\*\*(PASS|FAIL|PARTIAL)' "$f" \
    || note "$base: no per-criterion verdict — a result with no verdict records nothing"
done

if [ "$fail" -eq 0 ]; then
  echo "check-skill-behavior-records: records well formed"
  exit 0
fi

cat >&2 <<'EOF'

These are integrity checks on the records, not the tests themselves. A record
missing its date, its model, or its verdicts cannot be compared against a later
run, which is the only thing it exists for.
EOF
exit 1
