# flutter_table_plus — recipe browser

The example app for [`flutter_table_plus`](https://pub.dev/packages/flutter_table_plus). It is not a
starting point for a Flutter application; it is a set of **recipes** — one per feature, each a single
file you can read end to end and paste into your own app.

```sh
cd example
flutter run
```

## What a recipe is

One `.dart` file under [`lib/recipes/`](lib/recipes), holding a working table for exactly one
feature — and the app's menu is where you see which features those are.

A recipe is written to be *taken*, which shapes it in two ways:

- **It is one file.** Nothing is factored out into a shared helper you would then have to find. The
  demo data and the app theme are the only imports a reader is expected to drop.
- **Its doc-comment says what bit.** Each recipe opens with the traps that feature actually has —
  `TablePlusColumn.width` is a *preference* flexible columns share proportionally,
  `onColumnReorder`'s indices count displayed non-selection columns, `MergedRowGroup.isExpanded`
  *adds* a summary row rather than hiding the members. Those notes are the part that took the
  longest to learn and the part a snippet cannot carry.

The roster lives in [`lib/shell/recipe_catalog.dart`](lib/shell/recipe_catalog.dart) and nowhere
else. **There is deliberately no list of recipes in this README**, not even in prose: a second copy
is somewhere for the two to disagree, and a new recipe would have to remember to join it.

The catalogue is not trusted on its own either. `test/recipe_seam_test.dart` walks `lib/recipes/`
directly and checks the roster **both ways** — a catalogue entry with no file, and a file the
catalogue never lists. The second direction is the one that matters, since a recipe nobody
registered is in no menu, gets no source pane, and is walked by no other test.

## Two things the browser does that are worth knowing

**Every recipe renders inside a viewport preview.** It is drawn at a chosen phone / tablet / desktop
size *and told that size is the whole screen*, so column widths — and any `MediaQuery`-dependent
branch your own code would take — resolve as they would on that device rather than in the desktop
window. The frame owns its own `Overlay`, because a real viewport does: `Draggable` feedback and
`just_tooltip` both resolve `Overlay.of(context)` to the nearest one, and without it a header cell
dragged out of a preview drawn at 0.46× rendered at 1:1, floating over the whole window. There is a
fourth choice that draws all three sizes at once, side by side, for when the question is what changed
*between* two widths. All three are live and share one state, so selecting or sorting in the phone
frame — which renders at its full size, since a frame is never scaled up — shows the result at tablet
and desktop width in the same moment.

**The source pane shows the file itself**, read from the asset bundle — not a copy of the code in a
string. A snippet cannot drift from what you just watched run if it *is* what you just watched run.

## Also here

- **The playground** — every knob at once, on one table. It predates the recipes and still works;
  the recipes are a new surface beside it, not a replacement.
- **The viewport lab** and the **tooltip anchor** page, for the two behaviours that are easiest to
  get wrong by reasoning about them instead of looking.

## `test/` is a gate, not an afterthought

`cd example && flutter analyze && flutter test` runs on every change to the package, and a red
example suite blocks a release the same way a red package suite does. That is a lesson rather than a
policy: a leftover `flutter create` counter template once kept this suite permanently red, which
teaches everyone to ignore it — and a gate everyone ignores is worse than no gate.

Some of those tests assert about the *sources* rather than about rendered pixels, because that is
where certain mistakes live: `snapshot_idiom_test.dart` catches a list mutated in place (the
analyzer has no opinion, and the table renders it correctly anyway), and `font_coverage_test.dart`
reads the bundled font's `cmap` (a missing glyph does not throw — Flutter draws it from a platform
face and the text changes typeface mid-sentence).
