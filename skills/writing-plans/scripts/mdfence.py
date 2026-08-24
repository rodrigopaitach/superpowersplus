"""CommonMark fenced-code detection, shared by this repository's markdown gates.

Three carriers read markdown structurally. Two of them used a toggle that flips
on any three-backtick line, which is wrong whenever a three-backtick block sits
inside a four-backtick one: the inner opener closes the outer block and its
content reads as real structure. Measured 2026-08-24 across `docs/` and
`skills/`, that toggle and the rule below disagree about 77 structural headings
in 6 documents.

This module lives beside `check-cross-references` rather than under the
repository's root `scripts/` because `scripts/package-codex-plugin.sh:336` fails
the Codex build on any archived path beginning `scripts/`, while `:241` stages
`skills` wholesale — a module at the root would ship to one harness and not the
other, and the import would fail at runtime for Codex users.

Known deviations from CommonMark, each measured against the 131 versioned `.md`
files of this repository. Two are latent at zero occurrences; the third is not,
and reads as prose in six real places:

* A backtick opener whose info string itself contains a backtick is accepted
  here; CommonMark makes it a paragraph. 0 occurrences.
* Indented code blocks (four spaces, no fence) are not modelled at all — this
  scanner answers "is this line inside a FENCED block", which is the question
  the three carriers ask.
* A fence inside a block quote (`> ```) is not modelled: the `>` prefix means
  the opener does not match, so the block reads as prose. 6 occurrences —
  README.md:75,77, docs/README.en.md:54,56 and docs/README.pt-BR.md:54,56 —
  each a single command line carrying no heading, no table row and no link, so
  nothing any carrier extracts sits inside one. A block-quoted fence that ever
  carries structure would be read as structure, and that is the exposure.
"""

import re

# CommonMark: an opener is three or more backticks or tildes, indented at most
# three spaces, optionally followed by an info string.
_FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})[ \t]*(.*)$")


def fence_mask(lines):
    """(mask, unclosed) for a list of lines.

    mask[i] is True when lines[i] is inside a fenced block OR is a fence marker
    itself — a marker is not structure either, so no caller ever wants it.
    unclosed is the 1-based line a fence opened on and never closed, else None.
    """
    mask = []
    opener = None
    opened_at = None
    for number, line in enumerate(lines, 1):
        match = _FENCE.match(line)
        if match:
            token, info = match.group(1), match.group(2).strip()
            if opener is None:
                opener, opened_at = token, number
            elif token[0] == opener[0] and len(token) >= len(opener) and not info:
                # A closer matches the opener's character, is at least as long,
                # and carries no info string. Anything else is content.
                opener, opened_at = None, None
            mask.append(True)
            continue
        mask.append(opener is not None)
    return mask, opened_at


def prose(lines):
    """`lines` with every fenced line blanked, so line numbers still line up."""
    mask, _ = fence_mask(lines)
    return ["" if mask[index] else line for index, line in enumerate(lines)]
