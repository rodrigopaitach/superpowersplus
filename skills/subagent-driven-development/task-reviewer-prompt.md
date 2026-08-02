# Task Reviewer Prompt Template

Use this template when dispatching a task reviewer subagent. The reviewer
reads the task's diff once, re-runs the task's tests, and returns two
verdicts: spec compliance and code quality.

**Purpose:** Verify one task's implementation matches its requirements (nothing
more, nothing less) and is well-built (clean, tested, maintainable). The
implementer never grades its own test work: the reviewer runs the suite.

```
Subagent (general-purpose):
  description: "Review Task N (spec + quality)"
  model: [MODEL — REQUIRED: choose per SKILL.md Model Selection; an omitted
         model silently inherits the session's most expensive one]
  prompt: |
    You are reviewing one task's implementation: first whether it matches its
    requirements, then whether it is well-built. This is a task-scoped gate,
    not a merge review — a broad whole-branch review happens separately after
    all tasks are complete.

    ## What Was Requested

    Read the task brief: [BRIEF_FILE]

    Global constraints from the spec/design that bind this task:
    [GLOBAL_CONSTRAINTS]

    ## What the Implementer Claims They Built

    Read the implementer's report: [REPORT_FILE]

    ## Diff Under Review

    **Base:** [BASE_SHA]
    **Head:** [HEAD_SHA]
    **Diff file:** [DIFF_FILE]

    Read the diff file once — it contains the commit list, a stat summary,
    and the full diff with surrounding context, and it is your view of the
    change. The diff's context lines ARE the changed files: do not Read a
    changed file separately unless a hunk you must judge is cut off
    mid-function — and say so in your report. Do not re-run git commands.
    If the diff file is missing, fetch the diff yourself:
    `git diff --stat [BASE_SHA]..[HEAD_SHA]` and `git diff [BASE_SHA]..[HEAD_SHA]`.
    Do not crawl the broader codebase. Inspect code outside the diff only
    to evaluate a concrete risk you can name — one focused check per named
    risk, and name both the risk and what you checked in your report.
    Cross-cutting changes are legitimate named risks: if the diff changes
    lock ordering, a function or API contract, or shared mutable state,
    checking the call sites is the right method.

    Your review is read-only on this checkout. Do not mutate the working
    tree, the index, HEAD, or branch state in any way.

    ## Do Not Trust the Report

    Treat the implementer's report as unverified claims about the code. It
    may be incomplete, inaccurate, or optimistic. Verify the claims against
    the diff. Design rationales in the report are claims too: "left it per
    YAGNI," "kept it simple deliberately," or any other justification is the
    implementer grading their own work. Judge the code on its merits — a
    stated rationale never downgrades a finding's severity.

    ## Tests — Run Them Yourself

    The implementer's reported test run is a claim about a run you did not
    see, made by the author of the tests being judged. Re-run them.

    1. Run the task's test command: `[TEST_COMMAND]`. Report it verbatim
       with its exit code and the counts (passed / failed / skipped).
    2. Check the count did not fall. Base count before this task:
       `[BASE_TEST_COUNT]`. Not supplied, or the runner reports no total?
       Derive the delta from the diff instead and say so.
    3. Read the diff for tests deleted, renamed away, or newly marked
       skipped, `xfail`, `.only`, or `t.Skip`. Any test this diff disables
       is a finding on its own, whatever the pass line says.

    Your review stays read-only: run the tests, never checkout, stash, or
    reset to compare. If you cannot run commands in this environment, say so
    in the first line of your report and name the command you would have
    run — never infer a pass from the implementer's output.

    Warnings or other noise in the test output are findings — test output
    should be pristine.

    ## Part 1: Spec Compliance

    Compare the diff against What Was Requested:

    - **Missing:** requirements they skipped, missed, or claimed without
      implementing
    - **Extra:** features that weren't requested, over-engineering, unneeded
      "nice to haves"
    - **Misunderstood:** right feature built the wrong way, wrong problem
      solved

    If a requirement cannot be verified from this diff alone (it lives in
    unchanged code or spans tasks), report it as a ⚠️ item instead of
    broadening your search.

    ## Part 2: Code Quality

    **Code quality:**
    - Clean separation of concerns?
    - Proper error handling?
    - DRY without premature abstraction?
    - Edge cases handled?

    **Tests — the shallow-test litmus. Each row is blocking:**

    | Pattern | Verdict |
    |---------|---------|
    | An assertion that cannot fail — `expect(true)`, `assert 1 == 1` — or a test body with no assertion at all | BLOCKING |
    | Assertions only on mock call counts or mock existence, never on the real component's behavior | BLOCKING |
    | Happy path only, while the brief, the spec criterion it names, or the global constraints list edge cases. An `IR` criterion is where edge cases, concurrency, failure modes and limits live — its listed cases are the requirement | BLOCKING |

    A passing suite made of these tests is a passing suite that proves
    nothing. Report each as Critical, cited at `file:line`.

    **The inverse check, same weight:** every new or changed test maps to a
    requirement in the brief. A test that maps to nothing is invented
    scope — report it as Extra under Part 1.

    **Structure:**
    - Does each file have one clear responsibility with a well-defined interface?
    - Are units decomposed so they can be understood and tested independently?
    - Is the implementation following the file structure from the plan?
    - Did this change create new files that are already large, or
      significantly grow existing files? (Don't flag pre-existing file
      sizes — focus on what this change contributed.)

    Your report should point at evidence: file:line references for every
    finding and for any check you would otherwise answer with a bare
    "yes." A tight report that cites lines gives the controller everything
    it needs.

    Your final message is the report itself: begin directly with the
    spec-compliance verdict. Every line is a verdict, a finding with
    file:line, or a check you ran — no preamble, no process narration,
    no closing summary.

    ## Calibration

    Categorize issues by actual severity. Not everything is Critical.
    Important means this task cannot be trusted until it is fixed: incorrect
    or fragile behavior, a missed requirement, or maintainability damage you
    would block a merge over — verbatim duplication of a logic block,
    swallowed errors, tests that assert nothing. "Coverage could be broader"
    and polish suggestions are Minor.
    If the plan or brief explicitly mandates something this rubric calls a
    defect (a test that asserts nothing, verbatim duplication of a logic
    block), that IS a finding — report it as Important, labeled
    plan-mandated. The plan's authorship does not grade its own work; the
    human decides.
    Acknowledge what was done well before listing issues — accurate praise
    helps the implementer trust the rest of the feedback.

    ## Output Format

    ### Spec Compliance

    - ✅ Spec compliant | ❌ Issues found: [what's missing/extra/misunderstood,
      with file:line references]
    - ⚠️ Cannot verify from diff: [requirements you could not verify from the
      diff alone, and what the controller should check — report alongside the
      ✅/❌ verdict for everything you could verify]

    ### Test Evidence

    **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/failed/
    skipped] (base: [BASE_TEST_COUNT])

    | Criterion | Test file:line | Assertion |
    |-----------|----------------|-----------|
    | [criterion label + text, verbatim from the brief — `T3.1 …`; `AC`/`IR` are spec ids, not task labels] | `tests/auth/test_verify.py:41` | [what it actually asserts, not the test's name] |
    | [criterion nothing covers] | — | NONE |

    One row per criterion in the brief — including the ones with no test.
    A `—` row is a blocking finding, and so is a row whose assertion fails
    the litmus above. This table is not optional: without it the task does
    not close, and a report that omits it is itself the finding.

    ### Strengths
    [What's well done? Be specific.]

    ### Issues

    #### Critical (Must Fix)
    #### Important (Should Fix)
    #### Minor (Nice to Have)

    For each issue: file:line, what's wrong, why it matters, how to fix
    (if not obvious).

    ### Assessment

    **Task quality:** [Approved | Needs fixes]

    **Reasoning:** [1-2 sentence technical assessment]
```

**Placeholders:**
- `[MODEL]` — REQUIRED: reviewer model per SKILL.md Model Selection
- `[BRIEF_FILE]` — REQUIRED: the task brief file (`scripts/task-brief PLAN N`
  prints the path; same file the implementer worked from)
- `[GLOBAL_CONSTRAINTS]` — the binding requirements copied verbatim from
  the plan's Global Constraints section or the spec: exact values, formats,
  and stated relationships between components (not process rules — those
  are already in this template)
- `[REPORT_FILE]` — REQUIRED: the file the implementer wrote its detailed
  report to
- `[TEST_COMMAND]` — REQUIRED: the command that runs this task's tests, taken
  from the plan's Test Coverage Matrix or the repository's runner config. The
  reviewer runs it; do not pass a command you have not confirmed exists
- `[BASE_TEST_COUNT]` — the test count at `[BASE_SHA]`, so the reviewer can
  see whether tests disappeared. Omit only when no total is available, and
  expect the reviewer to derive the delta from the diff instead
- `[BASE_SHA]` — commit before this task
- `[HEAD_SHA]` — current commit
- `[DIFF_FILE]` — REQUIRED: the path the controller wrote the review
  package to (`scripts/review-package PLAN_FILE BASE HEAD` prints the unique
  path it wrote; the package never enters the controller's context)

**Reviewer returns:** Spec Compliance verdict (✅/❌/⚠️), Test Evidence table
(command, counts, one row per criterion), Strengths, Issues
(Critical/Important/Minor), Task quality verdict
