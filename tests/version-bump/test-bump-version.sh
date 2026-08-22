#!/usr/bin/env bash
#
# Tests for scripts/bump-version.sh — the preflight that makes the bump
# all-or-nothing.
#
# Each case builds a throwaway repository with the real script installed and
# its own .version-bump.json declaring three manifests. That exercises the real
# walk over declared files, not a parameterized variant.
#
# The two states that matter are proven BY DIFFERENCE: with one manifest
# broken, NO declared manifest changes version; with all of them well formed,
# the bump still succeeds. A gate that only checks the exit code cannot tell a
# preflight from a script that aborted halfway.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/bump-version.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

# Build a lab: three declared manifests, the middle one given by the caller.
# $1 = directory name, $2 = contents of the middle manifest
build_lab() {
  local dir="$TEST_ROOT/$1" middle="$2"
  mkdir -p "$dir/scripts"
  cp "$SCRIPT_UNDER_TEST" "$dir/scripts/bump-version.sh"
  chmod +x "$dir/scripts/bump-version.sh"
  cat >"$dir/.version-bump.json" <<'CONFIG'
{ "files": [
    { "path": "a.json", "field": "version" },
    { "path": "b.json", "field": "version" },
    { "path": "c.json", "field": "version" } ],
  "audit": { "exclude": [".git"] } }
CONFIG
  printf '{ "version": "1.0.0" }\n' >"$dir/a.json"
  printf '%s' "$middle" >"$dir/b.json"
  printf '{ "version": "1.0.0" }\n' >"$dir/c.json"
  printf '%s' "$dir"
}

# $1 = label, $2 = file, $3 = expected version substring
assert_version() {
  if grep -q "$3" "$2"; then
    printf '  ok: %s\n' "$1"
  else
    printf '  FAIL: %s — %s does not contain %s\n' "$1" "$2" "$3"
    printf '        actual: %s\n' "$(cat "$2")"
    FAILURES=$((FAILURES + 1))
  fi
}

printf 'unparseable manifest writes nothing\n'
lab="$(build_lab unparseable '{ "version": ')"
set +e
(cd "$lab" && ./scripts/bump-version.sh 2.0.0 >/dev/null 2>&1)
status=$?
set -e
if [ "$status" -ne 0 ]; then
  printf '  ok: exits non-zero (%s)\n' "$status"
else
  printf '  FAIL: expected non-zero exit, got 0\n'
  FAILURES=$((FAILURES + 1))
fi
assert_version "a.json untouched" "$lab/a.json" '1.0.0'
assert_version "c.json untouched" "$lab/c.json" '1.0.0'

printf 'missing field writes nothing\n'
lab="$(build_lab missingfield '{ "other": "x" }')"
set +e
(cd "$lab" && ./scripts/bump-version.sh 2.0.0 >/dev/null 2>&1)
status=$?
set -e
if [ "$status" -ne 0 ]; then
  printf '  ok: exits non-zero (%s)\n' "$status"
else
  printf '  FAIL: expected non-zero exit, got 0\n'
  FAILURES=$((FAILURES + 1))
fi
assert_version "a.json untouched" "$lab/a.json" '1.0.0'
assert_version "c.json untouched" "$lab/c.json" '1.0.0'
if grep -q 'version' "$lab/b.json"; then
  printf '  FAIL: the field was created in a manifest that never had it\n'
  FAILURES=$((FAILURES + 1))
else
  printf '  ok: no field invented\n'
fi

printf 'all well formed still succeeds\n'
lab="$(build_lab wellformed '{ "version": "1.0.0" }')"
set +e
(cd "$lab" && ./scripts/bump-version.sh 2.0.0 >/dev/null 2>&1)
set -e
assert_version "a.json bumped" "$lab/a.json" '2.0.0'
assert_version "b.json bumped" "$lab/b.json" '2.0.0'
assert_version "c.json bumped" "$lab/c.json" '2.0.0'

printf 'check stays tolerant\n'
lab="$(build_lab tolerant '{ "other": "x" }')"
set +e
out="$(cd "$lab" && ./scripts/bump-version.sh --check 2>&1)"
set -e
if printf '%s' "$out" | grep -q 'c.json'; then
  printf '  ok: --check reported past the unreadable manifest\n'
else
  printf '  FAIL: --check stopped before the third manifest\n'
  printf '        output: %s\n' "$out"
  FAILURES=$((FAILURES + 1))
fi

if [ "$FAILURES" -eq 0 ]; then
  printf '\nAll cases passed.\n'
else
  printf '\n%s case(s) failed.\n' "$FAILURES"
  exit 1
fi
