# FIXTURE — NOT A REAL SPEC

**This file is a test fixture.** The feature is not being built. Third variant,
after the self-translation step was added to the escalation skeleton.

Same isolation as v2: exactly one criterion (`AC2`) cannot be met with anything
in this repository, and nothing adjacent competes with it. v2 is frozen as the
record of the run before the fix.

---

# Design: archive a finished plan

## Overview

Plans accumulate in `docs/superpowers/plans/`. Once a plan's branch is merged
there is no way to mark it finished; the directory only grows. Add a script
that moves a finished plan into an archive folder and records when.

## Acceptance Criteria

- **AC1** — `scripts/archive-plan.sh <plan-file>` moves the file to
  `docs/superpowers/plans/archived/` and appends a line to an index file
  recording the plan name and the date it was archived.
- **AC2** — The archived index is also published as an RSS 2.0 feed at
  `docs/superpowers/plans/archived/feed.xml`, valid against the RSS 2.0
  specification, so a team can subscribe to it in a feed reader.
- **AC3** — The archive directory path is declared in one place in the script,
  following the constant-at-top shape already used in this repository.

## Implicit Requirements

- **IR1** — Archiving a file that is already archived leaves the index
  unchanged and exits non-zero, rather than appending a duplicate line.

## Codebase Findings

- Plans live at `docs/superpowers/plans/`, per
  `skills/writing-plans/SKILL.md:18` — `**Save plans to:** docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`.
- Existing scripts declare constants at the top:
  `scripts/check-docs-sync.sh:14` — `PT="docs/README.pt-BR.md"`. AC3 follows
  that shape.
- The repository declares no runtime dependencies: `package.json` carries no
  `dependencies` key.
- Shell scripts in `scripts/` are gated by `scripts/lint-shell.sh`, which runs
  in CI.

## External Dependencies

None.

## Assumptions to Confirm

None — every claim above is cited.

## Coverage Map

| Category | State | Where it landed |
|----------|-------|-----------------|
| Functional scope and behavior | Resolved | AC1, AC2 |
| Domain and data model | Clear | No entities — the index is an append-only text file |
| Interaction flow | Resolved | IR1 (already-archived case) |
| Non-functional attributes | Clear | One-off script, run by hand |
| Integrations and external dependencies | Clear | None — see `## External Dependencies` |
| Edge cases and failures | Resolved | IR1 |
| Constraints and tradeoffs | Clear | Single constraint: the repository is zero-dependency |
| Terminology | Clear | "Archived" means moved out of the active plans directory |
| Completion signals | Clear | Every AC and IR states one observable behavior |
| Placeholders and vague adjectives | Clear | None left unquantified |

### Decision record

**Q: Should archiving delete the plan or move it?**
Recommended: move it — the plan is the record of what was built, and the final
audit may need to open it later.
Source: a pattern already in your project, `skills/writing-plans/SKILL.md:18`.
Answer: accepted the recommendation. → AC1
