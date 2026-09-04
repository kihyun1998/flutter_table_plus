import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/row_cache_invalidation.dart';
import 'package:flutter_test/flutter_test.dart';

// #169. Two widgets cache row-derived state and both must answer "what did this
// update invalidate?" the same way. The *inputs* to the measurement half were
// unified at #120/#128; the *response* stayed copied in two places and drifted
// — the body split structural from measurement-only and the parent did not, so
// a `scale` change threw away a `RowLookup` no scale can move.
//
// This is the classifier's own test, and it is the only thing here that can go
// red. The improvement is invisible by construction: every behavioural
// assertion in the suite passes with the lookup rebuilt or kept, so the rest of
// the suite is a regression guard, not a proof. Measured before writing this —
// a scale change at n = 1,000 is ~5.5ms of which the lookup rebuild is 50µs, so
// a benchmark cannot see it either.
//
// Two cases carry more than they look:
//
//   * `structural dominates` — a build can move the snapshot AND the
//     measurement at once. An implementation that returns measurementOnly as
//     soon as the measurement fires is wrong exactly there, and every other
//     case here still passes for it.
//   * `idsStillMatch is not consulted…` — the walk is O(rows) and the two
//     `identical` checks are free. This is the only assertion that holds the
//     ordering, and nothing about the return value can express it.

typedef Row = Map<String, dynamic>;

List<Row> _rows(int n) => [
      for (int i = 0; i < n; i++) {'id': 'r$i'},
    ];

/// Every argument at its unchanged value, so each case can move exactly one.
RowCacheInvalidation _classify({
  List<Row>? oldData,
  List<Row>? newData,
  List<MergedRowGroup<Row>>? oldGroups,
  List<MergedRowGroup<Row>>? newGroups,
  double? Function(int, Row)? oldHeightFn,
  double? Function(int, Row)? newHeightFn,
  double oldScale = 1.0,
  double newScale = 1.0,
  double oldRowHeight = 40,
  double newRowHeight = 40,
  bool idsMatch = true,
  void Function()? onIdsChecked,
}) {
  final data = oldData ?? _sharedData;
  final groups = oldGroups ?? _sharedGroups;
  return classifyRowCacheInvalidation<Row>(
    oldData: data,
    newData: newData ?? data,
    oldMergedGroups: groups,
    newMergedGroups: newGroups ?? groups,
    oldCalculateRowHeight: oldHeightFn,
    newCalculateRowHeight: newHeightFn ?? oldHeightFn,
    oldScale: oldScale,
    newScale: newScale,
    oldRowHeight: oldRowHeight,
    newRowHeight: newRowHeight,
    idsStillMatch: () {
      onIdsChecked?.call();
      return idsMatch;
    },
  );
}

final List<Row> _sharedData = _rows(3);
final List<MergedRowGroup<Row>> _sharedGroups = <MergedRowGroup<Row>>[];

double? _heightA(int i, Row r) => 40;
double? _heightB(int i, Row r) => 80;

void main() {
  group('classifyRowCacheInvalidation — structural', () {
    test('a new data list', () {
      expect(_classify(newData: _rows(3)), RowCacheInvalidation.structural);
    });

    test('a new mergedGroups list', () {
      expect(_classify(newGroups: <MergedRowGroup<Row>>[]),
          RowCacheInvalidation.structural);
    });

    test('the ids no longer match, with nothing else changed', () {
      // A list sorted or shrunk in place, or a swapped rowId: `data` keeps its
      // identity and the snapshot has still moved (#135).
      expect(_classify(idsMatch: false), RowCacheInvalidation.structural);
    });

    test('structural dominates: the ids moved AND the measurement moved', () {
      // The case an implementation that short-circuits on the measurement gets
      // wrong, and the only case here that can tell the two apart.
      expect(
        _classify(idsMatch: false, oldScale: 1.0, newScale: 2.0),
        RowCacheInvalidation.structural,
      );
    });
  });

  group('classifyRowCacheInvalidation — measurementOnly', () {
    test('scale', () {
      expect(_classify(oldScale: 1.0, newScale: 1.5),
          RowCacheInvalidation.measurementOnly);
    });

    test('theme row height', () {
      expect(_classify(oldRowHeight: 40, newRowHeight: 56),
          RowCacheInvalidation.measurementOnly);
    });

    test('the height callback', () {
      expect(_classify(oldHeightFn: _heightA, newHeightFn: _heightB),
          RowCacheInvalidation.measurementOnly);
    });
  });

  group('classifyRowCacheInvalidation — none', () {
    test('every input equal', () {
      expect(_classify(), RowCacheInvalidation.none);
    });

    test('the same height tear-off twice is not a change', () {
      // `==`, not `identical`: a tear-off of the same function compares equal,
      // which is what makes `calculateRowHeight` watchable at all (#137).
      expect(_classify(oldHeightFn: _heightA, newHeightFn: _heightA),
          RowCacheInvalidation.none);
    });
  });

  group('ordering', () {
    test('idsStillMatch is not consulted when the snapshot visibly moved', () {
      // O(rows) against two free `identical` checks. Nothing in the return
      // value can express this, so it is asserted directly.
      int checks = 0;
      _classify(newData: _rows(3), onIdsChecked: () => checks++);
      expect(checks, 0, reason: 'a new data list settles it for free');

      checks = 0;
      _classify(
          newGroups: <MergedRowGroup<Row>>[], onIdsChecked: () => checks++);
      expect(checks, 0, reason: 'a new mergedGroups list settles it for free');
    });

    test('idsStillMatch is consulted exactly once when it is needed', () {
      int checks = 0;
      _classify(oldScale: 1.0, newScale: 2.0, onIdsChecked: () => checks++);
      expect(checks, 1,
          reason: 'the measurement moved, so structural must still be ruled '
              'out — and the walk may not be paid twice');

      checks = 0;
      _classify(onIdsChecked: () => checks++);
      expect(checks, 1, reason: 'nothing moved, and #135 still has to be seen');
    });
  });
}
