import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

const double _rowHeight = 40;
const double _headerHeight = 40;
const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 30, 40, 50);

class _Probe {
  final GlobalKey tableKey = GlobalKey();
  int cellBuilds = 0;
  final ValueNotifier<EdgeInsets> viewInsets = ValueNotifier(EdgeInsets.zero);
  final List<Set<String>> ends = [];
  EdgeInsets? cellPadding;
  EdgeInsets? cellViewPadding;
}

Future<_Probe> _pump(
  WidgetTester tester, {
  required EdgeInsets padding,
  int rowCount = 8,
  double tableHeight = 500,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final probe = _Probe();
  final columns = TableColumnsBuilder<Map<String, dynamic>>()
      .addColumn(
        'c0',
        TablePlusColumn<Map<String, dynamic>>(
          key: 'c0',
          label: 'C0',
          order: 0,
          valueAccessor: (r) => r['c0'],
          width: 100,
        ),
      )
      .addColumn(
        'probe',
        TablePlusColumn<Map<String, dynamic>>(
          key: 'probe',
          label: 'P',
          order: 0,
          valueAccessor: (r) => '',
          width: 100,
          statefulCellBuilder: (context, row, isSelected, isDim) {
            probe.cellBuilds++;
            probe.cellPadding = MediaQuery.paddingOf(context);
            probe.cellViewPadding = MediaQuery.viewPaddingOf(context);
            return const SizedBox.shrink();
          },
        ),
      )
      .build();

  await tester.pumpWidget(
    MaterialApp(
      home: Material(
        child: Center(
          child: SizedBox(
            width: 400,
            height: tableHeight,
            child: ValueListenableBuilder<EdgeInsets>(
              valueListenable: probe.viewInsets,
              builder: (context, viewInsets, table) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: padding,
                  viewPadding: padding,
                  viewInsets: viewInsets,
                ),
                child: table!,
              ),
              child: FlutterTablePlus<Map<String, dynamic>>(
                key: probe.tableKey,
                columns: columns,
                data: List.generate(
                  rowCount,
                  (i) => {'id': '$i', 'c0': 'r${i}c0'},
                ),
                rowId: (r) => r['id'] as String,
                isSelectable: true,
                enableDragSelection: true,
                theme: const TablePlusTheme(
                  bodyTheme: TablePlusBodyTheme(rowHeight: _rowHeight),
                  headerTheme: TablePlusHeaderTheme(height: _headerHeight),
                ),
                onDragSelectionUpdate: (_) {},
                onDragSelectionEnd: (ids) => probe.ends.add(Set.of(ids)),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return probe;
}

ScrollPosition _bodyPosition(WidgetTester tester) {
  return tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      )
      .position;
}

void main() {
  testWidgets('the first row starts right under the header', (tester) async {
    Rect row0(_Probe probe) => tester
        .getRect(find.text('r0c0'))
        .shift(-tester.getRect(find.byKey(probe.tableKey)).topLeft);

    final unpadded = row0(await _pump(tester, padding: EdgeInsets.zero));
    final padded = row0(await _pump(tester, padding: _padding));

    // Row 0 spans [header, header + rowHeight] below the table top, and the
    // padding moves it nowhere.
    expect(unpadded.top, greaterThanOrEqualTo(_headerHeight));
    expect(unpadded.bottom, lessThanOrEqualTo(_headerHeight + _rowHeight));
    expect(padded, unpadded);
  });

  testWidgets('a drag selects the rows drawn under the pointer', (
    tester,
  ) async {
    final probe = await _pump(tester, padding: _padding);

    final left = tester.getRect(find.byKey(probe.tableKey)).left + 20;
    final gesture = await tester.startGesture(
      Offset(left, tester.getCenter(find.text('r0c0')).dy),
    );
    await tester.pump();
    await gesture.moveTo(Offset(left, tester.getCenter(find.text('r3c0')).dy));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(probe.ends, hasLength(1));
    expect(probe.ends.single, <String>{'0', '1', '2', '3'});
  });

  testWidgets('the body scroll extent is the rows alone', (tester) async {
    await _pump(tester, padding: _padding, rowCount: 100);
    final position = _bodyPosition(tester);

    // Rows minus the body viewport: the padding adds nothing to either end.
    expect(
      position.maxScrollExtent,
      100 * _rowHeight - position.viewportDimension,
    );
  });

  testWidgets('a cell sees the left and right padding only', (tester) async {
    final probe = await _pump(tester, padding: _padding);

    // A vertical list consumes the top and bottom padding and passes the
    // left and right on to its children.
    expect(probe.cellPadding, const EdgeInsets.fromLTRB(20, 0, 40, 0));
  });

  testWidgets('a cell sees the whole view padding', (tester) async {
    final probe = await _pump(tester, padding: _padding);

    // The list leaves the view padding alone, as a vertical list does.
    expect(probe.cellViewPadding, _padding);
  });

  testWidgets('a MediaQuery change the cells do not read rebuilds no cell', (
    tester,
  ) async {
    final probe = await _pump(tester, padding: _padding);
    final builds = probe.cellBuilds;
    expect(builds, greaterThan(0));

    for (var i = 1; i <= 5; i++) {
      probe.viewInsets.value = EdgeInsets.only(bottom: i * 10.0);
      await tester.pump();
    }

    expect(probe.cellBuilds, builds);
  });
}
