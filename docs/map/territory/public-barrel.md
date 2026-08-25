# Public barrel and re-exports

## What it is

`lib/flutter_table_plus.dart` — the single file that decides what a consumer can
import. It exports this package's own types and **re-exports seven types from two
sibling packages** so callers do not have to depend on them directly.

One of the areas the maintainer names as never touched and expensive to get
wrong: nothing in this repository fails when it is wrong. The failure appears in
someone else's build.

## Governing decisions

**None.**

Nothing records the re-export policy: which sibling types are re-exported and
which are not, and what happens to the `show` list when a sibling adds a type.
The list is currently maintained by hand, and neither a test nor a gate reads it.

## Design model

- **The barrel is the public surface.** Anything not exported here is private by
  convention, regardless of whether Dart can reach it — `src/` is the marker.
- **Re-exports are `show`-listed, never blanket.** Four `just_tooltip` types
  (`TooltipAnchor`, `TooltipDirection`, `TooltipAlignment`, `TooltipAnimation`)
  and three `flutter_checkbox` types (`FlutterCheckbox`, `CheckboxStyle`,
  `CheckboxShape`) are named explicitly.
- **A `show` list is a compatibility promise in both directions.** Dropping a
  name breaks callers who imported it from here; failing to add one that a
  sibling introduced makes callers depend on the sibling directly, which is what
  the re-export existed to avoid.
- **Some public types are deliberately reachable only through `src/`.** Files
  that import `package:flutter_table_plus/src/...` internally are relying on
  that; the barrel is not the whole of what is importable, only of what is
  supported.

## Code

`flutter_table_plus.dart`

**No symbols — by construction.** The barrel declares nothing; it is export
directives end to end. There is no name here for a symbol check to resolve, and
that is the point: the file's whole content is a list of *other* files'
promises, which is exactly why nothing in this repository fails when it is
wrong.

## Reference behaviour

**None.** Whether the two siblings' current exports still match this `show` list
has never been checked against their sources — only assumed to hold.

## Cross-cutting invariants

→ [Do not work around an upstream contract here](../invariant/upstream-contract.md) — a re-export is the seam itself: it carries the sibling's names, and its floor, straight to every consumer

## Blast radius

→ [Publishing and release](publishing.md) — this list is what "breaking change" is measured against, and a removal is a major bump
→ [Tooltips](tooltips.md) — four of the seven re-exports are its types
→ [Row selection](row-selection.md) — the other three are the checkbox's
→ [Column model and ordering](column-model.md) — the most-imported type this barrel exports

## Known holes / open

**None.**
