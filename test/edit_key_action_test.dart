import 'package:flutter/services.dart';
import 'package:flutter_table_plus/src/utils/edit_key_action.dart';
import 'package:flutter_test/flutter_test.dart';

KeyDownEvent _down(LogicalKeyboardKey key, PhysicalKeyboardKey physical) =>
    KeyDownEvent(
        physicalKey: physical, logicalKey: key, timeStamp: Duration.zero);

void main() {
  group('editKeyAction', () {
    test('Enter down commits', () {
      expect(
        editKeyAction(
            _down(LogicalKeyboardKey.enter, PhysicalKeyboardKey.enter)),
        EditKeyAction.save,
      );
    });

    test('Escape down cancels', () {
      expect(
        editKeyAction(
            _down(LogicalKeyboardKey.escape, PhysicalKeyboardKey.escape)),
        EditKeyAction.cancel,
      );
    });

    test('any other key is none', () {
      expect(
        editKeyAction(_down(LogicalKeyboardKey.keyA, PhysicalKeyboardKey.keyA)),
        EditKeyAction.none,
      );
    });

    test('a key-up (even Enter) is not an action', () {
      expect(
        editKeyAction(const KeyUpEvent(
          physicalKey: PhysicalKeyboardKey.enter,
          logicalKey: LogicalKeyboardKey.enter,
          timeStamp: Duration.zero,
        )),
        EditKeyAction.none,
      );
    });

    test('a key-repeat (even Enter) is not an action', () {
      expect(
        editKeyAction(const KeyRepeatEvent(
          physicalKey: PhysicalKeyboardKey.enter,
          logicalKey: LogicalKeyboardKey.enter,
          timeStamp: Duration.zero,
        )),
        EditKeyAction.none,
      );
    });
  });
}
