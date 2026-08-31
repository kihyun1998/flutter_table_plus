import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/row_measurement.dart';
import 'package:flutter_test/flutter_test.dart';

// #137. `rowMeasurementChanged` compares the height callback with `==` rather
// than `identical`, and the difference is observable in exactly one shape: a
// tear-off of a `State` method. `identical` reports it as a new object on every
// build — in the JIT test VM, at least; under AOT it reports `true`, so a guard
// built on it behaves differently in the build users ship — and the body then
// drops its whole row-height cache and its drag geometry every build.
//
// The heights come back the same either way, so nothing on screen can observe
// this. What can is **how often the caller's callback is invoked**, which is why
// these tests count calls rather than assert pixels.

typedef Row = Map<String, dynamic>;

Map<String, TablePlusColumn<Row>> _columns() {
  final builder = TableColumnsBuilder<Row>();
  builder.addColumn(
    'c0',
    TablePlusColumn<Row>(
      key: 'c0',
      label: 'C0',
      order: 0,
      valueAccessor: (r) => r['c0'],
      width: 100,
    ),
  );
  return builder.build();
}

List<Row> _rows(int n) => List.generate(n, (i) => {'id': '$i', 'c0': 'r$i'});

/// Counts every call to the height callback the table is given.
int callCount = 0;

/// A host whose height callback is a **`State` method tear-off** — the shape
/// the two comparisons disagree about, and an ordinary way to write one.
class _TearOffHost extends StatefulWidget {
  const _TearOffHost({required this.data});
  final List<Row> data;
  @override
  State<_TearOffHost> createState() => _TearOffHostState();
}

class _TearOffHostState extends State<_TearOffHost> {
  double? _height(int index, Row row) {
    callCount++;
    return 40;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: FlutterTablePlus<Row>(
            columns: _columns(),
            data: widget.data,
            rowId: (r) => r['id'] as String,
            calculateRowHeight: _height,
            theme: const TablePlusTheme(
              bodyTheme: TablePlusBodyTheme(rowHeight: 40),
              headerTheme: TablePlusHeaderTheme(height: 40),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('rowMeasurementChanged compares by value', () {
    setUp(() => callCount = 0);

    testWidgets(
        'a State method tear-off is not treated as a new height function',
        (tester) async {
      final data = _rows(6);

      await tester.pumpWidget(const _TearOffHost(data: []));
      await tester.pumpWidget(_TearOffHost(data: data));
      await tester.pumpAndSettle();

      final afterFirst = callCount;
      expect(afterFirst, greaterThan(0),
          reason: 'the table never asked for a height, so this proves nothing');

      // A second pump with the same data list and the same State. Only the
      // tear-off's identity can differ, and it must not count as a change.
      await tester.pumpWidget(_TearOffHost(data: data));
      await tester.pumpAndSettle();

      expect(callCount, afterFirst,
          reason: 'the height cache was dropped and every row re-measured, '
              'because the callback was compared by identity rather than by '
              'value — a tear-off is equal to itself on the same receiver');
    });

    test('the predicate itself: a tear-off equals itself, across receivers not',
        () {
      final a = _Holder(1);
      final b = _Holder(2);

      expect(
        rowMeasurementChanged<Row>(
          oldCalculateRowHeight: a.height,
          newCalculateRowHeight: a.height,
          oldScale: 1,
          newScale: 1,
          oldRowHeight: 40,
          newRowHeight: 40,
        ),
        isFalse,
        reason: 'the same method on the same receiver is not a change',
      );

      expect(
        rowMeasurementChanged<Row>(
          oldCalculateRowHeight: a.height,
          newCalculateRowHeight: b.height,
          oldScale: 1,
          newScale: 1,
          oldRowHeight: 40,
          newRowHeight: 40,
        ),
        isTrue,
        reason: 'the same method on a *different* receiver is a real swap, and '
            'this is the case that has to keep working',
      );

      // The shape every ordinary call site writes. Two lambdas are never equal,
      // so this stays a change under either comparison — stated because it is
      // what makes the switch safe rather than merely cheaper.
      expect(
        rowMeasurementChanged<Row>(
          oldCalculateRowHeight: (i, r) => 40,
          newCalculateRowHeight: (i, r) => 40,
          oldScale: 1,
          newScale: 1,
          oldRowHeight: 40,
          newRowHeight: 40,
        ),
        isTrue,
        reason: 'two inline closures are distinct objects and unequal',
      );
    });
  });
}

class _Holder {
  _Holder(this.id);
  final int id;
  double? height(int index, Row row) => 40.0 + id;
}
