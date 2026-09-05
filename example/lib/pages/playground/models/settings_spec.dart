/// This example's settings, described in the gallery's vocabulary.
///
/// The types are in `package:example/gallery/gallery.dart`; what is here is the
/// description itself — every group, every feature, and every interaction
/// between two of them. `test/settings_spec_test.dart` keeps it true against
/// `PlaygroundSettings`.
library;

import '../../../gallery/gallery.dart';

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
            effect: 'Selecting a merged row reports the group id once, not the '
                'ids of the rows it stands for.',
            // `row_lookup.dart` only builds an id→group map; a lookup table
            // settles nothing. What settles it is which id reaches the
            // callback, and that is decided here.
            evidence: 'table_plus_merged_row.dart calls '
                'onRowSelectionChanged(mergeGroup.groupId)',
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
            effect: 'Dragging selects nothing while selection is off, and '
                'nothing in single-selection mode either. The table wires the '
                'drag handlers only when both hold.',
            // Cite the library, not the panel. The panel's shape is ours to
            // change, and citing it went stale the moment the sections that
            // guarded this control were deleted.
            //
            // Quoted in full: an abridged expression is worse than none. This
            // used to omit the selectionMode term, which read as a promise that
            // dragging works in single-selection mode.
            evidence: 'flutter_table_plus.dart: _isDragSelectionEnabled is '
                'enableDragSelection && isSelectable && '
                'selectionMode == SelectionMode.multiple && '
                'onDragSelectionUpdate != null',
          ),
          Interaction(
            otherFeatureId: 'mergedRows',
            effect: 'A drag crossing a merged group adds the group id, not the '
                'ids of the rows inside it.',
            evidence:
                'test/drag_selection_test.dart, "dragging across a merged '
                'group adds the group ID, not individual rows"; table_body.dart '
                'snapshots each render row as a "row id or merged group id"',
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
            effect: 'Turning tooltips off silences the row card too — the '
                'playground gives the card its enabled flag. And with '
                'TooltipBehavior.always every ellipsized column already has a '
                'tooltip, which leaves the card nowhere to appear.',
            // Two claims, so two citations. The test only backs the second.
            // The first is a control-flow fact one line above the wrapper.
            evidence: 'table_body.dart returns the row unwrapped when '
                '!rowTooltipTheme.enabled; test/row_tooltip_test.dart, '
                '"TooltipBehavior.always leaves no room for the card"',
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
            // The direction matters. The builder is not called and its result
            // discarded; the table never calls it, because a merged row stands
            // for several data rows and there is no single one to hand over.
            effect: 'The card is never built for a merged row. It stands for '
                'several data rows, so there is no single one to build from.',
            evidence: 'table_body.dart returns the row unwrapped when '
                '_getMergedGroupForRow is non-null, before calling the builder; '
                'test/row_tooltip_test.dart, "a merged row carries no card"',
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
        interactions: [
          Interaction(
            otherFeatureId: 'mergedRows',
            effect: 'A merged group is as tall as its members added up, and '
                'each member is drawn at the height you returned for it — not '
                'at an equal share of the group. Before 2.17.0 it was an equal '
                'share, so a 48/96/48 group drew three 64s.',
            evidence: 'table_plus_merged_row.dart `_sizeMemberCell`; '
                'test/merged_row_member_heights_test.dart, "differing heights: '
                'grouped matches ungrouped, cell for cell"',
          ),
        ],
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

/// The feature with this id, in *this* app's spec.
///
/// The gallery's [featureIn] takes a spec because it has none of its own; this
/// binds it to ours so the call sites read the way they always have.
SettingFeature featureById(String id) => featureIn(settingsSpec, id);
