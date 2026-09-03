# Review yield, a nit cap, and the problem the spec never carried — design

**Date:** 2026-09-03
**Status:** draft, round 3 findings repaired; round cap reached
**Route:** full process — more than two production files change (ten files across four skills, plus a new document), so criterion three of the short path fails and no offer was made.

## Problem

**This project measures what its reviews cost and never what they return.** The
median document review takes 7.3 minutes across the 29 runs on record
([`CHANGELOG.md`](../../../CHANGELOG.md), section `[1.16.0] - 2026-08-08`), and
a five-task branch dispatches between 13 and 69 subagents. Against that, there
is no record anywhere of how many blocking findings a round produced, or how
many survived the fix. The question "are the review passes paying for
themselves" cannot be answered from this repository — it can only be argued.

The gap is not academic. The `CHANGELOG` already records occasions where review
passes in series missed the same defect, including *"four independent review
lenses and 68 catalogue measurements passed a defect of this shape"* (section
`[1.20.0] - 2026-08-24`). Whether that is the rule or the exception decides
whether the round caps are too high, too low, or right — and nothing collects
the data that would settle it.

**A second problem shares the same root: the spec has never carried the problem
it solves.** Six sections are required
([`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md),
section "After the Design", the required-sections table) and none of them states
what is wrong today. `superpowersplus:final-branch-audit` traces `AC` and `IR`
row by row, which proves the thing was built as specified; nothing anywhere asks
whether the specification addressed the problem. Authors have felt the gap and
filled it by hand — 56 of 201 specs across eleven projects carry such a section,
under seven different names in two languages, and no gate reads any of them.

**A third, smaller one: a mechanical check reports limits it does not have.**
`skills/writing-plans/scripts/check-cross-references` carries a
`WHAT IT DOES NOT COVER` block so a green run is not over-read. It lists five
exclusions and omits a sixth: it never resolves a section reference pointing
into another file. In this repository `scripts/check-links.sh` covers that class
from the pre-commit hook; in a partner project, where the skill presents
`check-cross-references` as the mechanical check to run before dispatching a
reviewer, nothing does — and the block that exists to say so stays silent.

**Out of scope, deliberately.** Two candidates were investigated and held back
with their reasons recorded in the decision record below: telling reviewers not
to report what the deterministic gates already enforce (reasoned, never
measured — the instrument this design builds is what would measure it), and a
sixth short-path criterion (the short path has fired zero times in 40
opportunities, so the change would be unobservable). A third was measured and
rejected: teaching `check-cross-references` to resolve section references, since
zero of the 36 such references in the corpus are broken.

## Acceptance Criteria

**AC1.** [`skills/brainstorming/spec-document-reviewer-prompt.md`](../../../skills/brainstorming/spec-document-reviewer-prompt.md), section "Output Format", carries a line reporting how many findings the previous round raised and how many are still open.

**AC2.** [`skills/writing-plans/plan-document-reviewer-prompt.md`](../../../skills/writing-plans/plan-document-reviewer-prompt.md), section "Output Format", carries the same line.

**AC3.** The ledger is an artifact of the project being worked on, at `docs/superpowers/review-yield.md` — the location `docs/superpowers/specs/` and `docs/superpowers/plans/` already occupy — and its columns are date, branch, face, round, blocking findings raised, findings still open from the previous round. **Amended 2026-09-03**, from a path in this repository's own `docs/`. A skill instruction is read from an installed plugin, where `../../docs/` resolves inside the plugin directory and the Codex archive omits `docs/` entirely; and a ledger only this repository writes measures a handful of branches, against the eleven projects the corpus measurement swept.

**AC4.** Four skills instruct the controller to append one row per review dispatch: [`brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md) section "Spec Review", [`writing-plans/SKILL.md`](../../../skills/writing-plans/SKILL.md) section "Plan Review", [`subagent-driven-development/SKILL.md`](../../../skills/subagent-driven-development/SKILL.md) sections "3. Review the task" and "4. The fix loop", and [`requesting-code-review/SKILL.md`](../../../skills/requesting-code-review/SKILL.md) section "3. Act on feedback".

**AC5.** A reviewer prompt caps its advisory bucket at five items and reports the remainder as a count **when that bucket ends with the report** — `code-reviewer.md`, and the `Recommendations` bucket of both document reviewers. The two whose bucket the controller is required to carry onward are not capped: `task-reviewer-prompt.md`'s `Minor` and `re-review-prompt.md`'s `Out-of-Scope`, both of which `skills/subagent-driven-development/SKILL.md` transcribes item by item into the progress ledger. **Amended 2026-09-03**, from a uniform cap on all five. The cap protects the attention of whoever reads the report; where the reader is a controller under orders to forward every item, capping deletes data in transit — which that skill calls, in those words, a silent discard.

**AC6.** [`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md), section "After the Design", the required-sections table, requires `## Problem` as its first row, above `## Acceptance Criteria`.

**AC7.** [`skills/brainstorming/spec-document-reviewer-prompt.md`](../../../skills/brainstorming/spec-document-reviewer-prompt.md) treats a missing `## Problem` as blocking, in the same form the absent `## Coverage Map` already takes.

**AC8.** The same reviewer charges every acceptance criterion that does not serve the stated problem, naming the criterion and what it serves instead.

**AC9.** [`skills/brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md) carries a transition instruction for specs written before this requirement, in the form the coverage map's own transition already uses.

**AC10.** `skills/writing-plans/scripts/check-cross-references` names, in its `WHAT IT DOES NOT COVER` block, that a section reference into another file is not resolved, and where that class is covered instead.

## Implicit Requirements

**IR1.** A round-1 report writes the absence of previous findings in words ("none — round 1"), never a blank or an omitted line.

**IR2.** The ledger's column definitions live in exactly one place, a reference that ships with the plugin; each of the write points links that reference, names the ledger's path, and never restates the columns. **Amended 2026-09-03**: the definitions cannot live in the ledger itself once the ledger is a file in the partner's project, because a project that has never run a review has no such file to read.

**IR3.** No reviewer writes the ledger. The controller appends the row, because three of the five prompts declare the review read-only on the checkout.

**IR4.** Where a cap applies it is worded against that face's own bucket name — `#### Minor (Nice to Have)` for `code-reviewer.md`, `**Recommendations (advisory, do not block approval):**` for the two document faces — never one sentence shared across the five. The two uncapped faces state, inside the bucket itself, that it is uncapped and why. **Amended 2026-09-03**, alongside AC5: the enumeration named `#### Minor (Nice to Have)` for all three diff faces, which stopped being true for two of them the moment those two were uncapped.

**IR5.** `## Problem` is written in English, like the six sections already required. The section's content carries no language constraint.

**IR6.** Every write point's link to the definitions reference resolves under `scripts/check-links.sh`, and the ledger path itself is written in backticks, never as a markdown link — `CLAUDE.md`, section "Writing a reference" reserves backticks for artifact paths inside the partner's own project, and reserves links for files of this repository.

**IR7.** The change stages a `CHANGELOG.md` entry with it, as `scripts/check-changelog.sh` requires of any staged change under `skills/`.

**IR8.** Every corpus figure this document states is produced by the script embedded in `### Corpus measurements`, and by no rule stated only in prose, so a re-measurement that disagrees is settled by running it rather than by re-reading a sentence.

## Codebase Findings

**Five reviewer prompts, not four.** `skills/requesting-code-review/code-reviewer.md`, `skills/subagent-driven-development/task-reviewer-prompt.md`, `skills/subagent-driven-development/re-review-prompt.md`, `skills/brainstorming/spec-document-reviewer-prompt.md`, `skills/writing-plans/plan-document-reviewer-prompt.md`.

**Two output shapes, deliberately unlike.** Severity buckets at `skills/requesting-code-review/code-reviewer.md:118` — `#### Minor (Nice to Have)` — and `skills/subagent-driven-development/task-reviewer-prompt.md:206`. Status-plus-issues at `skills/brainstorming/spec-document-reviewer-prompt.md:230` and `skills/writing-plans/plan-document-reviewer-prompt.md:160`, whose advisory bucket is `**Recommendations (advisory, do not block approval):**` at `:240` and `:172` respectively.

**The re-review already measures yield per finding.** `skills/subagent-driven-development/re-review-prompt.md:90` — `### Finding Verdicts` — rules ADDRESSED, NOT ADDRESSED, CONFIRMED or WITHDRAWN on each finding carried in. This is why AC1 and AC2 name only the two document reviewers: the task loop already reports what survived, and `code-reviewer` and `task-reviewer` are single-pass faces with no prior round to compare against.

**Three of the five prompts declare the review read-only.** `skills/requesting-code-review/code-reviewer.md:35`, `skills/subagent-driven-development/task-reviewer-prompt.md:66`, `skills/subagent-driven-development/re-review-prompt.md:42` — *"Your review is read-only on this checkout. Do not mutate the working tree"*. A reviewer cannot write the ledger row.

**The task loop's review points are sections 3 and 4, not section 2.** `skills/subagent-driven-development/SKILL.md:228` is `### 2. Handle the report`, and it handles the *implementer's* report — `:230` reads *"Implementer subagents report one of four statuses"* — which happens before any reviewer has run. The task reviewer is dispatched from `### 3. Review the task` at `:250`, and the re-review from `### 4. The fix loop` at `:311`.

**The existing ledger is not reusable.** `skills/final-branch-audit/SKILL.md:361` — *"The ledger is the claim under audit"*. It carries an adversarial role; measurement written into it would be measurement under audit.

**The two document reviewers already receive what AC1 and AC2 report on.** `[PREVIOUS_FINDINGS]` is a required placeholder from round 2 in both templates, and neither Output Format asks for a verdict on any of them.

**A precedent exists for gating a form across reviewer prompts.** `scripts/check-evidence-line.sh:62-69` declares eight carriers by explicit list.

**Prompt files carry no line ceiling.** `scripts/check-skill-size.sh:53` iterates `skills/*/SKILL.md` only.

**`check-links.sh` walks the whole of `docs/`, and resolves an indented heading.** `scripts/check-links.sh:71` sets the targets; `:104` is `SECTION_HEADING = re.compile(r"^\s*(#{1,6})\s+(.*?)\s*#*\s*$")`, whose leading `\s*` is what lets it read a heading indented inside a fenced prompt template.

**`check-cross-references` parses headings only inside the document under check.** `skills/writing-plans/scripts/check-cross-references:142` defines `section(title_re)` as *"Body of the first `## <title>` section"* of that document. It carries no pattern for a section reference into another file, and its `WHAT IT DOES NOT COVER` block at `:17` lists five exclusions, none of them this class.

**The transition precedent for a newly required section.** `skills/brainstorming/SKILL.md:44` — *"Resuming a spec written before the map was required?"* — written when `## Coverage Map` became required.

**The controller's existing reporting points.** `skills/brainstorming/SKILL.md:290` and `skills/writing-plans/SKILL.md:419` both read *"Report the run to your human partner in the form every carrier uses"*. `skills/requesting-code-review/SKILL.md:52` is `**3. Act on feedback:**`.

**The short-path criteria are a conjunction.** `skills/brainstorming/SKILL.md:74` opens the criteria table and `:82` reads *"Any one failing means the full process, and no offer at all"*.

**The short path shipped in `[1.15.0] - 2026-08-06`.** `CHANGELOG.md`, that section's `### Added` block — *"A short path for a small change"*. It is not in `[1.16.0] - 2026-08-08`, whose entry moves the mechanical check before the first dispatch.

### Corpus measurements, 2026-09-03

**Every figure below is produced by this script, and by nothing else.** Three
independent readings of the same corpus disagreed while the rules lived in
prose — the author's, the round-1 review's and the round-2 review's — and each
disagreement was a rule read two ways rather than a corpus that changed. Run it
to reproduce or refute any number here; a result that differs means the script
is wrong, which is a claim anyone can settle.

```python
import re, pathlib, sys
ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path.home() / "Projetos")
SELF = "2026-09-03-review-yield-and-problem-section-design.md"
CUTOFF = "2026-08-06"
CLOSED = {"Problem", "Problems", "Problema", "Problemas", "O problema",
          "The request", "Context", "Contexto", "Background"}
REQUIRED = ["Acceptance Criteria", "Implicit Requirements", "Codebase Findings",
            "External Dependencies", "Assumptions to Confirm", "Coverage Map"]
TRANSLATED = ["Critérios de Aceitação", "Requisitos Implícitos", "Achados no Código",
              "Dependências Externas", "Suposições a Confirmar", "Mapa de Cobertura"]
HEAD = re.compile(r"^\s*\#{1,6}\s+(.*?)\s*\#*\s*$", re.M)

specs = [f for b in ROOT.rglob("docs/superpowers/specs") if b.is_dir()
         for f in b.glob("*.md") if f.name != SELF]
body = {f: f.read_text(encoding="utf-8", errors="replace") for f in specs}
heads = {f: {" ".join(h.split()) for h in HEAD.findall(t)} for f, t in body.items()}
projects = lambda fs: len({str(f.parents[2]) for f in fs})

print(f"corpus                          {len(specs)} specs, {projects(specs)} projects")
post = [f for f in specs if f.name[:10] >= CUTOFF]
print(f"since the short path shipped    {len(post)} specs, {projects(post)} projects")
route = [f for f in post if re.search(r"(Route|Rota):", body[f])]
en = [f for f in post if re.search(r"Route:", body[f])]
anchored = [f for f in post if re.search(r"^\*\*Route:\*\*", body[f], re.M)]
short = [f for f in post if re.search(r"(Route|Rota):\*{0,2}\s*(short|caminho curto)", body[f], re.I)]
print(f"declaring the route field       {len(route)}  ({len(en)} English, {len(route)-len(en)} Portuguese; anchored only: {len(anchored)})")
print(f"taking the short path           {len(short)}")

strict = {f: heads[f] & CLOSED for f in specs}
withp = [f for f in specs if strict[f]]
titles = {h for f in withp for h in strict[f]}
print(f"carrying a problem section      {len(withp)} of {len(specs)}, under {len(titles)} distinct headings")
gloss = re.compile(r"^(Problem|Problema|O problema|Contexto|Context)\b.*—")
loose = {f: {h for h in heads[f] if h in CLOSED or gloss.match(h)} for f in specs}
lw = [f for f in specs if loose[f]]
print(f"  same, admitting '<term> N — <gloss>'   {len(lw)} files, {len({h for f in lw for h in loose[f]})} headings")

before = after = both = 0
for f in withp:
    pos = [(m.start(), " ".join(m.group(1).split())) for m in HEAD.finditer(body[f])]
    p = next((o for o, t in pos if t in strict[f]), None)
    a = next((o for o, t in pos if t == "Acceptance Criteria"), None)
    if p is None or a is None:
        continue
    both += 1
    before += p < a
    after += p > a
print(f"position vs Acceptance Criteria {before} before, {after} after (of {both} carrying both)")

SECREF = re.compile(r"\[[^\]]*\]\(([^)\s]+\.md)\)[^.\n]{0,40}?,\s*section\s+\"([^\"]+)\"", re.S)
docs = [f for kind in ("specs", "plans")
        for b in ROOT.rglob(f"docs/superpowers/{kind}") if b.is_dir()
        for f in b.glob("*.md") if f.name != SELF]
found = resolved = no_heading = no_file = 0
for f in docs:
    for m in SECREF.finditer(f.read_text(encoding="utf-8", errors="replace")):
        found += 1
        target = (f.parent / m.group(1)).resolve()
        if not target.exists():
            no_file += 1
            continue
        titles = {" ".join(h.split()) for h in HEAD.findall(target.read_text(encoding="utf-8", errors="replace"))}
        if " ".join(m.group(2).split()) in titles:
            resolved += 1
        else:
            no_heading += 1
print(f"section references (specs+plans) {found} found: {resolved} resolve, {no_heading} name a missing heading, {no_file} point at a missing file")

print("required sections, English / translated:")
for en_name, pt_name in zip(REQUIRED, TRANSLATED):
    a = sum(1 for f in specs if en_name in heads[f])
    b = sum(1 for f in specs if pt_name in heads[f])
    print(f"  {en_name:24} {a:3} / {b}")
```

Run against `~/Projetos` on 2026-09-03:

```
corpus                          201 specs, 11 projects
since the short path shipped    40 specs, 6 projects
declaring the route field       21  (11 English, 10 Portuguese; anchored only: 5)
taking the short path           0
carrying a problem section      56 of 201, under 7 distinct headings
  same, admitting '<term> N — <gloss>'   56 files, 15 headings
position vs Acceptance Criteria 20 before, 0 after (of 20 carrying both)
section references (specs+plans) 36 found: 32 resolve, 0 name a missing heading, 4 point at a missing file
required sections, English / translated:
  Acceptance Criteria       44 / 0
  Implicit Requirements     43 / 0
  Codebase Findings         39 / 0
  External Dependencies     39 / 0
  Assumptions to Confirm    39 / 0
  Coverage Map              39 / 0
```

**What the numbers say.** The short path has never been taken: **0 of 40** since
it shipped, across 6 projects. The sizing step leaves a trace in **21 of those
40** — a figure that reads 11 if only the English `Route:` is counted and 5 if
the pattern is anchored to the line start, which is what two earlier readings
did. A problem section appears in **56 of 201** specs under **7** distinct
headings; admitting the form `<term> N — <gloss>` raises the heading count to 15
and leaves the file count at 56, because those headings occur inside specs the
strict set already counted.

**The section-reference measurement**, the evidence for AC10 rather than AC6,
is the one figure that spans plans as well as specs — the script's last-but-one
line: **36 references found, 32 resolve, 0 name a missing heading**, and 4 point
at a file that does not exist. It began as a separate measurement stated in
prose, and folding it into the script moved two of its numbers: 40 and 36 became
36 and 32, because the corpus definition excludes this document and the prose
version never applied that.

**The controlled comparison that justifies AC6.** Within one corpus — same
authors, same projects, same language — the six sections the skill names show
one heading each and **zero translations** (44, 43, 39, 39, 39, 39 against 0, 0,
0, 0, 0, 0 in the script's last block). The one section the skill does not name
shows seven headings in two languages. The only variable that differs is whether
the skill named it.

## External Dependencies

**The nit cap of five, and the `## Problem` heading, both come from the same published source:** the AI-Native SDLC playbook, Anthropic, `https://claude.com/blog/the-ai-native-sdlc-playbook`, consulted 2026-09-03. Its `REVIEW.md` template reads *"Report at most five nits per review; summarize the rest as a count"*, and its `intent.md` template opens with `## Problem` followed by proposed outcome, affected users and systems, constraints, and open questions.

This is a documentation source consulted for a convention, not a runtime dependency. This project remains zero-dependency.

## Assumptions to Confirm

**The yield ledger's usefulness cannot be verified before it holds data.** Three branches is the stated threshold and roughly one month at this repository's rate. Searched: `find` over the repository for any stored review report, and `grep` for the phrase recording the 29 reviews. The 29 document reviews behind the 7.3-minute median are not stored in this checkout, so no yield figure can be computed retroactively.

**Whether the 7.3-minute median still holds.** It was measured on 2026-08-08 and recorded in `CHANGELOG.md` section `[1.16.0]`. Nothing has re-measured it since. It is cited here as a dated figure, not a current one.

**Why 19 of the 40 recent specs carry no route field is not established.** The rule at `skills/brainstorming/SKILL.md:99` makes the header the only downstream signal and treats its absence as the full process, so the specs are correctly routed either way. Whether the sizing step ran and went unrecorded, or did not run, cannot be told from the artifacts — searched by grepping the 40 for `Route:` and `Rota:` under both an anchored and an unanchored pattern, which is what separates 21 from 5 and is itself recorded above. This is left for a separate branch rather than folded in here.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | Scope settled across five exchanges; the three held-back candidates are named in `## Problem` and recorded below. AC1–AC10 |
| Domain and data model | Clear | The entity is a review finding and its lifecycle across rounds. Already modelled at `re-review-prompt.md:90`; the document faces gain the same notion through AC1–AC2 |
| Interaction flow | Clear | The only reader is the controller, and the existing reporting points are where the row is written. No new flow |
| Non-functional attributes | Resolved | Observability is the subject of (a) itself — IR2, IR3 — and of AC10, which makes a gate's own blind spot legible |
| Integrations and external dependencies | Clear | Zero-dependency plugin; the playbook is a consulted document, recorded under `## External Dependencies` |
| Edge cases and failures | Resolved | Round 1 has no previous findings — IR1. A reviewer cannot write files — IR3 |
| Constraints and tradeoffs | Resolved | The prohibition on harmonizing the review faces (`CLAUDE.md`, and `docs/review-scopes.md`) shapes IR4; the read-only declaration shapes IR3 |
| Terminology | Resolved | The five faces name findings differently — `Critical`/`Important`/`Minor` against `Issues`/`Recommendations`. IR4 keeps each face's own words rather than imposing one vocabulary |
| Completion signals | Resolved | Every AC names a file and a section, settleable by opening it. The ledger's own usefulness is explicitly deferred to data — recorded under `## Assumptions to Confirm` |
| Placeholders and vague adjectives | Resolved | "Nit cap" quantified at five, with its source declared. Every corpus figure is printed by the script embedded in `### Corpus measurements`, none by a rule in prose — IR8 |

### Decision record

**Q1 — Where is the yield number written, so it outlives the session?**
Answer: a ledger file in the repository. Recommendation given: the same, on the ground that a number nobody aggregates fails the "who consumes this?" test that `CLAUDE.md` applies to any new field. Source: general practice, declared as such — no pattern in this project answered it, and the one adjacent artifact (the task ledger) was ruled out by `final-branch-audit/SKILL.md:361`.

**Q2 — Does the gate-coverage exclusion silence the reviewer or downgrade the finding?**
Answer: downgrade with a label. Recommendation given: the same, because `CLAUDE.md` sanctions `git commit --no-verify`, so a skipped gate is a real state rather than a hypothesis. Source: a project pattern, `CLAUDE.md`, section "Preparing a commit". **Superseded:** the exclusion itself was later held back (Q4), so this answer governs no criterion here and is recorded for the branch that takes it up.

**Q3 — Does the sixth short-path criterion enter this branch?**
Answer: it was folded in, then withdrawn in favour of `## Problem`. Recommendation given: withdraw. Source: measurement — the short path has fired 0 times in 40 opportunities across 6 projects, and its binding constraint is the two-file criterion, never intent; a criterion added to a conjunction that never passes changes nothing observable. Two defects in the proposed wording were found before it was withdrawn and are recorded for the branch that takes it up: the criterion read an artifact the checklist builds one step later, and the route it governed is the one that deletes that artifact.

**Q4 — Does the gate-coverage exclusion enter this branch?**
Answer: no, wait for data. Recommendation given: the same. Source: measurement, or its absence — the exclusion is reasoned and was never measured, the 29 review reports are not stored so it cannot be measured retroactively, and (a) is the instrument that would measure it. Applying "measure before cutting" to Q3 and not to this would be inconsistent. The nit cap was kept, on the different ground that it controls volume rather than judgement and carries a declared external source.

**Q5 — Does `check-cross-references` learn to resolve section references, or only declare that it does not?**
Answer: only declare it — AC10. Recommendation given: the same. Source: measurement — 36 such references exist across the corpus's specs and plans and **zero** name a missing heading, so there is no defect to catch; and in this repository `scripts/check-links.sh:104` already covers the class from the pre-commit hook. Building the resolver would be the same unmeasured construction that Q3 and Q4 were withdrawn for. What survives is that a green run must not read as coverage of a class the script never inspects.
