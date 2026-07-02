import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/src/widgets/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// isScaleModifierPressed picks the platform-appropriate modifier: Cmd (Meta) on
// macOS, Ctrl elsewhere. The non-macOS branch deliberately ignores Meta to
// dodge the sticky-Windows-key bug.
//
// debugDefaultTargetPlatformOverride must be reset inside the test body (the
// framework asserts it's unset before tearDown runs), hence the try/finally.

void main() {
  testWidgets('non-macOS: Control toggles it, Meta is ignored', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      expect(isScaleModifierPressed(), isFalse);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      expect(isScaleModifierPressed(), isTrue);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(isScaleModifierPressed(), isFalse);

      // Meta (the Windows key) must NOT count — this guards the sticky-key bug.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      expect(isScaleModifierPressed(), isFalse);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('macOS: Meta toggles it, Control is ignored', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      expect(isScaleModifierPressed(), isTrue);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      expect(isScaleModifierPressed(), isFalse);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
