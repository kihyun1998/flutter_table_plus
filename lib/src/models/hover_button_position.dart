import 'package:flutter/widgets.dart';

/// Enum that defines the positioning of hover buttons within a table row.
enum HoverButtonPosition {
  /// Positions the hover buttons on the left side of the row.
  left,

  /// Positions the hover buttons in the center of the row.
  center,

  /// Positions the hover buttons on the right side of the row.
  /// This is the default behavior.
  right;

  /// Wraps [child] in a [Positioned] widget according to this position.
  Widget buildPositioned({
    required Widget child,
    double horizontalOffset = 8.0,
  }) {
    switch (this) {
      case HoverButtonPosition.left:
        return Positioned(
          left: horizontalOffset,
          top: 0,
          bottom: 0,
          child: Center(child: child),
        );
      case HoverButtonPosition.center:
        return Positioned.fill(
          child: Center(child: child),
        );
      case HoverButtonPosition.right:
        return Positioned(
          right: horizontalOffset,
          top: 0,
          bottom: 0,
          child: Center(child: child),
        );
    }
  }
}
