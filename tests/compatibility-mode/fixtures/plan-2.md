# Case 2 — legacy spec, historical matrix, a read-only command in the Test cell

The shape a historical row takes when its `Test` cell holds a read-only command
instead of a test id. It is not promoted to `structural` by the fallback, and it
gains no invented test.

**Source spec:** `spec-legacy.md`

## Test Coverage Matrix

| Criterion | Spec criterion | Test type | Layer | Test |
|---|---|---|---|---|
| T1.1 | AC1 | grep | docs | grep -c 'the thing' docs/thing.md returns 1 |
