/// What the shell is asked to show — and who owns the state behind it.
library;

import 'shell_destination.dart';

/// The set of destinations one shell draws, together with their lifetime.
///
/// **The lifetime is why this is a port rather than a `List` parameter.** Every
/// destination that does anything is backed by a `ChangeNotifier` the stage and
/// the knob pane both read — that is what a destination *is* here, one object
/// with two views of it — and something has to dispose them. `ShellPage`'s state
/// did, because it also built the list; handing it a bare `List` would move the
/// building out and leave the disposing behind, which is the half-repair shape
/// `docs/map/invariant/no-signal-on-failure.md` keeps recording. A leaked
/// notifier throws nothing and fails no test.
///
/// So the shell still creates this once with its state and disposes it with its
/// state, exactly as before. What it no longer does is *know what is in it*.
///
/// [all] is read on every build. Implementations return a field, not a fresh
/// list: the shell holds the selected id rather than the selected object, but
/// `ShellMenu` and the stage both walk this on the same frame and a list rebuilt
/// per call would rebuild every destination's builder with it.
abstract class ShellDestinations {
  /// Every destination, in menu order. Grouping is [ShellCategory]'s job.
  List<ShellDestination> get all;

  /// Releases whatever the destinations hold.
  void dispose();
}
