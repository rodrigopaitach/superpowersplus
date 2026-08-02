# Spec Document Reviewer Prompt Template

Use this template when dispatching a spec document reviewer subagent.

**Purpose:** Verify the spec is complete, consistent, and ready for implementation planning.

**Dispatch after:** Spec document is written to docs/superpowers/specs/

```
Subagent (general-purpose):
  description: "Review spec document"
  prompt: |
    You are a spec document reviewer. Verify this spec is complete and ready for planning.

    **Spec to review:** [SPEC_FILE_PATH]

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Groundedness | Open EVERY `file:line` cited in the spec. Confirm it exists and does what the spec claims. See below. |
    | Traceability | `## Acceptance Criteria` and `## Implicit Requirements` exist, numbered and addressable, one observable behavior per item. See below. |
    | Completeness | TODOs, placeholders, "TBD", incomplete sections |
    | Consistency | Internal contradictions, conflicting requirements |
    | Clarity | Requirements ambiguous enough to cause someone to build the wrong thing |
    | Scope | Focused enough for a single plan — not covering multiple independent subsystems |
    | YAGNI | Unrequested features, over-engineering |

    ## Groundedness (blocking)

    Read the actual files. Do not reason from the spec's own text.

    | Finding | Verdict |
    |---------|---------|
    | Cited path or line does not exist | BLOCKING |
    | Code at that line does not do what the spec says | BLOCKING |
    | Claim about the existing system with no `file:line` citation | BLOCKING |
    | Item in `## Assumptions to Confirm` that IS verifiable in the code | BLOCKING — not a legitimate assumption. Go verify it yourself; if the code answers it, the spec had to cite it. |
    | Item in `## Assumptions to Confirm` with no search record | BLOCKING — see below |

    `## Assumptions to Confirm` is not an exemption. Every item there must state
    what was searched and why the code could not answer it: the searches run
    (grep patterns, globs) and the paths inspected. An item that just asserts
    uncertainty is blocking, exactly like a citation that does not check out.

    Spot-check each assumption: run the search yourself. If the code does answer
    it, the item is blocking under the row above.

    Report each blocking citation as: cited `file:line` → what the spec claims → what the code actually shows.
    Report each blocking assumption as: the item → what search was claimed (or missing) → what your own search found.

    ## Traceability (blocking)

    Everything downstream is charged against this list: the plan names the
    criterion each task delivers, and the final audit traces the two in both
    directions. A requirement stated only in prose is one nobody can trace.

    | Finding | Verdict |
    |---------|---------|
    | No `## Acceptance Criteria` section | BLOCKING |
    | No `## Implicit Requirements` section — "None" is the way to say there are none | BLOCKING |
    | A criterion bundling several behaviors | BLOCKING — it cannot take one verdict; split it |
    | A criterion no `file:line` citation could settle ("handles errors well") | BLOCKING — rewrite it as an observable behavior |
    | A requirement stated in the prose sections but absent from the list | BLOCKING — name it; the plan traces the list, not the prose |

    Read the prose for implicit requirements the spec discusses and never
    gave an `IR` id: concurrency, error handling, observability, edge cases,
    limits, failure modes. Each one is the row above — an unlisted implicit
    requirement reaches no plan and no matrix, and nothing downstream can
    notice it is missing. Judge them by the same bar as an `AC`; "it is
    non-functional" is not a reason for a weaker one.

    ## Calibration

    **Only flag issues that would cause real problems during implementation planning.**
    A missing section, a contradiction, or a requirement so ambiguous it could be
    interpreted two different ways — those are issues. Minor wording improvements,
    stylistic preferences, and "sections less detailed than others" are not.

    Approve unless there are serious gaps that would lead to a flawed plan.
    Any Groundedness or Traceability failure blocks approval regardless of
    calibration.

    ## Output Format

    ## Spec Review

    **Status:** Approved | Issues Found

    **Issues (if any):**
    - [Section X]: [specific issue] - [why it matters for planning]

    **Recommendations (advisory, do not block approval):**
    - [suggestions for improvement]
```

**Reviewer returns:** Status, Issues (if any), Recommendations
