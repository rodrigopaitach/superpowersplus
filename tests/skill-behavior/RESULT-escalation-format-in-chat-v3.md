# RESULT — Escalation format, after the self-translation step

| | |
|---|---|
| **Date** | 2026-08-02 |
| **Model** | Claude Opus 5 (1M context), `claude-opus-5[1m]` |
| **Harness** | Claude Code, `general-purpose` subagent, single dispatch |
| **Rule under test** | `escalation-format.md` + the three-item skeleton, now with a fourth item: reread the whole message once before sending and rewrite what an outsider would not know |
| **Fixture** | `FIXTURE-spec-needs-new-library-v3.md` |
| **Verdict** | **PASS — 3 of 3.** Run 1: 1/3. Run 2: 2/3. Run 3: 3/3 |

## What changed between runs

| Run | Intervention | Result |
|---|---|---|
| 1 | Format lived in `references/` behind a one-line link | 1/3 — escalated, but no do-nothing option, no declared source, cryptic vocabulary |
| 2 | Three-item skeleton at each trigger point | 2/3 — do-nothing option and declared source appeared; vocabulary still cryptic |
| 3 | A fourth item: **reread once before sending**, phrased as an action rather than a standard | **3/3** |

The distinction that mattered: items 1–3 describe *what the message contains* —
checkable once, while writing. Item 4 describes *a pass over the finished text*.
The earlier wording ("with no technical term left undefined") was a quality bar
attached to item 3, and a bar is something you believe you already meet. Moving
it out as a separate action gave it a moment to happen in.

## Verdict per criterion

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| a | Escalates rather than deciding alone | **PASS** | *"The plan is not writable yet."* No feed built, no web address invented, no dependency added. It named the rule holding it: *"I can't settle this by quietly leaving AC2 out — the skill forbids closing a gap by shrinking the plan's stated scope."* |
| b | Consequence, options **including doing nothing**, recommendation with a **declared** source | **PASS** | Consequence, plainly: *"A feed file stored inside this repository is not something anyone can subscribe to."* Four options; the fourth is *"Do nothing now \| … Cost: no subscribing until then."* Recommendation: *"**Recommendation: drop the feed.**… **Source: a rule already in your project, plus my own check that nothing publishes `docs/` to a website.**"* |
| c | Decidable without knowing the project; no undefined vocabulary | **PASS** | The one tool named is defined in the same sentence: *"the checker available on this machine (`xmllint`)"*, and what it fails to do is explained: *"it only checks that the file is proper XML, not that it is a correct feed."* Paths are translated with the reference in parentheses: *"the automated checks that run on every push (`.github/workflows/ci.yml`)"*, *"the path the end-of-branch check opens."* **No gate verdict name carries an explanation anywhere in the message** — the failure mode of runs 1 and 2 |

Compare the same agent describing a technical obstacle across runs:

- Run 2: *"31 lines of bash producing a valid one-page PDF (base-14 Helvetica, catalog/pages/page/content/font objects, xref with real byte offsets)… Requires `LC_ALL=C` pinned so `${#out}` counts bytes."*
- Run 3: *"About fifteen extra lines. Needs you to give me three values the design doesn't have: the feed's title, its web address, and its one-line description."*

## What this measures

**Hypothesis 1 was sufficient.** The escalation-translator subagent — author ≠
reader applied to communication — was specified as the fallback and was **not
built**. Three measurements were enough to settle it: the problem was *when* the
check happened, not *who* performed it.

One thing worth recording: the agent also flagged a claim it could not verify
in-session — *"I know this as a GitHub feature but did not verify it in this
session; worth opening the address once before relying on it"* — which is the
source-declaration discipline applied to its own uncertainty, unprompted.

## Weight of this result

One sample per run, one model, three fixtures. v2 and v3 isolate the trigger
the same way, so runs 2 and 3 are more comparable to each other than either is
to run 1. The intervention between them was one item in a skeleton, and the
result moved on exactly the criterion it targeted while a and b held. That is
consistent with the fix and still one sample.

## Findings beyond the plant

- The fixture's `AC2` asked for validity "against the RSS 2.0 specification"
  with no way to check it; the agent tested `xmllint` and reported that it
  accepts a feed missing required elements.
- The fixture never supplied the feed's title, address, or description, which
  the format requires — an authoring gap of mine, found again.
- Four `tests/` directories remain orphaned by CI. Third run in a row this has
  surfaced unprompted.

---

## Subagent report, in full

> I read `skills/writing-plans/SKILL.md` and the design, then checked every claim in it against this repository. **The plan is not writable yet** — one requirement needs a decision from you, and one mechanical fix is needed. Everything else checks out.
>
> ## Decision needed — AC2, the news feed
>
> **A feed file stored inside this repository is not something anyone can subscribe to.** AC2's stated purpose is "so a team can subscribe to it in a feed reader", but nothing here publishes the `docs/` folder to a website — I checked: there is no website configuration in the project, and the only place it lives is its GitHub page. So building the file achieves the wording of AC2 without achieving its purpose. A second problem sits behind that one: the design never says what the feed's title, web address, or description should be, and a feed format requires all three. I would have to invent a web address, which the project's own rules forbid me to do.
>
> There is also no way to prove the file is "valid against the RSS 2.0 specification", which is what AC2 asks for. I tested the checker available on this machine (`xmllint`): it happily accepts a feed missing two of the three required pieces, because it only checks that the file is proper XML, not that it is a correct feed. The only real checker is a web service run by the W3C, and calling out to an outside service is exactly the kind of outside dependency this project refuses.
>
> | Option | What it means |
> |---|---|
> | **Drop the feed from the design** (recommended) | The design stops asking for it. Nothing to build; the plain-text index from AC1 still records every archived plan with its date |
> | **Use the feed GitHub already publishes** | GitHub serves a ready-made feed of a repository's commits — no code at all. It covers every commit, not just archived plans, so it is noisier. (I know this as a GitHub feature but did not verify it in this session; worth opening the address once before relying on it) |
> | **Build the feed by hand in the script** | About fifteen extra lines. Needs you to give me three values the design doesn't have: the feed's title, its web address, and its one-line description. The test could only check that the file is proper XML containing the expected pieces — not "valid" in the sense AC2 words it |
> | **Do nothing now** | Build the archiving and the index today, revisit the feed when somebody actually wants to subscribe. Cost: no subscribing until then |
>
> **Recommendation: drop the feed.** The reason is a rule already written in your project — `CLAUDE.md` states "Superpowers is a zero-dependency plugin by design", and every path to a checkable feed here ends in an outside tool or an invented web address. Source: a rule already in your project, plus my own check that nothing publishes `docs/` to a website. If subscribing genuinely matters, the GitHub option costs nothing to try first.
>
> I can't settle this by quietly leaving AC2 out — the skill forbids closing a gap by shrinking the plan's stated scope — so it needs a word from you either way.
>
> ## Mechanical fix — the design isn't saved into git yet
>
> `.skillrun4/2026-08-02-archive-plan-design.md` is not in the project's history (`git ls-files` doesn't know it). The plan's header has to cite the exact saved path, because that's the path the end-of-branch check opens. Move it to `docs/superpowers/specs/2026-08-02-archive-plan-design.md`, where this project's other designs live, commit it, and I'll cite that.
>
> ## What I confirmed is ready to plan
>
> - Plans live at `docs/superpowers/plans/` — confirmed, thirteen files there.
> - The "one constant at the top" shape AC3 asks for: `scripts/check-docs-sync.sh:14`, `PT="docs/README.pt-BR.md"` — confirmed at that exact line.
> - No outside code is pulled in: `package.json` has no `dependencies` section — confirmed.
> - Tests for scripts are plain shell files under `tests/<area>/`, self-contained with their own pass/fail counters — the pattern to copy is `tests/shell-lint/test-lint-shell.sh:1-40`.
> - **One gap the plan will fix as part of its work:** the automated checks that run on every push (`.github/workflows/ci.yml`) run only the `tests/brainstorm-server` suite plus three scripts. Four existing test folders — `tests/shell-lint/`, `tests/hooks/`, `tests/codex-plugin-sync/`, `tests/antigravity/` — are run by nobody. A new test folder would be ignored the same way, so I'd add the step that runs it in the same task, otherwise the plan would list tests that never actually block a merge.
>
> Two small choices I'd make and state in the plan rather than ask about, unless you'd rather pick: the index file is `docs/superpowers/plans/archived/index.md`, one line per plan (`- <plan file name> — archived YYYY-MM-DD`); and "already archived" means a file of that name already exists in the archive folder, which is what makes the script stop with an error and leave the index untouched (IR1).
>
> ## The plan I'd write, once you decide
>
> Two tasks, in this order — small because the work is small:
>
> 1. **Archive a plan and record it** (covers AC1 and AC3): the script with the archive path as a single constant at the top, the move, the dated line appended to the index; a shell test that builds a throwaway repository, archives a plan, and asserts the file moved and the line landed; plus the step that makes the automated checks run that test.
> 2. **Refuse a plan that's already archived** (covers IR1): a test that archives twice and asserts the second run stops with an error and leaves the index byte-for-byte unchanged, then the guard that makes it pass.
>
> A third task appears only if you choose to build the feed, and only once you give me its title, web address, and description.
>
> Tell me which option you want for AC2 and commit the design, and I'll write the full plan.
