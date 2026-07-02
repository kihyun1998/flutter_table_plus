import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Auto-fit (double-tap a resize handle) routes through the tested
// TableColumnWidthCalculator. This integration smoke test asserts the wiring
// end-to-end: the result is reported and clamped to the column's bounds. Exact
// pixels depend on the font, so the assertions are relational.

void main() {
  testWidgets(
      'double-tapping a resize handle auto-fits within the column bounds',
      (tester) async {
    String? resizedKey;
    double? resizedWidth;

    final columns = (TableColumnsBuilder<Map<String, dynamic>>()
          ..addColumn(
            'name',
            TablePlusColumn<Map<String, dynamic>>(
              key: 'name',
              label: 'Name',
              order: 0,
              valueAccessor: (r) => r['name'],
              width: 300,
              minWidth: 80,
              maxWidth: 200,
            ),
          ))
        .build();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterTablePlus<Map<String, dynamic>>(
            columns: columns,
            data: const [
              {
                'id': '1',
                'name': 'A very long value that exceeds the max width'
              }
            ],
            rowId: (r) => r['id'] as String,
            resizable: true,
            onColumnResized: (key, width) {
              resizedKey = key;
              resizedWidth = width;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final handle = find.byKey(const ValueKey('resize_name'));
    expect(handle, findsOneWidget);

    // Double-tap the handle to trigger auto-fit.
    await tester.tap(handle);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(handle);
    await tester.pumpAndSettle();

    expect(resizedKey, 'name');
    expect(resizedWidth, isNotNull);
    // The content wants more than maxWidth, so auto-fit clamps to maxWidth.
    expect(resizedWidth, lessThanOrEqualTo(200));
    expect(resizedWidth, greaterThanOrEqualTo(80));
  });
}
