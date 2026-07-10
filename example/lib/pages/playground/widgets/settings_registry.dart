import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../models/playground_settings.dart';
import 'settings_controls.dart';

/// How each setting is drawn.
///
/// The description in `settings_spec.dart` says what the settings are and what
/// owns what; it stays pure data, so the invariants that guard it run without
/// pumping a widget. This says how to draw one of them, which is not data: a
/// slider needs bounds and a unit, a dropdown needs its item type and a name
/// for each value, and every control needs a getter and a callback.
///
/// The two are held together by `test/settings_registry_test.dart`: the ids
/// they cover must be the same set. A described id with no entry is a control
/// that vanishes; an entry the description never mentions is one nobody can
/// reach.
typedef ControlBuilder = SettingsControl Function(
  PlaygroundSettings s,
  ValueChanged<PlaygroundSettings> onChanged,
);

/// Attaches an explanatory line under [control], inside it rather than beside
/// it — a note that sits outside the [SettingsControl] is invisible to the
/// panel's search, which only looks at labelled controls.
SettingsControl _withNote(SettingsControl control, String? note) {
  if (note == null) return control;
  return SettingsControl(
    id: control.id,
    label: control.label,
    indent: control.indent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        control.child,
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            note,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
      ],
    ),
  );
}

final Map<String, ControlBuilder> settingsRegistry = {
  // data > data
  'rowCount': (s, onChanged) => buildLogSlider(
        id: 'rowCount',
        label: 'Row Count',
        value: s.rowCount.toDouble(),
        min: 5,
        max: 100000,
        onChanged: (value) {
          onChanged(s.copyWith(rowCount: value.round()));
        },
      ),

  // interaction > sorting
  'sortingEnabled': (s, onChanged) => buildSwitchTile(
        id: 'sortingEnabled',
        label: 'Sorting',
        value: s.sortingEnabled,
        onChanged: (value) {
          onChanged(s.copyWith(sortingEnabled: value));
        },
      ),
  'sortCycleOrder': (s, onChanged) => buildDropdownRow<SortCycleOrder>(
        id: 'sortCycleOrder',
        label: 'Sort Cycle',
        value: s.sortCycleOrder,
        items: SortCycleOrder.values,
        itemLabel: (order) =>
            order == SortCycleOrder.ascendingFirst ? 'ASC First' : 'DESC First',
        onChanged: (value) {
          onChanged(s.copyWith(sortCycleOrder: value));
        },
      ),

  // interaction > selection
  'selectionEnabled': (s, onChanged) => buildSwitchTile(
        id: 'selectionEnabled',
        label: 'Selection (Checkbox)',
        value: s.selectionEnabled,
        onChanged: (value) {
          onChanged(s.copyWith(selectionEnabled: value));
        },
      ),
  'selectionMode': (s, onChanged) => buildDropdownRow<SelectionMode>(
        id: 'selectionMode',
        label: 'Selection Mode',
        value: s.selectionMode,
        items: SelectionMode.values,
        itemLabel: (mode) => mode.name.toUpperCase(),
        onChanged: (value) {
          onChanged(s.copyWith(selectionMode: value));
        },
      ),
  'showCheckboxColumn': (s, onChanged) => buildSwitchTile(
        id: 'showCheckboxColumn',
        label: 'Show Checkbox Column',
        value: s.showCheckboxColumn,
        onChanged: (value) {
          onChanged(s.copyWith(showCheckboxColumn: value));
        },
      ),
  'selectAllEnabled': (s, onChanged) => buildSwitchTile(
        id: 'selectAllEnabled',
        label: 'Select All',
        value: s.selectAllEnabled,
        onChanged: (value) {
          onChanged(s.copyWith(selectAllEnabled: value));
        },
      ),
  'showRowCheckbox': (s, onChanged) => buildSwitchTile(
        id: 'showRowCheckbox',
        label: 'Show Row Checkbox',
        value: s.showRowCheckbox,
        onChanged: (value) {
          onChanged(s.copyWith(showRowCheckbox: value));
        },
      ),
  'cellTapTogglesCheckbox': (s, onChanged) => buildSwitchTile(
        id: 'cellTapTogglesCheckbox',
        label: 'Cell Tap Toggles Checkbox',
        value: s.cellTapTogglesCheckbox,
        onChanged: (value) {
          onChanged(s.copyWith(cellTapTogglesCheckbox: value));
        },
      ),

  // interaction > dragSelection
  'dragSelectionEnabled': (s, onChanged) => buildSwitchTile(
        id: 'dragSelectionEnabled',
        label: 'Drag Selection',
        value: s.dragSelectionEnabled,
        onChanged: (value) {
          onChanged(s.copyWith(dragSelectionEnabled: value));
        },
      ),

  // interaction > editing
  'editingEnabled': (s, onChanged) => buildSwitchTile(
        id: 'editingEnabled',
        label: 'Editing',
        value: s.editingEnabled,
        onChanged: (value) {
          onChanged(s.copyWith(editingEnabled: value));
        },
      ),

  // interaction > columnReorder
  'columnReorderEnabled': (s, onChanged) => buildSwitchTile(
        id: 'columnReorderEnabled',
        label: 'Column Reorder',
        value: s.columnReorderEnabled,
        onChanged: (value) {
          onChanged(s.copyWith(columnReorderEnabled: value));
        },
      ),

  // interaction > resizing
  'resizableEnabled': (s, onChanged) => buildSwitchTile(
        id: 'resizableEnabled',
        label: 'Column Resize',
        value: s.resizableEnabled,
        onChanged: (value) {
          onChanged(s.copyWith(resizableEnabled: value));
        },
      ),
  'columnMinWidth': (s, onChanged) => buildSliderSetting(
        id: 'columnMinWidth',
        label: 'Col Min Width',
        value: s.columnMinWidth,
        min: 20,
        max: 150,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(columnMinWidth: value));
        },
      ),
  'stretchLastColumn': (s, onChanged) => buildSwitchTile(
        id: 'stretchLastColumn',
        label: 'Stretch Last Column',
        value: s.stretchLastColumn,
        onChanged: (value) {
          onChanged(s.copyWith(stretchLastColumn: value));
        },
      ),
  'resizeHandleWidth': (s, onChanged) => buildSliderSetting(
        id: 'resizeHandleWidth',
        label: 'Handle Hit Width',
        value: s.resizeHandleWidth,
        min: 4,
        max: 24,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(resizeHandleWidth: value));
        },
      ),
  'resizeHandleThickness': (s, onChanged) => buildSliderSetting(
        id: 'resizeHandleThickness',
        label: 'Handle Thickness',
        value: s.resizeHandleThickness,
        min: 1,
        max: 6,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(resizeHandleThickness: value));
        },
      ),
  'resizeHandleIndent': (s, onChanged) => buildSliderSetting(
        id: 'resizeHandleIndent',
        label: 'Handle Indent (top)',
        value: s.resizeHandleIndent,
        min: 0,
        max: 24,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(resizeHandleIndent: value));
        },
      ),
  'resizeHandleEndIndent': (s, onChanged) => buildSliderSetting(
        id: 'resizeHandleEndIndent',
        label: 'Handle End Indent',
        value: s.resizeHandleEndIndent,
        min: 0,
        max: 24,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(resizeHandleEndIndent: value));
        },
      ),

  // interaction > zoom
  'scale': (s, onChanged) => buildSliderSetting(
        id: 'scale',
        label: 'Scale',
        value: s.scale,
        min: 0.25,
        max: 3.0,
        unit: 'x',
        decimalPlaces: 2,
        onChanged: (value) {
          onChanged(s.copyWith(scale: value));
        },
      ),
  'blockModifierScroll': (s, onChanged) => buildSwitchTile(
        id: 'blockModifierScroll',
        label: 'Block Modifier+Scroll',
        value: s.blockModifierScroll,
        onChanged: (value) {
          onChanged(s.copyWith(blockModifierScroll: value));
        },
      ),

  // content > tooltips
  'tooltipEnabled': (s, onChanged) => _withNote(
        buildSwitchTile(
          id: 'tooltipEnabled',
          label: 'Tooltip Enabled',
          value: s.tooltipEnabled,
          onChanged: (value) {
            onChanged(s.copyWith(tooltipEnabled: value));
          },
        ),
        'Off silences the row card too, not just cells and headers',
      ),
  'tooltipBehavior': (s, onChanged) => buildDropdownRow<TooltipBehavior>(
        id: 'tooltipBehavior',
        label: 'Cell Tooltip',
        value: s.tooltipBehavior,
        items: TooltipBehavior.values,
        itemLabel: (behavior) => switch (behavior) {
          TooltipBehavior.always => 'Always',
          TooltipBehavior.never => 'Never',
          TooltipBehavior.onlyTextOverflow => 'On Overflow',
        },
        onChanged: (value) {
          onChanged(s.copyWith(tooltipBehavior: value));
        },
      ),
  'headerTooltipBehavior': (s, onChanged) => buildDropdownRow<TooltipBehavior>(
        id: 'headerTooltipBehavior',
        label: 'Header Tooltip',
        value: s.headerTooltipBehavior,
        items: TooltipBehavior.values,
        itemLabel: (behavior) => switch (behavior) {
          TooltipBehavior.always => 'Always',
          TooltipBehavior.never => 'Never',
          TooltipBehavior.onlyTextOverflow => 'On Overflow',
        },
        onChanged: (value) {
          onChanged(s.copyWith(headerTooltipBehavior: value));
        },
      ),
  'tooltipWaitDurationMs': (s, onChanged) => buildSliderSetting(
        id: 'tooltipWaitDurationMs',
        label: 'Wait Duration',
        value: s.tooltipWaitDurationMs.toDouble(),
        min: 0,
        max: 2000,
        unit: 'ms',
        onChanged: (value) {
          onChanged(s.copyWith(tooltipWaitDurationMs: value.round()));
        },
      ),
  'tooltipDirection': (s, onChanged) => buildDropdownRow<TooltipDirection>(
        id: 'tooltipDirection',
        label: 'Direction',
        value: s.tooltipDirection,
        items: TooltipDirection.values,
        itemLabel: (d) => switch (d) {
          TooltipDirection.top => 'Top',
          TooltipDirection.bottom => 'Bottom',
          TooltipDirection.left => 'Left',
          TooltipDirection.right => 'Right',
        },
        onChanged: (value) {
          onChanged(s.copyWith(tooltipDirection: value));
        },
      ),
  'tooltipAnchor': (s, onChanged) => _withNote(
        buildDropdownRow<TooltipAnchor>(
          id: 'tooltipAnchor',
          label: 'Cell Anchor',
          value: s.tooltipAnchor,
          items: TooltipAnchor.values,
          itemLabel: (a) => switch (a) {
            TooltipAnchor.child => 'Child',
            TooltipAnchor.pointer => 'Pointer',
          },
          onChanged: (value) {
            onChanged(s.copyWith(tooltipAnchor: value));
          },
        ),
        'The row card always anchors at the pointer; it ignores this',
      ),
  'headerTooltipAnchor': (s, onChanged) =>
      buildDropdownRow<HeaderTooltipAnchor>(
        id: 'headerTooltipAnchor',
        label: 'Header Anchor',
        value: s.headerTooltipAnchor,
        items: HeaderTooltipAnchor.values,
        itemLabel: (a) => switch (a) {
          HeaderTooltipAnchor.followCells => 'Follow Cells',
          HeaderTooltipAnchor.child => 'Child',
          HeaderTooltipAnchor.pointer => 'Pointer',
        },
        onChanged: (value) {
          onChanged(s.copyWith(headerTooltipAnchor: value));
        },
      ),
  'tooltipAlignment': (s, onChanged) => _withNote(
        buildDropdownRow<TooltipAlignment>(
          id: 'tooltipAlignment',
          label: 'Alignment',
          value: s.tooltipAlignment,
          items: TooltipAlignment.values,
          itemLabel: (a) => switch (a) {
            TooltipAlignment.start => 'Start',
            TooltipAlignment.center => 'Center',
            TooltipAlignment.end => 'End',
            TooltipAlignment.startTargetCenter => 'Start Target Center',
            TooltipAlignment.endTargetCenter => 'End Target Center',
          },
          onChanged: (value) {
            onChanged(s.copyWith(tooltipAlignment: value));
          },
        ),
        s.tooltipAnchor == TooltipAnchor.pointer
            ? "Against the pointer there are no target edges, so this "
                "picks which of the tooltip's own edges lands on the cursor"
            : 'Picks which edge of the target the tooltip lines up with',
      ),
  'tooltipShowArrow': (s, onChanged) => buildSwitchTile(
        id: 'tooltipShowArrow',
        label: 'Show Arrow',
        value: s.tooltipShowArrow,
        onChanged: (value) {
          onChanged(s.copyWith(tooltipShowArrow: value));
        },
      ),
  'tooltipOffset': (s, onChanged) => buildSliderSetting(
        id: 'tooltipOffset',
        label: 'Offset',
        value: s.tooltipOffset,
        min: 0,
        max: 32,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(tooltipOffset: value.roundToDouble()));
        },
      ),
  'showTooltipFormatter': (s, onChanged) => _withNote(
        buildSwitchTile(
          id: 'showTooltipFormatter',
          label: 'tooltipFormatter (Email)',
          value: s.showTooltipFormatter,
          onChanged: (value) {
            onChanged(s.copyWith(showTooltipFormatter: value));
          },
        ),
        s.showTooltipFormatter
            ? 'Email column shows "Send to: {email}" tooltip'
            : null,
      ),
  'showTooltipBuilder': (s, onChanged) => _withNote(
        buildSwitchTile(
          id: 'showTooltipBuilder',
          label: 'tooltipBuilder (Name)',
          value: s.showTooltipBuilder,
          onChanged: (value) {
            onChanged(s.copyWith(showTooltipBuilder: value));
          },
        ),
        s.showTooltipBuilder
            ? 'Name column shows rich widget tooltip with employee details'
            : null,
      ),

  // content > rowCard
  'rowCardTooltip': (s, onChanged) => buildSwitchTile(
        id: 'rowCardTooltip',
        label: 'Row Card Tooltip',
        value: s.rowCardTooltip,
        onChanged: (value) {
          onChanged(s.copyWith(rowCardTooltip: value));
        },
      ),
  'rowCardWaitDurationMs': (s, onChanged) => buildSliderSetting(
        id: 'rowCardWaitDurationMs',
        label: 'Row Card Wait',
        value: s.rowCardWaitDurationMs.toDouble(),
        min: 0,
        max: 2000,
        unit: 'ms',
        onChanged: (value) {
          onChanged(s.copyWith(rowCardWaitDurationMs: value.round()));
        },
      ),

  // content > mergedRows
  'mergedRowsEnabled': (s, onChanged) => buildSwitchTile(
        id: 'mergedRowsEnabled',
        label: 'Merged Rows',
        value: s.mergedRowsEnabled,
        onChanged: (value) {
          onChanged(s.copyWith(mergedRowsEnabled: value));
        },
      ),

  // content > dynamicRowHeight
  'dynamicRowHeight': (s, onChanged) => buildSwitchTile(
        id: 'dynamicRowHeight',
        label: 'Dynamic Row Height',
        value: s.dynamicRowHeight,
        onChanged: (value) {
          onChanged(s.copyWith(dynamicRowHeight: value));
        },
      ),

  // content > dimRows
  'dimInactiveRows': (s, onChanged) => buildSwitchTile(
        id: 'dimInactiveRows',
        label: 'Dim Inactive Rows',
        value: s.dimInactiveRows,
        onChanged: (value) {
          onChanged(s.copyWith(dimInactiveRows: value));
        },
      ),

  // appearance > rowStyle
  'rowHeight': (s, onChanged) => buildSliderSetting(
        id: 'rowHeight',
        label: 'Row Height',
        value: s.rowHeight,
        min: 30,
        max: 100,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(rowHeight: value));
        },
      ),
  'fontSize': (s, onChanged) => buildSliderSetting(
        id: 'fontSize',
        label: 'Font Size',
        value: s.fontSize,
        min: 10,
        max: 24,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(fontSize: value));
        },
      ),
  'fontFamily': (s, onChanged) => buildDropdownRow<String>(
        id: 'fontFamily',
        label: 'Font Family',
        value: s.fontFamily,
        items: const [
          'default',
          'pretendard',
          'notoSansKr',
          'inter',
          'firaCode'
        ],
        itemLabel: (font) => switch (font) {
          'default' => 'Default (Roboto)',
          'pretendard' => 'Pretendard',
          'notoSansKr' => 'Noto Sans KR',
          'inter' => 'Inter',
          'firaCode' => 'Fira Code',
          _ => font,
        },
        onChanged: (value) {
          onChanged(s.copyWith(fontFamily: value));
        },
      ),
  'horizontalPadding': (s, onChanged) => buildSliderSetting(
        id: 'horizontalPadding',
        label: 'H-Padding',
        value: s.horizontalPadding,
        min: 4,
        max: 32,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(horizontalPadding: value));
        },
      ),
  'verticalPadding': (s, onChanged) => buildSliderSetting(
        id: 'verticalPadding',
        label: 'V-Padding',
        value: s.verticalPadding,
        min: 4,
        max: 24,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(verticalPadding: value));
        },
      ),
  'sortIconWidth': (s, onChanged) => buildSliderSetting(
        id: 'sortIconWidth',
        label: 'Sort Icon Width',
        value: s.sortIconWidth,
        min: 8,
        max: 32,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(sortIconWidth: value));
        },
      ),
  'checkboxTapTargetSize': (s, onChanged) => buildSliderSetting(
        id: 'checkboxTapTargetSize',
        label: 'Checkbox Tap Size',
        value: s.checkboxTapTargetSize,
        min: 18,
        max: 56,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(checkboxTapTargetSize: value));
        },
      ),

  // appearance > alternateRows
  'showAlternateRows': (s, onChanged) => buildSwitchTile(
        id: 'showAlternateRows',
        label: 'Alternate Rows',
        value: s.showAlternateRows,
        onChanged: (value) {
          onChanged(s.copyWith(showAlternateRows: value));
        },
      ),

  // appearance > bodyDividers
  'showDividers': (s, onChanged) => buildSwitchTile(
        id: 'showDividers',
        label: 'Show Dividers',
        value: s.showDividers,
        onChanged: (value) {
          onChanged(s.copyWith(showDividers: value));
        },
      ),

  // appearance > ink
  'splashColor': (s, onChanged) => buildDropdownRow<InkColorOption>(
        id: 'splashColor',
        label: 'Splash Color',
        value: s.splashColor,
        items: InkColorOption.values,
        itemLabel: (option) => option.label,
        onChanged: (option) {
          onChanged(s.copyWith(splashColor: option));
        },
      ),
  'hoverColor': (s, onChanged) => buildDropdownRow<InkColorOption>(
        id: 'hoverColor',
        label: 'Hover Color',
        value: s.hoverColor,
        items: InkColorOption.values,
        itemLabel: (option) => option.label,
        onChanged: (option) {
          onChanged(s.copyWith(hoverColor: option));
        },
      ),
  'highlightColor': (s, onChanged) => buildDropdownRow<InkColorOption>(
        id: 'highlightColor',
        label: 'Highlight Color',
        value: s.highlightColor,
        items: InkColorOption.values,
        itemLabel: (option) => option.label,
        onChanged: (option) {
          onChanged(s.copyWith(highlightColor: option));
        },
      ),

  // appearance > headerTopBorder
  'headerTopBorderShow': (s, onChanged) => buildSwitchTile(
        id: 'headerTopBorderShow',
        label: 'Top Border',
        value: s.headerTopBorderShow,
        onChanged: (value) {
          onChanged(s.copyWith(headerTopBorderShow: value));
        },
      ),
  'headerTopBorderThickness': (s, onChanged) => buildSliderSetting(
        id: 'headerTopBorderThickness',
        label: 'Thickness',
        value: s.headerTopBorderThickness,
        min: 0.5,
        max: 6,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(headerTopBorderThickness: value));
        },
        indent: true,
      ),

  // appearance > headerBottomBorder
  'headerBottomBorderShow': (s, onChanged) => buildSwitchTile(
        id: 'headerBottomBorderShow',
        label: 'Bottom Border',
        value: s.headerBottomBorderShow,
        onChanged: (value) {
          onChanged(s.copyWith(headerBottomBorderShow: value));
        },
      ),
  'headerBottomBorderThickness': (s, onChanged) => buildSliderSetting(
        id: 'headerBottomBorderThickness',
        label: 'Thickness',
        value: s.headerBottomBorderThickness,
        min: 0.5,
        max: 6,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(headerBottomBorderThickness: value));
        },
        indent: true,
      ),

  // appearance > headerVerticalDivider
  'headerVerticalDividerShow': (s, onChanged) => buildSwitchTile(
        id: 'headerVerticalDividerShow',
        label: 'Vertical Divider',
        value: s.headerVerticalDividerShow,
        onChanged: (value) {
          onChanged(s.copyWith(headerVerticalDividerShow: value));
        },
      ),
  'headerVerticalDividerThickness': (s, onChanged) => buildSliderSetting(
        id: 'headerVerticalDividerThickness',
        label: 'Thickness',
        value: s.headerVerticalDividerThickness,
        min: 0.5,
        max: 6,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(headerVerticalDividerThickness: value));
        },
        indent: true,
      ),
  'headerVerticalDividerIndent': (s, onChanged) => buildSliderSetting(
        id: 'headerVerticalDividerIndent',
        label: 'Indent (top)',
        value: s.headerVerticalDividerIndent,
        min: 0,
        max: 24,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(headerVerticalDividerIndent: value));
        },
        indent: true,
      ),
  'headerVerticalDividerEndIndent': (s, onChanged) => buildSliderSetting(
        id: 'headerVerticalDividerEndIndent',
        label: 'End Indent (bottom)',
        value: s.headerVerticalDividerEndIndent,
        min: 0,
        max: 24,
        unit: 'px',
        onChanged: (value) {
          onChanged(s.copyWith(headerVerticalDividerEndIndent: value));
        },
        indent: true,
      ),
};
