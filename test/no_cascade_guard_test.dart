import 'package:flutter_table_plus/src/utils/no_cascade_guard.dart';
import 'package:flutter_test/flutter_test.dart';

// The guard is the reentrancy state machine that stops synced scroll positions
// from bouncing forever. Parties are opaque tokens ('A'/'B' here).

void main() {
  group('NoCascadeGuard', () {
    test('a real master change yields the clamped jump offset', () {
      final g = NoCascadeGuard();
      expect(
        g.resolveJump(
          master: 'A',
          slave: 'B',
          masterOffset: 50,
          slaveOffset: -1,
          slaveMin: 0,
          slaveMax: 100,
        ),
        50,
      );
    });

    test('the slave echo that follows is suppressed (breaks the loop)', () {
      final g = NoCascadeGuard();
      // A moves -> we jump B (arms B's suppression).
      g.resolveJump(
        master: 'A',
        slave: 'B',
        masterOffset: 50,
        slaveOffset: -1,
        slaveMin: 0,
        slaveMax: 100,
      );
      // B's echoing notification must NOT jump A back.
      expect(
        g.resolveJump(
          master: 'B',
          slave: 'A',
          masterOffset: 50,
          slaveOffset: -1,
          slaveMin: 0,
          slaveMax: 100,
        ),
        isNull,
      );
    });

    test('after the echo, a genuine master change jumps again (not stuck)', () {
      final g = NoCascadeGuard();
      g.resolveJump(
        master: 'A',
        slave: 'B',
        masterOffset: 50,
        slaveOffset: -1,
        slaveMin: 0,
        slaveMax: 100,
      );
      g.resolveJump(
        master: 'B',
        slave: 'A',
        masterOffset: 50,
        slaveOffset: -1,
        slaveMin: 0,
        slaveMax: 100,
      );
      expect(
        g.resolveJump(
          master: 'A',
          slave: 'B',
          masterOffset: 70,
          slaveOffset: -1,
          slaveMin: 0,
          slaveMax: 100,
        ),
        70,
      );
    });

    test('clamps the offset to the slave extents', () {
      expect(
        NoCascadeGuard().resolveJump(
          master: 'A',
          slave: 'B',
          masterOffset: 150,
          slaveOffset: -1,
          slaveMin: 0,
          slaveMax: 100,
        ),
        100,
      );
      expect(
        NoCascadeGuard().resolveJump(
          master: 'A',
          slave: 'B',
          masterOffset: -10,
          slaveOffset: -1,
          slaveMin: 0,
          slaveMax: 100,
        ),
        0,
      );
    });

    test('reset clears armed suppression', () {
      final g = NoCascadeGuard();
      g.resolveJump(
        master: 'A',
        slave: 'B',
        masterOffset: 50,
        slaveOffset: -1,
        slaveMin: 0,
        slaveMax: 100,
      );
      g.reset();
      // B is no longer suppressed, so a B change now jumps A normally.
      expect(
        g.resolveJump(
          master: 'B',
          slave: 'A',
          masterOffset: 30,
          slaveOffset: -1,
          slaveMin: 0,
          slaveMax: 100,
        ),
        30,
      );
    });

    test('a jump that would not move the slave arms nothing', () {
      final g = NoCascadeGuard();
      expect(
        g.resolveJump(
          master: 'A',
          slave: 'B',
          masterOffset: 50,
          slaveOffset: 50,
          slaveMin: 0,
          slaveMax: 100,
        ),
        50,
      );
      // That jump sends no notification, so B's next one is a real change.
      expect(
        g.resolveJump(
          master: 'B',
          slave: 'A',
          masterOffset: 30,
          slaveOffset: 50,
          slaveMin: 0,
          slaveMax: 100,
        ),
        30,
      );
    });
  });
}
