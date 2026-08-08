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
    local skill="$1" prompt="$2" rc=0
    N=$((N + 1))
    echo ">>> Test $N: $prompt"
    "$SCRIPT_DIR/run-test.sh" "$skill" "$PROMPTS_DIR/$prompt.txt" || rc=$?
    case "$rc" in
        0) PASSED=$((PASSED + 1)); RESULTS="$RESULTS\nPASS: $prompt" ;;
        2) FAILED=$((FAILED + 1)); RESULTS="$RESULTS\nFAIL (loaded, never announced): $prompt" ;;
        *) FAILED=$((FAILED + 1)); RESULTS="$RESULTS\nFAIL (skill not invoked): $prompt" ;;
    esac
    echo ""
}

# The user names the skill plainly.
run_case "subagent-driven-development" "subagent-driven-development-please"
run_case "systematic-debugging" "use-systematic-debugging"
run_case "brainstorming" "please-use-brainstorming"

# The user names it inside a flow that is already moving, and picks it BY NAME
# from an offer the agent itself made — which is how the request arrives every
# time the execution offer comes up.
run_case "subagent-driven-development" "mid-conversation-execute-plan"
run_case "subagent-driven-development" "after-planning-flow"

# The two pressures that argue for skipping the skill, and are the reason the
# rule exists: the user already explains what the skill does, and the user
# asks for speed against the process.
run_case "subagent-driven-development" "i-know-what-sdd-means"
run_case "subagent-driven-development" "skip-formalities"

# The two rationalizations the agent makes on its own behalf: the task is too
# small to deserve the skill, and it has used the skill before so it can skip
# reading it. Red Flags at using-superpowers SKILL.md:51 and :49.
run_case "brainstorming" "skill-is-overkill"
run_case "subagent-driven-development" "i-remember-this-skill"

echo "=== Summary ==="
echo -e "$RESULTS"
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total: $((PASSED + FAILED))"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
