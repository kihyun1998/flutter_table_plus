import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  b.addColumn(
    'name',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'name',
      label: 'Name',
      order: 0,
      valueAccessor: (r) => r['name'],
      width: 160,
      editable: true,
    ),
  );
  b.addColumn(
    'tag',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'tag',
      label: 'Tag',
      order: 0,
      valueAccessor: (r) => r['tag'],
      width: 160,
    ),
  );
  return b.build();
}

const _data = [
  {'id': '1', 'name': 'Alpha', 'tag': 'T1'},
  {'id': '2', 'name': 'Bravo', 'tag': 'T2'},
  {'id': '3', 'name': 'Charlie', 'tag': 'T3'},
];

/// A table drawn with the factory's theme inside a *light* app, so a colour
/// that reached the screen from the ambient theme instead of from the scheme
/// handed to the factory cannot pass for it.
Future<void> _pump(
  WidgetTester tester,
  ColorScheme scheme, {
  bool isEditable = false,
  bool enableDragSelection = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(),
      home: Scaffold(
        body: FlutterTablePlus<Map<String, dynamic>>(
          columns: _columns(),
          data: _data,
          rowId: (r) => r['id'] as String,
          isSelectable: true,
          selectedRows: const {'2'},
          isEditable: isEditable,
          enableDragSelection: enableDragSelection,
          theme: TablePlusTheme.fromColorScheme(scheme),
          onRowSelectionChanged: (_, __) {},
          onCellChanged: (_, __, ___, ____, _____) {},
          onDragSelectionUpdate: (_) {},
          onDragSelectionEnd: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The colour the row holding [text] is filled with.
Color? _rowFill(WidgetTester tester, String text) {
  final ink = tester.widget<Ink>(
    find.descendant(
      of: find.ancestor(
        of: find.text(text),
        matching: find.byType(CustomInkWell),
      ),
      matching: find.byType(Ink),
    ),
  );
  return (ink.decoration as BoxDecoration?)?.color;
}

/// Every colour a `BoxDecoration` above [text] fills with.
Iterable<Color?> _fillsAbove(WidgetTester tester, String text) => tester
    .widgetList<Container>(
      find.ancestor(of: find.text(text), matching: find.byType(Container)),
    )
    .map((c) => c.decoration)
    .whereType<BoxDecoration>()
    .map((d) => d.color);

void main() {
  final dark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1565C0),
    brightness: Brightness.dark,
  );

  group('fromColorScheme maps each colour to its role', () {
    test('body', () {
      final body = TablePlusTheme.fromColorScheme(dark).bodyTheme;
      expect(body.backgroundColor, dark.surface);
      expect(body.textStyle.color, dark.onSurface);
      expect(body.selectedRowColor, dark.secondaryContainer);
      expect(body.selectedRowTextStyle?.color, dark.onSecondaryContainer);
      expect(body.dividerColor, dark.outlineVariant);
    });

    test('header', () {
      final header = TablePlusTheme.fromColorScheme(dark).headerTheme;
      expect(header.backgroundColor, dark.surfaceContainerHigh);
      expect(header.textStyle.color, dark.onSurface);
      expect(header.textStyle.fontWeight, FontWeight.w600);
      expect(header.bottomBorder.color, dark.outlineVariant);
      // Hidden by default; derived anyway, so turning it on is not a light
      // grey line in a dark table.
      expect(header.topBorder.color, dark.outlineVariant);
      expect(header.verticalDivider.color, dark.outlineVariant);
    });

    test('editing', () {
      final editable = TablePlusTheme.fromColorScheme(dark).editableTheme;
      expect(editable.editingCellColor, dark.primaryContainer);
      expect(editable.editingTextStyle.color, dark.onPrimaryContainer);
      expect(editable.editingBorderColor, dark.primary);
      expect(editable.cursorColor, dark.primary);
      expect(editable.effectiveErrorBorderColor, dark.error);
      // Its null fallback is a literal red, not errorBorderColor, so leaving it
      // null would draw a focused rejected cell in a red the scheme never named.
      expect(editable.effectiveFocusedErrorBorderColor, dark.error);
    });

    test('drag selection', () {
      final drag = TablePlusTheme.fromColorScheme(dark).dragSelectionTheme;
      expect(drag.borderColor, dark.primary);
      expect(drag.fillColor, dark.primary.withAlpha(0x33));
    });

    test('scrollbar', () {
      final scrollbar = TablePlusTheme.fromColorScheme(dark).scrollbarTheme;
      expect(scrollbar.thumbColor, dark.onSurfaceVariant);
      expect(scrollbar.trackColor, dark.surfaceContainerHighest);
    });

    test('tooltip', () {
      final tooltip = TablePlusTheme.fromColorScheme(dark).tooltipTheme;
      expect(tooltip.backgroundColor, dark.inverseSurface);
      expect(tooltip.textStyle.color, dark.onInverseSurface);
      expect(tooltip.textStyle.fontSize, 12);
    });

    test('checkbox', () {
      final style = TablePlusTheme.fromColorScheme(dark).checkboxTheme.style;
      expect(style.activeColor, dark.primary);
      expect(style.checkColor, dark.onPrimary);
      expect(style.borderColor, dark.outline);
      expect(style.size, 18);
    });

    test('the selected row keeps the body text style it replaces', () {
      // A selected row draws selectedRowTextStyle instead of textStyle, not
      // merged over it, so anything but the colour must come from textStyle.
      final body = TablePlusTheme.fromColorScheme(dark).bodyTheme;
      expect(
        body.selectedRowTextStyle,
        const TablePlusBodyTheme().textStyle.copyWith(
          color: dark.onSecondaryContainer,
        ),
      );
    });
  });

  group('what fromColorScheme leaves alone', () {
    test('every value that is not a colour stays at its default', () {
      final t = TablePlusTheme.fromColorScheme(dark);
      const d = TablePlusTheme();
      expect(t.bodyTheme.rowHeight, d.bodyTheme.rowHeight);
      expect(t.bodyTheme.padding, d.bodyTheme.padding);
      expect(t.bodyTheme.dividerThickness, d.bodyTheme.dividerThickness);
      expect(t.bodyTheme.textStyle.fontSize, d.bodyTheme.textStyle.fontSize);
      expect(t.headerTheme.height, d.headerTheme.height);
      expect(t.headerTheme.padding, d.headerTheme.padding);
      expect(t.headerTheme.topBorder.show, isFalse);
      expect(
        t.headerTheme.bottomBorder.thickness,
        d.headerTheme.bottomBorder.thickness,
      );
      expect(
        t.editableTheme.editingBorderWidth,
        d.editableTheme.editingBorderWidth,
      );
      expect(
        t.dragSelectionTheme.borderWidth,
        d.dragSelectionTheme.borderWidth,
      );
      expect(t.scrollbarTheme.trackWidth, d.scrollbarTheme.trackWidth);
      expect(t.tooltipTheme.anchor, d.tooltipTheme.anchor);
      expect(
        t.checkboxTheme.checkboxColumnWidth,
        d.checkboxTheme.checkboxColumnWidth,
      );
      expect(t.rowTooltipTheme, isNull);
      expect(t.headerTooltipTheme, isNull);
    });

    test(
      'nullable colours stay null, so their fallbacks follow the scheme',
      () {
        final body = TablePlusTheme.fromColorScheme(dark).bodyTheme;
        expect(body.alternateRowColor, isNull);
        expect(body.verticalDividerColor, isNull);
        expect(body.memberDividerColor, isNull);
        expect(body.hoverColor, isNull);
      },
    );

    test('the column rule stays split (#177)', () {
      // Header half 1.0 opaque, body half 0.5 at alpha 0.5, both from the
      // one role — the geometry is the default's, only the colour moved.
      final t = TablePlusTheme.fromColorScheme(dark);
      expect(t.headerTheme.verticalDivider.thickness, 1.0);
      expect(
        t.bodyTheme.verticalDividerSide,
        BorderSide(
          color: dark.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      );
    });
  });

  test('a scheme with no hue is followed, not replaced with one', () {
    final mono = ColorScheme.fromSeed(
      seedColor: Colors.black,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
      brightness: Brightness.dark,
    );
    final editable = TablePlusTheme.fromColorScheme(mono).editableTheme;
    // The scheme's primary is white; nothing swaps in a blue for visibility.
    expect(editable.editingBorderColor, const Color(0xFFFFFFFF));
    expect(editable.cursorColor, const Color(0xFFFFFFFF));
  });

  test('scaling keeps every derived colour', () {
    final t = TablePlusTheme.fromColorScheme(dark).scaledBy(2.0);
    expect(t.bodyTheme.rowHeight, const TablePlusBodyTheme().rowHeight * 2);
    expect(t.bodyTheme.backgroundColor, dark.surface);
    expect(t.bodyTheme.selectedRowColor, dark.secondaryContainer);
    expect(t.bodyTheme.selectedRowTextStyle?.color, dark.onSecondaryContainer);
    expect(t.headerTheme.backgroundColor, dark.surfaceContainerHigh);
    expect(t.headerTheme.textStyle.color, dark.onSurface);
    expect(t.editableTheme.editingBorderColor, dark.primary);
    expect(t.editableTheme.editingTextStyle.color, dark.onPrimaryContainer);
    expect(t.dragSelectionTheme.fillColor, dark.primary.withAlpha(0x33));
    expect(t.checkboxTheme.style.activeColor, dark.primary);
    expect(t.checkboxTheme.style.checkColor, dark.onPrimary);
  });

  group('what a table drawn with it shows', () {
    testWidgets('body, selected row and header', (tester) async {
      await _pump(tester, dark);
      expect(_rowFill(tester, 'Alpha'), dark.surface);
      expect(_rowFill(tester, 'Bravo'), dark.secondaryContainer);
      expect(
        tester.widget<Text>(find.text('Bravo')).style?.color,
        dark.onSecondaryContainer,
      );
      expect(
        tester.widget<Text>(find.text('Alpha')).style?.color,
        dark.onSurface,
      );
      expect(_fillsAbove(tester, 'Name'), contains(dark.surfaceContainerHigh));
    });

    testWidgets('the checkbox takes the passed scheme, not the app\'s', (
      tester,
    ) async {
      await _pump(tester, dark);
      final box = tester.widget<FlutterCheckbox>(
        find.byType(FlutterCheckbox).first,
      );
      expect(box.style.activeColor, dark.primary);
      expect(box.style.checkColor, dark.onPrimary);
    });

    testWidgets('an editing cell', (tester) async {
      await _pump(tester, dark, isEditable: true);
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.cursorColor, dark.primary);
      expect(field.decoration!.fillColor, dark.primaryContainer);
      final focused = field.decoration!.focusedBorder! as OutlineInputBorder;
      expect(focused.borderSide.color, dark.primary);
      final focusedError =
          field.decoration!.focusedErrorBorder! as OutlineInputBorder;
      expect(focusedError.borderSide.color, dark.error);
    });

    testWidgets('the drag-selection band', (tester) async {
      await _pump(tester, dark, enableDragSelection: true);
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('T1')),
      );
      await tester.pump();
      // Diagonal: a band with no width paints nothing.
      await gesture.moveTo(tester.getCenter(find.text('Charlie')));
      await tester.pump();
      final band = find.byWidgetPredicate(
        (w) =>
            w is CustomPaint &&
            w.painter.runtimeType.toString() == '_RubberBandPainter',
      );
      expect(band, findsOneWidget);
      expect(
        band,
        paints
          ..rect(color: dark.primary.withAlpha(0x33))
          ..rect(color: dark.primary),
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
