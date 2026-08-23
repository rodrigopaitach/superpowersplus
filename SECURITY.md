# Security Policy

## Supported versions

**The latest release only.** superpowersplus is maintained by one person as a
single line of work: there are no maintenance branches, and no fix is
backported. A problem found in an older version is fixed in the next release
from `main`.

| Version | Supported |
|---|---|
| Latest [release](https://github.com/rodrigopaitach/superpowersplus/releases/latest) | Yes |
| Anything older | No — upgrade first, then report if it persists |

Upgrading is `/plugin marketplace update superpowersplus` followed by
`/reload-plugins`.

## Reporting a vulnerability

Two channels, both on this repository:

- **[Private vulnerability reporting](https://github.com/rodrigopaitach/superpowersplus/security/advisories/new)** — use this
  when the details themselves are the risk. The report stays private until
  there is a fix.
- **A [normal issue](https://github.com/rodrigopaitach/superpowersplus/issues)** — fine
  for anything whose disclosure costs nothing, which is most of what this
  repository can get wrong.

There is no email channel and no service-level commitment. This is a
side project; expect a human, not a rota.

Please include what an attacker gains, and the smallest reproduction you have.
**Do not include credentials, tokens, or real personal data** in either channel
— redact them, use generated values, and say what you redacted.

## What this project's threat surface actually is

Worth being precise, because "plugin" suggests more than is here. superpowersplus
is skills (Markdown that shapes agent behavior), a handful of shell and Node
scripts, and manifests. It has **no third-party dependencies**, ships no
service, and stores no credentials.

Two areas where a real issue would live:

- **The brainstorming visual companion** (`skills/brainstorming/scripts/server.cjs`)
  is a local HTTP server. It binds `127.0.0.1` by default and authenticates
  clients with a per-session key, precisely because a local port is reachable
  by any browser tab on the machine. Binding it to a non-loopback host widens
  that; the key is what defends it.
- **Skills that read external content.** A skill that fetches a page treats it
  as *data, never as instruction* — a fetched page asking the agent to do
  something is the injection case, and the rule is enforced by an adversarial
  test at `tests/skill-behavior/RESULT-external-content-is-data.md`.

## Telemetry

**superpowersplus collects nothing.** No analytics, no crash reporting, no
usage counting of its own.

One inherited exception, documented in the README rather than left for you to
find: the brainstorming visual companion loads the Prime Radiant logo from
their site with the Superpowers version in the URL. Nothing about your project,
prompt, or agent goes with it — it is a rough usage count, and both the
mechanism and the credit are Superpowers'.

**Turn it off** with any of these, honored at
`skills/brainstorming/scripts/server.cjs:107-112`:

```bash
export SUPERPOWERS_DISABLE_TELEMETRY=1
# DISABLE_TELEMETRY and CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC also work
```

**The code default is on, and superpowersplus does not ship it disabled.** The
mechanism and the credit are both Superpowers': changing the default of an
inherited feature is a product decision about somebody else's work, not a
defect repair, and the switch above is documented rather than left for you to
find. Turning it off is an action you take in your own environment.
