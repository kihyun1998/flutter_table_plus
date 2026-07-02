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
/// classification was inlined at four editing-cell key handlers.
EditKeyAction editKeyAction(KeyEvent event) {
  if (event is! KeyDownEvent) return EditKeyAction.none;
  if (event.logicalKey == LogicalKeyboardKey.enter) return EditKeyAction.save;
  if (event.logicalKey == LogicalKeyboardKey.escape) {
    return EditKeyAction.cancel;
  }
  return EditKeyAction.none;
}
