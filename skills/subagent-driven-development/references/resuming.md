# Resuming an Interrupted Run

Everything here covers one situation: this plan was already being executed and
you are not starting it. `SKILL.md` sends you here from Setup — a ledger that
already exists, a branch carrying commits you did not make this session, or an
`**Execution:**` field naming the other path. **Read it before dispatching
anything.**

The failure it exists to prevent is the most expensive one observed in real
sessions: a controller that lost its place re-dispatched entire completed task
sequences. Conversation memory does not survive compaction. The ledger and
`git log` do.

## Reading the ledger

The ledger lives at `<workspace>/progress.md`.

- **Its first line names your plan file:** tasks with a `Task <N>: complete`
  line are DONE — do not re-dispatch them; resume at the first task without
  one.
- **A task whose last line is a fix round is mid-loop:** resume the loop at the
  next round.
- **Its first line names a different plan file** — or it is a stray ledger at
  the old flat path `.superpowers/sdd/progress.md` — that is another plan's
  progress: leave it in place and start your own, fresh.
- The ledger is your recovery map: the commits it names exist in git even when
  your context no longer remembers creating them. After compaction, trust the
  ledger and `git log` over your own recollection.
- `git clean -fdx` destroys the workspace — it is git-ignored scratch. If that
  happened, rebuild by the first of the two shapes below.

## Before dispatching anything

1. **Find the resume point** by the ledger rules above.
2. **Check it against `git log`.** The ledger claims; git holds. A completion
   line naming commits the branch does not contain, or commits past the last
   line the ledger recorded, means the two disagree — and what git contains is
   what happened.
3. **Present the resume point to your human partner and wait for one answer**,
   in the escalation shape `SKILL.md` carries: what the branch already has,
   where you would resume, what resuming in the wrong place costs (a second
   implementation of finished work, at full task price, or a gap every later
   task builds on), and your recommendation with that evidence behind it. This
   is the one moment continuous execution does not cover — everything after it
   rests on a starting point nobody checked.

## Two shapes the ledger rules cannot describe

In both, the ledger is what is missing.

- **No ledger, but the branch has work.** Never read an absent ledger as an
  unstarted plan — the workspace is git-ignored scratch that `git clean -fdx`
  deletes, and reading its absence as "nothing happened" is exactly the
  re-dispatch of a completed sequence this file exists to prevent. Rebuild from
  `git log` and the plan: map commits to tasks by what they touch, write only
  the lines the commits support, and mark each reconstructed one as
  reconstructed. Then present it as above — a mapping you inferred is the kind
  of claim your partner should get the chance to correct.
- **A task with no completion line and no report.** The interruption landed
  inside a dispatch. Read the task's report file — an implementer that got
  partway may have written it — and the commits since that task's BASE, before
  deciding anything. An implementer that committed and then lost its controller
  leaves work that a blind re-dispatch duplicates or reverts.

## The plan's `**Execution:**` field names the inline path

`SKILL.md` has you read that field at setup, and stop if it names the other
path. Here is what each side costs, which is what your partner is deciding
between:

- **Switching to the recorded inline path** gives up the ledger and the
  per-task reviews, and buys continuity with a record that does not outlive the
  session it was written in — which is gone, or you would not be here.
- **Continuing here** starts a ledger from nothing, so what is already done has
  to be established from `git log` and the plan by the route above, never
  assumed.

A plan with no such field is a plan written before the field existed. That is
not an error: proceed, and write the path you are taking into it.
