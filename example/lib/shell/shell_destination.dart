/// What the menu can point at.
library;

import 'package:flutter/widgets.dart';

/// The groups the menu shows, in the order it shows them.
///
/// **Two of these name content and the third names a hosting kind, and that is
/// deliberate.** A recipe is one pasteable feature and a scenario is several
/// assembled; [pages] is the remainder, and what its members share is not a
/// subject but a shape — each is a full page with its own `Scaffold`, so the
/// shell points at it instead of drawing it. Inventing a content theme to cover
/// "every setting at once" and "where a tooltip sits" would be naming a set
/// after something it does not have.
///
/// It was `playground('Playground')` until #147, when a second member arrived
/// and made the old name visibly a description of one element rather than of
/// the set.
enum ShellCategory {
  recipes('Recipes'),
  scenarios('Scenarios'),
  pages('Pages');

  const ShellCategory(this.title);

  final String title;
}

/// One entry in the menu.
///
/// There are two kinds and the difference is not cosmetic: one renders *into*
/// the shell's stage, the other leaves the shell entirely.
///
/// That distinction is the whole reason this type is sealed rather than a class
/// with a nullable builder. The playground is a full page — its own app bar, its
/// own three panes — and putting it inside the stage would mean taking it apart.
/// It is pointed at, not absorbed, and the type makes that a fact about the
/// destination rather than a branch someone can forget to write.
sealed class ShellDestination {
  const ShellDestination({required this.id, required this.label});

  final String id;
  final String label;

  ShellCategory get category;
}

/// A destination the shell draws itself, in its stage and its knob region.
class StageDestination extends ShellDestination {
  const StageDestination({
    required super.id,
    required super.label,
    required this.category,
    required this.stage,
    required this.knobs,
    this.source,
    this.allowsWall = true,
  });

  @override
  final ShellCategory category;

  /// What goes under the viewport control.
  final WidgetBuilder stage;

  /// That destination's own controls — the ones it owns, and no others.
  final WidgetBuilder knobs;

  /// Whether the Device Wall may draw this destination.
  ///
  /// **The policy lives here rather than on the page**, which is what
  /// `ShellPage`'s own doc-comment asks for: the shell knows that a destination
  /// supplies a stage and some knobs, and nothing else about it. A page-level
  /// test against a particular id would be the shell learning what a scenario
  /// is.
  ///
  /// True is right for anything that is one table: the wall draws three of them
  /// over one state, so an interaction in the narrow frame paints its result in
  /// the other two. What it is wrong for is a destination whose point is a
  /// measurement — three tables over the same hundred thousand rows makes a
  /// frame rate a measurement of the wall (#109).
  ///
  /// Setting it false is not enough on its own: the wall is a mode the shell is
  /// already *in*, so `ShellPage` also has to leave that mode when a
  /// destination that refuses it is opened. Nothing reports the invalid state
  /// otherwise — `SegmentedButton` never asserts that its selection is one of
  /// its segments.
  final bool allowsWall;

  /// The asset key of the file this destination *is*, when it is one file.
  ///
  /// Null is the ordinary answer. A recipe is one self-contained file and can
  /// show it; a demo assembled from several widgets is not, and offering a
  /// Code tab there would have to pick one of them and call it the source. So
  /// the shell draws the control only where this is non-null — absent rather
  /// than present-and-lying.
  ///
  /// **There is a second reason, and it is the one the scenarios turn on.**
  /// Each of them *is* one self-contained file, so the criterion above would
  /// let them show it — and they still pass null. The Code pane is not a
  /// general source viewer; it is the affordance of the pasteable claim, which
  /// is why the file it shows is read from the bundle so what runs and what is
  /// displayed cannot disagree. `test/recipe_seam_test.dart` holds
  /// `lib/recipes/` to an import allow-list and deliberately excludes
  /// `lib/scenarios/`, so offering the pane over a file that rule excludes
  /// would change what the pane means (#109).
  final String? source;
}

/// A destination that opens on its own route.
///
/// The shell hands over and gets out of the way. Nothing about the page it opens
/// changes to accommodate being listed here.
class RouteDestination extends ShellDestination {
  const RouteDestination({
    required super.id,
    required super.label,
    required this.category,
    required this.open,
  });

  @override
  final ShellCategory category;

  final WidgetBuilder open;
}
