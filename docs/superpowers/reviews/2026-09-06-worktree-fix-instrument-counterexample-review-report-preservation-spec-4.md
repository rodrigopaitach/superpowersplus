## Spec Review

**Status:** Approved

**Previous findings:** 1 received — 0 still open: none

**Scope taken.** Round-4 scope per "Which Round This Is": I verdicted the single round-3 blocking finding against the corrected document, read the three named change regions at full bar (re-running the command each claim in them rests on), grepped the identifiers the change touched (`816`, `120`, "totals", "ten", "stale by construction", `AC19`) for damage outside them, and took step (d)'s saving on everything else — I did not reopen `## Problem`, AC1–AC21, IR1–IR9, the POSIX claims, or the `## Codebase Findings` paragraphs the change list does not name.

**Round-3 verdict (fixed).** The defect was a present-tense "816 links across 120 files" the named command contradicted. The two totals are gone. What remains in that sentence reproduces exactly, measured in this tree just now:

- `scripts/check-links.sh` exits **1** (checked as an exit status, not from a piped tail).
- **Four** unresolved links across **three** lines (13, 23, 29×2), all in the preserved round-1 report, all relative to `docs/superpowers/reviews/`.
- The stated reason is true and now demonstrated a third time: the run prints **815 local links across 122 file(s)** — the file total was 120, then 121, and saving the round-3 report made it 122. The count moves once per preserved report, which is the fix's own argument. No durable number went out with the two totals: 815 is not durable either — it moved 816 → 815 inside this cycle from an ordinary edit to the spec, and report 1's own links had moved it before that.
- The construction mirrors a precedent the spec already carries: Q7 drops the transcript count with the identical "deliberately not written down" wording and its own reason (line 332). The two now read as one policy rather than one exception.

Advisories 1 and 2 of round 3 are both in place and correct: the Coverage Map's opening sentence reads "all ten are settled" (nine `Resolved` + one `Clear`, ten rows, no collision with a state name), and Q8's Recommended line carries the parenthetical *(this scope was too narrow — see the Answer)* pointing at the correction the Answer makes.

**On whether `CLAUDE.md`'s "a relation or a condition, never a measured number" transfers to a spec:** not as an absolute. That rule's stated reason is that a number in a permanently-loaded file ages in silence. A spec is dated in its own filename, consumed by a plan inside the same cycle, then frozen as a record — so a **dated** measurement belongs there, and this document already does it well two paragraphs above ("Proved by difference on 2026-09-06: … 811 → 812"). What does not belong is an **undated, present-tense** number, which ages exactly as the rule describes; that is what the round-3 finding caught and what the repair removed. Dropping was one of the three clean options and it is a legitimate one here, because these particular totals move on every run of the very thing being specified.

**Issues (if any):**
- None.

**Unverified External Claims (if any):**
- None. The diff touched no external-source claim; the POSIX citations sit outside all three regions and were verified in round 3.

**Recommendations (advisory, do not block approval):**
- `## Codebase Findings`, line 214: "so any figure recorded in this document is stale by construction" over-reaches and collides with two figures the document deliberately keeps — "four links, across three lines" three lines above, and the dated "811 → 812" in the paragraph before. Scoping it ("so either total recorded here is stale by construction") says the same thing without arguing against the dated form the spec itself uses.
- Same sentence: "two of its own review rounds moved it" is a count, and this round makes it three (measured, 121 → 122). "each of its own review rounds moves it" is the relation form, is what the sentence actually means, and never ages — the precise distinction the sentence is defending.
- The stated reason names only the file total ("this slice increments the file total every time it saves a report"), yet two totals are dropped. Measured: saving the round-3 report moved files 121 → 122 and links 815 → 815, because that report carried no local links — so the link total is contingently, not structurally, incremented. Half a clause on why it goes too (report 1's own links did move it; so did an ordinary edit to this spec) would make the justification cover what it is used for.
- Carried unchanged from rounds 1–3: AC11, AC12, AC15, AC16 and AC21 each bundle several independently checkable statements. Still not blocking, still cheaper to split before the plan traces them.

Corroborating checks, both run in this tree at this moment: `check-cross-references` reports every reference resolving (30 AC/IR defined, 30 cited, 21 `file:line` citations); `check-links.sh` exits 1 with the four failures confined to the preserved round-1 report — the condition AC19 exists to remove, expected until implementation.
