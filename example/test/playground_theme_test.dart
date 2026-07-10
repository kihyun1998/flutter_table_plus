import 'package:example/pages/playground/playground_page.dart';
import 'package:example/pages/playground/widgets/settings_panel.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaygroundSettings', () {
    test('anchors cell tooltips on the child until told otherwise', () {
      expect(const PlaygroundSettings().tooltipAnchor, TooltipAnchor.child);
    });

    test('copyWith carries the tooltip anchor', () {
      const settings = PlaygroundSettings();
      final c = settings.copyWith(tooltipAnchor: TooltipAnchor.pointer);
      expect(c.tooltipAnchor, TooltipAnchor.pointer);
      expect(c.copyWith().tooltipAnchor, TooltipAnchor.pointer);
      expect(c.tooltipAlignment, settings.tooltipAlignment);
    });
  });

  group('buildPlaygroundTheme', () {
    test('the cell anchor reaches the table theme', () {
      final theme = buildPlaygroundTheme(
        const PlaygroundSettings(tooltipAnchor: TooltipAnchor.pointer),
      );
      expect(theme.tooltipTheme.anchor, TooltipAnchor.pointer);
    });

    test('leaves the header tooltip theme unset while it follows the cells',
        () {
      // Null is the whole point: it selects the package's documented fallback
      // to tooltipTheme, so the playground walks that path unless a user
      // deliberately steps off it. Handing the header its own theme eagerly
      // would leave the fallback unexercised while everything still looked
      // right on screen.
      expect(
          buildPlaygroundTheme(const PlaygroundSettings()).headerTooltipTheme,
          isNull);
    });

    test('a chosen header anchor gives the header a theme of its own', () {
      final theme = buildPlaygroundTheme(
        const PlaygroundSettings(
            headerTooltipAnchor: HeaderTooltipAnchor.pointer),
      );
      expect(theme.headerTooltipTheme?.anchor, TooltipAnchor.pointer);
      expect(theme.tooltipTheme.anchor, TooltipAnchor.child,
          reason: 'the cell anchor is untouched by the header one');
    });

    test('the header can return to following the cells', () {
      // A dropdown must be able to walk back. `copyWith`'s `?? this.x` idiom
      // cannot restore a null, which is why the panel models this as a third
      // enum value rather than a nullable anchor.
      const settings =
          PlaygroundSettings(headerTooltipAnchor: HeaderTooltipAnchor.pointer);
      final back = settings.copyWith(
          headerTooltipAnchor: HeaderTooltipAnchor.followCells);
      expect(buildPlaygroundTheme(back).headerTooltipTheme, isNull);
    });
  });
}
