# Review yield

One row per review dispatch. Columns are defined by the
superpowersplus:requesting-code-review skill, in `references/review-yield.md`.

| Date | Branch | Face | Round | Blocking findings | Still open from the previous round |
|---|---|---|---|---|---|
| 03/09/2026 | review-yield-and-problem-section | plan | 1 | 3 | — |
| 03/09/2026 | review-yield-and-problem-section | plan | 2 | 0 | 0 |
| 03/09/2026 | review-yield-and-problem-section | branch | 1 | 6 | — |
| 03/09/2026 | review-yield-and-problem-section | branch | 2 | 0 | 0 |
| 03/09/2026 | review-yield-and-problem-section | branch | 3 | 1 | 0 |
| 03/09/2026 | main (release-notes footer fix) | branch | 1 | 5 | — |
| 04/09/2026 | main (evidence-model spec) | spec | 1 | 9 | — |
| 04/09/2026 | evidence-model (range validation) | spec | 2 | 3 | 0 |
| 04/09/2026 | evidence-model (evidence model v2) | spec | 1 | 9 | — |
| 04/09/2026 | evidence-model (range validation) | spec | 3 | 0 | 0 |
| 04/09/2026 | evidence-model (evidence model v2) | spec | 2 | 6 | 0 |
| 04/09/2026 | evidence-model (evidence model v2) | spec | 3 | 2 | 0 |
| 04/09/2026 | evidence-model (evidence model v2) | spec | 4 | 1 | 0 |
| 04/09/2026 | evidence-model (range validation) | plan | 1 | 2 | — |
| 04/09/2026 | evidence-model (range validation) | plan | 2 | 4 | 0 |
| 04/09/2026 | evidence-model (range validation) | plan | 3 | 1 | 0 |
| 04/09/2026 | evidence-model (evidence model v2) | plan | 1 | 6 | — |
| 04/09/2026 | evidence-model (evidence model v2) | plan | 2 | 4 | 0 |
| 04/09/2026 | evidence-model (evidence model v2) | plan | 3 | 7 | 0 |

**Round 3 was not empty, and that is the first thing this table says.** The
tidy story — round 1 pays, round 2 does not, stop at two — is what rounds 1 and
2 of both faces looked like on their own. Round 3 of the `branch` face then
returned one blocking finding, and it was a defect **round 2's own fix pass had
left behind**: a rename marked in one of the two places that carried it. Four
rows are not a policy, and the shape they make is not the one that was expected.

**The `spec` face's three rounds on this branch carry no row, and the reason is
the one this file exists to end.** They ran before the ledger did; round 1's
nine blocking findings are recoverable from the commit that answered them, and
rounds 2 and 3 are not — their counts were never written down anywhere, and
reconstructing them now would be inventing the first entries of a record whose
whole point is that it is measured. The gap is the argument.
