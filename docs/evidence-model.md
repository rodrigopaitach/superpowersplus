# The evidence model

What counts as proof that a requirement was delivered, and who produces it.

This document is the canonical statement of the model. The skills that write
specs, write plans, review them and audit a branch all implement it; when one
of them and this document disagree, this document is the one that is right and
the carrier is the defect.

The model exists because a single universal form of proof — a
`path/file.ext:line` citation for every claim — cannot express a claim about
something that is *not* there. A criterion saying "no carrier still declares the
old rule" has no line to cite, so under a universal citation rule it fails by
construction, whatever the branch actually contains.

## The model

### The three layers

Three layers, and the separation between them is the design:

| Layer | Responsibility |
|---|---|
| Spec | Defines the *requirement* and declares its **evidence class** |
| Plan | Resolves the **verification instrument** that class requires |
| Audit | **Re-runs** the instrument and verifies |

A layer never does the next one's job. A spec that names a test has decided an
instrument; an audit that accepts the plan's word has verified nothing.

### Delivery evidence classes

Three, and no new class without a real case the three cannot represent.

| Class | Delivery evidence | Verification evidence |
|---|---|---|
| `behavioral` | Located range of the implementation | Automated test covering it, cited by range |
| `structural` | Located range of the versioned artifact | Read-only validator command, or sufficient located ranges |
| `negative` | The artifact's scope — where to look, not proof | Read-only command over the diff or the repository |

### Source evidence is not a delivery class

A dependency pinned in the lockfile plus the line you read, or the official
documentation of the pinned version, grounds a *design decision*. It is what a
spec cites for a claim about a library. It never grants `DELIVERED`: it says
what the outside world guarantees, not what this branch contains.

### Measurement status is a separate dimension

Orthogonal to the class: a rule can be structurally delivered in the artifact
and still never have been measured in execution. Most rules in this project are
reasoned, not measured, and that is recorded as a condition of the project
rather than as a defect.

**"The protocol defines/requires" is `structural`; "the agent actually does it"
is `behavioral` and requires measurement.** No rule becomes subject to a
behavioral record merely by being normative.

### Smallest sufficient range

**The smallest sufficient range is the shortest contiguous interval of lines
that, read without depending on neighboring lines you did not cite, supports the
claim on its own.**

- One line is enough → `file.ext:10`.
- Two or more form the minimum unit of proof → `file.ext:10-14`.
- A range chosen by proximity does not qualify.
- A range that needs lines outside it is not sufficient.
- A huge range that does contain the proof is materially valid and still fails
  this rule.

### Live-document reference

A file of this repository that is edited every release is not anchored by
`file:line`, which rots, but by **markdown link plus section title** —
[`CLAUDE.md`](../CLAUDE.md), section "Writing a reference". The canonical form
earns both checks: the path from the link pass and the heading from the section
pass. **The form the gate reads is `<link or backticked path>, section "Title"`,
in English and contiguous** — `scripts/check-links.sh:102-103`.

### The three freshness regimes

Orthogonal to the class, and they decide what needs a guard against ageing:

| Regime | What it is | Guard |
|---|---|---|
| *ephemeral* | A citation the auditor or reviewer has just produced and the consumer reopens in the same cycle | None; consumption is immediate |
| *live persistent* | A spec or plan still active, reread in future cycles | Where one exists; the anchor fragment is the candidate, and it is not built here |
| *historical* | A record already executed | None against `HEAD`; a rotten one is **marked** stale, never rewritten |

### Locator is not evidence

In a plan, a line number is navigation, and it ages while the plan is being
executed — an earlier task edits the file and every later citation into it
shifts. In an audit, a line number is proof against `HEAD`.

**Plans locate work; audits locate evidence.**

### Current-state evidence is not provenance

Evidence is always checked against the current branch. A reference pinned to a
commit or a tag is historical provenance — legitimate in a changelog, in an
investigation and in an already-executed record; never proof of delivery.

### The instrument must match the scope of the claim

A sampled, truncated, paginated, filtered or partial view does not establish
completeness, cardinality, uniqueness or absence. A claim about a whole set
requires an instrument exhaustive over that set.

This is what separates a `negative` criterion that was verified from one that
was merely looked at: "I grepped and found nothing" is a claim about the scope
the grep covered, and the declared scope is part of the instrument.

### The containment clause

Two distinct invariants, and neither replaces the other:

1. **Task eligibility.** Every task in a plan still has to leave a versioned
   deliverable in the branch. Merging, deploying, applying a migration to a live
   environment, publishing a release, a smoke run somebody performs by hand —
   none of them are tasks.
2. **Evidence adequacy.** `command + result` proves a property *of the
   deliverable or of the branch state*, and it is **read-only**. It never turns
   a deploy, a publish, a live migration or a monitoring window into an
   auditable task.

### The Verification Matrix

The plan records, per criterion, the **verification instrument** the declared
class requires. It is not a universal test matrix:

| Class | Instrument |
|---|---|
| `behavioral` | An automated test, subject to the test-quality rules already in force |
| `structural` | A read-only validator command, or sufficient located ranges |
| `negative` | A read-only command over the declared scope |

**No criterion is left without a resolved instrument, and a test is never
invented to fill a `structural` or `negative` row.**

Because a mechanical gate parses the table, the schema is fixed. Six mandatory
columns, and **no separate `Test` column** — for `behavioral` the test id lives
in `Verification instrument`, rather than the same id repeated in two columns:

| Column | `behavioral` | `structural` and `negative` |
|---|---|---|
| `Criterion` | the task's label | same |
| `Spec criterion` | the `AC`/`IR` it refines | same |
| `Evidence class` | `behavioral` | `structural` or `negative` |
| `Verification instrument` | the exact test id | a read-only validator, a read-only command, or located evidence as the class requires |
| `Test type` | filled in | `—` |
| `Layer` | filled in | `—` |

**A `—` in `Test type` and `Layer` is not a finding when the class is not
`behavioral`.** Type and layer information is preserved where it has a consumer;
no row pretends to have a test.

### Compatibility: legacy behavioral

**An `AC`/`IR` from a spec written before this model, declaring no evidence
class, gets the compatibility fallback** — the same verdict it would have had
before the model. **It holds wherever a legacy artifact crosses the flow:**
writing and reviewing a new plan, the execution controllers, task review, the
fix round and the re-review, and the final audit. **The mode is decided at the
boundary that holds the source spec**; the consumers downstream take the
resolved contract and never reinterpret the spec themselves.

**What the fallback means, exactly.** *Legacy behavioral* does **not** mean that
everything in the old `Test` column is now read as a valid behavioral test —
that would be historically false. It means that, absent an evidence class in a
legitimately legacy artifact, the flow uses the **compatibility behavioral
semantics of the previous model**, preserving the behaviour that already existed:

- a legacy row that carried a usable test id keeps using that path;
- a legacy row that carried only a read-only command is **not promoted
  retroactively** to `structural` or `negative`;
- a row the previous task reviewer could not verify stays a legacy limitation;
- **the fallback does not make a bad old plan good.** It guarantees only that
  the model introduces no new regression on it.

**The authority is the source spec, never the plan's schema.** With the marker,
the mode is v2 and a historical `## Test Coverage Matrix` becomes a blocking
mismatch. Without it, the source spec is legacy — and that does **not** fix the
plan's schema: a historical plan carries the Test Coverage Matrix, and a plan
written today from a legacy spec carries the Verification Matrix with
`behavioral` in every class cell, which is exactly what the plan skill requires.
**No marker with a Verification Matrix is not a mismatch.** The schema is a
cross-check, never a source of truth.

**A plan with no source spec.** The entry blocker both execution paths already
carry stands: the controller does **not** conclude on its own that a missing
source spec means legacy. It stops, resolves it with its human partner, and only
once they confirm no spec exists is the plan treated as legacy for compatibility.
**No historical artifact is rewritten to record that decision.**

**Test command in legacy mode.** The controller preserves the pre-v2 derivation
of test command and runner **where it was available**: it does not withhold a
command the old flow would have supplied, and it does not invent one to turn an
old structural command into a test. Where no admissible command exists, none is
invented.

| # | Source spec | Plan | Mode | What the controller supplies |
|---|---|---|---|---|
| 1 | legacy, cited | Test Coverage Matrix, a test id in the row | legacy | the pre-v2 test command |
| 2 | legacy, cited | Test Coverage Matrix, a read-only command in the `Test` cell | legacy | the pre-v2 test command where the old flow derived one; nothing invented, and the row keeps its historical limitation |
| 3 | legacy, cited | Verification Matrix, every class `behavioral` | legacy | the test command — the schema is not the authority |
| 4 | v2 | Verification Matrix, `behavioral` criteria | v2 | the test command |
| 5 | v2 | Verification Matrix, only `structural` and `negative` | v2 | no test command, and none derived |
| 6 | v2 | a criterion with no class | v2 | nothing — it blocks before dispatch |
| 7 | v2 | Test Coverage Matrix | v2 | nothing — blocking mismatch |
| 8 | none cited | any | undecided | nothing — the entry blocker stands, and silence is never legacy |
| 9 | confirmed not to exist | any | legacy | only the pre-existing fallbacks actually available |
| 10 | any | any | identical on both paths | inline and subagent resolve the same artifacts the same way |
| 11 | legacy, cited | a re-review of a legacy fix round | legacy | the test command the task review had; none invented where there was none |
| 12 | any | any | — | nothing is written: no historical plan or spec is modified while being read |

**`legacy behavioral` is not a fourth evidence class.** The classes remain
exactly three — `behavioral`, `structural`, `negative` — and `legacy behavioral`
names the **compatibility state**, not a value of the namespace. With no marker,
the *effective evidence class* is `behavioral`, obtained by the fallback.

The operational consequence: a new plan written from a historical spec records
**`behavioral`** in the Verification Matrix's `Evidence class` cell, never
`legacy behavioral`. That the class came from the fallback may be noted beside
the table for a reader, but **no parser, reviewer or auditor has to recognise a
fourth value**.

**There is no heuristic inference of class.** The discriminator is an explicit
marker in the spec header, `**Evidence model:** v2`, and the rule is
**asymmetric on purpose**:

| Who reads | Rule |
|---|---|
| The skill writing a spec — new, or an old one migrated on resume | Writes the marker and requires a class on every `AC`/`IR` |
| The spec reviewer | **Requires the marker.** Marker present with a criterion carrying no class is blocking; marker absent on a spec arriving through the current flow is blocking too |
| The plan skill, the plan reviewer, the final audit | With the marker, a class is mandatory and its absence is an error. **Without the marker, the document is historical → compatibility fallback, effective class `behavioral`** |
| The two execution controllers | **Resolve the mode before executing**, from the source spec both are already required to read. With the marker a class is mandatory and its absence blocks **before dispatch**; without it, legacy mode |
| The task reviewer, the implementer, the re-reviewer | **Consume** the decision already made. They do not open the source spec, do not open the plan, and do not decide whether a v2 document could be legacy. A classless brief reaches them only by dispatch from a controller that already resolved the artifact as legacy — that invariant is what stops *absence = legacy* from becoming global inference again |

**The asymmetry is what closes the escape route:** the reviewer never concludes
*"no marker, therefore legacy"*, because that would let a defective new spec
escape through the simultaneous absence of the marker and the classes. The
fallback exists only in the downstream consumers, which have to accept
historical artifacts that never passed through the new flow.

**Declared limitation:** a document created outside the flow and deliberately
without a marker is indistinguishable from a historical one without appealing to
provenance. The model guarantees the distinction **inside the supported flow**,
and does not try to infer intent from the file. Declaring that limit is
preferable to a heuristic over git history.
