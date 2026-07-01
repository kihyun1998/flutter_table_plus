import 'package:flutter/widgets.dart';

import '../models/hover_button_position.dart';

/// Builds the positioned hover-button overlay for a row, or `null` when it
/// should not appear.
///
/// Shared by normal and merged rows, which previously each inlined the same
/// guard-then-build-then-position sequence. Returns `null` unless the row is
/// hovered, a [builder] is provided, and both an [id] and [data] are available
/// to feed that builder.
Widget? buildRowHoverButton<T>({
  required bool isHovered,
  required Widget? Function(String id, T data)? builder,
  required String? id,
  required T? data,
  required HoverButtonPosition position,
  required double horizontalOffset,
}) {
  if (!isHovered || builder == null || id == null || data == null) return null;
  final button = builder(id, data);
  if (button == null) return null;
  return position.buildPositioned(
    child: button,
    horizontalOffset: horizontalOffset,
  );
}
