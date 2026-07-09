import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/table_plus_row_widget.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal concrete [TablePlusRowWidget] exposing only the selection-tap
/// inputs, so the shared gating logic can be exercised without pumping a row.
/// The build-only getters are inert stubs — this double's state never renders
/// through [TablePlusRowStateBase].
class _TestRow extends TablePlusRowWidget<Object> {
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

  // Inert build-only stubs (never exercised by these unit tests).
  @override
  TablePlusBodyTheme get theme => const TablePlusBodyTheme();
  @override
  bool get isSelected => false;
  @override
  bool get isDim => false;
  @override
  Widget? Function(String, Object)? get hoverButtonBuilder => null;
  @override
  HoverButtonPosition get hoverButtonPosition => HoverButtonPosition.right;
  @override
  TablePlusHoverButtonTheme? get hoverButtonTheme => null;
  @override
  void Function(String)? get onRowDoubleTap => null;
  @override
  void Function(String, TapDownDetails, RenderBox, bool)?
      get onRowSecondaryTapDown => null;

  @override
  State<_TestRow> createState() => _TestRowState();
}

class _TestRowState extends State<_TestRow> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  group('TablePlusRowWidget.handleSelectionTap', () {
    test('toggles selection when selectable and id present', () {
      final calls = <String>[];
      _TestRow(
        isEditable: false,
        isSelectable: true,
        selectionId: 'r1',
        onRowSelectionChanged: calls.add,
      ).handleSelectionTap();
      expect(calls, ['r1']);
    });

    test('still toggles selection in editable mode', () {
      final calls = <String>[];
      _TestRow(
        isEditable: true,
        isSelectable: true,
        selectionId: 'r1',
        onRowSelectionChanged: calls.add,
      ).handleSelectionTap();
      expect(calls, ['r1']);
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

  group('TablePlusRowWidget.enableSelectionInk', () {
    _TestRow row({
      required bool isEditable,
      required bool isSelectable,
      required String? selectionId,
    }) {
      return _TestRow(
        isEditable: isEditable,
        isSelectable: isSelectable,
        selectionId: selectionId,
        onRowSelectionChanged: (_) {},
      );
    }

    test('true only when selectable and id present', () {
      expect(
        row(isEditable: false, isSelectable: true, selectionId: 'r')
            .enableSelectionInk,
        isTrue,
      );
    });

    test('still true while editing', () {
      expect(
        row(isEditable: true, isSelectable: true, selectionId: 'r')
            .enableSelectionInk,
        isTrue,
      );
    });

    test('false when not selectable', () {
      expect(
        row(isEditable: false, isSelectable: false, selectionId: 'r')
            .enableSelectionInk,
        isFalse,
      );
    });

    test('false when the id is null', () {
      expect(
        row(isEditable: false, isSelectable: true, selectionId: null)
            .enableSelectionInk,
        isFalse,
      );
    });
  });
}
