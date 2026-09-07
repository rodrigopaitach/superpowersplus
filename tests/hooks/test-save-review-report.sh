#!/usr/bin/env bash
#
# Tests for skills/requesting-code-review/scripts/save-review-report.sh.
#
# The helper's whole job is that it never overwrites something it did not
# create. Most of these cases are therefore about what happens when it CANNOT
# write, because that is the only place an overwrite can come from: a write
# error misread as a name collision walks the suffix search and produces
# -2, -3, … without writing anything, and a failure misread the other way lets
# the cleanup remove a file this run never created.
#
# `divergence removes what it created` mutates a COPY of the helper. The
# shipped script gains no seam for it: a script that runs a command handed to
# it by its environment would be a real hazard created only for a test.
#
# Every case but the last runs the helper as `bash <path>`. The last one runs
# it as a command, which is the only assertion here that depends on the
# executable bit — tested through behaviour that needs it rather than as a
# mode comparison.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HELPER="$REPO_ROOT/skills/requesting-code-review/scripts/save-review-report.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

PROBLEMS=()
T=""

# A case makes several assertions and reports ONE line, under the name the
# plan's verification matrix cites. A case reporting one line per assertion
# would let a matrix row point at a name that never appears in the output.
begin() {
    PROBLEMS=()
    T="$(mktemp -d "$TEST_ROOT/case.XXXXXX")"
}

note() {
    PROBLEMS+=("$1")
}

end() {
    if [ "${#PROBLEMS[@]}" -eq 0 ]; then
        echo "  [PASS] $1"
    else
        echo "  [FAIL] $1"
        local problem
        for problem in ${PROBLEMS[@]+"${PROBLEMS[@]}"}; do
            echo "        $problem"
        done
        FAILURES=$((FAILURES + 1))
    fi
}

# run <command> <args...> — captures stdout, stderr and status separately.
# STATUS is the discriminator every case here reads; OUT is the path the caller
# is told to write into the ledger; ERR is where a failure explains itself.
run() {
    local command="$1"
    shift
    STATUS=0
    "$command" "$@" >"$T/.stdout" 2>"$T/.stderr" || STATUS=$?
    OUT="$(cat "$T/.stdout")"
    ERR="$(cat "$T/.stderr")"
}

SOURCE_BODY='# A review report

Blocking: one thing.
'

echo "Test: save-review-report.sh"

# --- 1. the ordinary path --------------------------------------------------
begin
printf '%s' "$SOURCE_BODY" > "$T/src.md"
run bash "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
[ "$OUT" = "$T/reviews/r.md" ] || note "printed [$OUT], expected [$T/reviews/r.md]"
cmp -s "$T/src.md" "$T/reviews/r.md" || note "installed bytes differ from the source"
end "free destination"

# --- 2. the collision, which is the whole reason this helper exists ---------
# The prior file must be byte-identical afterwards AND the printed path must be
# the suffixed one. Either assertion alone passes a helper that overwrote and
# then printed something plausible.
begin
mkdir -p "$T/reviews"
printf '%s' "$SOURCE_BODY" > "$T/src.md"
printf 'the earlier report, which must survive\n' > "$T/reviews/r.md"
run bash "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
[ "$OUT" = "$T/reviews/r-2.md" ] || note "printed [$OUT], expected [$T/reviews/r-2.md]"
[ "$(cat "$T/reviews/r.md")" = "the earlier report, which must survive" ] \
    || note "the prior file was modified"
cmp -s "$T/src.md" "$T/reviews/r-2.md" || note "the suffixed install differs from the source"
end "collision preserves the prior file"

# --- 2b-2d. a destination that is not a regular file ------------------------
# The three cases below exist because the first implementation trusted bash's
# `noclobber` to mean "this name is free". It does not. The Bash manual, for
# the 5.3.9 installed here, says the redirection "fails if the file whose name
# results from the expansion of word exists AND IS A REGULAR FILE" — so every
# other kind of object at that name is opened rather than refused, and the
# helper concluded it had created something it had not.
#
# Each case asserts the same three things, because the failure took a different
# shape in each: the preexisting object survives untouched, the install goes to
# a suffix, and the run terminates.

# A symlink to /dev/null is not a regular file, so the redirection SUCCEEDED,
# the report went into the void, the comparison found the destination empty and
# the cleanup deleted the symlink — an object this run never created.
begin
mkdir -p "$T/reviews"
printf '%s' "$SOURCE_BODY" > "$T/src.md"
ln -s /dev/null "$T/reviews/r.md"
run timeout 20 bash "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
[ -L "$T/reviews/r.md" ] || note "the preexisting symlink was removed"
[ "$(readlink "$T/reviews/r.md" 2>/dev/null)" = "/dev/null" ]     || note "the preexisting symlink no longer points where it did"
[ "$OUT" = "$T/reviews/r-2.md" ] || note "printed [$OUT], expected the -2 suffix"
cmp -s "$T/src.md" "$T/reviews/r-2.md" || note "nothing was installed at the suffix"
end "a symlink destination is a collision, not a target"

# A FIFO is not a regular file either, so the redirection was attempted — and
# opening a FIFO for writing BLOCKS until a reader arrives. The run hung.
begin
mkdir -p "$T/reviews"
printf '%s' "$SOURCE_BODY" > "$T/src.md"
mkfifo "$T/reviews/r.md"
run timeout 20 bash "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -ne 124 ] || note "the run blocked and was killed by the timeout"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
[ -p "$T/reviews/r.md" ] || note "the preexisting FIFO is gone or is no longer a FIFO"
[ "$OUT" = "$T/reviews/r-2.md" ] || note "printed [$OUT], expected the -2 suffix"
cmp -s "$T/src.md" "$T/reviews/r-2.md" || note "nothing was installed at the suffix"
end "a FIFO destination does not block the run"

# A dangling symlink is a name that IS taken — POSIX link() returns EEXIST for
# it — but `[ -e ]` follows the link and reports false, so the old classifier
# read a taken name as a write error and never tried a suffix.
begin
mkdir -p "$T/reviews"
printf '%s' "$SOURCE_BODY" > "$T/src.md"
ln -s "$T/reviews/nowhere.md" "$T/reviews/r.md"
run timeout 20 bash "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
[ -L "$T/reviews/r.md" ] || note "the preexisting dangling symlink was removed"
[ ! -e "$T/reviews/nowhere.md" ] || note "the report was written THROUGH the dangling symlink"
[ "$OUT" = "$T/reviews/r-2.md" ] || note "printed [$OUT], expected the -2 suffix"
cmp -s "$T/src.md" "$T/reviews/r-2.md" || note "nothing was installed at the suffix"
end "a dangling symlink destination is a collision"

# A DIRECTORY at the destination name. This is not the same question as the
# three above, and it is why they were not enough: link() refuses the name, but
# `ln source target` is not a bare link() call — when target names a directory
# the command treats it as "link INTO that directory" and creates
# target/<basename of source>. Measured: the run then exits 0, leaves
# r.md/.save-review-report.<suffix> inside the directory, and prints the
# DIRECTORY as though it were the installed report.
begin
mkdir -p "$T/reviews/r.md"
printf '%s' "$SOURCE_BODY" > "$T/src.md"
run timeout 20 bash "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
[ -d "$T/reviews/r.md" ] || note "the preexisting directory is gone or is no longer a directory"
[ -z "$(find "$T/reviews/r.md" -mindepth 1 -print -quit)" ] \
    || note "something was written INTO the preexisting directory"
[ "$OUT" = "$T/reviews/r-2.md" ] || note "printed [$OUT], expected the -2 suffix"
cmp -s "$T/src.md" "$T/reviews/r-2.md" || note "the suffixed install differs from the source"
end "a directory destination is a collision"

# A symbolic link TO a directory reaches the same command behaviour through
# pathname resolution, and writes into somebody else's directory rather than
# this one.
begin
mkdir -p "$T/reviews" "$T/elsewhere"
printf '%s' "$SOURCE_BODY" > "$T/src.md"
ln -s "$T/elsewhere" "$T/reviews/r.md"
run timeout 20 bash "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
[ -L "$T/reviews/r.md" ] || note "the preexisting symlink was removed"
[ "$(readlink "$T/reviews/r.md" 2>/dev/null)" = "$T/elsewhere" ] \
    || note "the preexisting symlink no longer points where it did"
[ -z "$(find "$T/elsewhere" -mindepth 1 -print -quit)" ] \
    || note "something was written into the directory the symlink names"
[ "$OUT" = "$T/reviews/r-2.md" ] || note "printed [$OUT], expected the -2 suffix"
cmp -s "$T/src.md" "$T/reviews/r-2.md" || note "the suffixed install differs from the source"
end "a symlink-to-directory destination is a collision"

# --- 3. the integrity comparison -------------------------------------------
# A COPY of the helper, edited so the content write truncates. The shipped
# script is not touched and gains nothing for this.
#
# The comparison runs against the STAGED copy, before the report is linked to
# its real name, so a diverged report never appears at the destination at all —
# not even for an instant. The case therefore asserts absence at the
# destination AND that the staged copy was cleaned up.
begin
printf '%s' "$SOURCE_BODY" > "$T/src.md"
# `|| note` rather than a bare command: under `set -e` a sed that cannot read
# the helper would abort the whole suite here, and the six cases below would
# not run at all — a partial run that reports fewer failures than there are.
sed 's/cat -- /head -c 8 -- /' "$HELPER" > "$T/mutant.sh" \
    || note "could not read the helper in order to mutate a copy of it"
grep -q 'head -c 8 -- ' "$T/mutant.sh" \
    || note "the mutation did not apply — this case would then measure nothing"
run bash "$T/mutant.sh" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 4 ] || note "exit $STATUS, expected 4"
printf '%s' "$ERR" | grep -q 'differ' || note "the message does not say the bytes differed: $ERR"
[ ! -e "$T/reviews/r.md" ] || note "a diverged report was installed at the destination"
[ -z "$(find "$T/reviews" -name '.save-review-report.*' -print -quit 2>/dev/null)" ] \
    || note "the staged copy was left behind"
end "divergence installs nothing"

# --- 4. a write error that is NOT a collision ------------------------------
# The fixture is a filename the filesystem rejects, in a directory that exists
# and is perfectly writable. Measured 2026-09-06: this reaches the branch AFTER
# mkdir has succeeded and the exclusive create has failed for a reason other
# than the destination being taken — which is the branch AC8 is about.
#
# NOT a permission fixture, deliberately: a directory with no write bit is
# still writable by root, so a permission case passes silently wherever CI runs
# as root, and CI's user is not this machine's user. A name-length limit is not
# a permission and does not have that property.
begin
mkdir -p "$T/reviews"
printf '%s' "$SOURCE_BODY" > "$T/src.md"
long_name="$(printf 'x%.0s' $(seq 1 300))"
run bash "$HELPER" "$T/src.md" "$T/reviews/$long_name.md"
[ "$STATUS" -eq 3 ] || note "exit $STATUS, expected 3"
printf '%s' "$ERR" | grep -q "$T/reviews" || note "the message does not name the path: $ERR"
[ -z "$(find "$T/reviews" -name '*-[0-9]*.md' -print -quit)" ] \
    || note "a suffixed file was created on a non-collision error"
end "a non-collision error does not suffix"

# --- 5. the other half of the same behaviour -------------------------------
# The reviews directory does not exist in a project that has never saved a
# report. Without the mkdir the FIRST save in every project fails, and it fails
# invisibly in any checkout where the directory happens to be there already.
begin
printf '%s' "$SOURCE_BODY" > "$T/src.md"
run bash "$HELPER" "$T/src.md" "$T/a/b/c/r.md"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
cmp -s "$T/src.md" "$T/a/b/c/r.md" || note "nothing was installed at the deep path"
end "the directory is created on first use"

# --- 6. the suffix bound ---------------------------------------------------
begin
mkdir -p "$T/reviews"
printf '%s' "$SOURCE_BODY" > "$T/src.md"
printf 'the earliest report\n' > "$T/reviews/r.md"
for n in $(seq 2 99); do
    printf 'taken\n' > "$T/reviews/r-$n.md"
done
run bash "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 5 ] || note "exit $STATUS, expected 5"
[ "$(cat "$T/reviews/r.md")" = "the earliest report" ] \
    || note "the preexisting destination was modified in a failing run"
[ ! -e "$T/reviews/r-100.md" ] || note "the bound was crossed"
end "the bound is reached and nothing is touched"

# --- 7. usage --------------------------------------------------------------
begin
printf '%s' "$SOURCE_BODY" > "$T/src.md"
run bash "$HELPER" "$T/src.md"
[ "$STATUS" -eq 2 ] || note "one argument: exit $STATUS, expected 2"
[ ! -e "$T/r.md" ] || note "one argument: a file was created"
run bash "$HELPER" "$T/src.md" "$T/r.md" extra
[ "$STATUS" -eq 2 ] || note "three arguments: exit $STATUS, expected 2"
[ ! -e "$T/r.md" ] || note "three arguments: a file was created"
end "usage"

# --- 8. the executable bit, through the behaviour that needs it ------------
# AC1 is behavioral, and `test -x` is not what that class admits. Invoking the
# helper as a command is: the reference and the helper's own Usage line both
# tell a caller to run it this way, and without the mode bit that call is the
# one thing that fails.
begin
printf '%s' "$SOURCE_BODY" > "$T/src.md"
run "$HELPER" "$T/src.md" "$T/reviews/r.md"
[ "$STATUS" -eq 0 ] || note "exit $STATUS, expected 0 ($ERR)"
cmp -s "$T/src.md" "$T/reviews/r.md" || note "nothing was installed"
end "the helper runs as a command"

echo
if [ "$FAILURES" -gt 0 ]; then
    echo "$FAILURES save-review-report test(s) failed"
    exit 1
fi
echo "All save-review-report tests passed"
