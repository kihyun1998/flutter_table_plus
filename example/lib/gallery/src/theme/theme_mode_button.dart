import 'package:flutter/material.dart';

import 'example_theme.dart';

/// Cycles the app between following the system, light, and dark.
///
/// An app-bar action rather than a page, so every screen the example ships can
/// carry it without a route of its own. The icon reports the *mode*, not the
/// resulting brightness — `system` shows the system icon even while the system
/// is dark, because otherwise there is nothing on screen to distinguish
/// "following the system, which is dark" from "pinned to dark".
///
/// **Draws nothing when there is no [ExampleThemeScope] above it.** A page must
/// stay pumpable on its own — the suite pumps pages directly — so this degrades
/// to empty rather than asserting. An app bar that demanded the app's theme
/// plumbing would make every page in the example untestable in isolation.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ExampleThemeScope.maybeOf(context);
    if (controller == null) return const SizedBox.shrink();

    final (icon, label) = switch (controller.mode) {
      ThemeMode.system => (Icons.brightness_auto_outlined, 'Theme: system'),
      ThemeMode.light => (Icons.light_mode_outlined, 'Theme: light'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Theme: dark'),
    };

    return IconButton(
      icon: Icon(icon),
      tooltip: label,
      onPressed: controller.cycle,
    );
  }
}
