import 'package:example/pages/playground/widgets/settings_controls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('settingMatches', () {
    test('an empty query matches everything', () {
      expect(settingMatches('Row Count', ''), isTrue);
      expect(settingMatches('', ''), isTrue);
    });

    test('matches on any part of the label, not just its start', () {
      expect(settingMatches('Cell Anchor', 'anchor'), isTrue);
      expect(settingMatches('Header Anchor', 'head'), isTrue);
    });

    test('ignores case on both sides', () {
      expect(settingMatches('Row Count', 'ROW'), isTrue);
      expect(settingMatches('ROW COUNT', 'row'), isTrue);
    });

    test('ignores surrounding whitespace in the query', () {
      expect(settingMatches('Row Count', '  count '), isTrue);
      expect(settingMatches('Row Count', '   '), isTrue,
          reason: 'a query of only spaces is no query at all');
    });

    test('does not match a label it is absent from', () {
      expect(settingMatches('Row Count', 'anchor'), isFalse);
    });
  });
}
