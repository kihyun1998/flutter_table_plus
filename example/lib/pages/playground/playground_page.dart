import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/employee.dart';
import 'models/playground_settings.dart';
import 'playground_columns.dart';
import 'playground_format.dart';
import 'utils/random_data_generator.dart';
import 'widgets/performance_monitor.dart';
import 'widgets/settings_panel.dart';

/// Interactive playground for testing FlutterTablePlus
///
/// Features:
/// - Dynamic data generation (10 to 100,000+ rows)
/// - Real-time style adjustments
/// - Performance monitoring
/// - All table features in one place
class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  // Settings
  PlaygroundSettings _settings = const PlaygroundSettings();

  // Data
  List<Employee> _data = [];
  List<Employee> _originalData = [];
  Map<String, TablePlusColumn<Employee>> _columns = {};

  // Performance metrics
  PerformanceMetrics _performanceMetrics = PerformanceMetrics(
    rowCount: 0,
    lastUpdate: DateTime.now(),
  );

  // Table state
  String? _currentSortColumn;
  SortDirection _currentSortDirection = SortDirection.none;
  Set<String> _selectedRows = {};
  bool _isGenerating = false;

  // Saved column widths (simulates DB/SharedPreferences persistence)
  final Map<String, double> _savedWidths = {};
  // Active initial widths passed to initialResizedWidths
  Map<String, double>? _activeInitialWidths;

  // Merged rows (if enabled)
  List<MergedRowGroup<Employee>> _mergedGroups = [];

  @override
  void initState() {
    super.initState();
    _columns = buildPlaygroundColumns(_settings);
    _generateData();
  }

  /// Initialize table columns

  /// The row tooltip's card. It draws its own surface, which is why the
  /// playground gives `rowTooltipTheme` a transparent, unpadded one.
  Widget _rowCard(Employee e) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              Chip(
                  label: Text(e.department),
                  visualDensity: VisualDensity.compact),
              Chip(
                  label: Text(e.position),
                  visualDensity: VisualDensity.compact),
            ],
          ),
          const SizedBox(height: 6),
          Text('performance ${e.performance.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  /// Generate random data based on current row count setting
  Future<void> _generateData() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    final stopwatch = Stopwatch()..start();

    // Generate data
    await Future.delayed(Duration.zero); // Allow UI to update
    final newData = RandomDataGenerator.generateEmployees(_settings.rowCount);

    stopwatch.stop();

    setState(() {
      _data = newData;
      _originalData = List.of(newData);
      _selectedRows.clear();
      _currentSortColumn = null;
      _currentSortDirection = SortDirection.none;
      _isGenerating = false;

      // Update performance metrics
      _performanceMetrics = _performanceMetrics.copyWith(
        rowCount: newData.length,
        dataGenerationTimeMs: stopwatch.elapsedMilliseconds,
        lastUpdate: DateTime.now(),
      );

      // Update merged groups if enabled
      if (_settings.mergedRowsEnabled) {
        _updateMergedGroups();
      }
    });

    debugPrint(
        '✅ Generated ${newData.length} rows in ${stopwatch.elapsedMilliseconds}ms');
  }

  /// Handle settings changes
  void _handleSettingsChanged(PlaygroundSettings newSettings) {
    setState(() {
      final oldSettings = _settings;
      _settings = newSettings;

      // Check if features changed that require column rebuild
      final needsColumnRebuild = newSettings.sortingEnabled !=
              oldSettings.sortingEnabled ||
          newSettings.editingEnabled != oldSettings.editingEnabled ||
          newSettings.tooltipBehavior != oldSettings.tooltipBehavior ||
          newSettings.headerTooltipBehavior !=
              oldSettings.headerTooltipBehavior ||
          newSettings.showTooltipFormatter !=
              oldSettings.showTooltipFormatter ||
          newSettings.showTooltipBuilder != oldSettings.showTooltipBuilder ||
          newSettings.columnMinWidth != oldSettings.columnMinWidth;

      if (needsColumnRebuild) {
        _columns = buildPlaygroundColumns(_settings);
      }

      // Clear selection when selection is disabled
      if (!newSettings.selectionEnabled && oldSettings.selectionEnabled) {
        _selectedRows.clear();
      }

      // Update merged groups if toggle changed
      if (newSettings.mergedRowsEnabled != oldSettings.mergedRowsEnabled) {
        if (newSettings.mergedRowsEnabled) {
          _updateMergedGroups();
        } else {
          _mergedGroups = [];
        }
      }
    });
  }

  /// Handle column sorting
  void _handleSort(String columnKey, SortDirection direction) {
    final stopwatch = Stopwatch()..start();

    setState(() {
      _currentSortColumn = columnKey;
      _currentSortDirection = direction;

      if (direction == SortDirection.none) {
        // Reset to original order from cached copy
        _data = List.of(_originalData);
      } else {
        // Sort data using the column's valueAccessor
        final column = _columns[columnKey];
        if (column != null) {
          _data.sort((a, b) {
            final aValue = column.valueAccessor(a);
            final bValue = column.valueAccessor(b);

            int comparison = 0;

            if (aValue == null && bValue == null) {
              comparison = 0;
            } else if (aValue == null) {
              comparison = 1;
            } else if (bValue == null) {
              comparison = -1;
            } else if (aValue is num && bValue is num) {
              comparison = aValue.compareTo(bValue);
            } else if (aValue is String && bValue is String) {
              comparison = aValue.compareTo(bValue);
            } else if (aValue is DateTime && bValue is DateTime) {
              comparison = aValue.compareTo(bValue);
            } else {
              comparison = aValue.toString().compareTo(bValue.toString());
            }

            return direction == SortDirection.ascending
                ? comparison
                : -comparison;
          });
        }
      }

      // Update merged groups after sorting
      if (_settings.mergedRowsEnabled) {
        _updateMergedGroups();
      }
    });

    stopwatch.stop();

    setState(() {
      _performanceMetrics = _performanceMetrics.copyWith(
        lastSortTimeMs: stopwatch.elapsedMilliseconds,
        lastUpdate: DateTime.now(),
      );
    });

    debugPrint('🔄 Sorted by $columnKey in ${stopwatch.elapsedMilliseconds}ms');
  }

  /// Handle row selection (tile click) — single-select behavior:
  /// clears existing selection and selects only the clicked row.
  void _handleRowSelection(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedRows = {rowId};
      } else {
        _selectedRows.remove(rowId);
      }
    });
  }

  /// Handle checkbox click — multi-select toggle behavior:
  /// toggles the clicked row without affecting other selections.
  void _handleCheckboxSelection(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedRows.add(rowId);
      } else {
        _selectedRows.remove(rowId);
      }
    });
  }

  /// Handle cell editing
  void _handleCellChanged(
    Employee row,
    String columnKey,
    int rowIndex,
    dynamic oldValue,
    dynamic newValue,
  ) {
    setState(() {
      final employee = _data[rowIndex];
      switch (columnKey) {
        case 'position':
          _data[rowIndex] = employee.copyWith(position: newValue as String);
          break;
        case 'department':
          _data[rowIndex] = employee.copyWith(department: newValue as String);
          break;
        case 'salary':
          final parsed = int.tryParse(newValue.toString());
          if (parsed != null) {
            _data[rowIndex] = employee.copyWith(salary: parsed);
          }
          break;
      }
    });

    debugPrint(
        '✏️ Edited row $rowIndex, column $columnKey: $oldValue → $newValue');
  }

  /// Handle right-click context menu on a row
  void _handleRowSecondaryTapDown(
    String rowId,
    TapDownDetails details,
    RenderBox renderBox,
    bool isSelected,
  ) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(details.localPosition, ancestor: overlay),
        renderBox.localToGlobal(details.localPosition, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // Find the row data for display
    final employee = _data.firstWhere(
      (row) => row.id == rowId,
      orElse: () => _data.first,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 18, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text('View "${employee.name}"'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'select',
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.deselect : Icons.check_circle_outline,
                size: 18,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              Text(isSelected ? 'Deselect' : 'Select'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text('Delete'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'view':
          _showRowDetailDialog(employee);
          break;
        case 'select':
          _handleRowSelection(rowId, !isSelected);
          break;
        case 'delete':
          setState(() {
            _data.removeWhere((row) => row.id == rowId);
            _selectedRows.remove(rowId);
            if (_settings.mergedRowsEnabled) _updateMergedGroups();
          });
          debugPrint('🗑️ Deleted row $rowId');
          break;
      }
    });
  }

  /// Show row detail dialog
  void _showRowDetailDialog(Employee employee) {
    final details = {
      'ID': employee.id,
      'Name': employee.name,
      'Position': employee.position,
      'Department': employee.department,
      'Salary': '\$${formatPlaygroundNumber(employee.salary)}',
      'Performance': '${(employee.performance * 100).toStringAsFixed(0)}%',
      'Email': employee.email,
      'Phone': employee.phone,
      'Active': employee.isActive ? 'Yes' : 'No',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: details.entries
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${e.key}:',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(child: Text(e.value)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _hoverActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  /// Handle column reorder
  void _handleColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      final entries = _columns.entries.toList();
      final item = entries.removeAt(oldIndex);
      entries.insert(newIndex, item);

      _columns = Map.fromEntries(
        entries.asMap().entries.map((entry) {
          final index = entry.key;
          final mapEntry = entry.value;
          return MapEntry(
            mapEntry.key,
            mapEntry.value.copyWith(order: index),
          );
        }),
      );
    });

    debugPrint('🔄 Reordered column from $oldIndex to $newIndex');
  }

  /// Apply random widths to all columns (simulates restoring saved widths)
  void _randomizeColumnWidths() {
    final rng = Random();
    setState(() {
      _columns = Map.fromEntries(
        _columns.entries.map((entry) {
          final col = entry.value;
          final minW = col.minWidth;
          final maxW = col.maxWidth ?? 400.0;
          final randomWidth = minW + rng.nextDouble() * (maxW - minW);
          return MapEntry(
            entry.key,
            col.copyWith(width: randomWidth.roundToDouble()),
          );
        }),
      );
    });
    debugPrint('🎲 Randomized column widths');
  }

  /// Update merged groups (group by department)
  void _updateMergedGroups() {
    if (!_settings.mergedRowsEnabled || _data.isEmpty) {
      _mergedGroups = [];
      return;
    }

    final Map<String, List<Employee>> groupedByDept = {};

    for (var row in _data) {
      groupedByDept.putIfAbsent(row.department, () => []);
      groupedByDept[row.department]!.add(row);
    }

    _mergedGroups = groupedByDept.entries.map((entry) {
      final department = entry.key;
      final rows = entry.value;
      final rowKeys = rows.map((r) => r.id).toList();

      return MergedRowGroup<Employee>(
        groupId: 'dept_$department',
        rowKeys: rowKeys,
        mergeConfig: {
          'department': MergeCellConfig(
            shouldMerge: true,
            mergedContent: Text(
              department,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          'avatar': MergeCellConfig(
            shouldMerge: true,
            mergedContent: Icon(
              Icons.business,
              color: Colors.blue.shade600,
            ),
          ),
        },
        isExpanded: true,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterTablePlus Playground'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Scale indicator
          if (_settings.scale != 1.0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(_settings.scale * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          // Performance indicator in app bar
          if (_data.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${formatPlaygroundNumber(_data.length)} rows',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // Left: Settings Panel
          SettingsPanel(
            settings: _settings,
            performanceMetrics: _performanceMetrics,
            onSettingsChanged: _handleSettingsChanged,
            onGenerateData: _generateData,
            onRandomizeWidths: _randomizeColumnWidths,
            onRandomSavedWidths: () {
              final rng = Random();
              setState(() {
                _activeInitialWidths = {
                  for (final entry in _columns.entries)
                    entry.key: (entry.value.minWidth +
                            rng.nextDouble() *
                                ((entry.value.maxWidth ?? 400.0) -
                                    entry.value.minWidth))
                        .roundToDouble(),
                };
              });
              debugPrint('🎲 Applied random widths (not saved)');
            },
            onRestoreWidths: () {
              setState(() {
                _activeInitialWidths = Map.of(_savedWidths);
              });
              debugPrint(
                  '♻️ Restored saved widths: ${_savedWidths.entries.map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}px').join(', ')}');
            },
            hasSavedWidths: _savedWidths.isNotEmpty,
            isGenerating: _isGenerating,
          ),

          // Right: Table Area
          Expanded(
            child: _buildTableArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      color: Colors.white,
      child: FlutterTablePlus<Employee>(
        columns: _columns,
        data: _data,
        rowId: (row) => row.id,
        sortColumnKey: _currentSortColumn,
        sortDirection: _currentSortDirection,
        sortCycleOrder: _settings.sortCycleOrder,
        onSort: _settings.sortingEnabled ? _handleSort : null,
        onColumnReorder:
            _settings.columnReorderEnabled ? _handleColumnReorder : null,
        resizable: _settings.resizableEnabled,
        stretchLastColumn: _settings.stretchLastColumn,
        initialResizedWidths: _activeInitialWidths,
        onColumnResized: (columnKey, newWidth) {
          setState(() {
            _savedWidths[columnKey] = newWidth;
          });
          debugPrint(
              '↔️ Resized column "$columnKey" to ${newWidth.toStringAsFixed(1)}px');
        },
        isSelectable: _settings.selectionEnabled,
        selectionMode: _settings.selectionMode,
        selectedRows: _selectedRows,
        onRowSelectionChanged: _handleRowSelection,
        onCheckboxChanged: _handleCheckboxSelection,
        onSelectAll: _settings.selectAllEnabled
            ? (selectAll) {
                setState(() {
                  if (selectAll) {
                    _selectedRows = _data.map((row) => row.id).toSet();
                  } else {
                    _selectedRows = {};
                  }
                });
              }
            : null,
        enableDragSelection: _settings.dragSelectionEnabled,
        onDragSelectionUpdate: (draggedIds) {
          setState(() {
            _selectedRows = draggedIds; // replace pattern (most common)
          });
        },
        isEditable: _settings.editingEnabled,
        // The row is the hover region; the card is anchored beside the pointer.
        rowTooltipBuilder: _settings.rowCardTooltip
            ? (context, employee) => _rowCard(employee)
            : null,
        onCellChanged: _handleCellChanged,
        onRowSecondaryTapDown: _handleRowSecondaryTapDown,
        calculateRowHeight: _settings.dynamicRowHeight
            ? (rowIndex, employee) {
                // Taller rows for longer position titles
                return employee.position.length > 20 ? 70.0 : null;
              }
            : null,
        isDimRow: _settings.dimInactiveRows ? (row) => !row.isActive : null,
        noDataWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No employees found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try generating data or adjusting filters',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        hoverButtonBuilder: (rowId, employee) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _hoverActionButton(
              icon: Icons.visibility,
              color: Colors.blue,
              tooltip: 'View',
              onPressed: () => _showRowDetailDialog(employee),
            ),
            _hoverActionButton(
              icon: Icons.edit,
              color: Colors.orange,
              tooltip: 'Edit',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Edit "${employee.name}" — enable editing in settings to edit cells directly'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            _hoverActionButton(
              icon: Icons.delete,
              color: Colors.red,
              tooltip: 'Delete',
              onPressed: () {
                setState(() {
                  _data.removeWhere((row) => row.id == rowId);
                  _selectedRows.remove(rowId);
                  if (_settings.mergedRowsEnabled) _updateMergedGroups();
                });
              },
            ),
          ],
        ),
        hoverButtonPosition: HoverButtonPosition.right,
        mergedGroups: _settings.mergedRowsEnabled ? _mergedGroups : [],
        scale: _settings.scale,
        blockModifierScroll: _settings.blockModifierScroll,
        onScaleChanged: (newScale) {
          setState(() {
            _settings = _settings.copyWith(
              scale: newScale.clamp(0.25, 3.0),
            );
          });
        },
        theme: buildPlaygroundTheme(_settings),
      ),
    );
  }
}

/// The table theme the playground builds from its [PlaygroundSettings].
///
/// Free of `BuildContext` and of widget state, so it can be asserted on
/// directly: what the panel selects is exactly what the table receives.
TextStyle _fontTextStyle(
  PlaygroundSettings settings, {
  double? fontSize,
  Color? color,
  FontWeight? fontWeight,
}) {
  return switch (settings.fontFamily) {
    'pretendard' => TextStyle(
        fontFamily: 'Pretendard',
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight),
    'notoSansKr' => GoogleFonts.notoSansKr(
        fontSize: fontSize, color: color, fontWeight: fontWeight),
    'inter' => GoogleFonts.inter(
        fontSize: fontSize, color: color, fontWeight: fontWeight),
    'firaCode' => GoogleFonts.firaCode(
        fontSize: fontSize, color: color, fontWeight: fontWeight),
    _ => TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight),
  };
}

TablePlusTheme buildPlaygroundTheme(PlaygroundSettings settings) {
  final cellTooltip = TablePlusTooltipTheme(
    enabled: settings.tooltipEnabled,
    waitDuration: Duration(milliseconds: settings.tooltipWaitDurationMs),
    textStyle: _fontTextStyle(settings, fontSize: 12, color: Colors.white),
    direction: settings.tooltipDirection,
    alignment: settings.tooltipAlignment,
    showArrow: settings.tooltipShowArrow,
    offset: settings.tooltipOffset,
    anchor: settings.tooltipAnchor,
  );
  return TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(
      resizeHandle: TablePlusResizeHandleTheme(
        width: settings.resizeHandleWidth,
        thickness: settings.resizeHandleThickness,
        indent: settings.resizeHandleIndent,
        endIndent: settings.resizeHandleEndIndent,
      ),
      backgroundColor: Colors.blue.shade50,
      topBorder: TablePlusHeaderBorderTheme(
        show: settings.headerTopBorderShow,
        color: Colors.blue.shade200,
        thickness: settings.headerTopBorderThickness,
      ),
      bottomBorder: TablePlusHeaderBorderTheme(
        show: settings.headerBottomBorderShow,
        color: Colors.grey.shade300,
        thickness: settings.headerBottomBorderThickness,
      ),
      verticalDivider: TablePlusHeaderDividerTheme(
        show: settings.headerVerticalDividerShow,
        color: Colors.grey.shade300,
        thickness: settings.headerVerticalDividerThickness,
        indent: settings.headerVerticalDividerIndent,
        endIndent: settings.headerVerticalDividerEndIndent,
      ),
      textStyle: _fontTextStyle(
        settings,
        fontWeight: FontWeight.w600,
        color: Colors.blue.shade800,
        fontSize: settings.fontSize,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: settings.horizontalPadding,
        vertical: settings.verticalPadding,
      ),
      sortIcons: SortIcons(
        ascending: SvgPicture.asset(
          'assets/icons/up.svg',
          width: settings.sortIconWidth,
          height: settings.sortIconWidth,
          colorFilter: ColorFilter.mode(
            Colors.blue.shade700,
            BlendMode.srcIn,
          ),
        ),
        descending: SvgPicture.asset(
          'assets/icons/down.svg',
          width: settings.sortIconWidth,
          height: settings.sortIconWidth,
          colorFilter: ColorFilter.mode(
            Colors.blue.shade700,
            BlendMode.srcIn,
          ),
        ),
        unsorted: SvgPicture.asset(
          'assets/icons/upndown.svg',
          width: settings.sortIconWidth,
          height: settings.sortIconWidth,
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.srcIn,
          ),
        ),
      ),
      sortIconWidth: settings.sortIconWidth,
    ),
    bodyTheme: TablePlusBodyTheme(
      backgroundColor: Colors.white,
      alternateRowColor: settings.showAlternateRows
          ? Colors.blue.shade50.withValues(alpha: 0.3)
          : null,
      textStyle: _fontTextStyle(
        settings,
        fontSize: settings.fontSize,
        color: Colors.black87,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: settings.horizontalPadding,
        vertical: settings.verticalPadding,
      ),
      dividerColor:
          settings.showDividers ? Colors.grey.shade300 : Colors.transparent,
      showHorizontalDividers: settings.showDividers,
      showVerticalDividers: settings.showDividers,
      selectedRowColor: Colors.blue.shade100.withValues(alpha: 0.6),
      splashColor: settings.splashColor.color,
      hoverColor: settings.hoverColor.color,
      highlightColor: settings.highlightColor.color,
      rowHeight: settings.rowHeight,
    ),
    editableTheme: TablePlusEditableTheme(
      editingCellColor: Colors.yellow.shade100,
      editingBorderColor: Colors.orange.shade400,
      editingBorderWidth: 2.0,
    ),
    checkboxTheme: TablePlusCheckboxTheme(
      showCheckboxColumn: settings.showCheckboxColumn,
      style: CheckboxStyle(
        size: 18,
        hoverRingPadding: settings.checkboxTapTargetSize > 18
            ? (settings.checkboxTapTargetSize - 18) / 2
            : 0,
      ),
      cellTapTogglesCheckbox: settings.cellTapTogglesCheckbox,
      showRowCheckbox: settings.showRowCheckbox,
    ),
    // The card draws its own surface, so the tooltip must not draw one behind
    // it. Text tooltips keep the styled surface from `tooltipTheme`. The pause
    // before it appears is its own, because a card interrupts more than a line
    // of text does.
    rowTooltipTheme: TablePlusTooltipTheme(
      enabled: settings.tooltipEnabled,
      waitDuration: Duration(milliseconds: settings.rowCardWaitDurationMs),
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0,
      showArrow: false,
    ),
    tooltipTheme: cellTooltip,
    // Null while the header follows the cells, so the package's documented
    // fallback to `tooltipTheme` is the path the playground normally walks.
    // The two themes differ in nothing but the anchor.
    headerTooltipTheme: switch (settings.headerTooltipAnchor) {
      HeaderTooltipAnchor.followCells => null,
      HeaderTooltipAnchor.child =>
        cellTooltip.copyWith(anchor: TooltipAnchor.child),
      HeaderTooltipAnchor.pointer =>
        cellTooltip.copyWith(anchor: TooltipAnchor.pointer),
    },
  );
}
