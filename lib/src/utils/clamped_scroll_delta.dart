/// The scroll delta actually applied after clamping the target to `[min, max]`.
///
/// Returns 0 when the resulting move is within [epsilon] — a no-op that the
/// auto-scroll engine treats as "can't move any further, stop". Pure extraction
/// of the resize handle's scroll arithmetic (the `position.jumpTo` side effect
/// stays with the caller).
double clampedScrollDelta({
  required double pixels,
  required double delta,
  required double min,
  required double max,
  double epsilon = 0.5,
}) {
  final newOffset = (pixels + delta).clamp(min, max);
  final actual = newOffset - pixels;
  return actual.abs() <= epsilon ? 0 : actual;
}
