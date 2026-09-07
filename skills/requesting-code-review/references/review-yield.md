# The review-yield ledger

The one definition of the ledger's columns. The four skills that dispatch a
review link here rather than restating them — the same arrangement
[execution-path.md](../../writing-plans/references/execution-path.md) has with
its three callers, and for the same reason: a definition nobody owns is
corrected in one of the places that carry it.

**It lives here, in the plugin, and not in the ledger's own header, because the
ledger is a file in the project being worked on.** A project that has never run
a review has no ledger to read the format from, so the format cannot live
inside it.

## Where the file goes

`docs/superpowers/review-yield.md`, in the project being worked on — beside the
`docs/superpowers/specs/` and `docs/superpowers/plans/` that skill already
writes there. **Create it from the header below if it is not there yet.**

## What each dispatch records

One row per dispatch, never per face and never per branch. The round is what
the question turns on: rounds 2 and 3 coming back with zero blocking findings is
the shape that says the extra rounds buy nothing, and it is only legible if
every round has a row — including the clean ones.

| Column | What goes in it |
|---|---|
| Date | The date of the dispatch, `DD/MM/YYYY` |
| Branch | The branch the review ran against |
| Face | `spec`, `plan`, `task <N>`, `re-review <N>`, or `branch` |
| Round | `1` for the first dispatch of that face, then `2`, `3` |
| Blocking findings | How many the reviewer returned in this round. The two document faces return blocking findings by that name; the three diff faces return Critical and Important, and both count |
| Still open from the previous round | How many of the previous round's blocking findings this round found unfixed. `—` on round 1 |
| Report | A markdown link to the preserved report this dispatch returned, relative to the ledger's own directory. `—` means no report linked in this record |

The header to create the file with:

```markdown
# Review yield

One row per review dispatch. Columns are defined by the
superpowersplus:requesting-code-review skill, in `references/review-yield.md`.

| Date | Branch | Face | Round | Blocking findings | Still open from the previous round | Report |
|---|---|---|---|---|---|---|
```

## Where the report goes

The report a dispatch returns is saved **verbatim and whole**, one file per
dispatch, never appended to an existing one — and **saved before the row is
appended**, so a row never points at something that was not written yet.

```text
docs/superpowers/reviews/<date>-<branch-slug>-<subject-slug>-<face-slug>-<round>[-N].md
```

| Segment | What it is |
|---|---|
| `<date>` | The dispatch date, `YYYY-MM-DD` — ISO here, unlike the ledger's `DD/MM/YYYY` cell, so the directory sorts chronologically |
| `<branch-slug>` | The branch name, lowercased, with every run of characters outside `[a-z0-9]` replaced by a single `-`, and leading and trailing `-` removed |
| `<subject-slug>` | The same transformation applied to the short name of the document or diff under review. Omitted only when the branch reviews exactly one subject |
| `<face-slug>` | The face with its space replaced by `-`: `spec`, `plan`, `branch`, `task-2`, `re-review-3` |
| `<round>` | The round number, matching the row's Round cell |
| `[-N]` | **Never written by you.** Appended by the helper alone, and only when the path it was given is already taken |

**The write is done by a script, not by following this paragraph:**
[save-review-report.sh](../scripts/save-review-report.sh), called as
`save-review-report.sh <source> <destination>`. It creates the destination's
directory if it is missing — the reviews directory does not exist in a project
that has never saved one — and it prints the path it actually used.

**Write the printed path into the ledger, never the one you passed in.** On a
collision the helper installs at the next free suffix and says so, and the row
has to name the file that exists.

The reason this is a script and not a rule in prose: the guarantee is that
nothing is overwritten, and that has to live in the write operation. The helper
writes the report into a temporary file beside the destination and then claims
the name with `ln`, whose underlying `link()` POSIX defines as atomic and as
failing when the name already resolves to anything — a file, a directory, a
FIFO, a device, or a symbolic link resolving or not. So a name already taken
cannot be clobbered even by a caller who never read this page. A rule in prose
depends on the agent remembering it at the moment it matters.

## What the comparison proves

The helper compares what it installed against what it was handed, and removes
what it created if the two differ.

**That comparison proves equality with the source it was given. It does not
prove that the source is a faithful copy of what the subagent returned.** That
earlier step happens before the helper is called, is outside its inputs, and is
verified by nothing here. A pass means the bytes arrived intact from the file
you named onwards — no further.

## What goes in the cell

A **markdown link**, relative to the ledger's own directory:

```markdown
| 06/09/2026 | a-branch | spec | 1 | 3 | — | [spec 1](reviews/2026-09-06-a-branch-a-subject-spec-1.md) |
```

The example sits in a fenced block on purpose — the path in it names no real
file, and the link checker resolves every link it can see.

**Not a backticked path, and not a bare one.** The link checker,
[check-links.sh](../../../scripts/check-links.sh), resolves link syntax and
nothing else, so a path written any other way in this cell would never be
checked by it. The report gate,
[check-review-reports.sh](../../../scripts/check-review-reports.sh), therefore
rejects every cell that is neither the em-dash nor a markdown link — an empty
cell and a plain hyphen included. The form is fixed here so that the two gates
between them leave no cell unread.

## A ledger without the column

**A six-column ledger stays valid.** The column arrives when the first row under
this rule is appended, and every row already there gets `—` in it.

**No historical row has to be re-read, and nothing is reconstructed.** `—` says
one thing and only that: *no report linked in this record*. It is a statement
about the cell. It does not say a report was written, does not say one was not,
and asserts nothing about anything beyond this ledger.

## The controller appends the row, never the reviewer

Three of the five reviewer prompts declare the review read-only on the
checkout — [code-reviewer.md](../code-reviewer.md),
[task-reviewer-prompt.md](../../subagent-driven-development/task-reviewer-prompt.md),
[re-review-prompt.md](../../subagent-driven-development/re-review-prompt.md).
A reviewer cannot write this row, and none of them is asked to.
