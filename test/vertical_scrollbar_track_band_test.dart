import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Whether the body scrolls vertically is decided against the height the body
// actually gets: the table's height minus the header and, when the horizontal
// scrollbar is shown, minus the track reserved under the body.
//
// The fixture: default theme (header 56, rows 48), five rows, 400 wide, so the
// content is 56 + 5 * 48 = 296 tall. With the horizontal track (12 at scale 1)
// reserved, the body scrolls for every table height below 296 + 12 = 308.

const _rows = 5;
const _contentHeight = 56.0 + _rows * 48.0;

Future<void> _pump(
  WidgetTester tester, {
  required double height,
  required double columnWidth,
  double scale = 1.0,
  TablePlusTheme theme = const TablePlusTheme(),
}) async {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: height,
            child: FlutterTablePlus<Map<String, dynamic>>(
              columns: {
                'name': TablePlusColumn<Map<String, dynamic>>(
                  key: 'name',
                  label: 'Name',
                  order: 0,
                  valueAccessor: (r) => r['name'],
                  width: columnWidth,
                ),
              },
              data: [
                for (int i = 0; i < _rows; i++) {'id': '$i', 'name': 'R$i'},
              ],
              rowId: (r) => r['id'] as String,
              scale: scale,
              theme: theme,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The body's vertical scroll extent: the largest among the vertical
/// Scrollables in the table (the body, and the vertical strip slaved to it).
double _verticalExtent(WidgetTester tester) {
  final states = tester.stateList<ScrollableState>(
    find.byWidgetPredicate(
      (w) =>
          w is Scrollable &&
          axisDirectionToAxis(w.axisDirection) == Axis.vertical,
    ),
  );
  return states
      .map((s) => s.position.maxScrollExtent)
      .fold(0.0, (a, b) => a > b ? a : b);
}

bool _hasVerticalBar(WidgetTester tester) =>
    find.byKey(const ValueKey(Axis.vertical)).evaluate().isNotEmpty;

bool _hasHorizontalBar(WidgetTester tester) =>
    find.byKey(const ValueKey(Axis.horizontal)).evaluate().isNotEmpty;

void main() {
  group('with the horizontal scrollbar shown', () {
    for (final height in [294.0, 296.0, 300.0, 306.0, 307.0]) {
      testWidgets('a $height-tall table scrolls and shows the vertical bar', (
        tester,
      ) async {
        await _pump(tester, height: height, columnWidth: 1000);

        expect(_hasHorizontalBar(tester), isTrue);
        // The body is `height - 56 - 12` tall and holds 240 of rows.
        expect(
          _verticalExtent(tester),
          moreOrLessEquals(_contentHeight + 12 - height),
        );
        expect(
          _hasVerticalBar(tester),
          isTrue,
          reason:
              'the body scrolls by ${_contentHeight + 12 - height}px, so '
              'its vertical scrollbar has to be drawn',
        );
        // The vertical bar spans the body: from under the header down to
        // the top of the horizontal track.
        final bar = tester.getRect(find.byKey(const ValueKey(Axis.vertical)));
        final table = tester.getRect(
          find.byType(FlutterTablePlus<Map<String, dynamic>>),
        );
        expect(bar.top, table.top + 56);
        expect(bar.bottom, table.bottom - 12);
      });
    }

    testWidgets('a 308-tall table neither scrolls nor shows the vertical bar', (
      tester,
    ) async {
      await _pump(tester, height: 308, columnWidth: 1000);

      expect(_hasHorizontalBar(tester), isTrue);
      expect(_verticalExtent(tester), 0);
      expect(_hasVerticalBar(tester), isFalse);
    });

    testWidgets('at scale 2 the reserved track is the one the spacer takes', (
      tester,
    ) async {
      // At scale 2 the content is 112 + 5 * 96 = 592 tall. The spacer takes
      // the scrollbar theme's trackWidth, which `TablePlusTheme.scaledBy`
      // leaves at 12, so the body scrolls below 604.
      await _pump(tester, height: 600, columnWidth: 1000, scale: 2);

      expect(_hasHorizontalBar(tester), isTrue);
      expect(
        tester.getSize(find.byKey(const ValueKey(Axis.horizontal))).height,
        12,
      );
      expect(_verticalExtent(tester), moreOrLessEquals(4));
      expect(_hasVerticalBar(tester), isTrue);

      await _pump(tester, height: 604, columnWidth: 1000, scale: 2);
      expect(_verticalExtent(tester), 0);
      expect(_hasVerticalBar(tester), isFalse);
    });
  });

  group('without horizontal scrolling no track is reserved', () {
    testWidgets('a 296-tall table neither scrolls nor shows the vertical bar', (
      tester,
    ) async {
      await _pump(tester, height: 296, columnWidth: 300);

      expect(_hasHorizontalBar(tester), isFalse);
      expect(_verticalExtent(tester), 0);
      expect(_hasVerticalBar(tester), isFalse);
    });

    testWidgets('a 294-tall table scrolls and shows the vertical bar', (
      tester,
    ) async {
      await _pump(tester, height: 294, columnWidth: 300);

      expect(_verticalExtent(tester), moreOrLessEquals(2));
      expect(_hasVerticalBar(tester), isTrue);
    });
  });

  testWidgets('a hidden horizontal scrollbar reserves no track', (
    tester,
  ) async {
    await _pump(
      tester,
      height: 300,
      columnWidth: 1000,
      theme: const TablePlusTheme(
        scrollbarTheme: TablePlusScrollbarTheme(showHorizontal: false),
      ),
    );

    expect(_hasHorizontalBar(tester), isFalse);
    expect(_verticalExtent(tester), 0);
    expect(_hasVerticalBar(tester), isFalse);
  });

  group('the smart last-row border follows the same decision', () {
    const smart = TablePlusTheme(
      bodyTheme: TablePlusBodyTheme(
        lastRowBorderBehavior: LastRowBorderBehavior.smart,
      ),
    );

    int bottomBorders(WidgetTester tester) => tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).border is Border &&
              ((c.decoration! as BoxDecoration).border! as Border)
                      .bottom
                      .color ==
                  smart.bodyTheme.dividerColor,
        )
        .length;

    testWidgets('in the band the last row draws no bottom border', (
      tester,
    ) async {
      await _pump(tester, height: 300, columnWidth: 1000, theme: smart);
      expect(_verticalExtent(tester), greaterThan(0));
      expect(
        bottomBorders(tester),
        _rows - 1,
        reason: 'the body scrolls, so the smart border leaves the last row',
      );
    });

    testWidgets('when nothing scrolls the last row draws it', (tester) async {
      await _pump(tester, height: 308, columnWidth: 1000, theme: smart);
      expect(_verticalExtent(tester), 0);
      expect(bottomBorders(tester), _rows);
    });
  });
}
