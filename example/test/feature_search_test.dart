import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/widgets/feature_search.dart';
import 'package:flutter_test/flutter_test.dart';

// Search used to narrow one scrolling column to the controls whose labels
// matched. There is no such column now: the control someone is hunting almost
// always belongs to a feature they have not opened. So the search narrows the
// *list*, and says which setting matched.
//
// It matches a feature's name as well as its settings' labels. A feature's name
// is on screen, and typing what you can see and getting nothing back reads as a
// broken search, not as a narrow contract.

const _bare = PlaygroundSettings();

List<String> _ids(String query) =>
    searchFeatures(query, _bare).map((m) => m.feature.id).toList();

FeatureMatch _match(String query, String featureId) =>
    searchFeatures(query, _bare).firstWhere((m) => m.feature.id == featureId);

void main() {
  test('a blank query is not a search', () {
    final all = searchFeatures('', _bare);
    expect(all, hasLength(20));
    expect(all.every((m) => m.matchedLabels.isEmpty), isTrue,
        reason: 'nothing matched, because nothing was asked');
  });

  test('a query narrows the list to the features that hold a match', () {
    // 'Cell Anchor' and 'Header Anchor' are both settings of Tooltips.
    expect(_ids('anchor'), ['tooltips']);
    expect(_match('anchor', 'tooltips').matchedLabels,
        containsAll(['Cell Anchor', 'Header Anchor']));
  });

  test("a feature's own name matches", () {
    final m = _match('drag', 'dragSelection');
    expect(m.nameMatched, isTrue);
    expect(m.matchedLabels, isEmpty,
        reason: 'Drag selection owns no options; only its name matched');
  });

  test('a setting is found while its feature is off', () {
    expect(_bare.rowCardTooltip, isFalse);

    final m = _match('row card wait', 'rowCard');
    expect(m.matchedLabels, ['Row Card Wait']);
    expect(m.isOn, isFalse,
        reason: 'absent and non-existent are different things');
  });

  test('a query that matches nothing narrows to nothing', () {
    expect(_ids('zzz'), isEmpty);
  });
}
