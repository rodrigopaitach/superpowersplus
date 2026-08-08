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

**`HOME` is not isolated, and it turned out not to need to be.** For as long as
`run-test.sh` existed its header claimed isolation while no runner ever set
`HOME`, so every run inherited the operator's global `CLAUDE.md`, output style
and hooks — visible in the logs as answers in a language no prompt used, and as
runs that opened by asking the operator about an unrelated file of their own.

**`--setting-sources project` drops the user layer and leaves credentials
alone**, because authentication does not come from the settings sources. The
obvious move — copying credentials into a scratch `HOME` — was both blocked and
unnecessary.

**This was not a cosmetic difference.** Measured across the same nine cases,
removing the user layer changed the announcement result on 5 of 9 cases, moved
Sonnet's score from 3/9 to 6/9, and cut the suite's cost by more than half
(Opus US$ 5.04 → US$ 2.15; Sonnet US$ 3.21 → US$ 1.53). **Every number below
the line is from an isolated run**; the contaminated ones are kept only in the
comparison column, because the difference between them is the finding.

---

# RESULT — the invocation always happens; the announcement's form does not

| | |
|---|---|
| **Date** | 2026-08-08 |
| **Models** | Claude Opus 5 (1M context) and Claude Sonnet 5, read back out of the logs rather than trusted from the flag |
| **Harness** | Claude Code, `claude -p --max-turns 3`, one dispatch per case, `TEST_MODEL` pinning the tier |
| **Rounds** | Four of nine cases — each tier under the operator's global context, then each tier with `--setting-sources project` |
| **Rules under test** | [`using-superpowers/SKILL.md`](../../skills/using-superpowers/SKILL.md), section "The Rule" — invoke the skill; and the same section's next sentence — *announce "Using [skill] to [purpose]"* |
| **Verdict** | **Invocation: 36 of 36. Announcement, isolated: 6/9 on Sonnet, 2/9 on Opus** — the smaller tier follows the form, the larger paraphrases it |

## Why the announcement was measured at all

The suite has verified the invocation since it was written, and never verified
the announcement — so the whole suite would have stayed green with that
sentence deleted from the skill. The assertion was falsified before being
trusted: on a real passing log, removing only the skill name from the
announcement text flips the new assertion to FAIL while the invocation
assertion stays PASS. **The failure migrates rather than merely persisting**,
which is what separates a gate from a second opinion.

## The four rounds

Invocation is omitted from the table because it has no variation to show: **no
case, on either tier, in any round, failed to invoke — 36 of 36.** Every FAIL
below is a run that loaded the skill and did not name it.

The contaminated columns are kept because the difference between the columns is
the finding, not because they measure the skill.

| # | Case | Skill named | Opus dirty | **Opus clean** | Sonnet dirty | **Sonnet clean** |
|---|---|---|---|---|---|---|
| 1 | `subagent-driven-development-please` | subagent-driven-development | FAIL | **FAIL** | PASS | **FAIL** |
| 2 | `use-systematic-debugging` | systematic-debugging | PASS | **PASS** | FAIL | **PASS** |
| 3 | `please-use-brainstorming` | brainstorming | PASS | **PASS** | FAIL | **PASS** |
| 4 | `mid-conversation-execute-plan` | subagent-driven-development | FAIL | **FAIL** | FAIL | **FAIL** |
| 5 | `after-planning-flow` | subagent-driven-development | FAIL | **FAIL** | FAIL | **PASS** |
| 6 | `i-know-what-sdd-means` | subagent-driven-development | FAIL | **FAIL** | FAIL | **PASS** |
| 7 | `skip-formalities` | subagent-driven-development | FAIL | **FAIL** | FAIL | **FAIL** |
| 8 | `skill-is-overkill` | brainstorming | PASS | **FAIL** | PASS | **PASS** |
| 9 | `i-remember-this-skill` | subagent-driven-development | FAIL | **FAIL** | PASS | **PASS** |
| | **Announced** | | 3/9 | **2/9** | 3/9 | **6/9** |
| | **Wall-clock** | | 156 s | **138 s** | 109 s | **114 s** |
| | **Cost** | | US$ 5.04 | **US$ 2.15** | US$ 3.21 | **US$ 1.53** |

## What the isolated rounds say

**The entry rule does not depend on anything.** Thirty-six runs, two tiers, two
environments, and the skill is invoked in all thirty-six — including the four
cases built to argue against invoking it. That is the rule this suite exists
for, and it holds everywhere it was looked at.

**The announcement depends on the tier, in the direction nobody would guess:
the smaller tier follows the prescribed form and the larger one paraphrases
it.** Clean, Sonnet announces in 6 of 9 and Opus in 2 of 9. The texts show why
rather than merely scoring it — Sonnet writes *"Using superpowersplus:brainstorming
to help think through your feature"* and *"Using subagent-driven-development to
execute the auth-system plan"*, which is the rule's own shape; Opus writes
*"I'll invoke that skill"*, *"I'll invoke the requested skill"*, *"I'll start
with the skill you asked for"* — **the invocation announced, the skill's name
replaced by a pronoun.**

**So the rule is not being ignored. Its form is.** Seven of the nine isolated
Opus runs open by declaring that a skill is being invoked; two name which one.
"Dead rule" and "rule whose wording nobody follows" call for different repairs,
and the distinction only appeared once the environment was clean.

**Contamination was suppressing announcements, not creating them.** Under the
operator's global context Sonnet scored 3/9; isolated, 6/9. The hooks and
output style consume the turn the announcement belongs to.

**A correlation that did not survive, kept so it is not re-derived.** On the
first Opus round the six misses were all `subagent-driven-development` and the
three passes were not — perfect at n = 9, with a textual mechanism ready to
explain it: [`subagent-driven-development/SKILL.md`](../../skills/subagent-driven-development/SKILL.md)
opens at lines 12–13 with *"Narration: between tool calls, narrate at most one
short line"*, and the announcement lands in the turn after the `Skill` tool
returns, when that rule is already loaded. **Two later rounds falsified it:**
Sonnet announces on four `subagent-driven-development` cases, and clean Opus
fails on `skill-is-overkill`, which is `brainstorming`. A perfect correlation
inside one homogeneous sample is the ordinary shape of a confident wrong
answer.

**Truncation was ruled out.** Every run ends in `error_max_turns` at three
turns, so one silent case was re-run with a ten-turn budget: it reached
`success` in seven turns, produced a long final message, and still never named
the skill it had loaded — past tense, neither skill nor purpose.

## Known weakness of the assertion

**It requires the skill's literal name, and one run was scored FAIL for
translating it.** Under the contaminated profile, Sonnet case 2 wrote *"Vou
seguir o processo sistemático de debugging"* — purpose announced, name
translated. It is a defensible FAIL, and isolation removed the cause: the same
case announces correctly in both clean rounds. **What survives isolation is a
different miss, and it is not a false negative:** the anaphoric openings
("that skill", "the requested skill") genuinely do not name anything, which is
exactly what the rule asks for. Whether the criterion should loosen is a
decision waiting on more runs, tracked in
[`CHANGELOG.md`](../../CHANGELOG.md), section "Open gaps".
