# Cell editing

## What it is

Turning a cell into a text field, tracking which cell is being edited, deciding
what a key press means, and reporting the committed value. The package edits a
*widget*, never the data — the new value goes out through a callback.

## Governing decisions

**None.**

Nothing records the commit rules — which key commits, which cancels, what a
focus loss does, or whether an edit survives a rebuild with different data. Those
are the questions a caller actually hits, and they are readable only from the
session and key-action sources.

## Design model

- **One session at a time.** `CellEditSession` holds which (row, column) is open
  and the controller behind it, so the body stays a pure renderer.
- **Key handling is a pure classification.** `editKeyAction` maps a `KeyEvent` to
  an `EditKeyAction` — commit, cancel, move — instead of scattering key checks
  through the widget.
- **Commit reports, it does not mutate.** `onCellChanged` (and
  `onMergedCellChanged` for a group) carries row id, column key and the new
  value.
- **Editing is per column**, gated by the column's own `editable` flag, so the
  same table can mix editable and read-only columns without a mode.
- **The open session re-pins itself by id, and only on a `data` identity
  change.** `_reconcileEditingAfterDataChange` runs from the same condition
  that rebuilds every id-keyed cache, so a list mutated in place is not seen
  and a swapped `rowId` skips the re-pin entirely — leaving a commit reporting
  an id from the previous id space. That is the caller obligation stated in
  [Row identity](row-identity.md), reaching this territory; it is part of the
  answer to the open question above about surviving a rebuild with different
  data.

## Code

`widgets/cell_edit_session.dart` — `CellEditSession`
`widgets/cells/editable_text_field.dart` — `EditableTextField`
`utils/edit_key_action.dart` — `EditKeyAction`, `editKeyAction`
`models/theme/editable_theme.dart` — `TablePlusEditableTheme`

## Reference behaviour

**None.** Flutter's own `EditableText` focus and commit lifecycle has never been
read against this session model, although the repo has tests specifically about
focus lifecycle and data swaps during an edit.

## Cross-cutting invariants

→ [Observe at the screen, assert by count](../invariant/observe-at-the-screen.md) — the edit tests are widget tests, and this is the rule that keeps them from pinning implementation

## Blast radius

→ [Row identity](row-identity.md) — a commit is reported as (row id, column key); an identity change changes the callback contract
→ [Row interaction](row-interaction.md) — entering edit mode competes with tap, double tap and selection on the same row
→ [Merged rows](merged-rows.md) — a merged cell edits through a separate callback and its own layout
→ [Column model and ordering](column-model.md) — `editable` is a column flag
→ [Theme system](theme-system.md) — the editable sub-theme styles the open field

## Known holes / open

**None.**
