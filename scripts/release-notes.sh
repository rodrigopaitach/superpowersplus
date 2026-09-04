#!/usr/bin/env bash
#
# release-notes.sh — build a GitHub release body from CHANGELOG.md.
#
# The body is the version's own section, then the Open gaps section, then a
# footer. Open gaps is included on purpose: someone reading a release needs to
# see what is still open without clicking through to the changelog.
#
# A file is written only after the body is known to be non-empty, and that is
# not a style preference. On 2026-08-06 this script died on a version section
# that was empty; the `>` redirect had already truncated its target to zero
# bytes, and `gh release create --notes-file` published the empty file without
# complaining. The two commands were not chained, so nothing caught it. The
# guard belongs here because the redirect happens before the script runs — no
# rule written anywhere else can undo a truncation that already happened.
#
# Usage:
#   release-notes.sh 1.1.0            Print the body to stdout
#   release-notes.sh 1.1.0 body.md    Write it to body.md, only if non-empty
#
set -euo pipefail

VERSION="${1:?usage: release-notes.sh <version> [output-file]}"
OUTPUT="${2:-}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHANGELOG="$REPO_ROOT/CHANGELOG.md"

[ -f "$CHANGELOG" ] || { echo "error: $CHANGELOG not found" >&2; exit 1; }

body="$(python3 - "$CHANGELOG" "$VERSION" <<'PY'
import re
import sys

changelog, version = sys.argv[1], sys.argv[2]
text = open(changelog, encoding="utf-8").read()


# A section ends at the next `## ` heading OR at the link-reference footer.
# Two boundaries, not one, and knowing only the first is what this fixes:
# `## Open gaps` is the last `## ` in the changelog, so its slice fell through
# to end-of-file and carried the whole footer into every release body ever
# generated. Measured on 2026-09-03: 50 `[1.x.x]: …` lines in the body for
# 1.23.0. The footer is the only place these lines appear — every other link
# in the changelog is inline. The second alternative is line-anchored, so prose
# could in principle trip it: a markdown footnote definition, or a wrapped line
# starting `[the gate]: it was...`. Measured on the whole changelog the day this
# was written: zero such lines outside the footer, zero inside code fences.
# Its twin is FOOTER_START in scripts/check-links.sh, which slices the same
# section. Change one, look at the other.
SECTION_END = re.compile(r"^(?:## |\[[^\]]+\]: )", re.M)


def section(heading):
    """Body of a level-2 section, heading line excluded."""
    start = text.find(heading)
    if start == -1:
        raise SystemExit(f"error: section {heading!r} not found in the changelog")
    end = SECTION_END.search(text, start + len(heading))
    block = text[start:end.start() if end else len(text)].strip()
    parts = block.split("\n", 1)
    # A heading with nothing under it. Named, rather than left to fall through
    # to the IndexError it raised the first time — which read like a defect in
    # this script instead of an empty section in the changelog.
    if len(parts) < 2 or not parts[1].strip():
        raise SystemExit(f"error: section {heading!r} is empty in the changelog")
    return parts[1].strip()


marker = f"## [{version}] -"
print(section(marker))
print()
print("## Open gaps")
print()
print(section("\n## Open gaps"))
print(f"""
---

**Based on [Superpowers](https://github.com/obra/superpowers)**, by Jesse Vincent (Prime Radiant), under the MIT license. superpowersplus is a derivative work.

Full changelog: [CHANGELOG.md](https://github.com/rodrigopaitach/superpowersplus/blob/v{version}/CHANGELOG.md). The 34 `plus.N` entries that led to 1.0.0 are preserved in [docs/PLUS-CHANGELOG-historico.md](https://github.com/rodrigopaitach/superpowersplus/blob/v{version}/docs/PLUS-CHANGELOG-historico.md) (in Portuguese).

**Install:**
```
/plugin marketplace add rodrigopaitach/superpowersplus
/plugin install superpowersplus@superpowersplus
```

**Upgrading:** `/plugin marketplace update superpowersplus` then `/reload-plugins`.""")
PY
)"

# The body is in hand before anything is written, so an empty one never reaches
# a file and never reaches `gh release create --notes-file` through one.
if [ -z "${body//[[:space:]]/}" ]; then
    echo "release-notes: refusing to emit an empty body for $VERSION" >&2
    exit 1
fi

if [ -n "$OUTPUT" ]; then
    printf '%s\n' "$body" > "$OUTPUT"
    echo "release-notes: wrote $(wc -c < "$OUTPUT") bytes to $OUTPUT" >&2
else
    printf '%s\n' "$body"
fi
