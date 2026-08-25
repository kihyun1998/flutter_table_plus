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

## Code

`widgets/flutter_table_plus.dart` — `FlutterTablePlus`
`widgets/row_lookup.dart` — `RowLookup`
`models/table_column.dart` — `TablePlusColumn`

## Reference behaviour

**None.** Flutter's `DataTable` identifies rows positionally; that difference is
deliberate here but has never been written down as a comparison.

## Cross-cutting invariants

**None.**

## Blast radius

→ [Row selection](row-selection.md) — a selection *is* a set of these ids
→ [Drag selection](drag-selection.md) — `idsBetween` produces them from positions
→ [Merged rows](merged-rows.md) — a group has its own id space layered over row ids
→ [Cell editing](cell-editing.md) — an edit is reported as (row id, column key)
→ [Row rendering and geometry](row-render-geometry.md) — index↔row mapping lives there and must agree with identity here

## Known holes / open

**None.**
