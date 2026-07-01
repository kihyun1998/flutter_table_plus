import 'dart:async';

/// A single-axis edge-proximity auto-scroll engine.
///
/// Owns a periodic [Timer]; the host feeds it the pointer's position along the
/// axis via [update] and supplies a [scrollBy] callback that actually moves the
/// view. Extracted so both drag-selection and column-resize (which each grew
/// their own near-identical timer + edge-detection loop) can share one tested
/// implementation. Coordinate frame and any per-tick side effect are the host's
/// concern — this class only knows "how close to an edge, how fast to scroll".
class EdgeAutoScroller {
  EdgeAutoScroller({
    required this.edgeZone,
    required this.maxSpeed,
    required this.scrollBy,
    this.onScrolled,
    this.clampProximity = true,
    this.interval = const Duration(milliseconds: 16),
  });

  /// Distance from a viewport edge within which auto-scroll engages.
  final double edgeZone;

  /// Per-tick scroll cap at the very edge (before proximity scaling).
  final double maxSpeed;

  /// Applies a requested [delta] to the host's view, returning the amount it
  /// actually moved (0 at an extent). The engine stops when a tick moves 0.
  final double Function(double delta) scrollBy;

  /// Optional per-tick side effect, given the amount actually scrolled — e.g.
  /// column resize grows the dragged column by the same amount so the handle
  /// tracks the pointer.
  final void Function(double actualDelta)? onScrolled;

  /// Whether to cap the proximity scalar at 1 (speed never exceeds [maxSpeed]).
  /// `false` lets a pointer past the edge scroll faster than [maxSpeed].
  final bool clampProximity;

  /// The auto-scroll timer period.
  final Duration interval;

  Timer? _timer;
  double _axisPos = 0;
  double _viewportExtent = 0;

  /// The per-tick scroll delta for a pointer at [localPos] along an axis of
  /// size [viewportExtent]. Negative pulls toward the leading edge, positive
  /// toward the trailing edge, `0` when outside both edge zones.
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

  /// Feed the pointer's position along the axis and the viewport extent. Starts
  /// the timer when the pointer is in an edge zone, stops it otherwise.
  void update({required double axisPos, required double viewportExtent}) {
    _axisPos = axisPos;
    _viewportExtent = viewportExtent;
    if (_delta() != 0) {
      _start();
    } else {
      stop();
    }
  }

  double _delta() => axisScrollDelta(
        localPos: _axisPos,
        viewportExtent: _viewportExtent,
        edgeZone: edgeZone,
        maxSpeed: maxSpeed,
        clampProximity: clampProximity,
      );

  void _start() {
    if (_timer != null) return;
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  /// Cancels the timer without disposing (a later [update] can restart it).
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels the timer permanently. Call from the host's `dispose`.
  void dispose() => stop();

  void _tick() {
    final delta = _delta();
    if (delta == 0) {
      stop();
      return;
    }
    final actual = scrollBy(delta);
    if (actual == 0) {
      stop();
      return;
    }
    onScrolled?.call(actual);
  }
}
