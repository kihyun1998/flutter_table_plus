# CLAUDE.md

## Working discipline — theflow

Substantive changes (bug fix / feature / behavior change) follow the **`theflow`**
skill — run `/theflow` at the start. This repo's bindings (module map, reference
routing, boundary rule, proof methods, surfaces, gate matrix) live in
**`docs/agents/theflow.md`**; the per-incident evidence (#33, #50–#52, #55,
#58–#65, #69, #88→#96 …) in **`docs/agents/lessons.md`**. Read both before
starting; add new war-stories to lessons.

The successor skill **`thegraph`** also has a compiled build here —
**`docs/agents/thegraph.md`** — so `/thegraph` runs against this repo's own node
graph (which nodes exist, each one's guard and decider) instead of a fixed step
list. It reads the same bindings and the same lessons. **The two coexist**: use
either, and add war-stories to `lessons.md` regardless of which one you ran.

## Package philosophy

Flutter Table Plus is a **UI-only, data-agnostic** table widget: synchronized
scrolling, theming, sorting, selection, column reorder/resize, cell editing,
merged rows. It does **not** manage or mutate your data.

1. **No data management** — sort/filter/paginate stay with you.
2. **Callback-driven** — interactions come back as callbacks; you decide.
3. **Convenience first** — ready-made helpers with sensible defaults; always opt-out-able.
4. **State-management agnostic** — setState / Provider / Riverpod / Bloc alike.

## Identity & invariants (the boundary)

- **Generic, data-agnostic rows.** `FlutterTablePlus<T>` takes `List<T>`; identity
  comes from the required `rowId: String Function(T)`. Columns read via `valueAccessor`.
- **Synchronized scrolling.** Header/body/scrollbar each scroll horizontally;
  `SyncedScrollControllers` keeps them aligned — the **body is the input master**,
  the header uses `NeverScrollableScrollPhysics`.
- **Drag selection is one viewport-local coordinate frame.** A `Listener` sits
  *outside* the body's horizontal `Scrollable`, so `event.localPosition` is
  viewport-local on both axes. The gesture state machine, auto-scroll `Timer`, and
  rubber-band geometry live in a `DragSelectionController` (unit-testable in
  isolation); row lookups go through the narrow `RowLocator` port the body implements.
- **`scaledBy()` is built on `copyWith`** and names only the six sub-themes it
  scales — the scrollbar and three tooltip themes are never enumerated, so a field
  added later cannot be dropped by forgetting to list it. Hand-listing is exactly
  how `rowTooltipTheme` went missing (#50).
- **Tooltips are arbitrated by `just_tooltip`, not here.** Nesting = innermost
  wins, and since 0.4.4 "innermost" means *the innermost tooltip with something to
  draw*. `^0.4.4` is a **floor, not a preference** — the old local
  empty-message guard is gone (#96). A row tooltip uses `TooltipAnchor.pointer` as
  a **correctness requirement** (a row is `contentWidth` wide, so hover region ≠
  anchor), not a workaround. `just_tooltip` / `flutter_checkbox` sources sit at
  `../` — read them, don't guess from pub docs.

## Environment

Claude Code and the user share the same Windows machine; the Flutter SDK is on
`PATH`, so run `flutter test` / `analyze` / `dart format` directly. Ask the user
only for anything that opens a window (`flutter run`). **There is no CI** — the
gates in `docs/agents/theflow.md` (Step 7) are the only gates and run here.

## Agent skills

### Issue tracker
Issues are tracked in this repo's GitHub Issues via the `gh` CLI; external PRs
are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels
Default vocabulary (`needs-triage` / `needs-info` / `ready-for-agent` /
`ready-for-human` / `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs
Single-context: `CONTEXT.md` + `docs/adr/` at the repo root (created lazily). See
`docs/agents/domain.md`.
