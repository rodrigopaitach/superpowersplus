#!/usr/bin/env bash
#
# check-skill-size.sh — every SKILL.md stays under the 500-line ceiling.
#
# The number is not this project's invention. "Keep SKILL.md body under 500
# lines for optimal performance" is Anthropic's own guidance, vendored in this
# repository at skills/writing-skills/anthropic-best-practices.md:241 and
# repeated there as a checklist item at :1109 — a checkbox with nothing behind
# it. What this script adds is the running of it.
#
# It counts the whole file, frontmatter included, which is roughly five lines
# stricter than the rule as written. A file that fails by five lines is not the
# failure this guards against, and the exact accounting is not worth a second
# way to measure a file.
#
# It reads the working tree rather than the index, like check-links.sh: a
# SKILL.md crosses the ceiling because of its own content, so there is no
# equivalent of a link whose destination disappears in a commit that does not
# touch it.
#
# Usage:
#   check-skill-size.sh    Exit 1 if any non-exempt SKILL.md exceeds MAX
#
set -euo pipefail

MAX=500

# Files whose length is not this fork's to change. skills/writing-skills is 679
# lines here and 679 upstream: the only two lines this fork changed there are
# the namespace rename, and neither added any. Cutting it means rewriting a
# file the upstream maintains — which CLAUDE.md forbids — for a gain that
# belongs in somebody else's repository. Remove the entry the day this project
# starts owning that file's content.
EXEMPT=(skills/writing-skills/SKILL.md)

# Resolved from this script's own location, not from the working directory or
# `git rev-parse`: the ceiling and the exemption below are facts about THIS
# checkout's skills, so the answer must not depend on where it was invoked
# from. check-links.sh resolves its root the same way.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

over=""
for skill in skills/*/SKILL.md; do
    # No skills directory: the glob stays literal and names nothing.
    [ -f "$skill" ] || continue
    for exempt in "${EXEMPT[@]}"; do
        if [ "$skill" = "$exempt" ]; then continue 2; fi
    done
    lines="$(wc -l < "$skill")"
    if [ "$lines" -gt "$MAX" ]; then
        over="${over}  ${lines} lines  ${skill}"$'\n'
    fi
done

if [ -z "$over" ]; then
    exit 0
fi

cat >&2 <<EOF
check-skill-size: a SKILL.md is over the ${MAX}-line ceiling.

${over}
A SKILL.md is loaded whole, every time the skill fires. Past this length the
instructions at the bottom stop being followed reliably — which is why
Anthropic's own guidance, vendored here at
skills/writing-skills/anthropic-best-practices.md:241, puts the limit at ${MAX}.

The fix is progressive disclosure, not compression: move what a run does not
need until it needs it into references/, and leave the trigger that sends the
reader there. A pointer nobody is told to follow is a deletion.

To commit anyway (you own the consequence): git commit --no-verify
EOF
exit 1
