# Row selection

## What it is

Which rows are selected, how a tap or a checkbox changes that, single versus
multiple mode, and the tri-state select-all checkbox in the header. The set
itself is the caller's — the package renders it and reports requested changes.

## Governing decisions

**None.**

Nothing records why selection is caller-owned state rather than internal, nor why
tap-to-select and checkbox-to-select are separate callbacks
(`onRowSelectionChanged` vs `onCheckboxChanged`) when both change the same set.
That separation is load-bearing for callers that treat the two gestures
differently, and it is currently discoverable only from the signature list.

## Design model

- **The set comes in, changes go out.** `selectedRows` is rendered; the package
  never mutates it.
- **Select-all is derived, never stored.** `selectAllState` maps
  (total, selectedCount) to checked / unchecked / indeterminate, so the header
  checkbox cannot disagree with the rows.
- **Single mode is a policy, not a different mechanism** — the same callbacks
  fire; what changes is what the caller is expected to do with them.
- **The checkbox column is a column**, laid out and width-resolved like any
  other, which is why hiding it is a column concern and not a selection one.

## Code

`utils/select_all_state.dart` — `selectAllState`
`widgets/cells/table_plus_selection_cell.dart` — `TablePlusSelectionCell`
`widgets/table_header_cell.dart` — `SelectionHeaderCell`
`models/table_column.dart` — `SelectionMode`
`models/theme/checkbox_theme.dart` — `TablePlusCheckboxTheme`

## Reference behaviour

**None.** The checkbox itself is `flutter_checkbox`'s (a sibling package under
`../`), and its behaviour has never been pinned here — only consumed.

## Cross-cutting invariants

→ [Do not work around an upstream contract here](../invariant/upstream-contract.md) — the checkbox is a sibling package's, and its floor is ours the moment we raise the constraint

## Blast radius

→ [Drag selection](drag-selection.md) — the other producer of the same set; a change to selection semantics lands in both
→ [Row identity](row-identity.md) — the set is ids, so identity rules bind
→ [Row interaction](row-interaction.md) — tap-to-select shares the gesture path with double tap and secondary tap
→ [Column width resolution](column-width.md) — the checkbox column participates in width resolution
→ [Theme system](theme-system.md) — checkbox theming has its own sub-theme and its own Material-3 factory

## Known holes / open

**None.**
