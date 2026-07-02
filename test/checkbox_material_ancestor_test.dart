import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression for #3: the table's checkboxes must render without a Material
// ancestor (e.g. a desktop app that doesn't use Material / Scaffold).
//
// MaterialApp WITHOUT a Scaffold provides Directionality / MediaQuery /
// DefaultTextStyle but NOT a Material widget — exactly the reporter's setup.

Widget _table() {
  return FlutterTablePlus<Map<String, dynamic>>(
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
    onSelectAll: (_) {},
  );
}

void main() {
  testWidgets('checkboxes render without a Material ancestor', (tester) async {
    // No Scaffold -> no Material ancestor.
    await tester.pumpWidget(MaterialApp(home: _table()));

    expect(
      tester.takeException(),
      isNull,
      reason: 'the table must not require a Material ancestor for its '
          'checkboxes (#3)',
    );
  });
}
