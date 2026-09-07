#!/usr/bin/env bash
#
# save-review-report.sh — install a review report where nothing can overwrite it.
#
# Usage:
#   save-review-report.sh <source> <destination>
#
# Prints the path it actually used. The caller writes THAT path into the
# ledger, never the one it passed in: on a name collision this script installs
# at the next free suffix and says so.
#
# Exit statuses, fixed by the spec so a caller can tell the cases apart:
#   0  installed and verified
#   2  usage
#   3  a write error that is NOT a name collision
#   4  the report does not match its source; nothing was installed
#   5  the suffix bound was exhausted
#
# HOW THE NO-OVERWRITE GUARANTEE IS OBTAINED — stated in full, because the
# first version of this script got it wrong:
#
#   The report is written into a temporary file in the destination's OWN
#   directory and then linked into place with the `link` UTILITY. Two separate
#   things have to be right here, and confusing them is what produced the
#   second round of defects:
#
#   THE SYSTEM CALL'S GUARANTEE. POSIX defines link() to "atomically create a
#   new hard link", failing with [EEXIST] when "the path2 argument resolves to
#   an existing directory entry OR REFERS TO A SYMBOLIC LINK". So the name is
#   claimed or the call fails — for every kind of object that can already be
#   there: regular file, directory, FIFO, device, socket, and a symbolic link
#   whether or not it resolves to anything.
#
#   THE COMMAND'S SEMANTICS, which is a different question. `ln source target`
#   does NOT make that call on `target` when `target` is a directory: POSIX
#   says of ln that "the second synopsis form shall be assumed when the final
#   operand names an existing directory", so the command links INTO it. That
#   is specified behaviour, not a quirk, and measured against this script when
#   it used `ln`: a destination that was a directory named report.md exited 0,
#   left report.md/.save-review-report.<suffix> inside it, and printed the
#   DIRECTORY as the installed report; a symbolic link to a directory reached
#   the same behaviour through pathname resolution and wrote into somebody
#   else's directory.
#
#   The `link` utility is the one that has no such rule: POSIX gives it
#   "OPTIONS: None" and defines it as performing "the function call:
#   link(file1, file2)". `ln -T` fixes the same thing on GNU coreutils and is
#   not used, because it is a GNU extension and this script ships to machines
#   that have BSD's ln.
#
#   It is NOT `set -C` with a `>` redirection, which is what this script used
#   until the defects below were measured. The Bash manual (5.3.9, "Redirecting
#   Output") says that redirection "fails if the file whose name results from
#   the expansion of word exists AND IS A REGULAR FILE". Regular file only —
#   so noclobber says nothing about any other kind of object, and all three of
#   these were reproduced against the old script:
#     * destination a symbolic link to /dev/null — the redirection SUCCEEDED,
#       the report went into the void, the comparison then found the bytes
#       different, and the cleanup DELETED a symlink this script never created;
#     * destination a FIFO — the run blocked in open(), waiting for a reader
#       that never came;
#     * destination a dangling symbolic link — reported as a write error
#       instead of a taken name, so no suffix was ever tried.
#
#   link() also never opens the destination. That is what makes the FIFO case
#   terminate instead of waiting.
#
# WHAT THE COMPARISON PROVES — read this before trusting a pass:
#   It proves the installed bytes equal the bytes THIS SCRIPT WAS HANDED. It
#   does NOT prove the caller transcribed a subagent's returned report
#   faithfully. That earlier step is outside this helper's inputs and is not
#   verified by this comparison.
#
# WHAT THIS DOES NOT COVER:
#   * A destination directory on a filesystem with no hard links. `link` fails
#     there and this script exits 3, rather than falling back to a redirection:
#     every fallback available in shell reintroduces the defects above.
#
set -uo pipefail   # deliberately not -e: this script reads exit statuses itself

readonly EXIT_USAGE=2 EXIT_WRITE=3 EXIT_DIVERGED=4 EXIT_EXHAUSTED=5
readonly MAX_SUFFIX=99

staged=""

# The ONLY removal in this script, and the only path it can ever name is the
# temporary file THIS run created with mktemp. No path derived from the
# caller's destination is passed to it, on any branch, so no object that was
# already on disk can be removed by this script at all.
discard_the_staged_copy() {
    if [ -n "$staged" ]; then
        rm -f -- "$staged"
        staged=""
    fi
}
trap discard_the_staged_copy EXIT

die() { printf 'save-review-report: %s\n' "$1" >&2; exit "$2"; }

[ "$#" -eq 2 ] || die "usage: save-review-report.sh <source> <destination>" "$EXIT_USAGE"
src="$1"; dst="$2"
[ -f "$src" ] || die "source is not a readable file: $src" "$EXIT_USAGE"

# The reviews directory does not exist in a project that has never saved one.
# Without this, the FIRST save in every project fails — a failure invisible in
# any checkout where the directory happens to be there already.
dst_dir="$(dirname -- "$dst")"
mkdir -p -- "$dst_dir" 2>/dev/null \
    || die "cannot create the directory $dst_dir" "$EXIT_WRITE"

# Staged in the destination's own directory because `link` makes a hard link,
# and a hard link cannot cross a filesystem boundary.
staged="$(mktemp -- "$dst_dir/.save-review-report.XXXXXX" 2>/dev/null)" \
    || die "cannot write into the directory $dst_dir" "$EXIT_WRITE"

# mktemp creates its file at 0600. A report is an ordinary document that other
# people read out of the repository, so give it the mode a plain redirection
# would have produced under the caller's umask.
chmod "$(printf '%o' "$(( 0666 & ~0$(umask) ))")" -- "$staged" 2>/dev/null \
    || die "cannot set the mode on the staged copy in $dst_dir" "$EXIT_WRITE"

if ! cat -- "$src" > "$staged" 2>/dev/null; then
    die "could not copy the report out of $src" "$EXIT_WRITE"
fi

# The integrity check runs HERE, before the report is given its real name, so a
# report that does not match its source never appears at that name even for an
# instant — and the cleanup that follows a divergence removes only the staged
# copy, never anything at the destination.
if ! cmp -s -- "$src" "$staged"; then
    die "staged bytes differ from $src — nothing was installed" "$EXIT_DIVERGED"
fi

# Every candidate is built as "$dst_dir/<name>" rather than from "$dst"
# directly. For an ordinary path the result is byte-identical to what the
# caller passed; for a bare relative name it gains the "./" that keeps the
# operand from ever beginning with a hyphen, which matters because the `link`
# utility below has no `--`.
dst_name="$(basename -- "$dst")"
base="${dst_name%.md}"
n=1
while :; do
    if [ "$n" -eq 1 ]; then name="$dst_name"; else name="$base-$n.md"; fi
    target="$dst_dir/$name"

    # The atomic claim on the name. See the header for why this is the `link`
    # utility and neither a redirection nor `ln`.
    #
    # No `--`: POSIX gives link "OPTIONS: None", so `--` is not specified for
    # it. The guard against a target that begins with a hyphen is the path
    # construction above, which always prefixes the directory.
    if link "$staged" "$target" 2>/dev/null; then
        break
    fi

    # `link` exits non-zero both for a taken name and for a real write error,
    # and its message is emitted in the environment's locale — measured on this
    # project's machine in pt-BR. A parser of that text is right in one locale
    # and wrong in every other, so the message is discarded above and the
    # discriminator is STATE, which no locale changes.
    #
    # `-L` is not redundant with `-e`: `-e` follows the symlink, so a DANGLING
    # symbolic link is a name that link() refuses with [EEXIST] and that `-e`
    # alone reports as free. That combination is the third measured defect.
    if [ -e "$target" ] || [ -L "$target" ]; then
        n=$((n + 1))
        [ "$n" -le "$MAX_SUFFIX" ] \
            || die "every name up to $dst_dir/$base-$MAX_SUFFIX.md is taken" "$EXIT_EXHAUSTED"
        continue
    fi
    # Not "the directory is not writable": the same branch is reached by a name
    # the filesystem rejects, in a directory that is perfectly writable, and by
    # a filesystem that has no hard links at all.
    die "cannot create $target" "$EXIT_WRITE"
done

discard_the_staged_copy
printf '%s\n' "$target"
