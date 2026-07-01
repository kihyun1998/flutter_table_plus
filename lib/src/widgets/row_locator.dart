/// A narrow port that resolves viewport-local coordinates to renderable rows.
///
/// Drag selection needs two facts from the body without knowing *how* the
/// body lays rows out (uniform heights, dynamic heights, or merged groups):
///
/// 1. which render index sits under a given viewport-local Y, and
/// 2. which row/group IDs fall inside an inclusive render-index range.
///
/// [TablePlusBodyState] implements this; tests provide a fake. The controller
/// depends only on this interface, so the body's caching strategy can change
/// freely behind it.
abstract class RowLocator {
  /// The render index at [localY] (viewport-local, offset handled internally),
  /// or `null` when the position falls outside any rendered row.
  int? indexAt(double localY);

  /// The row IDs (or merged group IDs) for the inclusive render-index range
  /// `[startRenderIndex, endRenderIndex]`, in either order.
  Set<String> idsBetween(int startRenderIndex, int endRenderIndex);
}
