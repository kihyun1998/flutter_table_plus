# A caller's function is not a cache key

## The fact

A function this package receives from a caller is compared by **identity**, and
a caller who writes it inline hands over a new object on every build. Dart
offers no way around that: `==` on a tear-off asks whether the two **receivers**
are `identical`, never whether they are `==`. Measured 2026-09-04 with
non-`const` instances — `const` ones canonicalise, which is how the first probe
of this question deceived itself by comparing one object with itself:

```
a == b   (value-equal receivers)   true
identical(a, b)                    false
fa == fb (their tear-offs)         false
fa == fa (one receiver, twice)     true
```

So **a cache keyed on a caller's function is keyed on how the caller happened to
build it**, not on what it computes. Two callers writing the same behaviour get
opposite performance, and nothing in the type system distinguishes them.

Two escapes exist, and this package uses both:

- **Compare the answers, not the function.** Cheap when the answers are cheap.
- **Key on the values the computation consumes**, so the memo and the
  computation cannot list different inputs.

And there is a third case where neither is available, which is why this is an
invariant and not a rule: **when obtaining the answers is itself the cost you
were trying to avoid.** Then the only remaining move is to say so.

## Why it is cross-cutting

**Three caller-supplied functions, no call path between any two of them**, each
decided on its own:

| the function | how it is watched | why that one |
|---|---|---|
| `rowId` | **its answers** — the ids are re-derived and compared | required, so every caller writes it inline; comparing the closure would drop every cache on every build |
| the cell's text measurement | **the values it consumes** — a `TextMeasurement` record | the inputs are all values, so the key can be complete rather than curated |
| `calculateRowHeight` | **the function, by `==`** | optional, so it is usually the same `null` twice; and deriving its answers *is* the expensive walk |

The three look like three unrelated decisions and are one. Two of them were
decided wrong first: the overflow memo keyed on a hand-picked `(text, width)`
pair and went stale on a style change, and the height callback's documented
wiring made it differ on every build. The one that was right from the start is
the one whose answers were cheap.

**And the symptom differs at every site**, which is why it was never recognised
as one fact: a stale tooltip verdict, a cache that never drops, a cache that
always drops. Three reports that read as unrelated.

## Territories it holds in

→ [Row identity and data binding](../territory/row-identity.md) — `rowId` is required, so the closure is always new; its answers are compared instead, completely rather than sampled (#135)
→ [Text overflow detection](../territory/text-overflow.md) — the memo keys on the `TextMeasurement` the layout consumes, after a `(text, width)` key left wrong verdicts standing across a style or text-scale change (#156)
→ [Row height](../territory/row-height.md) — the one site where neither escape is available, because the answers are the cost; the repair is a debug diagnostic rather than a mechanism (#161)

## What a violation looks like

**A field of function type on either side of a comparison that decides whether a
cache is dropped.** The tell is literal: `oldWidget.someCallback !=
widget.someCallback`. It is not automatically wrong — it is right for
`calculateRowHeight` — but it is always a claim about the *caller's* build
discipline, and it has to be documented at the parameter as one.

**The inverse hides better: a value type with a function among its fields.**
`listEquals` over a `List<TablePlusColumn>` cannot work, because `valueAccessor`
is a function; and measured, adding a hand-written `==` to that class does not
rescue it — an inline accessor still compares unequal. So a configuration object
is only as value-comparable as its least value-comparable field, and a class
that grows a callback silently stops being a key.

**The probe that checks any of this must not use `const`.** Two `const`
instances with identical arguments are the same object, so the comparison
succeeds for a reason that will not survive the caller passing one runtime
value. Worse, the analyzer pushes callers toward `const`: measured, adding the
keyword flips the answer with nothing else changed, so a fast path can exist by
lint accident and vanish without a diff.

## Discovery history

**Three issues, and the order matters — each one made the next one visible.**

**#135** settled `rowId`: the contract had said comparing the answers was
impossible here, which was true only until `computeRenderableIndices` was fixed
in the same change. The reason had an expiry date and outlived it by three
months in four documents, because nothing reclaims a rationale.

**#156** settled the overflow memo, but the finding was not the fix. The key was
`(text, width)` — a hand-written subset of what the answer depends on — so a row
becoming selected left the previous verdict in place. Replacing it with the
measurement itself means "the memo and the measurement cannot list different
things, because there is only one list."

**#161** is the case with no mechanism, and it is where the three were seen as
one. The proposal was to give `calculateRowHeight` a value type with an `==`.
Probed rather than argued: the value object compares equal only when the caller
already holds their columns stable — which is the same discipline as holding the
callback stable, and therefore buys nothing for a breaking signature change.

## Where it will recur

**Every new caller-supplied function on a public widget.** Mechanical:
`rg 'final .*Function\(' lib/src/widgets/` and, for each hit, ask what drops
when it changes and whether the caller can reasonably hold it stable. A
*required* callback can never be held stable by every caller — that is what makes
`rowId` different in kind from `calculateRowHeight`, not just in degree.

**And every new memo or cache key.** Ask whether each field of the key is a
value. One function among them makes the whole key an identity check wearing a
value type's clothes, which is worse than an honest identity check because it
reads as if it works.

**The trap that hides it is that both failure modes are silent.** A key that is
too strict drops caches forever and only shows up as a frame budget; a key that
is too loose keeps a stale answer and only shows up as a wrong pixel. Neither
throws, and a test that builds its fixture once cannot see either — the fixture
has to rebuild the callback the way a caller's `build` does.
