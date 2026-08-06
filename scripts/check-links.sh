#!/usr/bin/env bash
#
# check-links.sh — every local markdown link points at something that exists.
#
# Covers the repository's outward-facing documents, everything in docs/, and
# every markdown file under skills/. check-docs-sync.sh only ever looked at the
# two bilingual READMEs; the other five files in docs/ had no gate at all, and
# a broken link in a showcase README is invisible until somebody clicks it.
#
# skills/ was left out while the fear was rebase churn — upstream text whose
# relative links move when their side changes. Measured instead of assumed:
# the 21 markdown links under skills/ all resolve, upstream's included, so the
# scan covers them and no design to tell a fork-owned link from an upstream one
# was needed. A link upstream wrote and broke is broken for this project's
# users exactly like one written here.
#
# What stays uncovered is the OTHER convention: a path in backticks, in prose.
# Also measured, and the reason is not cost — 78 of those exist under skills/
# and 34 resolve to nothing, none of which is a defect. They are placeholders
# (`<workspace>/progress.md`), artifact paths inside the partner's own project
# (`docs/superpowers/specs/…`), self-references (`SKILL.md` meaning this one),
# and upstream's illustrative examples. A gate there reports 34 non-problems on
# every commit.
#
# An http/https link is never FETCHED. Checking one means a network call per
# link on every push: it turns a deterministic gate into one that fails when a
# third-party site is slow, rate-limits CI, or is briefly down. A gate that
# goes red for reasons unrelated to the commit gets ignored, and then it
# guards nothing. A dead allowed link is still found by clicking it.
#
# Its DOMAIN is checked, which costs no network at all — that is the link diet
# below, and it is a different question from whether the link resolves.
#
# Usage:
#   check-links.sh    Exit 1 if a local link or anchor does not resolve, or if
#                     a URL names a host outside the link diet
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
TARGETS += sorted(str(p) for p in pathlib.Path("skills").rglob("*.md"))

FENCE = re.compile(r"^\s*(```|~~~)")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")

# The stable-anchor form: `path/file.md`, section "Exact Heading". A heading
# moves only when somebody renames it — rare, and loud in a diff — while a line
# number moves every time a paragraph is inserted above it. Three of the four
# review-face anchors and five of the measurement queue's were pointing at the
# wrong line when this was written, three of those five broken by the very
# session that wrote them.
# Matched against the whole file, never line by line: an editor wrapping a
# reference across two lines would otherwise stop it matching, the gate would
# go quiet, and the author would see a pass — silence reading as coverage,
# which is the failure this repository exists to separate. The path cannot
# contain a newline; the section title can, and is normalized before lookup.
#
# TWO forms are matched, and the reason is the bug that produced this line.
# The canonical form is the markdown link plus the section title — it obeys
# both of CLAUDE.md's rules at once (a pointer to a file of this repository is
# a link; a file edited every release is anchored by section) and it earns
# double coverage, the path from the link pass and the heading from here.
# But matching ONLY the canonical form would leave the gate blind to the older
# backtick form exactly as it was blind to the canonical one, which is how a
# reference to a deleted section passed green. Both are verified; neither is
# policed. Writing the canonical one is a rule for authors, not for this gate.
#
# Do not instantiate an example path inside a scanned file — `path/file.md`
# written to demonstrate the form is charged like a real reference. Point at
# one that exists instead. This already failed a commit once; the changelog
# entry for `1.8.2` records it.
SECTION_REF = re.compile(
    r'(?:`([^`\n]+\.md)`|\[[^\]]*\]\(([^)\s]+\.md)\)),\s*section\s+"([^"]+)"')
SECTION_HEADING = re.compile(r"^\s*(#{1,6})\s+(.*?)\s*#*\s*$")


def section_sources():
    """Every live markdown file — the text a reader is told to obey today.

    Dated records are out: the frozen history and the RESULT-*.md records
    each state what was true on their date, a heading renamed afterwards does
    not make them wrong, and a gate red on one would force rewriting a record
    to stay green. Fixtures stay in — a fixture is an input that must still
    name something real, and a red there says the recorded run's premise moved.

    The skip set is what drops the frozen history, which lives under docs/ and
    is therefore collected first. CHANGELOG.md is not in these roots at all;
    its entry there guards a root nobody has added, so no test can tell whether
    it is doing anything.

    Symlinks are out — AGENTS.md points at CLAUDE.md, and scanning both
    reports every problem twice.
    """
    found = [pathlib.Path("CLAUDE.md")]
    for base in ("docs", "skills", "tests"):
        found += sorted(pathlib.Path(base).rglob("*.md"))
    skip = {"CHANGELOG.md", "PLUS-CHANGELOG-historico.md"}
    return [p for p in found
            if p.is_file() and not p.is_symlink()
            and p.name not in skip
            and not p.name.startswith("RESULT-")]


SECTION_TARGETS = section_sources()
LINK = re.compile(r"(?<!\!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
EXTERNAL = re.compile(r"^(https?:|mailto:|tel:|ftp:)", re.IGNORECASE)

# --- The third-party link diet ---------------------------------------------
# Policy: one link to obra/superpowers per document where the attribution
# appears, this repository's own infrastructure, and nothing else. Anything a
# reader might want to look up is named in text instead — a name and a version
# identify a source without depending on somebody else's URL scheme.
#
# The diet is what makes not fetching links cheap: there is little left to rot.
URL = re.compile(r"https?://[^\s)\]\"'<>`]+")
ALLOWED_PREFIXES = (
    "https://github.com/rodrigopaitach/",
    "https://raw.githubusercontent.com/rodrigopaitach/",   # this repo's raw files
    "https://img.shields.io/",                             # this repo's badges
    "https://github.com/obra/superpowers",                 # attribution only
)

# Unlike the local-link pass, this reads RAW lines — fenced blocks included.
# An install command inside a ```block``` is exactly where a URL naming the
# wrong repository hides, and that is the defect this gate exists to catch.
#
# The frozen history is exempt from the DIET ONLY. It cannot acquire a new
# link by construction: check-frozen-history.sh refuses any change to it, so
# watching it for new domains is a check with no function. Its local links and
# anchors stay checked below — freezing a file does not freeze the files it
# points at, and a moved destination breaks it exactly like any other.
#
# Everything under skills/ is exempt from the DIET too, and for a reason the
# frozen history does not share: a skill legitimately cites vendor
# documentation. All 40 URLs under skills/ are off-diet — 11 to
# platform.claude.com in upstream's vendored best-practices, 3 to
# docs.stripe.com inside this fork's own worked example of a citation comment,
# and the rest the same shape. The diet is a policy about the seven documents
# this project owns and hands to a reader; a skill body pointing at the vendor
# doc that grounds a call is the citation rule working, not a leak.
DIET_EXEMPT = {"docs/PLUS-CHANGELOG-historico.md"}
DIET_EXEMPT |= {str(p) for p in pathlib.Path("skills").rglob("*.md")}


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


def section_slugs(path):
    """Every heading the file offers, indented ones included.

    Deliberately NOT anchors_of(): that one answers "what can a GitHub anchor
    link reach", so it needs '#' in column 1 and blanks fenced blocks. A prompt
    template is one fenced block from top to bottom and its headings are
    indented inside it — `task-reviewer-prompt.md` exposes 1 heading of its 10
    to those rules. Those are exactly the sections CLAUDE.md has to cite.

    The looseness is one-directional and declared: a `# comment` inside a shell
    block would count as a heading here, so this check can accept a section
    that is not one. It can never reject a section that exists, which is the
    failure that matters — the anchors it replaces were wrong three times.
    """
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return None
    found = set()
    for line in text.splitlines():
        match = SECTION_HEADING.match(line)
        if match:
            base = slug(match.group(2))
            if base:
                found.add(base)
    return found


def resolve_section_path(raw_path, source=None):
    """The changelog gate's cascade: relative to the citing file, then as
    written, then under skills/, then any tracked path ending with it. Several
    matches is an ambiguity to skip, not a claim to charge — same reasoning as
    check-changelog.sh.

    Relative-to-the-source comes first because that is what a markdown link
    means, and it is what the five references in
    finishing-a-development-branch/SKILL.md use: `../executing-plans/SKILL.md`
    resolves from that file, never from the repository root."""
    if source is not None:
        near = (source.parent / raw_path).resolve()
        if near.is_file() and ROOT in near.parents:
            return [near.relative_to(ROOT)]
    direct = pathlib.Path(raw_path)
    if direct.is_file():
        return [direct]
    under_skills = pathlib.Path("skills") / raw_path
    if under_skills.is_file():
        return [under_skills]
    return sorted(p for p in ROOT.rglob("*")
                  if p.is_file() and str(p).endswith("/" + raw_path))


problems = []
offdiet = []
checked = 0
scanned = 0

for name in TARGETS:
    source = pathlib.Path(name)
    if not source.is_file():
        problems.append(f"{name}: target file listed by this script does not exist")
        continue

    raw = source.read_text(encoding="utf-8")

    if name not in DIET_EXEMPT:
        for number, line in enumerate(raw.splitlines(), 1):
            for url in URL.findall(line):
                scanned += 1
                if not url.startswith(ALLOWED_PREFIXES):
                    offdiet.append(f"{name}:{number}: {url}")

    for number, line in enumerate(strip_fences(raw), 1):
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

sections = 0

for source in SECTION_TARGETS:
    name = str(source)
    text = source.read_text(encoding="utf-8")
    for match in SECTION_REF.finditer(text):
        raw_path = match.group(1) or match.group(2)
        heading = " ".join(match.group(3).split())
        number = text.count("\n", 0, match.start()) + 1
        sections += 1
        matches = resolve_section_path(raw_path, source)
        if not matches:
            problems.append(
                f"{name}:{number}: section reference names a file that does not exist: {raw_path}")
            continue
        if len(matches) > 1:
            continue
        available = section_slugs(matches[0])
        if available is None:
            problems.append(
                f"{name}:{number}: {raw_path} -> destination is not readable text")
            continue
        if slug(heading) not in available:
            problems.append(
                f'{name}:{number}: {raw_path} -> no heading matching section "{heading}"')

if problems:
    print("check-links: local links that do not resolve.", file=sys.stderr)
    print("", file=sys.stderr)
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    print("", file=sys.stderr)
    print(f"Checked {checked} local link(s) across {len(TARGETS)} file(s).", file=sys.stderr)
    print("Anchors follow GitHub's rules: lowercase, punctuation dropped,", file=sys.stderr)
    print("spaces to hyphens, accents kept.", file=sys.stderr)

if offdiet:
    print("check-links: URL(s) outside the third-party link diet.", file=sys.stderr)
    print("", file=sys.stderr)
    for entry in offdiet:
        print(f"  {entry}", file=sys.stderr)
    print("", file=sys.stderr)
    print("Policy: one link to obra/superpowers per document where the", file=sys.stderr)
    print("attribution appears, this repository's own infrastructure, and", file=sys.stderr)
    print("nothing else. Name the source in text instead — a name and a", file=sys.stderr)
    print("version identify it without depending on somebody else's URL", file=sys.stderr)
    print("scheme. Allowed prefixes:", file=sys.stderr)
    for prefix in ALLOWED_PREFIXES:
        print(f"  {prefix}", file=sys.stderr)
    print("", file=sys.stderr)
    print("A URL naming the upstream repository as an INSTALL source is not", file=sys.stderr)
    print("an allowlist gap — fix the document, do not widen the list.", file=sys.stderr)

if problems or offdiet:
    sys.exit(1)

print(f"check-links: {checked} local link(s) across {len(TARGETS)} file(s) resolve; "
      f"{scanned} URL(s) on the diet; {sections} section reference(s) resolve.")
PY
