#!/usr/bin/env bash
#
# release-notes.sh — build a GitHub release body from CHANGELOG.md.
#
# The body is the version's own section, then the Open gaps section, then a
# footer. Open gaps is included on purpose: someone reading a release needs to
# see what is still open without clicking through to the changelog.
#
# Usage:
#   release-notes.sh 1.1.0            Print the body to stdout
#
set -euo pipefail

VERSION="${1:?usage: release-notes.sh <version>}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHANGELOG="$REPO_ROOT/CHANGELOG.md"

[ -f "$CHANGELOG" ] || { echo "error: $CHANGELOG not found" >&2; exit 1; }

python3 - "$CHANGELOG" "$VERSION" <<'PY'
import sys

changelog, version = sys.argv[1], sys.argv[2]
text = open(changelog, encoding="utf-8").read()


def section(heading):
    """Body of a level-2 section, heading line excluded."""
    start = text.find(heading)
    if start == -1:
        raise SystemExit(f"error: section {heading!r} not found in the changelog")
    end = text.find("\n## ", start + len(heading))
    block = text[start:end if end != -1 else len(text)].strip()
    return block.split("\n", 1)[1].strip()


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
