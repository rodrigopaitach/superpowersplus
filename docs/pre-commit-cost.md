# What the pre-commit hook costs

A baseline, not a constant, and no gate reads it. `CLAUDE.md` keeps the one
line that acts on it — if a commit ever visibly drags, time the checks one at
a time against this table — and the numbers live here, where they can age
without looking like a rule.

Measured 2026-08-02, median of three runs each on a warm cache, invoking each script directly:

| Check | Cost |
|---|---|
| `check-docs-sync.sh` | 3 ms |
| `check-frozen-history.sh` | 3 ms |
| `check-changelog.sh` | 3 ms |
| `check-links.sh` | 70 ms |
| `check-skill-size.sh` | 10 ms |
| **`githooks/pre-commit` end to end** | **90 ms** |

Those three rows were re-measured 2026-08-04 the same way; the other three are unchanged from the run above. `check-links.sh` went 29 → 42 ms when its scan grew from 12 files to 56, then 42 → 70 when it gained the section-reference pass, which resolves each bare basename by walking the tree. `check-skill-size.sh` starts no interpreter — its cost is `wc` processes and nothing else.

**The condition matters more than the number, and there is deliberately no automatic timer.** Most of `check-links.sh` is `python3` startup, which moves with the machine and with whether the interpreter is in cache — an independent measurement the same day reported roughly 7× these figures. Treat the table as a baseline taken this way, on this machine, not as a constant. A stopwatch around the hook would be one more thing to maintain, reporting a number nobody reads on every commit; if a commit ever visibly drags, time the checks one at a time against the table above.

**One row is missing on purpose.** `check-evidence-line.sh` joined the hook
after both runs above and was never timed the same way. Measuring it now, on
a different day and a warm-or-cold interpreter, would blend two instruments
into one table — the failure this project charges everywhere else. It is
declared absent instead.
