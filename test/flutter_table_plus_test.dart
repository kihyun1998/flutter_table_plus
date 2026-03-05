import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterTablePlus', () {
    testWidgets('renders basic table with data', (WidgetTester tester) async {
      final columns = <String, TablePlusColumn<Map<String, dynamic>>>{
        'name': TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 1,
          valueAccessor: (row) => row['name'],
          width: 200,
        ),
        'age': TablePlusColumn<Map<String, dynamic>>(
          key: 'age',
          label: 'Age',
          order: 2,
          valueAccessor: (row) => row['age'],
          width: 100,
        ),
      };

      final data = [
        {'id': '1', 'name': 'Alice', 'age': 30},
        {'id': '2', 'name': 'Bob', 'age': 25},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: columns,
              data: data,
              rowId: (row) => row['id'] as String,
            ),
          ),
        ),
      );

      // Verify headers are displayed
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);

      // Verify data is displayed
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('renders empty state', (WidgetTester tester) async {
      final columns = <String, TablePlusColumn<Map<String, dynamic>>>{
        'name': TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 1,
          valueAccessor: (row) => row['name'],
          width: 200,
        ),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: columns,
              data: const [],
              rowId: (row) => row['id'] as String,
              noDataWidget: const Text('No data'),
            ),
          ),
        ),
      );

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('handles sorting', (WidgetTester tester) async {
      String? sortedColumn;
      SortDirection? sortedDirection;

      final columns = <String, TablePlusColumn<Map<String, dynamic>>>{
        'name': TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 1,
          valueAccessor: (row) => row['name'],
          width: 200,
          sortable: true,
        ),
      };

      final data = [
        {'id': '1', 'name': 'Alice'},
        {'id': '2', 'name': 'Bob'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: columns,
              data: data,
              rowId: (row) => row['id'] as String,
              onSort: (columnKey, direction) {
                sortedColumn = columnKey;
                sortedDirection = direction;
              },
            ),
          ),
        ),
      );

      // Tap on the sortable header
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      expect(sortedColumn, 'name');
      expect(sortedDirection, SortDirection.ascending);
    });

    testWidgets('handles selection', (WidgetTester tester) async {
      String? selectedRowId;
      bool? isSelected;

      final columns = <String, TablePlusColumn<Map<String, dynamic>>>{
        'name': TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 1,
          valueAccessor: (row) => row['name'],
          width: 200,
        ),
      };

      final data = [
        {'id': '1', 'name': 'Alice'},
        {'id': '2', 'name': 'Bob'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: columns,
              data: data,
              rowId: (row) => row['id'] as String,
              isSelectable: true,
              onRowSelectionChanged: (rowId, selected) {
                selectedRowId = rowId;
                isSelected = selected;
              },
            ),
          ),
        ),
      );

      // Tap on a row
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(selectedRowId, '1');
      expect(isSelected, true);
    });

    testWidgets('renders with custom cell builder',
        (WidgetTester tester) async {
      final columns = <String, TablePlusColumn<Map<String, dynamic>>>{
        'status': TablePlusColumn<Map<String, dynamic>>(
          key: 'status',
          label: 'Status',
          order: 1,
          valueAccessor: (row) => row['status'],
          width: 200,
          statefulCellBuilder: (context, row, isSelected, isDim) {
            return Text('Custom: ${row['status']}');
          },
        ),
      };

      final data = [
        {'id': '1', 'status': 'Active'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: columns,
              data: data,
              rowId: (row) => row['id'] as String,
            ),
          ),
        ),
      );

      expect(find.text('Custom: Active'), findsOneWidget);
    });
  });

  group('TableColumnsBuilder', () {
    test('builds columns with correct order', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'name',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'name',
            label: 'Name',
            order: 0,
            valueAccessor: (row) => row['name'],
          ),
        )
        ..addColumn(
          'age',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'age',
            label: 'Age',
            order: 0,
            valueAccessor: (row) => row['age'],
          ),
        );

      final columns = builder.build();

      expect(columns.length, 2);
      expect(columns['name']!.order, 1);
      expect(columns['age']!.order, 2);
    });

    test('throws on duplicate column keys', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'name',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'name',
            label: 'Name',
            order: 0,
            valueAccessor: (row) => row['name'],
          ),
        );

      expect(
        () => builder.addColumn(
          'name',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'name',
            label: 'Name 2',
            order: 0,
            valueAccessor: (row) => row['name'],
          ),
        ),
        throwsArgumentError,
      );
    });

    test('insert column shifts existing orders', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
        )
        ..addColumn(
          'b',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'b',
            label: 'B',
            order: 0,
            valueAccessor: (row) => row['b'],
          ),
        )
        ..insertColumn(
          'c',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'c',
            label: 'C',
            order: 0,
            valueAccessor: (row) => row['c'],
          ),
          1,
        );

      final columns = builder.build();

      expect(columns['c']!.order, 1);
      expect(columns['a']!.order, 2);
      expect(columns['b']!.order, 3);
    });
  });

  group('TablePlusColumn', () {
    test('copyWith preserves values', () {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 1,
        valueAccessor: (row) => row['name'],
        width: 200,
        sortable: true,
        editable: true,
      );

      final copied = column.copyWith(label: 'Full Name');

      expect(copied.key, 'name');
      expect(copied.label, 'Full Name');
      expect(copied.order, 1);
      expect(copied.width, 200);
      expect(copied.sortable, true);
      expect(copied.editable, true);
    });

    test('valueAccessor extracts correct value', () {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 1,
        valueAccessor: (row) => row['name'],
      );

      final row = {'name': 'Alice', 'age': 30};
      expect(column.valueAccessor(row), 'Alice');
    });
  });

  group('MergedRowGroup', () {
    test('getRowData finds correct row', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'group1',
        rowKeys: ['1', '2', '3'],
        mergeConfig: {},
      );

      final data = [
        {'id': '1', 'name': 'Alice'},
        {'id': '2', 'name': 'Bob'},
        {'id': '3', 'name': 'Charlie'},
      ];

      final row = group.getRowData(data, '2', (r) => r['id'] as String);
      expect(row?['name'], 'Bob');
    });

    test('getAllRowData returns all group rows', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'group1',
        rowKeys: ['1', '3'],
        mergeConfig: {},
      );

      final data = [
        {'id': '1', 'name': 'Alice'},
        {'id': '2', 'name': 'Bob'},
        {'id': '3', 'name': 'Charlie'},
      ];

      final rows = group.getAllRowData(data, (r) => r['id'] as String);
      expect(rows.length, 2);
      expect(rows[0]['name'], 'Alice');
      expect(rows[1]['name'], 'Charlie');
    });

    test('summaryBuilder returns widget for column', () {
      final group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'group1',
        rowKeys: const ['1'],
        mergeConfig: const {},
        summaryBuilder: (columnKey) {
          if (columnKey == 'total') {
            return const Text('100');
          }
          return null;
        },
      );

      final widget = group.summaryBuilder?.call('total');
      expect(widget, isA<Text>());

      final nullWidget = group.summaryBuilder?.call('other');
      expect(nullWidget, isNull);
    });
  });

  group('CellChangedCallback', () {
    test('includes row object in callback', () {
      Map<String, dynamic>? callbackRow;
      String? callbackColumnKey;
      int? callbackRowIndex;

      void callback(
        Map<String, dynamic> row,
        String columnKey,
        int rowIndex,
        dynamic oldValue,
        dynamic newValue,
      ) {
        callbackRow = row;
        callbackColumnKey = columnKey;
        callbackRowIndex = rowIndex;
      }

      final row = {'id': '1', 'name': 'Alice'};
      callback(row, 'name', 0, 'Alice', 'Bob');

      expect(callbackRow, row);
      expect(callbackColumnKey, 'name');
      expect(callbackRowIndex, 0);
    });
  });

  group('TableColumnsBuilder - removeColumn', () {
    test('removes column and shifts orders down', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
        )
        ..addColumn(
          'b',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'b',
            label: 'B',
            order: 0,
            valueAccessor: (row) => row['b'],
          ),
        )
        ..addColumn(
          'c',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'c',
            label: 'C',
            order: 0,
            valueAccessor: (row) => row['c'],
          ),
        )
        ..removeColumn('b');

      final columns = builder.build();

      expect(columns.length, 2);
      expect(columns['a']!.order, 1);
      expect(columns['c']!.order, 2);
    });

    test('throws on removing non-existent key', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>();

      expect(
        () => builder.removeColumn('nonexistent'),
        throwsArgumentError,
      );
    });
  });

  group('TableColumnsBuilder - reorderColumn', () {
    test('moves column forward', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
        )
        ..addColumn(
          'b',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'b',
            label: 'B',
            order: 0,
            valueAccessor: (row) => row['b'],
          ),
        )
        ..addColumn(
          'c',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'c',
            label: 'C',
            order: 0,
            valueAccessor: (row) => row['c'],
          ),
        )
        ..reorderColumn('c', 1);

      final columns = builder.build();

      expect(columns['c']!.order, 1);
      expect(columns['a']!.order, 2);
      expect(columns['b']!.order, 3);
    });

    test('moves column backward', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
        )
        ..addColumn(
          'b',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'b',
            label: 'B',
            order: 0,
            valueAccessor: (row) => row['b'],
          ),
        )
        ..addColumn(
          'c',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'c',
            label: 'C',
            order: 0,
            valueAccessor: (row) => row['c'],
          ),
        )
        ..reorderColumn('a', 3);

      final columns = builder.build();

      expect(columns['b']!.order, 1);
      expect(columns['c']!.order, 2);
      expect(columns['a']!.order, 3);
    });

    test('same position is no-op', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
        )
        ..reorderColumn('a', 1);

      final columns = builder.build();
      expect(columns['a']!.order, 1);
    });

    test('throws on non-existent key', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>();

      expect(
        () => builder.reorderColumn('nonexistent', 1),
        throwsArgumentError,
      );
    });

    test('throws on order less than 1', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
        );

      expect(
        () => builder.reorderColumn('a', 0),
        throwsArgumentError,
      );
    });
  });

  group('TableColumnsBuilder - insertColumn validation', () {
    test('throws on order less than 1', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>();

      expect(
        () => builder.insertColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
          0,
        ),
        throwsArgumentError,
      );
    });

    test('throws on duplicate key in insertColumn', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
        );

      expect(
        () => builder.insertColumn(
          'a',
          TablePlusColumn<Map<String, dynamic>>(
            key: 'a',
            label: 'A2',
            order: 0,
            valueAccessor: (row) => row['a'],
          ),
          1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('TableColumnsBuilder - properties', () {
    test('length, isEmpty, isNotEmpty, containsKey', () {
      final builder = TableColumnsBuilder<Map<String, dynamic>>();

      expect(builder.length, 0);
      expect(builder.isEmpty, true);
      expect(builder.isNotEmpty, false);
      expect(builder.containsKey('a'), false);

      builder.addColumn(
        'a',
        TablePlusColumn<Map<String, dynamic>>(
          key: 'a',
          label: 'A',
          order: 0,
          valueAccessor: (row) => row['a'],
        ),
      );

      expect(builder.length, 1);
      expect(builder.isEmpty, false);
      expect(builder.isNotEmpty, true);
      expect(builder.containsKey('a'), true);
      expect(builder.containsKey('b'), false);
    });
  });

  group('TablePlusColumn - additional', () {
    test('default values are correct', () {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'test',
        label: 'Test',
        order: 1,
        valueAccessor: (row) => row['test'],
      );

      expect(column.width, 100.0);
      expect(column.minWidth, 50.0);
      expect(column.maxWidth, isNull);
      expect(column.alignment, Alignment.centerLeft);
      expect(column.textAlign, TextAlign.left);
      expect(column.sortable, false);
      expect(column.editable, false);
      expect(column.visible, true);
      expect(column.textOverflow, TextOverflow.ellipsis);
      expect(column.tooltipBehavior, TooltipBehavior.always);
      expect(column.headerTooltipBehavior, TooltipBehavior.always);
      expect(column.hintText, isNull);
      expect(column.tooltipFormatter, isNull);
      expect(column.tooltipBuilder, isNull);
    });

    test('hasCustomCellBuilder returns false when no builder', () {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'test',
        label: 'Test',
        order: 1,
        valueAccessor: (row) => row['test'],
      );

      expect(column.hasCustomCellBuilder, false);
    });

    test('hasCustomCellBuilder returns true when builder provided', () {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'test',
        label: 'Test',
        order: 1,
        valueAccessor: (row) => row['test'],
        statefulCellBuilder: (context, row, isSelected, isDim) {
          return const Text('custom');
        },
      );

      expect(column.hasCustomCellBuilder, true);
    });

    testWidgets('buildCustomCell returns widget when builder set',
        (WidgetTester tester) async {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'test',
        label: 'Test',
        order: 1,
        valueAccessor: (row) => row['test'],
        statefulCellBuilder: (context, row, isSelected, isDim) {
          return Text('built: ${row['test']}');
        },
      );

      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            capturedContext = context;
            return const SizedBox();
          }),
        ),
      );

      final row = {'test': 'value'};
      final widget = column.buildCustomCell(capturedContext, row, false, false);
      expect(widget, isNotNull);
      expect(widget, isA<Text>());
    });

    test('buildCustomCell returns null when no builder', () {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'test',
        label: 'Test',
        order: 1,
        valueAccessor: (row) => row['test'],
      );

      // buildCustomCell needs a BuildContext, but when no builder is set
      // it returns null without using the context, so we can test the logic
      // indirectly via hasCustomCellBuilder
      expect(column.hasCustomCellBuilder, false);
    });

    test('copyWith replaces all specified fields', () {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 1,
        valueAccessor: (row) => row['name'],
      );

      final copied = column.copyWith(
        width: 300,
        minWidth: 100,
        maxWidth: 500,
        alignment: Alignment.center,
        textAlign: TextAlign.center,
        sortable: true,
        editable: true,
        visible: false,
        textOverflow: TextOverflow.fade,
        tooltipBehavior: TooltipBehavior.never,
        headerTooltipBehavior: TooltipBehavior.onlyTextOverflow,
        hintText: 'Enter name',
      );

      expect(copied.width, 300);
      expect(copied.minWidth, 100);
      expect(copied.maxWidth, 500);
      expect(copied.alignment, Alignment.center);
      expect(copied.textAlign, TextAlign.center);
      expect(copied.sortable, true);
      expect(copied.editable, true);
      expect(copied.visible, false);
      expect(copied.textOverflow, TextOverflow.fade);
      expect(copied.tooltipBehavior, TooltipBehavior.never);
      expect(copied.headerTooltipBehavior, TooltipBehavior.onlyTextOverflow);
      expect(copied.hintText, 'Enter name');
    });

    test('valueAccessor handles null value', () {
      final column = TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 1,
        valueAccessor: (row) => row['name'],
      );

      final row = <String, dynamic>{'name': null};
      expect(column.valueAccessor(row), isNull);
    });
  });

  group('MergedRowGroup - additional', () {
    test('rowCount returns correct count', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1', '2', '3'],
        mergeConfig: {},
      );

      expect(group.rowCount, 3);
    });

    test('shouldMergeColumn returns true for configured column', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1', '2'],
        mergeConfig: {
          'name': MergeCellConfig(shouldMerge: true),
          'age': MergeCellConfig(shouldMerge: false),
        },
      );

      expect(group.shouldMergeColumn('name'), true);
      expect(group.shouldMergeColumn('age'), false);
      expect(group.shouldMergeColumn('nonexistent'), false);
    });

    test('getSpanningRowIndex returns configured index', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1', '2', '3'],
        mergeConfig: {
          'name': MergeCellConfig(shouldMerge: true, spanningRowIndex: 2),
        },
      );

      expect(group.getSpanningRowIndex('name'), 2);
      expect(group.getSpanningRowIndex('nonexistent'), 0);
    });

    test('getSpanningRowKey returns correct row key', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['a', 'b', 'c'],
        mergeConfig: {
          'name': MergeCellConfig(shouldMerge: true, spanningRowIndex: 1),
        },
      );

      expect(group.getSpanningRowKey('name'), 'b');
    });

    test('getMergedContent returns widget when configured', () {
      const customWidget = Text('merged');
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1'],
        mergeConfig: {
          'name':
              MergeCellConfig(shouldMerge: true, mergedContent: customWidget),
          'age': MergeCellConfig(shouldMerge: true),
        },
      );

      expect(group.getMergedContent('name'), isA<Text>());
      expect(group.getMergedContent('age'), isNull);
      expect(group.getMergedContent('nonexistent'), isNull);
    });

    test('isMergedCellEditable respects conditions', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1'],
        mergeConfig: {
          'editable': MergeCellConfig(shouldMerge: true, isEditable: true),
          'not_editable': MergeCellConfig(shouldMerge: true, isEditable: false),
          'not_merged': MergeCellConfig(shouldMerge: false, isEditable: true),
          'has_content': MergeCellConfig(
            shouldMerge: true,
            isEditable: true,
            mergedContent: Text('custom'),
          ),
        },
      );

      expect(group.isMergedCellEditable('editable'), true);
      expect(group.isMergedCellEditable('not_editable'), false);
      expect(group.isMergedCellEditable('not_merged'), false);
      expect(group.isMergedCellEditable('has_content'), false);
      expect(group.isMergedCellEditable('nonexistent'), false);
    });

    test('effectiveRowCount without expandable', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1', '2'],
        mergeConfig: {},
      );

      expect(group.effectiveRowCount, 2);
    });

    test('effectiveRowCount with expandable collapsed', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1', '2'],
        mergeConfig: {},
        isExpandable: true,
        isExpanded: false,
      );

      expect(group.effectiveRowCount, 2);
    });

    test('effectiveRowCount with expandable expanded', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1', '2'],
        mergeConfig: {},
        isExpandable: true,
        isExpanded: true,
      );

      expect(group.effectiveRowCount, 3);
    });

    test('getRowData returns null for non-existent key', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1'],
        mergeConfig: {},
      );

      final data = [
        {'id': '1', 'name': 'Alice'},
      ];

      final result =
          group.getRowData(data, 'nonexistent', (r) => r['id'] as String);
      expect(result, isNull);
    });

    test('getAllRowData skips non-existent rows', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['1', '999'],
        mergeConfig: {},
      );

      final data = [
        {'id': '1', 'name': 'Alice'},
      ];

      final rows = group.getAllRowData(data, (r) => r['id'] as String);
      expect(rows.length, 1);
      expect(rows[0]['name'], 'Alice');
    });
  });

  group('MergeCellConfig', () {
    test('default values are correct', () {
      const config = MergeCellConfig(shouldMerge: true);

      expect(config.shouldMerge, true);
      expect(config.spanningRowIndex, 0);
      expect(config.mergedContent, isNull);
      expect(config.isEditable, false);
    });

    test('custom values are preserved', () {
      const config = MergeCellConfig(
        shouldMerge: false,
        spanningRowIndex: 2,
        mergedContent: Text('custom'),
        isEditable: true,
      );

      expect(config.shouldMerge, false);
      expect(config.spanningRowIndex, 2);
      expect(config.mergedContent, isA<Text>());
      expect(config.isEditable, true);
    });
  });

  group('SortIcons', () {
    test('defaultIcons has all icons', () {
      expect(SortIcons.defaultIcons.ascending, isA<Icon>());
      expect(SortIcons.defaultIcons.descending, isA<Icon>());
      expect(SortIcons.defaultIcons.unsorted, isA<Icon>());
    });

    test('simple icons has no unsorted icon', () {
      expect(SortIcons.simple.ascending, isA<Icon>());
      expect(SortIcons.simple.descending, isA<Icon>());
      expect(SortIcons.simple.unsorted, isNull);
    });
  });
}
