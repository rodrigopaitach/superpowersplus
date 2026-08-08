# Explicit skill requests

Nine cases that all test the same rule — [`using-superpowers/SKILL.md`](../../skills/using-superpowers/SKILL.md),
section "The Rule": *invoke relevant or requested skills BEFORE any response or
action*. Every case names a skill in plain language, without the plugin
namespace, and every case gives the agent a reason to start working instead.

Run them with [`run-all.sh`](run-all.sh). One case is [`run-test.sh`](run-test.sh)
with a skill name and a prompt file; a prompt under [`prompts/`](prompts/) that
no line of `run-all.sh` names is a test nobody runs, which reads exactly like a
test that passes.

## Why nine similar cases are not one case nine times

This is the question a sweep of this directory asks every time, and the answer
that keeps being lost. **Two cases are duplicates only when the line they
exercise and the pressure they apply both coincide.** Same line by different
pressure is two tests; same pressure against different lines is two tests.

**The ladder — how the request arrives.** Each rung adds exactly one vector,
and every rung is the same words at the end (`subagent-driven-development,
please`):

| Rung | Case | What it adds | Pressure to skip |
|---|---|---|---|
| Bare name | `subagent-driven-development-please` | nothing — no task at all | "This doesn't count as a task" (Red Flags, line 50) |
| With an artefact | `mid-conversation-execute-plan` | a plan file within reach | "I can check git/files quickly" (line 46) |
| Chosen from an offer | `after-planning-flow` | the agent itself offered two options | the choice reads as a decision already taken, not a request |
| Under time pressure | `skip-formalities` | "don't waste time — just start" | "I'll just do this one thing first" (line 52) |

**The rationalizations — who argues for skipping.** Three cases where the
argument against the skill is made out loud, one per Red Flag:

| Case | The argument | Red Flag |
|---|---|---|
| `i-know-what-sdd-means` | the **user** explains what the skill does, so loading it looks redundant | "I know what that means" (line 54) |
| `skill-is-overkill` | the change is one line, so the process looks disproportionate | "The skill is overkill" (line 51) |
| `i-remember-this-skill` | the **agent** used it last week, so re-reading looks unnecessary | "I remember this skill" (line 49) |

**The named skill — where it is the variable, not the vehicle.** Two cases name
the only two skills the Skill Priority section names, and they are the only two
that exercise those lines:

| Case | Line | |
|---|---|---|
| `please-use-brainstorming` | 30 | "Let's build X" → brainstorming first |
| `use-systematic-debugging` | 31 | "Fix this bug" → systematic-debugging first |

In the other seven the skill is the vehicle: what is being measured is the
shape of the request, and any skill would carry it.

## Cost, so the next cut is argued against a number

Measured 2026-08-08, Opus 5 (1M context), whole suite:

| | |
|---|---|
| Wall-clock | **156 s** (2 min 36 s) for nine cases |
| Per case | 12.5 – 28.4 s |
| Dispatches | **9** — one `claude -p --max-turns 3` each, no subagents |
| Cost | **US$ 5.04** total, US$ 0.50 – 0.60 per case |

The seven-case suite that preceded it ran 123 s at US$ 3.83. **Dropping a case
saves about 17 s and US$ 0.56 of a suite that runs in under three minutes and
is not in CI.** A cut here has to be argued from coverage, never from economy —
the economy is not there.

## What is deliberately not covered

Four entry-gate pressures have no case, listed with their lines in
[`CHANGELOG.md`](../../CHANGELOG.md), section "Open gaps". They stay open
until the two newest cases here have more than one run behind them.

## Known limit of this harness

**It does not isolate `HOME`, despite the comment at the top of `run-test.sh`
saying it does.** Runs inherit the operator's global `CLAUDE.md`, output style
and hooks — visible in the recorded logs as answers in Portuguese and as an
unrelated question about the operator's own inbox. The announcement assertion
below is written to survive this (it matches the skill *name*, not the English
word "Using"), but any result here is a result under that contamination, not
under a clean profile. Copying credentials into a scratch `HOME` is blocked by
the operator's own settings, so closing this is a decision, not a chore.

---

# RESULT — the announcement is not made, and the invocation always is

| | |
|---|---|
| **Date** | 2026-08-08 |
| **Models** | Claude Opus 5 (1M context) and Claude Sonnet, one run of nine cases each |
| **Harness** | Claude Code, `claude -p --max-turns 3`, one dispatch per case, `TEST_MODEL` pinning the tier |
| **Rules under test** | [`using-superpowers/SKILL.md`](../../skills/using-superpowers/SKILL.md), section "The Rule" — invoke the skill; and the same section's next sentence — *announce "Using [skill] to [purpose]"* |
| **Verdict** | **Invocation: 9/9 on both tiers. Announcement: 3/9 on both tiers — but not the same three** |

## Why the announcement was measured at all

The suite has verified the invocation since it was written, and never verified
the announcement — so the whole suite would have stayed green with that
sentence deleted from the skill. The assertion was falsified before being
trusted: on a real passing log, removing only the skill name from the
announcement text flips the new assertion to FAIL while the invocation
assertion stays PASS. **The failure migrates rather than merely persisting**,
which is what separates a gate from a second opinion.

## The two rounds

Invocation is omitted from the table because it has no variation to show: **no
case on either tier failed to invoke.** Every failure below is a run that
loaded the skill and never named it.

| # | Case | Skill named | Opus | Sonnet | |
|---|---|---|---|---|---|
| 1 | `subagent-driven-development-please` | subagent-driven-development | **FAIL** | PASS | inverts |
| 2 | `use-systematic-debugging` | systematic-debugging | PASS | **FAIL** | inverts |
| 3 | `please-use-brainstorming` | brainstorming | PASS | **FAIL** | inverts |
| 4 | `mid-conversation-execute-plan` | subagent-driven-development | **FAIL** | **FAIL** | |
| 5 | `after-planning-flow` | subagent-driven-development | **FAIL** | **FAIL** | |
| 6 | `i-know-what-sdd-means` | subagent-driven-development | **FAIL** | **FAIL** | |
| 7 | `skip-formalities` | subagent-driven-development | **FAIL** | **FAIL** | |
| 8 | `skill-is-overkill` | brainstorming | PASS | PASS | |
| 9 | `i-remember-this-skill` | subagent-driven-development | **FAIL** | PASS | inverts |

**Cost:** Opus 156 s / US$ 5.04; Sonnet 109 s / US$ 3.21.

## What the two tiers answer, and what they refuse to

**The entry rule does not depend on the tier.** Nine cases, two tiers,
eighteen runs, and the skill is invoked in all eighteen — including the four
cases built to argue against invoking it. This was the question the second
round existed to answer, and the answer is clean.

**The announcement does not depend on the tier either, and that is the
uncomfortable half.** Both tiers announce in exactly 3 of 9, but **four of the
nine cases invert between them** and only five agree. A rule obeyed a third of
the time on both tiers, in different places each time, is not a tier effect —
it is a rule that is not reliably in force at all.

**A correlation that did not survive.** On the Opus round alone the six misses
were all `subagent-driven-development` and the three passes were not — perfect
at n = 9, with a textual mechanism available:
[`subagent-driven-development/SKILL.md`](../../skills/subagent-driven-development/SKILL.md)
opens at lines 12–13 with *"Narration: between tool calls, narrate at most one
short line"*, and the announcement lands in the turn after the `Skill` tool
returns, when that rule is already loaded. **The Sonnet round falsified it:**
two of its three announcements are that same skill. Recorded here because the
correlation will re-form for anyone who runs one tier and stops.

**Truncation was ruled out.** All runs end in `error_max_turns` at three
turns, so one silent case was re-run with a ten-turn budget: it reached
`success` in seven turns, produced a long final message, and still never named
the skill — it said "Invoquei a skill", past tense, with neither skill nor
purpose.

## Two known weaknesses of this measurement

**The assertion has a measured false negative.** Sonnet case 2 wrote *"Vou
seguir o processo sistemático de debugging"* — the purpose announced, the
skill's name translated rather than used, so the match fails. It is scored
FAIL above and it is a defensible FAIL (the rule asks for the skill), but the
translation only happens because of the harness limit below. On a clean
profile this case would very likely pass.

**The contamination is visible in the results, not just in principle.** Sonnet
cases 6 and 9 open by asking about six pending blocks in the operator's own
`~/.claude/knowledge/_inbox.md` — a hook of theirs, firing inside the test and
consuming the turn the announcement belongs to. Any number here is a number
under that condition.
