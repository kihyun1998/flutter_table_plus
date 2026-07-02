/// Breaks the feedback loop when synchronizing paired scroll positions.
///
/// When a master position changes we jump the slave to match — but that jump
/// makes the slave fire its own notification, which would jump the master
/// back, and so on forever. This guard suppresses exactly that echo: before
/// jumping the slave it arms a one-shot suppression flag for it, so the slave's
/// immediately-following notification is consumed instead of bouncing back.
///
/// Pure extraction of the guard (previously inline in
/// [SyncedScrollControllers]), decoupled from [ScrollController] — parties are
/// opaque [Object] tokens (any stable identity) and positions are plain
/// numbers, so the reentrancy logic is unit-testable without real controllers.
class NoCascadeGuard {
  final Map<Object, bool> _suppress = {};

  /// Resolves a [master] position change into the offset [slave] should jump to
  /// (clamped to `[slaveMin, slaveMax]`), or `null` when this notification is
  /// the echo of our own prior jump and must be suppressed to break the loop.
  ///
  /// On a real (non-echo) change it arms [slave]'s one-shot suppression so the
  /// jump it is about to receive won't cascade back.
  double? resolveJump({
    required Object master,
    required Object slave,
    required double masterOffset,
    required double slaveMin,
    required double slaveMax,
  }) {
    if (_suppress[master] == true) {
      _suppress[master] = false;
      return null;
    }

    _suppress[slave] = true;
    return masterOffset.clamp(slaveMin, slaveMax);
  }

  /// Clears all armed suppression (called when controllers are (re)initialized).
  void reset() => _suppress.clear();
}
