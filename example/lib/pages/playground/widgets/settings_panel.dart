import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'performance_monitor.dart';

/// Playground settings configuration
class PlaygroundSettings {
  // Data settings
  final int rowCount;

  // Style settings
  final double columnMinWidth;
  final double rowHeight;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;

  // Feature toggles
  final bool sortingEnabled;
  final bool selectionEnabled;
  final SelectionMode selectionMode;
  final bool editingEnabled;
  final bool mergedRowsEnabled;
  final bool columnReorderEnabled;
  final bool resizableEnabled;
  final bool stretchLastColumn;
  final double resizeHandleWidth;
  final bool showAlternateRows;
  final bool showDividers;
  final bool dynamicRowHeight;
  final bool dimInactiveRows;
  final bool showCheckboxColumn;
  final double checkboxTapTargetSize;
  final bool selectAllEnabled;
  final bool dragSelectionEnabled;
  final bool cellTapTogglesCheckbox;
  final bool showRowCheckbox;
  final SortCycleOrder sortCycleOrder;
  final TooltipBehavior tooltipBehavior;
  final TooltipBehavior headerTooltipBehavior;
  final bool tooltipEnabled;
  final int tooltipWaitDurationMs;
  final bool showTooltipFormatter;
  final bool showTooltipBuilder;

  // Font settings
  final String fontFamily;

  // Header border/divider settings
  final bool headerTopBorderShow;
  final double headerTopBorderThickness;
  final bool headerBottomBorderShow;
  final double headerBottomBorderThickness;
  final bool headerVerticalDividerShow;
  final double headerVerticalDividerThickness;
  final double headerVerticalDividerIndent;
  final double headerVerticalDividerEndIndent;

  // Sort icon settings
  final double sortIconWidth;

  // Resize handle settings
  final double resizeHandleThickness;
  final double resizeHandleIndent;
  final double resizeHandleEndIndent;

  const PlaygroundSettings({
    this.rowCount = 100,
    this.columnMinWidth = 50.0,
    this.rowHeight = 50.0,
    this.fontSize = 14.0,
    this.horizontalPadding = 16.0,
    this.verticalPadding = 12.0,
    this.sortingEnabled = true,
    this.selectionEnabled = true,
    this.selectionMode = SelectionMode.multiple,
    this.editingEnabled = true,
    this.mergedRowsEnabled = false,
    this.columnReorderEnabled = true,
    this.resizableEnabled = true,
    this.stretchLastColumn = false,
    this.resizeHandleWidth = 8.0,
    this.showAlternateRows = true,
    this.showDividers = true,
    this.dynamicRowHeight = false,
    this.dimInactiveRows = false,
    this.showCheckboxColumn = true,
    this.checkboxTapTargetSize = 18.0,
    this.selectAllEnabled = true,
    this.dragSelectionEnabled = false,
    this.cellTapTogglesCheckbox = false,
    this.showRowCheckbox = true,
    this.sortCycleOrder = SortCycleOrder.ascendingFirst,
    this.tooltipBehavior = TooltipBehavior.always,
    this.headerTooltipBehavior = TooltipBehavior.always,
    this.tooltipEnabled = true,
    this.tooltipWaitDurationMs = 500,
    this.showTooltipFormatter = false,
    this.showTooltipBuilder = false,
    this.fontFamily = 'default',
    this.headerTopBorderShow = true,
    this.headerTopBorderThickness = 2.0,
    this.headerBottomBorderShow = true,
    this.headerBottomBorderThickness = 1.0,
    this.headerVerticalDividerShow = true,
    this.headerVerticalDividerThickness = 1.0,
    this.headerVerticalDividerIndent = 0.0,
    this.headerVerticalDividerEndIndent = 0.0,
    this.sortIconWidth = 14.0,
    this.resizeHandleThickness = 2.0,
    this.resizeHandleIndent = 0.0,
    this.resizeHandleEndIndent = 0.0,
  });

  PlaygroundSettings copyWith({
    int? rowCount,
    double? columnMinWidth,
    double? rowHeight,
    double? fontSize,
    double? horizontalPadding,
    double? verticalPadding,
    bool? sortingEnabled,
    bool? selectionEnabled,
    SelectionMode? selectionMode,
    bool? editingEnabled,
    bool? mergedRowsEnabled,
    bool? columnReorderEnabled,
    bool? resizableEnabled,
    bool? stretchLastColumn,
    double? resizeHandleWidth,
    bool? showAlternateRows,
    bool? showDividers,
    bool? dynamicRowHeight,
    bool? dimInactiveRows,
    bool? showCheckboxColumn,
    double? checkboxTapTargetSize,
    bool? selectAllEnabled,
    bool? dragSelectionEnabled,
    bool? cellTapTogglesCheckbox,
    bool? showRowCheckbox,
    SortCycleOrder? sortCycleOrder,
    TooltipBehavior? tooltipBehavior,
    TooltipBehavior? headerTooltipBehavior,
    bool? tooltipEnabled,
    int? tooltipWaitDurationMs,
    bool? showTooltipFormatter,
    bool? showTooltipBuilder,
    String? fontFamily,
    bool? headerTopBorderShow,
    double? headerTopBorderThickness,
    bool? headerBottomBorderShow,
    double? headerBottomBorderThickness,
    bool? headerVerticalDividerShow,
    double? headerVerticalDividerThickness,
    double? headerVerticalDividerIndent,
    double? headerVerticalDividerEndIndent,
    double? sortIconWidth,
    double? resizeHandleThickness,
    double? resizeHandleIndent,
    double? resizeHandleEndIndent,
  }) {
    return PlaygroundSettings(
      rowCount: rowCount ?? this.rowCount,
      columnMinWidth: columnMinWidth ?? this.columnMinWidth,
      rowHeight: rowHeight ?? this.rowHeight,
      fontSize: fontSize ?? this.fontSize,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      sortingEnabled: sortingEnabled ?? this.sortingEnabled,
      selectionEnabled: selectionEnabled ?? this.selectionEnabled,
      selectionMode: selectionMode ?? this.selectionMode,
      editingEnabled: editingEnabled ?? this.editingEnabled,
      mergedRowsEnabled: mergedRowsEnabled ?? this.mergedRowsEnabled,
      columnReorderEnabled: columnReorderEnabled ?? this.columnReorderEnabled,
      resizableEnabled: resizableEnabled ?? this.resizableEnabled,
      stretchLastColumn: stretchLastColumn ?? this.stretchLastColumn,
      resizeHandleWidth: resizeHandleWidth ?? this.resizeHandleWidth,
      showAlternateRows: showAlternateRows ?? this.showAlternateRows,
      showDividers: showDividers ?? this.showDividers,
      dynamicRowHeight: dynamicRowHeight ?? this.dynamicRowHeight,
      dimInactiveRows: dimInactiveRows ?? this.dimInactiveRows,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      checkboxTapTargetSize:
          checkboxTapTargetSize ?? this.checkboxTapTargetSize,
      selectAllEnabled: selectAllEnabled ?? this.selectAllEnabled,
      dragSelectionEnabled: dragSelectionEnabled ?? this.dragSelectionEnabled,
      cellTapTogglesCheckbox:
          cellTapTogglesCheckbox ?? this.cellTapTogglesCheckbox,
      showRowCheckbox: showRowCheckbox ?? this.showRowCheckbox,
      sortCycleOrder: sortCycleOrder ?? this.sortCycleOrder,
      tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
      headerTooltipBehavior:
          headerTooltipBehavior ?? this.headerTooltipBehavior,
      tooltipEnabled: tooltipEnabled ?? this.tooltipEnabled,
      tooltipWaitDurationMs:
          tooltipWaitDurationMs ?? this.tooltipWaitDurationMs,
      showTooltipFormatter: showTooltipFormatter ?? this.showTooltipFormatter,
      showTooltipBuilder: showTooltipBuilder ?? this.showTooltipBuilder,
      fontFamily: fontFamily ?? this.fontFamily,
      headerTopBorderShow: headerTopBorderShow ?? this.headerTopBorderShow,
      headerTopBorderThickness:
          headerTopBorderThickness ?? this.headerTopBorderThickness,
      headerBottomBorderShow:
          headerBottomBorderShow ?? this.headerBottomBorderShow,
      headerBottomBorderThickness:
          headerBottomBorderThickness ?? this.headerBottomBorderThickness,
      headerVerticalDividerShow:
          headerVerticalDividerShow ?? this.headerVerticalDividerShow,
      headerVerticalDividerThickness:
          headerVerticalDividerThickness ?? this.headerVerticalDividerThickness,
      headerVerticalDividerIndent:
          headerVerticalDividerIndent ?? this.headerVerticalDividerIndent,
      headerVerticalDividerEndIndent:
          headerVerticalDividerEndIndent ?? this.headerVerticalDividerEndIndent,
      sortIconWidth: sortIconWidth ?? this.sortIconWidth,
      resizeHandleThickness:
          resizeHandleThickness ?? this.resizeHandleThickness,
      resizeHandleIndent: resizeHandleIndent ?? this.resizeHandleIndent,
      resizeHandleEndIndent:
          resizeHandleEndIndent ?? this.resizeHandleEndIndent,
    );
  }
}

/// Settings panel widget for the playground
///
/// Provides controls for:
/// - Data quantity (slider + quick buttons)
/// - Table styling (row height, font size, padding)
/// - Feature toggles (sorting, selection, editing, etc.)
/// - Performance monitoring display
class SettingsPanel extends StatelessWidget {
  final PlaygroundSettings settings;
  final PerformanceMetrics performanceMetrics;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final VoidCallback onGenerateData;
  final VoidCallback? onRandomizeWidths;
  final bool isGenerating;

  const SettingsPanel({
    super.key,
    required this.settings,
    required this.performanceMetrics,
    required this.onSettingsChanged,
    required this.onGenerateData,
    this.onRandomizeWidths,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Data Settings
            _buildDataSettings(),
            const SizedBox(height: 24),

            // Style Settings
            _buildStyleSettings(),
            const SizedBox(height: 24),

            // Header Border/Divider Settings
            _buildHeaderBorderSettings(),
            const SizedBox(height: 24),

            // Feature Toggles
            _buildFeatureToggles(),
            const SizedBox(height: 24),

            // Tooltip Settings
            _buildTooltipSettings(),
            const SizedBox(height: 24),

            // Performance Monitor
            PerformanceMonitor(metrics: performanceMetrics),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.science, color: Colors.blue.shade700, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Playground',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Test FlutterTablePlus with various configurations',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDataSettings() {
    return _buildSection(
      title: 'Data Settings',
      icon: Icons.data_array,
      color: Colors.green.shade700,
      borderColor: Colors.green.shade200,
      initiallyExpanded: true,
      children: [
        const SizedBox(height: 12),

        // Row count label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Row Count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatNumber(settings.rowCount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Logarithmic slider (10 to 100,000)
        _buildLogSlider(
          value: settings.rowCount.toDouble(),
          min: 10,
          max: 100000,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(rowCount: value.round()));
          },
        ),
        const SizedBox(height: 16),

        // Quick select buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickButton('100', 100),
            _buildQuickButton('1K', 1000),
            _buildQuickButton('10K', 10000),
            _buildQuickButton('100K', 100000),
          ],
        ),
        const SizedBox(height: 16),

        // Generate button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isGenerating ? null : onGenerateData,
            icon: isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(isGenerating ? 'Generating...' : 'Generate Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSettings() {
    return _buildSection(
      title: 'Style Settings',
      icon: Icons.palette,
      color: Colors.purple.shade700,
      borderColor: Colors.purple.shade200,
      children: [
        const SizedBox(height: 12),

        // Font family
        _buildDropdownRow<String>(
          label: 'Font Family',
          value: settings.fontFamily,
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
            onSettingsChanged(settings.copyWith(fontFamily: value));
          },
        ),
        const SizedBox(height: 16),

        // Column min width
        _buildSliderSetting(
          label: 'Col Min Width',
          value: settings.columnMinWidth,
          min: 20,
          max: 150,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(columnMinWidth: value));
          },
        ),
        const SizedBox(height: 12),

        // Randomize column widths button
        if (onRandomizeWidths != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRandomizeWidths,
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('Randomize Column Widths'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple.shade700,
                side: BorderSide(color: Colors.purple.shade300),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Row height
        _buildSliderSetting(
          label: 'Row Height',
          value: settings.rowHeight,
          min: 30,
          max: 100,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(rowHeight: value));
          },
        ),
        const SizedBox(height: 16),

        // Font size
        _buildSliderSetting(
          label: 'Font Size',
          value: settings.fontSize,
          min: 10,
          max: 24,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(fontSize: value));
          },
        ),
        const SizedBox(height: 16),

        // Horizontal padding
        _buildSliderSetting(
          label: 'H-Padding',
          value: settings.horizontalPadding,
          min: 4,
          max: 32,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(horizontalPadding: value));
          },
        ),
        const SizedBox(height: 16),

        // Vertical padding
        _buildSliderSetting(
          label: 'V-Padding',
          value: settings.verticalPadding,
          min: 4,
          max: 24,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(verticalPadding: value));
          },
        ),
        const SizedBox(height: 16),

        // Checkbox tap target size
        _buildSliderSetting(
          label: 'Checkbox Tap Size',
          value: settings.checkboxTapTargetSize,
          min: 18,
          max: 56,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(checkboxTapTargetSize: value));
          },
        ),
        const SizedBox(height: 16),

        // Sort icon width
        _buildSliderSetting(
          label: 'Sort Icon Width',
          value: settings.sortIconWidth,
          min: 8,
          max: 32,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(sortIconWidth: value));
          },
        ),
      ],
    );
  }

  Widget _buildHeaderBorderSettings() {
    return _buildSection(
      title: 'Header Border / Divider',
      icon: Icons.border_all,
      color: Colors.teal.shade700,
      borderColor: Colors.teal.shade200,
      children: [
        // --- Top Border ---
        _buildSwitchTile(
          label: 'Top Border',
          value: settings.headerTopBorderShow,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(headerTopBorderShow: value));
          },
        ),
        if (settings.headerTopBorderShow)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildSliderSetting(
              label: 'Thickness',
              value: settings.headerTopBorderThickness,
              min: 0.5,
              max: 6,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerTopBorderThickness: value));
              },
            ),
          ),
        const SizedBox(height: 4),

        // --- Bottom Border ---
        _buildSwitchTile(
          label: 'Bottom Border',
          value: settings.headerBottomBorderShow,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(headerBottomBorderShow: value));
          },
        ),
        if (settings.headerBottomBorderShow)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildSliderSetting(
              label: 'Thickness',
              value: settings.headerBottomBorderThickness,
              min: 0.5,
              max: 6,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerBottomBorderThickness: value));
              },
            ),
          ),

        const Divider(height: 24),

        // --- Vertical Divider ---
        _buildSwitchTile(
          label: 'Vertical Divider',
          value: settings.headerVerticalDividerShow,
          onChanged: (value) {
            onSettingsChanged(
                settings.copyWith(headerVerticalDividerShow: value));
          },
        ),
        if (settings.headerVerticalDividerShow) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildSliderSetting(
              label: 'Thickness',
              value: settings.headerVerticalDividerThickness,
              min: 0.5,
              max: 6,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerVerticalDividerThickness: value));
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildSliderSetting(
              label: 'Indent (top)',
              value: settings.headerVerticalDividerIndent,
              min: 0,
              max: 24,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerVerticalDividerIndent: value));
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildSliderSetting(
              label: 'End Indent (bottom)',
              value: settings.headerVerticalDividerEndIndent,
              min: 0,
              max: 24,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerVerticalDividerEndIndent: value));
              },
            ),
          ),
        ],

        const Divider(height: 24),

        // --- Resize Handle ---
        if (settings.resizableEnabled) ...[
          _buildSliderSetting(
            label: 'Handle Hit Width',
            value: settings.resizeHandleWidth,
            min: 4,
            max: 24,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(resizeHandleWidth: value));
            },
          ),
          const SizedBox(height: 8),
          _buildSliderSetting(
            label: 'Handle Thickness',
            value: settings.resizeHandleThickness,
            min: 1,
            max: 6,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(resizeHandleThickness: value));
            },
          ),
          const SizedBox(height: 8),
          _buildSliderSetting(
            label: 'Handle Indent (top)',
            value: settings.resizeHandleIndent,
            min: 0,
            max: 24,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(resizeHandleIndent: value));
            },
          ),
          const SizedBox(height: 8),
          _buildSliderSetting(
            label: 'Handle End Indent',
            value: settings.resizeHandleEndIndent,
            min: 0,
            max: 24,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(resizeHandleEndIndent: value));
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureToggles() {
    return _buildSection(
      title: 'Feature Toggles',
      icon: Icons.toggle_on,
      color: Colors.orange.shade700,
      borderColor: Colors.orange.shade200,
      children: [
        const SizedBox(height: 12),

        _buildSwitchTile(
          label: 'Sorting',
          value: settings.sortingEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(sortingEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Editing',
          value: settings.editingEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(editingEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Column Reorder',
          value: settings.columnReorderEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(columnReorderEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Column Resize',
          value: settings.resizableEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(resizableEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Stretch Last Column',
          value: settings.stretchLastColumn,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(stretchLastColumn: value));
          },
        ),

        _buildSwitchTile(
          label: 'Alternate Rows',
          value: settings.showAlternateRows,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(showAlternateRows: value));
          },
        ),

        _buildSwitchTile(
          label: 'Show Dividers',
          value: settings.showDividers,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(showDividers: value));
          },
        ),

        _buildSwitchTile(
          label: 'Merged Rows',
          value: settings.mergedRowsEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(mergedRowsEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Dynamic Row Height',
          value: settings.dynamicRowHeight,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(dynamicRowHeight: value));
          },
        ),

        _buildSwitchTile(
          label: 'Dim Inactive Rows',
          value: settings.dimInactiveRows,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(dimInactiveRows: value));
          },
        ),

        _buildSwitchTile(
          label: 'Selection (Checkbox)',
          value: settings.selectionEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(selectionEnabled: value));
          },
        ),

        if (settings.selectionEnabled) ...[
          _buildSwitchTile(
            label: 'Show Checkbox Column',
            value: settings.showCheckboxColumn,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(showCheckboxColumn: value));
            },
          ),
          _buildSwitchTile(
            label: 'Select All',
            value: settings.selectAllEnabled,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(selectAllEnabled: value));
            },
          ),
          _buildSwitchTile(
            label: 'Drag Selection',
            value: settings.dragSelectionEnabled,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(dragSelectionEnabled: value));
            },
          ),
          _buildSwitchTile(
            label: 'Cell Tap Toggles Checkbox',
            value: settings.cellTapTogglesCheckbox,
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(cellTapTogglesCheckbox: value));
            },
          ),
          _buildSwitchTile(
            label: 'Show Row Checkbox',
            value: settings.showRowCheckbox,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(showRowCheckbox: value));
            },
          ),
        ],

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // Selection mode dropdown
        _buildDropdownRow<SelectionMode>(
          label: 'Selection Mode',
          value: settings.selectionMode,
          items: SelectionMode.values,
          itemLabel: (mode) => mode.name.toUpperCase(),
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(selectionMode: value));
          },
        ),
        const SizedBox(height: 8),

        // Sort cycle order dropdown
        _buildDropdownRow<SortCycleOrder>(
          label: 'Sort Cycle',
          value: settings.sortCycleOrder,
          items: SortCycleOrder.values,
          itemLabel: (order) => order == SortCycleOrder.ascendingFirst
              ? 'ASC First'
              : 'DESC First',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(sortCycleOrder: value));
          },
        ),
      ],
    );
  }

  Widget _buildTooltipSettings() {
    return _buildSection(
      title: 'Tooltip Settings',
      icon: Icons.chat_bubble_outline,
      color: Colors.indigo.shade700,
      borderColor: Colors.indigo.shade200,
      children: [
        const SizedBox(height: 12),

        // Tooltip enabled toggle
        _buildSwitchTile(
          label: 'Tooltip Enabled',
          value: settings.tooltipEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(tooltipEnabled: value));
          },
        ),

        if (settings.tooltipEnabled) ...[
          const SizedBox(height: 8),

          // Cell tooltip behavior
          _buildDropdownRow<TooltipBehavior>(
            label: 'Cell Tooltip',
            value: settings.tooltipBehavior,
            items: TooltipBehavior.values,
            itemLabel: (behavior) => switch (behavior) {
              TooltipBehavior.always => 'Always',
              TooltipBehavior.never => 'Never',
              TooltipBehavior.onlyTextOverflow => 'On Overflow',
            },
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(tooltipBehavior: value));
            },
          ),
          const SizedBox(height: 4),

          // Header tooltip behavior
          _buildDropdownRow<TooltipBehavior>(
            label: 'Header Tooltip',
            value: settings.headerTooltipBehavior,
            items: TooltipBehavior.values,
            itemLabel: (behavior) => switch (behavior) {
              TooltipBehavior.always => 'Always',
              TooltipBehavior.never => 'Never',
              TooltipBehavior.onlyTextOverflow => 'On Overflow',
            },
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(headerTooltipBehavior: value));
            },
          ),

          const Divider(height: 24),

          // Wait duration slider
          _buildSliderSetting(
            label: 'Wait Duration',
            value: settings.tooltipWaitDurationMs.toDouble(),
            min: 0,
            max: 2000,
            unit: 'ms',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(tooltipWaitDurationMs: value.round()));
            },
          ),

          const Divider(height: 24),

          // Demo: tooltipFormatter
          _buildSwitchTile(
            label: 'tooltipFormatter (Email)',
            value: settings.showTooltipFormatter,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(showTooltipFormatter: value));
            },
          ),
          if (settings.showTooltipFormatter)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                'Email column shows "Send to: {email}" tooltip',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),

          // Demo: tooltipBuilder
          _buildSwitchTile(
            label: 'tooltipBuilder (Name)',
            value: settings.showTooltipBuilder,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(showTooltipBuilder: value));
            },
          ),
          if (settings.showTooltipBuilder)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                'Name column shows rich widget tooltip with employee details',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        children: children,
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.round()}$unit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 2).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        DropdownButton<T>(
          value: value,
          onChanged: (T? newValue) {
            if (newValue != null) onChanged(newValue);
          },
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                itemLabel(item),
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    // Convert to logarithmic scale
    final logMin = math.log(min) / math.ln10;
    final logMax = math.log(max) / math.ln10;
    final logValue = math.log(value) / math.ln10;

    return Slider(
      value: logValue,
      min: logMin,
      max: logMax,
      divisions: 100,
      onChanged: (logVal) {
        final actualValue = math.pow(10, logVal).toDouble();
        onChanged(actualValue);
      },
    );
  }

  Widget _buildQuickButton(String label, int value) {
    final isSelected = settings.rowCount == value;
    return ElevatedButton(
      onPressed: () {
        onSettingsChanged(settings.copyWith(rowCount: value));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.green.shade600 : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
