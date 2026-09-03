import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// #160. `TablePlusHeaderTheme.decoration` is a public field applied to the box
// that wraps the whole header, and the body below has no equivalent box. A
// `Container` folds a border's `dimensions` into its child's inset, so a caller
// setting a border there slid every header column against its body column by
// the left border's width — silently, with no exception and no overflow banner.
//
// The assertion is the conjunction the package's identity actually promises:
// header column N starts where body column N starts. Not the box's own size,
// which nothing promises.

Widget _table({Decoration? decoration, double viewport = 500}) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: viewport,
          child: FlutterTablePlus<Map<String, dynamic>>(
            columns: {
              'a': TablePlusColumn<Map<String, dynamic>>(
                  key: 'a',
                  label: 'AAA',
                  order: 0,
                  valueAccessor: (r) => r['a'],
                  width: 300,
                  minWidth: 300,
                  maxWidth: 300),
              'b': TablePlusColumn<Map<String, dynamic>>(
                  key: 'b',
                  label: 'BBB',
                  order: 1,
                  valueAccessor: (r) => r['b'],
                  width: 300,
                  minWidth: 300,
                  maxWidth: 300),
            },
            data: const [
              {'id': '1', 'a': 'a1', 'b': 'b1'}
            ],
            rowId: (r) => r['id'] as String,
            theme: TablePlusTheme(
                headerTheme: TablePlusHeaderTheme(decoration: decoration)),
          ),
        ),
      ),
    );

double _desync(WidgetTester tester) =>
    tester.getRect(find.text('BBB')).left -
    tester.getRect(find.text('b1')).left;

void main() {
  testWidgets('a caller decoration with a border does not slide the header',
      (tester) async {
    // Control first: without a decoration there is nothing to inset, so this
    // says the fixture can tell aligned from misaligned rather than always
    // reading zero.
    await tester.pumpWidget(_table());
    await tester.pumpAndSettle();
    expect(_desync(tester), 0.0);

    await tester.pumpWidget(
        _table(decoration: BoxDecoration(border: Border.all(width: 2))));
    await tester.pumpAndSettle();
    expect(_desync(tester), 0.0,
        reason: 'the header slid against the body by the left border');
    expect(tester.takeException(), isNull);
  });

  testWidgets('and it still holds once the table is scrolled', (tester) async {
    // The columns total 600 in a 500 viewport, so this reaches the far end —
    // where a header whose content is a different width than the body's would
    // come apart even if it looked right at rest.
    await tester.pumpWidget(
        _table(decoration: BoxDecoration(border: Border.all(width: 2))));
    await tester.pumpAndSettle();

    await tester.drag(find.text('b1'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(_desync(tester), 0.0);
    expect(tester.takeException(), isNull);
  });
}
