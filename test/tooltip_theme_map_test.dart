import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// TablePlusTooltipTheme.toJustTooltipTheme maps the visual subset of the theme
// onto the just_tooltip package's JustTooltipTheme.

void main() {
  test('toJustTooltipTheme carries the visual fields through', () {
    const t = TablePlusTooltipTheme(
      backgroundColor: Color(0xFF010203),
      borderWidth: 3,
      elevation: 7,
      showArrow: true,
      arrowBaseWidth: 20,
    );

    final j = t.toJustTooltipTheme();
    expect(j.backgroundColor, const Color(0xFF010203));
    expect(j.borderWidth, 3);
    expect(j.elevation, 7);
    expect(j.showArrow, isTrue);
    expect(j.arrowBaseWidth, 20);
  });
}
