# Review yield

What each review dispatch returned, one row per dispatch. The cost of a review
is already on record — a median of 7.3 minutes across 29 document reviews,
[`CHANGELOG.md`](../CHANGELOG.md), section `[1.16.0] - 2026-08-08`. What it returns was not on
record anywhere, so "are the review passes paying for themselves" could be
argued and never answered.

**One row per dispatch, not per face and not per branch.** The round is what
the question turns on: if round 2 and round 3 keep coming back with zero
blocking findings, the extra rounds buy nothing, and that is legible here
without anyone reading prose.

**The controller appends the row, never the reviewer.** Three of the five
reviewer prompts declare the review read-only on the checkout —
`skills/requesting-code-review/code-reviewer.md:35`,
`skills/subagent-driven-development/task-reviewer-prompt.md:66`,
`skills/subagent-driven-development/re-review-prompt.md:42`.

| Column | What goes in it |
|---|---|
| Date | The date of the dispatch, `DD/MM/AAAA` |
| Branch | The branch the review ran against |
| Face | `spec`, `plan`, `task <N>`, `re-review <N>`, or `branch` |
| Round | `1` for the first dispatch of that face, then `2`, `3` |
| Blocking findings | How many the reviewer returned in this round. The two document faces return blocking findings by that name; the three diff faces return Critical and Important, and both count |
| Still open from the previous round | How many of the previous round's blocking findings this round found unfixed. `—` on round 1 |

| Date | Branch | Face | Round | Blocking findings | Still open from the previous round |
|---|---|---|---|---|---|
