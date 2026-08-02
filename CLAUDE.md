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
| **Never rename `docs/superpowers/specs/` or `docs/superpowers/plans/`.** | Those are artifact paths inside your partner's own projects. Renaming them orphans every spec and plan already written |
| **Skills name actions, not tools.** Do not edit skill bodies to fit a harness. | One skill body has to run on every harness |
| **`evals/` is gitignored and absent from this checkout.** | It is a separate repository. Nothing here depends on it |

## Rebase relationship with Superpowers

The upstream remote stays, and rebasing onto `obra/superpowers` is how their improvements arrive. That has one standing consequence:

**Touch the minimum of the files the upstream edits often.** Every line rewritten in a file they also maintain is a conflict at the next rebase. Prefer additive blocks in regions they do not touch; when a line must change, change that line and not its neighbors. `README.md` is this project's own now, but the rule still holds for `skills/`, `RELEASE-NOTES.md`, and everything under `tests/` that came from them.

**Do not edit an upstream test to assert the opposite of what it asserts.** A test rewritten to match this project stops detecting the upstream's changes — it conflicts *and* loses the signal. Two currently fail because of the namespace rename (`tests/codex/test-marketplace-manifest.sh:36`, `tests/kimi/test-plugin-manifest.sh:24`); they are left failing on purpose.

## What does not belong here

- **Third-party dependencies.** This is a zero-dependency plugin. A change needing an external tool or service belongs in its own plugin.
- **Fabricated content.** Invented claims, made-up problem descriptions, hallucinated functionality. If you cannot describe the specific session, error, or experience that motivated a change, do not make it.
- **Project-specific or personal configuration.** Skills, hooks, or config that only benefit one project, team, or workflow.
- **Domain-specific skills.** Ask: "would this help someone working on a completely different kind of project?" If not, it goes in a standalone plugin.
- **Bundled unrelated changes.** One problem per commit.

**`docs/PLUS-CHANGELOG-historico.md` is a frozen record and takes no new writing.** Everything new goes in `CHANGELOG.md`, including closing an open gap.

## Versioning

Semver, from `1.0.0` on. **PATCH** for a fix that does not change how a skill behaves; **MINOR** for a new skill or a compatible new rule; **MAJOR** for anything that breaks existing artifacts or invocations — the namespace rename would have been MAJOR.

Bump with `scripts/bump-version.sh <version>`; the seven files carrying the field are declared in `.version-bump.json`. Never edit them by hand.

## Changing a skill

Skills are not prose — they are code that shapes agent behavior. Carefully-tuned content (Red Flags tables, rationalization lists, "human partner" language) is not reworded without evidence the change improves outcomes.

Adversarial skill-behavior tests live at [`tests/skill-behavior/`](tests/skill-behavior/) — a fixture, the input carrying it, and a recorded result per rule. Read its `README.md` before adding one. Plugin-infrastructure tests are at `tests/`, run via each directory's own `run-*.sh`. CI runs the `brainstorm-server` suite, shell lint, and the bilingual-docs sync check on every push.

Most rules in this project are reasoned, not measured. When you add one, say which it is.
