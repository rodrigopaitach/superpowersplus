#!/usr/bin/env bash
# Run all explicit skill request tests
# Usage: ./run-all.sh
#
# Every case lives in the list below. A prompt file under prompts/ that no line
# here names is a test nobody runs — which reads exactly like a test that
# passes. Adding a case is one line.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

echo "=== Running All Explicit Skill Request Tests ==="
echo ""

PASSED=0
FAILED=0
RESULTS=""
N=0

run_case() {
    local skill="$1" prompt="$2"
    N=$((N + 1))
    echo ">>> Test $N: $prompt"
    if "$SCRIPT_DIR/run-test.sh" "$skill" "$PROMPTS_DIR/$prompt.txt"; then
        PASSED=$((PASSED + 1))
        RESULTS="$RESULTS\nPASS: $prompt"
    else
        FAILED=$((FAILED + 1))
        RESULTS="$RESULTS\nFAIL: $prompt"
    fi
    echo ""
}

# The user names the skill plainly.
run_case "subagent-driven-development" "subagent-driven-development-please"
run_case "systematic-debugging" "use-systematic-debugging"
run_case "brainstorming" "please-use-brainstorming"

# The user names it inside a flow that is already moving.
run_case "subagent-driven-development" "mid-conversation-execute-plan"

# The two pressures that argue for skipping the skill, and are the reason the
# rule exists: the user already explains what the skill does, and the user
# asks for speed against the process.
run_case "subagent-driven-development" "i-know-what-sdd-means"
run_case "subagent-driven-development" "skip-formalities"

echo "=== Summary ==="
echo -e "$RESULTS"
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total: $((PASSED + FAILED))"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
