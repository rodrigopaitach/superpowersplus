#!/usr/bin/env bash
#
# Tests for scripts/check-escalation-shape.sh.
#
# The script resolves its repository root from its own location and reads a
# hardcoded list of carriers, so each case builds a throwaway tree with the
# script installed and all six carrier files present. That exercises the real
# script — its real carrier list, its real item-chaining rule — rather than a
# parameterized variant that only exists for tests.
#
# The two states that matter are the last two groups: an item REWORDED or
# REMOVED must fail, and the same items REFORMATTED must pass. A gate that
# cannot tell those apart is a formatting linter wearing a gate's name.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-escalation-shape.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() {
    echo "  [PASS] $1"
}

fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

# Six files, five skills — subagent-driven-development carries it twice. That
# asymmetry is the reason a list of skill names is not a list of carriers.
CARRIERS=(
    "skills/brainstorming/SKILL.md"
    "skills/executing-plans/SKILL.md"
    "skills/final-branch-audit/SKILL.md"
    "skills/subagent-driven-development/SKILL.md"
    "skills/subagent-driven-development/references/final-review.md"
    "skills/writing-plans/SKILL.md"
)

canonical_shape() {
    cat <<'EOF'
Some prose above the shape.

**Escalation shape** (detail and a worked example: `../using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern.
4. **Before sending, reread the whole message once**, looking for terms.

Some prose below it.
EOF
}

# new_tree — throwaway tree with the script and all six carriers. Echoes path.
new_tree() {
    local tree
    tree="$(mktemp -d "$TEST_ROOT/tree.XXXXXX")"
    mkdir -p "$tree/scripts"
    cp "$SCRIPT_UNDER_TEST" "$tree/scripts/check-escalation-shape.sh"
    local carrier
    for carrier in "${CARRIERS[@]}"; do
        mkdir -p "$tree/$(dirname "$carrier")"
        canonical_shape > "$tree/$carrier"
    done
    printf '%s\n' "$tree"
}

run_check() {
    bash "$1/scripts/check-escalation-shape.sh" >/dev/null 2>&1
}

echo "Testing check-escalation-shape.sh"

# --- the real repository -----------------------------------------------------

if bash "$SCRIPT_UNDER_TEST" >/dev/null 2>&1; then
    pass "this repository's six carriers agree"
else
    fail "this repository's six carriers agree"
fi

# --- baseline ----------------------------------------------------------------

tree="$(new_tree)"
if run_check "$tree"; then
    pass "identical carriers pass"
else
    fail "identical carriers pass"
fi

# --- a declared carrier missing ----------------------------------------------

tree="$(new_tree)"
rm "$tree/skills/subagent-driven-development/references/final-review.md"
if run_check "$tree"; then
    fail "a missing carrier file fails"
else
    pass "a missing carrier file fails"
fi

# --- a carrier that lost the marker ------------------------------------------

tree="$(new_tree)"
printf 'Take it to your human partner and explain the options.\n' \
    > "$tree/skills/writing-plans/SKILL.md"
if run_check "$tree"; then
    fail "a carrier with no escalation shape at all fails"
else
    pass "a carrier with no escalation shape at all fails"
fi

# --- MUTATION: one item reworded on one carrier ------------------------------
# The failure this gate exists for: a copy drifts and starts teaching a shape
# nothing else uses.

tree="$(new_tree)"
sed -i 's/3\. \*\*A recommendation naming which source backs it\*\*/3. **A recommendation with a source**/' \
    "$tree/skills/final-branch-audit/SKILL.md"
if run_check "$tree"; then
    fail "MUTATION: rewording item 3 on one carrier fails"
else
    pass "MUTATION: rewording item 3 on one carrier fails"
fi

# --- MUTATION: one item removed from one carrier -----------------------------
# Item 4 is the one this project measured into existence — FAIL, FAIL, PASS —
# so a carrier quietly dropping it is the regression worth naming.

tree="$(new_tree)"
sed -i '/^4\. \*\*Before sending/d' "$tree/skills/brainstorming/SKILL.md"
if run_check "$tree"; then
    fail "MUTATION: dropping item 4 from one carrier fails"
else
    pass "MUTATION: dropping item 4 from one carrier fails"
fi

# --- MUTATION: a fifth item added to one carrier -----------------------------
# Divergence runs both ways.

tree="$(new_tree)"
printf '5. **Sign off with your name**, always.\n' \
    >> "$tree/skills/executing-plans/SKILL.md"
if run_check "$tree"; then
    fail "MUTATION: a fifth item on one carrier fails"
else
    pass "MUTATION: a fifth item on one carrier fails"
fi

# --- THE OTHER STATE: formatting changed, items identical --------------------
# Everything the gate is required to tolerate: indentation, an item wrapped
# across lines, and different prose after each bold lead.

tree="$(new_tree)"
cat > "$tree/skills/subagent-driven-development/SKILL.md" <<'EOF'
    **Escalation shape** (detail: elsewhere):
    1. **What breaks or costs**
       whenever nothing is decided.
    2. **2–4 options with the cost of each**,
       and doing nothing counts as one.
    3. **A recommendation naming which source backs it**
       — the docs, or a line in this repo.
    4. **Before sending, reread the whole message once**,
       hunting for jargon.
EOF
if run_check "$tree"; then
    pass "REFORMAT: indented, wrapped, different trailing prose still passes"
else
    fail "REFORMAT: indented, wrapped, different trailing prose still passes"
fi

# --- REFORMAT: the whole shape on one line -----------------------------------

tree="$(new_tree)"
cat > "$tree/skills/executing-plans/SKILL.md" <<'EOF'
**Escalation shape**: 1. **What breaks or costs** x. 2. **2–4 options with the cost of each**, y. 3. **A recommendation naming which source backs it** z. 4. **Before sending, reread the whole message once**, w.
EOF
if run_check "$tree"; then
    pass "REFORMAT: the whole shape collapsed onto one line still passes"
else
    fail "REFORMAT: the whole shape collapsed onto one line still passes"
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All check-escalation-shape tests passed"
    exit 0
fi
echo "$FAILURES check-escalation-shape test(s) failed"
exit 1
