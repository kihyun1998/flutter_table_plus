import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A column's `tooltipBuilder` draws content of its own; it does not read the
// cell's text. So whether the text is ellipsized, or empty, must not decide
// whether that tooltip appears. Only TooltipBehavior.never suppresses it.
//
// These hover the table for real: JustTooltip inserts into the Overlay after
// `waitDuration` (500ms by default), so each case pumps past it.

const _cardText = 'CARD';

Widget _table({
  required TablePlusColumn<Map<String, dynamic>> column,
  List<Map<String, dynamic>> data = const [
    {'id': '1', 'name': 'Alpha'}
  ],
}) {
  return MaterialApp(
    home: Scaffold(
      body: FlutterTablePlus<Map<String, dynamic>>(
        columns: {'name': column},
        data: data,
        rowId: (r) => r['id'] as String,
      ),
    ),
  );
}

/// Hovers [location] and waits out the tooltip's `waitDuration`.
Future<void> _hoverAt(WidgetTester tester, Offset location) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await tester.pump();

  await mouse.moveTo(location);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

/// Hovers the centre of [finder].
Future<void> _hover(WidgetTester tester, Finder finder) =>
    _hoverAt(tester, tester.getCenter(finder));

void main() {
  testWidgets('a widget tooltip shows on a column that does not ellipsize',
      (tester) async {
    await tester.pumpWidget(
      _table(
        column: TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 0,
          valueAccessor: (r) => r['name'],
          width: 200,
          textOverflow: TextOverflow.visible,
          tooltipBuilder: (context, rowData) => const Text(_cardText),
        ),
      ),
    );

    await _hover(tester, find.text('Alpha'));

    expect(find.text(_cardText), findsOneWidget);
  });

  testWidgets('a widget tooltip shows on a cell whose text is empty',
      (tester) async {
    await tester.pumpWidget(
      _table(
        data: const [
          {'id': '1', 'name': ''}
        ],
        column: TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 0,
          valueAccessor: (r) => r['name'],
          width: 200,
          tooltipBuilder: (context, rowData) => const Text(_cardText),
        ),
      ),
    );

    await _hover(tester, find.text(''));

    expect(find.text(_cardText), findsOneWidget);
  });

  testWidgets('a widget tooltip shows on a statefulCellBuilder column',
      (tester) async {
    await tester.pumpWidget(
      _table(
        column: TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 0,
          valueAccessor: (r) => r['name'],
          width: 200,
          statefulCellBuilder: (context, rowData, isSelected, isDim) =>
              const Icon(Icons.circle),
          tooltipBuilder: (context, rowData) => const Text(_cardText),
        ),
      ),
    );

    await _hover(tester, find.byIcon(Icons.circle));

    expect(find.text(_cardText), findsOneWidget);
  });

  testWidgets('TooltipBehavior.never still suppresses a widget tooltip',
      (tester) async {
    await tester.pumpWidget(
      _table(
        column: TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 0,
          valueAccessor: (r) => r['name'],
          width: 200,
          tooltipBehavior: TooltipBehavior.never,
          tooltipBuilder: (context, rowData) => const Text(_cardText),
        ),
      ),
    );

    await _hover(tester, find.text('Alpha'));

    expect(find.text(_cardText), findsNothing);
  });

  testWidgets('a text tooltip still shows on an ellipsized column',
      (tester) async {
    await tester.pumpWidget(
      _table(
        column: TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 0,
          valueAccessor: (r) => r['name'],
          width: 200,
          tooltipFormatter: (rowData) => 'FULL',
        ),
      ),
    );

    await _hover(tester, find.text('Alpha'));

    expect(find.text('FULL'), findsOneWidget);
  });

  testWidgets('a text tooltip still ignores the blank part of its cell',
      (tester) async {
    // The text tooltip belongs to the glyphs. Widening its hover area to the
    // whole cell would be an observable change for existing users.
    await tester.pumpWidget(
      _table(
        column: TablePlusColumn<Map<String, dynamic>>(
          key: 'name',
          label: 'Name',
          order: 0,
          valueAccessor: (r) => r['name'],
          width: 400,
          tooltipFormatter: (rowData) => 'FULL',
        ),
      ),
    );

    final text = tester.getRect(find.text('Alpha'));
    await _hoverAt(tester, Offset(text.right + 40, text.center.dy));

    expect(find.text('FULL'), findsNothing);
  });

  testWidgets('a widget tooltip shows on a merged custom cell', (tester) async {
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
                statefulCellBuilder: (context, rowData, isSelected, isDim) =>
                    const Icon(Icons.circle),
                tooltipBuilder: (context, rowData) => const Text(_cardText),
              ),
            },
            data: const [
              {'id': '1', 'name': 'Alpha'},
              {'id': '2', 'name': 'Bravo'},
            ],
            rowId: (r) => r['id'] as String,
            mergedGroups: const [
              MergedRowGroup<Map<String, dynamic>>(
                groupId: 'g1',
                rowKeys: ['1', '2'],
                mergeConfig: {'name': MergeCellConfig(shouldMerge: true)},
              ),
            ],
          ),
        ),
      ),
    );

    await _hover(tester, find.byIcon(Icons.circle));

    expect(find.text(_cardText), findsOneWidget);
  });
}
