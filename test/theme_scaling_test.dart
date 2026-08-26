import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// copyWith / scaledBy coverage for the remaining theme classes. scaledBy has a
// consistent contract across the family: multiply dimensional values by the
// factor, leave colors/flags/durations alone, and return the same instance for
// factor 1.0. Expected values are hand-derived from documented defaults.

void main() {
  group('TablePlusHeaderTheme', () {
    const theme = TablePlusHeaderTheme();

    test('scaledBy scales dimensions but not colors/borders', () {
      final s = theme.scaledBy(2.0);
      expect(s.height, 112); // 56 * 2
      expect(s.textStyle.fontSize, 28); // 14 * 2
      expect(s.padding, const EdgeInsets.symmetric(horizontal: 32));
      expect(s.sortIconSpacing, 8); // 4 * 2
      expect(s.sortIconWidth, 32); // 16 * 2
      expect(s.resizeHandle.width, 16); // 8 * 2
      expect(s.backgroundColor, theme.backgroundColor);
      expect(s.bottomBorder.thickness, theme.bottomBorder.thickness);
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });

    test('copyWith replaces only the named field', () {
      final c = theme.copyWith(height: 80);
      expect(c.height, 80);
      expect(c.backgroundColor, theme.backgroundColor);
    });
  });

  group('TablePlusHeaderTheme resize handle', () {
    // The same guard one class over. Nothing is dropped here today — all five
    // fields happen to be listed — so this test passes before the fix as well
    // as after it. It is written anyway, because "happens to be complete" is
    // the state a hand-list is in right up until someone adds a field, and
    // `color` is the one that makes the handle visible at all.
    const theme = TablePlusHeaderTheme(
      resizeHandle: TablePlusResizeHandleTheme(
        width: 10,
        color: Color(0xFF0A0A0A),
        thickness: 3,
        indent: 5,
        endIndent: 7,
      ),
    );

    test('scaledBy scales the handle geometry and nothing else', () {
      final h = theme.scaledBy(2.0).resizeHandle;
      expect(h.width, 20);
      expect(h.indent, 10);
      expect(h.endIndent, 14);
      expect(h.color, const Color(0xFF0A0A0A));
      expect(h.thickness, 3);
    });
  });

  group('header sub-theme copyWith', () {
    test('border / divider / resize handle preserve unspecified fields', () {
      const border = TablePlusHeaderBorderTheme();
      expect(border.copyWith(show: false).show, isFalse);
      expect(border.copyWith(show: false).color, border.color);

      const divider = TablePlusHeaderDividerTheme();
      expect(divider.copyWith(indent: 5).indent, 5);
      expect(divider.copyWith(indent: 5).thickness, divider.thickness);

      const handle = TablePlusResizeHandleTheme();
      expect(handle.copyWith(width: 20).width, 20);
      expect(handle.copyWith(width: 20).thickness, handle.thickness);
    });
  });

  group('TablePlusCheckboxTheme', () {
    // A regression guard, not a semantic one. #50/#52 recorded the difference:
    // "leaves an unset field unset" passes with the fix removed, because a
    // dropped nullable is null either way. So every field here is set to a
    // NON-default value, and the assertion is that it comes back unchanged.
    //
    // `scaledBy` changes exactly two things — `style.scale` and
    // `checkboxColumnWidth`. Everything below is the rest of `CheckboxStyle`,
    // which is `flutter_checkbox`'s type and therefore grows when that package
    // ships. Neither `CheckboxStyle` nor this theme implements `==`, so there
    // is no way to write an assertion that catches a field added upstream
    // tomorrow; that is what `copyWith` is for, and this test only pins the
    // fields that exist today.
    const style = CheckboxStyle(
      shape: CheckboxShape.circle,
      size: 30,
      scale: 1.5,
      activeColor: Color(0xFF010101),
      checkColor: Color(0xFF020202),
      borderColor: Color(0xFF030303),
      inactiveColor: Color(0xFF040404),
      borderWidth: 3,
      borderRadius: 7,
      checkStrokeWidth: 3.5,
      checkScale: 0.42,
      hoverRingPadding: 9,
      hoverRingShape: CheckboxShape.rectangle,
      hoverRingBorderRadius: 11,
      hoverColor: Color(0xFF050505),
      focusColor: Color(0xFF060606),
      splashColor: Color(0xFF070707),
      disabledOpacity: 0.17,
      animationDuration: Duration(milliseconds: 321),
      animationCurve: Curves.bounceIn,
      morphDuration: Duration(milliseconds: 123),
      morphCurve: Curves.elasticOut,
    );
    // Every outer field is non-default too, and for the same reason. The first
    // version of this fixture left them at their defaults, and a mutation
    // replacing the outer `copyWith` with a fresh `TablePlusCheckboxTheme(...)`
    // — dropping five layout flags at every factor but 1.0 — passed all 401
    // tests. Measured 2026-08-26. The #50/#52 lesson had been applied
    // meticulously to `CheckboxStyle` and not at all to the class holding it.
    const theme = TablePlusCheckboxTheme(
      style: style,
      checkboxColumnWidth: 44,
      mouseCursor: SystemMouseCursors.grab,
      showCheckboxColumn: false,
      showSelectAllCheckbox: false,
      cellTapTogglesCheckbox: true,
      showRowCheckbox: false,
    );

    test('scaledBy carries every unscaled style field through untouched', () {
      final s = theme.scaledBy(2.0).style;

      expect(s.shape, CheckboxShape.circle);
      expect(s.size, 30);
      expect(s.activeColor, const Color(0xFF010101));
      expect(s.checkColor, const Color(0xFF020202));
      expect(s.borderColor, const Color(0xFF030303));
      expect(s.inactiveColor, const Color(0xFF040404));
      expect(s.borderWidth, 3);
      expect(s.borderRadius, 7);
      expect(s.checkStrokeWidth, 3.5);
      expect(s.checkScale, 0.42);
      expect(s.hoverRingPadding, 9);
      expect(s.hoverRingShape, CheckboxShape.rectangle);
      expect(s.hoverRingBorderRadius, 11);
      expect(s.hoverColor, const Color(0xFF050505));
      expect(s.focusColor, const Color(0xFF060606));
      expect(s.splashColor, const Color(0xFF070707));
      expect(s.disabledOpacity, 0.17);
      expect(s.animationDuration, const Duration(milliseconds: 321));
      expect(s.animationCurve, Curves.bounceIn);
      expect(s.morphDuration, const Duration(milliseconds: 123));
      expect(s.morphCurve, Curves.elasticOut);
    });

    test('scaledBy carries the outer layout fields through untouched', () {
      final s = theme.scaledBy(2.0);
      expect(s.mouseCursor, SystemMouseCursors.grab);
      expect(s.showCheckboxColumn, isFalse);
      expect(s.showSelectAllCheckbox, isFalse);
      expect(s.cellTapTogglesCheckbox, isTrue);
      expect(s.showRowCheckbox, isFalse);
    });

    test('scaledBy scales the two things it is for', () {
      final s = theme.scaledBy(2.0);
      expect(s.style.scale, 3.0); // 1.5 * 2
      expect(s.checkboxColumnWidth, 88); // 44 * 2
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });

  group('TablePlusEditableTheme', () {
    const theme = TablePlusEditableTheme();

    test('scaledBy scales font, border width, and paddings only', () {
      final s = theme.scaledBy(2.0);
      expect(s.editingTextStyle.fontSize, 28); // 14 * 2
      expect(s.editingBorderWidth, 4); // 2 * 2
      expect(s.textFieldPadding,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      expect(s.cellContainerPadding, const EdgeInsets.all(16));
      expect(s.editingCellColor, theme.editingCellColor);
      expect(s.editingBorderRadius, theme.editingBorderRadius);
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });

  group('TablePlusDragSelectionTheme', () {
    const theme = TablePlusDragSelectionTheme();

    test('scaledBy scales only the border width', () {
      final s = theme.scaledBy(3.0);
      expect(s.borderWidth, 3); // 1 * 3
      expect(s.fillColor, theme.fillColor);
      expect(s.borderColor, theme.borderColor);
      expect(s.show, theme.show);
      expect(s.borderRadius, theme.borderRadius);
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });

    test('copyWith replaces only the named field', () {
      expect(theme.copyWith(show: false).show, isFalse);
      expect(theme.copyWith(show: false).fillColor, theme.fillColor);
    });
  });

  group('TablePlusScrollbarTheme', () {
    test('scaledBy scales trackWidth and leaves null thickness/radius null',
        () {
      const theme = TablePlusScrollbarTheme();
      final s = theme.scaledBy(2.0);
      expect(s.trackWidth, 24); // 12 * 2
      expect(s.thickness, isNull);
      expect(s.radius, isNull);
      expect(s.thumbColor, theme.thumbColor);
      expect(s.opacity, theme.opacity);
    });

    test('scaledBy scales explicit thickness and radius', () {
      const theme = TablePlusScrollbarTheme(thickness: 6, radius: 4);
      final s = theme.scaledBy(2.0);
      expect(s.thickness, 12);
      expect(s.radius, 8);
    });

    test('scaledBy(1.0) returns the same instance', () {
      const theme = TablePlusScrollbarTheme();
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });

  group('TablePlusHoverButtonTheme', () {
    const theme = TablePlusHoverButtonTheme();

    test('scaledBy scales the horizontal offset', () {
      expect(theme.scaledBy(2.0).horizontalOffset, 16); // 8 * 2
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });

    test('copyWith replaces the offset', () {
      expect(theme.copyWith(horizontalOffset: 20).horizontalOffset, 20);
    });
  });

  group('TablePlusTooltipTheme', () {
    const theme = TablePlusTooltipTheme();

    test('copyWith replaces only the named field', () {
      final c = theme.copyWith(enabled: false);
      expect(c.enabled, isFalse);
      expect(c.backgroundColor, theme.backgroundColor);
      expect(c.hideOnEmptyMessage, theme.hideOnEmptyMessage);
    });

    test('anchors on the child unless told otherwise', () {
      expect(theme.anchor, TooltipAnchor.child);
    });

    test('copyWith carries the anchor', () {
      final c = theme.copyWith(anchor: TooltipAnchor.pointer);
      expect(c.anchor, TooltipAnchor.pointer);
      expect(c.copyWith().anchor, TooltipAnchor.pointer);
      expect(c.direction, theme.direction);
    });
  });

  group('TablePlusTheme (composite)', () {
    const theme = TablePlusTheme();

    test('copyWith replaces one sub-theme and preserves the rest', () {
      const newBody = TablePlusBodyTheme(rowHeight: 100);
      final c = theme.copyWith(bodyTheme: newBody);
      expect(c.bodyTheme, same(newBody));
      expect(c.headerTheme, same(theme.headerTheme));
      expect(c.checkboxTheme, same(theme.checkboxTheme));
    });

    test('scaledBy scales the dimensional sub-themes', () {
      final s = theme.scaledBy(2.0);
      expect(s.bodyTheme.rowHeight, 96); // 48 * 2
      expect(s.headerTheme.height, 112); // 56 * 2
      expect(s.checkboxTheme.checkboxColumnWidth, 120); // 60 * 2
    });

    test('scaledBy leaves the scrollbar and tooltip themes unscaled', () {
      final s = theme.scaledBy(2.0);
      expect(s.scrollbarTheme, same(theme.scrollbarTheme));
      expect(s.tooltipTheme, same(theme.tooltipTheme));
    });

    test('scaledBy carries the row tooltip theme through untouched', () {
      const rowTooltip = TablePlusTooltipTheme(padding: EdgeInsets.zero);
      const scoped = TablePlusTheme(rowTooltipTheme: rowTooltip);
      expect(scoped.scaledBy(2.0).rowTooltipTheme, same(rowTooltip));
    });

    test('scaledBy leaves an unset row tooltip theme unset', () {
      // Null is meaningful: it selects the documented fallback to tooltipTheme.
      // Defaulting it to an instance here would silently break that.
      expect(theme.scaledBy(2.0).rowTooltipTheme, isNull);
    });

    test('scaledBy carries the header tooltip theme through untouched', () {
      const headerTooltip =
          TablePlusTooltipTheme(anchor: TooltipAnchor.pointer);
      const scoped = TablePlusTheme(headerTooltipTheme: headerTooltip);
      expect(scoped.scaledBy(2.0).headerTooltipTheme, same(headerTooltip));
    });

    test('scaledBy leaves an unset header tooltip theme unset', () {
      expect(theme.scaledBy(2.0).headerTooltipTheme, isNull);
    });

    test('copyWith carries the header tooltip theme', () {
      const headerTooltip =
          TablePlusTooltipTheme(anchor: TooltipAnchor.pointer);
      final c = theme.copyWith(headerTooltipTheme: headerTooltip);
      expect(c.headerTooltipTheme, same(headerTooltip));
      expect(c.copyWith().headerTooltipTheme, same(headerTooltip));
      expect(c.tooltipTheme, same(theme.tooltipTheme));
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });
}
