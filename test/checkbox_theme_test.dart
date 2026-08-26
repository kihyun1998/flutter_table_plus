import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Pure-logic coverage for TablePlusCheckboxTheme: the colored() factory, the
// field-preserving copyWith, dimension scaling, and buildCheckbox wiring.

void main() {
  group('colored factory', () {
    test('applies the colors and size to the checkbox style', () {
      final theme = TablePlusCheckboxTheme.colored(
        activeColor: const Color(0xFF00FF00),
        checkColor: const Color(0xFFFFFFFF),
        borderColor: const Color(0xFF000000),
        size: 24,
      );
      expect(theme.style.activeColor, const Color(0xFF00FF00));
      expect(theme.style.checkColor, const Color(0xFFFFFFFF));
      expect(theme.style.borderColor, const Color(0xFF000000));
      expect(theme.style.size, 24);
    });

    test('carries through the layout flags', () {
      final theme = TablePlusCheckboxTheme.colored(
        showCheckboxColumn: false,
        showSelectAllCheckbox: false,
        showRowCheckbox: false,
        cellTapTogglesCheckbox: true,
        checkboxColumnWidth: 80,
      );
      expect(theme.showCheckboxColumn, isFalse);
      expect(theme.showSelectAllCheckbox, isFalse);
      expect(theme.showRowCheckbox, isFalse);
      expect(theme.cellTapTogglesCheckbox, isTrue);
      expect(theme.checkboxColumnWidth, 80);
    });
  });

  group('copyWith', () {
    test('replaces only the named field', () {
      const theme = TablePlusCheckboxTheme(checkboxColumnWidth: 60);
      final copy = theme.copyWith(checkboxColumnWidth: 90);
      expect(copy.checkboxColumnWidth, 90);
      expect(copy.showCheckboxColumn, isTrue); // preserved default
    });
  });

  group('scaledBy', () {
    test('scales the column width and the style scale', () {
      const theme = TablePlusCheckboxTheme(checkboxColumnWidth: 60);
      final scaled = theme.scaledBy(2.0);
      expect(scaled.checkboxColumnWidth, 120.0);
      expect(scaled.style.scale, theme.style.scale * 2.0);
    });

    test('returns the same instance for a factor of 1.0', () {
      const theme = TablePlusCheckboxTheme();
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });

  group('buildCheckbox', () {
    test('is disabled when onChanged is null', () {
      final widget = const TablePlusCheckboxTheme()
          .buildCheckbox(value: true, onChanged: null) as FlutterCheckbox;
      expect(widget.enabled, isFalse);
      expect(widget.value, isTrue);
    });

    test('is enabled and can be tristate when a handler is given', () {
      final widget = const TablePlusCheckboxTheme().buildCheckbox(
        value: null,
        onChanged: (_) {},
        tristate: true,
      ) as FlutterCheckbox;
      expect(widget.enabled, isTrue);
      expect(widget.tristate, isTrue);
    });
  });

  group('the style survives the trip through a real table', () {
    // The tests above are pure. This one is the round trip: a caller's style
    // has to travel `FlutterTablePlus.scale` -> `TablePlusTheme.scaledBy` ->
    // this class's `scaledBy` -> `buildCheckbox` -> the `FlutterCheckbox`
    // widget, and it is the whole trip that was broken. A pure assertion on
    // `scaledBy` would have caught the defect; only this one shows a rendered
    // checkbox actually wearing what the caller asked for.
    //
    // `checkScale` is the field to read: it is a plain double with a
    // non-default value, it was one of the five that were being dropped, and
    // `scaledBy` does not touch it — so at scale 2.0 it must still be 0.42.
    testWidgets('a table at scale 2.0 renders the style the caller asked for',
        (tester) async {
      final columns = (TableColumnsBuilder<Map<String, dynamic>>()
            ..addColumn(
              'name',
              TablePlusColumn<Map<String, dynamic>>(
                key: 'name',
                label: 'Name',
                order: 0,
                valueAccessor: (r) => r['name'],
              ),
            ))
          .build();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: columns,
              data: const [
                {'id': '1', 'name': 'a'}
              ],
              rowId: (r) => r['id'] as String,
              isSelectable: true,
              scale: 2.0,
              theme: const TablePlusTheme(
                checkboxTheme: TablePlusCheckboxTheme(
                  style: CheckboxStyle(
                    // 1.5, not the default 1.0, so the assertion below can tell
                    // `scale * factor` from `scale = factor`. At the default
                    // both give 2.0 and the check is vacuous — measured: a
                    // mutation replacing the multiply passed this whole file.
                    scale: 1.5,
                    checkScale: 0.42,
                    hoverColor: Color(0xFF050505),
                    disabledOpacity: 0.17,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final boxes = tester
          .widgetList<FlutterCheckbox>(find.byType(FlutterCheckbox))
          .toList();
      expect(boxes, isNotEmpty,
          reason: 'no checkbox rendered — the test proves nothing');

      for (final box in boxes) {
        expect(box.style.checkScale, 0.42);
        expect(box.style.hoverColor, const Color(0xFF050505));
        expect(box.style.disabledOpacity, 0.17);
        // The one field the factor is allowed to move. It also proves the
        // checkbox observed came through the *scaled* theme rather than
        // `widget.theme`, which is what makes the assertions above meaningful.
        expect(box.style.scale, 3.0); // 1.5 * 2
      }
    });
  });
}
