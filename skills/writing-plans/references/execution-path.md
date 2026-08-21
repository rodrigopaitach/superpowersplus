# Choosing the execution path

The one statement of the criterion. [`writing-plans`](../SKILL.md),
[`executing-plans`](../../executing-plans/SKILL.md) and
[`subagent-driven-development`](../../subagent-driven-development/SKILL.md) all
point here rather than restating it — it stood in eight places across those
three files, and a criterion nobody owns is corrected in one of them.

## A subagent is context-budget management, not a quality technique

This is the sentence the rest of the page rests on, and it is the one the
plugin did not say. The subagent path is worth choosing because a single window
will not hold the work, not because splitting work improves it. Review quality
comes from the review gates, which both paths run.

## Two questions, in this order

**1. Does the plan fit in one context window, with slack left for a correction
round?**

Not "does it finish in one sitting". Those two come apart exactly where it is
expensive: a plan can be short in time and dense in context. In the measurement
this rests on, a single-agent run took practically the same wall time as the
best configuration and ended with its window at 74% full against that
configuration's 26% — same sitting, three times the occupancy, and no budget
left for the round of corrections that follows a first pass.

The slack is the point. A run that ends green with the window nearly full has
already spent the budget it needs for the first bug.

**2. Is there a low-coupling boundary between the tasks?**

Tasks are coupled when they have a
shared file, shared interface, or shared state. The boundary is the point where
they stop having all three. Where no such
boundary exists, splitting the work moves the coupling into the gaps between
subagents, where nothing can see it.

Both answers point the same way, or the criterion has not been applied: a plan
that overflows the window but has no boundary is a plan to re-decompose, not a
plan to split.

## What the agent can measure, and what it cannot

**Nothing in this plugin gives an agent its own window occupancy.** The rule
therefore never asks for it. What the agent measures from the plan and states
in the offer is the count of tasks and the number of distinct files those tasks
touch — density, which is the part of the answer that is on the page.

The occupancy judgement belongs to the human partner, who has the meter on
screen. The offer asks; it does not assume, and it does not estimate.

## Where the evidence comes from, and what it does not cover

[`docs/context-budget.md`](../../../docs/context-budget.md) records the
measurement, its four configurations, and — in its own section — the three
things it did not measure, the turning point among them.
**It is a third party's measurement, not this project's**, and the rule above
is reasoned on top of it rather than measured here.

This is why no number appears in the criterion. The one figure a threshold
would need is the one the source declares it never took.
