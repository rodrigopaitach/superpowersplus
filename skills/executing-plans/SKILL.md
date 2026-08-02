---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents (Claude Code, Codex CLI, Codex App, Copilot CLI, and Gemini CLI all qualify; see the per-platform tool refs in `../using-superpowers/references/`). If subagents are available, use superpowers:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Ensure an isolated workspace: use superpowers:using-git-worktrees to create one or verify the existing one
2. Read plan file
3. Read the spec the plan cites — the plan is a translation of it, and
   superpowers:final-branch-audit traces one against the other at the end. A
   plan citing no spec is an entry blocker: get the path from your human
   partner before Step 2, never start and sort it out later.
4. Review critically - identify any questions or concerns about the plan
5. Check every task carries acceptance criteria verifiable by located
   evidence — one observable behavior each, settled by a `file:line`
   citation, naming its covering test (the format superpowers:writing-plans
   specifies). A task whose criteria no citation could settle is a concern:
   the audit in Step 3 will charge exactly what the plan wrote.
6. If concerns: Raise them with your human partner before starting
7. If no concerns: Create todos for the plan items and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Audit the Branch

After the last task, before finishing: the conformance audit is mandatory.

- **REQUIRED SUB-SKILL:** Use superpowers:final-branch-audit
- It walks every task and verdicts every acceptance criterion against
  located evidence. Your own todos are claims under audit, not evidence —
  marking a task completed in Step 2 proves nothing to it.
- Verdict FAIL: the branch is not done. Fix the NOT DELIVERED rows and
  re-run the audit. Never resolve a gap by editing the plan to stop asking.

### Step 4: Complete Development

After all tasks complete and verified, and the audit PASSes:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

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
