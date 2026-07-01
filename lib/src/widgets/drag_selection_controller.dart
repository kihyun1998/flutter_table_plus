import 'package:flutter/widgets.dart';

import 'row_locator.dart';

/// Owns the drag-to-select gesture state machine, decoupled from the widget.
///
/// It takes primitive coordinates (not [PointerEvent]s) so it can be driven
/// directly in unit tests without pumping a widget. The host widget's
/// `Listener` translates pointer events into [down] / [move] / [up] / [cancel]
/// calls; row resolution is delegated to a [RowLocator] port.
class DragSelectionController {
  DragSelectionController({
    required this.locator,
    required this.verticalOffset,
    required this.horizontalOffset,
    this.onUpdate,
    this.onEnd,
    this.activationThreshold = 8.0,
    this.edgeZone = 40.0,
    this.maxSpeedVertical = 10.0,
    this.maxSpeedHorizontal = 40.0,
  });

  /// Movement (in global pixels) required before a press becomes a drag.
  final double activationThreshold;

  /// Distance from a viewport edge within which auto-scroll engages.
  final double edgeZone;

  /// Per-tick vertical auto-scroll cap.
  final double maxSpeedVertical;

  /// Per-tick horizontal auto-scroll cap.
  final double maxSpeedHorizontal;

  /// Resolves coordinates to rows. A function so the host can hand over the
  /// body's current state each call without holding a stale reference.
  final RowLocator? Function() locator;

  /// Current vertical scroll offset (used by auto-scroll / rubber band).
  final double Function() verticalOffset;

  /// Current horizontal scroll offset (used by auto-scroll / rubber band).
  final double Function() horizontalOffset;

  /// Fires continuously as the selection range changes during a drag.
  final ValueChanged<Set<String>>? onUpdate;

  /// Fires once when the drag ends with a valid range.
  final ValueChanged<Set<String>>? onEnd;

  double _pointerDownGlobalY = 0;
  bool _isDragging = false;
  bool _startedFromEmpty = false;
  int? _startRenderIndex;
  int? _currentRenderIndex;

  // Viewport-local coordinate state for the rubber band + auto-scroll. All in
  // the body's viewport frame; horizontal scroll happens inside this frame, so
  // no conversion is needed after capture.
  Size _viewport = Size.zero;
  Offset? _downLocal;
  Offset? _currentLocal;
  double _startVerticalOffset = 0;
  double _startHorizontalOffset = 0;

  void down({
    required Offset local,
    required Offset global,
    required Size viewport,
  }) {
    _pointerDownGlobalY = global.dy;
    _viewport = viewport;
    _downLocal = local;
    _currentLocal = local;
    _startVerticalOffset = verticalOffset();
    _startHorizontalOffset = horizontalOffset();
    _startRenderIndex = locator()?.indexAt(local.dy);
    _startedFromEmpty = _startRenderIndex == null;
    _currentRenderIndex = null;
  }

  void move({required Offset local, required Offset global}) {
    if (!_isDragging) {
      if ((global.dy - _pointerDownGlobalY).abs() < activationThreshold) {
        _currentLocal = local;
        return;
      }
      _isDragging = true;
    }

    _currentLocal = local;

    final renderIdx = locator()?.indexAt(local.dy);
    // Lazy anchor: the first crossing into a real row sets the start.
    _startRenderIndex ??= renderIdx;

    if (_startRenderIndex == null) return;

    if (renderIdx != null) {
      _currentRenderIndex = renderIdx;
      _emit(onUpdate);
    } else if (_startedFromEmpty) {
      // Pointer-down began in the empty area below the data. Returning to
      // that area (absolute Y >= 0) releases the range; moving up into the
      // header (absolute Y < 0) preserves the sticky selection.
      final absoluteY = local.dy + verticalOffset();
      if (absoluteY >= 0) {
        _startRenderIndex = null;
        _currentRenderIndex = null;
        onUpdate?.call(<String>{});
      }
    }
  }

  void up() {
    if (_isDragging) _emit(onEnd);
    _reset();
  }

  void cancel() => _reset();

  /// Whether a drag has crossed the activation threshold and is live.
  bool get isDragging => _isDragging;

  /// Re-resolve the row under the (stationary) pointer after an auto-scroll has
  /// shifted the content beneath it, emitting an update only when the row
  /// actually changed. The host calls this each auto-scroll tick after moving
  /// the scroll offsets, since no pointer event fires during pure auto-scroll.
  void refresh() {
    final local = _currentLocal;
    if (local == null || !_isDragging || _startRenderIndex == null) return;
    final renderIdx = locator()?.indexAt(local.dy);
    if (renderIdx != null && renderIdx != _currentRenderIndex) {
      _currentRenderIndex = renderIdx;
      _emit(onUpdate);
    }
  }

  /// The rubber band rectangle in viewport-local coordinates, or `null` when
  /// no drag is active. The origin is content-anchored on both axes: as either
  /// scroll axis advances, the origin slides by the matching scroll delta so
  /// the rect stays pinned to the content cell where the drag began.
  Rect? rubberBandRect() {
    if (!_isDragging) return null;
    final down = _downLocal;
    final current = _currentLocal;
    if (down == null || current == null) return null;
    final vDelta = verticalOffset() - _startVerticalOffset;
    final hDelta = horizontalOffset() - _startHorizontalOffset;
    final origin = Offset(down.dx - hDelta, down.dy - vDelta);
    return Rect.fromPoints(origin, current);
  }

  /// The per-tick auto-scroll delta for one axis, given the pointer's
  /// viewport-local position on that axis. Negative pulls toward the leading
  /// edge, positive toward the trailing edge, `0` when outside both edge
  /// zones. [clampProximity] caps the proximity scalar at 1 so the speed never
  /// exceeds [maxSpeed]; leaving it false lets the pointer overshoot the edge
  /// and scroll faster than [maxSpeed] (the historical vertical behavior).
  static double axisScrollDelta({
    required double localPos,
    required double viewportExtent,
    required double edgeZone,
    required double maxSpeed,
    required bool clampProximity,
  }) {
    if (localPos < edgeZone) {
      var proximity = (edgeZone - localPos) / edgeZone;
      if (clampProximity) proximity = proximity.clamp(0.0, 1.0);
      return -maxSpeed * proximity;
    } else if (localPos > viewportExtent - edgeZone) {
      var proximity = (localPos - (viewportExtent - edgeZone)) / edgeZone;
      if (clampProximity) proximity = proximity.clamp(0.0, 1.0);
      return maxSpeed * proximity;
    }
    return 0;
  }

  /// The auto-scroll delta to apply this tick as an [Offset] (`dx` horizontal,
  /// `dy` vertical), computed from the last known pointer position and the
  /// viewport captured at [down]. [Offset.zero] means no auto-scroll.
  Offset autoScrollDelta() {
    final pos = _currentLocal;
    if (pos == null) return Offset.zero;
    final dy = axisScrollDelta(
      localPos: pos.dy,
      viewportExtent: _viewport.height,
      edgeZone: edgeZone,
      maxSpeed: maxSpeedVertical,
      clampProximity: false,
    );
    final dx = axisScrollDelta(
      localPos: pos.dx,
      viewportExtent: _viewport.width,
      edgeZone: edgeZone,
      maxSpeed: maxSpeedHorizontal,
      clampProximity: true,
    );
    return Offset(dx, dy);
  }

  void _emit(ValueChanged<Set<String>>? sink) {
    final start = _startRenderIndex;
    final current = _currentRenderIndex;
    if (start == null || current == null) return;
    final ids = locator()?.idsBetween(start, current);
    if (ids != null) sink?.call(ids);
  }

  void _reset() {
    _isDragging = false;
    _startedFromEmpty = false;
    _startRenderIndex = null;
    _currentRenderIndex = null;
    _pointerDownGlobalY = 0;
    _viewport = Size.zero;
    _downLocal = null;
    _currentLocal = null;
    _startVerticalOffset = 0;
    _startHorizontalOffset = 0;
  }
}
