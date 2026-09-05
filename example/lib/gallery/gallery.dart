/// The gallery — a shell that demonstrates a package without knowing which one.
///
/// A menu of destinations, a viewport-aware preview stage with a device wall, a
/// source pane that reads the running file, and the app chrome around them. None
/// of it names a table, and `test/portable_seam_test.dart` holds it to that by
/// walking the directory rather than trusting the intention.
///
/// **This barrel is the entry point, and that is a rule rather than a
/// convenience.** `lib/app/` may import this file and nothing under
/// `lib/gallery/src/`. The day this directory becomes a package of its own, a
/// `src/` import from outside is exactly what stops resolving — and today it
/// resolves fine, compiles, and passes every test, so nothing but a rule catches
/// it. Same shape as the main package's own barrel row in
/// `docs/map/invariant/tree-rule.md`: a symbol is exported here or it is not
/// public.
library;

export 'src/perf/performance_monitor.dart';
export 'src/preview/device_wall.dart';
export 'src/preview/preview_frame.dart';
export 'src/preview/preview_stage.dart';
export 'src/preview/viewport_spec.dart';
export 'src/settings/feature_detail_pane.dart';
export 'src/settings/feature_list_pane.dart';
export 'src/settings/feature_search.dart';
export 'src/settings/setting_spec.dart';
export 'src/settings/settings_host.dart';
export 'src/settings/settings_controls.dart';
export 'src/shell/dart_highlighter.dart';
export 'src/shell/shell_destination.dart';
export 'src/shell/shell_destinations.dart';
export 'src/shell/shell_menu.dart';
export 'src/shell/shell_page.dart';
export 'src/shell/source_pane.dart';
export 'src/theme/example_theme.dart';
export 'src/theme/theme_mode_button.dart';
