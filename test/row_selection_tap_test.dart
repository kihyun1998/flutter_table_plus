import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/widgets/table_plus_row_widget.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal concrete [TablePlusRowWidget] exposing only the selection-tap
/// inputs, so the shared gating logic can be exercised without pumping a row.
class _TestRow extends TablePlusRowWidget {
  const _TestRow({
    required this.isEditable,
    required this.isSelectable,
    required this.selectionId,
    required this.onRowSelectionChanged,
  });

  @override
  final bool isEditable;
  @override
  final bool isSelectable;
  @override
  final String? selectionId;
  @override
  final void Function(String id) onRowSelectionChanged;

  @override
  int get effectiveRowCount => 1;
  @override
  List<int> get originalDataIndices => const [0];
  @override
  double? get calculatedHeight => null;
  @override
  bool get isLastRow => false;
  @override
  Color get backgroundColor => const Color(0xFF000000);

  @override
  State<_TestRow> createState() => _TestRowState();
}

class _TestRowState extends State<_TestRow> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  group('TablePlusRowWidget.handleSelectionTap', () {
    test('toggles selection when selectable, not editable, and id present', () {
      final calls = <String>[];
      _TestRow(
        isEditable: false,
        isSelectable: true,
        selectionId: 'r1',
        onRowSelectionChanged: calls.add,
      ).handleSelectionTap();
      expect(calls, ['r1']);
    });

    test('does nothing in editable mode', () {
      final calls = <String>[];
      _TestRow(
        isEditable: true,
        isSelectable: true,
        selectionId: 'r1',
        onRowSelectionChanged: calls.add,
      ).handleSelectionTap();
      expect(calls, isEmpty);
    });

    test('does nothing when not selectable', () {
      final calls = <String>[];
      _TestRow(
        isEditable: false,
        isSelectable: false,
        selectionId: 'r1',
        onRowSelectionChanged: calls.add,
      ).handleSelectionTap();
      expect(calls, isEmpty);
    });

    test('does nothing when the selection id is null', () {
      final calls = <String>[];
      _TestRow(
        isEditable: false,
        isSelectable: true,
        selectionId: null,
        onRowSelectionChanged: calls.add,
      ).handleSelectionTap();
      expect(calls, isEmpty);
    });
  });
}
