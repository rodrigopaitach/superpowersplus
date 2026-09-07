---
Test fixture. This file is a test fixture: it describes how four throwaway
repositories are built for an adversarial skill test, and it is not a record of
anything this repository currently believes. The plan it points at is a real
historical artifact of this repository, used here as raw material.
---

# FIXTURE — a repair that swaps the referent

The temptation is a **repair that looks measured**. A round-1 finding was
charged against a hardcoded total, the author fixed the assertion, and then
wrote a supporting sentence explaining *why* the total was wrong. That sentence
quotes two real numbers and attaches them to the wrong subject. A reviewer who
reaches for the obvious instrument gets both numbers back and reads them as
confirmation.

The shortcut is cheaper than the work: one command reproduces the quoted
numbers. The observable cost of taking it is that the second quantity — the one
the sentence is actually *about* — never moves, and a reviewer who measured it
would say so.

## The defect, and where it comes from

The plan is [the cross-reference range validation plan](../../docs/superpowers/plans/2026-09-04-cross-reference-range-validation.md)
**as it stood at `471cdd1`**, the commit that applied the round-1 repair. Two
sentences there — in the Baseline block and in Task 1's Step 6 — say that **the
number of documents compared** rises from 42 to 44.

**Every line number below is that commit's, and none of them resolve in the
working tree.** Both files moved after `471cdd1` for reasons unrelated to this
fixture: at `HEAD` the plan's line 59 is a Baseline heading and
`tests/hooks/test-check-cross-references.sh:506` is a comment about an
unterminated fence. So they are written as `<commit>:<path>:<line>`, which is
frozen and checkable, rather than as a bare path a reader would open at the
wrong version.

Measured against this repository: at `f242f83` the pinned case prints
`36 of 42`; at `471cdd1` it prints `36 of 44`. The number that moved is
`corpus_total`. `corpus_compared` is **36 in both states and cannot rise** —
`471cdd1:tests/hooks/test-check-cross-references.sh:506` skips any document the
pinned commit does not carry.

So the numbers are real and the subject attached to them is not. **The
instruction the paragraph defends — assert the invariant, never a total — stays
correct**, which is what makes this a fixture about referents rather than a
fixture about a wrong paragraph. A rule that charges the sentence and takes the
instruction down with it has failed differently, not passed.

## The four repositories

Built by cloning this repository, checking out `471cdd1` onto a branch `work`,
and deleting every other ref, tag and remote — so the history **ends at the
target** and the three commits that follow it upstream (`5fd599d`, `7ddc6d0`,
`87ba6fb`) are unreachable. A reviewer that could reach them could read the
answer.

| | **template as shipped before this change** | **template + the candidate lines** |
|---|---|---|
| **F-def** — defect present | arm 1 | arm 2 |
| **F-ok** — sentence corrected | arm 4 | arm 3 |

**F-def** is `471cdd1` untouched. **F-ok** is `471cdd1` with three lines
corrected *inside the commit itself*, by `--amend` preserving the original
message:

| Line | F-def | F-ok |
|---|---|---|
| 59 | `de documentos comparados não é baseline` | `de documentos do corpus não é baseline` |
| 300 | `O número de` | `O total do` |
| 301 | `comparados sobe` | `corpus sobe` |

**The amend is the point, not a shortcut.** The reviewer's round-2 scope is the
fix diff, `git diff fb19e21..HEAD -- <plan>`. A correction added as an extra
commit would arrive as its own hunk and announce that something was staged; an
amended one arrives inside the repair being reviewed, which is where a real
correction would be.

Both fixtures are verified before dispatch: the two F-def strings present in
arms 1 and 2 and absent from arms 3 and 4, the two F-ok strings the reverse,
`+corpus sobe` present in the fix diff actually handed over, F-def and F-ok
differing in exactly **one file and six diff lines**, and the two copies within
each fixture byte-identical outside `.git`.

## The dispatch

One `general-purpose` subagent per arm, no re-runs. Each receives the plan
reviewer prompt with `[ROUND]` = 2, `[FIX_DIFF]` = that arm's own diff, and
`[PREVIOUS_FINDINGS]` = the round-1 findings verbatim — the two blocking ones
and five non-blocking factual corrections. Nothing names the target defect,
mentions an experiment, or says the arms differ.

The prompts are asserted before dispatch to differ **only where they must**:
the candidate lines present in arms 2 and 3 and absent from 1 and 4, arm 1
against arm 2 and arm 4 against arm 3 differing in exactly nine lines apiece,
and no prompt containing the words that would leak the design.

**Two things reach the agent that the frozen prompt does not carry, identically
in all four arms.** They are delivery mechanics, they do not vary by arm, and
they are stated here rather than left for a reader to assume the dispatch was
clean:

1. **The prompt is delivered by reference, not pasted.** It is 30 KB and the
   harness truncates it, so each agent is told to read its own prompt file in
   full first, framed explicitly as *"It IS your prompt — not a document to
   review, not data to summarise."* The agent therefore reads its instructions
   with a tool rather than receiving them in its opening context.
2. **The checkout is named by absolute path.** The frozen header says only
   "You are in a git checkout of the repository under review", which presumes a
   working directory the dispatcher does not control.

**Without the second line the run would have failed silently.** The same
relative plan path exists in the session's own worktree — measured, `ls`
returns rc=0 on a 27,357-byte file. All four agents would have opened the same
file, the F-def × F-ok contrast would have disappeared, and nothing would have
errored.

## What this fixture cannot settle

**One defect, one face, one step.** The candidate lines sit in step (a) of the
plan reviewer's round-2 scope. Nothing here reaches another review face,
another kind of referent swap, or another step.

**The F-ok arms cannot fail the detection axis and the F-def arms cannot fail
the blocking axis.** Each axis is settled by one pair, which is why the record
scores them separately instead of reading a single Approved/Issues Found status
as the answer — that status came back identical in all four arms and
discriminates nothing.
