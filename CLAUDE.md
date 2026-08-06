# superpowersplus — working in this repository

**superpowersplus** is a derivative work of [Superpowers](https://github.com/obra/superpowers) (Jesse Vincent, Prime Radiant, MIT). It takes no outside contributions — there is no PR process here. What this project adds is recorded in [`CHANGELOG.md`](CHANGELOG.md); the `plus.N` entries that led to 1.0.0 are in [`docs/PLUS-CHANGELOG-historico.md`](docs/PLUS-CHANGELOG-historico.md).

## If You Are an AI Agent

Stop. Read this before doing anything.

**Evidence-or-zero is the rule this project exists to enforce, and it applies to you.** Every claim you make about this code carries a `path/file.ext:line` citation. A claim you cannot locate is not a claim — say you could not verify it. An unverified statement and a verified one look identical once written down, which is the entire failure this repository was built to separate. Do not become the thing it guards against.

Before you change anything here:

1. **Measure, don't estimate.** Counts, file lists, and "this is used in N places" get a command run, not a guess. Past sessions have stated numbers that were wrong by more than 2×.
2. **Show your human partner the complete diff** before committing anything non-trivial.
3. **Report faithfully.** Tests that fail, steps you skipped, things you could not verify — say so plainly, with the output.

## Technical invariants

These break things silently when violated.

| Invariant | Why |
|---|---|
| **The plugin's `name` is the skills' namespace.** Skills reference each other as `superpowersplus:brainstorming`. Changing `name` in `.claude-plugin/plugin.json` means changing every such reference, the matching entry in `.claude-plugin/marketplace.json`, the other harness manifests, and the hardcoded string in `hooks/session-start`. | Miss one and the reference names a skill that does not exist — no error, just a rule nobody follows |
| **Plans and specs written before `1.0.0` use the `superpowers:` namespace.** Read `superpowers:brainstorming` there as `superpowersplus:brainstorming`; do not invoke the old name. | The rename happened at `1.0.0`; those documents are historical records and were not rewritten |
| **Deliberate exceptions to the rename — never rename these.** `docs/superpowers/` and `.superpowers/` inside your partner's projects (artifact continuity); `skills/using-superpowers/` (the entry skill's directory name); the internal names in `.pi/` and the Codex packager. | The first two would orphan existing artifacts; the last two are harnesses this project does not exercise, where the cost exceeds the gain |
| **Never rename `docs/superpowers/specs/` or `docs/superpowers/plans/`.** | Those are artifact paths inside your partner's own projects. Renaming them orphans every spec and plan already written |
| **Skills name actions, not tools.** Do not edit skill bodies to fit a harness. | One skill body has to run on every harness |
| **`evals/` is gitignored and absent from this checkout.** | It is a separate repository. Nothing here depends on it |

## The four review scopes are distinct by design

Each face runs something different. They are **not one rule written four ways**
— harmonizing them into a common protocol changes the reach of three gates at
once. Do not.

| Face | What it actually runs |
|---|---|
| `subagent-driven-development/task-reviewer-prompt.md`, section "Tests — Run Them Yourself" | The **task's** test command, `[TEST_COMMAND]`, reported verbatim |
| `requesting-code-review/code-reviewer.md`, section "What to Check" | The **project's** suite, with a fallback to the command the dispatch named |
| `subagent-driven-development/re-review-prompt.md`, section "Tests — Run Them Yourself" | **Re-runs** what already ran, reporting command, exit code, and counts |
| `final-branch-audit/SKILL.md`, section "The Auditor Re-Runs the Searches" | **No tests at all** — re-runs the *searches* against the spec |

The evidence block `**Command:** [verbatim] — **exit:** [code] — **counts:** …`
appears three times, identical but for a baseline suffix that is content, not
wording: `base:` in `task-reviewer-prompt.md`, section "Test Evidence";
`previous:` in `re-review-prompt.md`, section "Test Run"; none in
`code-reviewer.md`, section "Test Run", which has no prior count.

**A form inside a subagent's `## Output Format` is unified in place, never
extracted — and then charged by a gate.** The measured exception to "at a third
occurrence, extract it": `references/escalation-format.md:9-11` records it at
1/3, then 3/3 once the form returned to the point of use. **Without the gate,
"unified in place" is just "copied"** — `scripts/check-evidence-line.sh` compares
the five carriers' fields, tolerating formatting. (Line number: no heading.)

**Anchor by `file:line` for code and artifacts that do not move because of what
we write; by file plus section title — the form above — for a file of this
repository we edit every release.** `check-links.sh` proves the section only
where `SECTION_TARGETS` reaches — this file alone. Under `skills/` the form has
no gate, and twice an instruction has asked `file:line` where the rule asks the
section: **on a third, the finding is that the rule needs a gate.**

## Relationship with Superpowers

**This project does not pull from the upstream.** `obra/superpowers` is where this code came from and the reason the MIT attribution exists — the owner decided on 2026-08-05 that it stops being a source of updates. The `upstream` remote may stay for consultation, and `git diff upstream/main` still answers where a file came from, but no rebase is planned and none is owed.

**Rebase cost is not a criterion in any decision here.** Not for touching a file they also maintain, not for how a change is shaped, not for whether a fix is worth making. Every rule that reached for it lost its foundation the day this was decided: it gets rewritten on its own merits or it goes, and it is never left standing on a reason that no longer exists. When you find one, that is the finding — say so rather than working around it.

**The attribution does not move, and this is not the same question.** [`LICENSE`](LICENSE) and the credit at the top of this file are a license obligation on code that came from them, independent of whether anything is ever pulled again. Every file here that originated upstream stays MIT under their copyright. Ending the sync does not end the credit.

**What the old rule about their tests was protecting no longer exists.** Upstream tests were kept as written so they would keep detecting the upstream's decisions — telemetry, defaults, policy. Nothing consumes that signal now. A test here is judged like any other file of this project: it asserts what this project decided, or it changes, or it goes.

## What does not belong here

- **Third-party dependencies.** This is a zero-dependency plugin. A change needing an external tool or service belongs in its own plugin.
- **Fabricated content.** Invented claims, made-up problem descriptions, hallucinated functionality. If you cannot describe the specific session, error, or experience that motivated a change, do not make it.
- **Project-specific or personal configuration.** Skills, hooks, or config that only benefit one project, team, or workflow.
- **Domain-specific skills.** Ask: "would this help someone working on a completely different kind of project?" If not, it goes in a standalone plugin.
- **Bundled unrelated changes.** One problem per commit.

**`docs/PLUS-CHANGELOG-historico.md` is a frozen record and takes no new writing.** Everything new goes in `CHANGELOG.md`, including closing an open gap.

## Preparing a commit

**Never chain content preparation and `git commit` in one `&&` block.** Prepare,
then verify the preparation produced what you expected, then commit. A script
that edits three files and a `git commit` on the next line are independent: the
edit can fail and the commit still runs.

This is not hypothetical. A `CHANGELOG.md` edit failed on a wrong anchor, the
commit and the push ran anyway, and the change shipped without its changelog
entry — the failure was invisible because nothing was chained to it.

**A staged change under `skills/`, `scripts/`, `githooks/`, `.github/` or
`hooks/` needs `CHANGELOG.md` staged with it**, and `scripts/check-changelog.sh`
in the pre-commit hook enforces it. The rule was written above and broke inside
the same cycle: `ab1cf41` shipped that very rule *and*
`check-skill-behavior-records.sh` with no changelog line, and nobody noticed
until the version was cut and the entry had to be reconstructed from the diff.
A rule nothing enforces holds until the first busy commit. Genuinely
entry-less changes — a typo in a comment, whitespace — are what
`git commit --no-verify` is for; the gate cannot tell them apart and does not
try.

**If a commit ever visibly drags, time the checks one at a time against the baseline in [`docs/pre-commit-cost.md`](docs/pre-commit-cost.md)** — there is deliberately no automatic timer, which would be one more thing to maintain, reporting on every commit a number nobody reads.

## Versioning

Semver, from `1.0.0` on. **PATCH** for a fix that does not change how a skill behaves; **MINOR** for a new skill or a compatible new rule; **MAJOR** for anything that breaks existing artifacts or invocations — the namespace rename would have been MAJOR.

Bump with `scripts/bump-version.sh <version>`; the seven files carrying the field are declared in `.version-bump.json`. Never edit them by hand.

**One class of bump-audit warning is a false positive: a version constant in an upstream test fixture.** The audit scans the repository for the new version string and reports files that carry it without being declared. A fixture holding an arbitrary version — today `tests/codex-plugin-sync/test-sync-to-codex-plugin.sh:8`, `PACKAGE_VERSION="1.2.3"`, paired with `MANIFEST_VERSION="9.8.7"` — will eventually collide with the real version by coincidence. **Do not add the file to `audit.exclude` for this.** The warning undoes itself at the next bump, while an exclusion is permanent and blinds the whole file to a genuine leak later. Read the line, confirm it is a fixture constant, and carry on.

**`[Unreleased]` does not survive more than one cycle of work.** When it tells a
complete story — a measured correction closed, a set of leftovers cleared — cut
the version. A fat `[Unreleased]` means `main` has drifted from the last
installable release with no name describing the difference, and the only way to
know what is on `main` becomes reading the diff. It also loses entries: the
commit-preparation rule and `check-skill-behavior-records.sh` both shipped
without a changelog entry and were caught only when the version was cut.

**A release body is generated, never hand-written:** `scripts/release-notes.sh <version>` builds it from `CHANGELOG.md` — the version's section, then Open gaps, then the footer. A body assembled by hand drifts from the changelog it claims to summarize. Publishing is `gh release create` with **both guards**: `--repo rodrigopaitach/superpowersplus` and `--verify-tag`.

## Documentation hierarchy

Three README-shaped files, with different jobs. The relation, not the sizes: `docs/README.pt-BR.md` is canonical and `docs/README.en.md` translates it, `scripts/check-docs-sync.sh:14-15` names exactly those two and forces them into the same commit, and `README.md` is outside that pair. **This file keeps no measured number. It keeps the relation, or the condition.** A number that matters lives in `CHANGELOG.md`, with its date. A measured number here ages in silence and goes on reading as true, and a condition — something a command answers today — never does.

| File | Job | Gated by |
|---|---|---|
| `README.md` | **Showcase.** What somebody landing on the repository sees: what the project is, one measured example, how to install | `check-links.sh` only |
| `docs/README.pt-BR.md` | **Canonical reference documentation.** The full text; on any divergence, this file is the one that holds | `check-docs-sync.sh` + `check-links.sh` |
| `docs/README.en.md` | **Translation of the canonical one.** Never edited alone | `check-docs-sync.sh` + `check-links.sh` |

**Structural divergence between the showcase and the documentation is deliberate** — different sections, different order, different depth, because they answer different questions. Do not "harmonize" them; the sync gate covers the bilingual pair only, and extending it to the root would force the showcase to mirror a reference document. What ties the three together is their links, and those are verified: `scripts/check-links.sh` also covers the five files in `docs/` that no gate reached before.

**`check-links.sh` scans the institutional files at the root, `docs/`, and every markdown file under `skills/`.** `skills/**` was left out while the fear was rebase churn — upstream text whose relative links move when their side changes. Measured instead of assumed, 2026-08-03: every markdown link under `skills/` resolves, upstream's included — `check-links.sh` is what keeps that true — so the scan simply covers them and no design to tell a fork-owned link from an upstream one was needed. A link upstream wrote and broke is broken for this project's users exactly like one written here.

**A pointer to a file of this repository is written as a markdown link, never in backticks** — `check-links.sh` resolves link syntax and nothing else, so a real reference in backticks is one no gate has ever read; the fix is the link, not a gate. **Backticks are reserved for the paths that do not resolve on purpose, and those are never "corrected":** placeholders (`<workspace>/progress.md`), artifact paths inside your partner's own project (`docs/superpowers/specs/…`), self-references (`SKILL.md` meaning the one you are reading), and the `❌ Bad` paths `writing-skills` exists to teach you not to write. **That convention is deliberately not gated, and the reason is measured, not cost:** the backticked paths under `skills/` that resolve to nothing were counted and read one by one, and **not one of them was a defect** — the count is in `CHANGELOG.md` with its date. A gate there reports that many non-problems on every commit, which is how a gate stops being read.

**Third-party links are kept to what attribution requires** (decided 2026-08-02, applied in the same cycle: 65 → 43 across the seven documents this project owns). One link to `obra/superpowers` per document where the attribution appears; the repository's own infrastructure; nothing else. Everything a reader could want to look up is named in text instead — a name and a version identify a source without depending on somebody else's URL scheme.

**A third-party link is never fetched, but its domain is checked.** These are different questions and `check-links.sh` answers only the second. It makes no network call: a dead external link is still discovered by clicking it, and this project accepts that in exchange for a gate that cannot go red because somebody else's site is slow. The link diet is what makes this cheap — there is little left to rot.

**The diet is a gate, not a convention.** `check-links.sh` fails on a URL whose prefix is not one of four: `github.com/rodrigopaitach/`, `raw.githubusercontent.com/rodrigopaitach/`, `img.shields.io/`, and `github.com/obra/superpowers` for attribution. It reads **raw lines, fenced blocks included** — an install command naming the wrong repository is the defect this catches, and it lives inside a ```` ``` ```` block that the local-link pass blanks out. When it fails, fix the document; a URL pointing at the upstream as an install source is not a gap in the allowlist.

**`docs/PLUS-CHANGELOG-historico.md` is exempt from the diet only.** It cannot acquire a new link by construction — `check-frozen-history.sh` refuses any change to it — so watching it for new domains is a check with no function. Its local links and anchors stay checked: freezing a file does not freeze the files it points at.

**`skills/**` is exempt from the diet too, for a different reason: a skill legitimately cites vendor documentation.** Every URL under `skills/` is off-diet — upstream's vendored best-practices point at the platform docs, this fork's worked example of a citation comment points at the vendor whose call it grounds, and the rest are the same shape. The diet governs the seven documents this project hands to a reader; a skill body pointing at the vendor doc that grounds a call is the citation rule working. Their **links and anchors are checked** — only the domain policy stops at the directory boundary.

## Running `gh`

**Every `gh` invocation in this checkout carries `--repo rodrigopaitach/superpowersplus` — reads included.** Not only the outward-facing ones. This repository has an upstream remote, and `gh` resolves against the remotes, not against your intent.

The failure mode is why the rule covers reads. `gh run list --branch main` here returned runs from **`obra/superpowers`** — a month old, `conclusion: success`, formatted exactly like the answer being looked for. Nothing errors. Taken at face value it confirms a CI run that never happened, on a repository nobody pushed to. A wrong write announces itself; a wrong read is indistinguishable from a right one.

`gh release create` additionally takes `--verify-tag`, so a mistyped tag fails instead of being created.

**Waiting on CI means waiting on a SHA, never on `gh run list --limit 1`.** The newest run is not the run you pushed: between the push and the query there is a gap in which the list still holds the *previous* run, already concluded, already green. That is what happened here — the answer read as a pass for a commit CI had not started on yet, and nothing about it looked wrong. Ask for the run whose `headSha` is the commit you pushed, and treat "no run yet" as *not yet*, not as failure:

```bash
sha="$(git rev-parse HEAD)"
gh run list --repo rodrigopaitach/superpowersplus --commit "$sha" \
  --json status,conclusion,headSha
```

## Changing a skill

Skills are not prose — they are code that shapes agent behavior. Carefully-tuned content (Red Flags tables, rationalization lists, "human partner" language) is not reworded without evidence the change improves outcomes.

**A `SKILL.md` stays under 500 lines, and `scripts/check-skill-size.sh` enforces it.** The number is borrowed, not measured here — "Keep SKILL.md body under 500 lines for optimal performance" is Anthropic's own guidance, vendored in this checkout at `skills/writing-skills/anthropic-best-practices.md:241` and repeated at `:1109` as a checklist item nothing ever ran. This project did not pick a stricter number, because it has no measurement that would justify one, and inventing a tighter limit by argument is the move its own Open gaps entry refuses. The gate counts the whole file, frontmatter included — about five lines stricter than the rule as written, which is not the failure it guards against.

**The fix for a red is progressive disclosure, never compression.** Move what a run does not need until it needs it into `references/`, and leave the trigger that sends the reader there: a pointer nobody is told to follow is a deletion. `subagent-driven-development/SKILL.md` is the worked case: it has been cut twice this way, both times into `references/`, with every trigger left behind in `SKILL.md` as an imperative. The line counts of each pass are in `CHANGELOG.md`, dated.

**`skills/writing-skills/SKILL.md` is exempt, and it is the only entry.** **The exemption holds while the file is the upstream's, and falls the day it stops being.** `git diff upstream/main -- skills/writing-skills/SKILL.md` answers that now and never ages: today it returns the namespace rename and nothing else. Anything beyond that rename means this project has begun owning the file's content, and the exemption goes with it. Cutting it means rewriting a file the upstream maintains for a gain that belongs in somebody else's repository. Remove the exemption the day this project starts owning that file's content — never to make a red go away.

Adversarial skill-behavior tests live at [`tests/skill-behavior/`](tests/skill-behavior/) — a fixture, the input carrying it, and a recorded result per rule. Read its `README.md` before adding one. Plugin-infrastructure tests are at `tests/`, run via each directory's own `run-*.sh`.

**`tests/codex/test-package-codex-plugin.sh` only tells the truth on a clean tree.** The packager builds its archive from a git ref — `REF="HEAD"` at `scripts/package-codex-plugin.sh:15`, and `--allow-dirty` (which the test passes) permits a dirty tree while still packaging the ref. The test then reads its expected values from the *working tree*, at `tests/codex/test-package-codex-plugin.sh:175-176`, and compares the two at line 177. With anything uncommitted the two sources disagree and `archive manifest preserves source hooks` fails with no defect present — measured: staging a `9.9.9` version locally produced `expected: 9.9.9` against `actual: 1.2.0`, and reverting made it green. Run this suite after committing. It has cost two debugging detours already, and the reason it was left alone — somebody else's file — is no longer one: fixing it is ordinary work on a file this project owns, available to whoever takes it. CI runs every static suite on every push: `brainstorm-server`, `shell-lint`, `hooks`, `codex-plugin-sync`, `antigravity`, `codex`, `systematic-debugging`, `kimi`, `opencode` and `pi`, plus shell lint, the bilingual-docs sync check, the `SKILL.md` line ceiling, and the integrity check on the adversarial records. The three that stay out all dispatch a live agent — `claude-code`, `explicit-skill-requests`, `skill-behavior` — which costs tokens and is non-deterministic. A suite CI does not run blocks nothing; if you add one, add its step.

**`dispatching-parallel-agents` is orphaned in the invocation graph on purpose.** No `SKILL.md` names it — the one place that does is `skills/using-superpowers/references/codex-tools.md:10`, listing which harness tools it needs, which routes nothing to it — and a sweep for dead references will keep surfacing it. It fires on its description — the harness matches the work at hand against the frontmatter — which is how a skill that applies to *any* fan-out gets reached without every caller listing it. Do not "fix" it by wiring an invocation in: a reference from one skill would suggest that skill is where parallel dispatch belongs.

**`escalation-format.md` sits just over its length target, and that is closed by decision, not outstanding.** The line to cut was looked for and every block carries distinct normative content: the scope boundary, why the file exists, why item 4 is an action rather than a quality bar (the lesson that was measured failing twice), gate vocabulary, the self-test, and the worked example. Cutting to reach the number costs content the file exists to carry. It does not need re-reporting.

Most rules in this project are reasoned, not measured. When you add one, say which it is.
