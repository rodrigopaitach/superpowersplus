#!/usr/bin/env bash
#
# check-skill-frontmatter.sh — every SKILL.md's `name` and `description` obey
# the Agent Skills specification.
#
# The numbers and rules are not this project's invention. They are the
# constraints table and the `name` field section of the Agent Skills
# specification at agentskills.io/specification, plus two that Anthropic's own
# skill best-practices page adds and the open spec does not carry: no XML tags
# in the name, and never the reserved words `anthropic` or `claude`. Both were
# read on 2026-09-04.
#
# Why this script exists at all: for as long as nothing read the frontmatter,
# skills/writing-skills/SKILL.md — the skill that governs how every other skill
# here is written — prescribed a 1024-character limit shared between both
# fields, an example name in Title-Case, and a description rule the spec
# contradicts. Three rules wrong in the one file everything else copies from,
# none of them caught, because the only script that opened a frontmatter
# counted lines. A rule with no reader is invisible until it fails.
#
# What this script does NOT check, deliberately: whether the description says
# what the skill does as well as when to use it. That property is real and the
# spec states it, but no regex distinguishes a description that names its
# outcome from one that repeats its trigger — searching for "Use when" would
# rebuild the very rule this cycle had to correct. It belongs to
# skills/writing-skills and to the behaviour records in tests/skill-behavior/,
# not here. A gate that guesses at meaning certifies noise.
#
# One deliberate narrowing: the spec says "unicode lowercase alphanumeric", and
# the pattern below is ASCII. Every name in this repository is ASCII, so the
# gate is very slightly stricter than the spec. Widening it would need a case
# that exists.
#
# Reads the working tree, like check-skill-size.sh and check-links.sh: a
# frontmatter is wrong because of its own content.
#
# Usage:
#   check-skill-frontmatter.sh    Exit 1 if any SKILL.md frontmatter is invalid
#
set -euo pipefail

NAME_MAX=64
DESC_MAX=1024
RESERVED=(anthropic claude)

# Resolved from this script's own location, never from the working directory:
# the answer is a fact about THIS checkout's skills, so it must not depend on
# where the script was invoked from. check-skill-size.sh resolves the same way.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

problems=""
note() { problems="${problems}  ${1}"$'\n'; }

# field <file> <key> — the value of a frontmatter key, or the empty string.
# Reads only between the opening `---` and the closing one, so a line in the
# body that happens to start with `name:` is not mistaken for the frontmatter's.
field() {
    awk -v key="$2" '
        NR == 1 && $0 != "---" { exit }
        NR == 1 { next }
        $0 == "---" { exit }
        index($0, key ": ") == 1 { print substr($0, length(key) + 3); exit }
        $0 == key ":" { print ""; exit }
    ' "$1"
}

for skill in skills/*/SKILL.md; do
    # No skills directory: the glob stays literal and names nothing.
    [ -f "$skill" ] || continue
    dir="$(basename "$(dirname "$skill")")"

    if [ "$(head -n 1 "$skill")" != "---" ]; then
        note "$skill: no YAML frontmatter — the first line must be ---"
        continue
    fi

    name="$(field "$skill" name)"
    desc="$(field "$skill" description)"

    if [ -z "$name" ]; then
        note "$skill: no \`name\` field, which the spec requires"
    else
        if [ "${#name}" -gt "$NAME_MAX" ]; then
            note "$skill: name is ${#name} characters, over the ${NAME_MAX} the spec allows"
        fi
        if ! [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
            note "$skill: name \`$name\` — lowercase letters, numbers and single interior hyphens only"
        fi
        if [ "$name" != "$dir" ]; then
            note "$skill: name \`$name\` does not equal its directory \`$dir\`, which the spec requires"
        fi
        for word in "${RESERVED[@]}"; do
            case "$name" in
                *"$word"*) note "$skill: name \`$name\` contains the reserved word \`$word\`" ;;
            esac
        done
    fi

    if [ -z "$desc" ]; then
        note "$skill: no \`description\` field, or it is empty — the spec requires a non-empty one"
    elif [ "${#desc}" -gt "$DESC_MAX" ]; then
        note "$skill: description is ${#desc} characters, over the ${DESC_MAX} the spec allows"
    fi
done

if [ -z "$problems" ]; then
    exit 0
fi

cat >&2 <<EOF
check-skill-frontmatter: a SKILL.md frontmatter does not match the spec.

${problems}
The constraints are the Agent Skills specification's, not this project's:
\`name\` is at most ${NAME_MAX} characters of lowercase letters, numbers and
hyphens, with no leading, trailing or consecutive hyphen, and it must equal the
skill's directory name; \`description\` is non-empty and at most ${DESC_MAX}
characters. The two reserved words come from Anthropic's skill best-practices
page. The limits are per field — they are not shared.

A name that does not match its directory, or a field over its limit, is not
rejected loudly by every harness. It is the kind of thing that loads wrong
somewhere else, later, with nothing pointing back here.

To commit anyway (you own the consequence): git commit --no-verify
EOF
exit 1
