## 2.17.0

*   **FIX**: a merged group's member cells are now drawn by the same cell widget a plain row uses, instead of by a second copy of it that had drifted one decision at a time ([#155](https://github.com/kihyun1998/flutter_table_plus/issues/155))
    *   **What a consumer sees differently.** A member's vertical divider was hand-built at width `1` while the theme's is `0.5` — twice as thick, at the *default* theme, in every grouped table. Its separator was hardcoded at `1` while every other row divider reads `dividerThickness`, so raising that value thickened every line on screen except the ones inside a group. On `TooltipBehavior.onlyTextOverflow` a member measured its text against the group's tallest-member **height** in a parameter named `maxWidth` — a 200px column over a 48px group measured against ~16px, so nearly every value claimed overflow and drew a tooltip it should not have. A widget tooltip anchored to the bare `Text` rather than to the cell, leaving most of the cell unhoverable. And the overflow measurement was uncached, alone among the cells
    *   **The divider now stays while a cell is being edited, for plain rows too.** The cell did `if (!isCellEditing) border = ...`, so the column line vanished under an open editor and returned on commit. This is a deliberate reversal, and the references agree with it: `pluto_grid` branches its cell decoration on *which cell is current* and never on whether it is editing, letting the editor draw no border of its own so the container's survives; Flutter's `DataTable` puts no decoration on a cell at all and never has to choose. If you relied on the gap, the editable theme's own border is where to put it back
    *   **New: `TablePlusBodyTheme.memberDividerSide`.** The separator between two members of one merged group, at `dividerColor` alpha 0.3 and `dividerThickness`. Distinct from the group's own outer border, which the row decoration draws at full `dividerColor` — a member is not a row, so no row decoration can reach between two of them. Additive, and not scaled by `scaledBy`, exactly as `dividerThickness` is not
    *   **A fifth inline copy of `editKeyAction` went with it.** The extraction that folded four editing-cell key handlers into one classifier missed the merged row's stacked branch, and the count in its own doc-comment said four for as long as the fifth survived
    *   **The parity test is the finding, not the fix.** Asserting grouped-against-ungrouped is worthless once both paths are the same widget: breaking that widget breaks both sides and the comparison still holds. Measured — replacing the cell's `theme.verticalDividerSide` with a hardcoded `BorderSide(width: 1)` left every assertion green. The discriminating assertions read the *theme*, and the fixture runs at `dividerThickness: 4.0` because at the default `1.0` the old literal and the theme value are the same number and every divider assertion is unfailable. Flipping the existing `merged_row_member_heights_test` from `1.0` to `4.0` turned it from blind to a positional witness: it fails by exactly `(t − 1) / 2` without this change
    *   **Four defects in the same file were deliberately left**, because they are about what the merged *row* assembles rather than what a cell draws: a member's separator is gated on the **group's** `isLastRow`, so at the default `LastRowBorderBehavior.never` the last group in a table loses all of its internal separators; a merged row builds a selection cell whenever `isSelectable` even when `showCheckboxColumn` is off; the summary cell's `top` border is hardcoded and ungated; and `getSpanningRowKey` indexes `rowKeys` positionally. Raised rather than repaired quietly under a ticket sized for the cell
    *   **And two the ordinary cell already had, now inherited by every member** ([#156](https://github.com/kihyun1998/flutter_table_plus/issues/156)): its overflow width subtracts padding but not the 0.5px divider inset, and the detector ignores `MediaQuery.textScaler` while the auto-fit *width* path already takes one
*   **FIX**: a merged group now draws each member at the height you returned for it, instead of at an equal share of the group. The group's *total* was always the sum of its members' measured heights and still is — only the distribution inside it was wrong ([#121](https://github.com/kihyun1998/flutter_table_plus/issues/121))
    *   **What a consumer sees differently.** A group over rows measuring 48 / 96 / 48 was 192px tall and drew three **64px** members: the tall one clipped, the short ones padded, every member misaligned against the same row rendered outside a group. It now draws 48 / 96 / 48. Nothing moves for a caller who passes no `calculateRowHeight`, or whose group's members all measure the same and is not expanded
    *   **Every member's height was already computed, passed into the widget, and then discarded.** The cells were laid out in an `Expanded`, which is `Flexible(fit: FlexFit.tight)`, and a tight flex child is forced to the extent the flex division allocated — so `flex: 1` on every member divided the total evenly no matter what had been measured
    *   **The last cell in a column is left flexible and the rest get fixed extents**, which is a measured choice rather than an obvious one. The group's `Container` carries the row's bottom border in its `decoration`, and a `BoxDecoration` border consumes the child's space, so the `Column` receives the group's height *minus* `dividerThickness`. Fixed extents for every cell overflow by exactly that. Distributing the shortfall proportionally instead was written first, and it moves **every** member off the position its ungrouped twin occupies, by an amount that grows with `dividerThickness` — at `dividerThickness: 4` the third member of that group lands 2.0px high, silently. The border sits at the bottom, so the cell against it absorbs it and the others land exactly
    *   **An expanded group's summary row stays at `bodyTheme.rowHeight`** while its members keep their own measurements. Before this, all of them — summary included — were equal shares, so an expanded group changes even when its members all measure the same
    *   **`TablePlusMergedRow.individualHeights` was removed**, replaced by a map keyed by row key. Internal: the widget is not exported from the barrel, so no caller can name either. The tallest-member value that path read was *derived* from that map rather than carried beside it — two representations of one fact is the shape `docs/map/invariant/no-hand-enumeration.md` exists for, and this change had briefly added a third
*   **FIX**: a merged group whose `rowKeys` name a row `data` does not hold no longer takes rows off the screen, and no longer reserves height for the member that is missing. Four derivations answer *"which rows render, and how tall is a group"*, and two of them disagreed with the other two — both in the body, both against the parent ([#135](https://github.com/kihyun1998/flutter_table_plus/issues/135))
    *   **What a consumer sees differently.** Hand the table a `data` list that no longer holds a row some group still names — the *supported* path, a new list — and the group's surviving members are drawn instead of vanishing with it. Measured 2026-08-31: a group over `['0','1']` against a `data` list holding only `'1'` drew **neither** row; it now draws `r1`. A group missing a member is also one row shorter than it was, so rows below it move **up by one row height each** and a table that was scrolling by exactly that much stops
    *   **`rowKeys` order stopped mattering too.** The anchor was `indexOf(rowKeys.first)`, so a group whose first key was not its earliest row in `data` rendered nothing while its members were marked handled — they were drawn by neither branch. A test named *"preserves the out-of-order-rowKeys quirk (group skipped)"* pinned that as correct; it is rewritten rather than deleted, because the case is still a case
    *   **The two that were right were left alone, and that is how the other two were found.** `computeTableMetrics` has always anchored a group at the earliest member actually present, and `FlutterTablePlusState._getMergedRowHeight` has always skipped a key it cannot resolve. So the parent counted a group the body drew nothing for, and decided whether a scrollbar was needed from a total the body was not laying out. There was no product call to make here — only a question of which two of four were correct
    *   **And `RowLookup.idsMatch` landed with it, in that order.** The invalidation guard #132 costed and deferred compares the snapshot's ids against what the current `rowId` produces, in both `didUpdateWidget`s. It catches a swapped `rowId` over an unchanged list, a list sorted in place, and a list shrunk in place — which used to throw `RangeError` on a merged-group table. It does **not** catch an element replaced under the same id: the ids are identical and the index-keyed height cache keeps the pre-edit measurement
    *   **The order is the finding, not the guard.** Switched on first it would have made things worse: 412 tests green and the `RangeError` gone, but its rebuild ran the broken derivation, so a loud crash became a *silently missing row* — and which of the two a caller got depended on which member they removed. #132 recorded the reason as "unaffordable", corrected it to "ordered behind something else", and only the second reason had an expiry date
    *   **The rule had seven copies, not four.** The issue was written against the four the pure functions and the state methods hold; the adversarial pass found three more inside the widget — `_buildRowWidget`'s own anchor, its per-member height loop, and the stacked-cell loop that drew an empty cell for a member `data` does not hold. The four that were *testable in isolation* were the four that got found, which is worth stating as a property of hand-lists rather than of this one. The anchor now has a single home, `_mergedGroupAnchor`
    *   **Two of those three have no test, on purpose.** `_buildRowWidget` now passes the extent the list actually allocated instead of letting the widget fall back to `theme.rowHeight * effectiveRowCount`, and its height loop skips an absent key. Measured under mutation, both change only the height the merged row's inner `SizedBox` *asks* for — and the list hands that row a tight constraint, so the box, the texts and every position are identical either way. They are still right, because a widget asking for a height it will not be given is a disagreement waiting for the constraint to loosen; but the only assertion available reaches into the implementation, which this project's own rules forbid. The reason is recorded beside the tests instead
        *   **Half of that stopped being true inside this same unreleased version.** #121 gave the per-member height loop's output a job: it now sets each member's fixed extent, so restoring an absent key to it moves a surviving member on screen, and `test/merged_row_member_heights_test.dart` observes exactly that. The `calculatedHeight` half is unchanged and the sentence above still holds for it. Left in place with this correction rather than rewritten — the reasoning was right when it was written, and what it was right *about* is the part worth keeping
    *   Passing a new list is still the cheaper signal and still the documented one. In-place mutation being *caught* is a safety net, not a second supported route, and `FlutterTablePlus.data` / `.rowId` / `.mergedGroups` now say exactly that
*   **BREAKING**: removed `onMergedRowExpandToggle` and `MergedRowGroup.isExpandable`. Both were dead surface — the callback was declared on `FlutterTablePlus`, threaded through `TablePlusBody` into `TablePlusMergedRow`, stored, and **never invoked by anything**; `isExpandable` was an extra `&&` in front of `isExpanded` and gated nothing on its own. Deleting both, plus all five of `isExpandable`'s consumption sites, left the suite at 405 passing tests with no assertion touched
    *   **Migration is deleting the arguments.** No behaviour changes, because neither did anything: a callback that never fired cannot have been load-bearing, and `isExpandable: true` was the only value that ever meant anything. `isExpanded` and `summaryBuilder` are untouched and keep working exactly as before
    *   **The reason this needed removing rather than documenting**: `docs/FEATURES.md` showed the callback in a `setState` example, in the same code block as `onMergedCellChanged`, which *is* wired — so a reader had no way to tell them apart. `docs/map/territory/merged-rows.md` called expansion "reported through `onMergedRowExpandToggle`", and `MergedRowGroup`'s own doc-comment promised that `isExpandable` would show an expand/collapse icon the package has never drawn. Three surfaces describing a working feature that did not exist
    *   **Deprecating first was considered and rejected.** A deprecation window exists to migrate working code, and there was none to migrate; what it would actually have bought is one more release in which the API still accepts an argument it ignores. The false documentation is the harm, and it is fixed either way
    *   **The expand control was always the caller's to draw**, and now the docs say so: put an `IconButton` in the merged cell's `mergedContent` and wire it to your own `setState`. A `MergedRowGroup` is an immutable value you rebuild, so the state has to live where the data does. `example/lib/recipes/merged_rows_recipe.dart` is a complete working version and already did this before the removal
    *   Everything below in this section was written while the release was numbered 2.16.2. The version moved because this entry landed, not because anything below it changed

*   **FIX**: dragging a column boundary now honours `minWidth` / `maxWidth` at any `scale`. The handle accumulated the drag in **rendered** pixels and clamped it against bounds a caller declares in **logical** ones — two coordinate spaces compared as one, so away from `scale: 1.0` a column's declared range was wrong by exactly the factor. Measured 2026-08-26: a column declaring `minWidth: 80, maxWidth: 300` at `scale: 2.0` reported **40** and **150**, and since it already sat past that halved ceiling at rest, touching the handle at all snapped it there before the pointer had moved anywhere
    *   `onColumnResized` therefore reports different numbers than 2.16.1 did for an app running at a scale other than 1.0. The old numbers were the defect: `minWidth` / `maxWidth` are documented as logical and were being enforced as rendered. Nothing in the public API changed, and at `scale: 1.0` — where the two spaces coincide — no behaviour moves at all
    *   The bounds are now converted where the handle is built, the same way `_handleColumnAutoFit` has always converted them for the double-tap path. One rule, and both paths into the shared `clamp` now reach it
    *   **Affected range: 2.9.0 – 2.16.1**, at any `scale` other than 1.0. The defect entered with `scale` in 2.9.0; releases before that had no factor for the two spaces to disagree by
    *   **Why no test caught it:** all three drag-to-resize tests ran at `scale: 1.0`, where logical and rendered pixels are the same numbers — so no assertion *could* have separated the two implementations. The suite now drags at 2.0 as well, including a column that declares no `maxWidth`, which is a separate branch of the conversion that nothing else reaches
    *   Three neighbouring paths were unobserved for the same reason and are guarded now, without changing their behaviour: auto-fit's measurement branch (which converts) and its `autoFitColumnWidth` override branch (which correctly does not), and the rendered position of the boundary itself — deleting the unscale on the *live* resize path used to leave the whole suite green while the column ran away from the pointer at 2.5x
    *   **Not fixed, and now recorded in `docs/map/territory/column-resize.md`:** changing the zoom during a held drag still reports a width in the pre-change space, and `maxWidth * scale / scale` is not exact at every double, so the reported number can sit ~1e-14 outside the declared bound at a scale accumulated by repeated wheel steps. Layout is unaffected in both cases
*   **FIX**: a table at a `scale` other than 1.0 no longer resets five of the caller's checkbox style fields to their defaults. `TablePlusCheckboxTheme.scaledBy` rebuilt `CheckboxStyle` by listing its fields, and the list had fallen behind the type — which belongs to `flutter_checkbox` and grows when *that* package ships, with no commit here to point at
    *   Measured 2026-08-26 at `scale: 2.0` against the pinned `flutter_checkbox 0.3.1`: `checkScale` 0.42 → **1.0**, `hoverColor` / `focusColor` / `splashColor` → **null**, `disabledOpacity` 0.17 → **0.4**. So a zoomed table lost its checkbox hover, focus and splash colours, its check scale and its disabled opacity — in every selection checkbox it draws: row, header select-all and merged-row
    *   **Affected: 2.16.0 (retracted) and 2.16.1 — one available release.** The list was *complete* when it was written: `flutter_checkbox 0.2.0` and 0.2.1 both declared exactly the 17 fields it named, so 2.10.0 through 2.15.3 are correct. 0.3.0 added all five at once, and 2.16.0 took `^0.2.1` → `^0.3.0`. `shadows` becomes a sixth on 0.3.2, which `^0.3.1` already admits, so an app that ran `pub get` after 0.3.2 shipped was losing six
    *   **2.16.0's own entry walked past it.** It called 0.3.0 *"purely additive over the surface this package uses"* and, in the same sentence, named both `CheckboxStyle.copyWith` and `CheckboxStyle.checkScale` — the fix and the defect. The claim was true of the upstream API and false of this package's behaviour, because **an additive change to a type you hand-list is a subtractive change to your copy of it.** That is the whole reason the fix is `copyWith` rather than a longer list
    *   **Narrower than it sounds, and worth stating plainly.** Three things had to hold together: a scale other than 1.0, a selectable table (`isSelectable` defaults to `false`), and a caller who had explicitly set one of the five. The hand-list reset each dropped field to *its own* default, so a caller who never named them got a byte-identical style — and `TablePlusCheckboxTheme.colored()` cannot reach any of the five, so it took a hand-built `CheckboxStyle`. A real defect, not one reachable from the defaults
    *   Both levels now use `copyWith` and name only what they change. `TablePlusHeaderTheme.scaledBy` was re-assembling `TablePlusResizeHandleTheme` the same way; it happened to list all five fields, so nothing was lost there — that one is a structural fix with no behaviour change
    *   **This is #50 one level down.** #50 rebuilt the *root* `TablePlusTheme.scaledBy` on `copyWith` for exactly this reason and left the sub-themes alone
    *   Guarded at both levels, at a factor of 2.0 because `scaledBy(1.0)` returns its receiver and proves nothing. The outer `TablePlusCheckboxTheme` is guarded too: a first attempt at this fix left its five layout flags at their defaults in the fixture, and re-assembling *that* class dropped `showRowCheckbox`, `cellTapTogglesCheckbox` and three more with the whole suite still green
    *   **And a tripwire for the next upstream release.** Neither type implements `==`, so no value assertion can fail when a field is added. `test/checkbox_style_field_set_test.dart` reads the *resolved* `flutter_checkbox` source instead and pins its field set: green at 0.3.1, and against 0.3.2 it fails naming `shadows`. It asserts nothing about behaviour — it says **go read the new field and decide whether the factor applies to it**, which is the half `copyWith` cannot answer: an added *dimensional* field is now carried faithfully and never scaled
*   **EXAMPLE**: The example app is being rebuilt as a **recipe browser** — one page per feature, each a single file you can read end to end and paste into your own app. In progress; this entry grows as the series lands ([#98](https://github.com/kihyun1998/flutter_table_plus/issues/98))
    *   **Every recipe runs inside a viewport preview.** A recipe renders at a chosen phone / tablet / desktop size and is told that size is the whole screen, so a table's column widths — and any `MediaQuery`-dependent branch your own code would take — resolve as they would on that device rather than in the desktop window. The frame owns its own `Overlay`, because a real viewport does: `Draggable` feedback and `just_tooltip` both resolve `Overlay.of(context)` to the *nearest* one, so without it a header cell dragged out of a preview drawn at 0.46x rendered at 1:1, floating over the whole window at more than twice the size of the row it came from
    *   **Each recipe shows its own source, read from the asset bundle.** Not a copy of the code in a string — the file itself, so a snippet cannot drift from what you just watched run
    *   **Shipped so far:** sorting, drag selection and cell editing; column reorder, resizing and zoom. Each carries its knobs, and each names the traps it found rather than designing around them — `TablePlusColumn.width` is a *preference* that flexible columns share proportionally (`maxWidth == width` is the only opt-out), `onColumnReorder`'s indices count *displayed* non-selection columns, and `resizable` is table-wide while the bounds are per-column
    *   **And since:** tooltips, the row card, merged rows and dynamic row heights ([#107](https://github.com/kihyun1998/flutter_table_plus/issues/107)). Four more traps named rather than designed around — `TooltipBehavior.always` means *whenever the column ellipsizes*, which is every column by default, so a table nobody configured already draws a cell tooltip over every cell; a cell tooltip nests **inside** the row card and the innermost wins, so a card only appears where the cells above it were silenced; a header's `always` ignores `textOverflow` entirely and its `onlyTextOverflow` measures uncached, so the two tooltip behaviours are two different rules wearing one type; and `MergedRowGroup.isExpanded` **adds** a summary row rather than hiding the members, which is the opposite of what "expand" suggests
    *   **The width lesson from the previous batch caught the next recipe anyway.** The entry above already said `TablePlusColumn.width` is a preference that flexible columns share proportionally — and the dynamic-height recipe still measured its text at the declared 300 while the column painted at 517.5 in an 1100px window, giving every row a wrap 250px narrower than the one it got. `maxWidth == width` is the opt-out, and it is now asserted at two viewports rather than described once
    *   **The demo table decides its own tooltip colours**, in both brightnesses. The package's default is a fixed `#616161` with white text — legible in either, which is why nothing forced the decision until a recipe drew one. `headerTooltipTheme` stays null on purpose: null *is* the documented fallback to `tooltipTheme`, and the tooltips recipe exists partly to walk it
    *   **Two font bugs the app could not report, because a missing glyph does not throw.** Flutter draws an absent character from a platform face, so both of these rendered as a typeface seam rather than as an error, and both survived several releases. The bundled Pretendard subset held six of General Punctuation and not the em dash, under a doc-comment claiming it was bundled for Korean it had never carried and the demo data has never contained; the charset is now written down as ranges in `scripts/fonts/subset_pretendard.py` and a test reads the shipped `cmap` against a scan of the sources, rather than checking the characters somebody remembered. And the Code pane set `fontFamilyFallback` without `fontFamily` — which appends to the inherited family instead of replacing it — so it had been drawing source in the proportional chrome font since the pane was built, with indentation that could not line up ([#122](https://github.com/kihyun1998/flutter_table_plus/issues/122), [#123](https://github.com/kihyun1998/flutter_table_plus/issues/123))
    *   **The Code pane highlights, and the highlighter is proved unable to change what you paste.** A pure-Dart tokenizer with zero imports returns a **partition** — concatenating the token texts reproduces the bundle's bytes exactly. There are two ways the file leaves the pane and they are proved separately, because they are different paths: the **copy button** hands over the bundle's bytes directly and never passes through the highlighter, while **selecting and copying** does, and is checked by flattening the rendered spans with the same call the clipboard makes. The property is structural rather than asserted: tokens are cut from recorded end offsets, which makes the two shapes a hand-written scanner reaches for naturally unreachable — splitting on `\n` and re-joining, which silently normalises CRLF, and lower-casing a word to match a keyword. It is **hue-free**, because the chrome is achromatic on purpose and the scheme is `monochrome` seeded from black, so weight, slant and the grey roles are the whole vocabulary; comments are the one thing *not* dimmed, inverting the usual mapping, because in this corpus they are 29% of the lines and they are the teaching. A **copy button** joins the path bar, disabled while loading and on failure rather than hidden — the two states where copying would silently yield nothing. **Line numbers were dropped**: the pane is the affordance of the pasteable claim, not a source viewer, and their natural implementation is also the broken one, since an inline gutter of placeholder spans writes `\u{FFFC}` into every copied line ([#113](https://github.com/kihyun1998/flutter_table_plus/issues/113))
        *   **Two of the three grounds offered for these decisions were falsified before they shipped, and the decisions kept anyway.** The copy button was argued as a touch-platform capability — measured false, because `SelectableText` defaults its `contextMenuBuilder` to `AdaptiveTextSelectionToolbar` and long-press → Select all → Copy already worked. Line numbers were dropped because "nothing in the app names a line" — false at repo scope, since two scenarios cite `file:line` and the MAP gate actively rejects line numbers in favour of symbols. Both survive on one sentence that was already written and that neither argument had cited. **A conclusion reached on a wrong reason is a conclusion the next reader deletes as obsolete**, which is #69's lesson arriving through a decision rather than through a doc comment
        *   **And two guards were added because the obvious ones look sufficient and are not.** The #123 monospace test reads `EditableText.style` — the *wrapper* `SelectableText` puts around a given span tree — so once the pane went `.rich` a token span naming a font family would have rendered proportional with that test still green; it is measured, by mutation, that the new leaf-level assertion reddens while all three original ones stay green. The achromatic-chrome test hand-listed four `ColorScheme` roles and the highlighter draws from two others. Both are the shape that let #110 close as "the demo goes neutral" while four blues survived: **a check that reads a value's source rather than its destination passes anything that acquired the value another way**
    *   **A rationale this repo had already withdrawn was still on one page.** #69 established that a row card anchors at the pointer because a row is `contentWidth` wide — not because its centre scrolls off screen, which stopped being true at `just_tooltip 0.4.2`. The anchor page kept the old reason, in phrasing that sweep never matched. Same conclusion, and the wrong reason is the one that gets the requirement deleted as obsolete ([#124](https://github.com/kihyun1998/flutter_table_plus/issues/124))
    *   **The app has a real theme now**, light and dark, with no hard-coded colours left in the demo table. The playground's own colour decisions were deleted rather than re-themed, and the demo data was lifted out of it so every page shares one source ([#99](https://github.com/kihyun1998/flutter_table_plus/issues/99), [#100](https://github.com/kihyun1998/flutter_table_plus/issues/100), [#110](https://github.com/kihyun1998/flutter_table_plus/issues/110))
    *   **And a mode that draws every viewport at once.** The Device Wall puts desktop, tablet and mobile side by side on the same knobs and the same state, so an interaction in one frame paints its result in the other two — *what changed between two widths*, at once, rather than held against a memory of the other mode. It was specified to take no pointer input and ships live instead: the reason given was that scaling put drag selection's coordinate frame in question, which was measured and withdrawn, and the fallback reason — three frames are too small to operate — is true of one of them. They do not share a scale, because each viewport is fit into an equal column and the frame never scales up: measured at an 1800px window, desktop 0.28×, tablet 0.48×, and **mobile at 1.0×, its full size**. The desktop frame's rows are ~11px and imprecise to hit; the single-viewport modes are where precision lives. Every column is always fit, so the Fit / 1:1 control is not drawn in this mode ([#108](https://github.com/kihyun1998/flutter_table_plus/issues/108))
    *   **And two scenarios, which are a recipe's opposite bargain.** A recipe shows one feature with nothing else switched on, which is what makes it readable and what makes it unlike any real screen. A scenario assembles several and answers the other question — *what does this look like when you put it together*: an HR dashboard that merges four departments, sorts inside each one and selects across them, and a table of up to a hundred thousand rows that times its own generation and its own sort against the playground's existing performance monitor. The seam between the two zones is **asserted rather than assumed** — `lib/recipes/` is held to an import allow-list and `lib/scenarios/` is deliberately outside it, so a scenario may reuse the monitor and a recipe may not, and the test also insists at least one scenario really does import something a recipe could not ([#109](https://github.com/kihyun1998/flutter_table_plus/issues/109))
        *   **Sorting a merged table is the caller's problem, and the dashboard is what the answer looks like.** `data` and `mergedGroups` are two caller lists the package validates neither against the other, so a *global* sort by salary interleaves the departments and draws each group stacked at wherever its earliest surviving member landed — nothing throws and nothing warns. Sorting **inside** each department and rebuilding the group list in the same pass is not a workaround for a limitation; it is what "group by department, sort by salary" means. Measured under mutation: building the groups from the unsorted list leaves every other assertion in the suite green, because every id is still in the right group and only where it is drawn has moved
        *   **The Device Wall exclusion stopped being a comment.** It was written in three places and enforced in none; it is now `StageDestination.allowsWall` — the destination's call, not the page's — plus `ShellPage` leaving the wall when a destination that refuses it is opened. That second half is the one nothing would have reported: `SegmentedButton` asserts three things and none of them is that `selected` is a subset of `segments`, so dropping the segment out from under the selection draws a bar with nothing highlighted, over a wall that should not be there
    *   **Nothing was removed.** The playground and every existing entry point still work; the browser is a new surface beside them
*   **FIX**: changing `calculateRowHeight` now re-measures the rows. `TablePlusBody` invalidated its height cache only when `data` or `mergedGroups` changed identity, so handing the table a new height function while the list stayed the same object changed nothing on screen: the rows kept the heights they were first measured at. Measured 2026-08-26 — swapping a height function from 100 to 40 with the `data` list held identical left the rendered row pitch at **100**
    *   `FlutterTablePlus` has always watched `calculateRowHeight`, so its own total-height figure *did* update. That figure decides `needsVerticalScroll`, which is passed back down and also settles the last row's bottom border — so the table could conclude it needed vertical scrolling, or that it did not, from heights it was not drawing. (The ListView's scroll extent is **not** affected: it comes from the body's own `itemExtentBuilder`, reading the same stale cache as the rows, so those two stayed consistent with each other. An earlier draft of this entry said the extent and the rows disagreed; they do not.)
    *   **Only reachable when the height function's identity changes**, which is why there is no report and why nothing caught it: a static tear-off — what this package's suite and both example recipes passed — can never change identity. A closure over state (a density toggle, a font-size slider) is a new object on every build, and that is the ordinary way to write one
    *   **Affected: every 2.x release, 2.0.0 – 2.16.1**, wherever a caller passed a `calculateRowHeight` that is not a constant tear-off. The body's height cache and the parent's identity check both arrived before 2.0.0 — the cache with `itemExtentBuilder`, the check with the generic `<T>` migration — and `git log -S` finds the parent's condition written once and never edited since, so the two have disagreed for the whole major. A table with no height function, or with a tear-off, renders exactly as before
    *   `calculateRowHeight` joins `scale` in the *measurement* branch rather than `data` in the *structure* branch. Its identity changing says nothing about which rows exist, so `RowLookup` and the renderable indices survive and only the heights — and the geometry accumulated from them — are dropped. The two branches now say what kind of change they handle, which is something a future field can be checked against; the previous split was by which field happened to be listed
    *   **The `scale` clause turned out to be untested as well**, found by deleting it and watching the suite stay green. Reaching it needs a table that uses `calculateRowHeight` *and* a rebuild changing only `scale`, and nothing had both — so a zoomed table with per-row heights was resting on an unproven line. Its behaviour was always correct; only the proof was missing, and it has a test now
*   **TESTS**: drag selection is now exercised against **changing** row heights. `TablePlusBodyState` answers every hit test from a `RowGeometry` snapshot built lazily on the first drag and held until something clears it — and nothing checked that it ever was cleared: deleting the clear left the whole suite green, because every drag test ran on one uniform height and never re-pumped. Two tests close that, one per arm of the invalidation branch
    *   Two separate things are pinned, and the distinction is worth keeping straight. Both *lines* of the measurement branch are load-bearing — deleting either the geometry clear or the height clear reddens **both** tests, because `_buildGeometry` re-reads the height cache and a rebuilt snapshot would otherwise re-read stale numbers. Both *arms of the guard* are load-bearing too, and there one test each: dropping the `scale` arm reddens only the scale test, dropping the `calculateRowHeight` arm only the other. So neither test is redundant
    *   Each test is also verified **unable to pass for the wrong reason**: with the invalidation deleted, removing the priming drag or letting the second pump take a fresh list turns it green. The first would leave the snapshot unbuilt, the second would rebuild it through the structure branch — and a fixture that can go green either way proves nothing
    *   Writing those tests found the defect below, which is why this entry has a FIX under it
*   **FIX**: changing row height through the **theme** now invalidates the caches derived from it. `TablePlusBodyState` and `FlutterTablePlusState` each cached row heights behind a hand-written condition listing `data`, `mergedGroups`, `calculateRowHeight` and `scale` — and `theme.bodyTheme.rowHeight` is a height input that appeared in neither. Changing it while the data list kept its identity left both caches serving the previous height
    *   **Two symptoms, and neither one looks like a stale cache.** The rows are drawn correctly throughout — `itemExtent` and `itemExtentBuilder` read the theme live — so only what is *derived* from the caches is wrong. In the body that is the `RowGeometry` every drag hit-test is answered from: measured 2026-08-31, rows drawn at 40px while a drag across four of them reported the two they would have covered at 80. In the parent it is the cached total that decides `needsVerticalScroll`, so **the vertical scrollbar can silently fail to appear** when rows grow past the viewport
    *   **Affected: 2.13.0 – 2.16.1** for the drag half — `RowGeometry` arrived in 2.13.0 — and **every 2.x release** for the scrollbar half, whose cache dates to the 1.17.x series. Reachable without any height callback at all, which is what makes it broader than the #120 case: this repository's own example has a row-height slider that reaches it
    *   The three measurement inputs now live in one predicate, `rowMeasurementChanged`, called by both widgets. **It is a reduced list, not a derivation** — Dart cannot enumerate what a computation reads, and folding the inputs into a value type with an `==` would move the hand-listing into that operator, which is the shape that dropped fields from `scaledBy` in #50 and #116. What one predicate removes is the failure that actually happened twice: two conditions that disagreed
    *   `docs/map/invariant/no-hand-enumeration.md` is widened to hold both shapes. The interval is the finding — #50 to #116 was six releases, #120 to #128 was one
    *   One test per input, each holding the data list identical. The scale term turned out to be **redundant for the body and load-bearing for the parent**, because the two callers pass differently-scaled heights; a mutation deleting it survived until a test reached the parent's path alone
*   **EXAMPLE**: `example/README.md` describes the recipe browser. It was still sixteen lines of the `flutter create` template — *"A new Flutter project. This project is a starting point for a Flutter application."* — on a package whose example is a curated recipe browser, and pub.dev gives `example/` its own tab, so it is a published surface ([#138](https://github.com/kihyun1998/flutter_table_plus/issues/138))
    *   **It deliberately carries no list of recipes, not even in prose.** The roster is `lib/shell/recipe_catalog.dart`; a second copy in a README is a thing a new recipe has to remember to join. A first draft of this README listed all eleven in a sentence, one paragraph above saying it would not
    *   **And writing that sentence found the guard pointing the wrong way.** `test/recipe_seam_test.dart` checked `expect(onDisk, containsAll(registered))` under a comment reading *"A recipe added and never listed is exactly the one nobody would think to check"* — which is the case that assertion passes. The intent was written and the assertion did the reverse. Both directions are checked now, and the new one was verified by adding an unregistered file and watching it fail
*   **EXAMPLE**: the playground stopped demonstrating the mutation the package documents against, and stopped paying for the accident that hid it. It sorted and removed rows in place and replaced cells with `_data[rowIndex] = ...`, all of which hold the list identity so the table never re-derives — and it was safe anyway only because `mergedGroups: ... : []` allocated a fresh list on every build, rebuilding every cache every build. Both are fixed, in that order, since removing the rescue first would have exposed the mutations ([#136](https://github.com/kihyun1998/flutter_table_plus/issues/136))
    *   **A department edit left the grouping describing the previous departments.** `_updateMergedGroups` derives its groups from `Employee.department` and `_handleCellChanged` never called it, so editing that cell changed the grouping input and nothing recomputed the grouping. Found by reading the call graph, not by reproducing it — the playground needs a window, which is not an agent gate here
    *   **The page also contradicted its own recipe.** `calculateRowHeight` was an inline closure, which `recipes/dynamic_row_height_recipe.dart` spends two paragraphs advising against and prices; it is a `static` function now
    *   **Pinned by a source scan rather than by a pumped widget**, because nothing else could catch it: the analyzer has no opinion about `list.sort()`, and a widget test renders the new contents correctly since rendering reads `data` live. `example/test/snapshot_idiom_test.dart` states what it cannot see — it matches spellings, not semantics — and each of the three reverts reddens exactly its own assertion
    *   **The two recipe getters that rebuild their group list every build are left alone, on purpose.** They are correct for staleness and pay a rebuild for it, their row counts are small, and memoising would put a cache into code whose point is that a `MergedRowGroup` is an immutable value you rebuild. The over-invalidation direction is now named in `FlutterTablePlus.mergedGroups`, which previously said only "rebuild the list as well"
*   **FIX**: a `calculateRowHeight` written as a `State` method tear-off no longer drops the row-height cache and the drag hit-test geometry on every build. `rowMeasurementChanged` compared it with `identical`, and the comment justifying that choice named a hazard `==` does not have — measured 2026-08-31, `==` agrees with `identical` on every shape a caller writes except a tear-off, where it is `true` because it **is** the same function on the same receiver ([#137](https://github.com/kihyun1998/flutter_table_plus/issues/137))
    *   **`identical` was not even stable on that shape.** A `State` tear-off compares `false` in the JIT test VM and `true` under AOT, so the guard behaved one way in tests and another in the build users ship. That is the same JIT/AOT trap that put a wrong row into `docs/map/territory/row-identity.md`'s measurement table in the first place
    *   Two tear-offs of the same method on *different* receivers still compare unequal, which is the case that had to keep working; it is pinned rather than assumed. Nothing else in the suite moves — reverting the operator reddens exactly the two new tests and no others
    *   **No caller sees a behaviour change**, only fewer measurements: the heights were always recomputed to the same values, which is why nothing on screen could observe this and the test counts callback invocations instead
*   **DOCS**: `data`, `rowId` and `mergedGroups` now say what they oblige the caller to do. The three are one **snapshot**: every id-keyed derivation — `RowLookup`'s two maps, the renderable-index list, and the ids the drag hit-test geometry is answered from — is built from the pair `(data, rowId)` and dropped only when `data` is a *different object*. So writing `groups[0] = newGroup` on the same `mergedGroups` is not seen. Swapping `rowId` while keeping the same list was not seen either when this entry was written; the **FIX** at the top of this release closes it, and the paragraphs below describe the state #132 left rather than the state 2.17.0 ships. Each field's doc-comment was one line before and said none of this ([#132](https://github.com/kihyun1998/flutter_table_plus/issues/132))
    *   **Measured 2026-08-31**, with a drag before the change so the lazily-built geometry actually exists: after a `rowId` swap over an unchanged list the rows render as `X0..X5` and the selection highlight follows the caller's new ids, while the drag callback keeps reporting `{0, 1, 2, 3}` — ids that no longer exist in the caller's space. **That is #128's shape**: the screen right and the answer wrong
    *   **The in-place group mutation is milder, and the word is doing narrow work.** On its own nothing diverges: render and hit-test read the same stale lookup, agree with each other, and the table shows the previous state while describing it correctly -- the update is missed rather than misreported. **Put a measurement change in the same build and that stops being true.** The parent ORs `rowMeasurementChanged` into the branch that also holds its two identity checks, so it rebuilds from the *live* group list; the body keeps those in an `else if`, so it keeps the stale lookup. The parent then believes 320px of content in 300px, raises `needsVerticalScroll` and draws a vertical scrollbar over a `ListView` whose `maxScrollExtent` is `0.0`. Pre-existing, and documented nowhere before this
    *   **`rowId` was not guarded here, and the reason was ordering rather than cost — the ordering resolved later in this same release.** The first version of this entry said the guard was unaffordable. That is true of the *obvious* guard and only of that one: `rowId` is required, every call site writes an inline closure -- all fifteen in this repo's own example -- and an inline closure is a new object on every build even when it captures nothing, so `!identical(rowId)` fires for every caller on every build and rebuilds both lookups, measured AOT at 0.08% of a 16.7ms frame at 100 rows, 0.70% at 1,000 and **10.0%** at 10,000
        *   **The option nobody costed was comparing the answers.** `RowLookup` already stores the ids, so regenerating them through the current closure and comparing is complete rather than heuristic, and costs 0.010% / 0.112% / **0.971%** at those sizes -- about a tenth. It is not even a new pattern here: `lib/src/utils/overflow_cache.dart` keys on the derived `(text, width)` pair and never compares the `measure` function it is handed
        *   **What holds it back is what it does once switched on.** Prototyped: 412 tests green, and an in-place `removeWhere` that used to throw a `RangeError` stops throwing. But on a merged-group table the rebuild it triggers runs `computeRenderableIndices`, which drops a group's remaining members when the removed row was the group's **first** key -- so a loud crash becomes a silently missing row, and which of the two a caller gets depends on which member they removed. Measured. The derivation is fixed first, then the guard — and that is exactly the order both landed in, in the entry at the top of this section
    *   **This is the obligation Flutter already states for lists**, four times over — `SliverChildListDelegate.children`, `TwoDimensionalChildListDelegate`, `MultiChildRenderObjectWidget.children` and `PlatformMenuBar.menus`, that last a list of non-Widget data objects and so the closest documented shape to `mergedGroups`. It states none for a *function*, because where the SDK takes one it either compares it (`ListWheelChildBuilderDelegate.shouldRebuild`) or caches nothing from it (`AnimatedList` reads `itemBuilder` live). This package extracts identity through a separate **required function** — a deliberate divergence, and the thing that stopped the data's identity covering the caches derived from it
    *   **No public API and no runtime behaviour changed.** A caller already handing over a new list whenever the data changes — the ordinary way, and what every recipe here does — was never affected and still is not
    *   **The sweep found this package teaching the pattern the contract forbids.** `README.md`'s Core Philosophy block and `docs/FEATURES.md`'s sorting example both wrote `_myData.sort(...)` in place — and `FEATURES.md`'s *other* branch already built a new list, so the two arms of one example disagreed with each other. The playground did the same with an in-place sort and two `removeWhere`s, and was correct only by accident: its `mergedGroups:` ternary allocates a bare `[]` on the false branch, a fresh object every build, which invalidated every cache every build and hid the mutation. All of them now pass a new list
    *   **And one comment in `lib/` was false in the way that matters.** `_rowLookup`'s own doc said it is *"rebuilt whenever the data or merged groups change"* — a **content** claim in front of an **identity** check, sitting directly above the cache this entry is about. `MergedRowGroup.isExpanded` taught rebuilding the group and stopped one step short of the list; `RowLookup.build`'s doc named two of its three inputs; and `rowMeasurementChanged`'s *"deliberately absent"* list named `data` and `mergedGroups` and not `rowId`, which is absent for the opposite reason — not that it fails to change what a height is, but that it is the one caller function this package could not watch
    *   **Commit or cancel an open cell edit before changing the id space** — including the supported way, which is the part worth knowing. A session is pinned by *index* and re-pinned by *id*, so a new `data` list makes it search that list for the id it captured, which is an id from the space just left; it is not found, the session is disposed, and the typed text goes with it without an `onCellChanged`. The duplicate-id validator likewise does not run over a swapped `rowId`, being gated on the same list identity. `docs/map/territory/cell-editing.md` records this, and its `## Governing decisions` had already listed *"whether an edit survives a rebuild with different data"* as unrecorded
    *   **This entry first said the opposite, and the correction is the useful part.** It claimed an in-flight edit *"commits against the abandoned id space"*. Measured: it does not, and it cannot — `_stopEditing` reports `data[session.rowIndex]`, the column key and the index, and touches no id at all. So the hazard is losing an edit, never misreporting one, and the reasoning had inverted which side of the contract carries the risk: it is the caller who **obeys** the new rule who loses the edit
    *   **And #120's own residue, found by re-reading the same predicate.** `example/lib/recipes/dynamic_row_height_recipe.dart` still told readers, in the present tense, that the per-index height cache *"is not keyed on the callback"* and that a function answering differently *"leaves the old heights on screen"* -- quoting #120's own measurement as a live hazard. The advice it supports (hold the callback still, prefer a pure function) is unchanged; the second of its two reasons is what stopped being true
        *   **It stopped being true in this unreleased version, not in a shipped one**, and the difference is the whole point of stating it: #120's fix is in 2.17.0 and the latest published version is 2.16.1, so for every reader on a released build that warning is **still accurate today**. The recipe now says "Fixed in 2.17.0" rather than describing it as past. An earlier draft of this entry said "one release ago", which would have been a count of zero
    *   **Two production defects surfaced by the pass that checked this work, both filed rather than fixed here** — this entry changes no runtime behaviour and neither of them can be closed without doing so. On a table with `mergedGroups`, *shrinking* `data` in place throws a `RangeError`: `itemCount` reads the cached render-index list while the row build reads `data` live, and two of the three readers of that index already range-guard while the third does not. And a caller who obeys the new rule exactly — a **new** `data` list — still loses rows silently if that list no longer holds a row some group names, because `computeRenderableIndices` adds nothing when the group's first key is missing and marks the rest processed anyway. The doc-comments on `data` and `mergedGroups` said both plainly, since *"is not seen"* reads as benign and one of these is a red screen. Both were then fixed under this same version and those comments rewritten again; the **FIX** at the top of this release is where the current contract lives
    *   Two tests pin the **supported** path rather than the stale one, on purpose: asserting the stale answer would freeze a documented non-guarantee into the suite and make a later decision to guard `rowId` read as a regression. The rule lives in `docs/map/territory/row-identity.md`, whose `## Reference behaviour` also stops saying the `DataTable` comparison "has never been written down"; `docs/map/invariant/no-hand-enumeration.md` records it as shape 2's **second exit** — name the input as a contract instead of adding it to a list — and carries the grep for the next one: of fifteen function-typed parameters on the public widget, exactly two have cached results
*   **INTERNAL**: `lib/` changed in the three fixes above, in the removal at the top of this entry, and in doc-comments: one correction that #128's sweep reclaimed, plus #132's contract on `data` / `rowId` / `mergedGroups` and the four `lib/` comments its own sweep reclaimed — the cached-geometry field still described the invalidation set #120 had already widened. (This line read "one place", then "three places", then "four places", as each further change landed under the same open version. It has stopped carrying a count: the count was reassurance that a *patch* release was small, and this is no longer a patch release. The list is the honest form.)
    *   Verified against `flutter_checkbox` **0.3.2**, the version a consumer's `pub get` picks today, not only against the 0.3.1 that happened to be resolved locally. The constraint stays `^0.3.1` — 0.3.1 is fine and excluding it would be a floor nobody needs — and 0.3.2 declares the identical `sdk >=3.6.0` / `flutter >=3.27.0`, so nothing moves. `example/pubspec.lock` records it; the package's own lockfile is git-ignored, as a published library's should be, which is exactly why "all tests pass against 0.3.x" has always meant *whatever that machine resolved that day*
    *   The new tripwire earned itself on that upgrade, an hour after it was written: it failed naming `shadows`, upstream's changelog settled that the field is deliberately unscaled — *"like `borderWidth`, `borderRadius` and `checkStrokeWidth`, shadow offsets and radii stay in logical pixels while `scale` resizes the box"* — and the field set was updated with that reason attached. Against 0.3.2 the old hand-list reddens two tests instead of none. Alongside it the repository grew a **territory map** (`docs/map/`, with its own gate) and a compiled agent build (`docs/agents/thegraph.md`). Neither ships: the root `.pubignore` excludes `docs/`, so the archive is unchanged by them

## 2.16.1

*   **DEPS**: `flutter_checkbox: ^0.3.0` → `^0.3.1`, which **lowers this package's minimum Flutter to `3.27.0` (Dart `3.6.0`)**, down from the `3.35.0` (Dart `3.9.2`) that 2.16.0 declared. `lib/` is byte-for-byte unchanged; all package and example tests pass against 0.3.1 unmodified
    *   **2.16.0 was retracted.** It shipped a `3.35` floor that was too aggressive — a floor it never actually needed. This release supersedes it. *Relative to 2.16.0* the floor moves **down** (`3.35` → `3.27`), so this entry is not breaking. But 2.16.0 is retracted, so `pub` upgrades come from the last non-retracted release, 2.15.3 (Flutter `3.13`); **relative to 2.15.3 this still raises the floor to `3.27`** and inherits 2.16.0's `flutter_checkbox` `^0.2.1` → `^0.3.x` bump — read the 2.16.0 entry for that BREAKING context. 2.16.1 only *reduces the size* of the raise 2.16.0 attempted
    *   The `3.35` floor was never this package's own requirement — it was inherited. 0.3.0 had set *its* floor to `3.35`, the SDK it happened to be built with rather than the one its code needs, and taking `^0.3.0` made that `3.35` our transitive requirement. 0.3.1 corrects it to the real minimum — `Color.withValues` is its newest call (Flutter `3.27` / Dart `3.6`), everything else needs only Dart `3.0` — so this package's floor is free to follow it down. The other binding, `just_tooltip` 0.4.4, floors at `3.13`, so the honest floor is `max(3.27, 3.13) = 3.27`
    *   The constraint is raised to `^0.3.1`, not left at `^0.3.0`, on purpose: `^0.3.0` still admits 0.3.0, whose `3.35` floor a `3.27` user could not satisfy. A declared SDK range is only honest if it holds for *every* version the constraint allows — the same reasoning the 2.16.0 raise applied when it moved the floor up, applied here to move it down

## 2.16.0

*   **BREAKING**: minimum Flutter is now `3.35.0` (Dart `3.9.2`), up from `3.13.0` (Dart `3.1.0`). No class, method or field in this package changed — the *floor* did. `flutter_checkbox` 0.3.0 corrected its own declared minimum from a `flutter create` default (`>=1.17.0`) to its real one, `Dart ^3.9.2` / `Flutter >=3.35.0` (it uses `Color.withValues`, 3.27+, and 3.9.2 language features). Taking `^0.3.0` makes 3.35 the transitive requirement, so any floor lower than that here would be a promise this package could not keep — the same honesty the 3.13 raise served in 2.15.0. This subsumes the Flutter 3.13 floor `just_tooltip` imposed, which still stands unchanged upstream
    *   An app that pinned an older SDK can stay on 2.15.3; upgrading to 2.16.0 requires Flutter 3.35+
*   **DEPS**: `flutter_checkbox: ^0.2.1` → `^0.3.0`. 0.3.0 is purely additive over the surface this package uses — it *adds* constructor-level `activeColor` / `checkColor` / `semanticLabel`, `CheckboxStyle.copyWith`, style-resolved overlay colors, and `CheckboxStyle.checkScale`, and removes nothing (the last removals were 0.2.0, which this package already sits above). So `lib/` is byte-for-byte unchanged; all 382 package tests and 67 example tests pass against 0.3.0 unmodified
    *   Reachable from the defaults: 0.3.0 merges the checkbox's state semantics and its tap action onto one node (`MergeSemantics`), where before a screen reader saw two. Every selection checkbox this table renders — row, header select-all, merged-row — now announces and activates as a single control to assistive tech, with no code change here

## 2.15.3

*   **DEPS**: `just_tooltip: ^0.4.3` → `^0.4.4`. **A floor, not a preference.** 0.4.4 stops a tooltip that has nothing to draw from displacing the tooltips around it ([just_tooltip#46](https://github.com/kihyun1998/just_tooltip/issues/46)) — the very guarantee 2.15.2 secured for itself by never building such a tooltip. That guard is gone now, so under 0.4.3 this package would *reissue* the bug 2.15.2 fixed, rather than merely miss an upstream improvement
    *   The SDK floor is unchanged. 0.4.4 still declares `sdk >=3.1.0 <4.0.0` and `flutter >=3.13.0`, so this package's Flutter 3.13 floor stands
    *   0.4.4 also makes a tooltip that is already on screen follow changes to its `message`, `tooltipBuilder`, `theme`, `direction` and `alignment` ([just_tooltip#47](https://github.com/kihyun1998/just_tooltip/issues/47)); the overlay rendered them live but nothing ever asked it to rebuild. Nothing here relied on the old behaviour — all 382 package tests and 67 example tests pass against 0.4.4 unmodified
*   **REFACTOR**: `wrapWithTooltip` no longer skips the wrap when the resolved message is empty. just_tooltip owns that rule now, and a local copy of the predicate was a second thing that had to agree with the first, with nothing in the build to make it
    *   `a cell tooltip that cannot show does not suppress the card` did not change one character. It observes the contract — the row card survives — and not the mechanism, so it kept passing once upstream took the mechanism over
    *   Removing the guard while allowing 0.4.3 is what would break, and only there: the same test is the single failure across the suite when both are done
*   **DOCS**: 2.15.2 argued for its fix with a rationale that 0.4.4 has made false, and **no test guards a rationale**. It held that suppressing ancestors from `MouseRegion.onEnter` was an intended contract of just_tooltip, so a tooltip that cannot show must never be built. Upstream has since judged that a trap in its own default and fixed it there. What 2.15.2 shipped was right for 0.4.3; the reason it gave was not, and a reader following that reason today would conclude the guard must stay
    *   Withdrawn from `TablePlusTooltipTheme.hideOnEmptyMessage`, `TablePlusColumn.tooltipFormatter`, `wrapWithTooltip`, `docs/THEMING.md` and the tests that repeated it. `hideOnEmptyMessage` now reads "draws nothing, and displaces nothing"
    *   `FlutterTablePlus.rowTooltipBuilder` needed no correction: "a cell only takes the card's place when it has something to show" is what 0.4.4 made upstream law

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
