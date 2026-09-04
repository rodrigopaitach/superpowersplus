#!/usr/bin/env bash
#
# Tests for scripts/release-notes.sh — where a changelog section ends.
#
# Each case builds a throwaway repository with the real script installed and
# its own CHANGELOG.md. The changelog is synthetic on purpose: the real one
# changes every release, and a test reading it would drift from asserting
# behaviour to asserting today's content.
#
# The defect this suite was written for: `## Open gaps` is the LAST `## `
# section of the changelog, and the slice fell back to end-of-file when no
# next `## ` was found — swallowing the link-reference footer into the body of
# every release ever generated. The changelog has two kinds of section
# boundary, `## ` and the footer, and the script knew only one.
#
# Proven BY DIFFERENCE: the footer must be absent AND the section's own last
# line must be present. A cut that stops too early passes the first assertion
# alone, which is why both run on the same body.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/release-notes.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

# A changelog shaped like the real one: newest version first, `## Open gaps`
# last among the `## ` headings, then the link-reference footer.
# $1 = lab directory name, $2 = "footer" or "no-footer"
build_lab() {
    local dir="$TEST_ROOT/$1" footer="$2"
    mkdir -p "$dir/scripts"
    cp "$SCRIPT_UNDER_TEST" "$dir/scripts/release-notes.sh"
    chmod +x "$dir/scripts/release-notes.sh"
    cat >"$dir/CHANGELOG.md" <<'CHANGELOG'
# Changelog

## [2.0.0] - 2026-09-03

### Added

- The new thing.

LAST-LINE-OF-2.0.0

## [1.0.0] - 2026-08-02

### Added

- The old thing.

## Open gaps

- A gap that is still open.

LAST-LINE-OF-OPEN-GAPS
CHANGELOG
    # The second boundary. Omitted for the no-footer lab, which is the only
    # case that reaches the end-of-file fallback in section().
    if [ "$footer" = footer ]; then
        cat >>"$dir/CHANGELOG.md" <<'FOOTER'

[2.0.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v2.0.0
[1.0.0]: https://github.com/rodrigopaitach/superpowersplus/releases/tag/v1.0.0
FOOTER
    fi
    printf '%s' "$dir"
}

# Run the script and keep stderr. Discarding it is what the first version of
# this suite did, and under `set -e` a failing script then produced a header
# line and nothing else — the one message naming the cause went to /dev/null.
# $1 = lab, $2 = version
run_script() {
    local lab="$1" version="$2" err
    if ! err="$("$lab/scripts/release-notes.sh" "$version" "$lab/body.md" 2>&1)"; then
        printf '  FAIL: release-notes.sh exited non-zero for %s\n' "$version"
        printf '        %s\n' "$err"
        FAILURES=$((FAILURES + 1))
        return 1
    fi
    return 0
}

# grep reports "not found" both when the string is absent and when it never
# searched — a missing file (exit 2) or a file it classified as binary. An
# assertion whose whole job is proving ABSENCE cannot tell those apart, so the
# file is checked first and grep is given -a.
# $1 = label, $2 = body file, $3 = string that must NOT appear
assert_absent() {
    if [ ! -f "$2" ]; then
        printf '  FAIL: %s — %s does not exist\n' "$1" "$2"
        FAILURES=$((FAILURES + 1))
        return
    fi
    if grep -qaF "$3" "$2"; then
        printf '  FAIL: %s — body contains %s\n' "$1" "$3"
        FAILURES=$((FAILURES + 1))
    else
        printf '  ok: %s\n' "$1"
    fi
}

# $1 = label, $2 = body file, $3 = string that MUST appear
assert_present() {
    if [ ! -f "$2" ]; then
        printf '  FAIL: %s — %s does not exist\n' "$1" "$2"
        FAILURES=$((FAILURES + 1))
        return
    fi
    if grep -qaF "$3" "$2"; then
        printf '  ok: %s\n' "$1"
    else
        printf '  FAIL: %s — body is missing %s\n' "$1" "$3"
        FAILURES=$((FAILURES + 1))
    fi
}

printf 'the link-reference footer is not part of the Open gaps section\n'
lab="$(build_lab footer footer)"
if run_script "$lab" 2.0.0; then
    assert_absent 'footer link for 2.0.0 stays out of the body' "$lab/body.md" \
        '[2.0.0]: https://github.com'
    assert_absent 'footer link for 1.0.0 stays out of the body' "$lab/body.md" \
        '[1.0.0]: https://github.com'
    assert_present 'the last line of Open gaps survives the cut' "$lab/body.md" \
        'LAST-LINE-OF-OPEN-GAPS'

    printf 'a version section still ends at the next version, on the same body\n'
    assert_present 'the last line of 2.0.0 is in the body' "$lab/body.md" \
        'LAST-LINE-OF-2.0.0'
    assert_absent 'the older version does not leak in' "$lab/body.md" \
        'The old thing.'
fi

# End-of-file IS a legitimate end for a document, which is why section() keeps
# its len(text) fallback. That claim is asserted here rather than only stated:
# a changelog with no footer must still yield the whole Open gaps section.
printf 'a changelog with no footer still yields the whole last section\n'
lab="$(build_lab no-footer no-footer)"
if run_script "$lab" 2.0.0; then
    assert_present 'the last line of Open gaps survives with no terminator' \
        "$lab/body.md" 'LAST-LINE-OF-OPEN-GAPS'
fi

if [ "$FAILURES" -ne 0 ]; then
    printf '\n%d assertion(s) failed\n' "$FAILURES"
    exit 1
fi
printf '\nall assertions passed\n'
