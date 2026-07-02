import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/sort_cycle.dart';
import 'package:flutter_test/flutter_test.dart';

// Full truth table for the sort-cycle FSM.

SortDirection next(
  SortDirection current, {
  String tapped = 'a',
  String? sorted = 'a',
  required SortCycleOrder cycle,
}) {
  return nextSortDirection(
    current: current,
    tappedKey: tapped,
    sortedKey: sorted,
    cycle: cycle,
  );
}

void main() {
  group('same column, ascendingFirst (none -> asc -> desc -> none)', () {
    const c = SortCycleOrder.ascendingFirst;
    test(
        'none -> ascending',
        () => expect(
            next(SortDirection.none, cycle: c), SortDirection.ascending));
    test(
        'ascending -> descending',
        () => expect(
            next(SortDirection.ascending, cycle: c), SortDirection.descending));
    test(
        'descending -> none',
        () => expect(
            next(SortDirection.descending, cycle: c), SortDirection.none));
  });

  group('same column, descendingFirst (none -> desc -> asc -> none)', () {
    const c = SortCycleOrder.descendingFirst;
    test(
        'none -> descending',
        () => expect(
            next(SortDirection.none, cycle: c), SortDirection.descending));
    test(
        'descending -> ascending',
        () => expect(
            next(SortDirection.descending, cycle: c), SortDirection.ascending));
    test(
        'ascending -> none',
        () => expect(
            next(SortDirection.ascending, cycle: c), SortDirection.none));
  });

  group('a different column ignores current direction and starts fresh', () {
    test('ascendingFirst starts ascending', () {
      expect(
        next(SortDirection.descending,
            tapped: 'b', sorted: 'a', cycle: SortCycleOrder.ascendingFirst),
        SortDirection.ascending,
      );
    });

    test('descendingFirst starts descending', () {
      expect(
        next(SortDirection.ascending,
            tapped: 'b', sorted: 'a', cycle: SortCycleOrder.descendingFirst),
        SortDirection.descending,
      );
    });

    test('nothing sorted yet (null key) starts the cycle', () {
      expect(
        next(SortDirection.none,
            tapped: 'a', sorted: null, cycle: SortCycleOrder.ascendingFirst),
        SortDirection.ascending,
      );
    });
  });
}
