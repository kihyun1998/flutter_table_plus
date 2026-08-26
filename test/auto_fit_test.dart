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

  testWidgets('auto-fit clamps to the declared maxWidth at scale 2.0',
      (tester) async {
    // This file named no scale until #114, and that is the whole point of the
    // test. `_handleColumnAutoFit` measures in rendered space and converts the
    // bounds to match (`column.maxWidth! * scale`); at `scale: 1.0` that
    // multiplication is the identity, so deleting it left every assertion above
    // green. Measured 2026-08-26 — without the conversion this reports 100.
    //
    // Auto-fit is the *other* path into the same clamp the drag path uses, and
    // it was the precedent #114's fix was modelled on. An unobserved precedent
    // is not a precedent.
    double? resized;

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
            scale: 2.0,
            onColumnResized: (key, width) => resized = width,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final handle = find.byKey(const ValueKey('resize_name'));
    await tester.tap(handle);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(handle);
    await tester.pumpAndSettle();

    // Exact, not relational: the content overflows the ceiling at any scale, so
    // the answer is the declared ceiling itself. A relational bound would be
    // satisfied by the mis-scaled 100 as well.
    expect(resized, closeTo(200, 0.001));
  });

  testWidgets('an autoFitColumnWidth override is clamped in logical units',
      (tester) async {
    // The third path into a bound clamp, and the one that must NOT convert:
    // this callback is documented to return logical pixels, so it is clamped
    // logical-against-logical. That makes it look like an inconsistency beside
    // the two rendered-space clamps, and a future reader "fixing" it would
    // break it — so the asymmetry is pinned here rather than left to a comment.
    //
    // 500 is over the ceiling either way; what separates the two is *which*
    // ceiling. Logical gives 200. Scaling it the way the other two paths scale
    // theirs gives 400.
    double? resized;

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
              {'id': '1', 'name': 'short'}
            ],
            rowId: (r) => r['id'] as String,
            resizable: true,
            scale: 2.0,
            autoFitColumnWidth: (_) => 500,
            onColumnResized: (key, width) => resized = width,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final handle = find.byKey(const ValueKey('resize_name'));
    await tester.tap(handle);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(handle);
    await tester.pumpAndSettle();

    expect(resized, closeTo(200, 0.001));
  });
}
