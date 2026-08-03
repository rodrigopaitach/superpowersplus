#!/usr/bin/env bash
#
# check-links.sh — every local markdown link points at something that exists.
#
# Covers the repository's outward-facing documents plus everything in docs/.
# check-docs-sync.sh only ever looked at the two bilingual READMEs; the other
# five files in docs/ had no gate at all, and a broken link in a showcase
# README is invisible until somebody clicks it.
#
# http/https links are IGNORED on purpose. Checking them means a network call
# per link on every push: it turns a deterministic gate into one that fails
# when a third-party site is slow, rate-limits CI, or is briefly down. A gate
# that goes red for reasons unrelated to the commit gets ignored, and then it
# guards nothing. Local links are the ones this repository can actually break.
#
# Usage:
#   check-links.sh    Exit 1 if any local link or anchor does not resolve
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$REPO_ROOT"

python3 - <<'PY'
import pathlib
import re
import sys

ROOT = pathlib.Path(".").resolve()

TARGETS = ["README.md", "CONTRIBUTING.md", "SECURITY.md",
           "CODE_OF_CONDUCT.md", "CHANGELOG.md"]
TARGETS += sorted(str(p) for p in pathlib.Path("docs").glob("*.md"))

FENCE = re.compile(r"^\s*(```|~~~)")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
LINK = re.compile(r"(?<!\!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
EXTERNAL = re.compile(r"^(https?:|mailto:|tel:|ftp:)", re.IGNORECASE)


def strip_fences(text):
    """Blank out fenced code blocks, keeping line numbers intact.

    A bash comment inside a ```block``` looks exactly like a heading, and a
    sample command containing brackets looks exactly like a link.
    """
    out, in_fence = [], False
    for line in text.splitlines():
        if FENCE.match(line):
            in_fence = not in_fence
            out.append("")
            continue
        out.append("" if in_fence else line)
    return out


def slug(text):
    """GitHub's heading anchor, as github-slugger builds it.

    Inline markdown comes off first, then everything that is not a letter,
    digit, space, hyphen or underscore is dropped, then spaces become hyphens.
    Accents survive (`Instalação` -> `instalação`); emoji and em dashes do not,
    and an em dash surrounded by spaces therefore leaves TWO hyphens behind.
    """
    text = re.sub(r"`([^`]*)`", r"\1", text)
    text = re.sub(r"\*\*([^*]*)\*\*", r"\1", text)
    text = re.sub(r"\*([^*]*)\*", r"\1", text)
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = text.strip().lower()
    kept = [c for c in text if c.isalnum() or c in " -_"]
    return "".join(kept).replace(" ", "-")


def anchors_of(path):
    """Every anchor the file offers, with GitHub's -1/-2 duplicate suffixes."""
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return None
    found, seen = set(), {}
    for line in strip_fences(text):
        match = HEADING.match(line)
        if not match:
            continue
        base = slug(match.group(2))
        if not base:
            continue
        count = seen.get(base, 0)
        seen[base] = count + 1
        found.add(base if count == 0 else f"{base}-{count}")
    return found


anchor_cache = {}


def anchors_cached(path):
    key = str(path)
    if key not in anchor_cache:
        anchor_cache[key] = anchors_of(path)
    return anchor_cache[key]


problems = []
checked = 0

for name in TARGETS:
    source = pathlib.Path(name)
    if not source.is_file():
        problems.append(f"{name}: target file listed by this script does not exist")
        continue

    for number, line in enumerate(strip_fences(source.read_text(encoding="utf-8")), 1):
        for target in LINK.findall(line):
            if EXTERNAL.match(target):
                continue
            checked += 1

            path_part, _, anchor = target.partition("#")

            if path_part:
                destination = (source.parent / path_part).resolve()
                try:
                    destination.relative_to(ROOT)
                except ValueError:
                    problems.append(f"{name}:{number}: {target} -> escapes the repository")
                    continue
                if not destination.exists():
                    problems.append(f"{name}:{number}: {target} -> no such file")
                    continue
            else:
                destination = source.resolve()

            if not anchor:
                continue
            if destination.is_dir() or destination.suffix.lower() != ".md":
                continue

            available = anchors_cached(destination)
            if available is None:
                problems.append(f"{name}:{number}: {target} -> destination is not readable text")
                continue
            if anchor.lower() not in available:
                problems.append(f"{name}:{number}: {target} -> no heading with anchor '{anchor}'")

if problems:
    print("check-links: local links that do not resolve.", file=sys.stderr)
    print("", file=sys.stderr)
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    print("", file=sys.stderr)
    print(f"Checked {checked} local link(s) across {len(TARGETS)} file(s).", file=sys.stderr)
    print("Anchors follow GitHub's rules: lowercase, punctuation dropped,", file=sys.stderr)
    print("spaces to hyphens, accents kept.", file=sys.stderr)
    sys.exit(1)

print(f"check-links: {checked} local link(s) across {len(TARGETS)} file(s) resolve.")
PY
