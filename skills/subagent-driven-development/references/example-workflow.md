# Example Workflow

**Open this to see the loop's shape end to end** — setup, two tasks (one
clean, one through a fix round), and both final gates. It illustrates the
protocol in SKILL.md; it does not add rules.

```
You: I'm using Subagent-Driven Development to execute this plan.

[Setup: worktree verified]
[Read plan file once: docs/superpowers/plans/feature-plan.md]
[Resolve workspace: scripts/sdd-workspace docs/superpowers/plans/feature-plan.md — no ledger inside, fresh start]
[Create todos for all tasks]

Task 1: Hook installation script

[Run task-brief for Task 1; dispatch implementer with brief + report paths + context]

Implementer: "Before I begin - should the hook be installed at user or system level?"

You: "User level (~/.config/superpowers/hooks/)"

Implementer: [Later]
  - Implemented install-hook command
  - Added tests, 5/5 passing
  - Self-review: Found I missed --force flag, added it
  - Committed

[Run review-package PLAN_FILE BASE HEAD; dispatch task reviewer with the printed path]
Task reviewer: Spec ✅ - all requirements met, nothing extra.
  Test Evidence: `npm test test/hooks.test.js` exit 0 — 5 passed / 0 failed
  (base: unknown)

  | Criterion | Test file:line | Assertion |
  |-----------|----------------|-----------|
  | T1.1 Installs the hook at user level | `test/hooks.test.js:12` | the file exists under ~/.config/superpowers/hooks/ after install |
  | T1.2 `--force` overwrites an existing hook | `test/hooks.test.js:31` | second install rewrites the file, exit 0 |
  | T1.3 Refuses to overwrite without `--force` | `test/hooks.test.js:48` | exits non-zero and the file is byte-identical |

  Strengths: Good test coverage, clean. Issues: None. Task quality: Approved.

[Ledger: Task 1: complete (commits a1b2c3d..d4e5f6a, review clean)]

Task 2: Recovery modes

[Run task-brief for Task 2; dispatch implementer with brief + report paths + context]

Implementer: [No questions]
  - Added verify/repair modes
  - 8/8 tests passing
  - Committed

[Run review-package PLAN_FILE BASE HEAD; dispatch task reviewer with the printed path]
Task reviewer: Spec ❌:
  - Missing: Progress reporting (spec says "report every 100 items")
  Test Evidence: `npm test test/recovery.test.js` exit 0 — 8 passed / 0 failed
  (base: 5)

  | Criterion | Test file:line | Assertion |
  |-----------|----------------|-----------|
  | T2.1 Verify mode reports corrupt entries | `test/recovery.test.js:15` | every corrupt id is listed, exit 1 |
  | T2.2 Repair mode rewrites corrupt entries | `test/recovery.test.js:37` | a corrupt entry re-reads as valid after repair |
  | T2.3 Reports every 100 items | — | NONE |

  Issues (Important): Magic number (100)

[Fix round 1: resume the implementer with both findings]
Implementer: Added progress reporting, extracted PROGRESS_INTERVAL constant.
  Re-ran test/recovery.test.js — 10/10 passing. Fix report appended.

[Run review-package PLAN_FILE FIX_BASE HEAD; dispatch scoped re-review]
Re-reviewer: Test Run: `npm test test/recovery.test.js` exit 0 — 10 passed
  (previous: 8). Missing progress reporting — ADDRESSED (src/recovery.js:41).
  Magic number — ADDRESSED (src/recovery.js:7). New breakage: none.
  Verdict: all findings addressed.

[Ledger: Task 2: fix round 1/5 (2 addressed, 0 open; commits d4e5f6a..b7c8d9e)]
[Ledger: Task 2: complete (commits d4e5f6a..b7c8d9e, review clean)]

...

[After all tasks]
[Dispatch superpowers:final-branch-audit with plan + MERGE_BASE..HEAD + ledger, most capable model]
Auditor: PASS — spec docs/superpowers/specs/2026-03-04-feature-design.md
  (exists, committed); traceability 9/9 TRACED (6 AC + 3 IR), no invented scope;
  12/12 criteria DELIVERED, every row cited. No false completions.

[Run review-package PLAN_FILE MERGE_BASE HEAD; dispatch final code-reviewer, most capable model]
Final reviewer: All requirements met. Deferred minors triaged: none block merge.

[Delete this plan's workspace — the record now lives in git]

Done! Using superpowers:finishing-a-development-branch.
```
