# Row identity and data binding

## What it is

How a row is named and how a cell's value is read out of it. `rowId` is the only
identity the package has; `valueAccessor` is the only way it reads data. Both
belong to the caller, and this territory is where that split is enforced.

## Governing decisions

**None.**

The rule is stated in `CLAUDE.md` as identity ("generic, data-agnostic rows") and
demonstrated in `docs/MIGRATION.md`, but nothing records the decision: why a
`String` id supplied by a function rather than an index, an `Object` key, or a
required interface on `T`. Every callback signature in the public API follows
from that choice.

## Design model

- **Identity is caller-supplied and stringly typed.** `rowId: String Function(T)`
  is required; the package never derives identity from position, equality, or
  hash.
- **Every callback speaks ids, not objects or indices.** Selection, drag
  selection and expansion all hand back `String` ids — which is what lets a
  caller re-sort or re-page the list without the package noticing.
- **Positions exist, but only inside a frame.** `RowLookup` maps a visual index
  to a row for rendering and hit-testing; those indices never leave the package.
- **Reading a value is delegated per column**, so the table never inspects `T`.
- **Identity is the (`data`, `rowId`) pair, and only the list's identity is
  watched.** Every id-keyed derivation — `RowLookup`'s two maps, the
  renderable-index list, and the ids the drag geometry answers `idsBetween`
  from — is built from the pair and dropped when `data` is a *different object*,
  **or when the ids it derived no longer match**. Since #135 `RowLookup.idsMatch`
  re-derives them through the current `rowId` and compares, so a swapped
  extractor, a list sorted in place and a list shrunk in place are all seen.
  What no comparison of `rowId`'s answers can see is an element replaced in
  place under the same id, and that is where the contract below still does the
  work.
  - **That is a decision with a measured reason, not an omission.** `rowId` is
    **required**, so every call site writes an inline closure — all fifteen in
    this repo's own example do — and an inline closure is a new object on every
    build even when it captures nothing. Measured 2026-08-31 across two builds
    of one element, **under `identical`**: an inline non-capturing lambda, an
    inline capturing lambda and a `State` method tear-off all come back
    `false`; only a top-level or `static` tear-off is stable. **That was
    measured in the JIT test VM** — under AOT the instance tear-off comes back
    `identical == true`, so that row does not survive a release build while the
    two lambda rows do. Watching the closure's identity would drop every cache
    on every build for every caller.
    - **`==` is the comparison `rowMeasurementChanged` uses, and the reason is
      this measurement.** On the same four shapes `==` agrees with `identical`
      on both closures and differs on the instance tear-off, where it is `true`
      because it *is* the same function on the same receiver. So `==` is never
      less discriminating here — the predicate's original comment justified
      `identical` by a hazard `==` does not have, and under it a caller writing
      `calculateRowHeight: _myHeight` dropped the height cache and the drag
      geometry on every build. Two tear-offs of the same method on *different*
      receivers still compare unequal, which is the case that had to keep
      working and is pinned by a test (#137).
  - **So changing the id space is a change to `data`**, signalled the same way:
    pass a new list. That is the obligation Flutter states four times over for
    lists — `SliverChildListDelegate.children`,
    `TwoDimensionalChildListDelegate`, `MultiChildRenderObjectWidget.children`,
    and `PlatformMenuBar.menus`, the last being a list of non-Widget data
    objects and so the nearest documented shape to `mergedGroups`. It states it
    **nowhere for a function**. It *often* either compares one
    (`ListWheelChildBuilderDelegate.shouldRebuild`) or caches nothing from it
    (`AnimatedList` reads `itemBuilder` live) — but not always, and the
    exception is the closest analogue there is. `RawAutocomplete.optionsBuilder`
    is **required**, its result is cached in `_options`, `didUpdateWidget`
    compares only the controller and the focus node, and neither it nor
    `displayStringForOption` — a caller-supplied `T` to `String` extractor — is
    compared anywhere or carries any documented obligation. The SDK does what
    this package does, in the one place it meets the same shape.
  - **That was measured as a divergence, and it is what the guard closed.** The
    rows on screen and the selection highlight followed the new `rowId` live
    while the drag callbacks kept reporting ids from the space the caller had
    abandoned — screen right, answer wrong, #128's shape. Since #135 the ids are
    compared and the swap is seen. What survives is narrower and worth keeping
    separate: an element replaced **under the same id** leaves the ids
    identical, so the index-keyed height cache still holds the pre-edit
    measurement.
- **Exactly two caller-supplied functions have cached results, and they are
  treated oppositely.** `rowId` is excluded by the contract above;
  `calculateRowHeight` is watched by `rowMeasurementChanged`, and can be
  because most callers leave it `null` and `identical(null, null)` holds. Of
  the **nineteen** function-typed parameters on the public widget the other
  seventeen are called live at build; a twentieth that starts caching its
  result inherits this question.
  - **Optional-vs-required is the wrong axis**, even though it is what
    separates these two in practice. What decides watchability *under
    `identical`* is how the caller writes the argument: an optional parameter
    passed as an inline closure is exactly as unwatchable. The worked example
    this used to cite — `playground_page.dart` paying that cost for
    `calculateRowHeight` — **is gone**: the page passes a `static` tear-off and
    its own comment records the inline version as deliberately removed. The
    argument survives without it; the demonstration does not, which is the
    ordinary fate of an example named inside a rule.
  - **And the axis was avoidable, which is what shipped.** `RowLookup.idsMatch`
    compares the *ids* rather than the function: complete however the caller
    writes the argument, and about a tenth of the rebuild it prevents — 0.971%
    of a 16.7ms frame at 10,000 rows against 10.0%, measured AOT.
    `utils/overflow_cache.dart` is the same pattern, already shipping here and
    four files away from the code that needed it.
  - **The order it landed in is the load-bearing part.** Switching the guard on
    first would have turned an in-place `RangeError` into a *silently missing
    row*, because the rebuild it triggers ran a `computeRenderableIndices` that
    dropped a group whose first key was gone — a loud failure traded for a quiet
    one, with which of the two you got depending on which member the caller
    removed. The derivation was fixed first and the guard second (#135).
- **Why the SDK does not have this problem.** There, identity rides on the data
  — a `Key` on the child — so the data's identity covers every cache derived
  from it. All three peer packages do the same: `pluto_grid` mints a
  `UniqueKey()` per row, `data_table_2` carries a `LocalKey`, and
  `two_dimensional_scrollables` uses integer coordinates and has no id
  extractor at all. Extracting identity through a separate function is this
  package's own deliberate divergence, and this contract is its cost.

## Code

`widgets/flutter_table_plus.dart` — `FlutterTablePlus`
`widgets/row_lookup.dart` — `RowLookup`
`models/table_column.dart` — `TablePlusColumn`

## Reference behaviour

Read 2026-08-31 for #132, at Flutter 3.41.9 (`00b0c91f06`) and the three
confirmed peers.

- **Flutter's `DataTable` identifies rows positionally**, and the delegates that
  do keep an id→index cache — `SliverChildListDelegate._keyToIndex` — invalidate
  it on the *source list's* identity, because the key rides on the child.
- **`SliverChildBuilderDelegate.shouldRebuild` is `=> true`** and
  `findChildIndexCallback` is therefore compared nowhere: it exists to prevent
  *state loss* on reorder, not staleness, and there is no cached map behind it.
- **`ListWheelChildBuilderDelegate.shouldRebuild` compares `builder`**, and
  `two_dimensional_scrollables`'s `TableCellListDelegate.shouldRebuild` compares
  its two span builders — so comparing a caller function is done where the
  result is cached.
- **No peer has a caller-supplied id extractor at all**, so none of them can
  answer the specific question; what they answer is why they never had to.

## Cross-cutting invariants

→ [Never hand-maintain a list a later addition must join](../invariant/no-hand-enumeration.md) — the caches keyed on identity are invalidated by a hand-written condition, and `rowId` is the input it deliberately omits (#132)

## Blast radius

→ [Row selection](row-selection.md) — a selection *is* a set of these ids
→ [Drag selection](drag-selection.md) — `idsBetween` produces them from positions
→ [Merged rows](merged-rows.md) — a group has its own id space layered over row ids
→ [Cell editing](cell-editing.md) — an edit is reported as (row id, column key)
→ [Row rendering and geometry](row-render-geometry.md) — index↔row mapping lives there and must agree with identity here

## Known holes / open

**None.**
