import 'package:flutter/material.dart';

import '../utils/clamped_scroll_delta.dart';
import 'edge_auto_scroller.dart';

/// An overlay resize handle widget centered on a column boundary.
///
/// Positioned by the parent [Stack] at each column's right edge.
/// On hover, a centered indicator line appears. Horizontal drag gestures
/// resize the column in real-time with auto-scroll support.
class ResizeHandle extends StatefulWidget {
  const ResizeHandle({
    super.key,
    required this.columnKey,
    required this.columnWidth,
    required this.minWidth,
    required this.handleColor,
    this.handleThickness = 2.0,
    this.handleIndent = 0.0,
    this.handleEndIndent = 0.0,
    this.maxWidth,
    this.onResize,
    this.onResizeEnd,
    this.onDoubleTap,
  });

  final String columnKey;
  final double columnWidth;
  final double minWidth;
  final double? maxWidth;
  final Color handleColor;
  final double handleThickness;
  final double handleIndent;
  final double handleEndIndent;
  final void Function(String columnKey, double newWidth)? onResize;
  final void Function(String columnKey, double finalWidth)? onResizeEnd;
  final VoidCallback? onDoubleTap;

  @override
  State<ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle> {
  bool _isHovering = false;
  bool _isDragging = false;
  double _dragWidth = 0;

  // Auto-scroll during a resize drag, delegated to the shared engine. Created
  // on drag start, disposed on drag end/cancel.
  EdgeAutoScroller? _autoScroller;
  ScrollableState? _scrollable;

  /// Distance in pixels from the viewport edge where auto-scroll activates.
  static const double _autoScrollEdgeZone = 50.0;

  /// Maximum scroll speed in pixels per tick at the very edge.
  static const double _autoScrollMaxSpeed = 8.0;

  @override
  void dispose() {
    _autoScroller?.dispose();
    super.dispose();
  }

  /// Applies a scroll [delta] to the resize viewport, clamped to its extents.
  /// Returns the amount actually moved, or 0 when it would move <= 0.5px
  /// (preserving the original no-op threshold), which stops the engine.
  double _applyResizeScroll(double delta) {
    final position = _scrollable?.position;
    if (position == null) return 0;
    final actual = clampedScrollDelta(
      pixels: position.pixels,
      delta: delta,
      min: position.minScrollExtent,
      max: position.maxScrollExtent,
    );
    if (actual != 0) position.jumpTo(position.pixels + actual);
    return actual;
  }

  /// Grows the dragged column by the scrolled amount so the handle keeps
  /// tracking the pointer during auto-scroll.
  void _onResizeScrolled(double actualDelta) {
    _dragWidth += actualDelta;
    final clamped = _dragWidth.clamp(
      widget.minWidth,
      widget.maxWidth ?? double.infinity,
    );
    widget.onResize?.call(widget.columnKey, clamped);
  }

  /// Feed the pointer's viewport-relative X into the auto-scroll engine.
  void _updateAutoScroll(Offset globalPosition) {
    final scrollable = _scrollable;
    final scroller = _autoScroller;
    if (scrollable == null || scroller == null) return;

    final renderBox = scrollable.context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final viewportLeft = renderBox.localToGlobal(Offset.zero).dx;
    scroller.update(
      axisPos: globalPosition.dx - viewportLeft,
      viewportExtent: renderBox.size.width,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: widget.onDoubleTap,
        onHorizontalDragStart: (details) {
          _scrollable = Scrollable.maybeOf(context);
          _autoScroller = EdgeAutoScroller(
            edgeZone: _autoScrollEdgeZone,
            maxSpeed: _autoScrollMaxSpeed,
            scrollBy: _applyResizeScroll,
            onScrolled: _onResizeScrolled,
          );
          setState(() {
            _isDragging = true;
            _dragWidth = widget.columnWidth;
          });
        },
        onHorizontalDragUpdate: (details) {
          _dragWidth += details.delta.dx;
          final clamped = _dragWidth.clamp(
            widget.minWidth,
            widget.maxWidth ?? double.infinity,
          );
          widget.onResize?.call(widget.columnKey, clamped);
          _updateAutoScroll(details.globalPosition);
        },
        onHorizontalDragEnd: (details) {
          _autoScroller?.dispose();
          _autoScroller = null;
          _scrollable = null;
          final clamped = _dragWidth.clamp(
            widget.minWidth,
            widget.maxWidth ?? double.infinity,
          );
          setState(() => _isDragging = false);
          widget.onResizeEnd?.call(widget.columnKey, clamped);
        },
        onHorizontalDragCancel: () {
          _autoScroller?.dispose();
          _autoScroller = null;
          _scrollable = null;
          setState(() => _isDragging = false);
        },
        child: (_isHovering || _isDragging)
            ? Padding(
                padding: EdgeInsets.only(
                  top: widget.handleIndent,
                  bottom: widget.handleEndIndent,
                ),
                child: Center(
                  child: SizedBox(
                    width: widget.handleThickness,
                    height: double.infinity,
                    child: ColoredBox(color: widget.handleColor),
                  ),
                ),
              )
            : const SizedBox.expand(),
      ),
    );
  }
}
