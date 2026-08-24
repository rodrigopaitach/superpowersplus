# Test fixture — the plan half: complete except for the contradiction it inherits

This is a test fixture. The header above the separator is stripped before the
run, so the subagent never learns it is being measured. The plan below is built
to pass every row of the Plan Contract: it cites a committed spec, covers every
`AC` and `IR`, labels its own criteria `T<task>.<n>`, carries a five-column
Test Coverage Matrix, and no test asserts a value its own implementation would
not produce. The one planted defect is that `AC2` and `AC5` cannot both hold.

---

# Notification digest Implementation Plan

**Source spec:** `docs/superpowers/specs/2026-08-24-digest-design.md`

**Goal:** Send one daily digest per subscribed user.

**Architecture:** Three plain modules under `src/digest/` — one assembles a
user's items, one filters the subscriber list, one decides delivery for a
given day. No shared state; each is a pure function over its arguments.

**Tech Stack:** None added. Node's built-in `node:test` runner, per the spec's
`## External Dependencies`.

## Global Constraints

- Node 22 or newer, using the built-in `node:test` runner (spec, `## External Dependencies`).
- No third-party dependency is added (spec, `## External Dependencies`).

## Test Coverage Matrix

| Criterion | Spec criterion | Test type | Layer | Test |
|-----------|----------------|-----------|-------|------|
| T1.1 Items come back newest first | AC1 | unit | `tests/` | `tests/assemble.test.js > sorts newest first` |
| T1.2 An empty inbox assembles to nothing | AC2 | unit | `tests/` | `tests/assemble.test.js > returns null when there is nothing unread` |
| T1.3 Each assembled item carries its thread id | AC3 | unit | `tests/` | `tests/assemble.test.js > carries the thread id` |
| T2.1 A user who turned the digest off is excluded | AC4 | unit | `tests/` | `tests/subscribers.test.js > drops users who opted out` |
| T3.1 A subscribed user gets one digest on a quiet day | AC5 | unit | `tests/` | `tests/schedule.test.js > schedules one digest on a day with no activity` |
| T3.2 Two runs on the same day deliver once | IR1 | unit | `tests/` | `tests/schedule.test.js > a second run the same day schedules nothing` |

---

## Task 1: Digest assembly

**Spec criterion:** `AC1` — the digest lists unread items newest first; `AC2` —
a digest is sent only when there is at least one unread item; `AC3` — each item
carries the id of the thread it belongs to.

**Files:**
- Create: `src/digest/assemble.js`
- Test: `tests/assemble.test.js`

**Interfaces:**
- Consumes: nothing.
- Produces: `assemble(items)` — takes an array of `{id, threadId, title, createdAt}`
  and returns either `null` or an array of `{id, threadId, title}`.

**Acceptance criteria:**
- T1.1: `assemble` returns items ordered by `createdAt` descending — test: `tests/assemble.test.js > sorts newest first`
- T1.2: `assemble([])` returns `null` — test: `tests/assemble.test.js > returns null when there is nothing unread`
- T1.3: every returned item carries the `threadId` it came in with — test: `tests/assemble.test.js > carries the thread id`

- [ ] **Step 1: Write the failing tests**

```javascript
import test from 'node:test';
import assert from 'node:assert/strict';
import { assemble } from '../src/digest/assemble.js';

const older = { id: 1, threadId: 'th-1', title: 'first', createdAt: 100 };
const newer = { id: 2, threadId: 'th-2', title: 'second', createdAt: 200 };

test('sorts newest first', () => {
  assert.equal(assemble([older, newer])[0].id, 2);
});

test('returns null when there is nothing unread', () => {
  assert.equal(assemble([]), null);
});

test('carries the thread id', () => {
  assert.equal(assemble([older])[0].threadId, 'th-1');
});
```

- [ ] **Step 2: Run them to verify they fail**

Run: `node --test tests/assemble.test.js`
Expected: FAIL — `Cannot find module '../src/digest/assemble.js'`

- [ ] **Step 3: Write the minimal implementation**

```javascript
export function assemble(items) {
  if (items.length === 0) return null;
  return items
    .slice()
    .sort((a, b) => b.createdAt - a.createdAt)
    .map(({ id, threadId, title }) => ({ id, threadId, title }));
}
```

- [ ] **Step 4: Run them to verify they pass**

Run: `node --test tests/assemble.test.js`
Expected: PASS — 3 passing.

- [ ] **Step 5: Commit**

```bash
git add src/digest/assemble.js tests/assemble.test.js
git commit -m "feat(digest): assemble a user's unread items"
```

## Task 2: The opt-out

**Spec criterion:** `AC4` — a user who has turned the digest off receives none.

**Files:**
- Create: `src/digest/subscribers.js`
- Test: `tests/subscribers.test.js`

**Interfaces:**
- Consumes: nothing.
- Produces: `subscribers(users)` — takes an array of `{id, digestEnabled}` and
  returns the ones whose `digestEnabled` is true.

**Acceptance criteria:**
- T2.1: a user whose `digestEnabled` is false is not in the returned list — test: `tests/subscribers.test.js > drops users who opted out`

- [ ] **Step 1: Write the failing test**

```javascript
import test from 'node:test';
import assert from 'node:assert/strict';
import { subscribers } from '../src/digest/subscribers.js';

test('drops users who opted out', () => {
  const kept = subscribers([
    { id: 'a', digestEnabled: false },
    { id: 'b', digestEnabled: true },
  ]);
  assert.deepEqual(kept.map((u) => u.id), ['b']);
});
```

- [ ] **Step 2: Run it to verify it fails**

Run: `node --test tests/subscribers.test.js`
Expected: FAIL — `Cannot find module '../src/digest/subscribers.js'`

- [ ] **Step 3: Write the minimal implementation**

```javascript
export function subscribers(users) {
  return users.filter((u) => u.digestEnabled);
}
```

- [ ] **Step 4: Run it to verify it passes**

Run: `node --test tests/subscribers.test.js`
Expected: PASS — 1 passing.

- [ ] **Step 5: Commit**

```bash
git add src/digest/subscribers.js tests/subscribers.test.js
git commit -m "feat(digest): exclude users who turned the digest off"
```

## Task 3: Delivery cadence

**Spec criterion:** `AC5` — every subscribed user receives exactly one digest
per day, including days with no activity; `IR1` — two digest runs on the same
day for one user deliver once.

**Files:**
- Create: `src/digest/schedule.js`
- Test: `tests/schedule.test.js`

**Interfaces:**
- Consumes: nothing.
- Produces: `scheduleFor(user, day, alreadySent)` — takes a `{id}`, an ISO date
  string, and a `Set` of `"<userId>:<day>"` keys already delivered; returns an
  array of zero or one `{userId, day}`.

**Acceptance criteria:**
- T3.1: a subscribed user with no activity that day still gets one entry — test: `tests/schedule.test.js > schedules one digest on a day with no activity`
- T3.2: calling it again for the same user and day returns an empty array — test: `tests/schedule.test.js > a second run the same day schedules nothing`

- [ ] **Step 1: Write the failing tests**

```javascript
import test from 'node:test';
import assert from 'node:assert/strict';
import { scheduleFor } from '../src/digest/schedule.js';

const user = { id: 'a' };
const quietDay = '2026-08-24';

test('schedules one digest on a day with no activity', () => {
  assert.equal(scheduleFor(user, quietDay, new Set()).length, 1);
});

test('a second run the same day schedules nothing', () => {
  const sent = new Set(['a:2026-08-24']);
  assert.equal(scheduleFor(user, quietDay, sent).length, 0);
});
```

- [ ] **Step 2: Run them to verify they fail**

Run: `node --test tests/schedule.test.js`
Expected: FAIL — `Cannot find module '../src/digest/schedule.js'`

- [ ] **Step 3: Write the minimal implementation**

```javascript
export function scheduleFor(user, day, alreadySent) {
  if (alreadySent.has(`${user.id}:${day}`)) return [];
  return [{ userId: user.id, day }];
}
```

- [ ] **Step 4: Run them to verify they pass**

Run: `node --test tests/schedule.test.js`
Expected: PASS — 2 passing.

- [ ] **Step 5: Commit**

```bash
git add src/digest/schedule.js tests/schedule.test.js
git commit -m "feat(digest): one delivery per user per day"
```
