#!/usr/bin/env bash
#
# Tests for scripts/check-links.sh.
#
# The script resolves its own repository root from its location, so each case
# copies it into a throwaway tree and builds the target files there. That
# exercises the real script — including its hardcoded list of target files —
# rather than a parameterized variant that only exists for tests.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-links.sh"

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

# new_tree — throwaway repository with the script installed and every target
# file present but empty. Echoes its path.
new_tree() {
    local tree
    tree="$(mktemp -d "$TEST_ROOT/tree.XXXXXX")"
    mkdir -p "$tree/scripts" "$tree/docs"
    cp "$SCRIPT_UNDER_TEST" "$tree/scripts/check-links.sh"
    local target
    for target in README.md CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md CHANGELOG.md; do
        : > "$tree/$target"
    done
    printf '%s\n' "$tree"
}

# assert_run <expected exit> <description> <tree> [needle in output]
assert_run() {
    local expected="$1" description="$2" tree="$3" needle="${4:-}"
    local actual output
    output="$("$tree/scripts/check-links.sh" 2>&1)" && actual=0 || actual=$?

    if [ "$actual" -ne "$expected" ]; then
        fail "$description"
        echo "    expected exit $expected, got $actual"
        printf '%s\n' "$output" | sed 's/^/      /'
        return
    fi
    if [ -n "$needle" ] && ! printf '%s' "$output" | grep -Fq -- "$needle"; then
        fail "$description"
        echo "    output did not mention '$needle'"
        printf '%s\n' "$output" | sed 's/^/      /'
        return
    fi
    pass "$description"
}

echo "Test: a link that resolves, and one that does not"
T="$(new_tree)"
printf '# Doc\n\nSee [the guide](docs/guide.md).\n' > "$T/README.md"
printf '# Guide\n' > "$T/docs/guide.md"
assert_run 0 "existing file passes" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [the guide](docs/missing.md).\n' > "$T/README.md"
assert_run 1 "missing file fails" "$T" "no such file"

echo "Test: anchors"
T="$(new_tree)"
printf '# Doc\n\nSee [gaps](CHANGELOG.md#open-gaps).\n' > "$T/README.md"
printf '# Changelog\n\n## Open gaps\n' > "$T/CHANGELOG.md"
assert_run 0 "existing anchor passes" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [gaps](CHANGELOG.md#closed-gaps).\n' > "$T/README.md"
printf '# Changelog\n\n## Open gaps\n' > "$T/CHANGELOG.md"
assert_run 1 "missing anchor fails" "$T" "no heading with anchor"

T="$(new_tree)"
printf '# Doc\n\nJump to [gaps](#open-gaps).\n\n## Open gaps\n' > "$T/README.md"
assert_run 0 "same-file anchor passes" "$T"

echo "Test: GitHub slug rules on the shapes this repo actually has"
T="$(new_tree)"
printf '# Doc\n\nVeja [pendências](docs/hist.md#pendências-conhecidas).\n' > "$T/README.md"
printf '# Hist\n\n## Pendências conhecidas\n' > "$T/docs/hist.md"
assert_run 0 "accented anchor passes (accents are kept)" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [part one](docs/port.md#part-1--how-it-works).\n' > "$T/README.md"
printf '# Port\n\n## Part 1 — How it works\n' > "$T/docs/port.md"
assert_run 0 "em dash leaves two hyphens" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [docs](docs/emo.md#documentation).\n' > "$T/README.md"
printf '# Emo\n\n## 📖 Documentation\n' > "$T/docs/emo.md"
assert_run 1 "emoji leaves the leading hyphen it strips to" "$T" "no heading with anchor"

T="$(new_tree)"
printf '# Doc\n\nSee [docs](docs/emo.md#-documentation).\n' > "$T/README.md"
printf '# Emo\n\n## 📖 Documentation\n' > "$T/docs/emo.md"
assert_run 0 "the emoji heading answers to its real slug" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [code](docs/c.md#the-scripts-shape).\n' > "$T/README.md"
printf '# C\n\n## The `scripts/` shape\n' > "$T/docs/c.md"
assert_run 0 "backticks and slashes come out of the slug" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [second](docs/d.md#added-1).\n' > "$T/README.md"
printf '# D\n\n## Added\n\ntext\n\n## Added\n' > "$T/docs/d.md"
assert_run 0 "duplicate headings get GitHub's -1 suffix" "$T"

echo "Test: what is deliberately not checked"
T="$(new_tree)"
printf '# Doc\n\n[dead](https://example.invalid/nope) and [also](http://x.invalid).\n' > "$T/README.md"
assert_run 0 "http and https links are ignored" "$T"

T="$(new_tree)"
printf '# Doc\n\n```bash\n# A comment, not a heading\ncat [not](a/link.md)\n```\n' > "$T/README.md"
assert_run 0 "links inside fenced code are ignored" "$T"

T="$(new_tree)"
printf '# Doc\n\n![shot](docs/shot.png)\n' > "$T/README.md"
: > "$T/docs/shot.png"
assert_run 0 "an image that exists passes" "$T"

echo "Test: docs/ files are targets too, not just the two bilingual READMEs"
T="$(new_tree)"
printf '# Other doc\n\nSee [gone](gone.md).\n' > "$T/docs/README.kimi.md"
assert_run 1 "a broken link inside docs/ is caught" "$T" "README.kimi.md"

T="$(new_tree)"
printf '# Doc\n\nSee [outside](../../etc/passwd).\n' > "$T/README.md"
assert_run 1 "a path escaping the repository is rejected" "$T" "escapes the repository"

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All check-links tests passed"
else
    echo "$FAILURES check-links test(s) failed"
    exit 1
fi
