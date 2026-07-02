/// Pure hit-test geometry for the rendered rows.
///
/// Given each render row's height and id (a row id, or a merged group id), this
/// resolves an absolute Y coordinate to a render index and collects the ids a
/// render-index range spans. It is the algorithm behind [TablePlusBodyState]'s
/// [RowLocator] port, lifted out of the widget so the coordinate math — the
/// part drag selection actually depends on — can be unit-tested without pumping
/// a table. The body resolves per-row heights/ids (uniform, dynamic, or merged
/// extents) and hands this object a pure snapshot.
class RowGeometry {
  RowGeometry({required List<double> heights, required List<String> ids})
      : assert(heights.length == ids.length),
        _heights = heights,
        _ids = ids;

  final List<double> _heights;
  final List<String> _ids;

  /// The number of rendered rows.
  int get renderRowCount => _heights.length;

  /// The render index at [absoluteY] (viewport-local Y plus the scroll offset),
  /// or `null` when the coordinate falls above the first row ([absoluteY] < 0)
  /// or below the last row. Callers rely on the `null` to keep drag selection
  /// sticky at the last valid row rather than snapping past it.
  int? indexAt(double absoluteY) {
    if (_heights.isEmpty || absoluteY < 0) return null;
    double cumulative = 0;
    for (int i = 0; i < _heights.length; i++) {
      cumulative += _heights[i];
      if (absoluteY < cumulative) return i;
    }
    return null;
  }

  /// The ids for the inclusive render-index range `[a, b]`, given in either
  /// order. Out-of-range endpoints are ignored.
  Set<String> idsBetween(int a, int b) {
    final lo = a < b ? a : b;
    final hi = a < b ? b : a;
    final result = <String>{};
    for (int i = lo; i <= hi; i++) {
      if (i < 0 || i >= _ids.length) continue;
      result.add(_ids[i]);
    }
    return result;
  }
}
