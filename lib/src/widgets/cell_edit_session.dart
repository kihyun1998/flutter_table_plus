import 'package:flutter/widgets.dart';

/// Encapsulates a single in-progress cell edit.
///
/// Bundles the five pieces that must move together — the edited row's id, its
/// current index, the column key, the original value, and the text controller —
/// so they can't drift apart. Keyed by [rowId]: when the table's data changes,
/// [repin] re-resolves the index (or reports the row is gone) instead of
/// leaving a stale index behind.
///
/// The controller outlives the "active" edit on purpose: [end] marks the edit
/// finished while keeping the controller alive, so the host can defer
/// [dispose] until the editing text field has rebuilt out of the tree (avoiding
/// use-after-dispose), matching the widget's original disposal timing.
class CellEditSession<T> {
  CellEditSession({
    required this.rowId,
    required this.columnKey,
    required this.originalValue,
    required int rowIndex,
  })  : _rowIndex = rowIndex,
        controller =
            TextEditingController(text: originalValue?.toString() ?? '');

  /// The id of the row being edited (stable across data reorders).
  final String rowId;

  /// The key of the column being edited.
  final String columnKey;

  /// The cell's value when editing began.
  final Object? originalValue;

  /// The editor's text controller.
  final TextEditingController controller;

  int _rowIndex;

  /// The row's current index in the data list (kept fresh via [repin]).
  int get rowIndex => _rowIndex;

  bool _active = true;

  /// Whether this is still the active edit (`false` after [end]).
  bool get isActive => _active;

  /// The text currently in the editor.
  String get currentText => controller.text;

  /// Whether the editor text differs from [originalValue].
  bool get isDirty => currentText != (originalValue?.toString() ?? '');

  /// Whether this session is the active edit for [rowIndex] / [columnKey].
  bool isEditing(int rowIndex, String columnKey) =>
      _active && _rowIndex == rowIndex && this.columnKey == columnKey;

  /// Marks the edit finished, keeping the controller for deferred disposal.
  void end() => _active = false;

  /// Re-pins to the edited row's new index after [data] changed, matching by
  /// [rowId]. Returns `false` when the row no longer exists (the caller should
  /// [dispose] and drop this session).
  bool repin(List<T> data, String Function(T) rowIdOf) {
    final newIndex = data.indexWhere((row) => rowIdOf(row) == rowId);
    if (newIndex == -1) return false;
    _rowIndex = newIndex;
    return true;
  }

  /// Disposes the text controller.
  void dispose() => controller.dispose();
}
