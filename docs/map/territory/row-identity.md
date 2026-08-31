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
  from — is built from the pair and dropped when `data` is a *different object*.
  `rowId` is compared nowhere in the package.
  - **That is a decision with a measured reason, not an omission.** `rowId` is
    **required**, so every call site writes an inline closure — all fifteen in
    this repo's own example do — and an inline closure is a new object on every
    build even when it captures nothing. Measured 2026-08-31 across two builds
    of one element, **under `identical`**: an inline non-capturing lambda, an
    inline capturing lambda and a `State` method tear-off all come back
    `false`; only a top-level or `static` tear-off is stable. Watching it would
    drop every cache on every build for every caller.
    - **`==` is not the same measurement, and the difference is a live
      question.** On the same four shapes `==` agrees with `identical` on both
      closures and differs on the instance tear-off, where it is `true` because
      it is the same function on the same receiver. So `==` is never *less*
      discriminating here than `identical` — which is worth holding against
      `rowMeasurementChanged`'s own comment, where the choice of `identical` is
      justified by a hazard `==` does not actually have.
  - **So changing the id space is a change to `data`**, signalled the same way:
    pass a new list. That is the obligation Flutter states four times over for
    lists — `SliverChildListDelegate.children`,
    `TwoDimensionalChildListDelegate`, `MultiChildRenderObjectWidget.children`,
    and `PlatformMenuBar.menus`, the last being a list of non-Widget data
    objects and so the nearest documented shape to `mergedGroups`. It states it
    **nowhere for a function**, because where the SDK takes one it either
    compares it (`ListWheelChildBuilderDelegate.shouldRebuild`) or caches
    nothing from it (`AnimatedList` reads `itemBuilder` live). This package is
    on neither side by construction, which is what the contract closes.
  - **Unmet, the failure is a divergence and not a lag.** Measured: the rows on
    screen and the selection highlight follow the new `rowId` live, while the
    drag callbacks keep reporting ids from the space the caller abandoned.
- **Exactly two caller-supplied functions have cached results, and they are
  treated oppositely.** `rowId` is excluded by the contract above;
  `calculateRowHeight` is watched by `rowMeasurementChanged`, and can be
  because most callers leave it `null` and `identical(null, null)` holds. Of
  the **nineteen** function-typed parameters on the public widget the other
  seventeen are called live at build; a twentieth that starts caching its
  result inherits this question.
  - **Optional-vs-required is the wrong axis to state the rule on**, even
    though it is what separates these two in practice. What decides
    watchability is how the caller *writes* the argument: an optional parameter
    passed as an inline closure is exactly as unwatchable, and
    `playground_page.dart` pays that cost for `calculateRowHeight` on every
    build today. A required `rowId` passed as a top-level tear-off would be
    watchable.
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
