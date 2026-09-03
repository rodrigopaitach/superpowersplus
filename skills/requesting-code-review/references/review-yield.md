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

The header to create the file with:

```markdown
# Review yield

One row per review dispatch. Columns are defined by the
superpowersplus:requesting-code-review skill, in `references/review-yield.md`.

| Date | Branch | Face | Round | Blocking findings | Still open from the previous round |
|---|---|---|---|---|---|
```

## The controller appends the row, never the reviewer

Three of the five reviewer prompts declare the review read-only on the
checkout — [code-reviewer.md](../code-reviewer.md),
[task-reviewer-prompt.md](../../subagent-driven-development/task-reviewer-prompt.md),
[re-review-prompt.md](../../subagent-driven-development/re-review-prompt.md).
A reviewer cannot write this row, and none of them is asked to.
