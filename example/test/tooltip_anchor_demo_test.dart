import 'package:example/pages/tooltip_anchor/tooltip_anchor_page.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The demo's only logic is turning two anchor choices into a TablePlusTheme.
// Whether a tooltip then lands beside the cursor is the package's business, and
// it is pinned there — repeating it here would test just_tooltip twice.

void main() {
  test('cells anchor on the child until told otherwise', () {
    final theme = buildAnchorDemoTheme();
    expect(theme.tooltipTheme.anchor, TooltipAnchor.child);
  });

  test('the cell anchor reaches the theme', () {
    final theme = buildAnchorDemoTheme(cellAnchor: TooltipAnchor.pointer);
    expect(theme.tooltipTheme.anchor, TooltipAnchor.pointer);
  });

  test('the header follows the cells until told otherwise', () {
    // Null is the point: it selects the package's documented fallback to
    // tooltipTheme, so the demo walks that path unless a visitor steps off it.
    // Handing the header a theme eagerly would leave the fallback unexercised
    // while the screen still looked right.
    expect(buildAnchorDemoTheme().headerTooltipTheme, isNull);
  });

  test('a chosen header anchor gives the header a theme of its own', () {
    final theme = buildAnchorDemoTheme(
      headerAnchor: HeaderAnchorChoice.pointer,
    );
    expect(theme.headerTooltipTheme?.anchor, TooltipAnchor.pointer);
    expect(theme.tooltipTheme.anchor, TooltipAnchor.child,
        reason: 'the cell anchor is untouched by the header one');
  });

  test('the header can walk back to following the cells', () {
    final theme = buildAnchorDemoTheme(
      cellAnchor: TooltipAnchor.pointer,
      headerAnchor: HeaderAnchorChoice.followCells,
    );
    expect(theme.headerTooltipTheme, isNull);
    expect(theme.tooltipTheme.anchor, TooltipAnchor.pointer);
  });
}
