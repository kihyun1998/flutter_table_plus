import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// `TooltipBehavior.onlyTextOverflow` exists to show the full value when the
// cell cuts it off. The failure it can have is the one that deletes its whole
// point: the text is clipped on screen and no tooltip is offered.
//
// Both cases below are conjunctions — clipped *and* a tooltip — because either
// half alone passes for the wrong reason. A tooltip assertion with no clipping
// check passes on a column that was simply too narrow to be interesting, and a
// clipping check with no tooltip assertion tests the renderer rather than this
// package.
//
// Every expected width here is derived from a TextPainter at run time. The
// widget-test font is a square per glyph, so a literal would be measuring that
// font and not the screen.

const _value = 'Wide';

Widget _table({
  required double columnWidth,
  TextScaler scaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          // Boxed narrower than the column's own width, so the resolver has no
          // leftover space to hand out and the pin below is the real width. A
          // declared width is a preference, not a width.
          child: SizedBox(
            width: 60,
            child: FlutterTablePlus<Map<String, dynamic>>(
              columns: {
                'note': TablePlusColumn<Map<String, dynamic>>(
                  key: 'note',
                  label: 'note',
                  order: 0,
                  valueAccessor: (r) => r['note'],
                  width: columnWidth,
                  minWidth: columnWidth,
                  maxWidth: columnWidth,
                  tooltipBehavior: TooltipBehavior.onlyTextOverflow,
                ),
              },
              data: const [
                {'id': '1', 'note': _value}
              ],
              rowId: (r) => r['id'] as String,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The style the glyphs are actually painted with, read off the render tree —
/// it carries the ambient Material family, `letterSpacing` and `height`, none
/// of which the package's own theme style names.
TextStyle _paintedStyle(WidgetTester tester) =>
    tester.renderObject<RenderParagraph>(find.text(_value)).text.style!;

double _needs(TextStyle style, {TextScaler scaler = TextScaler.noScaling}) {
  final p = TextPainter(
    text: TextSpan(text: _value, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout(maxWidth: double.infinity);
  final w = p.width;
  p.dispose();
  return w;
}

bool _isClipped(WidgetTester tester, double needs) =>
    tester.renderObject<RenderParagraph>(find.text(_value)).size.width < needs;

Future<void> _hoverText(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await tester.pump();
  await mouse.moveTo(tester.getCenter(find.text(_value).first));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

void main() {
  // Default body padding is symmetric(horizontal: 16).
  const padding = 32.0;

  testWidgets(
    'a cell clipped by the divider\'s own inset still offers a tooltip',
    (tester) async {
      // Measure first, at a width wide enough that nothing is clipped.
      await tester.pumpWidget(_table(columnWidth: 200));
      await tester.pumpAndSettle();
      final needs = _needs(_paintedStyle(tester));

      // Put the declared inner width a quarter-pixel *above* what the glyphs
      // need, so the only thing that clips the text is the 0.5px the vertical
      // divider's border folds into the child's inset. Before this fix the
      // detector was told the declared inner width and answered "fits".
      await tester.pumpWidget(_table(columnWidth: needs + padding + 0.25));
      await tester.pumpAndSettle();

      expect(_isClipped(tester, needs), isTrue,
          reason: 'the case is only meaningful if the text is actually cut');

      await _hoverText(tester);
      // The value appears twice: once in the cell, once in the tooltip.
      expect(find.text(_value), findsNWidgets(2));
    },
  );

  testWidgets(
    'the same cell at a non-default text scale offers a tooltip',
    (tester) async {
      const scaler = TextScaler.linear(1.25);

      await tester.pumpWidget(_table(columnWidth: 200, scaler: scaler));
      await tester.pumpAndSettle();
      final style = _paintedStyle(tester);

      // A width that fits the *unscaled* string with room to spare, so nothing
      // but the scaler can clip it. A test left at TextScaler.noScaling cannot
      // fail for this — the default is the value at which the defect is
      // invisible.
      final width = _needs(style) + padding + 2;
      final scaledNeeds = _needs(style, scaler: scaler);
      expect(scaledNeeds, greaterThan(width - padding),
          reason: 'the scaled string must not fit, or the case tests nothing');

      await tester.pumpWidget(_table(columnWidth: width, scaler: scaler));
      await tester.pumpAndSettle();

      expect(_isClipped(tester, scaledNeeds), isTrue);

      await _hoverText(tester);
      expect(find.text(_value), findsNWidgets(2));
    },
  );

  // The third call site. #155 routed a group's *member* cells through the
  // ordinary cell, so they inherit whatever it does; the **spanning** cell kept
  // its own copy of this measurement and needs its own case. Without one, a
  // third of the sites this change touched would ship with no assertion able to
  // observe it.
  testWidgets(
    'a merged group\'s spanning cell offers a tooltip when its text is cut',
    (tester) async {
      Widget table(double columnWidth) => MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 60,
                child: FlutterTablePlus<Map<String, dynamic>>(
                  columns: {
                    'note': TablePlusColumn<Map<String, dynamic>>(
                      key: 'note',
                      label: 'note',
                      order: 0,
                      valueAccessor: (r) => r['note'],
                      width: columnWidth,
                      minWidth: columnWidth,
                      maxWidth: columnWidth,
                      tooltipBehavior: TooltipBehavior.onlyTextOverflow,
                    ),
                  },
                  data: const [
                    {'id': '1', 'note': _value},
                    {'id': '2', 'note': _value},
                  ],
                  rowId: (r) => r['id'] as String,
                  mergedGroups: const [
                    MergedRowGroup<Map<String, dynamic>>(
                      groupId: 'g',
                      rowKeys: ['1', '2'],
                      mergeConfig: {
                        'note': MergeCellConfig(
                          shouldMerge: true,
                          spanningRowIndex: 0,
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          );

      await tester.pumpWidget(table(200));
      await tester.pumpAndSettle();
      // One spanning cell across two rows, so the value is drawn once.
      expect(find.text(_value), findsOneWidget);
      final needs = _needs(_paintedStyle(tester));

      await tester.pumpWidget(table(needs + padding + 0.25));
      await tester.pumpAndSettle();

      expect(_isClipped(tester, needs), isTrue,
          reason: 'the case is only meaningful if the text is actually cut');

      await _hoverText(tester);
      expect(find.text(_value), findsNWidgets(2));
    },
  );

  // The two causes above are not separable in the cell: measured, neither the
  // inset nor the merge repairs that case alone, so a test of it reddens when
  // either is turned off and isolates neither.
  //
  // The header is where they come apart. It draws its divider as a Positioned
  // overlay rather than a border, so nothing is folded into its child's inset
  // and the inset term is zero — leaving the inherited style as the only thing
  // that can move the answer.
  testWidgets(
    'a header clipped only by the inherited style still offers a tooltip',
    (tester) async {
      const label = 'Header';
      const bare = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

      Widget header(double columnWidth) => MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 60,
                child: FlutterTablePlus<Map<String, dynamic>>(
                  columns: {
                    'note': TablePlusColumn<Map<String, dynamic>>(
                      key: 'note',
                      label: label,
                      order: 0,
                      valueAccessor: (r) => r['note'],
                      width: columnWidth,
                      minWidth: columnWidth,
                      maxWidth: columnWidth,
                      headerTooltipBehavior: TooltipBehavior.onlyTextOverflow,
                    ),
                  },
                  data: const [
                    {'id': '1', 'note': 'x'}
                  ],
                  rowId: (r) => r['id'] as String,
                ),
              ),
            ),
          );

      await tester.pumpWidget(header(400));
      await tester.pumpAndSettle();

      final painted =
          tester.renderObject<RenderParagraph>(find.text(label)).text.style!;
      double needs(TextStyle s) {
        final p = TextPainter(
          text: TextSpan(text: label, style: s),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.infinity);
        final w = p.width;
        p.dispose();
        return w;
      }

      // The band between what the package's own style needs and what the
      // painted (ambient-merged) style needs. The header theme's style is what
      // the detector used to measure; the painted one carries the family and
      // letter-spacing it never named.
      final bareNeeds = needs(bare);
      final paintedNeeds = needs(painted);
      expect(paintedNeeds, greaterThan(bareNeeds),
          reason: 'no band means this case cannot observe the merge');

      const padding = 32.0; // TablePlusHeaderTheme default symmetric(h: 16)
      final width = (bareNeeds + paintedNeeds) / 2 + padding;

      await tester.pumpWidget(header(width));
      await tester.pumpAndSettle();

      expect(
        tester.renderObject<RenderParagraph>(find.text(label)).size.width <
            paintedNeeds,
        isTrue,
        reason: 'the label must actually be cut for this to mean anything',
      );

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text(label).first));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text(label), findsNWidgets(2));
    },
  );
}
