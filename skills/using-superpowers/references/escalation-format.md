# Escalation Format

**The shape itself is stated where the escalation happens** — the four
numbered items at each trigger point. Read it there. This file carries what
those four lines cannot: the boundary they apply to, why they are worded that
way, and one worked example.

**Five skills, six carriers, and the difference is the point.**
`brainstorming`, `writing-plans`, `executing-plans`, `final-branch-audit`, and
`subagent-driven-development` — which holds the shape **twice**: once in its
`SKILL.md`, and once in
[final-review.md](../../subagent-driven-development/references/final-review.md),
where the two end-of-branch gates escalate. A list of skill names undercounts
the files that have to agree, which is how that sixth carrier stayed off every
enumeration until somebody counted files instead.
[check-escalation-shape.sh](../../../scripts/check-escalation-shape.sh) is the
gate: it reads all six, fails when their items diverge, and tolerates
formatting. A seventh carrier is added there, by hand, on purpose.

That split is measured, not preferred. Three runs of the same scenario moved
from 1/3 to 3/3 as the shape moved out of this file and into the moment of use
— see [tests/skill-behavior/README.md](../../../tests/skill-behavior/README.md).

**Scope: the machine → human boundary only.** A reviewer reporting to the
controller, or an implementer reporting to the controller, keeps its own
format — those are machines talking to machines, and gate vocabulary is
precise there. This file governs what reaches a person.

**Why it exists:** your partner may not program. They decide well given a
practical consequence, options with their cost, and a recommendation with a
declared source. They decide badly — or stall — given internal gate
vocabulary. An escalation that reads like a verdict hands them a decision they
have no basis to take.

**Why the fourth item is an action and not a standard.** Items 1–3 describe
what the message contains, checkable once while writing it. Item 4 describes a
pass over the finished text. Worded as a quality bar — "with no technical term
left undefined" — it was measured failing twice: a bar is something a writer
believes they already meet, because the writer is the worst judge of what the
reader does not know. It only began holding once it named a moment for the
check to happen in.

**Gate vocabulary** — `LOST IN TRANSLATION`, `FALSE COMPLETION`,
`INVENTED SCOPE`, severity labels — may appear in parentheses as a reference
for someone who wants to trace it. It never carries the explanation.

**Self-test before sending:** could somebody who does not know this project
decide by reading only this? If not, it is not ready.

## Example

A conformance audit found a criterion no task delivered. The internal verdict
is `LOST IN TRANSLATION`. What reaches the partner:

> **The spec says a failed login gets logged with the account id, and nothing
> in this branch writes that log.** If it ships as is, the first time someone
> reports being locked out there is no record of which account it was, and the
> only way to investigate is to reproduce it live.
>
> | Option | What it means |
> |---|---|
> | Add it now (recommended) | One task, one test — the logging call and a test that asserts the account id lands in the log. Delays the merge by about one task |
> | Ship without it, add next branch | Merges today. Until it lands, lockout reports cannot be investigated after the fact |
> | Drop the requirement | The spec stops asking for it. Nothing to build, but the audit will stop flagging a gap that was deliberate |
>
> **Recommend: add it now.** Every other failure path in this project already
> logs the account id — `src/auth/session.ts:88` does exactly this for expired
> sessions. Source: a pattern already in your project.
>
> (Audit verdict for this item: `LOST IN TRANSLATION`, criterion `IR3`.)

Reply "yes" to take the recommendation.
