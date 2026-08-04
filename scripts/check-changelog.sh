#!/usr/bin/env bash
#
# check-changelog.sh — pre-commit hook: content changes ship with their entry.
#
# The rule already existed in CLAUDE.md and failed inside the same cycle that
# wrote it: ab1cf41 shipped the commit-preparation rule and
# check-skill-behavior-records.sh with no CHANGELOG.md line at all, and nobody
# noticed until the version was cut and the entry had to be reconstructed from
# the diff. A rule nothing enforces is a rule that holds until the first busy
# commit. This is the gate.
#
# Scope: what a reader of the changelog would expect to find named there —
# skills (agent behavior), scripts and githooks (the checks that guard it),
# .github (what CI enforces), hooks (what loads at session start). Commits that
# touch only docs/, tests/ or fixtures are exempt by not matching, which is why
# the list is a small allowlist of prefixes rather than an exclusion list.
#
# Staging the changelog is necessary and was never sufficient: the gate proved
# the entry existed, never that the edit was correct. One session produced three
# defects no gate would have caught — an entry title replaced instead of
# preceded (an Edit whose old_string was the next entry's heading), and two
# file:line anchors that pointed nowhere. All three were caught by reading the
# diff before committing, which is exactly the step a busy commit skips. The
# structural checks below are the ones a machine can decide.
#
# What they do NOT cover, so nobody assumes coverage that is not here:
#
#   * An anchor pointing at the WRONG LINE of a file that exists and is long
#     enough. Deciding that needs the claim's meaning, which is a reader's job.
#     `path.md:40` where the subject moved to :44 passes this gate.
#   * An anchor matching several files — `SKILL.md:63` matches fifteen. Those
#     are skipped, not failed: this changelog's path convention is genuinely
#     mixed (repo-root; relative to skills/; relative to the directory being
#     discussed, as in `references/final-review.md`; and bare basenames
#     resolved by the surrounding sentence), and a gate that guessed would go
#     red on correct entries. That fourth convention is why the resolver ends
#     in a suffix match: charging it as nonexistent took CI red on 1.7.0, on an
#     anchor written before this gate existed and correct the whole time.
#   * Prose accuracy of any kind. This is a structural check, not a reviewer.
#
# Usage:
#   check-changelog.sh    Exit 1 if content is staged without CHANGELOG.md,
#                         or if a staged CHANGELOG.md fails a structural check
#
set -euo pipefail

CHANGELOG="CHANGELOG.md"

CONTENT_PREFIXES=(skills/ scripts/ githooks/ .github/ hooks/)

staged="$(git diff --cached --name-only --diff-filter=ACMRD)"

# ---------------------------------------------------------------------------
# Structural checks, run when CHANGELOG.md is itself staged.
# ---------------------------------------------------------------------------

structure_failed=0

structure_fail() {
    printf 'check-changelog: %s\n' "$1" >&2
    shift
    [ "$#" -eq 0 ] || printf '  %s\n' "$@" >&2
    printf '\n' >&2
    structure_failed=1
}

# resolve_anchor <path> — echo every tracked file the anchor could name.
# Cascade, in the order a reader resolves them: as written from the repository
# root, then under skills/, then anywhere tracked whose path ENDS with it. That
# last step covers two conventions at once — a bare basename (`SKILL.md`) and a
# path relative to the directory of the file being discussed
# (`references/final-review.md`, read from inside a skill). Counting the
# matches is the caller's job: one is a resolution, several is an ambiguity to
# skip, none is a claim to charge.
resolve_anchor() {
    local path="$1"
    if [ -f "$path" ]; then
        printf '%s\n' "$path"
        return
    fi
    if [ -f "skills/$path" ]; then
        printf '%s\n' "skills/$path"
        return
    fi
    git ls-files "*/$path" 2>/dev/null || true
}

check_structure() {
    local staged_body head_body
    staged_body="$(git show ":$CHANGELOG" 2>/dev/null || true)"
    [ -n "$staged_body" ] || return 0
    head_body="$(git show "HEAD:$CHANGELOG" 2>/dev/null || true)"

    # (a) Headings never decrease. A title replaced instead of preceded is
    #     invisible in every other way: the entry reads fine, one is just gone.
    local staged_heads head_heads
    staged_heads="$(printf '%s\n' "$staged_body" | grep -c '^## ' || true)"
    head_heads="$(printf '%s\n' "$head_body" | grep -c '^## ' || true)"
    if [ -n "$head_body" ] && [ "$staged_heads" -lt "$head_heads" ]; then
        structure_fail \
            "a '## ' heading disappeared ($head_heads at HEAD, $staged_heads staged)." \
            "An edit anchored on the next entry's title replaces it instead of" \
            "preceding it. Diff the headings and put the missing one back:" \
            "  git diff --cached $CHANGELOG | grep '^[-+]## '"
    fi

    # (b) One heading, one meaning.
    local dupes unreleased
    dupes="$(printf '%s\n' "$staged_body" | grep '^## ' | sort | uniq -d || true)"
    if [ -n "$dupes" ]; then
        structure_fail "duplicated version heading:" "$dupes"
    fi
    unreleased="$(printf '%s\n' "$staged_body" | grep -c '^## \[Unreleased\]' || true)"
    if [ "$unreleased" -gt 1 ]; then
        structure_fail "[Unreleased] appears $unreleased times; it may appear once."
    fi

    # (c) Anchors added by this commit name a real file, long enough to have
    #     the line. See the header for what this deliberately does not check.
    local added anchor path line matches count target length
    added="$(git diff --cached -U0 -- "$CHANGELOG" | grep '^+' | grep -v '^+++' || true)"
    while IFS= read -r anchor; do
        [ -n "$anchor" ] || continue
        path="${anchor%:*}"
        line="${anchor##*:}"
        line="${line%%-*}"
        matches="$(resolve_anchor "$path")"
        count="$(printf '%s' "$matches" | grep -c . || true)"
        if [ "$count" -eq 0 ]; then
            # Only a path-shaped anchor is specific enough to charge. A bare
            # name matching nothing is prose, not a claim about a file.
            case "$path" in
                */*) structure_fail "anchor names a file that does not exist: $anchor" ;;
            esac
            continue
        fi
        # Several: `SKILL.md` names fifteen files. Picking one needs the
        # sentence around the anchor, so this skips instead of guessing.
        [ "$count" -eq 1 ] || continue
        target="$matches"
        length="$(wc -l <"$target")"
        if [ "$line" -gt "$length" ]; then
            structure_fail \
                "anchor points past the end of the file: $anchor" \
                "$target has $length lines."
        fi
    done < <(printf '%s\n' "$added" |
        grep -oE '\.?[A-Za-z0-9][A-Za-z0-9._/-]*:[0-9]+(-[0-9]+)?' || true)

    [ "$structure_failed" -eq 0 ] || return 1
}

if grep -qxF "$CHANGELOG" <<<"$staged"; then
    check_structure || exit 1
    exit 0
fi

touched=()
while IFS= read -r file; do
    [ -n "$file" ] || continue
    for prefix in "${CONTENT_PREFIXES[@]}"; do
        # Anchored by construction: only a path starting with the prefix
        # matches, so vendor/skills/ is not a skills/ change.
        case "$file" in
            "$prefix"*) touched+=("$file"); break ;;
        esac
    done
done <<<"$staged"

[ "${#touched[@]}" -gt 0 ] || exit 0

cat >&2 <<EOF
check-changelog: content is staged and $CHANGELOG is not.

Staged under a content prefix (${CONTENT_PREFIXES[*]}):

$(printf '  %s\n' "${touched[@]}")

Every one of those changes something a reader of the changelog would expect to
find named there. Write the entry now, while you still remember why the change
was made — reconstructed later from a diff, it describes what changed and not
what it fixes.

  git add $CHANGELOG

A change genuinely not worth an entry — a typo in a comment, a whitespace
fix — is the case this gate cannot tell apart: git commit --no-verify
EOF
exit 1
