import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A scrollbar strip's thumb is painted from TablePlusScrollbarTheme on every
// platform, iOS included, and a ScrollbarTheme widget around the table does
// not reach it. The margins and minimum lengths are Material's own for the
// platform, as Material's Scrollbar paints them off iOS. The thumb is no
// thicker than its room across the strip, and a MediaQuery padding around
// the table does not move it.

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final builder = TableColumnsBuilder<Map<String, dynamic>>();
  for (int i = 0; i < 8; i++) {
    builder.addColumn(
      'c$i',
      TablePlusColumn<Map<String, dynamic>>(
        key: 'c$i',
        label: 'C$i',
        order: 0,
        valueAccessor: (r) => r['c$i'],
        width: 150,
      ),
    );
  }
  return builder.build();
}

final List<Map<String, dynamic>> _rows = [
  for (int i = 0; i < 100; i++)
    {'id': '$i', for (int j = 0; j < 8; j++) 'c$j': 'r${i}c$j'},
];

const Color _red = Color(0xFFFF0000);
const Color _green = Color(0xFF00FF00);

/// A 400x300 table of 100 rows by 8 columns, so both axes scroll, with
/// [scrollbarTheme] as its scrollbar theme, [ancestor] as a
/// [ScrollbarTheme] around it, and [padding] as the [MediaQuery] padding and
/// view padding around it.
Future<void> _pump(
  WidgetTester tester, {
  required TablePlusScrollbarTheme scrollbarTheme,
  ScrollbarThemeData? ancestor,
  EdgeInsets? padding,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final Widget table = FlutterTablePlus<Map<String, dynamic>>(
    columns: _columns(),
    data: _rows,
    rowId: (r) => r['id'] as String,
    wheelMotion: null,
    theme: TablePlusTheme(scrollbarTheme: scrollbarTheme),
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: Builder(
              builder: (context) {
                final themed = ancestor == null
                    ? table
                    : ScrollbarTheme(data: ancestor, child: table);
                if (padding == null) return themed;
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(padding: padding, viewPadding: padding),
                  child: themed,
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The scroll view a scrollbar strip on [axis] is drawn on: the one under a
/// scrollbar, which the header and the body are not.
Finder _strip(Axis axis) => find.descendant(
  of: find.byWidgetPredicate((w) => w is RawScrollbar),
  matching: find.byWidgetPredicate(
    (w) => w is SingleChildScrollView && w.scrollDirection == axis,
  ),
);

/// The `CustomPaint` that paints the thumb of the strip on [axis].
CustomPaint _thumbPaint(WidgetTester tester, Axis axis) => tester
    .widgetList<CustomPaint>(
      find.ancestor(
        of: _strip(axis),
        matching: find.byWidgetPredicate(
          (w) => w is CustomPaint && w.foregroundPainter is ScrollbarPainter,
        ),
      ),
    )
    .first;

ScrollbarPainter _painter(WidgetTester tester, Axis axis) =>
    _thumbPaint(tester, axis).foregroundPainter! as ScrollbarPainter;

/// Material's cross-axis margin for the platform: none on Android, 2
/// elsewhere (`_kScrollbarMargin`, Flutter 3.47.1).
double _materialMargin() =>
    defaultTargetPlatform == TargetPlatform.android ? 0.0 : 2.0;

/// Checks the thumb of the strip on [axis] against a theme of thickness 6,
/// radius 1 and [_red], with Material's margins and minimum lengths.
void _expectThemedThumb(WidgetTester tester, Axis axis) {
  final painter = _painter(tester, axis);
  expect(painter.thickness, 6);
  expect(painter.radius, const Radius.circular(1));
  expect(painter.color, _red);
  expect(painter.crossAxisMargin, _materialMargin());
  expect(painter.mainAxisMargin, 0);
  expect(painter.minLength, 48);
  expect(painter.minOverscrollLength, 18);

  // The thumb as painted: a shape of the theme's colour, as thick as the
  // theme says, set in from the far edge of the 12 px track by the margin.
  // The framework paints it, so either canvas call is accepted.
  final margin = _materialMargin();
  expect(
    find.byWidget(_thumbPaint(tester, axis)),
    paints..something((method, arguments) {
      final Rect rect;
      if (method == #drawRRect) {
        rect = (arguments[0] as RRect).outerRect;
      } else if (method == #drawRect) {
        rect = arguments[0] as Rect;
      } else {
        return false;
      }
      final paint = arguments[1] as Paint;
      final (near, far) = axis == Axis.vertical
          ? (rect.left, rect.right)
          : (rect.top, rect.bottom);
      return paint.color == _red &&
          near == 12 - 6 - margin &&
          far == 12 - margin;
    }),
  );
}

/// Checks that the thumb of the strip on [axis] is painted [thickness] thick,
/// at Material's margin for the platform, ending at the far edge of the room
/// across the strip less that margin.
void _expectCappedThumb(
  WidgetTester tester,
  Axis axis, {
  required double room,
  required double thickness,
}) {
  final margin = _materialMargin();
  final painter = _painter(tester, axis);
  expect(painter.thickness, thickness);
  expect(painter.crossAxisMargin, margin);
  final size = tester.getSize(find.byWidget(_thumbPaint(tester, axis)));
  expect(axis == Axis.vertical ? size.width : size.height, room);
  expect(
    find.byWidget(_thumbPaint(tester, axis)),
    paints..something((method, arguments) {
      final Rect rect;
      if (method == #drawRRect) {
        rect = (arguments[0] as RRect).outerRect;
      } else if (method == #drawRect) {
        rect = arguments[0] as Rect;
      } else {
        return false;
      }
      final paint = arguments[1] as Paint;
      final (near, far) = axis == Axis.vertical
          ? (rect.left, rect.right)
          : (rect.top, rect.bottom);
      return paint.color == _red &&
          near == room - thickness - margin &&
          far == room - margin;
    }),
  );
}

/// The rect of the thumb of the strip on [axis], as painted, in the
/// painter's coordinates.
Rect _thumbRect(WidgetTester tester, Axis axis) {
  Rect? painted;
  expect(
    find.byWidget(_thumbPaint(tester, axis)),
    paints..something((method, arguments) {
      final Rect rect;
      if (method == #drawRRect) {
        rect = (arguments[0] as RRect).outerRect;
      } else if (method == #drawRect) {
        rect = arguments[0] as Rect;
      } else {
        return false;
      }
      if ((arguments[1] as Paint).color != _red) return false;
      painted = rect;
      return true;
    }),
  );
  return painted!;
}

const _theme = TablePlusScrollbarTheme(
  thickness: 6,
  radius: 1,
  thumbColor: _red,
);

const _platforms = TargetPlatformVariant({
  TargetPlatform.iOS,
  TargetPlatform.android,
  TargetPlatform.windows,
});

void main() {
  for (final axis in Axis.values) {
    testWidgets('the $axis thumb is painted from TablePlusScrollbarTheme', (
      tester,
    ) async {
      await _pump(tester, scrollbarTheme: _theme);
      _expectThemedThumb(tester, axis);
    }, variant: _platforms);

    testWidgets(
      'a ScrollbarTheme around the table does not restyle the $axis thumb',
      (tester) async {
        await _pump(
          tester,
          scrollbarTheme: _theme,
          ancestor: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(_green),
            thickness: WidgetStateProperty.all(1),
            radius: const Radius.circular(9),
            crossAxisMargin: 5,
            mainAxisMargin: 7,
            minThumbLength: 20,
          ),
        );
        _expectThemedThumb(tester, axis);
      },
      variant: _platforms,
    );
  }

  for (final axis in Axis.values) {
    testWidgets('MediaQuery padding does not move the $axis thumb', (
      tester,
    ) async {
      await _pump(tester, scrollbarTheme: _theme);
      final unpadded = _thumbRect(tester, axis);
      await _pump(
        tester,
        scrollbarTheme: _theme,
        padding: const EdgeInsets.fromLTRB(20, 30, 40, 50),
      );
      expect(_thumbRect(tester, axis), unpadded);
    }, variant: _platforms);
  }

  // Each case: the theme's thickness and track border, the room across the
  // strip inside that border, and the thickness painted off Android (margin
  // 2) and on Android (margin 0), worked out by hand from a 12 px track. A
  // border takes as much of the track as it is drawn inside it: all of its
  // width by default, half with strokeAlignCenter, none with
  // strokeAlignOutside.
  final cases = <(String, double?, Border?, double, double, double)>[
    ('thickness 12, no border', 12, null, 12, 10, 12),
    (
      'the default thickness, Border.all(width: 2)',
      null,
      Border.all(width: 2),
      8,
      6,
      8,
    ),
    ('thickness 10, Border.all(width: 1)', 10, Border.all(width: 1), 10, 8, 10),
    (
      'thickness 12, Border.all(width: 5.5)',
      12,
      Border.all(width: 5.5),
      1,
      0,
      1,
    ),
    (
      'thickness 12, Border.all(width: 2) drawn centred on the edge',
      12,
      Border.all(width: 2, strokeAlign: BorderSide.strokeAlignCenter),
      10,
      8,
      10,
    ),
    (
      'thickness 12, Border.all(width: 2) drawn outside the edge',
      12,
      Border.all(width: 2, strokeAlign: BorderSide.strokeAlignOutside),
      12,
      10,
      12,
    ),
  ];
  for (final axis in Axis.values) {
    for (final (name, thickness, border, room, elsewhere, android) in cases) {
      testWidgets('the $axis thumb fits inside its track: $name', (
        tester,
      ) async {
        await _pump(
          tester,
          scrollbarTheme: TablePlusScrollbarTheme(
            thickness: thickness,
            radius: 1,
            thumbColor: _red,
            trackBorder: border,
          ),
        );
        _expectCappedThumb(
          tester,
          axis,
          room: room,
          thickness: defaultTargetPlatform == TargetPlatform.android
              ? android
              : elsewhere,
        );
      }, variant: _platforms);
    }

    testWidgets(
      'the $axis thumb is capped by the border on its own cross axis only',
      (tester) async {
        const border = Border(left: BorderSide(width: 3));
        await _pump(
          tester,
          scrollbarTheme: const TablePlusScrollbarTheme(
            thickness: 12,
            radius: 1,
            thumbColor: _red,
            trackBorder: border,
          ),
        );
        final room = axis == Axis.vertical ? 9.0 : 12.0;
        _expectCappedThumb(
          tester,
          axis,
          room: room,
          thickness: room - _materialMargin(),
        );
      },
      variant: _platforms,
    );
  }
}
