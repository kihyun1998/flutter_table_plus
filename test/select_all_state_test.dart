import 'package:flutter_table_plus/src/utils/select_all_state.dart';
import 'package:flutter_test/flutter_test.dart';

// The select-all checkbox is false / true / null (indeterminate).

void main() {
  group('selectAllState', () {
    test('no rows at all -> false', () {
      expect(selectAllState(total: 0, selectedCount: 0), isFalse);
    });

    test('rows exist but none selected -> false', () {
      expect(selectAllState(total: 3, selectedCount: 0), isFalse);
    });

    test('every row selected -> true', () {
      expect(selectAllState(total: 3, selectedCount: 3), isTrue);
    });

    test('some but not all selected -> null (indeterminate)', () {
      expect(selectAllState(total: 3, selectedCount: 1), isNull);
      expect(selectAllState(total: 3, selectedCount: 2), isNull);
    });

    test('no rows short-circuits even if a stale count is passed', () {
      expect(selectAllState(total: 0, selectedCount: 5), isFalse);
    });
  });
}
