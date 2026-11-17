# `MediaQuery` padding is the screen's edge, not the table's

## The fact

Flutter's scrolling and scrollbar widgets read `MediaQuery` padding as the
part of the **screen** covered by a notch or a system bar, and keep their
content or their thumb clear of it unless told otherwise:

- a `BoxScrollView` (`ListView`, `GridView`) with no `padding` pads its
  sliver by the padding along its scroll axis and passes the cross-axis padding
  on to its children (`BoxScrollView.buildSlivers`, `widgets/scroll_view.dart`);
- Material's `Scrollbar` always insets its painter by it, `RawScrollbar`
  unless its `padding` is given.

That default is right for a widget drawn along the screen's edge. Inside the
table it is wrong: the table lays out its own body, strips and tracks, and
every coordinate it hands to hit tests assumes none of them moved. A table in a
real app is under a padding, because a `Scaffold` passes its body the
padding it does not use itself.

`SingleChildScrollView` reads no `MediaQuery` padding
(`widgets/single_child_scroll_view.dart`), so the header and the horizontal
scroll views are outside this rule. Flutter 3.41.9 for all three reads.

## Why it is cross-cutting

The padding arrives from above the table, through no parameter, and each SDK
widget inside reads it on its own. Two sites have taken it so far, in two
territories, and each was repaired differently because what sits **under** the
widget differs:

- a scrollbar strip's thumb is the table's own paint with no consumer child,
  so `MediaQuery.removePadding` on all four sides changes nothing a consumer
  reads (#238);
- the body list's children are the consumer's cells, which saw the left and
  right padding and the whole `viewPadding` before; `removePadding` would
  have zeroed their `viewPadding` top and bottom, so the list sits under a
  `MediaQuery` whose `padding` alone has top and bottom 0 (#242).

## Territories it holds in

→ [Synced scrolling](../territory/synced-scrolling.md) — both scrollbar thumbs were inset off their tracks (#238)
→ [Row rendering and geometry](../territory/row-render-geometry.md) — the body list padded its rows below the header (#242)
→ [Drag selection](../territory/drag-selection.md) — its hit tests put row 0 at the body's top, so a padded list made a drag select the rows below the ones under the pointer (#242)

## What a violation looks like

**No exception and no failing test**: under no padding, which is every widget
test that does not set one, the table draws as intended. Under one, something
moves by exactly a padding value: a row 30 px below the header, a thumb off its
track, a scroll extent 80 px longer (top 30 plus bottom 50). The costly form is
the one the screen does not show: a drag across the visible rows 0 to 3 that
reports 1 to 4 to the consumer's callback.

## Discovery history

**#238** found it in the scrollbar thumbs, and its entry left "`MediaQuery`
read anywhere else in the table" uncovered. **#242** found the body list, the
only other `BoxScrollView` in `lib/`, the day after, and is what made this a
note rather than a line in one territory.

## Where it will recur

**Any SDK scroll view, scrollbar, `SafeArea` or `Scaffold` placed inside the
table**: a grid of cells, a list in an editor overlay, a footer, an empty
state the table builds itself. Before adding one, read whether it consumes
`MediaQuery` padding and test it under a padding on all four sides. Then ask
the #242 question: does it have consumer children? If it does, decide what
their `MediaQuery` must still say before choosing `removePadding`.
`noDataWidget` is the consumer's own and is laid out outside the body, so it
still receives the padding.
