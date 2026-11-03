import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// #209. The header's top and bottom borders stay visible over header cells
// that paint an opaque background. Observed as pixels: the colour at the
// header's first and last rows, in an ordinary header cell and in the
// selection header cell, which paint their own fills independently.

const _fill = Color(0xFF00FF00);
const _top = Color(0xFFFF0000);
const _bottom = Color(0xFF0000FF);
const _headerHeight = 40.0;
const _thickness = 2.0;
const _boundaryKey = Key('boundary');

Widget _table(TablePlusHeaderTheme headerTheme) => MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: RepaintBoundary(
        key: _boundaryKey,
        child: SizedBox(
          width: 400,
          height: 200,
          child: FlutterTablePlus<Map<String, dynamic>>(
            columns: {
              'a': TablePlusColumn<Map<String, dynamic>>(
                key: 'a',
                label: 'A',
                order: 0,
                valueAccessor: (r) => r['a'],
                width: 200,
                minWidth: 200,
                maxWidth: 200,
              ),
            },
            data: const [
              {'id': '1', 'a': 'a1'},
            ],
            rowId: (r) => r['id'] as String,
            isSelectable: true,
            onRowSelectionChanged: (_, _) {},
            theme: TablePlusTheme(headerTheme: headerTheme),
          ),
        ),
      ),
    ),
  ),
);

/// The colour at (x, y) in logical pixels of the captured table.
Future<Color> Function(double x, double y) _sampler(WidgetTester tester) =>
    (x, y) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(_boundaryKey),
      );
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final width = image.width;
        image.dispose();
        return (data!, width);
      });
      final (data, width) = bytes!;
      final offset = (y.floor() * width + x.floor()) * 4;
      return Color.fromARGB(
        data.getUint8(offset + 3),
        data.getUint8(offset),
        data.getUint8(offset + 1),
        data.getUint8(offset + 2),
      );
    };

/// x of a point inside the selection header cell, and inside the ordinary
/// header cell, clear of the checkbox and the label.
(double, double) _columnXs(WidgetTester tester) {
  final label = tester.getRect(find.text('A'));
  return (2.0, label.right + 40);
}

Future<void> _expectBordersPainted(WidgetTester tester) async {
  final sample = _sampler(tester);
  final (selectionX, cellX) = _columnXs(tester);
  for (final x in [selectionX, cellX]) {
    expect(await sample(x, 0.5), _top, reason: 'top border at x=$x');
    expect(
      await sample(x, _headerHeight - 0.5),
      _bottom,
      reason: 'bottom border at x=$x',
    );
    // The fill is still painted between them: the borders are drawn over the
    // cells, not instead of them.
    expect(await sample(x, _headerHeight / 2), _fill, reason: 'fill at x=$x');
  }
}

void main() {
  testWidgets('topBorder and bottomBorder are painted over opaque cells', (
    tester,
  ) async {
    await tester.pumpWidget(
      _table(
        const TablePlusHeaderTheme(
          height: _headerHeight,
          backgroundColor: _fill,
          topBorder: TablePlusHeaderBorderTheme(
            color: _top,
            thickness: _thickness,
          ),
          bottomBorder: TablePlusHeaderBorderTheme(
            color: _bottom,
            thickness: _thickness,
          ),
          verticalDivider: TablePlusHeaderDividerTheme(show: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expectBordersPainted(tester);
  });

  testWidgets('a bottomBorder alone is painted over opaque cells', (
    tester,
  ) async {
    await tester.pumpWidget(
      _table(
        const TablePlusHeaderTheme(
          height: _headerHeight,
          backgroundColor: _fill,
          topBorder: TablePlusHeaderBorderTheme(show: false),
          bottomBorder: TablePlusHeaderBorderTheme(
            color: _bottom,
            thickness: _thickness,
          ),
          verticalDivider: TablePlusHeaderDividerTheme(show: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final sample = _sampler(tester);
    final (selectionX, cellX) = _columnXs(tester);
    for (final x in [selectionX, cellX]) {
      expect(await sample(x, 0.5), _fill, reason: 'no top border at x=$x');
      expect(
        await sample(x, _headerHeight - 0.5),
        _bottom,
        reason: 'bottom border at x=$x',
      );
    }
  });

  testWidgets('a caller BoxDecoration border is painted over opaque cells', (
    tester,
  ) async {
    await tester.pumpWidget(
      _table(
        const TablePlusHeaderTheme(
          height: _headerHeight,
          backgroundColor: _fill,
          decoration: BoxDecoration(
            color: _fill,
            border: Border(
              top: BorderSide(color: _top, width: _thickness),
              bottom: BorderSide(color: _bottom, width: _thickness),
            ),
          ),
          verticalDivider: TablePlusHeaderDividerTheme(show: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expectBordersPainted(tester);
  });

  testWidgets('a caller border keeps the rounded corners of its decoration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _table(
        TablePlusHeaderTheme(
          height: _headerHeight,
          backgroundColor: _fill,
          decoration: BoxDecoration(
            border: Border.all(color: _top, width: _thickness),
            borderRadius: BorderRadius.circular(12),
          ),
          verticalDivider: const TablePlusHeaderDividerTheme(show: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final sample = _sampler(tester);
    final (_, cellX) = _columnXs(tester);
    expect(await sample(cellX, 0.5), _top, reason: 'straight top edge');
    // The corner lies outside the rounded stroke, so what shows there is the
    // cell's own fill; a square border would put its colour there.
    expect(await sample(0.5, 0.5), _fill, reason: 'rounded corner');
  });
}
