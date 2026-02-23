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
}
