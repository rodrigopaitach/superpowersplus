# The Verification Matrix, class by class

What each delivery evidence class admits as an instrument, and what each of the
six columns holds. The rules that govern the table — the fixed schema, the `—`
convention, and where the class comes from — are in
[SKILL.md](../SKILL.md), section "Verification Matrix". This file is the
detail you open while filling in the rows.

The model itself, and the reasoning behind the three classes, is in
[`docs/evidence-model.md`](../../../docs/evidence-model.md), section
"Delivery evidence classes".

## The instrument each class requires

| Class | Instrument |
|---|---|
| `behavioral` | An automated test, under the test-quality rules already in force |
| `structural` | A read-only validating command, or located ranges sufficient on their own |
| `negative` | A read-only command over the declared scope |

**A test is what `behavioral` needs.** Inventing one to fill a `structural` or
`negative` row is the defect the Verification Matrix replaced: it produces a
green row whose instrument never observed the property the criterion is about.

**`structural` and `negative` instruments are read-only.** A command that
changes the tree proves nothing about the tree the auditor will read, and it is
not admissible however convincing its output.

## What each column holds

| Column | `behavioral` | `structural` and `negative` |
|---|---|---|
| `Criterion` | the task's own label and text | idem |
| `Spec criterion` | the `AC`/`IR` it refines | idem |
| `Evidence class` | `behavioral` | `structural` or `negative` |
| `Verification instrument` | the exact test id | the read-only command or the located evidence the class admits |
| `Test type` | this repository's own vocabulary | `—` |
| `Layer` | the real directory that type lives in | `—` |

`Criterion` carries the task number in its label, which is why there is no
separate Task column. `Verification instrument` is the only column that ever
names a test, and it names exactly one per row.
