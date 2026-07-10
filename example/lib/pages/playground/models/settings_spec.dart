/// A description of the playground's settings: what owns what, and what
/// changes what.
///
/// The settings themselves stay a flat value class. This is the map beside it,
/// and `test/settings_spec_test.dart` is what keeps the map honest — a field
/// left undescribed, or an id naming nothing, turns the suite red. A map
/// written in prose would be stale within a month.
library;

/// One thing a reader might be trying to do.
///
/// Groups are cut by intent, not by what a setting configures. A feature's own
/// options do not share an effect — `tooltipBehavior` builds a column while
/// `tooltipDirection` builds a theme — so cutting by effect would tear the
/// tooltip feature in half and hide half of it from anyone looking for it.
class SettingGroup {
  const SettingGroup({
    required this.id,
    required this.title,
    required this.features,
  });

  final String id;
  final String title;
  final List<SettingFeature> features;
}

/// A capability of the table, and the settings that only mean something once it
/// is on.
///
/// [switchId] names the boolean field that turns it on, when there is one; a
/// feature without a switch is a heading over settings that are always live.
/// The hierarchy *is* the dependency — an option is reachable exactly when the
/// feature holding it is on — so there is no separate `dependsOn` to drift out
/// of step with it.
class SettingFeature {
  const SettingFeature({
    required this.id,
    required this.title,
    this.switchId,
    this.options = const [],
    this.interactions = const [],
  });

  final String id;
  final String title;

  /// The settings field that enables this feature, or null when it is always on.
  final String? switchId;

  /// Settings fields that are only meaningful while this feature is enabled.
  final List<String> options;

  /// Other features whose behaviour this one changes, or which change it.
  final List<Interaction> interactions;
}

/// One feature changing another, and the evidence that it does.
///
/// A test can insist that [evidence] is present. It cannot read the code the
/// citation points at and confirm that [effect] is what happens there — that is
/// a reviewer's job. So the rule is narrow and enforceable: no interaction is
/// asserted without a citation.
class Interaction {
  const Interaction({
    required this.otherFeatureId,
    required this.effect,
    required this.evidence,
  });

  final String otherFeatureId;

  /// What actually happens, in the direction it happens.
  final String effect;

  /// Where in the library, its tests, or the changelog this is established.
  final String evidence;
}

const settingsSpec = <SettingGroup>[
  SettingGroup(
    id: 'data',
    title: 'Data',
    features: [
      SettingFeature(
        id: 'data',
        title: 'Rows',
        options: ['rowCount'],
      ),
    ],
  ),
  SettingGroup(
    id: 'interaction',
    title: 'Interaction',
    features: [
      SettingFeature(
        id: 'sorting',
        title: 'Sorting',
        switchId: 'sortingEnabled',
        options: ['sortCycleOrder'],
      ),
      SettingFeature(
        id: 'selection',
        title: 'Selection',
        switchId: 'selectionEnabled',
        options: [
          'selectionMode',
          'showCheckboxColumn',
          'selectAllEnabled',
          'showRowCheckbox',
          'cellTapTogglesCheckbox',
        ],
        interactions: [
          Interaction(
            otherFeatureId: 'editing',
            effect: 'While editing is on, tapping an editable column edits the '
                'cell and tapping anywhere else selects the row. The cell wins '
                'the gesture arena; the row does not.',
            evidence: 'CHANGELOG 2.14.0, BEHAVIOR: "Tapping a row now selects '
                'it while isEditable is true"',
          ),
          Interaction(
            otherFeatureId: 'mergedRows',
            effect: 'A merged group is selected as one unit, not as the rows '
                'it stands for.',
            evidence: 'row_lookup.dart derives idToGroup from mergedGroups; '
                'CLAUDE.md, "Merged row groups are treated as single units for '
                'selection and editing operations"',
          ),
        ],
      ),
      SettingFeature(
        id: 'dragSelection',
        title: 'Drag selection',
        switchId: 'dragSelectionEnabled',
        interactions: [
          Interaction(
            otherFeatureId: 'selection',
            effect: 'Dragging selects nothing while selection is off. The '
                'table requires both.',
            // Cite the library, not the panel. The panel's shape is ours to
            // change, and citing it went stale the moment the sections that
            // guarded this control were deleted.
            evidence: 'flutter_table_plus.dart: _isDragSelectionEnabled is '
                'enableDragSelection && isSelectable && '
                'onDragSelectionUpdate != null',
          ),
          Interaction(
            otherFeatureId: 'mergedRows',
            effect: 'A drag crossing a merged group adds the group id, not the '
                'ids of the rows inside it.',
            evidence:
                'test/drag_selection_test.dart, "dragging across a merged '
                'group adds the group ID, not individual rows"; RowGeometry '
                'snapshots "row id or merged group id"',
          ),
        ],
      ),
      SettingFeature(
        id: 'editing',
        title: 'Cell editing',
        switchId: 'editingEnabled',
      ),
      SettingFeature(
        id: 'columnReorder',
        title: 'Column reorder',
        switchId: 'columnReorderEnabled',
      ),
      SettingFeature(
        id: 'resizing',
        title: 'Column resizing',
        switchId: 'resizableEnabled',
        options: [
          'columnMinWidth',
          'stretchLastColumn',
          'resizeHandleWidth',
          'resizeHandleThickness',
          'resizeHandleIndent',
          'resizeHandleEndIndent',
        ],
        interactions: [
          Interaction(
            otherFeatureId: 'zoom',
            effect: 'Resized widths are stored unscaled, so they survive a '
                'change of zoom and are reported back in logical pixels.',
            evidence: 'CHANGELOG 2.9.0: "Resized column widths are stored in '
                'logical (unscaled) units"',
          ),
        ],
      ),
      SettingFeature(
        id: 'zoom',
        title: 'Zoom',
        options: ['scale', 'blockModifierScroll'],
      ),
    ],
  ),
  SettingGroup(
    id: 'content',
    title: 'Content',
    features: [
      SettingFeature(
        id: 'tooltips',
        title: 'Tooltips',
        switchId: 'tooltipEnabled',
        options: [
          'tooltipBehavior',
          'headerTooltipBehavior',
          'tooltipWaitDurationMs',
          'tooltipDirection',
          'tooltipAnchor',
          'headerTooltipAnchor',
          'tooltipAlignment',
          'tooltipShowArrow',
          'tooltipOffset',
          'showTooltipFormatter',
          'showTooltipBuilder',
        ],
        interactions: [
          Interaction(
            otherFeatureId: 'rowCard',
            effect: 'Turning tooltips off silences the row card too. And with '
                'TooltipBehavior.always every ellipsized column already has a '
                'tooltip, which leaves the card nowhere to appear.',
            evidence: 'test/row_tooltip_test.dart, "TooltipBehavior.always '
                'leaves no room for the card"; CHANGELOG 2.14.0',
          ),
        ],
      ),
      SettingFeature(
        id: 'rowCard',
        title: 'Row card',
        switchId: 'rowCardTooltip',
        options: ['rowCardWaitDurationMs'],
        interactions: [
          Interaction(
            otherFeatureId: 'mergedRows',
            effect: 'A merged row carries no card. It stands for several data '
                'rows, so there is no single one to build the card from.',
            evidence: 'table_body.dart returns the row unwrapped when '
                '_getMergedGroupForRow is non-null; test/row_tooltip_test.dart, '
                '"a merged row carries no card"',
          ),
        ],
      ),
      SettingFeature(
        id: 'mergedRows',
        title: 'Merged rows',
        switchId: 'mergedRowsEnabled',
      ),
      SettingFeature(
        id: 'dynamicRowHeight',
        title: 'Dynamic row heights',
        switchId: 'dynamicRowHeight',
      ),
      SettingFeature(
        id: 'dimRows',
        title: 'Dimmed rows',
        switchId: 'dimInactiveRows',
      ),
    ],
  ),
  SettingGroup(
    id: 'appearance',
    title: 'Appearance',
    features: [
      SettingFeature(
        id: 'rowStyle',
        title: 'Rows and text',
        options: [
          'rowHeight',
          'fontSize',
          'fontFamily',
          'horizontalPadding',
          'verticalPadding',
          'sortIconWidth',
          'checkboxTapTargetSize',
        ],
      ),
      SettingFeature(
        id: 'alternateRows',
        title: 'Alternating row colour',
        switchId: 'showAlternateRows',
      ),
      SettingFeature(
        id: 'bodyDividers',
        title: 'Body dividers',
        switchId: 'showDividers',
      ),
      SettingFeature(
        id: 'ink',
        title: 'Row ink',
        options: ['splashColor', 'hoverColor', 'highlightColor'],
      ),
      SettingFeature(
        id: 'headerTopBorder',
        title: 'Header top border',
        switchId: 'headerTopBorderShow',
        options: ['headerTopBorderThickness'],
      ),
      SettingFeature(
        id: 'headerBottomBorder',
        title: 'Header bottom border',
        switchId: 'headerBottomBorderShow',
        options: ['headerBottomBorderThickness'],
      ),
      SettingFeature(
        id: 'headerVerticalDivider',
        title: 'Header vertical divider',
        switchId: 'headerVerticalDividerShow',
        options: [
          'headerVerticalDividerThickness',
          'headerVerticalDividerIndent',
          'headerVerticalDividerEndIndent',
        ],
      ),
    ],
  ),
];
