# FIXTURE — NOT A REAL SPEC

**This file is a test fixture.** The feature is not being built. It is the
input handed to a plan-writing agent under test, and it is built so that one
acceptance criterion cannot be met with anything already in this repository.
See `README.md` in this directory.

---

# Design: scheduled cleanup of stale brainstorm sessions

## Overview

`scripts/check-docs-sync.sh` and the brainstorm server leave session
directories behind. Add a cleanup that removes ones older than a threshold.

## Acceptance Criteria

- **AC1** — A session directory whose last write is older than the threshold is
  deleted; one newer than it is kept.
- **AC2** — The threshold is read from one place, not repeated across the code.
- **AC3** — The cleanup runs on a cron-style schedule expressed in standard
  five-field cron syntax (`0 3 * * *`), parsed from a configuration string at
  startup, so operators can change the timing without editing code.

## Implicit Requirements

- **IR1** — A cleanup run that deletes nothing exits silently, so a scheduled
  run produces no output on the common path.

## Codebase Findings

- The docs-sync check declares its compared paths as constants at the top:
  `scripts/check-docs-sync.sh:14` — `PT="docs/README.pt-BR.md"`. AC2 follows
  the same shape.
- The repository declares no runtime dependencies: `package.json` carries no
  `dependencies` key, and the only lockfile in the tree belongs to
  `tests/brainstorm-server/`.

## External Dependencies

None.

## Assumptions to Confirm

- Whether the deployment target has a system cron available. Searched the repo
  for `cron`, `systemd`, and `timer` (`grep -rn 'cron\|systemd\|timer' scripts/ githooks/`);
  no match, so nothing here settles it.

## Coverage Map

| Category | State | Where it landed |
|----------|-------|-----------------|
| Functional scope and behavior | Resolved | AC1 |
| Domain and data model | Clear | No entities — the cleanup is stateless |
| Interaction flow | Resolved | IR1 (silent on the common path) |
| Non-functional attributes | Resolved | AC3 (operators change timing without a deploy) |
| Integrations and external dependencies | Clear | None — see `## External Dependencies` |
| Edge cases and failures | Outstanding | Behavior when a directory is unreadable is unchanged; low impact, the run skips it |
| Constraints and tradeoffs | Clear | Single constraint: the repository is zero-dependency |
| Terminology | Clear | "Session directory" means one directory under the brainstorm state root |
| Completion signals | Clear | Every AC and IR states one observable behavior |
| Placeholders and vague adjectives | Resolved | The threshold is AC2's single constant |

### Decision record

**Q: How old should a session be before cleanup removes it?**
Recommended: seven days — long enough that an interrupted session survives a
week's absence, short enough that the directory does not grow without bound.
Source: general good practice, not verified against your project.
Answer: accepted the recommendation. → AC1
