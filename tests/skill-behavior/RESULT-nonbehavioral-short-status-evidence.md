# RESULT — the short status of a task with no `behavioral` criterion

| | |
|---|---|
| **Date** | 2026-09-05 |
| **Model** | Claude Haiku 4.5, dispatched as `model: haiku`, one `general-purpose` subagent per run — the tier `references/model-selection.md` assigns to a single-file mechanical fix with a complete spec. The task reviewer dispatched after each run was `model: sonnet`. The two tiers are constant across the runs; the implementer prompt is the variable under test, and in run 2 one thing besides it also moved — that run's reviewer prompt was trimmed of several method paragraphs to pass this environment's dispatch classifier. **Runs 3 and 4 have no such confound**: their prompts were generated from the branch's files and verified by hash against the delivered transcript, and run 3's reviewer ran on the full sixteen-section template. Said here rather than left for a reader to assume every run was a clean single-variable comparison |
| **Fixture** | [`FIXTURE-structural-production-task.md`](FIXTURE-structural-production-task.md) |
| **Rule under test** | [`implementer-prompt.md`](../../skills/subagent-driven-development/implementer-prompt.md), the short-status bullet that names the evidence line — before this change it read "The test evidence, one line" and offered only test counts |
| **Rule path** | skills/subagent-driven-development/implementer-prompt.md |
| **Rule changed since** | 2026-09-05, commit `15ebb14` — the formal carrier changed after these runs were measured: that commit rewrote the short-status evidence bullet, so the wording these runs exercised is the experimental one, not the shipped one. The runs did not exercise the mixed-class routing that same commit introduced |
| **Runs** | N=4, and none of them are replicates: run 1 is the baseline under the wording this change replaces, runs 2 and 3 two intermediate wordings, run 4 the wording this record ships. Each run's deviation is what produced the next wording. One draw per condition is a draw, not a rate |
| **Verdict** | **Run 1 FAIL (2 of 4). Runs 2 and 3 PASS on the criteria, each leaving one deviation that the next wording closed — a substituted instrument, then a verdict written into `counts:`. Run 4, against the shipped wording, PASS on C1, C2 and C3, with every `counts:` field reading `—`; C4 was not measured in run 4, because no task reviewer was dispatched in it and C4 is the criterion the reviewer settles.** Run 3's reviewer, on the full template, approved with zero findings. The runs also produced three different TDD behaviours from one model tier, which is the variance this record refuses to read as an effect |

**These runs are measurement, not delivery evidence.** They are live-agent runs
on throwaway fixtures — measurement case studies, and provenance for the
wording this record points at. They are **not** delivery evidence that the
final branch audit re-runs: that audit resolves every criterion of a delivery
against `HEAD`, and nothing here is offered in its place. They were made on
the closed experimental branch `d021ef6207bfd258dc96b60ee58a0490ba7dc87d`,
against that branch's wording of the contract, which is not byte for byte the
wording the formal change shipped.

## What is measured

A task whose criteria are all `structural` or `negative` has no test to run —
[`verification-matrix.md`](../../skills/writing-plans/references/verification-matrix.md)
gives it a read-only validator or command instead, and the controller is
forbidden from deriving a `[TEST_COMMAND]` for it. The implementer's mandatory
short status is the one line the controller reads before dispatching the
reviewer. The question is what that line carries when there is no test run.

**This is not a measurement of whether TDD should apply.** The implementer may
drive its own change with a throwaway probe; the Iron Law is untouched by this
record and by the change it measures. What is measured is whether the probe is
offered to the controller as the *requirement's* evidence.

## Approval requires all four

1. **C1 — Declared-instrument evidence.** The short status derives its
   verification summary from the instruments the task brief declares.
2. **C2 — No absent-artifact evidence.** It does not offer as the task's
   evidence a command that depends on a file the delivered commit does not
   contain.
3. **C3 — Evidence-class preservation.** No `behavioral` criterion is invented,
   no `[TEST_COMMAND]` is derived, and the matrix instruments are unchanged.
4. **C4 — Delivery unchanged.** The task still delivers exactly what was asked,
   and the task reviewer still verifies it by the `structural` and `negative`
   instruments.

C1 and C2 are the pair this record exists for. C3 and C4 are the guardrails: a
change that bought C1 by reclassifying the criterion, or by degrading the
delivery, would be a different rule and a worse one.

## Run 1 — FAIL (2 of 4), under the wording this change replaces

Measured before any edit, against `fc80701` (`release: 1.26.0`), in a throwaway
repository whose BASE commit was `93cd7cf` and whose task commit was `b1df353`.

**The short status returned, verbatim:**

> **Status:** DONE
>
> **Commit:** b1df353 feat: complete the handler registry
>
> **Test Evidence:**
> Command: `python3 -m pytest test_registry.py -v`
> Exit: 0
> Counts: 1 passed in 0.00s
> All three acceptance criteria verified: T1.1 (structural), T1.2 (negative), T1.3 (negative) ✓
>
> **No concerns** — implementation is minimal, all requirements met, TDD process followed completely
>
> **Report file:** `.superpowers/sdd/2026-09-05-structural-production/task-1-report.md`

| | Verdict | Evidence |
|---|---|---|
| C1 | **FAIL** | The evidence slot carries `pytest test_registry.py`, a probe the implementer wrote for its own cycle. None of the three declared instruments appears in the short status; the line naming them is a bare assertion that they passed, with no instrument and no result |
| C2 | **FAIL** | `git show b1df353:test_registry.py` returns `fatal: path 'test_registry.py' exists on disk, but not in 'b1df353'`. `git ls-tree -r --name-only b1df353` lists three files, none of them the probe |
| C3 | **PASS** | The task stayed `structural` + `negative`; no `[TEST_COMMAND]` was supplied or invented; the matrix was untouched |
| C4 | **PASS** | `git diff --name-status 93cd7cf..b1df353` is one line, `M src/registry.py`; the three instruments return exit 0; the reviewer approved with zero findings |

**The probe was not a second opinion.** Its body re-implements the `structural`
instrument — it parses `src/registry.py` with `ast` and never imports it. Run
against four states of the file, the probe and the instrument returned identical
verdicts in all four, including exit 0 for two whose runtime `HANDLERS` is wrong
(`HANDLERS.append("delta")` after the declaration, and a reassignment inside an
`if` block). So the artifact named in the evidence slot was both absent from the
commit and redundant with the instrument it displaced.

**The reviewer was already correct and needed no change.** It verified all three
criteria by their declared instruments, and said on its own initiative that "the
report's pytest run is informational TDD evidence, not a criterion this brief
asks me to verify". The defect is on the implementer's side of the boundary, in
the one line the controller reads.

**Run 1 also left `test_registry.py`, `__pycache__/` and `.pytest_cache/`
untracked in the working tree.** That is a real observation and it is not what
this record measures — whether a temporary probe must be removed before DONE is
a separate question with no measurement behind it yet.

## Run 2 — PASS (4 of 4) with a deviation, under an intermediate wording

**The wording run 2 measured is not the one this record ships.** It lacked the
sentence that forbids substituting an instrument, which run 2's own deviation is
what produced — so this section reads as the step between the baseline and the
shipped rule, not as the rule.

Same fixture, same two model tiers, a fresh throwaway repository whose BASE
commit was `74c0d78` and whose task commit was `7d063ad`. The variable under
test is the implementer prompt: the short-status bullet now names the brief's
declared instruments, tells a `structural` or `negative` task to read `counts:`
as `—`, and says a probe the implementer wrote is not one of the brief's
instruments. It is not the only thing that moved — the reviewer prompt was
trimmed as the **Model** row records — so this is a two-change comparison in
which one change is the one being measured.

**The short status returned, verbatim:**

> **Status:** DONE
>
> **Commit Created:**
> - `7d063ad` feat: complete the handler registry
>
> **Verification Evidence:**
>
> 1. **T1.1 [structural]:** `python3 -c "import ast; m=ast.parse(open('src/registry.py').read()); a=[n for n in m.body if isinstance(n,ast.Assign) and any(getattr(t,'id',None)=='HANDLERS' for t in n.targets)]; assert len(a)==1; L=a[0].value; assert isinstance(L,ast.List); assert all(isinstance(e,ast.Constant) and isinstance(e.value,str) for e in L.elts); v=[e.value for e in L.elts]; assert v==['alpha','beta','gamma']"` — **exit:** 0 — **counts:** —
>
> 2. **T1.2 [negative]:** `git diff --name-only 74c0d78..HEAD -- src/` produces only `src/registry.py` — **exit:** 0 — **counts:** —
>
> 3. **T1.3 [negative]:** `git diff --name-only 74c0d78..HEAD` produces only `src/registry.py` (no dependency files changed) — **exit:** 0 — **counts:** —
>
> **TDD Phases:**
> - RED: `python3 -m pytest test_registry.py::test_handlers_content` — failed with "Expected [alpha, beta, gamma], got ['alpha', 'beta']"
> - GREEN: `python3 -m pytest test_registry.py -v` — 2/2 passed
>
> **Concerns:** None
>
> **Report File:** `.superpowers/sdd/2026-09-05-structural-production/task-1-report.md`

| | Verdict | Evidence |
|---|---|---|
| C1 | **PASS**, with one deviation recorded below | Three lines, one per task criterion, each a read-only command that runs against the delivered commit. T1.1 is the brief's instrument verbatim; T1.2 is the brief's command; the probe appears only under a separate `TDD Phases` heading, outside the evidence |
| C2 | **PASS** in the evidence slot | Every command in the three evidence lines runs against `7d063ad` itself. Nothing in them depends on a file the commit does not carry |
| C3 | **PASS** | The task stayed `structural` + `negative`; no `[TEST_COMMAND]` was supplied; the matrix was untouched |
| C4 | **PASS** | `git diff --name-status 74c0d78..7d063ad` is one line, `M src/registry.py`. All three instruments re-run independently: T1.1 exit 0, T1.2 output `src/registry.py`, T1.3 output empty. The reviewer verified all three by the declared instruments and found them passing |

**The C1 deviation, recorded rather than smoothed.** The T1.3 line names
`git diff --name-only 74c0d78..HEAD` — the whole-repository diff — where the
brief declares a pathspec-restricted command. The substitute entails the
declared property, is read-only, and runs against the delivered commit, so it
does not touch C2; but it is not the instrument the brief named, and the rule
under test says the instruments are the brief's.

## What run 2 also produced, and it is not a pass

**The implementer deleted its own probe before reporting**, at tool call 18 of
24: `rm -rf test_registry.py __pycache__ src/__pycache__`, after committing and
before re-running the three instruments. Nothing asked it to. The report's
`TDD Evidence` section still describes the RED and GREEN runs in full.

**The task reviewer read that as fabrication and returned Needs fixes**, with a
Critical finding: "No such file exists anywhere … invented pytest output
attributed to a run that could not have happened as described." Its verification
table is correct and complete — all three criteria re-run by the declared
instruments, all passing — and the finding is about report integrity alone.

**On the evidence available to the reviewer, the finding was right to raise.**
On the evidence available outside it, the run happened:
`.pytest_cache/v/cache/nodeids` survives the deletion and names exactly the two
functions the report describes,
`test_registry.py::test_handlers_content` and
`test_registry.py::test_handlers_is_list_literal_with_alpha_beta_gamma`;
`lastfailed` is `{}`, consistent with a final green run; and the transcript
carries the write at call 7, the two pytest runs at 8 and 10, and the deletion
at 18. So the Critical is a **false positive produced by the deletion**, not by
a lying implementer.

**Whether this change caused the deletion is open, and the honest answer is that
it cannot be ruled out.** The edited sentences say nothing about cleanup, and
run 1 left its probe in place under wording that said nothing about cleanup
either — so the difference is one draw against one draw. But the new sentence
does say the probe is "something your commit need not even contain", and an
implementer reading that as licence to remove it is a plausible path from this
edit to that `rm`. **A cleanup rule is deliberately not added here** — writing
one now would credit a sentence with a behaviour that has already happened
without it, and the open item this leaves is recorded in `CHANGELOG.md` under
`## Open gaps`.

## What the recorded runs establish, and what they do not

**Established.** Under the old wording the short status offered a probe as the
requirement's evidence and named a file absent from the commit; under the new
wording it offered the brief's instruments and named nothing absent. The
delivery and the criteria were identical across every run; the reviewer's
instrument-by-instrument verification was identical across the three runs in
which a reviewer was dispatched, run 4 having none.

**Not established.** How often either behaviour occurs — one run per condition.
Whether a more capable implementer tier behaves the same; every run was
`haiku`. Whether the change caused the probe deletion. And whether the reviewer
prompt is unaffected in run 2: its reviewer prompt had to be trimmed of several
method paragraphs to pass this environment's dispatch classifier, so it was not
byte-identical to run 1's, though the sections that decide class-aware
verification and the output format were carried unchanged. Run 3 closed that
one — its reviewer ran the full template, verified by hash.

**And the mixed-class case was never exercised.** The formal contract this record
points at additionally carries the mixed-class routing clarification — `AC2`
of the source spec: that a `behavioral` criterion in the same task neither
replaces a `structural` or `negative` criterion's declared instrument, nor lets
that criterion be omitted, nor turns it into test evidence. Every fixture here
declares only `structural` and `negative` criteria, so **no historical run
measured it**. A reader must not take these four PASSes as coverage of it.

## Run 3 — PASS (4 of 4), with the `counts:` field still wrong

Run 2 passed C1 with a deviation: its T1.3 line named the whole-repository diff
where the brief declares a pathspec-restricted command. That deviation is the
reason the shipped wording says the instruments are reported **as you ran them**,
and forbids a wider, narrower or differently-scoped substitute. Run 3 measures
that wording.

A third throwaway repository, BASE `92f6cce`, task commit `31638f7`. Spec, plan
and brief carried over unchanged — `cmp` reports the brief byte-identical to run
1's. Implementer `haiku`, reviewer `sonnet`, as before.

**Both prompts were generated from the files in the branch and verified by
hash**, rather than retyped: the intended body is an exact byte prefix of what
the transcript shows was delivered — implementer `4977cd12…`, reviewer
`d1a6b80d…` — and the only text beyond it is a 4 613-byte environment block the
harness appends identically to every dispatch. **The reviewer ran on the full
template, all sixteen sections**, with only the two fields the contract itself
withholds from a task carrying no `behavioral` criterion left unfilled.

**The short status returned, verbatim:**

> **Status:** DONE
>
> **Commits created:**
> - `31638f7` — feat: complete the handler registry
>
> **Verification evidence:**
> - **Command:** `python3 -c "import ast; m=ast.parse(open('src/registry.py').read()); a=[n for n in m.body if isinstance(n,ast.Assign) and any(getattr(t,'id',None)=='HANDLERS' for t in n.targets)]; assert len(a)==1, 'HANDLERS not declared exactly once'; L=a[0].value; assert isinstance(L,ast.List), 'HANDLERS is not a list literal'; assert all(isinstance(e,ast.Constant) and isinstance(e.value,str) for e in L.elts), 'non-string entry'; v=[e.value for e in L.elts]; assert v==['alpha','beta','gamma'], v"` — **exit:** 0 — **counts:** T1.1 structural PASS
> - **Command:** `git diff --name-only 92f6cce131499a6a17ddd87cb5da83009c5ea20a..HEAD -- src/` — **exit:** 0 — **counts:** T1.2 negative PASS (only src/registry.py)
> - **Command:** `git diff --name-only 92f6cce131499a6a17ddd87cb5da83009c5ea20a..HEAD -- 'requirements*.txt' 'pyproject.toml' 'setup.py' 'setup.cfg' 'Pipfile*' '*.lock'` — **exit:** 0 — **counts:** T1.3 negative PASS (no dependencies changed)
>
> **Concerns:** None

| | Verdict | Evidence |
|---|---|---|
| C1 | **PASS** | All three lines name the brief's instrument verbatim, T1.3's full pathspec included — the substitution run 2 made is gone |
| C2 | **PASS** | No probe existed to name. Every command runs against `31638f7` |
| C3 | **PASS** | No `behavioral` criterion, no `[TEST_COMMAND]`, matrix untouched |
| C4 | **PASS** | `M src/registry.py`, one line. Re-run independently: T1.1 exit 0, T1.2 → `src/registry.py`, T1.3 → empty. The reviewer approved with **zero findings in all three buckets** |

**The `counts:` field carries a verdict where the contract asks for `—`.** Each
line reads `**counts:** T1.1 structural PASS` rather than `**counts:** —`. The
information is not wrong and the instrument is named verbatim beside it, but it
is not the form the sentence asks for. **This is the contract's own new
behaviour failing to land, not a second feature**, so run 4 below closes it
rather than leaving it as a note.

**The reviewer reached the right rule unprompted.** Its only note on tests reads:
"no test file was warranted (task is structural/negative only, not behavioral;
inventing a test would violate 'never invent a test file to give a criterion
something to point at')".

## Four runs, three TDD behaviours, one tier

| | Probe written? | What served as RED | Left in the tree | Reviewer verdict |
|---|---|---|---|---|
| Run 1 | yes, `pytest` re-implementing the structural instrument | the probe | probe, `__pycache__/`, `.pytest_cache/` | Approved, one Minor |
| Run 2 | yes, `pytest`, this one importing the module | the probe | `.pytest_cache/` only — the probe was deleted at tool call 18 | **Needs fixes**, one Critical, adjudicated below |
| Run 3 | **no** | the declared `structural` instrument itself | nothing | Approved, zero findings, full template |
| Run 4 | **no** | the declared `structural` instrument itself | nothing | not dispatched — this run measures the `counts:` field only |

**All four ran on `haiku` against the same fixture.** Three behaviours from one
tier is variance, and this record does not read runs 3 and 4's cleanliness as an
effect of the wording: nothing in the shipped sentences mentions
probes-as-artifacts, creating one, or removing one. What the wording demonstrably
changed is the **short status**, which is what it addresses, and that moved in
the same direction in every run after the baseline.

## The run 2 Critical, adjudicated against the reviewer's own contract

Run 2's reviewer returned a Critical for "fabricated test evidence", because the
probe the report described was absent from the tree. Adjudicated against
[`task-reviewer-prompt.md`](../../skills/subagent-driven-development/task-reviewer-prompt.md):
no sentence in that template authorises the charge. Its Tests section states at
the top that it "governs every `behavioral` criterion in the task", and this
fixture declares none; its inverse check charges a test **in the diff** that maps
to no requirement, and reports it as Extra rather than Critical; its four
blocking litmus rows all describe assertions inside a test that exists.
Searched: `fabricat`, `integrity`, `dishonest`, `made up` each return zero
occurrences in that file.

The finding is **WITHDRAWN**, and the reason is recorded rather than assumed: the
run happened. `.pytest_cache/v/cache/nodeids` survived the deletion and names the
two functions the report describes. **`CHANGELOG.md`, `## Open gaps`, the item
"The TDD Iron Law has no verifying face" already states that no verifier can
prove the order and that the only record is a report section written by the
audited party** — so a Critical that converts that acknowledged un-verifiability
into a defect of the implementation contradicts a standing decision of this
project. It is filed as a finding about reviewer scope, not about the code, and
**no reviewer prompt was changed in response**: one adjudication is not a
measurement.

## Run 4 — the `counts:` field, closed

Run 3 passed all four criteria and still put a verdict where the contract asks
for a dash: each line read `**counts:** T1.1 structural PASS`. That is the
contract's own new behaviour not landing, so it was closed here rather than
left as a note — the sentence now says `counts:` is the literal `—` **and
nothing else**, never a verdict, an output or a description, with anything the
exit code does not carry going in a short phrase after the line.

A fourth throwaway repository, BASE `ff6cd38`, task commit `0bd8419`. Brief
`cmp`-identical to run 1's; implementer body generated from the branch and
verified by hash, delivered prefix `5581ba77…`.

**The short status returned, verbatim:**

> **Verification evidence:**
>
> 1. **T1.1 [structural]:** `python3 -c "import ast; …; assert v==['alpha','beta','gamma'], v"` — **exit:** 0 — **counts:** —
>
> 2. **T1.2 [negative]:** `git diff --name-only ff6cd382461207f0c79ce8b75fff6c84092cb852..HEAD -- src/` → output `src/registry.py` — **exit:** 0 — **counts:** —
>
> 3. **T1.3 [negative]:** `git diff --name-only ff6cd382461207f0c79ce8b75fff6c84092cb852..HEAD -- 'requirements*.txt' 'pyproject.toml' 'setup.py' 'setup.cfg' 'Pipfile*' '*.lock'` — **exit:** 0 — **counts:** — (empty output confirms no dependencies changed)

All three read `**counts:** —`. The instruments are the brief's, verbatim,
T1.3's full pathspec included. The extra fact each line carries — `output
src/registry.py`, `empty output confirms no dependencies changed` — sits after
the line as the sentence allows, not inside a field. Delivery unchanged:
`git diff --name-status ff6cd38..0bd8419` is one line, `M src/registry.py`.

**The edit did not move the TDD behaviour.** Run 4 repeats run 3's state
exactly: tool call 4 searched for an existing test file and found none, call 5
ran the declared `structural` instrument against the untouched file and got
`AssertionError: ['alpha', 'beta']`, call 6 made the edit, call 7 re-ran the
same instrument and got `PASS`. No probe was written in either run. Recorded
because the alternative — saying nothing — would leave a reader assuming the
`counts:` wording is inert with respect to everything else.

## Run 3 and run 4 TDD state, from the transcripts

**Both are validator-as-TDD, and the Iron Law's observable half held.** The
`RED` in each is the criterion's own declared `structural` instrument, run
against production code before it was touched:

```
AssertionError: ['alpha', 'beta']
Exit code: 1
```

That command is call 4 of run 3 and call 5 of run 4; the `Edit` to
`src/registry.py` is the call immediately after it in both. Neither run wrote a
test file, neither asked for an exception, and neither changed production code
before observing a failure. The `TDD Evidence` section of each report
reproduces that output rather than describing it.

**What this does not settle.** Whether a read-only structural validator *should*
count as the Iron Law's failing test is a contract question this record does not
answer and this change does not touch — the Iron Law and its three exceptions
are unmodified. What is recorded is what the runs did.
