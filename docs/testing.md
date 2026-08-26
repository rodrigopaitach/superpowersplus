# Testing superpowersplus

> Derived from the original Superpowers testing guide by Jesse Vincent (Prime Radiant), under the MIT license.

Two distinct kinds of tests. Only one of them lives in this repository:

- **`tests/`** — does the plugin's non-LLM code work? Bash + node + python
  checks for manifests, plugin loading, hooks, sync scripts, and skill
  behavior. This is what you run and what CI runs.
- **`evals/`** — do agents behave correctly on real LLM sessions? **Not in this
  checkout.** The eval harness is a separate repository, cloned into `evals/`
  for local use and excluded by `.gitignore:13`. Nothing here depends on it, so
  a missing `evals/` breaks nothing.

## Plugin tests

Every directory under `tests/` is a suite. There is no single entry point and no
`npm test` at the repository root — each suite is invoked the way its own
directory expects, which is `run-tests.sh` for some and a named `test-*.sh` for
others. `.github/workflows/ci.yml` holds the exact command for every one of
them and is the reference when you are unsure.

**CI runs every static suite on every push** — every directory under `tests/`
except the three below. Neither the count nor the list is written here: both
age the moment a suite is added, and a list of names is a count wearing a
disguise. `ls -d tests/*/` and `.github/workflows/ci.yml` answer it today, and
a suite in the first without a step in the second is the defect to look for.

**Three stay out**, because each dispatches a live agent — that costs tokens
and is non-deterministic, so re-running one is a human decision:

- `tests/claude-code/` — agent-behavior tests driving Claude Code sessions.
- `tests/explicit-skill-requests/` — multi-turn and skill-name-prompted tests.
- `tests/skill-behavior/` — the adversarial records: a `FIXTURE-*.md` per
  rule, a `RESULT-*.md` per run, a `spec-under-test.md` carrying a fixture into
  a reviewer, and the directory's own `README.md`, which is the entry point —
  read it before adding anything. **How many of each is not written here**: the
  counts said five and six while `ls tests/skill-behavior/` answered seven and
  eight, which is what a number in a document does when nobody re-runs it. A
  rule can hold more than one result: the escalation format has one per run,
  and the inline resume route has a single file covering its runs.

  **These never run in CI, and that is deliberate.** Each one dispatches a
  live agent: real tokens, minutes of wall clock, and a non-deterministic
  answer. A suite like that on every push is a suite people learn to ignore
  when it goes red for the third time on nothing. **What CI checks is the
  integrity of the records** — `check-skill-behavior-records.sh` verifies that
  every `FIXTURE-*` says in its own text that it is a test fixture, so nobody
  mistakes one for a real document, and that every `RESULT-*` carries a
  **Date** row, a **Model** row, a **Verdict** row, at least one per-criterion
  `PASS`/`FAIL`/`PARTIAL`, a **Rule path** row and a **Runs** row. A record
  missing those cannot be compared against a later run, which is the only thing
  it exists for.
  **Re-running one is a human decision**, taken when the rule under test
  changes — not something that happens on a push. **Declining it is no longer
  silent:** the same script asks `git log` for the newest edit to each
  **Rule path** and fails when the measured text moved after the measurement
  unless the record carries a dated **Rule changed since** row. It never asks
  for the re-run — noticing costs a `git log`, re-measuring costs an agent.

A suite CI does not run blocks nothing. If you add a suite, add its CI step.

## Gates CI runs beyond the suites

The same scripts the pre-commit hook runs, applied to the pushed range:
`lint-shell.sh`, `check-docs-sync.sh`, `check-changelog.sh`,
`check-frozen-history.sh`, `check-links.sh`, `check-skill-size.sh`,
`check-evidence-line.sh`, `check-escalation-shape.sh`, `check-no-dispatch.sh`
and `check-skill-behavior-records.sh`.

This list is a condition, not a tally: it is what
`grep -oE 'scripts/check-[a-z-]+\.sh|scripts/lint-shell\.sh' .github/workflows/ci.yml`
answers today. It stood at seven while the workflow ran ten — the three added
with the review gates were never written in — which is the drift the paragraph
below deliberately avoids for the suites.

## Two caveats that have cost debugging time

- **`tests/codex/test-package-codex-plugin.sh` only tells the truth on a clean
  tree.** The packager builds its archive from a git ref while the test reads
  its expected values from the working tree, so anything uncommitted makes the
  two disagree and fails a test with no defect present. Run it after
  committing.
- **Do not edit an upstream test to assert the opposite of what it asserts.** A
  test rewritten to match this project stops detecting the upstream's changes.
