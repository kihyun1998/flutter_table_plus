import 'package:flutter_table_plus/src/widgets/cell_edit_session.dart';
import 'package:flutter_test/flutter_test.dart';

CellEditSession<Map<String, dynamic>> _session({
  int rowIndex = 1,
  Object? original = 'Bravo',
}) {
  return CellEditSession<Map<String, dynamic>>(
    rowId: 'b',
    columnKey: 'name',
    originalValue: original,
    rowIndex: rowIndex,
  );
}

String _idOf(Map<String, dynamic> r) => r['id'] as String;

void main() {
  group('CellEditSession', () {
    test('starts with the original value in its controller and is clean', () {
      final s = _session(original: 'Bravo');
      expect(s.controller.text, 'Bravo');
      expect(s.isDirty, isFalse);
      s.dispose();
    });

    test('a null original value yields an empty controller', () {
      final s = _session(original: null);
      expect(s.controller.text, '');
      s.dispose();
    });

    test('becomes dirty once the text differs from the original', () {
      final s = _session(original: 'Bravo');
      s.controller.text = 'Edited';
      expect(s.isDirty, isTrue);
      expect(s.currentText, 'Edited');
      s.dispose();
    });

    test('repin follows the row to its new index by id', () {
      final s = _session(rowIndex: 1);
      final moved = [
        {'id': 'a'},
        {'id': 'c'},
        {'id': 'b'}, // 'b' now at index 2
      ];
      expect(s.repin(moved, _idOf), isTrue);
      expect(s.rowIndex, 2);
      s.dispose();
    });

    test('repin returns false when the row no longer exists', () {
      final s = _session(rowIndex: 1);
      final removed = [
        {'id': 'a'},
        {'id': 'c'},
      ];
      expect(s.repin(removed, _idOf), isFalse);
      s.dispose();
    });

    test('isEditing tracks index, column key, and active state', () {
      final s = _session(rowIndex: 1);
      expect(s.isEditing(1, 'name'), isTrue);
      expect(s.isEditing(2, 'name'), isFalse);
      expect(s.isEditing(1, 'other'), isFalse);

      s.end();
      expect(s.isActive, isFalse);
      expect(s.isEditing(1, 'name'), isFalse,
          reason: 'an ended session is no longer the active edit');
      s.dispose();
    });
  });
}
