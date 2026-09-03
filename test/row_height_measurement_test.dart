import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// `TableRowHeightCalculator` is the piece a caller cannot compute without doing
// a layout — that is the stated reason it is exported. So it has to measure the
// same string the screen draws, and it was measuring three things differently:
// no text scaler, no ambient `DefaultTextStyle`, and a width that ignored the
// divider a body cell folds into its child's inset.
//
// The conjunction is what matters: a predicted height *and* a paragraph that
// fits inside it. A height assertion alone passes on any number that happens to
// be large enough.

const _v =
    'a reasonably long sentence that will need to wrap onto several lines';
const _bare = TextStyle(fontSize: 14, color: Color(0xFF212121));
const _colW = 220.0;
const _pad = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

TablePlusColumn<Map<String, dynamic>> _col() =>
    TablePlusColumn<Map<String, dynamic>>(
      key: 'note',
      label: 'note',
      order: 0,
      valueAccessor: (r) => r['note'],
      width: _colW,
      minWidth: _colW,
      maxWidth: _colW,
      textOverflow: TextOverflow.visible,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the text scaler participates', () {
    test('a scaled string needs a taller row', () {
      double at(TextScaler s) => TableRowHeightCalculator.calculateTextHeight(
            text: _v,
            textStyle: _bare,
            maxWidth: 188,
            textScaler: s,
          );

      // Derived, never written: the unscaled height is whatever it is, and the
      // scaled one must exceed it.
      expect(at(const TextScaler.linear(1.25)),
          greaterThan(at(TextScaler.noScaling)));
    });
  });

  group('the decoration inset participates', () {
    test('a width the cell does not actually hand out gives a taller row', () {
      double at(double extra) =>
          TableRowHeightCalculator.calculateRowHeight<Map<String, dynamic>>(
            rowData: const {'note': _v},
            columns: [_col()],
            columnWidths: const [_colW],
            defaultTextStyle: _bare,
            cellPadding: _pad,
            extraWidth: extra,
          );

      // Narrower text wraps to at least as many lines. The strict case is the
      // one that matters, so pick an inset big enough to force a line — a half
      // pixel need not, and asserting it would be asserting nothing.
      expect(at(40), greaterThan(at(0)));
      expect(at(0.5), greaterThanOrEqualTo(at(0)));
    });
  });

  testWidgets(
    'a row sized by the helper fits the paragraph the screen actually draws',
    (tester) async {
      late double predicted;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => SizedBox(
              width: 200,
              child: FlutterTablePlus<Map<String, dynamic>>(
                columns: {'note': _col()},
                data: const [
                  {'id': '1', 'note': _v}
                ],
                rowId: (r) => r['id'] as String,
                calculateRowHeight: (i, r) {
                  predicted = TableRowHeightCalculator.createHeightCalculator<
                      Map<String, dynamic>>(
                    columns: [_col()],
                    columnWidths: const [_colW],
                    defaultTextStyle: _bare,
                    cellPadding: _pad,
                    // the two ambient inputs, resolved from the context the
                    // Text will be built in
                    context: context,
                  )(i, r)!;
                  return predicted;
                },
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final para = tester.renderObject<RenderParagraph>(find.text(_v));

      // What the painted style actually needs, measured here rather than
      // written down — the widget-test font is a square per glyph, so any
      // literal would be measuring that font and not the screen.
      final painter = TextPainter(
        text: TextSpan(text: _v, style: para.text.style),
        maxLines: null,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: para.size.width);
      final needs = painter.height;
      painter.dispose();

      expect(para.size.height, greaterThanOrEqualTo(needs),
          reason: 'the paragraph is clipped: the row was sized from a '
              'measurement the glyphs never got');
      expect(predicted, greaterThanOrEqualTo(needs + _pad.vertical));
    },
  );
}
