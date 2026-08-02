# FIXTURE SPEC — Retry wrapper for the docs-sync check

**This file is a test fixture**, not a real spec, and the feature it describes
is not being built. It is the input handed to the spec reviewer under test.
One of its citations is deliberately wrong; see `README.md` in this directory.

---

## Overview

Wrap `scripts/check-docs-sync.sh` so that transient `git` failures are retried
instead of blocking the commit.

## Acceptance Criteria

- **AC1** — When `git diff --cached` exits non-zero, the check retries up to
  three times before failing the commit.
- **AC2** — The retry delay doubles between attempts, starting at 100ms.
- **AC3** — The two document paths the check compares stay configurable in one
  place, not repeated across the retry logic.

## Implicit Requirements

- **IR1** — A retry that eventually succeeds does not print the failure text,
  so a passing commit stays silent.

## Codebase Findings

- The check declares the two compared paths as constants at the top of the
  script: `scripts/check-docs-sync.sh:14` — `PT="docs/README.pt-BR.md"` — and
  `scripts/check-docs-sync.sh:15` — `EN="docs/README.en.md"`. AC3 keeps these
  as the single place they are named.
- The hook resolves the repository root before delegating:
  `githooks/pre-commit:11` — `repo_root="$(git rev-parse --show-toplevel)"`.
  The retry wrapper runs inside that resolved root.

## External Dependencies

- Retry behavior uses `@acme/retry-client@4.2.0`. The option that bounds
  attempts is `maxAttempts`, and it counts the initial attempt, so
  `maxAttempts: 3` means one request plus two retries — documented at
  `tests/skill-behavior/FIXTURE-vendor-docs.md`, the vendor's API reference for
  v4.2.0. AC1 sets `maxAttempts: 3` on that basis.

## Assumptions to Confirm

- Whether the commit hook runs with a writable temp directory for the retry
  log. Searched `githooks/` and `scripts/` for `TMPDIR`, `mktemp`, and
  `/tmp` (`grep -rn 'TMPDIR\|mktemp\|/tmp' githooks/ scripts/`); no match, so
  nothing in this repo settles it.

## Coverage Map

| Category | State | Where it landed |
|----------|-------|-----------------|
| Functional scope and behavior | Resolved | AC1, AC2 |
| Domain and data model | Clear | No entities — the check is stateless |
| Interaction flow | Resolved | IR1 (silent on eventual success) |
| Non-functional attributes | Resolved | AC2 (backoff bounds the delay) |
| Integrations and external dependencies | Resolved | AC1, via `@acme/retry-client` |
| Edge cases and failures | Outstanding | Behavior when all three attempts fail is unchanged from today; low impact, the commit blocks either way |
| Constraints and tradeoffs | Clear | Single constraint from the request: the hook must stay a single entry point |
| Terminology | Clear | "Attempt" means one `git` invocation, per the vendor's own counting |
| Completion signals | Clear | Every AC and IR states one observable behavior |
| Placeholders and vague adjectives | Clear | None left unquantified |

### Decision record

**Q: How many times should the check retry before it gives up and blocks the commit?**
Recommended: three attempts total — matches the vendor's documented default
counting at `tests/skill-behavior/FIXTURE-vendor-docs.md`.
Source: official documentation of the dependency.
Answer: accepted the recommendation. → AC1
