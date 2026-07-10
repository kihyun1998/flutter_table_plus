## 2.15.2

*   **FIX**: a cell whose `tooltipFormatter` returns an empty string no longer swallows the `rowTooltipBuilder` card. Hovering such a cell showed nothing at all — not the cell's tooltip, not the row's
    *   A tooltip suppresses its ancestors from `MouseRegion.onEnter`, *before* it decides whether it has anything to draw, and `hideOnEmptyMessage` decides "nothing" inside `_show()`. The cell had already taken the card down. Hoisting that guard to where the cell is wrapped means a tooltip that cannot show is never built, so it cannot suppress anything. The header has guarded this way all along — an empty label gets no tooltip — but a cell's message is only known once `tooltipFormatter` has run
    *   `hideOnEmptyMessage: false` is unchanged: that asks for the empty bubble, and it still wins over the card
*   **DOCS**: `rowTooltipBuilder`'s "the whole row is the hover region" is now pinned by tests, including over a cell whose value is empty. It was never broken there — a row's `MouseRegion` is opaque and hit-tests itself, so a zero-width `Text` under the pointer changes nothing — but nothing said so, and the neighbouring `tooltipFormatter` bug looked exactly like a hole in that region. The doc comment now says which boundaries the region actually has, and which cells take the card's place
*   **DOCS**: `TablePlusTooltipTheme.hideOnEmptyMessage` was absent from `docs/THEMING.md` altogether. It was a footnote when a tooltip stood alone; it decides whether the row card appears once one nests inside another

## 2.15.1

*   **DEPS**: `just_tooltip: ^0.4.2` → `^0.4.3`. No API change — 0.4.3 declares the same public classes, enums and fields, and touches two internal files. All 378 package tests and 28 example tests pass against it unmodified, and its SDK floor is the same, so this package's Flutter 3.13 floor stands
    *   It fixes an `interactive` tooltip dying for good once the cursor returns from the tooltip body to its child ([just_tooltip#43](https://github.com/kihyun1998/just_tooltip/issues/43)). Leaving the tooltip armed a 100 ms bridge that re-entering the child never cancelled; it fired unseen, started a fade-out, and a pointer already inside the child sends no further `onEnter` to revive it. The tooltip vanished roughly 250 ms after the cursor came home and stayed gone
    *   **This was reachable from the defaults.** `TablePlusTooltipTheme.interactive` is `true` and every cell, header and row tooltip passes it. `TooltipAnchor.pointer`, added in 2.15.0, draws the tooltip beside the cursor — exactly the arrangement that walks the cursor into the tooltip body
*   **EXAMPLE**: The playground's settings panel is searchable
    *   68 controls across five sections, and no way to find one except to remember which section held it. Typing narrows the panel to the controls whose labels match; a section holding a match opens to show them, one holding none stands aside, and clearing the search restores what was open before
    *   The row card gained its own wait duration, separate from the cells'. A card interrupts more than a line of text does. Its transparent background and zero padding stay fixed: the builder draws its own surface, so a tooltip surface behind it would be a second card
    *   `Tooltip Enabled` also silences the row card, which the toggle never said. It says so now
*   **INTERNAL**: No library code changed in this release — `lib/` is byte-for-byte the 2.15.0 tree

## 2.15.0

*   **BREAKING**: minimum Flutter is now `3.13.0` (Dart `3.1.0`), up from `3.10.0`. `just_tooltip` 0.4.2 walks `RenderObject.parent`, which was `AbstractNode?` — a type with no `describeApproximatePaintClip` — before Flutter 3.13. The `just_tooltip: ^0.4.0` constraint already resolved 0.4.2, so the old floor had quietly become a promise this package could not keep; raising it is the honest fix, not the cause
*   **DEPS**: `just_tooltip: ^0.4.2`. Upstream now anchors `TooltipAnchor.child` to the *visible* part of the child, re-aims a shown tooltip when its child moves, and hides it once the child is clipped out of sight. Cell and row tooltip behaviour here is unchanged; all 378 tests pass unmodified

*   **FEAT**: `TablePlusTooltipTheme.anchor` — position a tooltip beside the cursor instead of beside the widget it wraps
    *   `TooltipAnchor.child` (the default) anchors to the visible part of the hovered widget's rect. That is wrong whenever the widget is far wider than the neighbourhood the user is pointing at: a cell in a column wider than the viewport gets a tooltip at the centre of whatever slice is on screen, wherever the cursor may be. `TooltipAnchor.pointer` keeps the same hover region and anchors at the cursor
    *   Against a point there are no target edges to align to, so under `TooltipAnchor.pointer` the `alignment` field selects which of the tooltip's *own* edges lands on the cursor
    *   `TooltipAnchor` is now re-exported, so you no longer need `just_tooltip` in your own `pubspec.yaml` to name it
    *   Row tooltips built by `rowTooltipBuilder` always anchored at the pointer and still do; they ignore this field. A row is as wide as the table's content, so a child anchor would aim at the centre of whatever slice of the row is on screen — visible, but unrelated to where along the row the cursor is
*   **FEAT**: `TablePlusTheme.headerTooltipTheme` — style header tooltips apart from cell tooltips
    *   Header and cell tooltips were styled by one `tooltipTheme`, so tooltip *behavior* was separable (`headerTooltipBehavior` vs `tooltipBehavior`) while tooltip *style* was not. With `anchor` exposed, that asymmetry bit: anchoring a header at the pointer dragged every cell along with it
    *   Nullable, and falls back to `tooltipTheme` when unset — the same shape as `rowTooltipTheme`. Leave it null and nothing changes
*   **FIX**: A scaled table no longer loses `rowTooltipTheme`
    *   `TablePlusTheme.scaledBy()` rebuilt the theme without carrying `rowTooltipTheme`, so at any `scale` other than `1.0` it went null and the documented fallback handed the row tooltip to `tooltipTheme` instead. A card styled for its own surface — transparent, unpadded — came back wearing the grey text tooltip's
    *   `scaledBy(1.0)` returns the receiver untouched, so this never fired at the default scale, which is why it went unnoticed
    *   `scaledBy()` now names only the sub-themes it actually scales and leans on `copyWith` to carry the rest, so a theme field added later cannot be dropped by forgetting to list it

## 2.14.0

*   **FIX**: Row splash / hover / highlight now use the colors you set on `TablePlusBodyTheme`, in every mode
    *   The row's ink colors were passed as `null` whenever the row was not tap-selectable — notably in editing mode — to suppress the ink. But `null` does not suppress it: `InkWell` resolves `widget.splashColor ?? Theme.of(context).splashColor`, so the table silently rendered Flutter's faint grey default instead of your theme. On a white row that default is nearly invisible, which made "no splash" and "a splash you cannot see" look identical. `TablePlusBodyTheme.splashColor` already documented the real contract: *pass `Colors.transparent` to disable*
    *   Which ink appears is now decided by which callbacks are wired, which is what `InkWell` actually gates on — a splash/highlight needs a primary-button callback, a hover highlight needs any callback. The row shell previously forwarded `onDoubleTap` / `onSecondaryTapDown` as non-null closures that merely called a possibly-null handler, so `InkWell` always looked enabled and painted a splash for a tap that did nothing. Those closures are now forwarded only when a handler exists, and the theme's colors are always passed through
*   **FEAT**: `rowTooltipBuilder` — a rich card shown while hovering anywhere on a row
    *   `FlutterTablePlus.rowTooltipBuilder(context, rowData)` returns the card, or `null` for a row that should not have one. The whole row is the hover region, so the card does not blink off as the pointer crosses columns, and it is anchored beside the pointer rather than at the row's centre — a row is as wide as the table's content, which can far exceed the viewport
    *   A cell with a tooltip of its own wins: exactly one tooltip is visible, the innermost under the pointer
    *   **`TooltipBehavior.always` — the default — leaves the card nowhere to appear.** `always` means "whenever the column is ellipsized", not "whenever the text is actually cut", so every ordinary text column already has a tooltip. Use `TooltipBehavior.onlyTextOverflow` on text columns alongside a row card
    *   Style it with `TablePlusTheme.rowTooltipTheme` (falls back to `tooltipTheme`). A card draws its own surface, so it wants `padding: EdgeInsets.zero`, a transparent `backgroundColor` and no elevation — settings that would ruin plain text tooltips
    *   Merged rows stand for several data rows, so there is no single `rowData` to build from; they carry no card
*   **FIX**: A column's `tooltipBuilder` no longer depends on the cell's text being truncated, and custom cells can finally have a tooltip
    *   The decision "should this cell show a tooltip?" was made by asking "has this cell's text been truncated?" — so a `tooltipBuilder`, whose content has nothing to do with that text, only rendered on a column that happened to be ellipsized and non-empty. Since `textOverflow` defaults to `TextOverflow.ellipsis`, this only bit columns that opt into `TextOverflow.visible`, which dynamic row heights encourage
    *   A cell built by `statefulCellBuilder` returned before the tooltip wrapper was ever reached, in the normal row and in both merged-row paths. Such a column — a status badge, say, exactly the kind that wants a rich tooltip — could not have one at all
    *   Ink for a widget tooltip now covers the whole cell, not just the text. An empty cell's `Text` is zero-wide and a short one leaves most of its cell unhoverable, so the tooltip was attached but unreachable. **Text** tooltips still belong to the glyphs: hovering the blank part of a wide column shows nothing, exactly as before
    *   `TooltipBehavior.never` still suppresses everything. For a widget tooltip, `always` and `onlyTextOverflow` both show it — "text overflow" is undefined for builder content
*   **BEHAVIOR**: Tapping a row now selects it while `isEditable` is true
    *   Tapping an **editable** column still starts editing that cell — the cell's own `GestureDetector` wins the gesture arena against the row-level tap. Tapping anywhere else on a selectable row now toggles its selection, as it does outside editing mode
    *   Row-tap selection was suppressed during editing since editing was introduced, when the two modes were mutually exclusive (`assert((isSelectable && isEditable) == false)`). That assert was removed to let them coexist, but the row guard survived, leaving a contradiction: while editing you could still select a row via its checkbox, just not by clicking it
    *   If you relied on rows not selecting on tap while editing, handle it in your `onRowSelectionChanged`
*   **PERF**: The selection cell no longer allocates its own `Material`s — up to three per row become one
    *   `TablePlusSelectionCell` wrapped its checkbox in a transparent `Material`, and its cell-tap `InkWell` in another, so that `FlutterCheckbox`'s internal `InkWell` would find a `Material` ancestor and the table would render without a `Scaffold` (#3). But `CustomInkWell` already wraps the whole row in one, and the selection cell only renders when the row is selectable — which is exactly when that row `Material` exists. Both were redundant
    *   A `Material` is not cheap: with the default `canvas` type it expands to `AnimatedDefaultTextStyle` → `AnimatedPhysicalModel` → `PhysicalModel` → `_InkFeatures`, i.e. two render objects and two implicit-animation controllers. Removing them takes a selection-enabled row from three to one
    *   Ink is still painted per row, so this is unrelated to the root-`Material` hoist rejected in #38 — that regressed scroll because it moved ink painting outside each row's `RepaintBoundary`
*   **CHORE**: Bump `just_tooltip` dependency `^0.3.0` → `^0.4.0`
    *   Picks up a fix for tooltips laid out in a nested `Navigator` or an inset `Overlay`, which were displaced by the Overlay's offset (just_tooltip#24), and reliable innermost-wins behavior for nested tooltips (just_tooltip#22). Neither is reachable from this package's current widget tree, so nothing changes here
    *   Adds `TooltipAnchor.pointer`, which #45 needs: a row tooltip must keep the whole row as its hover region while anchoring beside the cursor
*   **TEST**: The #3 regression guard now exercises the checkbox, not just its rendering
    *   `InkWell` resolves `Material.of` only when it paints ink — on tap (`_createSplash`) and on hover/press (`updateHighlight`) — so a checkbox with no `Material` ancestor builds fine and throws only when touched. The old guard pumped the table and asserted no exception, which passed for an incidental reason: the row's `Ink` demands a `Material` at build. The guard now taps the checkbox, taps the cell (`cellTapTogglesCheckbox`, previously untested), and hovers the checkbox

## 2.13.1

*   **PERF**: Rows no longer rebuild on pointer hover when there are no hover buttons
    *   Each row wrapped its content in a hover-tracking `MouseRegion` that called `setState` on every pointer enter/exit, but that state drives only the hover button. When `hoverButtonBuilder == null` (the common case), the rebuild — all cells, including tooltip overflow re-measurement — had no visible effect, and fired continuously while the mouse moved over the table during scrolling
    *   The `MouseRegion` + `setState` are now installed only when there are hover buttons. Row hover / splash / highlight **colors** are unchanged (painted by the row's `CustomInkWell`), and the hover-button reveal is unchanged when a builder is set
*   **PERF**: Cell `FocusNode` is now allocated lazily, only when a cell can edit
    *   `TablePlusCell` created a `FocusNode` (and registered a listener) for every cell in `initState`, though only editing uses it. It is now created on first edit, so non-editable tables and non-editable columns allocate none — one fewer object + listener per visible cell as rows scroll into view
*   **CHORE**: Bump `just_tooltip` dependency `^0.2.5` → `^0.3.0`
*   **PERF**: Uniform-height tables now scroll with O(1)-per-frame layout instead of O(n)
    *   `TablePlusBody` used `ListView.builder(itemExtentBuilder: ...)` unconditionally, which drives `RenderSliverVariedExtentList` — it sums every row's extent on each layout to know the total scroll extent and to map a scroll offset to an index. On a 100k-row table this is ~O(n) per frame and caused visible scroll jank
    *   When there are no merged groups and no `calculateRowHeight` (i.e. all rows share `theme.rowHeight`), the body now passes a fixed `itemExtent`, so Flutter uses `RenderSliverFixedExtentList` (offset↔index by division). Merged-group and dynamic-height tables keep `itemExtentBuilder` with identical geometry
    *   Local harness (100k uniform rows, 60 `jumpTo` layouts): ~83.6 ms/jump → ~22.1 ms/jump end-to-end, and the per-frame layout cost no longer grows with row count

## 2.13.0

*   **FIX**: Row-level gestures now fire while `isEditable` is `true`
    *   `onRowDoubleTap` and `onRowSecondaryTapDown` previously never fired in edit mode because the row's interaction layer was gated on selection being active (`isSelectable && !isEditable`). They now fire whenever a handler is provided — e.g. right-click a row to delete it while other rows stay editable
    *   Tap-to-select is still suppressed while editing (a single tap edits a cell); the selection ink splash is not shown for edit-mode gestures
*   **FIX**: Checkboxes no longer require a `Material` / `Scaffold` ancestor
    *   The `InkWell` inside `FlutterCheckbox` needs a `Material` ancestor; the row selection cell and header select-all cell now wrap the checkbox in a transparent `Material`, so the table works in non-Material desktop apps without a `Scaffold`
*   **FIX**: Narrow selection columns no longer clip the checkbox
    *   The row and header select-all cells no longer wrap the (already-centered) checkbox in the full horizontal padding, which squeezed the content area to zero. A `checkboxColumnWidth` below ~40 now keeps the checkbox visible
*   **PERF**: Column-width layout is now near-linear in the column count
    *   The max-width redistribution used to cap one exceeding column and restart the scan (~O(n²)). It now settles all caps in a single sweep over columns sorted by `maxWidth / width` (~O(n log n)) — identical widths, verified by a differential test against the previous algorithm across randomized inputs
    *   ~28× faster at 10,000 columns in the local benchmark (9.7 ms → 0.35 ms); negligible difference for normal column counts
*   **INTERNAL**: Large testability refactor — no public API or behavior change
    *   The column-width algorithm, the row hit-test geometry behind the drag-selection `RowLocator` port, table metrics (total height / row count / renderable indices), the sort-direction cycle, the single/double-tap timing, the scroll-sync reentrancy guard, and several theme/row helpers were extracted into pure, unit-tested modules
    *   Test count `271` → `331`; line coverage ~85% → ~91%. Added `benchmark/pure_paths_benchmark.dart` microbenchmarks (run with `flutter test benchmark/pure_paths_benchmark.dart`)

## 2.12.2

*   **CHORE**: Bump `flutter_checkbox` dependency `^0.2.0` → `^0.2.1`

## 2.12.1

*   **FIX**: Explicitly set `mouseCursor: SystemMouseCursors.click` on interactive `InkWell` widgets so the pointing-hand cursor appears reliably on recent Flutter versions
    *   `CustomInkWell` (used by row and merged-row selection) now resolves to `SystemMouseCursors.click` when `onTap` or `onDoubleTap` is provided, and to `MouseCursor.defer` otherwise — `defer` leaves the cursor decision to an ancestor `MouseRegion` (e.g., resize handles) instead of stomping it with `basic`
    *   `TablePlusSelectionCell`'s checkbox-cell `InkWell` mirrors the same pattern, guarded on `rowId != null`
    *   Previously, the wrapped `InkWell` relied on the implicit `WidgetStateMouseCursor.clickable` default, which no longer flips to `click` in all configurations after recent Flutter cursor-resolution changes

## 2.12.0

*   **FEAT**: Horizontal auto-scroll during drag selection
    *   When the table is wider than its viewport (`SingleChildScrollView` is scrollable horizontally), dragging the pointer near the left or right edge of the visible viewport now scrolls the table horizontally at proximity-proportional speed, mirroring the existing vertical auto-scroll
    *   Edge detection runs in *visible-viewport* coordinates (uses `horizontalController.position.viewportDimension`), not body-local coordinates, so the edge zone tracks the user's actual visible area
    *   Both axes can scroll simultaneously when the pointer is in a corner (e.g., bottom-right)
    *   The rubber band rectangle is content-anchored on both axes — its origin tracks the underlying content via the symmetric `downLocal − hDelta/vDelta` formula, so scrolling on either axis grows the rectangle visually
    *   Horizontal proximity is clamped to `[0, 1]` so dragging the pointer far past the visible viewport edge does not overshoot the configured max speed (the vertical axis retains its original feel)
    *   The drag-selection `Listener` sits at the body's *viewport* level (outside the body's horizontal `Scrollable`), so its `event.localPosition` is viewport-local on both axes — there is no "body slid in screen" compensation to maintain. As a consequence, the auto-scroll engine progresses cleanly to `maxScrollExtent` while the pointer is held in an edge zone, instead of stalling once accumulated horizontal scroll delta would have pushed a stale captured origin out of the zone
*   **FEAT**: Rubber band rectangle for drag selection (Finder/Explorer-style marquee)
    *   When `enableDragSelection` is true, a translucent rectangle is now drawn from the pointer-down position to the current pointer position while the drag is active, providing immediate visual feedback for the selection range
    *   The rectangle is decoupled from anchor establishment: it appears as soon as the activation threshold is passed, even when the drag stays entirely inside empty space (no row anchor yet) or when the pointer crosses back above row 1 into the header area
    *   Content-anchored rectangle: the origin is fixed to the underlying content rather than the viewport, so auto-scroll causes the rectangle to grow visually — matching OS marquee conventions
    *   New `TablePlusDragSelectionTheme` (composed into `TablePlusTheme.dragSelectionTheme`) with `show`, `fillColor`, `borderColor`, `borderWidth`, `borderRadius`. Default `show: true`; set to `false` to keep drag-selection logic without the visual cue
    *   `borderWidth` participates in `TablePlusTheme.scaledBy()`; colors and `borderRadius` are intentionally not scaled
    *   Re-exported from the main library for convenient theming
*   **FIX**: Drag selection no longer snaps to the last row when the pointer is in the empty area below the data
    *   `_renderIndexFromLocalY` now returns `null` for coordinates outside the actual row area (above the first row or below the last); callers' existing null-guards activate sticky behavior at the last reached row instead of clamping to a row the pointer never crossed
    *   Lazy activation: when pointer-down lands in the empty area below the last row, the drag anchor is deferred until the pointer first crosses into a real row — starting a drag from the empty area and moving into rows still works, but a drag confined to empty space no longer selects anything
    *   Side-aware release: when a drag started from the below-data empty area and the pointer returns to that same area, the lazy anchor is released and the selection collapses (mirroring OS marquee behavior in Finder/Explorer). Re-entering a row lazy-activates a fresh anchor. Crossing instead above row 1 into the header area preserves the sticky range, so sweeping up through every row and continuing past the header keeps the full selection intact
    *   Sticky preservation for in-row starts: when a drag started inside the rows moves past the last row into empty space (or above row 1 into the header area), the selection freezes at the last reached row instead of being coerced to the boundary
*   **EXAMPLE**: Added `5` quick preset to the playground for testing small-data drag-selection scenarios (logarithmic slider lower bound: `10` → `5`)
*   **INTERNAL**: Drag-selection coordinate model unified to a single viewport-local frame
    *   Header and body now use independent horizontal `SingleChildScrollView`s synced via a shared-controller pattern (`SyncedScrollControllers` adds a 5th controller slot for the header). The header is `NeverScrollableScrollPhysics` — body is the master input source
    *   `TablePlusBody` is a pure row renderer; drag-selection state, pointer handlers, auto-scroll engine, and rubber band painter all live in `_FlutterTablePlusState`. `TablePlusBodyState` exposes `renderIndexAtLocalY` and `rowIdsBetween` for the parent's lookup needs (accessed via `GlobalKey<TablePlusBodyState<T>>`)
    *   Single-axis auto-scroll engine extracted (`_performAxisAutoScroll`); per-axis wrappers now differ only in coordinate source and a `clampProximity` flag. Vertical retains its historical >1 acceleration past the edge zone; horizontal still caps at `maxSpeed`
*   **TEST**: Added `test/drag_selection_test.dart` with 8 widget tests covering basic drag, threshold gating, sticky range at empty/header boundaries, vertical / horizontal / dual-axis auto-scroll, and merged-group traversal

## 2.11.0

*   **BREAKING**: Rename `blockCtrlScroll` → `blockModifierScroll` to accurately reflect platform-aware behavior (Ctrl on Windows/Linux, Cmd on macOS)
*   **FIX**: Use platform-aware modifier key check to fix Cmd+scroll zoom not working on macOS
*   **FEAT**: Export `isScaleModifierPressed()` helper for library consumers implementing custom Ctrl/Cmd + scroll zoom

## 2.10.0

*   **BREAKING**: Replaced Material `Checkbox` with [`flutter_checkbox`](https://pub.dev/packages/flutter_checkbox) package
    *   `TablePlusCheckboxTheme` now uses a single `CheckboxStyle style` property instead of individual Material properties
    *   Removed: `fillColor`, `overlayColor`, `checkColor`, `focusColor`, `hoverColor`, `side`, `shape`, `materialTapTargetSize`, `visualDensity`, `splashRadius`, `size`, `tapTargetSize`
    *   Added: `style` (`CheckboxStyle`) — controls all visual aspects (colors, shape, size, border, hover ring, animations)
    *   `buildCheckbox()` now creates `FlutterCheckbox` with CustomPainter rendering for crisp display at any size
    *   `scaledBy()` uses `CheckboxStyle.scale` for accurate visual scaling (previously SizedBox-only scaling)
    *   Renamed `material3()` factory → `colored()` factory
    *   Re-exported `FlutterCheckbox`, `CheckboxStyle`, `CheckboxShape` from main library for convenience
*   **Migration**:
    *   `TablePlusCheckboxTheme(fillColor: ..., checkColor: ..., size: 18)` → `TablePlusCheckboxTheme(style: CheckboxStyle(activeColor: ..., checkColor: ..., size: 18))`
    *   `tapTargetSize` → `CheckboxStyle(hoverRingPadding: ...)`
    *   `splashRadius` → removed (hover ring replaces ripple effect)
    *   Table-specific properties (`showCheckboxColumn`, `showSelectAllCheckbox`, `checkboxColumnWidth`, `cellTapTogglesCheckbox`, `showRowCheckbox`) remain unchanged

## 2.9.1

*   **FEAT**: Added `blockModifierScroll` parameter to `FlutterTablePlus` — independently control whether Ctrl+wheel (Cmd+wheel on macOS) scrolling is blocked
    *   When `true`, Ctrl+wheel events are consumed and do not scroll the table
    *   When `false`, Ctrl+wheel scrolls normally even if `onScaleChanged` is set
    *   Defaults to `null` — automatically follows `onScaleChanged` (blocked when non-null, allowed when null), preserving existing behavior
    *   Enables use cases where Ctrl+scroll blocking is desired without zoom, or zoom without scroll blocking

## 2.9.0

*   **FEAT**: Added `scale` parameter to `FlutterTablePlus` — zoom in/out by scaling all table dimensions
    *   Multiplies column widths, row heights, font sizes, padding, and icon sizes by the scale factor
    *   Default `1.0` (100%); no upper limit enforced — caller is responsible for clamping
    *   `assert(scale > 0)` prevents division-by-zero crashes
    *   Scroll positions are automatically adjusted when scale changes so that the same content remains visible
    *   Resized column widths are stored in logical (unscaled) units — survive scale changes and `onColumnResized` reports logical widths
*   **FEAT**: Added `onScaleChanged` callback — enables Ctrl+wheel (Cmd+wheel on macOS) zoom with scroll prevention
    *   When non-null, the library intercepts Ctrl+wheel events and calls the callback with the proposed new scale
    *   Uses `_ScaleBlockingScrollPhysics` internally: overrides `shouldAcceptUserOffset()` to return `false` when Ctrl is held, preventing `Scrollable` from registering a scroll handler — **no scroll contamination**
    *   Pre-scale scroll offsets are saved as a backup for position correction in `didUpdateWidget`
    *   `scaleStep` parameter controls the increment per wheel tick (default `0.05`)
*   **FEAT**: Added `scaledBy(double factor)` method to all theme classes
    *   `TablePlusTheme`, `TablePlusHeaderTheme`, `TablePlusBodyTheme`, `TablePlusCheckboxTheme`, `TablePlusEditableTheme`, `TablePlusScrollbarTheme`, `TablePlusHoverButtonTheme`
    *   Returns a new instance with dimensional values (heights, font sizes, padding, icon sizes) scaled by the factor
    *   Colors, booleans, durations, and border thickness are intentionally **not** scaled
    *   Scrollbar theme and tooltip theme are excluded from scaling (UI chrome, overlay)
    *   Short-circuits with `return this` when `factor == 1.0`
*   **IMPROVEMENT**: Sort icons now wrapped in `FittedBox` — custom sort icon widgets scale correctly with `sortIconWidth`
*   **IMPROVEMENT**: Body `_cachedRowHeights` cleared when scale changes to prevent stale height values

## 2.8.2

*   **REFACTOR**: Deduplicated checkbox creation across header, body, and merged row widgets
    *   Added `buildCheckbox()` helper method to `TablePlusCheckboxTheme` — builds a fully-themed `Checkbox` widget in one call
    *   Replaced 3 identical inline `Checkbox(...)` blocks (~47 lines) with `checkboxTheme.buildCheckbox()` calls
*   **REFACTOR**: Deduplicated vertical divider border creation across cell widgets
    *   Added `verticalDividerSide` and `verticalDividerBorder` getters to `TablePlusBodyTheme`
    *   Replaced 5 identical inline `Border(right: BorderSide(...))` blocks with single getter calls
*   **REFACTOR**: Moved `_shouldShowBottomBorder` logic to `TablePlusBodyTheme.shouldShowBottomBorder()`
    *   Removed identical private methods from `_TablePlusRowState` and `_TablePlusMergedRowState`
*   **REFACTOR**: Consolidated hover button positioning logic into `HoverButtonPosition.buildPositioned()`
    *   Added `buildPositioned()` method to `HoverButtonPosition` enum
    *   Replaced identical switch-case blocks (~25 lines each) in `TablePlusRow` and `TablePlusMergedRow` with single method calls
*   **REFACTOR**: Removed dead if/else branch in `_handleRegularRowSelectionToggle` — both branches were identical
*   **REFACTOR**: Moved `nonSelectionColumns` filtering outside `List.generate` loop in `TablePlusMergedRow` to avoid redundant per-iteration computation
*   **REFACTOR**: Extracted `_buildScrollbarTrack()` helper to consolidate identical vertical/horizontal scrollbar widget trees (~140 lines → ~60 lines)
*   No API or behavioral changes — all appearance and functionality remain identical

## 2.8.1

*   Bumped `just_tooltip` dependency to `^0.2.5`
    *   Supports new `TooltipAlignment.startTargetCenter` and `TooltipAlignment.endTargetCenter` values — arrow dynamically points toward the center of the target widget

## 2.8.0

*   **BREAKING**: Migrated tooltip system from custom implementation to [`just_tooltip`](https://pub.dev/packages/just_tooltip) package
    *   Removed `CustomTooltipWrapper` widget and `CustomTooltipWrapperTheme` class
    *   Removed `decoration`, `margin`, `preferBelow`, `verticalOffset`, `exitDuration`, `customWrapper` from `TablePlusTooltipTheme`
    *   Added `just_tooltip`-based properties: `backgroundColor`, `borderRadius`, `elevation`, `boxShadow`, `borderColor`, `borderWidth`, `showArrow`, `arrowBaseWidth`, `arrowLength`, `arrowPositionRatio`
    *   Added layout/behavior properties: `direction`, `alignment`, `offset`, `crossAxisOffset`, `screenMargin`, `enableTap`, `enableHover`, `interactive`, `animation`, `animationCurve`, `fadeBegin`, `scaleBegin`, `slideOffset`, `rotationBegin`, `animationDuration`, `hideOnEmptyMessage`
    *   `FlutterTooltipPlus` now accepts both `message` (String?) and `tooltipBuilder` (WidgetBuilder?) — unified text and widget tooltips
    *   Added `toJustTooltipTheme()` helper on `TablePlusTooltipTheme`
    *   Re-exported `TooltipDirection`, `TooltipAlignment`, `TooltipAnimation` from `just_tooltip`

## 2.7.1

*   **FIX**: `initialResizedWidths` now reacts to runtime changes via `didUpdateWidget`
    *   Previously only applied once at widget creation (`initState`); switching data contexts (e.g., different servers) kept stale resize widths
    *   Uses `mapEquals` for value-based comparison — avoids unnecessary resets when state management (Riverpod, Provider, etc.) rebuilds pass an equivalent map
    *   Widget no longer needs a `Key` swap to apply new initial widths

## 2.7.0

*   **FEAT**: Added `stretchLastColumn` parameter to `FlutterTablePlus` — last column absorbs remaining space when all columns have fixed widths
    *   When `false` (default), columns keep their exact widths and empty space may appear on the right (Windows Explorer behavior)
    *   When `true`, the last visible column stretches to fill any leftover space after auto-fit or manual resize
    *   Only activates when remaining space exists; no effect when columns already fill or exceed available width
    *   Selection column (`__selection__`) is excluded from stretching
*   **FIX**: Column reorder now works when dragging to empty space right of the last column
    *   Added trailing `DragTarget` in header row to accept drops beyond the last column
    *   Dropped column moves to the last position, consistent with drag-to-column behavior
*   **FEAT**: Added `initialResizedWidths` parameter to `FlutterTablePlus` — restore saved column widths from a previous session
    *   Columns in this map are treated as fixed (exact pixel width), same as user-resized columns
    *   Only applied once at widget creation; subsequent user resizes override at runtime
    *   Pair with `onColumnResized` to implement full column width persistence
*   **FIX**: Flexible columns no longer jump in size when window crosses the fixed-total threshold
    *   Changed proportional distribution condition from `spaceForFlexible <= 0` to `spaceForFlexible < flexiblePreferredTotal`
    *   Flexible columns keep their preferred width (with horizontal scroll) until enough space exists for proportional expansion
    *   Ensures smooth, continuous width transitions during window resize

## 2.6.0

*   **FEAT**: Added `autoFitColumnWidth` callback to `FlutterTablePlus` — override default auto-fit measurement for columns with custom cell builders
    *   Return a width to override, or `null` to fall back to built-in text measurement
    *   Useful for `statefulCellBuilder` columns with custom styles, padding, or text transformations
    *   Result is clamped to per-column `minWidth` / `maxWidth` constraints
*   **FEAT**: Added `TableColumnWidthCalculator` utility class for external column width measurement
    *   `measureTextWidth()` — measure a single text string with style, padding, and extra width
    *   `calculateColumnWidth()` — measure header + all body values and return optimal width
    *   Follows the same `TextPainter`-based pattern as `TableRowHeightCalculator`

## 2.5.0

*   **FEAT**: Added `showRowCheckbox` to `TablePlusCheckboxTheme` — hide individual row checkboxes while keeping the header select-all checkbox
    *   When `false`, the checkbox column still renders with the header select-all checkbox, but row cells show no checkbox
    *   Row selection is done via row tap only; defaults to `true` (backward compatible)
    *   Supported in normal rows, merged rows, and the `material3` factory
*   **BREAKING**: Removed deprecated `cellBuilder` from `TablePlusColumn`
    *   Use `statefulCellBuilder` instead — same functionality with additional `isSelected` and `isDim` parameters
    *   Migration: `cellBuilder: (ctx, row) => ...` → `statefulCellBuilder: (ctx, row, _, _) => ...`

## 2.4.2

*   **FEAT**: Added `sortIconWidth` to `TablePlusHeaderTheme` for accurate tooltip overflow detection with custom sort icons
    *   Sort icon is wrapped in `SizedBox(width: sortIconWidth)` to enforce consistent layout
    *   Header tooltip calculation uses `sortIconSpacing + sortIconWidth` instead of hardcoded `24.0`
    *   Tooltip now checks actual icon visibility — no space subtracted when `unsorted` icon is `null`
    *   Default `16.0` matches built-in `SortIcons.defaultIcons` size

## 2.4.1

*   **FIX**: Columns hitting `maxWidth` no longer leave unused space at the end of the table
    *   Proportional width distribution now uses iterative redistribution — when a flexible column is clamped to `maxWidth`, the excess space is re-distributed to remaining flexible columns
    *   Guarantees all available width is consumed when uncapped columns exist

## 2.4.0

*   **FEAT**: Added `statefulCellBuilder` to `TablePlusColumn` — custom cell builder with `isSelected` and `isDim` state
    *   Signature: `Widget Function(BuildContext context, T rowData, bool isSelected, bool isDim)`
    *   Takes precedence over `cellBuilder` when both are provided
    *   Added `hasCustomCellBuilder` getter and `buildCustomCell()` helper on `TablePlusColumn`
*   **DEPRECATED**: `cellBuilder` — use `statefulCellBuilder` instead for access to row selection and dim state

## 2.3.5

*   **FIX**: Last row no longer obscured by horizontal scrollbar
    *   Automatically reserves space equal to `scrollbarTheme.trackWidth` when horizontal scrollbar is visible
    *   No new parameters required — applied internally based on existing scroll/theme conditions

## 2.3.4

*   **FEAT**: Added `cellTapTogglesCheckbox` to `TablePlusCheckboxTheme` — expands checkbox tap area to the entire selection column cell, preventing accidental single-select when missing the checkbox

## 2.3.3

*   **FIX**: `checkboxColumnWidth` below default `minWidth` (50) no longer crashes
    *   Selection column now sets `minWidth` equal to `checkboxColumnWidth`, preventing `clamp(min > max)` error
    *   e.g. `checkboxColumnWidth: 45` previously threw `Invalid argument(s): 50.0`

## 2.3.2

*   **FIX**: Checkbox column no longer expands proportionally with available width
    *   Added `maxWidth` constraint equal to `checkboxColumnWidth` on the internal `__selection__` column
    *   Ensures the selection column stays at its configured fixed width regardless of table size
*   **FIX**: Fixed-width columns no longer cause space loss in proportional layout
    *   Columns whose `maxWidth` caps their preferred width are now excluded from proportional distribution
    *   Remaining space is distributed only among flexible columns, eliminating the right-side gap

## 2.3.1

*   **BREAKING**: Extracted `TablePlusResizeHandleTheme` from flat fields on `TablePlusHeaderTheme`
    *   Removed `resizeHandleWidth`, `resizeHandleColor`, `resizeHandleThickness`, `resizeHandleIndent`, `resizeHandleEndIndent` from `TablePlusHeaderTheme`
    *   Added `TablePlusResizeHandleTheme` class with `width`, `color`, `thickness`, `indent`, `endIndent` and `copyWith`
    *   New composed property: `TablePlusHeaderTheme.resizeHandle` (default `const TablePlusResizeHandleTheme()`)
    *   Consistent with existing `TablePlusHeaderBorderTheme` / `TablePlusHeaderDividerTheme` pattern
*   **FIX**: Hide vertical divider on column reorder drag feedback
    *   The floating header cell during drag-and-drop reorder no longer renders the right-edge vertical divider
    *   Added `showDivider` parameter to `_HeaderCell` (default `true`, set to `false` for feedback only)

## 2.3.0

*   **FEAT**: Added `tapTargetSize` to `TablePlusCheckboxTheme`
    *   Expands the checkbox tap/hover hit-test area without changing the visual checkbox size
    *   Configurable in logical pixels (e.g., `tapTargetSize: 40` gives a 40×40 hit area)
    *   Defaults to `size` when not set — fully backward compatible
    *   Applied to body rows, header select-all, and merged row checkboxes
*   **BREAKING**: Refactored header border/divider into separate theme classes
    *   Removed `showVerticalDividers`, `showBottomDivider`, `dividerColor`, `dividerThickness` from `TablePlusHeaderTheme`
    *   Added `TablePlusHeaderBorderTheme` for top/bottom horizontal borders (`show`, `color`, `thickness`)
    *   Added `TablePlusHeaderDividerTheme` for vertical column dividers with `indent` / `endIndent` support
    *   New properties: `topBorder` (default hidden), `bottomBorder` (default visible), `verticalDivider` (default visible)
    *   Vertical dividers now rendered as `Stack` overlay instead of `BoxDecoration.border`, enabling indent control
*   **FEAT**: Resize handle `indent` / `endIndent` / `thickness` theming
    *   `resizeHandleThickness` controls the visible indicator line width (default `2.0`)
    *   `resizeHandleIndent` / `resizeHandleEndIndent` inset the indicator from top/bottom edges
*   **FIX**: Resize handle now centered on column boundary
    *   Previously the handle was positioned entirely inside the left column (`right: 0`), making it asymmetric
    *   Now uses a header-level `Stack` overlay with `left: cumulativeWidth - handleWidth / 2`, giving equal hit area on both sides of the border
    *   Visual indicator line renders at the exact column boundary center
    *   `ValueKey` per handle ensures stable state across rebuilds and column reorders

## 2.2.0

*   **FEAT**: Drag-to-select rows
    *   `enableDragSelection` parameter enables mouse drag row selection (Excel/Finder style)
    *   `onDragSelectionUpdate` callback fires during drag with the dragged range row IDs
    *   `onDragSelectionEnd` callback fires once when drag ends
    *   Auto-scroll when dragging near viewport edges (~60fps, speed proportional to edge proximity)
    *   8px activation threshold prevents conflicts with existing tap/click gestures
    *   Works with uniform heights (O(1)), dynamic heights, and merged row groups
    *   Parent controls selection behavior (replace or additive) — consistent with UI-only philosophy

## 2.1.1

*   **IMPROVEMENT**: Auto-scroll during column resize drag
    *   When dragging a resize handle near the viewport edge, the table automatically scrolls in that direction
    *   Scroll speed is proportional to pointer proximity to the edge (50px activation zone)

## 2.1.0

*   **FEAT**: Column resizing support
    *   `resizable` parameter enables drag-to-resize on column header edges
    *   `onColumnResized` callback fires with `(String columnKey, double newWidth)` for persistence
    *   Respects per-column `minWidth` / `maxWidth` constraints; selection column excluded
*   **FEAT**: Resize handle theming in `TablePlusHeaderTheme`
    *   `resizeHandleWidth` (default `8.0`) and `resizeHandleColor` properties
*   **FIX**: `minWidth` / `maxWidth` constraints now enforced in all layout calculation paths

## 2.0.2

*   **FIX**: `showCheckboxColumn: false` in `TablePlusCheckboxTheme` now properly hides the checkbox column
*   **IMPROVEMENT**: Header select-all checkbox auto-hides when `onSelectAll` is null

## 2.0.1

*   **FIX**: Fixed header-body column width misalignment when table width exceeds total column widths

## 2.0.0

*   **BREAKING**: Migrated from `Map<String, dynamic>` to generic type parameter `<T>`
    *   `FlutterTablePlus<T>` accepts any data model type
    *   `rowIdKey` → `rowId: String Function(T)`
    *   `dimRowKey` / `invertDimRow` → `isDimRow: bool Function(T)?`
    *   `TablePlusColumn<T>` requires `valueAccessor: (T) => dynamic`
    *   `cellBuilder`, `hoverButtonBuilder`, `calculateRowHeight` signatures use `T` instead of `Map`
    *   `onCellChanged` receives `T` instead of `Map`
    *   `MergedRowGroup<T>` parameterized with data type
    *   `summaryRowData` → `summaryBuilder: Widget? Function(String columnKey)?`

## 1.17.2

*   **PERF**: Eliminated full table rebuilds on mouse hover
*   **PERF**: Cached total data height, row count, and visible columns computation
*   **PERF**: Added overflow detection caching in `TablePlusCell`
*   **FIX**: Added missing `TextPainter.dispose()` in `TableRowHeightCalculator`

## 1.17.1

*   **FIX**: Fixed scroll controllers being destroyed on every parent rebuild
*   **FIX**: Improved scroll sync reliability in `SyncedScrollControllers`

## 1.17.0

*   **IMPROVEMENT**: Added `itemExtentBuilder` for improved scroll performance with large datasets (10,000+ rows)

## 1.16.7

*   **FEAT**: Added `verticalOffset` to `TablePlusTooltipTheme` for customizable tooltip positioning

## 1.16.6

*   **BREAKING**: Replaced `isDimRow` callback with `dimRowKey` and `invertDimRow`

## 1.16.5

*   **FEAT**: Added dim row feature with `isDimRow` callback and theme support

## 1.16.4

*   **FIX**: Rapid consecutive taps now correctly trigger multiple `onRowTap` when `onRowDoubleTap` is null

## 1.16.3

*   **FEAT**: Added `tooltipBuilder` for custom widget tooltips (priority: `tooltipBuilder` > `tooltipFormatter` > default)
*   **FEAT**: Enhanced tooltip timing with `exitDuration` property and hover interaction support
*   **FEAT**: Intelligent tooltip positioning that adapts to available screen space
*   **FEAT**: Added `CustomTooltipWrapperTheme` for tooltip configuration

## 1.16.2

*   **FEAT**: Added configurable `doubleClickTime` to `TablePlusBodyTheme` (default 500ms)

## 1.16.1

*   **FEAT**: Added `isSelected` parameter to `onRowSecondaryTapDown` callback
*   **IMPROVEMENT**: Enhanced `TablePlusScrollbarTheme` with independent track/thumb styling (`trackWidth`, `thickness`, `radius`, `thumbColor`, `trackBorder`)

## 1.16.0

*   **BREAKING**: Removed deprecated `TablePlusSelectionTheme`
    *   Selection styling → `TablePlusBodyTheme` (`selectedRowColor`, `selectedRowTextStyle`)
    *   Checkbox properties → `TablePlusCheckboxTheme`
    *   Row interaction colors → `TablePlusBodyTheme`
*   **BREAKING**: `onRowSecondaryTap` → `onRowSecondaryTapDown` with `TapDownDetails` and `RenderBox`

## 1.15.6

*   **FEAT**: Added `TooltipBehavior.onlyTextOverflow` — tooltips only appear when text overflows
*   **FIX**: Fixed row hover colors not appearing due to Stack blocking `CustomInkWell`
*   **REFACTOR**: Moved row interaction properties from `TablePlusSelectionTheme` to `TablePlusBodyTheme`
*   **DEPRECATED**: Row interaction properties in `TablePlusSelectionTheme` (removed in 1.16.0)

## 1.15.5

*   **FEAT**: Added `TablePlusCheckboxTheme` with Material 3 `WidgetStateProperty` support
*   **DEPRECATED**: Checkbox properties in `TablePlusSelectionTheme`

## 1.15.4

*   **BREAKING**: Removed `TooltipBehavior.onOverflowOnly`

## 1.15.3

*   **FEAT**: Added `onCheckboxChanged` callback to distinguish checkbox clicks from row clicks
*   **FEAT**: Added checkbox color customization (`hoverColor`, `focusColor`, `fillColor`, `side`)
*   **FIX**: Fixed tooltip null check error during column reordering

## 1.15.2

*   **FEAT**: Added `tooltipFormatter` to `TablePlusColumn` for custom tooltip content
*   **UPDATE**: Minimum Flutter version changed to >=3.10.0

## 1.15.1

*   **FIX**: Static analysis fixes

## 1.15.0

*   **BREAKING**: Removed frozen column functionality (`frozenColumns`, `TablePlusFrozenTheme`, `TablePlusDividerTheme`)
*   **FEAT**: Hover button system with `hoverButtonBuilder`, `HoverButtonPosition`, and `TablePlusHoverButtonTheme`
*   **FEAT**: Enhanced expandable row functionality for merged row groups

## 1.14.2

*   **FEAT**: Expandable summary rows for merged row groups
    *   `isExpandable`, `isExpanded`, `summaryRowData` on `MergedRowGroup`
    *   `onMergedRowExpandToggle` callback
*   **FEAT**: Added `summaryRowBackgroundColor` to `TablePlusBodyTheme`
*   **FIX**: Fixed tooltip and height calculation in merged rows

## 1.14.1

*   **FEAT**: Added `lastRowBorderBehavior` to `TablePlusBodyTheme` (`never`, `always`, `smart`)
*   **FIX**: Fixed sorting with merged rows

## 1.14.0

*   **FEAT**: Frozen column divider with `TablePlusDividerTheme`
*   **FIX**: Fixed layout overflow in constrained height containers
*   **FIX**: Fixed vertical scrollbar track height calculation

## 1.13.2

*   **FIX**: Fixed single selection mode — clicking selected row now correctly deselects

## 1.13.1

*   **FEAT**: Added `calculateRowHeight` callback and `TableRowHeightCalculator` utility

## 1.13.0

*   **BREAKING**: Removed dynamic row height feature (`RowHeightMode`, `minRowHeight`, `TextHeightCalculator`)

## 1.12.0

*   **FEAT**: Dynamic row height with `RowHeightMode.dynamic` and `minRowHeight`
*   **FEAT**: Improved sorting with merged rows
*   **REFACTOR**: `MergedRowGroup` uses `rowKeys` instead of `originalIndices`
*   **FIX**: Fixed alternate row color logic and background color application

## 1.11.1

*   **IMPROVEMENT**: Improved focus handling for editable cells

## 1.11.0

*   **FEAT**: Merged row functionality with `MergedRowGroup` and `MergeCellConfig`
    *   Selection and editing support for merged cells
    *   Auto-save on focus loss for editable cells
*   **FEAT**: Added `cellContainerPadding` to `TablePlusEditableTheme`

## 1.10.1

*   **CHORE**: Applied `dart format`

## 1.10.0

*   **FEAT**: Dynamic row height calculation based on content
*   **FEAT**: Dynamic scrollbar visibility based on content height

## 1.9.0

*   **FEAT**: Added `headerTooltipBehavior` to `TablePlusColumn`

## 1.8.0

*   **FEAT**: Added `tooltipBehavior` to `TablePlusColumn` (`always`, `onOverflowOnly`, `never`)
*   **DEPRECATED**: `showTooltipOnOverflow` in favor of `tooltipBehavior`

## 1.7.0

*   **FEAT**: Added `noDataWidget` for custom empty state display
*   **IMPROVEMENT**: Sorting auto-disabled when data is empty

## 1.6.2

*   **FEAT**: Added `visible` property to `TablePlusColumn` for column visibility control

## 1.6.1

*   **FEAT**: Added `selectedTextStyle` to `TablePlusTheme`

## 1.6.0

*   **FEAT**: `decoration` and `cellDecoration` in `TablePlusHeaderTheme`
*   **FEAT**: Granular row interaction colors in `TablePlusSelectionTheme` (`hoverColor`, `splashColor`, `highlightColor`)
*   **FEAT**: `dividerThickness` in `TablePlusHeaderTheme`
*   **FEAT**: `rowIdKey` for custom row identifier field
*   **FEAT**: `textOverflow` property on `TablePlusColumn` with auto-tooltip on ellipsis

## 1.5.0

*   **FEAT**: Added `SelectionMode.single` for single row selection

## 1.4.0

*   **FEAT**: Disable column reordering with `onColumnReorder: null`
*   **FEAT**: Disable sorting with `onSort: null`

## 1.3.0

*   **FEAT**: Enabled simultaneous selection and editing

## 1.2.0

*   **FEAT**: Configurable sort cycle order via `sortCycle`

## 1.1.2

*   **FEAT**: Added `hintText` to `TablePlusColumn` and `hintStyle` to `TablePlusEditableTheme`
*   **FEAT**: Added `onRowDoubleTap` and `onRowSecondaryTap` callbacks

## 1.1.1

*   Updated README.md

## 1.1.0

*   **FEAT**: Cell editing with `isEditable`, per-column `editable`, `onCellChanged`, and `TablePlusEditableTheme`

## 1.0.0

*   **Initial release** — customizable table widget with synchronized scrolling, theming, sorting, selection, column reordering, and custom cell builders
