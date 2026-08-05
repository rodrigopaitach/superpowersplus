# Context Audit

A procedure, not a skill. A skill costs its name and description in every
session whether or not it runs; a document under `docs/` costs nothing until
somebody names it.

## How to invoke it

> "follow `docs/context-audit.md`, scope: `<target>`"

Targets: `everything` · `CLAUDE.md` · `<skill-name>` · `always-on` (what loads
in every session) · `conflicts`.

**No scope declared? Ask before starting.** An audit with no cut produces a
menu, not a decision.

## Where the criteria come from

*The New Rules of Context Engineering for Claude 5 Generation Models* — Thariq
Shihipar, Anthropic, 2026-07-24. Anything written here that is not in that
article is this project's own interpretation, and it is marked as such.

The source is named rather than linked on purpose: `check-links.sh` holds the
seven documents this project owns to four allowed URL prefixes, and `docs/` is
inside that diet. A name and a date identify a source without depending on
somebody else's URL scheme.

## Step 1 — measure before judging

Four measurements, all of them commands rather than estimates:

| What | Why it is the number that matters |
|------|-----------------------------------|
| Lines per `SKILL.md` and per `references/`, with the ratio between them | The ratio is the shape: a thin entry point over thick reference is the target, and a skill with nothing extracted has never been asked the question |
| Lines per section of `CLAUDE.md` | The ceiling is enforced on the file; the decision is taken per section |
| What loads **always** (hook + always-on rules) against what loads on demand | Always-on is the only budget nobody can opt out of |
| Divergence of each file against `upstream/main` | This is the rebase cost, and it is an input to the decision, not a veto on it |

**Report the table BEFORE any judgment.** If a measurement diverges from what
the request asserts, **STOP at that item and report it** instead of editing:
two of fourteen items in an earlier session arrived with a wrong number.

## Step 2 — classify

Every section into one bucket, with `file:line` and a line count:

| Bucket | What it is | Where it goes |
|--------|------------|---------------|
| **GUARDS AN ACT** | A lock, a gate, a mandatory output format, a condition that decides the next step | **Stays**, always |
| **GOTCHA** | A trap in the code the agent does not discover by looking at the repository | **Stays** — this is where the tokens belong |
| **OBVIOUS** | What the agent finds by reading the filesystem or running one command | **Goes** |
| **RECORD** | A historical measurement, the rationale behind a decision, a justification nobody executes | **Goes**, to a referenced file |
| **CONSULTATION** | Read at one specific moment, not on every action | **Goes**, to `references/`, with an imperative pointer at the point of use |
| **DOUBTFUL** | You could not decide with certainty | **Listed with the doubt stated.** Do not guess — a misfiled doubtful is how a rule goes back to describing a pattern |

## Step 3 — conflict

Instructions that contradict each other across `CLAUDE.md`, skills, and
subagent prompts. The article names this the number-one cost, and this
repository has had six at once. List each with the `file:line` of **both**
sides.

## Step 4 — rule against judgment

For each rule, ask: would a model of this generation decide correctly without
it? Mark the ones where the answer is probably yes.

**A rule born of an observed defect is not a candidate** — it already satisfies
the article's filter. Provenance counts when it is in
[`CHANGELOG.md`](../CHANGELOG.md) or in
[`tests/skill-behavior/`](../tests/skill-behavior/). A precautionary rule with
no recorded symptom is the target.

## Step 5 — propose without applying

For each item that goes: **where it goes, and what pointer stays behind.**

The pointer is an **imperative carrying its moment** — a verb and a trigger
("open X before dispatching Task 1"), never a mention ("see X"). Write it as a
**markdown link, never in backticks**: `check-links.sh` resolves link syntax
and nothing else, so a backticked pointer is one no gate has ever read.

Then state the size of each file after the proposal.

## The restriction that is not violated

*(this project's own interpretation, and it is measured)*

**Extracting content that guards an act, to behind a link, degrades it** —
[`RESULT-resume-route-inline.md`](../tests/skill-behavior/RESULT-resume-route-inline.md),
FAIL → FAIL → PASS. It becomes content that **describes a pattern**, and a
pattern is violated even when it has been read and quoted. Nothing in the
GUARDS AN ACT bucket becomes material of consultation. If a proposal would
have that effect, mark it and do not propose it.

**What does not follow: that moving a rule closer to the act improves it.**
That inference was drawn from the run above and it is now bounded —
[`RESULT-main-branch-consent.md`](../tests/skill-behavior/RESULT-main-branch-consent.md),
2026-08-05, six runs across three states of one rule. The rule in a recap at
the end of the file (**A**) and the same wording moved into the step that acts
(**C**) were **indistinguishable, 2/2 each**; deleted (**B**) it failed **0/2**.
Presence was the variable. Position was not.

**Two explanations survive, and neither has been tested against the other:**

| | The claim | What it predicts |
|---|---|---|
| **(a) Reading** | Position decides only when it changes *whether the rule is read*. A link is not followed; a recap in the same file is read on the way past | Any position inside the file the agent already reads performs the same; only crossing a file boundary costs |
| **(b) Cost of obeying** | The price of compliance decides, not the placement. Stopping and returning nothing is expensive; creating a branch is nearly free | A cheap rule holds from anywhere, including behind a link; an expensive one fails from anywhere, including at the point of action |

Both fit both runs: the resume rule was expensive *and* behind a link; the
main-branch rule was cheap *and* in the same file. **Every measurement so far
varies the two together**, which is why neither is settled.

**To separate them, a test has to cross them:** an *expensive* rule placed at
the point of action in the same file, and a *cheap* rule placed behind a link.
(a) predicts the first holds and the second fails; (b) predicts the opposite.
Until a run does that, cite the bounded finding above — the extraction
restriction — and not the general one.

## The golden rule

Never write "never do X" without a specific, demonstrable failure mode.

## What this procedure does NOT do

- **It applies nothing.** It measures, classifies, and proposes. The decision is
  the owner's, item by item.
- **It does not cut a rule for being bulky.** Volume is not a finding.
- **It does not touch an upstream file** unless the rebase cost is already in
  Step 1's table.

## Settled cases — do not reopen

| Case | Why it is settled |
|------|-------------------|
| [`skills/final-branch-audit/SKILL.md`](../skills/final-branch-audit/SKILL.md) stays at 368 | It is two documents, not one long one: a rulebook the controller reads to interpret the verdict, and the dispatch prompt that restates it to produce one. Extracting the rulebook leaves the controller reading only the prompt, which does not carry the rationale |
| The escalation shape, copied in place across five carriers | A measured exception — [`escalation-format.md`](../skills/using-superpowers/references/escalation-format.md) records 1/3 behind a link, 3/3 once the form returned to the point of use. A form inside an output block does not go behind a link |
| The fake paths in [`skills/writing-skills/SKILL.md`](../skills/writing-skills/SKILL.md)'s teaching examples | They are the example, not the defect. "Correcting" a `❌ Bad` path teaches the opposite of what the section exists to teach |
| [`skills/writing-skills/SKILL.md`](../skills/writing-skills/SKILL.md) at 679 lines | Exempt from the ceiling: 679 here and 679 upstream, two changed lines, both the namespace rename. Cutting it means rewriting a file somebody else maintains |
| The provenance inside `CLAUDE.md`'s "Preparing a commit" | **The provenance of a rule that survived Step 4's filter is not disposable RECORD — it is what holds the rule up.** It reads as history and classifies as RECORD, which is the trap: strip the `ab1cf41` story and "never chain preparation and `git commit`" becomes a rule with no symptom, and the *next* audit cuts it under the golden rule. A demonstrable failure mode stays beside the rule it demonstrates |
