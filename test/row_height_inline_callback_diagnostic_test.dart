import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// #161. `calculateRowHeight` is compared with `==`, so a closure built fresh in
// the caller's `build` is never equal to the last one and both height caches
// drop every frame -- 62ms per rebuild at a thousand rows with a text-measuring
// height function. No mechanism removes that cost (shapes (1) and (3) were
// refuted by measurement, and (2) by the probe recorded on the issue), so the
// repair is to make the slow path say so once, in debug.
//
// **Case 2 is the control and it is the whole test.** A diagnostic that fires
// on a stable receiver would be worthless, and one that only ever fires is
// indistinguishable from a `debugPrint` with no condition at all. So every case
// here drives the same number of rebuilds through the same harness and differs
// in exactly one term:
//
//   1  inline closure, data and columns held   -> speaks, once
//   2  static tear-off, everything else equal  -> silent  (the receiver term)
//   3  inline closure, columns rebuilt too     -> silent  (the resize-drag term)
//
// Case 3 is not hypothetical: a caller who stores the width `onColumnResized`
// hands back and passes new columns down rebuilds their height callback on
// every frame of a resize drag, which runs far past any threshold. The
// threshold is not what excludes it -- the `columns` identity term is -- and
// case 3 is the only thing that can tell those two apart.

typedef Row = Map<String, dynamic>;

/// Held in a top-level final on purpose: the harness must vary one term per
/// case, so everything else has to be genuinely stable across rebuilds.
final List<Row> _data = [
  for (int i = 0; i < 6; i++) {'id': 'r$i', 'c0': 'row $i'},
];

Map<String, TablePlusColumn<Row>> _buildColumns() {
  final b = TableColumnsBuilder<Row>();
  b.addColumn(
    'c0',
    TablePlusColumn<Row>(
      key: 'c0',
      label: 'C0',
      order: 0,
      valueAccessor: (r) => r['c0'],
      width: 200,
    ),
  );
  return b.build();
}

final Map<String, TablePlusColumn<Row>> _stableColumns = _buildColumns();

/// A top-level tear-off: `==`-stable across builds, which is the fast path the
/// documentation asks for and case 2's whole point.
double? _staticHeight(int index, Row row) => 40.0;

/// Rebuild the table [times] times through the same element, so every rebuild
/// after the first is a `didUpdateWidget` on one live state.
Future<void> _pumpRebuilds(
  WidgetTester tester,
  int times, {
  required bool inlineCallback,
  required bool rebuildColumns,
}) async {
  tester.view.physicalSize = const Size(800, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  for (int i = 0; i < times; i++) {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: FlutterTablePlus<Row>(
              columns: rebuildColumns ? _buildColumns() : _stableColumns,
              data: _data,
              rowId: (r) => r['id'] as String,
              calculateRowHeight:
                  inlineCallback ? (int index, Row row) => 40.0 : _staticHeight,
              theme: const TablePlusTheme(
                bodyTheme: TablePlusBodyTheme(rowHeight: 40),
                headerTheme: TablePlusHeaderTheme(height: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Run [body] with `debugPrint` captured, and hand back only this diagnostic's
/// lines.
///
/// The restore happens inside the test body rather than in a `tearDown`,
/// deliberately: `_verifyInvariants` checks that every foundation debug variable
/// is back to its default at the end of the body, which is *before* any tearDown
/// runs. Leaving it to a tearDown fails all three cases with a framework
/// assertion instead of an assertion of theirs.
///
/// The filter matters too. `_validateColumns` and `_validateUniqueIds` print
/// through this same channel, so asserting on the whole buffer could pass for a
/// reason that has nothing to do with row heights.
Future<List<String>> _warningsWhile(Future<void> Function() body) async {
  final printed = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) printed.add(message);
  };
  try {
    await body();
  } finally {
    debugPrint = original;
  }
  return printed.where((m) => m.contains('calculateRowHeight')).toList();
}

void main() {
  group('inline calculateRowHeight diagnostic (#161)', () {
    testWidgets('speaks once when the callback is the only thing rebuilt',
        (tester) async {
      final warnings = await _warningsWhile(() => _pumpRebuilds(tester, 12,
          inlineCallback: true, rebuildColumns: false));

      // Once, not twelve times: the condition holds on every build after the
      // threshold, so "fires" and "floods" are different claims and this
      // asserts the narrower one.
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('built inline in build()'));
      expect(warnings.single, contains('createHeightCalculator'));
    });

    testWidgets('stays silent for a stable receiver', (tester) async {
      final warnings = await _warningsWhile(() => _pumpRebuilds(tester, 12,
          inlineCallback: false, rebuildColumns: false));

      expect(warnings, isEmpty);
    });

    testWidgets('stays silent while the columns are rebuilt too',
        (tester) async {
      final warnings = await _warningsWhile(() => _pumpRebuilds(tester, 12,
          inlineCallback: true, rebuildColumns: true));

      expect(warnings, isEmpty);
    });
  });
}
