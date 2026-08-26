import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget-level coverage for TablePlusMergedRow's render + edit paths (the model
// is unit-tested elsewhere; this drives the actual widget).

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns({
  bool groupEditable = false,
}) {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  b.addColumn(
    'group',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'group',
      label: 'Group',
      order: 0,
      valueAccessor: (r) => r['group'],
      width: 150,
      editable: groupEditable,
    ),
  );
  b.addColumn(
    'value',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'value',
      label: 'Value',
      order: 0,
      valueAccessor: (r) => r['value'],
      width: 150,
    ),
  );
  return b.build();
}

const _data = [
  {'id': '1', 'group': 'GA', 'value': 'V1'},
  {'id': '2', 'group': 'GB', 'value': 'V2'},
];

MergedRowGroup<Map<String, dynamic>> _group({
  Map<String, MergeCellConfig> config = const {
    'group': MergeCellConfig(shouldMerge: true),
  },
  bool expanded = false,
  Widget? Function(String columnKey)? summary,
}) {
  return MergedRowGroup<Map<String, dynamic>>(
    groupId: 'g1',
    rowKeys: const ['1', '2'],
    mergeConfig: config,
    isExpanded: expanded,
    summaryBuilder: summary,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required List<MergedRowGroup<Map<String, dynamic>>> groups,
  Map<String, TablePlusColumn<Map<String, dynamic>>>? columns,
  bool editable = false,
  void Function(String groupId, String columnKey, dynamic newValue)?
      onMergedCellChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FlutterTablePlus<Map<String, dynamic>>(
          columns: columns ?? _columns(),
          data: _data,
          rowId: (r) => r['id'] as String,
          mergedGroups: groups,
          isEditable: editable,
          onMergedCellChanged: onMergedCellChanged,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a merged column shows one spanning value; others stack',
      (tester) async {
    await _pump(tester, groups: [_group()]);

    // 'group' is merged (spanningRowIndex 0) -> shows GA only, not GB.
    expect(find.text('GA'), findsOneWidget);
    expect(find.text('GB'), findsNothing);
    // 'value' is not merged -> both rows stack.
    expect(find.text('V1'), findsOneWidget);
    expect(find.text('V2'), findsOneWidget);
  });

  testWidgets('a merged column with mergedContent renders that widget',
      (tester) async {
    await _pump(tester, groups: [
      _group(config: const {
        'group':
            MergeCellConfig(shouldMerge: true, mergedContent: Text('CUSTOM')),
      }),
    ]);

    expect(find.text('CUSTOM'), findsOneWidget);
    expect(find.text('GA'), findsNothing); // replaced by the custom content
  });

  testWidgets('the summary row renders only when expanded', (tester) async {
    Widget? summary(String col) =>
        col == 'value' ? const Text('SUMMARY') : null;

    await _pump(tester, groups: [_group(expanded: true, summary: summary)]);
    expect(find.text('SUMMARY'), findsOneWidget);
  });

  testWidgets('the summary row is hidden when collapsed', (tester) async {
    Widget? summary(String col) =>
        col == 'value' ? const Text('SUMMARY') : null;

    await _pump(tester, groups: [_group(expanded: false, summary: summary)]);
    expect(find.text('SUMMARY'), findsNothing);
  });

  testWidgets('editing an editable merged cell fires onMergedCellChanged',
      (tester) async {
    String? groupId;
    String? columnKey;
    dynamic newValue;

    await _pump(
      tester,
      columns: _columns(groupEditable: true),
      groups: [
        _group(config: const {
          'group': MergeCellConfig(shouldMerge: true, isEditable: true),
        }),
      ],
      editable: true,
      onMergedCellChanged: (g, c, v) {
        groupId = g;
        columnKey = c;
        newValue = v;
      },
    );

    await tester.tap(find.text('GA'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'EDITED');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(groupId, 'g1');
    expect(columnKey, 'group');
    expect(newValue, 'EDITED');
  });
}
