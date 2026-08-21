# Context budget and subagent granularity

**This records a third-party measurement. This project did not run it, did not
reproduce it, and does not vouch for its method.** It is here because the
execution-path criterion rests on it, and a rule resting on evidence nobody can
open is a rule resting on nothing.

**This document deliberately does not link to the skill that consumes it.** The
criterion links here; linking back would make the two files a cycle, and a
cycle cannot be built in any order — whichever lands first fails the link gate
on a file that does not exist yet. Evidence does not point at its consumer.

## Sources

Two artifacts, named rather than linked — the third-party link diet allows four
host prefixes and none of them covers these
([`docs-and-links.md`](docs-and-links.md), section "The third-party link diet"):

- **"Aula — Sub-agents Benchmark (Fakeflix)"**, an Excalidraw board by the
  benchmark's author. The primary record: it alone carries the full scoreboard.
- **A Gemini-produced summary of a video by Waldemar Neto (Dev Lab), "Quando
  usar SUB AGENTS com IA"**, which states in its own opening that it is a
  summary and not a verbatim transcript. It corroborates part of the board and
  is silent on the rest.

Neither artifact is under version control in this repository.

## What was measured

Four runs of the same product requirements document, driven from the same
specification, differing only in how the same 17–18 subtasks were split across
workers.

| Configuration | Grade | Final window | Tokens | Wall time |
|---|---|---|---|---|
| 1 agent (single-threaded) | 0.93 † | 74% † | 9M ‡ | 19m ‡ |
| 3 workers, one per cohesive phase | 0.95 † | 26% † | 10.5M † | 18m † |
| 7 workers | 0.90 ‡ | — | 15M ‡ | 35m ‡ |
| 18 workers, one per task | 0.81 † | — | ~25M † | 43m † |

**† corroborated by both artifacts. ‡ carried by the board alone.** A cell
written `—` is one no source carries; nothing here is estimated or
interpolated. The summary gives the 3-worker token figure as "around 10
million", which the board states as 10.5M.

## The decision rule the board states

> Use subagents when the task does **not** fit in the window **and** there is a
> low-coupling boundary.

And, in the board's own words, a subagent is context-budget management, not a
quality technique.

## What this measurement does **not** cover

The board declares these gaps itself; they are not this project's caveats added
after the fact.

- **The turning point.** The exact point at which a single agent loses to a
  multi-agent split was not measured. The board says so in the block titled
  "what I have not yet validated".
- **The cost curve.** The curve of cost and degradation as the window fills is
  drawn on the board as illustrative and labelled as not measured.
- **Whether a coupling boundary exists** for a given task is posed on the board
  as an open question, not answered.

## Why it is not this project's measurement

The runs used a different tool, and no run had a review step per task, which
this project's subagent path does. The conclusion this project draws from it is
therefore about the **selection criterion**, not about task granularity — the
reasoning is in
[`2026-08-21-execution-path-context-budget-design.md`](superpowers/specs/2026-08-21-execution-path-context-budget-design.md),
`## Codebase Findings`, finding 4.
