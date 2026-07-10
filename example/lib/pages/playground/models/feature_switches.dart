import 'playground_settings.dart';

/// Reading and writing a settings field by name.
///
/// The description names a feature's switch with a string, and Dart cannot turn
/// a string into a field. So the knowledge lives here, once, and
/// `test/settings_presets_test.dart` holds it to the description: every switch
/// the description declares must appear as a key.
///
/// Without that invariant the panel had a quiet default — an unknown switch id
/// read as `true`, so a feature whose switch nobody taught it to read would be
/// drawn as permanently on, and nothing would fail.
class FeatureSwitch {
  const FeatureSwitch({required this.read, required this.write});

  final bool Function(PlaygroundSettings) read;
  final PlaygroundSettings Function(PlaygroundSettings, bool) write;
}

final Map<String, FeatureSwitch> featureSwitches = {
  'sortingEnabled': FeatureSwitch(
    read: (s) => s.sortingEnabled,
    write: (s, v) => s.copyWith(sortingEnabled: v),
  ),
  'selectionEnabled': FeatureSwitch(
    read: (s) => s.selectionEnabled,
    write: (s, v) => s.copyWith(selectionEnabled: v),
  ),
  'dragSelectionEnabled': FeatureSwitch(
    read: (s) => s.dragSelectionEnabled,
    write: (s, v) => s.copyWith(dragSelectionEnabled: v),
  ),
  'editingEnabled': FeatureSwitch(
    read: (s) => s.editingEnabled,
    write: (s, v) => s.copyWith(editingEnabled: v),
  ),
  'columnReorderEnabled': FeatureSwitch(
    read: (s) => s.columnReorderEnabled,
    write: (s, v) => s.copyWith(columnReorderEnabled: v),
  ),
  'resizableEnabled': FeatureSwitch(
    read: (s) => s.resizableEnabled,
    write: (s, v) => s.copyWith(resizableEnabled: v),
  ),
  'tooltipEnabled': FeatureSwitch(
    read: (s) => s.tooltipEnabled,
    write: (s, v) => s.copyWith(tooltipEnabled: v),
  ),
  'rowCardTooltip': FeatureSwitch(
    read: (s) => s.rowCardTooltip,
    write: (s, v) => s.copyWith(rowCardTooltip: v),
  ),
  'mergedRowsEnabled': FeatureSwitch(
    read: (s) => s.mergedRowsEnabled,
    write: (s, v) => s.copyWith(mergedRowsEnabled: v),
  ),
  'dynamicRowHeight': FeatureSwitch(
    read: (s) => s.dynamicRowHeight,
    write: (s, v) => s.copyWith(dynamicRowHeight: v),
  ),
  'dimInactiveRows': FeatureSwitch(
    read: (s) => s.dimInactiveRows,
    write: (s, v) => s.copyWith(dimInactiveRows: v),
  ),
  'showAlternateRows': FeatureSwitch(
    read: (s) => s.showAlternateRows,
    write: (s, v) => s.copyWith(showAlternateRows: v),
  ),
  'showDividers': FeatureSwitch(
    read: (s) => s.showDividers,
    write: (s, v) => s.copyWith(showDividers: v),
  ),
  'headerTopBorderShow': FeatureSwitch(
    read: (s) => s.headerTopBorderShow,
    write: (s, v) => s.copyWith(headerTopBorderShow: v),
  ),
  'headerBottomBorderShow': FeatureSwitch(
    read: (s) => s.headerBottomBorderShow,
    write: (s, v) => s.copyWith(headerBottomBorderShow: v),
  ),
  'headerVerticalDividerShow': FeatureSwitch(
    read: (s) => s.headerVerticalDividerShow,
    write: (s, v) => s.copyWith(headerVerticalDividerShow: v),
  ),
};
