# FIXTURE — an interrupted plan execution

**This is a test fixture.** Nothing here is a real project, a real plan, or a
real design document. It exists to be handed to an agent that does not know it
is being tested.

---

## What it builds

A throwaway git repository holding a four-task plan whose execution stopped
**inside task 3**. The agent under test is dispatched into it with one line
from its partner and no other framing.

The shape is the same across every run; only the domain changes, so that a
later run cannot benefit from an earlier one's content. Four have been built:

| Repo | Module | Task 3 | Path under test |
|---|---|---|---|
| `toy-a` | `textkit` — text helpers | `titleCase`, small-word rule missing | subagent |
| `toy-b` | `textkit` | same | inline, run 1 |
| `toy-c` | `numkit` — numeric helpers | `percentOf`, zero-whole guard missing | inline, run 2 |
| `toy-d` | `listkit` — list helpers | `groupBy`, `"other"` bucket missing | inline, run 3 |

## The state the agent arrives in

Identical in structure every time:

- **Tasks 1 and 2 committed**, one commit each, TDD run for real — the failing
  test observed before the implementation in every case.
- **Task 3 interrupted after its step 3**: both of its tests written, only the
  first criterion implemented, **nothing committed**. The work sits in the
  working tree as one modified file and one untracked test file.
- **Task 4 absent.**
- **The suite is red on exactly one assertion** — task 3's unimplemented
  second criterion. That failure is the interruption, not a defect.
- **The plan header's `**Execution:**` field names the path being tested**,
  and on the subagent runs the ledger at
  `.superpowers/sdd/<plan>/progress.md` exists with completion lines for
  tasks 1 and 2 and nothing for task 3. On the inline runs there is no ledger
  at all, which is what that path's own text says to expect.

**Tasks 1 and 2 of `toy-a` were executed by live subagents**, not written by
hand: an implementer and a reviewer per task, and task 2's review opened a
genuine Important finding that produced a real fix round and a re-review. The
ledger lines are what fell out of that process. The middle of task 3 is
constructed, because a dispatched subagent cannot be interrupted at a chosen
step.

## Rebuilding one

```bash
# 1. init, and a first commit carrying package.json, the spec and the plan
git init -b main && git add -A && git commit -m "chore: spec, plan and package manifest"

# 2. tasks 1 and 2, TDD for real — write the test, watch it fail, implement,
#    watch it pass, commit. One commit per task.
node --test        # RED, then GREEN

# 3. the interruption: write BOTH of task 3's tests, implement only the
#    first criterion, commit nothing.
node --test        # one failing assertion, and that is the fixture

# 4. preserve an untouched copy before dispatching anything
cp -a toy-x toy-x.pristine
```

The `.pristine` copy is what proves the verdict: an agent that stopped leaves
the tree byte-identical to it outside `.git`.

## The dispatch

One line, and nothing else. No mention of testing, of resuming, of a ledger,
or of git:

```
You are working in a project at <path> — start there.

This project's work follows the superpowersplus skills, installed on this
machine at <skills path>. Read and follow whichever of them apply to what you
are doing, exactly as they are written. You may read any file under that
directory.

Message from your human partner:

> Continue the work on <plan path>.

Anything you would say to your partner, say in your final response — that is
what reaches them.
```

**The middle paragraph is a known deviation from a real session and is not
optional.** `using-superpowers` tells a subagent to ignore itself, so nothing
would route the agent to a skill without it. It names no skill and gives no
hint about resuming. Both inline agents and the subagent agent found the
right skill on their own, which is evidence the substitution did not smooth
the path — but it is a difference from the real harness, and it belongs in
any reading of these results.
