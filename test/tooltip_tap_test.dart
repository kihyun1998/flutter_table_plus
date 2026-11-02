import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// TablePlusTooltipTheme.enableTap decides whether a tap on a cell opens its
// tooltip.

const _tip = 'Name: Alpha';

Widget _table({required bool enableTap}) {
  return MaterialApp(
    home: Scaffold(
      body: FlutterTablePlus<Map<String, dynamic>>(
        theme: TablePlusTheme(
          tooltipTheme: TablePlusTooltipTheme(enableTap: enableTap),
        ),
        columns: {
          'name': TablePlusColumn<Map<String, dynamic>>(
            key: 'name',
            label: 'Name',
            order: 0,
            width: 200,
            valueAccessor: (r) => r['name'],
            tooltipFormatter: (r) => _tip,
          ),
        },
        data: const [
          {'id': '1', 'name': 'Alpha'},
        ],
        rowId: (r) => r['id'] as String,
      ),
    ),
  );
}

void main() {
  testWidgets('enableTap: true opens the tooltip on a tap', (tester) async {
    await tester.pumpWidget(_table(enableTap: true));

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(find.text(_tip), findsOneWidget);
  });

  testWidgets('enableTap: false leaves a tap without a tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(_table(enableTap: false));

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(find.text(_tip), findsNothing);
  });
}
