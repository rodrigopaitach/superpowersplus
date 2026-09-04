#!/usr/bin/env bash
# The twelve compatibility-mode cases docs/evidence-model.md enumerates,
# asserted against the fixtures that carry them and the carriers that resolve
# them. Deterministic: nothing here dispatches an agent.
#
# What it protects is the boundary, not an opinion about it. A carrier that
# loses its clause, a fixture that drifts into a different case, the three
# prompts drifting apart, a decision-table row disappearing, or a fourth
# evidence class appearing — each of those turns this red.
#
# Cases 1-8 have a document shape and are asserted against a fixture. Cases
# 9-12 are properties of the flow (a confirmed-absent spec, the two paths
# agreeing, a legacy re-review, reading without migrating) and are asserted
# against the carriers that state them; there is no document that could carry
# them alone.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
FIX="$HERE/fixtures"
pass=0
fail=0

ok()  { printf '  [PASS] %s\n' "$1"; pass=$((pass + 1)); }
bad() { printf '  [FAIL] %s — %s\n' "$1" "$2"; fail=$((fail + 1)); }
check() {
  if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1" "$3"; fi
}

echo "Testing compatibility mode"

# --- the decision table covers every case, and no more
rows=$(awk '/^\| # \| Source spec/ {f = 1; next}
            f && /^\| [0-9]/ {n++}
            f && !/^\|/ {exit}
            END {print n + 0}' "$ROOT/docs/evidence-model.md")
check "the decision table carries exactly twelve cases" \
  "[ \"$rows\" -eq 12 ]" "found $rows"

# --- each fixture is still the case it claims
check "a legacy spec carries no evidence-model marker" \
  "! grep -q 'Evidence model' '$FIX/spec-legacy.md'" "the marker appeared"
check "a v2 spec carries the evidence-model marker" \
  "grep -q '^\*\*Evidence model:\*\* v2' '$FIX/spec-v2.md'" "the marker is missing"

check "case 1: a legacy plan naming a test id keeps the historical schema" \
  "grep -q '^## Test Coverage Matrix' '$FIX/plan-1.md' && grep -q '| > ' '$FIX/plan-1.md'" \
  "the shape drifted"
check "case 2: a legacy Test cell holding a read-only command names no test id" \
  "grep -q '^## Test Coverage Matrix' '$FIX/plan-2.md' && ! grep -qE '\| > |::' '$FIX/plan-2.md'" \
  "the shape drifted"
check "case 3: a new plan from a legacy spec carries the Verification Matrix" \
  "grep -q '^## Verification Matrix' '$FIX/plan-3.md' && grep -q '| behavioral |' '$FIX/plan-3.md'" \
  "the shape drifted"
check "case 4: a v2 plan with a behavioral criterion declares that class" \
  "grep -q '| behavioral |' '$FIX/plan-4.md'" "the shape drifted"
check "case 5: a v2 structural-only plan declares no behavioral criterion" \
  "! grep -q '| behavioral |' '$FIX/plan-5.md'" "a behavioral row appeared"
check "case 6: a v2 plan with a classless criterion has an empty class cell" \
  "grep -qE '^\| T1\.1 \| AC1 \| +\|' '$FIX/plan-6.md'" "the shape drifted"
check "a v2 spec with a historical Test Coverage Matrix is a blocking mismatch" \
  "grep -q 'spec-v2' '$FIX/plan-7.md' && grep -q '^## Test Coverage Matrix' '$FIX/plan-7.md'" \
  "the shape drifted"
check "case 8: a plan with no source spec cites none" \
  "! grep -q '^\*\*Source spec:\*\*' '$FIX/plan-8.md'" "a source spec appeared"

# --- the two controllers resolve all three outcomes, and both name the spec
#     as the authority. Same four properties in both: one decision, two paths.
#
# Matched against the file with its whitespace collapsed, never line by line.
# The two carriers wrap their prose differently — one is a numbered list, the
# other a paragraph — so a line-anchored grep passes on one and fails on the
# other for a sentence both actually carry. Measured: it did, on the first run.
flat() { tr -s ' \n' ' ' < "$ROOT/$1"; }
for c in skills/executing-plans/SKILL.md skills/subagent-driven-development/SKILL.md; do
  check "$c resolves the v2 mode" \
    "flat '$c' | grep -q '\*\*v2 mode\*\*'" "the clause is missing"
  check "$c resolves the legacy mode" \
    "flat '$c' | grep -q '\*\*legacy mode\*\*'" "the clause is missing"
  check "$c keeps the entry blocker when no spec exists" \
    "flat '$c' | grep -q 'silence is never legacy'" "the clause is missing"
  check "$c names the source spec as the authority, not the schema" \
    "flat '$c' | grep -q \"authority — never the plan's matrix schema\"" "the clause is missing"
  check "$c points at the canonical document for what each mode requires" \
    "flat '$c' | grep -q 'Compatibility: legacy behavioral'" "the pointer is missing"
done

# --- the three prompts carry one identical clause, and none of them decides
clause() {
  grep -A7 'A brief that declares no evidence class' "$ROOT/$1" | tr -s ' \n' ' '
}
a=$(clause skills/subagent-driven-development/task-reviewer-prompt.md)
b=$(clause skills/subagent-driven-development/implementer-prompt.md)
c=$(clause skills/subagent-driven-development/re-review-prompt.md)
check "the three prompts carry the consumption clause" "[ -n \"$a\" ]" "not found"
check "the three prompts agree on one body" \
  "[ \"$a\" = \"$b\" ] && [ \"$b\" = \"$c\" ]" "the three bodies diverged"
check "the consumption clause forbids opening the spec or the plan" \
  "printf '%s' \"\$a\" | grep -q 'Do not open the source spec, do not open the plan'" \
  "the prohibition is missing"

# --- no fourth class, anywhere in the tree
check "legacy behavioral is never a value in an Evidence class cell" \
  "! git -C '$ROOT' grep -qE '\| *legacy behavioral *\|'" "a fourth class appeared"

echo
if [ "$fail" -ne 0 ]; then
  echo "$fail case(s) failed"
  exit 1
fi
echo "All compatibility-mode cases passed ($pass)"
