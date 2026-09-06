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
| 04/09/2026 | evidence-model (evidence model v2) | plan | 3 | 8 | 0 |
| 04/09/2026 | evidence-model (evidence model v2) | plan | 4 | 2 | 0 |
| 04/09/2026 | evidence-model (range validation impl) | branch | 1 | 0 | — |
| 04/09/2026 | evidence-model (whole branch) | branch | 1 | 4 | — |
| 04/09/2026 | evidence-model (whole branch) | branch | 2 | 1 | 1 |
| 05/09/2026 | evidence-model (whole branch) | branch | 3 | 3 | 0 |
| 05/09/2026 | evidence-model (whole branch) | branch | 4 | 0 | 0 |
| 05/09/2026 | worktree-fix+nonbehavioral-verification-evidence | spec | 1 | 0 | — |
| 05/09/2026 | worktree-fix+nonbehavioral-verification-evidence | spec | 2 | 2 | 0 |
| 05/09/2026 | worktree-fix+nonbehavioral-verification-evidence | spec | 3 | 0 | 0 |
| 05/09/2026 | worktree-fix+nonbehavioral-verification-evidence | plan | 1 | 2 | — |
| 05/09/2026 | worktree-fix+nonbehavioral-verification-evidence | plan | 2 | 0 | 0 |
| 05/09/2026 | worktree-fix+nonbehavioral-verification-evidence | plan | 3 | 3 | 0 |
| 06/09/2026 | worktree-fix+nonbehavioral-verification-evidence | branch | 1 | 5 | — |
| 06/09/2026 | worktree-fix+nonbehavioral-verification-evidence | branch | 2 | 1 | 0 |
| 06/09/2026 | worktree-fix+nonbehavioral-verification-evidence | branch | 3 | 0 | 0 |

**Round 3 was not empty, and that is the first thing this table says.** The
tidy story — round 1 pays, round 2 does not, stop at two — is what rounds 1 and
2 of both faces looked like on their own. Round 3 of the `branch` face then
returned one blocking finding, and it was a defect **round 2's own fix pass had
left behind**: a rename marked in one of the two places that carried it. Four
rows are not a policy, and the shape they make is not the one that was expected.

**What the `plan` round 3 cell used to say, and why it does not say it now.**
It read `1`, and the number was real but answered a different question. Round
3's report opens *"Previous findings: 10 received — 1 still open"*, and that
one was finding #5, Task 2's claim about the neighbouring README entries. But
round 2 of that face returned **Approved, zero blocking findings** — its only
findings section is headed *Recommendations (advisory, do not block)* — so
there was no blocking finding for round 3 to find unfixed, which is the only
quantity this column holds. The ten were advisory items and human-review
findings, a wider set the ledger has no column for. The cell is `0`; the `1`
is recorded here so the correction is not mistaken for the count going
missing.

**The `branch` face's rows count Critical and Important together**, as the
column definition requires of the three diff faces. Round 1 returned no
Critical and five Important. Round 2 is the re-review of the closing fix wave:
it found all five repaired — so `0` still open — and returned one new Important
of its own, a closing code fence the wave itself had swallowed. **A fix wave
that repairs five and introduces one is what this column exists to make
visible**. It is also not the first round on this branch that the tidy story
would have predicted empty and that was not: `spec | 2` returned two and
`plan | 3` returned three. Named rather than counted — an ordinal over a table
that keeps growing goes stale the next time somebody appends to it, which is
how the first version of this sentence came to say *second*.

**Round 3 is the re-review of that repair, and it approved.** It found the
fence restored, the two stale numbers turned into conditions, and returned no
Critical and no Important — three Minors, which this column does not count.
It ran against `628d0d6`; **no row here reviews `a01aedf`**, which answered
those Minors and has not been reviewed. A clean round earns a row like any
other: the rule this file states is one row per dispatch, green ones included,
and a zero that is absent reads exactly like a dispatch that never happened.

**The `spec` face's three rounds on `review-yield-and-problem-section` carry
no row, and the reason is the one this file exists to end.** They ran before
the ledger did; round 1's nine blocking findings are recoverable from the
commit that answered them, and rounds 2 and 3 are not — their counts were
never written down anywhere, and reconstructing them now would be inventing
the first entries of a record whose whole point is that it is measured. The
gap is the argument.

**That paragraph read "this branch" until 06/09/2026.** It was written when
the table held three rows and no `spec` row at all (`7ec54eb`), so "this
branch" was unambiguous then. Rows for
`worktree-fix+nonbehavioral-verification-evidence` were appended later, its
`spec` rounds 1 to 3 among them, and a reader then met a sentence saying the
`spec` rounds carry no row sitting directly under three rows that do. Only the
branch name was added; the claim is unchanged.
