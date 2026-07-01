import 'package:flutter/material.dart';

import 'custom_ink_well.dart';

/// The shared interaction wrapper around a row's content.
///
/// Both normal and merged rows built the same three-layer shell — a [Stack]
/// (content + optional hover overlay), a [MouseRegion] for hover detection,
/// and, when the row is selectable and not editing, a [CustomInkWell] for tap
/// selection. This widget owns that structure; the row supplies the already
/// built [rowContent]/[hoverButtons] and its id-specific callbacks.
class RowInteractionShell extends StatelessWidget {
  const RowInteractionShell({
    super.key,
    required this.rowContent,
    required this.hoverButtons,
    required this.onHoverChanged,
    required this.enableSelectionInk,
    required this.inkKey,
    required this.onTap,
    required this.onDoubleTap,
    required this.onSecondaryTapDown,
    required this.doubleClickTime,
    required this.backgroundColor,
    required this.hoverColor,
    required this.splashColor,
    required this.highlightColor,
  });

  /// The row's built content (cells).
  final Widget rowContent;

  /// The positioned hover-button overlay, or null when none.
  final Widget? hoverButtons;

  /// Called with the hover state as the pointer enters/exits the row.
  final ValueChanged<bool> onHoverChanged;

  /// Whether to wrap the row in a [CustomInkWell] for tap selection.
  final bool enableSelectionInk;

  /// Key applied to the [CustomInkWell] (typically a ValueKey of the row id).
  final Key inkKey;

  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final void Function(TapDownDetails details, RenderBox renderBox)?
      onSecondaryTapDown;
  final Duration doubleClickTime;
  final Color backgroundColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final hovered = MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: Stack(
        children: [
          rowContent,
          if (hoverButtons != null) hoverButtons!,
        ],
      ),
    );

    if (!enableSelectionInk) return hovered;

    return CustomInkWell(
      key: inkKey,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapDown: onSecondaryTapDown,
      doubleClickTime: doubleClickTime,
      backgroundColor: backgroundColor,
      hoverColor: hoverColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: hovered,
    );
  }
}
