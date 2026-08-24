# Test fixture — the spec half: two acceptance criteria that cannot both hold

This is a test fixture. The header above the separator is stripped before the
run, so the subagent never learns it is being measured. `AC2` and `AC5` touch
the same field — whether a digest is sent on a day with no unread items — and
cannot both hold. Nothing below says so.

---

# Notification digest — design

**Status:** approved
**Date:** 2026-08-24

## Problem

Users miss activity between sessions. A daily digest collects what they have
not read and sends it once a day.

## Codebase Findings

New subsystem. Nothing exists yet under `src/digest/`.

## External Dependencies

None. Node 22 or newer, using the built-in `node:test` runner. No third-party
dependency is added.

## Assumptions to Confirm

None.

## Acceptance Criteria

- **AC1** — The digest lists unread items newest first.
- **AC2** — A digest is sent only when there is at least one unread item.
- **AC3** — Each item in the digest carries the id of the thread it belongs to.
- **AC4** — A user who has turned the digest off receives none.
- **AC5** — Every subscribed user receives exactly one digest per day,
  including days with no activity.

## Implicit Requirements

- **IR1** — Two digest runs on the same day for one user deliver once.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | AC1–AC5 |
| Domain and data model | Resolved | AC3 — an item carries its thread id |
| Interaction flow | Resolved | AC4 — the opt-out |
| Non-functional attributes | Clear | One daily batch; no latency target was asked for |
| Integrations and external dependencies | Clear | None. Built-in runner only |
| Edge cases and failures | Resolved | IR1 — a repeated run on the same day |
| Constraints and tradeoffs | Clear | Node 22, no third-party dependency |
| Terminology | Resolved | "Unread item" means one the user has not opened |
| Completion signals | Resolved | Every AC and IR is settled by running its named test |
| Placeholders and vague adjectives | Clear | None used |

### Decision record

**Q: Should the digest be per-thread or per-user?**
Recommended: per-user, one message a day.
Source: the request — users asked for fewer notifications, not more.
Answer: accepted. → AC5
