import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

void main() {
  group('TablePlusHeaderTheme decoration tests', () {
    testWidgets('header decoration is applied when provided',
        (WidgetTester tester) async {
      final headerDecoration = BoxDecoration(
        color: Colors.red,
        boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)],
      );

      final columns = TableColumnsBuilder()
          .addColumn('id', TablePlusColumn(key: 'id', label: 'ID', order: 0))
          .build();

      final data = [
        {'id': '1'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus(
              columns: columns,
              data: data,
              theme: TablePlusTheme(
                headerTheme: TablePlusHeaderTheme(
                  decoration: headerDecoration,
                ),
              ),
            ),
          ),
        ),
      );

      // Find the main header container
      final headerContainer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(FlutterTablePlus),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(headerContainer.decoration, equals(headerDecoration));
    });

    testWidgets('cell decoration is applied when provided',
        (WidgetTester tester) async {
      final cellDecoration = BoxDecoration(
        color: Colors.blue,
        border: Border.all(color: Colors.green, width: 2),
      );

      final columns = TableColumnsBuilder()
          .addColumn('id', TablePlusColumn(key: 'id', label: 'ID', order: 0))
          .build();

      final data = [
        {'id': '1'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus(
              columns: columns,
              data: data,
              theme: TablePlusTheme(
                headerTheme: TablePlusHeaderTheme(
                  cellDecoration: cellDecoration,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that cell decoration is applied
      final cellContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(FlutterTablePlus),
          matching: find.byType(Container),
        ),
      );

      // Should find containers with the cell decoration
      expect(
          cellContainers
              .any((container) => container.decoration == cellDecoration),
          isTrue);
    });

    testWidgets(
        'falls back to backgroundColor and dividers when no decoration provided',
        (WidgetTester tester) async {
      const backgroundColor = Colors.grey;
      const dividerColor = Colors.black;

      final columns = TableColumnsBuilder()
          .addColumn('id', TablePlusColumn(key: 'id', label: 'ID', order: 0))
          .build();

      final data = [
        {'id': '1'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus(
              columns: columns,
              data: data,
              theme: TablePlusTheme(
                headerTheme: TablePlusHeaderTheme(
                  backgroundColor: backgroundColor,
                  dividerColor: dividerColor,
                  showBottomDivider: true,
                  showVerticalDividers: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find containers and check they have expected BoxDecoration properties
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(FlutterTablePlus),
          matching: find.byType(Container),
        ),
      );

      // Should find containers with backgroundColor
      expect(
        containers.any((container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration &&
              decoration.color == backgroundColor;
        }),
        isTrue,
      );
    });
  });

  group('TablePlusHeaderTheme copyWith tests', () {
    test('copyWith preserves cellDecoration', () {
      const originalTheme = TablePlusHeaderTheme(
        backgroundColor: Colors.red,
        cellDecoration: BoxDecoration(color: Colors.blue),
      );

      final copiedTheme = originalTheme.copyWith(
        backgroundColor: Colors.green,
      );

      expect(copiedTheme.backgroundColor, Colors.green);
      expect(
          copiedTheme.cellDecoration, const BoxDecoration(color: Colors.blue));
    });

    test('copyWith can update cellDecoration', () {
      const originalTheme = TablePlusHeaderTheme(
        backgroundColor: Colors.red,
        cellDecoration: BoxDecoration(color: Colors.blue),
      );

      const newCellDecoration = BoxDecoration(color: Colors.yellow);
      final copiedTheme = originalTheme.copyWith(
        cellDecoration: newCellDecoration,
      );

      expect(copiedTheme.backgroundColor, Colors.red);
      expect(copiedTheme.cellDecoration, newCellDecoration);
    });
  });
}
