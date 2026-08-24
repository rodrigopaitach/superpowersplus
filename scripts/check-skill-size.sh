#!/usr/bin/env bash
#
# check-skill-size.sh — every SKILL.md stays under the 500-line ceiling.
#
# The number is not this project's invention. "Keep SKILL.md body under 500
# lines for optimal performance" is Anthropic's own guidance, vendored in this
# repository at skills/writing-skills/anthropic-best-practices.md, section
# "Token budgets", and repeated there under "Before sharing a Skill, verify"
# as a checklist item — a checkbox with nothing behind it. What this script
# adds is the running of it.
#
# Anchored by SECTION, never by line. That file is vendored and this project
# edits it: removing six table-of-contents entries shifted every line below
# them by six, and the two line citations that used to stand here pointed at
# "Avoid vague descriptions like these:" and at a bare fence marker. Neither
# had ever named the limit. Nothing caught it because check-links.sh reads
# README-family, docs/**/*.md and skills/**/*.md — never a .sh comment.
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

# Exempt while that file's structural review is open — a deadline, not a
# condition. The entry used to say the length was not this fork's to change
# because the file was the upstream's; that stopped meaning anything when this
# project stopped pulling from them, and a rule standing on a dead reason is
# still obeyed, which is worse than one that is simply wrong. The review's
# dossier is in CLAUDE.md's changelog under Open gaps. Remove this entry when
# the review closes — never to make a red go away.
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
skills/writing-skills/anthropic-best-practices.md, section "Token budgets",
puts the limit at ${MAX}.

The fix is progressive disclosure, not compression: move what a run does not
need until it needs it into references/, and leave the trigger that sends the
reader there. A pointer nobody is told to follow is a deletion.

To commit anyway (you own the consequence): git commit --no-verify
EOF
exit 1
