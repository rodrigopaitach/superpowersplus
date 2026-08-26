#!/usr/bin/env bash
#
# check-skill-behavior-records.sh — integrity of tests/skill-behavior/ records.
#
# It checks that the records are WELL FORMED. It never re-runs the adversarial
# tests: those dispatch a live agent, cost tokens, and are non-deterministic.
# Re-running one is a human decision, taken when a rule changes — not something
# CI does on every push.
#
# The staleness pass is the deterministic half of that decision. Re-measuring
# costs tokens and cannot be automated honestly; noticing that the measured text
# has MOVED costs a `git log` and can. So this pass never asks for a re-run — it
# asks the record to stop reading as current for words it never saw, by naming
# the day the rule moved. Declining to re-measure stays free; declining in
# silence does not.
#
# **Runs** is required for the reason the staleness pass exists one level up: a
# single-run verdict from a live agent is a draw from a distribution, not a
# measurement, and a record that prints only its verdict invites the reader to
# treat N=1 as settled. What the number buys is in tests/skill-behavior/README.md,
# section "What N buys".
#
# Usage:
#   check-skill-behavior-records.sh    Exit 1 on a malformed or unmarked record
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

# cell <file> <row label> — the contents of a one-row table cell, or empty.
cell() {
  sed -n "s/^| \*\*$2\*\* | *\(.*[^ ]\) *|\$/\1/p" "$1" | head -1
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

  grep -qE '^\| \*\*Runs\*\*' "$f" \
    || note "$base: no **Runs** row — a verdict without its N reads as settled when it may be one draw"

  rule="$(cell "$f" 'Rule path' || true)"
  if [ -z "$rule" ]; then
    note "$base: no **Rule path** row — without it the staleness pass cannot see this record at all"
    continue
  fi

  # An unresolvable rule is allowed, declared. A bare dash is not: it reads
  # identical to a resolvable path nobody filled in.
  case "$rule" in
    [—-]*)
      reason="$(printf '%s' "$rule" | sed 's/^[—-]* *//')"
      [ "${#reason}" -ge 10 ] \
        || note "$base: **Rule path** is a bare dash — say why the rule is not a file, or give the path"
      continue
      ;;
  esac

  path="$(printf '%s' "$rule" | grep -oE '[A-Za-z0-9_./-]+\.(md|sh|json)' | head -1 || true)"
  if [ -z "$path" ]; then
    note "$base: **Rule path** names no file — give a repository path, or a dash and the reason"
    continue
  fi
  if [ ! -f "$REPO_ROOT/$path" ]; then
    note "$base: **Rule path** points at $path, which does not exist"
    continue
  fi

  # The NEWEST EDIT, not the newest commit. Author dates are not monotonic with
  # the graph — a commit written on another machine or in another timezone lands
  # on top carrying an earlier day — so `log -1` can report a date older than an
  # edit that really happened, and the record would pass for text that moved.
  ruledate="$(git -C "$REPO_ROOT" log --format=%ad --date=short -- "$path" 2>/dev/null | sort -r | head -1 || true)"
  if [ -z "$ruledate" ]; then
    note "$base: git holds no date for $path — the record cannot be compared against it"
    continue
  fi

  measured="$(cell "$f" 'Date' | grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' | head -1 || true)"
  if [ -z "$measured" ]; then
    note "$base: **Date** carries no YYYY-MM-DD"
    continue
  fi

  # The mark carries a date so a SECOND edit re-opens the finding. Without that,
  # one mark would exempt the record forever.
  marked="$(cell "$f" 'Rule changed since' | grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' | head -1 || true)"
  baseline="$measured"
  [ -n "$marked" ] && [[ "$marked" > "$baseline" ]] && baseline="$marked"

  # A mark past the newest edit is the one way to satisfy this gate without
  # being true: it names a day nothing happened and the baseline sails past
  # every real edit. Checked in both directions, or the mark is just a number
  # the author chose.
  if [ -n "$marked" ] && [[ "$marked" > "$ruledate" ]]; then
    note "$base: **Rule changed since** names $marked, but no commit touched $path after $ruledate"
  elif [[ "$ruledate" > "$baseline" ]]; then
    note "$base: measured $measured, but $path was edited $ruledate — add or update a **Rule changed since** row naming that day"
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "check-skill-behavior-records: records well formed"
  exit 0
fi

cat >&2 <<'EOF'

These are integrity checks on the records, not the tests themselves. A record
missing its date, its model, or its verdicts cannot be compared against a later
run, which is the only thing it exists for. A record whose rule has since moved
is worse than missing: it reads as current for text it never measured.
EOF
exit 1
