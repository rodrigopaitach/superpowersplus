# Escalation Format

How a decision is handed to your human partner. Generalized from the question
form in `skills/brainstorming/coverage-map.md`, which already required it for
clarifying questions.

**Scope: the machine → human boundary only.** A reviewer reporting to the
controller, or an implementer reporting to the controller, keeps its own
format — those are machines talking to machines, and gate vocabulary is
precise there. This file governs what reaches a person.

**Why it exists:** your partner may not program. They decide well given a
practical consequence, options with their cost, and a recommendation with a
declared source. They decide badly — or stall — given internal gate
vocabulary. An escalation that reads like a verdict hands them a decision they
have no basis to take.

## The four parts, in this order

1. **The finding, in one sentence of practical consequence** — what breaks,
   what costs, what ends up wrong if nothing is decided. The mechanism does
   not open the explanation; it may follow in one sentence if it helps.
2. **The options, 2–4**, each with one line of what it means in practice.
   **Always include doing nothing now, with its cost.** An escalation without
   that option is a demand wearing a question's clothes.
3. **The recommendation, with its source declared**, in the order already in
   force: a pattern in this project (`path/file.ext:line`) > the dependency's
   official documentation > general good practice, said to be general practice.
4. **Before sending, reread the whole message once**, looking for terms
   someone outside this project would not know. Rewrite each in plain
   language, or define it in the sentence that uses it. This is a step you
   perform, not a standard you aspire to: the writer is the worst judge of
   what the reader does not know, and the only way past that is to go back
   over the text once with the reader in mind.

**Gate vocabulary** — `LOST IN TRANSLATION`, `FALSE COMPLETION`,
`INVENTED SCOPE`, severity labels — may appear in parentheses as a reference
for someone who wants to trace it. It never carries the explanation.

**Self-test before sending:** could somebody who does not know this project
decide by reading only this? If not, it is not ready.

## Example

A conformance audit found a criterion no task delivered. The internal verdict
is `LOST IN TRANSLATION`. What reaches the partner:

> **The spec says a failed login gets logged with the account id, and nothing
> in this branch writes that log.** If it ships as is, the first time someone
> reports being locked out there is no record of which account it was, and the
> only way to investigate is to reproduce it live.
>
> | Option | What it means |
> |---|---|
> | Add it now (recommended) | One task, one test — the logging call and a test that asserts the account id lands in the log. Delays the merge by about one task |
> | Ship without it, add next branch | Merges today. Until it lands, lockout reports cannot be investigated after the fact |
> | Drop the requirement | The spec stops asking for it. Nothing to build, but the audit will stop flagging a gap that was deliberate |
>
> **Recommend: add it now.** Every other failure path in this project already
> logs the account id — `src/auth/session.ts:88` does exactly this for expired
> sessions. Source: a pattern already in your project.
>
> (Audit verdict for this item: `LOST IN TRANSLATION`, criterion `IR3`.)

Reply "yes" to take the recommendation.
