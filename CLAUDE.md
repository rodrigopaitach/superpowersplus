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

Each face in the review chain runs something different. They are **not one rule
written four ways** — unifying them into a common protocol would change the
reach of three gates at once. Do not harmonize.

| Face | What it actually runs |
|---|---|
| `subagent-driven-development/task-reviewer-prompt.md:69` | The **task's** test command, `[TEST_COMMAND]`, reported verbatim |
| `requesting-code-review/code-reviewer.md:52` | The **project's** suite, with a fallback to the command the dispatch named |
| `subagent-driven-development/re-review-prompt.md:58` | **Re-runs** what already ran, reporting command, exit code, and counts |
| `final-branch-audit/SKILL.md:221` | **No tests at all** — re-runs the *searches* against the spec |

The evidence block `**Command:** [verbatim] — **exit:** [code] — **counts:** …`
appears in `re-review-prompt.md:81` and `code-reviewer.md:85` and must stay
identical in both. Two occurrences do not justify extraction; at a third,
extract it.

## Rebase relationship with Superpowers

The upstream remote stays, and rebasing onto `obra/superpowers` is how their improvements arrive. That has one standing consequence:

**Touch the minimum of the files the upstream edits often.** Every line rewritten in a file they also maintain is a conflict at the next rebase. Prefer additive blocks in regions they do not touch; when a line must change, change that line and not its neighbors. `README.md` is this project's own now, but the rule still holds for `skills/`, `RELEASE-NOTES.md`, and everything under `tests/` that came from them.

**Do not edit an upstream test to assert the opposite of what it asserts.** A test rewritten to match this project stops detecting the upstream's changes — it conflicts *and* loses the signal.

The line to draw is what the assertion *watches*. A test asserting this package's own name held an obsolete fact after the rename and watched nothing upstream decides — `db91242` updated both (`tests/codex/test-marketplace-manifest.sh`, `tests/kimi/test-plugin-manifest.sh`) and they pass. A test asserting an upstream *decision* — telemetry, a default, a policy — is the one to leave failing.

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

Three README-shaped files, with different jobs. Measured, not assumed: `README.md` is 170 lines, each `docs/README.*` is 153, and `scripts/check-docs-sync.sh:14-15` names exactly two files.

| File | Job | Gated by |
|---|---|---|
| `README.md` | **Showcase.** What somebody landing on the repository sees: what the project is, one measured example, how to install | `check-links.sh` only |
| `docs/README.pt-BR.md` | **Canonical reference documentation.** The full text; on any divergence, this file is the one that holds | `check-docs-sync.sh` + `check-links.sh` |
| `docs/README.en.md` | **Translation of the canonical one.** Never edited alone | `check-docs-sync.sh` + `check-links.sh` |

**Structural divergence between the showcase and the documentation is deliberate** — different sections, different order, different depth, because they answer different questions. Do not "harmonize" them; the sync gate covers the bilingual pair only, and extending it to the root would force the showcase to mirror a reference document. What ties the three together is their links, and those are verified: `scripts/check-links.sh` also covers the five files in `docs/` that no gate reached before.

## Running `gh`

**Every `gh` invocation in this checkout carries `--repo rodrigopaitach/superpowersplus` — reads included.** Not only the outward-facing ones. This repository has an upstream remote, and `gh` resolves against the remotes, not against your intent.

The failure mode is why the rule covers reads. `gh run list --branch main` here returned runs from **`obra/superpowers`** — a month old, `conclusion: success`, formatted exactly like the answer being looked for. Nothing errors. Taken at face value it confirms a CI run that never happened, on a repository nobody pushed to. A wrong write announces itself; a wrong read is indistinguishable from a right one.

`gh release create` additionally takes `--verify-tag`, so a mistyped tag fails instead of being created.

## Changing a skill

Skills are not prose — they are code that shapes agent behavior. Carefully-tuned content (Red Flags tables, rationalization lists, "human partner" language) is not reworded without evidence the change improves outcomes.

Adversarial skill-behavior tests live at [`tests/skill-behavior/`](tests/skill-behavior/) — a fixture, the input carrying it, and a recorded result per rule. Read its `README.md` before adding one. Plugin-infrastructure tests are at `tests/`, run via each directory's own `run-*.sh`.

**`tests/codex/test-package-codex-plugin.sh` only tells the truth on a clean tree.** The packager builds its archive from a git ref — `REF="HEAD"` at `scripts/package-codex-plugin.sh:15`, and `--allow-dirty` (which the test passes) permits a dirty tree while still packaging the ref. The test then reads its expected values from the *working tree*, at `tests/codex/test-package-codex-plugin.sh:175-176`, and compares the two at line 177. With anything uncommitted the two sources disagree and `archive manifest preserves source hooks` fails with no defect present — measured: staging a `9.9.9` version locally produced `expected: 9.9.9` against `actual: 1.2.0`, and reverting made it green. Run this suite after committing. It has cost two debugging detours already; it is upstream's file and is not fixed here. CI runs every static suite on every push: `brainstorm-server`, `shell-lint`, `hooks`, `codex-plugin-sync`, `antigravity`, `codex`, `systematic-debugging`, `kimi`, `opencode` and `pi`, plus shell lint, the bilingual-docs sync check, and the integrity check on the adversarial records. The three that stay out all dispatch a live agent — `claude-code`, `explicit-skill-requests`, `skill-behavior` — which costs tokens and is non-deterministic. A suite CI does not run blocks nothing; if you add one, add its step.

Most rules in this project are reasoned, not measured. When you add one, say which it is.
