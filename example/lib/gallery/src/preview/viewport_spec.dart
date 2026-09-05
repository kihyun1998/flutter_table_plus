/// A viewport the preview stage can pretend to be.
///
/// The example runs on a desktop window, so every table it draws is a table
/// with room. The one layout behaviour a reader most needs to see before
/// adopting this package is what happens when there *isn't* room —
/// `flutter_table_plus` does not reflow, it clips and scrolls horizontally —
/// and that is the one thing a desktop-sized demo can never show.
library;

import 'package:flutter/widgets.dart';

/// One named viewport, and whether the shell around it keeps its furniture at
/// that width.
@immutable
class ViewportSpec {
  const ViewportSpec({
    required this.id,
    required this.label,
    required this.size,
    required this.showsChrome,
  });

  final String id;

  /// What the reader is told they are looking at, dimensions included. The
  /// numbers are part of the label on purpose: a frame that says only "mobile"
  /// invites the reader to supply their own idea of how wide that is.
  final String label;

  final Size size;

  /// Whether a shell hosting this viewport keeps its sidebar at this width.
  ///
  /// A policy of the *shell*, answered here because it is a fact about the
  /// width rather than about any particular shell — and because a shell that
  /// derives it from a raw pixel comparison spreads the same threshold across
  /// however many widgets ask.
  final bool showsChrome;

  double get width => size.width;
  double get height => size.height;

  /// Desktop, tablet, mobile — in that order, because the reader starts from
  /// the width they are already looking at.
  static const values = [desktop, tablet, mobile];

  static const desktop = ViewportSpec(
    id: 'desktop',
    label: 'Desktop · 1440 × 900',
    size: Size(1440, 900),
    showsChrome: true,
  );

  static const tablet = ViewportSpec(
    id: 'tablet',
    label: 'Tablet · 834 × 1112',
    size: Size(834, 1112),
    showsChrome: true,
  );

  static const mobile = ViewportSpec(
    id: 'mobile',
    label: 'Mobile · 390 × 844',
    size: Size(390, 844),
    showsChrome: false,
  );

  static ViewportSpec byId(String id) =>
      values.firstWhere((v) => v.id == id, orElse: () {
        throw ArgumentError.value(id, 'id', 'no viewport with this id');
      });

  @override
  bool operator ==(Object other) =>
      other is ViewportSpec &&
      other.id == id &&
      other.label == label &&
      other.size == size &&
      other.showsChrome == showsChrome;

  @override
  int get hashCode => Object.hash(id, label, size, showsChrome);

  @override
  String toString() => 'ViewportSpec($id, ${size.width}×${size.height})';
}
