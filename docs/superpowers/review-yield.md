# Review yield

One row per review dispatch. Columns are defined by the
superpowersplus:requesting-code-review skill, in `references/review-yield.md`.

| Date | Branch | Face | Round | Blocking findings | Still open from the previous round |
|---|---|---|---|---|---|
| 03/09/2026 | review-yield-and-problem-section | plan | 1 | 3 | — |
| 03/09/2026 | review-yield-and-problem-section | plan | 2 | 0 | 0 |
| 03/09/2026 | review-yield-and-problem-section | branch | 1 | 6 | — |
| 03/09/2026 | review-yield-and-problem-section | branch | 2 | 0 | 0 |

**The `spec` face's three rounds on this branch carry no row, and the reason is
the one this file exists to end.** They ran before the ledger did; round 1's
nine blocking findings are recoverable from the commit that answered them, and
rounds 2 and 3 are not — their counts were never written down anywhere, and
reconstructing them now would be inventing the first entries of a record whose
whole point is that it is measured. The gap is the argument.
