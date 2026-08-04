---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents (Claude Code, Codex CLI, Codex App, Copilot CLI, and Gemini CLI all qualify; see the per-platform tool refs in `../using-superpowers/references/`). If subagents are available, use superpowersplus:subagent-driven-development instead of this skill.

**Progress reports.** Report to your human partner at four fixed points, one
line each:

- **Starting:** how many tasks the plan has, that this is the inline path,
  and that the record is this session's todo list.
- **Each task done:** `task N of M complete — <short title>`, and what
  comes next.
- **Going back to fix something** — a verification that failed, an audit
  that came back FAIL: what failed, and that you are fixing it. This path
  runs no numbered fix rounds, so there is no round count to give; do not
  invent one.
- **Finishing:** what was delivered, and which gate runs next.

A report asks nothing and waits for nothing — you keep going in the same
breath. It carries no gate vocabulary either: `NOT DELIVERED` and the rest
belong to the audit's own report, not to a line telling your partner where
the work is. Past two lines it has become a status summary; shorten it. When
you actually need a decision, that is an escalation, and the shape for it is
below.

**No gate can check any of this, and none is asked to.** These reports
happen in the chat, which the audit does not read. Do not build a verifier
for them later.

**Resuming after an interruption.** This path records progress in session
todos, and session todos do not outlive the session — compaction inside one
loses them just as well. There is no ledger here to fall back on, and this
skill does not create one: inline execution exists for work that finishes in
one sitting, and a plan that keeps outliving its session is telling you it
belonged on the subagent path. Say the limitation out loud when you start,
in the first report above, rather than letting your partner meet it later.

When you do have to resume, reconstruct — do not guess. Read the plan, then
read `git log` for the branch: commits map to tasks by what they touch and by
what each task's steps named. Rebuild the todo list from those two sources,
state which tasks you believe are done and the evidence for each, and get
your partner's confirmation before executing anything — in the escalation
shape below, since being wrong costs them either way. Re-running a finished
task duplicates or reverts work already committed; skipping an unfinished one
ships a gap that surfaces at the Step 3 audit, after everything downstream was
built on it.

## The Process

### Step 1: Load and Review Plan
1. Ensure an isolated workspace: use superpowersplus:using-git-worktrees to create one or verify the existing one
2. Read plan file
3. Read the plan header's `**Execution:**` field — it records the path this
   plan was handed to and where its progress was being kept. If it names the
   subagent path, you are resuming by a different route than the one it started
   on: read the ledger it names first, whatever else follows — it may still be
   on disk and it holds the exact resume point. Then the choice, **but only
   where subagents are actually available**: present it in the escalation shape
   below before executing anything, since switching to
   superpowersplus:subagent-driven-development keeps that record and the
   per-task reviews, while continuing here abandons a record that exists and can
   be read, for todos that will not outlive this session. Where they are not,
   there is no choice to present — this skill is the path for exactly that case
   (the Note above), and offering a route the harness cannot take spends your
   partner's turn on a decision they cannot make. Say which of the two you are
   in: "no subagents here" and "I did not check" read the same otherwise. A plan
   with no such field is a plan written before the field existed — not an error:
   proceed, and write the path you are taking into it.
4. Read the spec the plan cites — the plan is a translation of it, and
   superpowersplus:final-branch-audit traces one against the other at the end. A
   plan citing no spec is an entry blocker: get the path from your human
   partner before Step 2, never start and sort it out later.
5. Review critically - identify any questions or concerns about the plan
6. Check every task carries acceptance criteria verifiable by located
   evidence — one observable behavior each, settled by a `file:line`
   citation, naming its covering test (the format superpowersplus:writing-plans
   specifies). A task whose criteria no citation could settle is a concern:
   the audit in Step 3 will charge exactly what the plan wrote.
7. If concerns: Raise them with your human partner before starting
8. If no concerns: Create todos for the plan items and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Audit the Branch

After the last task, before finishing: the conformance audit is mandatory.

- **REQUIRED SUB-SKILL:** Use superpowersplus:final-branch-audit
- It walks every task and verdicts every acceptance criterion against
  located evidence. Your own todos are claims under audit, not evidence —
  marking a task completed in Step 2 proves nothing to it.
- Verdict FAIL: the branch is not done. Fix the NOT DELIVERED rows and
  re-run the audit. Never resolve a gap by editing the plan to stop asking.

**Three audit rounds maximum.** A round is one fix pass plus one re-run of the
audit. Three and not the task loop's five: those five exist because rounds 4–5
change the actor — a fresh implementer on a more capable model, at
`../subagent-driven-development/SKILL.md`. This path has no such escalation and
cannot acquire one; it is the path for when subagents are not available, and it
names no dispatch and no model anywhere. The same actor fixes and re-audits
every round, reading the same plan against the same branch, so nothing about
round four differs from round three. Its match is the constant-actor final fix
wave, capped at three, in
`../subagent-driven-development/references/final-review.md`.

**At the cap, escalate — do not open a fourth round.** In the escalation shape
below: which rows are still NOT DELIVERED, why three rounds did not close them,
and the options with their cost — finish with the gaps recorded and named to
your partner, implement what the audit keeps asking for as its own task, or go
back to the plan, which is where a criterion nothing can satisfy usually comes
from. Three rounds that did not converge is a finding about the plan, not about
the last fix.

**A row that returns to NOT DELIVERED after being fixed escalates immediately,
whatever the round.** Either two criteria are pulling against each other —
every fix satisfies one and breaks the other — or it is a criterion no evidence
could settle, which is the concern Step 1 asks you to raise before starting.
Rounds settle neither, because each one re-runs the same collision. Name the
criterion, the fix that moved it, and what moved it back, and take it to your
partner.

### Step 4: Complete Development

After all tasks complete and verified, and the audit PASSes:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowersplus:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

**Escalation shape** (detail and a worked example: `../using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it. A gate verdict name (`LOST IN TRANSLATION`, `INVENTED SCOPE`, …) appears only in parentheses, never carrying the explanation.

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- A completed todo is not evidence — the audit in Step 3 decides what shipped
- Never start implementation on main/master branch without explicit user consent
