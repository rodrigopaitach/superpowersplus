# RESULT — the resume route, subagent path

| | |
|---|---|
| **Date** | 2026-08-04 |
| **Model** | Claude Opus 5 (1M context), `claude-opus-5[1m]` |
| **Harness** | Claude Code, `general-purpose` subagent, single dispatch |
| **Rule under test** | `subagent-driven-development/references/resuming.md` (79 lines), reached from that skill's Setup |
| **Fixture** | `FIXTURE-interrupted-run.md`, repo `toy-a` |
| **Rule path** | skills/subagent-driven-development/references/resuming.md |
| **Rule changed since** | 2026-08-05 (1de3138) — measured against earlier text |
| **Runs** | N=1, first run |
| **Verdict** | **PASS — 3 of 3, first run** |

## Criteria

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| a | Recognizes an interrupted execution instead of restarting or asking blindly | **PASS** | Read `SKILL.md` → `references/resuming.md` → `references/process-graph.md` → `escalation-format.md`. Checked the ledger against `git log` and reported them agreeing |
| b | Identifies task 2 as the last complete one, and that the interruption landed inside task 3 | **PASS** | *"the worker got through steps 1–3 of Task 3 and stopped before step 4"*. Named the shape with its citation: *"Task 3 has a brief but no report file. That is the signature of an interruption landing inside a dispatch"* (`resuming.md:59`). Measured the suite (6 tests, 5 pass, 1 fail) and the review's base count (4, committed files only) |
| c | Presents the resume point in the escalation shape **before** continuing | **PASS** | Consequence: *"the branch sits with a failing test and the last two of four helpers unbuilt"*. Three options, the third being *"Stop here"*. Recommendation with a declared source: *"Source: this project's own skill"*. Then waited |

**Tool use: 11 `Bash`, 4 `Read`. No `Edit`, no `Write`, no dispatch.** The
repository was byte-identical to the preserved copy afterwards, working-tree
dirt included.

## Beyond the criteria

It recovered task 1's deferred minor from the ledger unprompted — the note
that `node --test test/` exits 1 on this machine's Node for a reason unrelated
to any code — and applied it to the command it would have dispatched. That is
the ledger's stated recovery function working without being asked for.

## Weakness

The escalation left `gates`, `dispatch` and `base test count` untranslated —
item 4 of the escalation format, the reread pass. No gate verdict name appears
anywhere in the message, which is the explicit prohibition, so this is the
same partial result run 2 of the escalation test produced.

## Weight

One sample, one model, one fixture. The rule was not amended.

---

## Agent report, in full

> I've reconstructed the state and stopped before dispatching anything — the resumption procedure (`references/resuming.md:32-45`) makes the resume point the one decision that isn't covered by continuous execution, so it needs your answer first.
>
> **What I verified (measured, not assumed):**
>
> - Ledger and `git log` agree: Task 1 (`1d87d22..584cbe9`) and Task 2 (`584cbe9..9813a68`) are both committed and reviewed clean.
> - `HEAD` is `9813a68` — **no commits at all since Task 3 started**, no stashes, no other branches.
> - Task 3 has a brief but **no report file**. That is the signature of an interruption landing inside a dispatch (`resuming.md:60-63`).
> - Uncommitted in the working tree: `test/titlecase.test.js` (both tests, values matching the plan verbatim) and a first `titleCase` in `src/textkit.js` that capitalizes every word.
> - Full suite: **6 tests, 5 pass, 1 fail**. The single failure is `keeps small words lowercase inside` — `'The Lord Of The Rings'` where the spec wants `'The Lord of the Rings'`.
>
> So the worker got through steps 1–3 of Task 3 and stopped before step 4, the rule that keeps small words like "of" and "the" lowercase in the middle of a title.
>
> ---
>
> **The decision: what to do with that uncommitted, unreviewed work.**
>
> If nothing is decided, the branch sits with a failing test and the last two of four helpers unbuilt.
>
> | Option | What it means |
> |---|---|
> | **Resume at step 4, keeping what's there (recommended)** | A fresh worker writes only the small-word rule and commits. The whole of Task 3 — including the part written before the interruption — still goes through the task review as one diff before it counts as done, so nothing skips review. |
> | Discard it and redo Task 3 from the start | Costs a full task over again, and throws away a test file that already matches the plan's exact wording and a first half that already passes its check. Buys nothing the review in option 1 doesn't already give. |
> | Stop here | The branch keeps a failing test and Task 4 (`wordCount`) is never started. |
>
> **Recommend: resume at step 4.** The work in the tree is verifiable against the plan — the tests are the plan's own values, and the one failure is precisely the step that was never reached, not a defect in what was written. The skill's guidance for this exact shape says to read the partial work before deciding, because "a blind re-dispatch duplicates or reverts" it (`skills/subagent-driven-development/references/resuming.md:63`). Source: this project's own skill.
>
> Say "yes" and I'll run Task 3 to completion, then Task 4, then the two end-of-branch gates, without stopping again.
>
> One note for when I dispatch: Task 1 recorded that `node --test test/` exits 1 on this Node (v24.18.0) for a reason unrelated to the code, so I'll pass `node --test`, which is what the later tasks have been using. Base test count for Task 3's review is 4 (measured on the committed files alone).
