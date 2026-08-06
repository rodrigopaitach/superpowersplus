# Documents and links

Read before adding a document or a link. [`CLAUDE.md`](../CLAUDE.md) carries the
two rules an author applies while writing — a pointer is a markdown link, and
what each anchor form is for. This file carries what the gate does, so a red is
readable and a document lands in the right place.

## Three README-shaped files, three jobs

The relation, not the sizes. [`docs/README.pt-BR.md`](README.pt-BR.md) is
canonical and [`docs/README.en.md`](README.en.md) translates it;
`scripts/check-docs-sync.sh:14-15` names exactly those two and forces them into
the same commit. [`README.md`](../README.md) is outside that pair.

| File | Job | Gated by |
|---|---|---|
| [`README.md`](../README.md) | **Showcase.** What somebody landing on the repository sees: what the project is, one measured example, how to install | `check-links.sh` only |
| [`docs/README.pt-BR.md`](README.pt-BR.md) | **Canonical reference documentation.** The full text; on any divergence, this one holds | `check-docs-sync.sh` + `check-links.sh` |
| [`docs/README.en.md`](README.en.md) | **Translation of the canonical one.** Never edited alone | `check-docs-sync.sh` + `check-links.sh` |

**Structural divergence between the showcase and the documentation is
deliberate** — different sections, order and depth, because they answer
different questions. The sync gate covers the bilingual pair only; extending it
to the root would force the showcase to mirror a reference document.

## What check-links.sh reads

[`check-links.sh`](../scripts/check-links.sh) makes three passes, and they cover
different sets:

| Pass | Covers | Charges |
|---|---|---|
| Local links | The institutional files at the root — `CLAUDE.md` among them — everything in `docs/`, and every markdown file under `skills/` | A link whose destination does not exist, or whose anchor names no heading |
| Third-party diet | The same set, minus the two exemptions below, reading **raw lines, fenced blocks included** | A URL whose host is not on the allowlist |
| Section references | Every live markdown file, dated records excluded — plus `CHANGELOG.md`'s `## Open gaps` section, sliced out of the file around it | A section reference naming a file, or a heading, that does not exist |

`skills/**` was in none of them while the fear was rebase churn — upstream text
whose relative links move when their side changes. Measured instead of assumed:
every markdown link under `skills/` resolved, upstream's included, so the scan
simply covers them and no design to tell a fork-owned link from an upstream one
was needed. A link upstream wrote and broke is broken for this project's users
exactly like one written here.

`AGENTS.md` is deliberately in no pass: it is a symlink to `CLAUDE.md`, and
scanning both reports every problem twice.

**Dated records stay out of the section pass** — the changelog, the frozen
history, and the `RESULT-` files. A heading renamed later does not make a record
wrong, and a gate red on one would force rewriting a record to stay green.

**One section inside a dated record is the exception, and it is exempt for the
wrong reason without it.** `CHANGELOG.md`'s `## Open gaps` calls itself the live
list in its own opening line — closing an item edits it in place — while sitting
inside the one file this pass skips for being history. Exempt by container, live
by content, and so read by nothing: an item there went on describing a gate that
had already been widened, citing a line number that had itself moved. The
section is sliced from its heading to end of file, on the same boundary
[`release-notes.sh`](../scripts/release-notes.sh) uses to put it in a release
body, and reported line numbers are offset back to the real file. A renamed
heading raises rather than yielding an empty slice, which would report zero
problems and read like a clean pass. Added in `1.14.0`.

## Why the backtick convention is not gated

The reason is measured, not cost. The backticked paths under `skills/` that
resolve to nothing were counted and read one by one, and **not one of them was a
defect** — the count is in [`CHANGELOG.md`](../CHANGELOG.md) with its date. They
are placeholders, artifact paths inside a partner's own project,
self-references, and the deliberately-bad examples `writing-skills` teaches you
not to write. A gate there reports that many non-problems on every commit, which
is how a gate stops being read.

## The third-party link diet

**Third-party links are kept to what attribution requires**: one link to
`obra/superpowers` per document where the attribution appears, this
repository's own infrastructure, and nothing else. Everything a reader could
want to look up is named in text instead — a name and a version identify a
source without depending on somebody else's URL scheme. The reduction and its
date are in [`CHANGELOG.md`](../CHANGELOG.md).

**It is a gate, not a convention.** Four allowed prefixes:

- `github.com/rodrigopaitach/`
- `raw.githubusercontent.com/rodrigopaitach/`
- `img.shields.io/`
- `github.com/obra/superpowers` — attribution only

It reads raw lines because an install command naming the wrong repository is the
defect it exists to catch, and that lives inside a fenced block the local-link
pass blanks out. When it fails, fix the document: a URL pointing at the upstream
as an install source is not a gap in the allowlist.

**A third-party link is never fetched, but its domain is checked.** These are
different questions and only the second is answered. Checking the first would
mean a network call per link on every push, turning a deterministic gate into
one that goes red when somebody else's site is slow — and a gate that goes red
for reasons unrelated to the commit gets ignored. A dead allowed link is still
found by clicking it, and the diet is what makes that cheap: there is little
left to rot.

**Two exemptions from the diet only, for different reasons.**
[`docs/PLUS-CHANGELOG-historico.md`](PLUS-CHANGELOG-historico.md) cannot acquire
a new link by construction — `check-frozen-history.sh` refuses any change to it
— so watching it for new domains is a check with no function. Everything under
`skills/` is exempt because a skill legitimately cites vendor documentation: the
vendored best-practices point at the platform docs, and this fork's worked
example of a citation comment points at the vendor whose call it grounds. The
diet governs the documents this project hands to a reader.

Their local links and anchors stay checked in both cases. Freezing a file does
not freeze the files it points at, and the domain policy is the only thing that
stops at the directory boundary.
