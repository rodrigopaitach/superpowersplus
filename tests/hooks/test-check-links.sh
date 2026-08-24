#!/usr/bin/env bash
#
# Tests for scripts/check-links.sh.
#
# The script resolves its own repository root from its location, so each case
# copies it into a throwaway tree and builds the target files there. That
# exercises the real script — including its hardcoded list of target files —
# rather than a parameterized variant that only exists for tests.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/check-links.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() {
    echo "  [PASS] $1"
}

fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

# new_tree — throwaway repository with the script installed and every target
# file present but empty. Echoes its path.
new_tree() {
    local tree
    tree="$(mktemp -d "$TEST_ROOT/tree.XXXXXX")"
    mkdir -p "$tree/scripts" "$tree/docs" "$tree/skills/writing-plans/scripts"
    cp "$SCRIPT_UNDER_TEST" "$tree/scripts/check-links.sh"
    # The gate imports the shared fence scanner by a path relative to its own
    # root, so a fixture tree that carries the script without the module is a
    # tree the real gate could never run in.
    cp "$REPO_ROOT/skills/writing-plans/scripts/mdfence.py" \
        "$tree/skills/writing-plans/scripts/mdfence.py"
    local target
    for target in README.md CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md CHANGELOG.md CLAUDE.md; do
        : > "$tree/$target"
    done
    # CHANGELOG.md is the one target that cannot be empty: the section pass
    # slices `## Open gaps` out of it and raises when that heading is absent,
    # rather than yielding an empty slice that would report zero problems and
    # read like a clean pass. A tree without the heading is not a smaller
    # repository, it is a malformed one.
    printf '# Changelog\n\n## [1.0.0] - 2026-01-01\n\n- an entry.\n\n## Open gaps\n\n- none.\n' \
        > "$tree/CHANGELOG.md"
    printf '%s\n' "$tree"
}

# assert_run <expected exit> <description> <tree> [needle in output]
assert_run() {
    local expected="$1" description="$2" tree="$3" needle="${4:-}"
    local actual output
    output="$("$tree/scripts/check-links.sh" 2>&1)" && actual=0 || actual=$?

    if [ "$actual" -ne "$expected" ]; then
        fail "$description"
        echo "    expected exit $expected, got $actual"
        printf '%s\n' "$output" | sed 's/^/      /'
        return
    fi
    if [ -n "$needle" ] && ! printf '%s' "$output" | grep -Fq -- "$needle"; then
        fail "$description"
        echo "    output did not mention '$needle'"
        printf '%s\n' "$output" | sed 's/^/      /'
        return
    fi
    pass "$description"
}

echo "Test: a link that resolves, and one that does not"
T="$(new_tree)"
printf '# Doc\n\nSee [the guide](docs/guide.md).\n' > "$T/README.md"
printf '# Guide\n' > "$T/docs/guide.md"
assert_run 0 "existing file passes" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [the guide](docs/missing.md).\n' > "$T/README.md"
assert_run 1 "missing file fails" "$T" "no such file"

echo "Test: anchors"
T="$(new_tree)"
printf '# Doc\n\nSee [gaps](CHANGELOG.md#open-gaps).\n' > "$T/README.md"
printf '# Changelog\n\n## Open gaps\n' > "$T/CHANGELOG.md"
assert_run 0 "existing anchor passes" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [gaps](CHANGELOG.md#closed-gaps).\n' > "$T/README.md"
printf '# Changelog\n\n## Open gaps\n' > "$T/CHANGELOG.md"
assert_run 1 "missing anchor fails" "$T" "no heading with anchor"

T="$(new_tree)"
printf '# Doc\n\nJump to [gaps](#open-gaps).\n\n## Open gaps\n' > "$T/README.md"
assert_run 0 "same-file anchor passes" "$T"

echo "Test: GitHub slug rules on the shapes this repo actually has"
T="$(new_tree)"
printf '# Doc\n\nVeja [pendências](docs/hist.md#pendências-conhecidas).\n' > "$T/README.md"
printf '# Hist\n\n## Pendências conhecidas\n' > "$T/docs/hist.md"
assert_run 0 "accented anchor passes (accents are kept)" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [part one](docs/port.md#part-1--how-it-works).\n' > "$T/README.md"
printf '# Port\n\n## Part 1 — How it works\n' > "$T/docs/port.md"
assert_run 0 "em dash leaves two hyphens" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [docs](docs/emo.md#documentation).\n' > "$T/README.md"
printf '# Emo\n\n## 📖 Documentation\n' > "$T/docs/emo.md"
assert_run 1 "emoji leaves the leading hyphen it strips to" "$T" "no heading with anchor"

T="$(new_tree)"
printf '# Doc\n\nSee [docs](docs/emo.md#-documentation).\n' > "$T/README.md"
printf '# Emo\n\n## 📖 Documentation\n' > "$T/docs/emo.md"
assert_run 0 "the emoji heading answers to its real slug" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [code](docs/c.md#the-scripts-shape).\n' > "$T/README.md"
printf '# C\n\n## The `scripts/` shape\n' > "$T/docs/c.md"
assert_run 0 "backticks and slashes come out of the slug" "$T"

T="$(new_tree)"
printf '# Doc\n\nSee [second](docs/d.md#added-1).\n' > "$T/README.md"
printf '# D\n\n## Added\n\ntext\n\n## Added\n' > "$T/docs/d.md"
assert_run 0 "duplicate headings get GitHub's -1 suffix" "$T"

echo "Test: what is deliberately not checked"
T="$(new_tree)"
printf '# Doc\n\n[latest](https://github.com/rodrigopaitach/superpowersplus/releases/latest).\n' > "$T/README.md"
assert_run 0 "an allowed http(s) link is never fetched, only its domain read" "$T"

echo "Test: the third-party link diet"
T="$(new_tree)"
printf '# Doc\n\nSee [the tracker](https://example.invalid/nope).\n' > "$T/README.md"
assert_run 1 "a URL outside the allowlist fails" "$T" "outside the third-party link diet"

T="$(new_tree)"
printf '# Doc\n\nSee [the tracker](https://example.invalid/nope).\n' > "$T/README.md"
assert_run 1 "the failure names the policy, not just the URL" "$T" "do not widen the list"

T="$(new_tree)"
printf '# Doc\n\n[Superpowers](https://github.com/obra/superpowers) by Jesse Vincent.\n' > "$T/README.md"
assert_run 0 "the attribution link to the upstream is allowed" "$T"

T="$(new_tree)"
printf '# Doc\n\n![CI](https://img.shields.io/github/license/x?style=flat-square)\n' > "$T/README.md"
assert_run 0 "a badge from img.shields.io is allowed" "$T"

T="$(new_tree)"
printf '# Doc\n\nFetch https://raw.githubusercontent.com/rodrigopaitach/superpowersplus/refs/heads/main/x.md\n' > "$T/README.md"
assert_run 0 "raw.githubusercontent for this owner is this repo's own infrastructure" "$T"

# The defect this gate exists to catch: an install command naming the wrong
# repository. It lives inside a fenced block, which the local-link pass blanks
# out — so the diet pass has to read raw lines or it would miss exactly this.
T="$(new_tree)"
printf '# Doc\n\n```text\n/plugins install https://github.com/obra/superpowers\n```\n' > "$T/README.md"
assert_run 0 "an upstream URL is allowed even in a fenced block (attribution prefix)" "$T"

T="$(new_tree)"
printf '# Doc\n\n```json\n{"plugin": ["x@git+https://gitlab.invalid/x.git"]}\n```\n' > "$T/README.md"
assert_run 1 "an install URL inside a fenced block is still caught" "$T" "gitlab.invalid"

T="$(new_tree)"
printf '# Doc\n\nSee http://plain.invalid/x\n' > "$T/README.md"
assert_run 1 "a bare http URL is off the diet too" "$T" "plain.invalid"

echo "Test: the frozen history is exempt from the diet only"
T="$(new_tree)"
printf '# Hist\n\nSee [Stripe](https://docs.stripe.com/api/idempotent_requests).\n' \
    > "$T/docs/PLUS-CHANGELOG-historico.md"
assert_run 0 "a third-party domain in the frozen history is exempt" "$T"

T="$(new_tree)"
printf '# Hist\n\nSee [gone](moved.md).\n' > "$T/docs/PLUS-CHANGELOG-historico.md"
assert_run 1 "a broken LOCAL link in the frozen history is still caught" "$T" "no such file"

T="$(new_tree)"
printf '# Doc\n\n```bash\n# A comment, not a heading\ncat [not](a/link.md)\n```\n' > "$T/README.md"
assert_run 0 "links inside fenced code are ignored" "$T"

T="$(new_tree)"
printf '# Doc\n\n![shot](docs/shot.png)\n' > "$T/README.md"
: > "$T/docs/shot.png"
assert_run 0 "an image that exists passes" "$T"

echo "Test: docs/ files are targets too, not just the two bilingual READMEs"
T="$(new_tree)"
printf '# Other doc\n\nSee [gone](gone.md).\n' > "$T/docs/README.kimi.md"
assert_run 1 "a broken link inside docs/ is caught" "$T" "README.kimi.md"

T="$(new_tree)"
printf '# Doc\n\nSee [outside](../../etc/passwd).\n' > "$T/README.md"
assert_run 1 "a path escaping the repository is rejected" "$T" "escapes the repository"

echo "Test: skills/ is scanned for links and exempt from the diet"

T="$(new_tree)"
mkdir -p "$T/skills/a-skill/references"
printf '# A skill\n\nSee [the reference](references/detail.md).\n' \
    > "$T/skills/a-skill/SKILL.md"
printf '# Detail\n' > "$T/skills/a-skill/references/detail.md"
assert_run 0 "a resolving link inside skills/ passes" "$T"

T="$(new_tree)"
mkdir -p "$T/skills/a-skill"
printf '# A skill\n\nSee [the reference](references/gone.md).\n' \
    > "$T/skills/a-skill/SKILL.md"
assert_run 1 "a broken link inside skills/ is caught" "$T" "skills/a-skill/SKILL.md"

# A skill citing the vendor doc that grounds a call is the citation rule
# working. The diet governs the documents this project hands to a reader, and
# a skill body is not one of them — so this must PASS while the same URL in
# README.md fails.
T="$(new_tree)"
mkdir -p "$T/skills/a-skill"
printf '# A skill\n\n<!-- https://docs.stripe.com/api -->\n' \
    > "$T/skills/a-skill/SKILL.md"
assert_run 0 "an off-diet URL inside skills/ is allowed" "$T"

T="$(new_tree)"
printf '# Doc\n\n<!-- https://docs.stripe.com/api -->\n' > "$T/README.md"
assert_run 1 "the same URL in a root document is still off-diet" \
    "$T" "outside the third-party link diet"

echo
echo "Test: CLAUDE.md is scanned by the link pass and the diet, not only sections"

# CLAUDE.md used to reach only the section pass. It is the file that writes
# "a pointer to a file of this repository is a markdown link, never backticks",
# and the pass that resolves links did not read it — so a link it wrote to a
# deleted file passed green, as did a URL naming any host at all. Each case
# below is paired with its opposite: a gate is proved by the DIFFERENCE between
# two states, never by one verdict.

T="$(new_tree)"
printf '# Rules\n\nSee [the guide](docs/guide.md).\n' > "$T/CLAUDE.md"
printf '# Guide\n' > "$T/docs/guide.md"
assert_run 0 "a link in CLAUDE.md that resolves passes" "$T"

T="$(new_tree)"
printf '# Rules\n\nSee [the guide](docs/missing.md).\n' > "$T/CLAUDE.md"
assert_run 1 "a link in CLAUDE.md that does not resolve fails" "$T" "no such file"

T="$(new_tree)"
printf '# Rules\n\nUpstream: https://github.com/obra/superpowers\n' > "$T/CLAUDE.md"
assert_run 0 "an allowed URL in CLAUDE.md passes the diet" "$T"

T="$(new_tree)"
printf '# Rules\n\nSee https://docs.stripe.com/api\n' > "$T/CLAUDE.md"
assert_run 1 "an off-diet URL in CLAUDE.md fails" \
    "$T" "outside the third-party link diet"

echo
echo "Test: section references — the stable anchor form"

T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Tests — Run Them Yourself\n\nbody\n' > "$T/skills/demo/SKILL.md"
printf 'See `skills/demo/SKILL.md`, section "Tests — Run Them Yourself".\n' > "$T/CLAUDE.md"
assert_run 0 "a section that exists passes" "$T"

T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Tests — Run Them Yourself\n' > "$T/skills/demo/SKILL.md"
printf 'See `skills/demo/SKILL.md`, section "Tests Nobody Wrote".\n' > "$T/CLAUDE.md"
assert_run 1 "a section that does not exist fails" "$T" "no heading matching section"

T="$(new_tree)"
printf 'See `skills/gone/SKILL.md`, section "Anything".\n' > "$T/CLAUDE.md"
assert_run 1 "a section reference to a missing file fails" "$T" "names a file that does not exist"

# The case this form exists for: in a prompt template the whole body is one
# fenced block and its headings are indented, so the link-anchor regex — which
# needs '#' in column 1 and blanks fenced blocks — sees none of them.
T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Template\n\n```\n  prompt: |\n    ## Tests — Run Them Yourself\n\n    body\n```\n' \
    > "$T/skills/demo/prompt.md"
printf 'See `skills/demo/prompt.md`, section "Tests — Run Them Yourself".\n' > "$T/CLAUDE.md"
assert_run 0 "an indented heading inside a fenced prompt body counts" "$T"

T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## The `--verify-tag` Guard\n' > "$T/skills/demo/SKILL.md"
printf 'See `skills/demo/SKILL.md`, section "The `--verify-tag` Guard".\n' > "$T/CLAUDE.md"
assert_run 0 "a section name carrying backticks matches after normalization" "$T"

T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Setup\n' > "$T/skills/demo/SKILL.md"
printf 'See `demo/SKILL.md`, section "Setup".\n' > "$T/CLAUDE.md"
assert_run 0 "a path relative to skills/ resolves, like the changelog gate's cascade" "$T"

T="$(new_tree)"
printf 'The rule lives at `scripts/check-docs-sync.sh:14-15`.\n' > "$T/CLAUDE.md"
assert_run 0 "a plain file:line anchor is untouched by this check" "$T"

# A reference wrapped across lines by an editor must still be checked. Reading
# line by line, it simply stops matching — the gate goes quiet and the author
# sees a pass, which is the "silence reads as coverage" failure this repository
# exists to separate.
T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Test Run\n' > "$T/skills/demo/SKILL.md"
printf 'See `skills/demo/SKILL.md`, section "Test\nRun" for the shape.\n' > "$T/CLAUDE.md"
assert_run 0 "a reference wrapped across two lines still resolves" "$T"

T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Test Run\n' > "$T/skills/demo/SKILL.md"
printf 'See `skills/demo/SKILL.md`, section "Nothing\nHere" for the shape.\n' > "$T/CLAUDE.md"
assert_run 1 "a wrapped reference to a missing section still fails" "$T" "no heading matching section"

echo
echo "Test: the canonical form — markdown link plus section title"

# The bug this whole group exists for. Obeying the pointer rule (a repository
# file is a link) and the anchor rule (a file edited every release is cited by
# section) at the same time produces this form, and for two releases the regex
# could not see it: a reference naming a section that had just been deleted
# passed green.
T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Execution Handoff\n' > "$T/skills/demo/SKILL.md"
printf 'See [SKILL.md](skills/demo/SKILL.md), section "Execution Handoff".\n' > "$T/CLAUDE.md"
assert_run 0 "the canonical link form resolves" "$T" "1 section reference(s) resolve"

T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Execution Handoff\n' > "$T/skills/demo/SKILL.md"
printf 'See [SKILL.md](skills/demo/SKILL.md), section "Section Nobody Kept".\n' > "$T/CLAUDE.md"
assert_run 1 "the canonical link form fails on a deleted section" "$T" "no heading matching section"

echo
echo "Test: the section pass reaches every live file, not just CLAUDE.md"

# SECTION_TARGETS used to be ["CLAUDE.md"]. Skills cite each other in this form
# too, and those references were read by nothing.
T="$(new_tree)"
mkdir -p "$T/skills/one" "$T/skills/two"
printf '# Two\n\n## Overview\n' > "$T/skills/two/SKILL.md"
printf '# One\n\nSee [two](../two/SKILL.md), section "Not A Heading".\n' > "$T/skills/one/SKILL.md"
assert_run 1 "a bad section reference inside skills/ is caught" "$T" "no heading matching section"

# A relative path means relative to the citing file — never to the repository
# root, which is where five real references in finishing-a-development-branch
# would have resolved to nothing.
T="$(new_tree)"
mkdir -p "$T/skills/one" "$T/skills/two"
printf '# Two\n\n## Overview\n' > "$T/skills/two/SKILL.md"
printf '# One\n\nSee [two](../two/SKILL.md), section "Overview".\n' > "$T/skills/one/SKILL.md"
assert_run 0 "a ../ path resolves from the citing file" "$T" "1 section reference(s) resolve"

# Dated records state what was true on their date. A heading renamed afterwards
# does not make one wrong, and a gate red on one would force rewriting a record
# to stay green.
T="$(new_tree)"
mkdir -p "$T/skills/demo" "$T/tests/skill-behavior"
printf '# Demo\n\n## Overview\n' > "$T/skills/demo/SKILL.md"
printf 'Ran against [demo](../../skills/demo/SKILL.md), section "Gone Since".\n' \
    > "$T/tests/skill-behavior/RESULT-something.md"
assert_run 0 "a RESULT- record is not charged for a renamed heading" "$T"

# The frozen history is the exclusion the skip set actually exercises: it lives
# under docs/, so it IS collected and then dropped. CHANGELOG.md is dropped as a
# whole file and re-enters as one section — the three cases below.
T="$(new_tree)"
mkdir -p "$T/skills/demo" "$T/docs"
printf '# Demo\n\n## Overview\n' > "$T/skills/demo/SKILL.md"
printf '# History\n\nWas [demo](../skills/demo/SKILL.md), section "Gone Since".\n' \
    > "$T/docs/PLUS-CHANGELOG-historico.md"
assert_run 0 "the frozen history is not charged for a renamed heading" "$T"

# --- CHANGELOG.md: the live section is read, the history around it is not ----
# Open gaps calls itself the live list and sits inside the file exempted for
# being history. These three cases are the whole reason the slice exists, and
# the first two must disagree — a pass on both would mean the slice boundary
# does nothing.

T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Overview\n' > "$T/skills/demo/SKILL.md"
printf '# Changelog\n\n## [1.0.0] - 2026-01-01\n\n- shipped.\n\n## Open gaps\n\nStill open: [demo](skills/demo/SKILL.md), section "Gone Since".\n' \
    > "$T/CHANGELOG.md"
assert_run 1 "a stale section reference inside Open gaps is caught" "$T" \
    'no heading matching section "Gone Since"'

T="$(new_tree)"
mkdir -p "$T/skills/demo"
printf '# Demo\n\n## Overview\n' > "$T/skills/demo/SKILL.md"
printf '# Changelog\n\n## [1.0.0] - 2026-01-01\n\nWas [demo](skills/demo/SKILL.md), section "Gone Since".\n\n## Open gaps\n\n- none.\n' \
    > "$T/CHANGELOG.md"
assert_run 0 "a dated entry above Open gaps is not charged" "$T"

# A renamed heading must raise, never yield an empty slice: an empty one
# reports zero problems and is indistinguishable from a clean pass.
T="$(new_tree)"
printf '# Changelog\n\n## [1.0.0] - 2026-01-01\n\n- shipped.\n\n## Open questions\n\n- none.\n' \
    > "$T/CHANGELOG.md"
assert_run 1 "a renamed Open gaps heading fails loudly instead of scanning nothing" "$T" \
    "has no '## Open gaps' heading"

echo
echo "Test: docs/ is walked recursively, and work records are diet-exempt"

# The local-link pass collected docs/ one level deep while collecting skills/
# recursively, so every spec and plan was read by nothing. These cases hold the
# recursion in place: without it the first assertion below exits 0, which is a
# clean pass that has checked nothing.
T="$(new_tree)"
mkdir -p "$T/docs/superpowers/specs"
printf '# Spec\n\n[gone](../../does-not-exist.md)\n' \
    > "$T/docs/superpowers/specs/2026-01-01-a-design.md"
assert_run 1 "a broken link inside docs/superpowers/specs/ is caught" "$T" \
    'does-not-exist.md'

T="$(new_tree)"
mkdir -p "$T/docs/plans"
printf '# Plan\n\n[gone](./does-not-exist.md)\n' > "$T/docs/plans/2026-01-01-a.md"
assert_run 1 "a broken link inside docs/plans/ is caught" "$T" \
    'does-not-exist.md'

T="$(new_tree)"
mkdir -p "$T/docs/windows"
printf '# Note\n\n[gone](../does-not-exist.md)\n' > "$T/docs/windows/note.md"
assert_run 1 "a broken link inside a docs/ subdirectory that is not a work record is caught" "$T" \
    'does-not-exist.md'

# The diet exemption for work records is domain-only. A plan carrying a
# loopback address in a test example must not be charged; the same plan
# carrying a broken local link must still fail. One assertion without the
# other cannot tell an exemption from a hole.
T="$(new_tree)"
mkdir -p "$T/docs/superpowers/plans"
printf '# Plan\n\n```bash\ncurl http://localhost:8080/health\n```\n' \
    > "$T/docs/superpowers/plans/2026-01-01-a.md"
assert_run 0 "a loopback address inside a plan is exempt from the diet" "$T"

T="$(new_tree)"
mkdir -p "$T/docs/superpowers/specs"
printf '# Spec\n\nSee https://example.invalid/page for context.\n' \
    > "$T/docs/superpowers/specs/2026-01-01-a-design.md"
assert_run 0 "an off-diet host inside a spec is exempt from the diet" "$T"

T="$(new_tree)"
mkdir -p "$T/docs/superpowers/plans"
printf '# Plan\n\n```bash\ncurl http://localhost:8080/health\n```\n\n[gone](./does-not-exist.md)\n' \
    > "$T/docs/superpowers/plans/2026-01-01-a.md"
assert_run 1 "a diet-exempt plan is still charged for a broken local link" "$T" \
    'does-not-exist.md'

# A document under docs/ that is NOT a work record keeps the diet.
T="$(new_tree)"
mkdir -p "$T/docs/windows"
printf '# Note\n\nSee https://example.invalid/page for context.\n' > "$T/docs/windows/note.md"
assert_run 1 "an off-diet host in a docs/ subdirectory that is not a work record is caught" "$T" \
    'example.invalid'

# The six entries this checks for were this project's own addition (46cf5c4) and
# pointed at headings that exist only inside fenced example blocks. The link gate
# passed them for ten weeks because its own fence mask had the same blind spot.
# This case reads the real file rather than a fixture: the defect was in shipped
# content, and a fixture would prove nothing about it.
#
# It deliberately does NOT import skills/writing-plans/scripts/mdfence.py. The
# finding this whole change rests on is that a generator and a gate sharing one
# blind spot agree with each other and prove nothing; a check on shipped content
# that ran the same scanner as the gate would rebuild exactly that echo. Keep
# this scanner separate — do not "fix" it into an import.
toc_doc="$REPO_ROOT/skills/writing-skills/anthropic-best-practices.md"
toc_report="$(python3 -B - "$toc_doc" <<'PY'
import re
import sys

lines = open(sys.argv[1], encoding="utf-8").read().splitlines()
FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})[ \t]*(.*)$")


def slug(text):
    # A third copy of the gate's own slug rule, and unlike the fence scanner
    # above it has no independence argument: it is here because this check runs
    # in a heredoc with no import path, and GitHub's anchor rule is stable. If
    # that rule ever moves, this copy and scripts/check-links.sh disagree in
    # silence — the cheapest place to notice is this comment.
    text = re.sub(r"`([^`]*)`", r"\1", text).strip().lower()
    text = re.sub(r"[^\w\s-]", "", text)
    return re.sub(r"\s+", "-", text)


opener, sections, entries = None, [], []
for line in lines:
    match = FENCE.match(line)
    if match:
        token, info = match.group(1), match.group(2).strip()
        if opener is None:
            opener = token
        elif token[0] == opener[0] and len(token) >= len(opener) and not info:
            opener = None
        continue
    if opener is not None:
        continue
    heading = re.match(r"^##\s+(.*?)\s*$", line)
    if heading and heading.group(1) != "Contents":
        sections.append(slug(heading.group(1)))
    entry = re.match(r"^- \[.*?\]\(#([^)]+)\)\s*$", line)
    if entry:
        entries.append(entry.group(1))

orphan = [e for e in entries if e not in sections]
missing = [s for s in sections if s not in entries]
print(f"orphan={','.join(orphan) or 'none'} missing={','.join(missing) or 'none'}")
PY
)"
if [ "$toc_report" = "orphan=none missing=none" ]; then
    pass "every table-of-contents anchor in anthropic-best-practices resolves"
else
    fail "every table-of-contents anchor in anthropic-best-practices resolves"
    echo "        $toc_report"
fi

# --- the CommonMark closing rule ------------------------------------------
# The naive toggle flipped on any three-backtick line, so a three-backtick block
# nested inside a four-backtick one closed the outer block and its headings
# became real anchors. Measured 2026-08-24: six links in a shipped skill file
# resolved against headings that exist only inside an example.
T="$(new_tree)"
printf '# Doc\n\n[to the example](#inner-heading)\n\n````markdown\n# Template\n\n```md\n## Inner heading\n```\n````\n' \
    > "$T/README.md"
assert_run 1 "a nested-fence heading produces no anchor" "$T" "inner-heading"

# AC14: the other half of the same change. Blanking MORE than before would break
# the pass that ignores links inside code; the nested shape is where a wider
# mask would reach first.
T="$(new_tree)"
printf '# Doc\n\n````markdown\n# Template\n\n```bash\ncat [not](a/link.md)\n```\n````\n' \
    > "$T/README.md"
assert_run 0 "a link inside a nested fenced block is ignored" "$T"

# AC17: every other case here runs the gate over a throwaway tree. This one runs
# it over the repository, which is the only thing that answers whether the two
# halves of this branch — the corrected mask and the corrected table of contents
# — actually agree in place.
repo_exit=0
"$REPO_ROOT/scripts/check-links.sh" >/dev/null 2>&1 || repo_exit=$?
if [ "$repo_exit" -eq 0 ]; then
    pass "the gate passes over this repository itself"
else
    fail "the gate passes over this repository itself — exit $repo_exit"
    { "$REPO_ROOT/scripts/check-links.sh" 2>&1 | sed 's/^/        /'; } || true
fi

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All check-links tests passed"
else
    echo "$FAILURES check-links test(s) failed"
    exit 1
fi
