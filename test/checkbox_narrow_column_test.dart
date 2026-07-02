import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression for #4: a narrow selection column (checkboxColumnWidth < ~40) must
// not clip the checkbox. The checkbox's rendered size should not depend on how
// wide its column is. Fails today because the selection cell wraps the checkbox
// in the full horizontal body padding, squeezing the content area to near zero.

Future<void> _pump(
  WidgetTester tester, {
  required double columnWidth,
  required bool showSelectAll,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FlutterTablePlus<Map<String, dynamic>>(
          columns: {
            'name': TablePlusColumn<Map<String, dynamic>>(
              key: 'name',
              label: 'Name',
              order: 0,
              valueAccessor: (r) => r['name'],
              width: 200,
            ),
          },
          data: const [
            {'id': '1', 'name': 'A'}
          ],
          rowId: (r) => r['id'] as String,
          isSelectable: true,
          onRowSelectionChanged: (_, __) {},
          onSelectAll: showSelectAll ? (_) {} : null,
          theme: TablePlusTheme(
            checkboxTheme: TablePlusCheckboxTheme(
              checkboxColumnWidth: columnWidth,
              showSelectAllCheckbox: showSelectAll,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the row selection checkbox does not shrink in a narrow column',
      (tester) async {
    // Only the row checkbox renders (select-all off) -> find.first is the row.
    await _pump(tester, columnWidth: 200, showSelectAll: false);
    final roomy = tester.getSize(find.byType(FlutterCheckbox).first).width;

    await _pump(tester, columnWidth: 30, showSelectAll: false);
    final narrow = tester.getSize(find.byType(FlutterCheckbox).first).width;

    expect(narrow, closeTo(roomy, 0.5),
        reason: 'the checkbox size must not depend on the column width (#4)');
  });

  testWidgets(
      'the header select-all checkbox does not shrink in a narrow column',
      (tester) async {
    // The header renders before the body, so find.first is the select-all box.
    await _pump(tester, columnWidth: 200, showSelectAll: true);
    final roomy = tester.getSize(find.byType(FlutterCheckbox).first).width;

    await _pump(tester, columnWidth: 30, showSelectAll: true);
    final narrow = tester.getSize(find.byType(FlutterCheckbox).first).width;

    expect(narrow, closeTo(roomy, 0.5),
        reason: 'the select-all checkbox size must not depend on the column '
            'width (#4)');
  });
}
