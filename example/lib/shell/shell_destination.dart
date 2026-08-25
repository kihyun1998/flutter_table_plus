/// What the menu can point at.
library;

import 'package:flutter/widgets.dart';

/// The groups the menu shows, in the order it shows them.
enum ShellCategory {
  recipes('Recipes'),
  scenarios('Scenarios'),
  playground('Playground');

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
  });

  @override
  final ShellCategory category;

  /// What goes under the viewport control.
  final WidgetBuilder stage;

  /// That destination's own controls — the ones it owns, and no others.
  final WidgetBuilder knobs;
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
