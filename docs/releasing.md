# Cutting a release

Read when cutting a version. [`CLAUDE.md`](../CLAUDE.md) carries the rules that
guard an act — what counts as PATCH, that the bump goes through the script, that
the release body is written to a file and never redirected into one. This file
carries what you consult once, at the moment.

## The bump audit's one false positive

`scripts/bump-version.sh <version>` writes the files declared in
`.version-bump.json`, then scans the repository for the new version string and
reports any file carrying it without being declared.

**A version constant in a test fixture is a false positive, and it is the only
class that is.** A fixture holding an arbitrary version — today
`tests/codex-plugin-sync/test-sync-to-codex-plugin.sh:8`, `PACKAGE_VERSION`,
paired with a deliberately different `MANIFEST_VERSION` — will eventually
collide with the real version by coincidence.

**Do not add the file to `audit.exclude` for this.** The warning undoes itself
at the next bump; an exclusion is permanent and blinds the whole file to a
genuine leak later. Read the line, confirm it is a fixture constant, carry on.

## What `[Unreleased]` costs when it grows

The rule is in [`CLAUDE.md`](../CLAUDE.md): it does not survive more than one
cycle of work. What it costs is measured. Two changes shipped with no changelog
entry at all — the commit-preparation rule and `check-skill-behavior-records.sh`
— and neither was noticed until the version was cut and the entries had to be
reconstructed from the diff. A fat `[Unreleased]` does not only mean `main` has
drifted from the last installable release with no name describing the
difference; it loses entries on the way.

## The SKILL.md ceiling exemption

[`check-skill-size.sh`](../scripts/check-skill-size.sh) holds exactly one
exemption, `skills/writing-skills/SKILL.md`, and **it runs on a deadline rather
than a condition.** It held while that file was the upstream's — a test that
stopped meaning anything the day this project stopped pulling from them. It now
holds while the file's structural review is open, and it falls when the review
closes, whatever the review decides.

The dossier that review will consume is in [`CHANGELOG.md`](../CHANGELOG.md)
under Open gaps, so it does not start from zero. Removing the exemption to make
a red go away, before that review, is the one thing it does not authorise.
