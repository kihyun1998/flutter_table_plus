import 'dart:async';

import 'package:flutter/material.dart';

/// A custom [InkWell] widget that provides enhanced tap, double-tap, and secondary-tap
/// functionalities without delaying single taps when double-tap is enabled.
class CustomInkWell extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// Called when the user taps this [CustomInkWell].
  final VoidCallback? onTap;

  /// Called when the user double-taps this [CustomInkWell].
  final VoidCallback? onDoubleTap;

  /// Called when the user performs a secondary tap (e.g., right-click on desktop)
  /// on this [CustomInkWell].
  final VoidCallback? onSecondaryTap;

  /// The maximum duration between two taps for them to be considered a double-tap.
  /// Defaults to 300 milliseconds.
  final Duration doubleClickTime;

  /// The color of the ink splash when the [CustomInkWell] is tapped.
  final Color? splashColor;

  /// The highlight color of the [CustomInkWell] when it's pressed.
  final Color? highlightColor;

  /// The border radius of the ink splash and highlight.
  final BorderRadius? borderRadius;

  /// Creates a [CustomInkWell] instance.
  const CustomInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.doubleClickTime = const Duration(milliseconds: 300),
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
  });

  @override
  State<CustomInkWell> createState() => _CustomInkWellState();
}

class _CustomInkWellState extends State<CustomInkWell> {
  int _clickCount = 0;
  Timer? _timer;

  void _handleTap() {
    _clickCount++;

    if (_clickCount == 1) {
      // 첫 번째 클릭 - 즉시 처리 (지연 없음!)
      widget.onTap?.call();

      if (widget.onDoubleTap != null) {
        // 더블클릭 콜백이 있으면 타이머 시작
        _timer = Timer(widget.doubleClickTime, () {
          _clickCount = 0;
        });
      } else {
        _clickCount = 0;
      }
    } else if (_clickCount == 2) {
      // 두 번째 클릭 - 더블클릭 처리
      _timer?.cancel();
      widget.onDoubleTap?.call();
      _clickCount = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTap: widget.onSecondaryTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (widget.onTap != null || widget.onDoubleTap != null)
              ? _handleTap
              : null,
          splashColor: widget.splashColor,
          highlightColor: widget.highlightColor,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}
