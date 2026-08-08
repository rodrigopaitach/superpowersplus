#!/usr/bin/env bash
# Test explicit skill requests (user names a skill directly)
# Usage: ./run-test.sh <skill-name> <prompt-file>
#
# Tests whether Claude invokes a skill when the user explicitly requests it by name
# (without using the plugin namespace prefix)
#
# Uses isolated HOME to avoid user context interference

set -e

SKILL_NAME="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-3}"

if [ -z "$SKILL_NAME" ] || [ -z "$PROMPT_FILE" ]; then
    echo "Usage: $0 <skill-name> <prompt-file> [max-turns]"
    echo "Example: $0 subagent-driven-development ./prompts/subagent-driven-development-please.txt"
    exit 1
fi

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the superpowers plugin root (two levels up)
PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/superpowers-tests/${TIMESTAMP}/explicit-skill-requests/${SKILL_NAME}"
mkdir -p "$OUTPUT_DIR"

# Read prompt from file
PROMPT=$(cat "$PROMPT_FILE")

echo "=== Explicit Skill Request Test ==="
echo "Skill: $SKILL_NAME"
echo "Prompt file: $PROMPT_FILE"
echo "Max turns: $MAX_TURNS"
echo "Output dir: $OUTPUT_DIR"
echo ""

# Copy prompt for reference
cp "$PROMPT_FILE" "$OUTPUT_DIR/prompt.txt"

# Create a minimal project directory for the test
PROJECT_DIR="$OUTPUT_DIR/project"
mkdir -p "$PROJECT_DIR/docs/superpowers/plans"

# Create a dummy plan file for mid-conversation tests
cat > "$PROJECT_DIR/docs/superpowers/plans/auth-system.md" << 'EOF'
# Auth System Implementation Plan

## Task 1: Add User Model
Create user model with email and password fields.

## Task 2: Add Auth Routes
Create login and register endpoints.

## Task 3: Add JWT Middleware
Protect routes with JWT validation.
EOF

# Run Claude with isolated environment
LOG_FILE="$OUTPUT_DIR/claude-output.json"
cd "$PROJECT_DIR"

echo "Plugin dir: $PLUGIN_DIR"
echo "Running claude -p with explicit skill request..."
echo "Prompt: $PROMPT"
echo ""

# TEST_MODEL pins the tier. Unset, the run takes whatever the operator's session
# defaults to — which is fine for a working run and useless in a record, because
# a result whose model is inferred cannot be compared against a later one.
# The README records which tier produced which numbers; this is how it is set.
timeout 300 claude -p "$PROMPT" \
    --plugin-dir "$PLUGIN_DIR" \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    ${TEST_MODEL:+--model "$TEST_MODEL"} \
    --output-format stream-json --verbose \
    > "$LOG_FILE" 2>&1 || true

echo "Model: ${TEST_MODEL:-<operator default>}"

echo ""
echo "=== Results ==="

# Check if skill was triggered (look for Skill tool invocation)
# Match either "skill":"skillname" or "skill":"namespace:skillname"
SKILL_PATTERN='"skill":"([^"]*:)?'"${SKILL_NAME}"'"'
if grep -q '"name":"Skill"' "$LOG_FILE" && grep -qE "$SKILL_PATTERN" "$LOG_FILE"; then
    echo "PASS: Skill '$SKILL_NAME' was triggered"
    TRIGGERED=true
else
    echo "FAIL: Skill '$SKILL_NAME' was NOT triggered"
    TRIGGERED=false
fi

# Show what skills WERE triggered
echo ""
echo "Skills triggered in this run:"
grep -o '"skill":"[^"]*"' "$LOG_FILE" 2>/dev/null | sort -u || echo "  (none)"

# Check if Claude took action BEFORE invoking the skill (the failure mode)
echo ""
echo "Checking for premature action..."

# Look for tool invocations before the Skill invocation
# This detects the failure mode where Claude starts doing work without loading the skill
FIRST_SKILL_LINE=$(grep -n '"name":"Skill"' "$LOG_FILE" | head -1 | cut -d: -f1)
if [ -n "$FIRST_SKILL_LINE" ]; then
    # Check if any non-Skill, non-system tools were invoked before the first Skill invocation
    # Filter out task tracking tools (planning is ok) and other non-action tools
    PREMATURE_TOOLS=$(head -n "$FIRST_SKILL_LINE" "$LOG_FILE" | \
        grep '"type":"tool_use"' | \
        grep -v '"name":"Skill"' | \
        grep -vE '"name":"(TodoWrite|TaskCreate|TaskUpdate|TaskList|TaskGet)"' || true)
    if [ -n "$PREMATURE_TOOLS" ]; then
        echo "WARNING: Tools invoked BEFORE Skill tool:"
        echo "$PREMATURE_TOOLS" | head -5
        echo ""
        echo "This indicates Claude started working before loading the requested skill."
    else
        echo "OK: No premature tool invocations detected"
    fi
else
    echo "WARNING: No Skill invocation found at all"
fi

# Check the announcement the rule asks for
# using-superpowers SKILL.md:24 — announce "Using [skill] to [purpose]".
#
# Matched by the skill NAME appearing in the agent's own text, never by the English
# words: this harness does not isolate HOME, so the announcement arrives in whatever
# language the operator's CLAUDE.md asks for. A run that loads a skill and never
# names it is the failure this assertion exists to catch, in any language.
echo ""
echo "Checking for the announcement..."

ANNOUNCE=$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' \
    "$LOG_FILE" 2>/dev/null | grep -iF -- "$SKILL_NAME" || true)
if [ -n "$ANNOUNCE" ]; then
    echo "PASS: the run names '$SKILL_NAME' in its own text"
    echo "$ANNOUNCE" | head -2
    ANNOUNCED=true
else
    echo "FAIL: no assistant text names '$SKILL_NAME'"
    echo "  using-superpowers SKILL.md:24 asks for \"Using [skill] to [purpose]\""
    ANNOUNCED=false
fi

# Show first assistant message
echo ""
echo "First assistant response (truncated):"
grep '"type":"assistant"' "$LOG_FILE" | head -1 | jq -r '.message.content[0].text // .message.content' 2>/dev/null | head -c 500 || echo "  (could not extract)"

echo ""
echo "Full log: $LOG_FILE"
echo "Timestamp: $TIMESTAMP"

# Two failures, two exit codes. Collapsing them into one loses which rule broke:
# a skill that never loads and a skill that loads without announcing are different
# defects, and the summary that reports them as one number cannot be acted on.
if [ "$TRIGGERED" != "true" ]; then
    exit 1
elif [ "$ANNOUNCED" != "true" ]; then
    exit 2
else
    exit 0
fi
