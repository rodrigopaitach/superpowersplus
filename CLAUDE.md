# superpowersplus — working in this repository

**superpowersplus** is a derivative work of [Superpowers](https://github.com/obra/superpowers) (Jesse Vincent, Prime Radiant, MIT): a plugin of skills that shape how an agent works. It takes no outside contributions — there is no PR process here. What this project adds is recorded in [`CHANGELOG.md`](CHANGELOG.md); the `plus.N` entries that led to `1.0.0` are in [`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md).

## How you work here

**Evidence-or-zero is the rule this project exists to enforce, and it applies to you.** Every claim about this code carries a `path/file.ext:line`. A claim you cannot locate is not a claim — say you could not verify it. An unverified statement and a verified one look identical once written down, which is the whole failure this repository was built to separate.

- **Measure, don't estimate.** Counts, file lists, "this is used in N places" — run the command. Past sessions have stated counts the command then contradicted.
- **Show your human partner the complete diff** before committing anything non-trivial.
- **Report faithfully.** Tests that fail, steps you skipped, what you could not verify — say so plainly, with the output.
- **This file keeps a relation or a condition, never a measured number.** A number that matters lives in [`CHANGELOG.md`](CHANGELOG.md) with its date. A number here ages in silence and goes on reading as true; a condition — something a command answers today — never does.
- **Most rules here are reasoned, not measured.** When you add one, say which it is.

## Names and paths that break silently

| Trap | What happens if you miss it |
|---|---|
| **The plugin's `name` in `.claude-plugin/plugin.json` is the skills' namespace.** Skills reference each other as `superpowersplus:brainstorming`. Renaming it means changing every such reference, the matching entry in `.claude-plugin/marketplace.json`, the other harness manifests, and the hardcoded string in `hooks/session-start`. | The reference names a skill that does not exist — no error, just a rule nobody follows |
| **Plans and specs written before `1.0.0` use the `superpowers:` namespace.** Read `superpowers:brainstorming` there as `superpowersplus:brainstorming`; do not invoke the old name. | They are historical records and were not rewritten. Invoking the old name reaches nothing |
| **A surviving `superpowers` string is not an unfinished rename.** Ask what it names before touching it: an artifact path inside your partner's project (`docs/superpowers/`, `.superpowers/`) — or a harness this project does not exercise (`.pi/`, the Codex packager) — or the entry skill's own directory, `skills/using-superpowers/`. | A sweep that "finishes the rename" orphans every spec and plan already written in a partner's project, and manifests nothing here tests |
| **Skills name actions, not tools.** Do not edit a skill body to fit a harness. | One skill body has to run on every harness |
| **`evals/` is a separate repository, gitignored and absent. Nothing in this checkout runs it.** | `docs/testing.md` once documented it as one of two local suites and gave a runnable `cd evals && uv sync`. `.gitignore` points here for the reason |
| **`dispatching-parallel-agents` is orphaned in the invocation graph on purpose.** No `SKILL.md` names it; it fires on its description, which is how a skill applying to *any* fan-out is reached without every caller listing it. | A sweep for dead references keeps surfacing it. Wiring an invocation in would suggest that one skill is where parallel dispatch belongs |
| **`verification-before-completion` is orphaned on purpose too, and its reason is a measurement.** [`RESULT-verification-before-completion.md`](tests/skill-behavior/RESULT-verification-before-completion.md) has the verification running in a repository where no skill was reachable. Wiring it in argues against the record. | The sweep surfaces it beside `dispatching-parallel-agents` and it looks like the one real orphan. Connecting it would ship a rule the measurement says is not what produces the behaviour |
| **`tests/codex/test-package-codex-plugin.sh` only tells the truth on a clean tree.** The packager builds its archive from a git ref; the test reads its expected values from the working tree. Run this suite after committing. | With anything uncommitted the two sources disagree and it fails with no defect present. It has cost two debugging detours |

## Where the obvious move is wrong

- **The four review faces are not one rule written four ways.** Harmonizing them into a common protocol changes the reach of three gates at once. What each one actually runs is in [`docs/review-scopes.md`](docs/review-scopes.md) — read it before touching any of them.
- **A form inside a subagent's `## Output Format` is unified in place, never extracted** — and then charged by a gate. This inverts "at a third occurrence, extract it", and the inversion is measured. Without the gate, "unified in place" is just "copied".
- **A `SKILL.md` over the line ceiling is fixed by progressive disclosure, never by compression.** Move what a run does not need until it needs it into `references/`, and leave the trigger that sends the reader there — a pointer nobody is told to follow is a deletion.
- **The showcase and the reference documentation diverge on purpose.** Different sections, order and depth, because they answer different questions. Do not harmonize them; see [`docs/docs-and-links.md`](docs/docs-and-links.md).
- **Skills are code that shapes agent behavior, not prose.** Carefully-tuned content — Red Flags tables, rationalization lists, "human partner" language — is not reworded without evidence the change improves outcomes.

## Writing a reference

- **A pointer to a file of this repository is a markdown link, never backticks.** `check-links.sh` resolves link syntax and nothing else, so a real reference in backticks is one no gate has ever read. The fix is the link, not a gate.
- **Backticks are reserved for the paths that do not resolve on purpose, and those are never "corrected":** placeholders (`<workspace>/progress.md`), artifact paths inside your partner's own project (`docs/superpowers/specs/…`), self-references (`SKILL.md` meaning the one you are reading), and the `❌ Bad` paths `writing-skills` exists to teach you not to write.
- **Anchor by `file:line` for code and artifacts that do not move because of what we write; by markdown link plus section title for a file of this repository we edit every release.** Obeying the two rules separately produced a reference no gate could read — a link naming a section that had just been deleted passed green, because the gate matched only the backticked variant. The canonical form earns both checks, the path from the link pass and the heading from the section pass.

## Relationship with Superpowers

**This project does not pull from the upstream.** `obra/superpowers` is where this code came from and the reason the MIT attribution exists; on 2026-08-05 the owner decided it stops being a source of updates. The `upstream` remote may stay for consultation, and `git diff upstream/main` still answers where a file came from, but no rebase is planned and none is owed.

**Rebase cost is not a criterion in any decision here.** Not for touching a file they also maintain, not for how a change is shaped, not for whether a fix is worth making. **When you find a rule still standing on it, that is the finding** — say so rather than working around it. A test here is judged like any other file of this project: it asserts what this project decided, or it changes, or it goes.

**The attribution does not move, and it is not the same question.** [`LICENSE`](LICENSE) and the credit at the top of this file are a license obligation on code that came from them, independent of whether anything is ever pulled again. Ending the sync does not end the credit.

## What does not belong here

- **Third-party dependencies.** This is a zero-dependency plugin. A change needing an external tool or service belongs in its own plugin.
- **Fabricated content.** Invented claims, made-up problem descriptions, hallucinated functionality. If you cannot describe the specific session, error, or experience that motivated a change, do not make it.
- **Anything that helps only one project, team, or workflow** — configuration and skills alike. Ask: would this help someone working on a completely different kind of project?
- **New writing in [`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md).** It is a frozen record. Everything new goes in [`CHANGELOG.md`](CHANGELOG.md), including closing an open gap.

## Preparing a commit

**Never chain content preparation and `git commit` in one `&&` block.** Prepare, then verify the preparation produced what you expected, then commit. A script that edits three files and a `git commit` on the next line are independent: the edit can fail and the commit still runs. This is not hypothetical — a `CHANGELOG.md` edit failed on a wrong anchor, the commit and the push ran anyway, and the change shipped without its changelog entry. The failure was invisible because nothing was chained to it.

**A staged change under `skills/`, `scripts/`, `githooks/`, `.github/` or `hooks/` needs `CHANGELOG.md` staged with it**, and [`check-changelog.sh`](scripts/check-changelog.sh) in the pre-commit hook enforces it. The rule was written before the gate and broke inside the same cycle: `ab1cf41` shipped that very rule *and* `check-skill-behavior-records.sh` with no changelog line, and nobody noticed until the version was cut and the entry had to be reconstructed from the diff. A rule nothing enforces holds until the first busy commit. A change genuinely without an entry — a typo in a comment, whitespace — is what `git commit --no-verify` is for; the gate cannot tell them apart and does not try.

**One problem per commit.** Bundled unrelated changes cost the reader the ability to revert one of them.

**If a commit ever visibly drags**, time the checks one at a time against the baseline in [`docs/pre-commit-cost.md`](docs/pre-commit-cost.md). There is deliberately no automatic timer, which would be one more thing to maintain, reporting on every commit a number nobody reads.

## Versioning

Semver from `1.0.0` on. **PATCH** for a fix that does not change how a skill behaves; **MINOR** for a new skill or a compatible new rule; **MAJOR** for anything that breaks existing artifacts or invocations — the namespace rename would have been MAJOR.

Bump with `scripts/bump-version.sh <version>`; the files carrying the field are declared in `.version-bump.json` and are never edited by hand. How to read the audit's one class of false positive is in [`docs/releasing.md`](docs/releasing.md).

**`[Unreleased]` does not survive more than one cycle of work.** When it tells a complete story — a measured correction closed, a set of leftovers cleared — cut the version. A fat `[Unreleased]` means `main` has drifted from the last installable release with no name describing the difference, and the only way to know what is on `main` becomes reading the diff.

**A release body is generated, never hand-written**, and it is generated **into a file by the script itself** — `scripts/release-notes.sh <version> <file>`, then `gh release create … --notes-file <file>`. Never `release-notes.sh <version> > <file>`: the redirect truncates the target before the script runs, so a script that fails still leaves a zero-byte file and `gh` publishes it without complaining. That shipped an empty release body once; the two-argument form writes only after the body exists, and refuses an empty one. Publish with both guards from [Running `gh`](#running-gh).

## Running `gh`

**Every `gh` invocation in this checkout carries `--repo rodrigopaitach/superpowersplus` — reads included.** Not only the outward-facing ones. This repository has an upstream remote, and `gh` resolves against the remotes, not against your intent.

The failure mode is why the rule covers reads. `gh run list --branch main` here returned runs from **`obra/superpowers`** — a month old, `conclusion: success`, formatted exactly like the answer being looked for. Nothing errors. Taken at face value it confirms a CI run that never happened, on a repository nobody pushed to. A wrong write announces itself; a wrong read is indistinguishable from a right one.

**`gh release create` additionally takes `--verify-tag`**, so a mistyped tag fails instead of being created. Publishing takes both guards.

**Waiting on CI means waiting on a SHA, never on `gh run list --limit 1`.** The newest run is not the run you pushed: between the push and the query there is a gap in which the list still holds the *previous* run, already concluded, already green. That is what happened here — the answer read as a pass for a commit CI had not started on yet, and nothing about it looked wrong. Ask for the run whose `headSha` is the commit you pushed, and treat "no run yet" as *not yet*, not as failure:

```bash
sha="$(git rev-parse HEAD)"
gh run list --repo rodrigopaitach/superpowersplus --commit "$sha" \
  --json status,conclusion,headSha
```

## Where the rest lives

- [`docs/review-scopes.md`](docs/review-scopes.md) — what each of the four review faces runs, and the two shapes copied across carriers on purpose. **Read before editing any reviewer prompt.**
- [`docs/docs-and-links.md`](docs/docs-and-links.md) — the three README-shaped files and their jobs, what `check-links.sh` reads in each of its three passes, and the third-party link diet. **Read before adding a document or a link.**
- [`docs/releasing.md`](docs/releasing.md) — the bump audit's one false positive, and the `SKILL.md` ceiling exemption that runs on a deadline. **Read when cutting a version.**
- [`tests/skill-behavior/README.md`](tests/skill-behavior/README.md) — the adversarial records: a fixture, the input carrying it, a recorded result per rule. **Read before adding one.** Plugin-infrastructure tests live at [`tests/`](tests/) and run via each directory's own `run-*.sh`. CI runs every static suite; the three that dispatch a live agent stay out because they cost tokens and are non-deterministic. **Add a suite, add its CI step.**
