import 'package:flutter/services.dart';

/// The edit action a key event maps to inside an editing text field.
enum EditKeyAction {
  /// Commit the edit (Enter).
  save,

  /// Discard the edit (Escape).
  cancel,

  /// No edit action for this event.
  none,
}

/// Classifies a raw [KeyEvent] into its [EditKeyAction].
///
/// Only key-*down* events for Enter/Escape map to an action; key up/repeat and
/// every other key are [EditKeyAction.none]. Extracted because this exact
/// classification was inlined at editing-cell key handlers — four were folded
/// in when it was written, and a **fifth**, in the merged row's stacked branch,
/// was not found until that branch started reusing the ordinary cell (#155).
/// The count was written as four for as long as the fifth survived, which is
/// why `docs/map/invariant/no-hand-enumeration.md` covers counts as well as
/// lists.
EditKeyAction editKeyAction(KeyEvent event) {
  if (event is! KeyDownEvent) return EditKeyAction.none;
  if (event.logicalKey == LogicalKeyboardKey.enter) return EditKeyAction.save;
  if (event.logicalKey == LogicalKeyboardKey.escape) {
    return EditKeyAction.cancel;
  }
  return EditKeyAction.none;
}
