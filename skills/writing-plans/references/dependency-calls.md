# Code That Calls a Dependency

Every code block here is transcribed, not interpreted: `scripts/task-brief`
extracts the task verbatim and the controller hands it over as "your
requirements, with the exact values to use verbatim". A signature you
half-remembered reaches the implementer labeled as fact, and the first thing
to disagree with it is the running system.

superpowersplus:brainstorming grounds every claim the spec makes about a
library, external API, or third-party service in one of two forms: the
lockfile-pinned version plus the line you read inside the dependency, or the
vendor's official documentation for that version. A step whose code calls
that dependency carries the same source, in the same forms.

| In the step | What it carries |
|-------------|-----------------|
| Code the spec already grounded | The spec's citation, copied into the block as a comment |
| A signature, field name, error code, header, status, or default the spec never stated | Its own source, in one of the two forms. The spec settled the design, not every symbol you now have to type |
| A call you could not ground at either source | Not a step. Take it to your human partner with what you tried — same routing as an unverifiable claim in the spec |

**An unreachable source is not an approval.** Writing the call anyway
inverts the cost: it reaches the implementer as an exact value, the reviewer
sees code that looks deliberate, and the disagreement surfaces at
integration.

The citation and the code have to be the same language: a JavaScript source
cannot ground a Python call, however real the line it points at.

A pinned-source citation names a path you opened in this checkout, never one
you expect to be there. A directory that exists in the vendor's repository
is routinely absent from the published tarball — `stripe`'s `src/*.ts` on
GitHub ships as `cjs/*.js` in `node_modules` — and the reviewer opens what
you cite.

```javascript
// stripe@19.1.0 — https://docs.stripe.com/api/idempotent_requests
// create(params, options): the idempotency key is a request option,
// never a param — RequestOptions.idempotencyKey sets the
// Idempotency-Key header.
const intent = await stripe.paymentIntents.create(
  {amount: 1200, currency: 'brl'},
  {idempotencyKey: key},
);
```
