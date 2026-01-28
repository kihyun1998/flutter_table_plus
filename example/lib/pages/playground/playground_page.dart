import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'utils/random_data_generator.dart';
import 'widgets/settings_panel.dart';
import 'widgets/performance_monitor.dart';

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
  List<Map<String, dynamic>> _data = [];
  Map<String, TablePlusColumn> _columns = {};

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

  // Merged rows (if enabled)
  List<MergedRowGroup> _mergedGroups = [];

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    _generateData();
  }

  /// Initialize table columns
  void _initializeColumns() {
    final builder = TableColumnsBuilder();

    final tooltip = _settings.tooltipBehavior;

    builder.addColumn(
      'avatar',
      TablePlusColumn(
        key: 'avatar',
        label: '👤',
        order: 0,
        width: 60,
        sortable: false,
        tooltipBehavior: tooltip,
        headerTooltipBehavior: tooltip,
      ),
    );

    builder.addColumn(
      'name',
      TablePlusColumn(
        key: 'name',
        label: 'Name',
        order: 0,
        width: 180,
        sortable: _settings.sortingEnabled,
        tooltipBehavior: tooltip,
        headerTooltipBehavior: tooltip,
      ),
    );

    builder.addColumn(
      'position',
      TablePlusColumn(
        key: 'position',
        label: 'Position',
        order: 0,
        width: 200,
        sortable: _settings.sortingEnabled,
        editable: _settings.editingEnabled,
        tooltipBehavior: tooltip,
        headerTooltipBehavior: tooltip,
      ),
    );

    builder.addColumn(
      'department',
      TablePlusColumn(
        key: 'department',
        label: 'Department',
        order: 0,
        width: 150,
        sortable: _settings.sortingEnabled,
        editable: _settings.editingEnabled,
        tooltipBehavior: tooltip,
        headerTooltipBehavior: tooltip,
      ),
    );

    builder.addColumn(
      'salary',
      TablePlusColumn(
        key: 'salary',
        label: 'Salary',
        order: 0,
        width: 120,
        sortable: _settings.sortingEnabled,
        editable: _settings.editingEnabled,
        tooltipBehavior: tooltip,
        headerTooltipBehavior: tooltip,
        cellBuilder: (context, rowData) {
          final salary = rowData['salary'] as int;
          return Center(
            child: Text(
              '\$${_formatNumber(salary)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          );
        },
      ),
    );

    builder.addColumn(
      'performance',
      TablePlusColumn(
        key: 'performance',
        label: 'Performance',
        order: 0,
        width: 130,
        sortable: _settings.sortingEnabled,
        tooltipBehavior: tooltip,
        headerTooltipBehavior: tooltip,
        cellBuilder: (context, rowData) {
          final performance = rowData['performance'] as double;
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPerformanceColor(performance),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(performance * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );

    builder.addColumn(
      'email',
      TablePlusColumn(
        key: 'email',
        label: 'Email',
        order: 0,
        width: 220,
        sortable: _settings.sortingEnabled,
        tooltipBehavior: tooltip,
        headerTooltipBehavior: tooltip,
      ),
    );

    builder.addColumn(
      'phone',
      TablePlusColumn(
        key: 'phone',
        label: 'Phone',
        order: 0,
        width: 130,
        sortable: _settings.sortingEnabled,
        tooltipBehavior: tooltip,
        headerTooltipBehavior: tooltip,
      ),
    );

    _columns = builder.build();
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
      final needsColumnRebuild =
          newSettings.sortingEnabled != oldSettings.sortingEnabled ||
              newSettings.editingEnabled != oldSettings.editingEnabled ||
              newSettings.tooltipBehavior != oldSettings.tooltipBehavior;

      if (needsColumnRebuild) {
        _initializeColumns();
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
        // Reset to original order - regenerate
        _data = RandomDataGenerator.generateEmployees(_settings.rowCount);
      } else {
        // Sort data
        _data.sort((a, b) {
          final aValue = a[columnKey];
          final bValue = b[columnKey];

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

  /// Handle row selection
  void _handleRowSelection(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_settings.selectionMode == SelectionMode.single) {
          _selectedRows = {rowId};
        } else {
          _selectedRows.add(rowId);
        }
      } else {
        _selectedRows.remove(rowId);
      }
    });
  }

  /// Handle cell editing
  void _handleCellChanged(
    String columnKey,
    int rowIndex,
    dynamic oldValue,
    dynamic newValue,
  ) {
    setState(() {
      _data[rowIndex][columnKey] = newValue;
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
    final rowData = _data.firstWhere(
      (row) => row['id'].toString() == rowId,
      orElse: () => <String, dynamic>{},
    );
    final rowName = rowData['name'] ?? rowId;

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
              Text('View "$rowName"'),
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
          _showRowDetailDialog(rowData);
          break;
        case 'select':
          _handleRowSelection(rowId, !isSelected);
          break;
        case 'delete':
          setState(() {
            _data.removeWhere((row) => row['id'].toString() == rowId);
            _selectedRows.remove(rowId);
            if (_settings.mergedRowsEnabled) _updateMergedGroups();
          });
          debugPrint('🗑️ Deleted row $rowId');
          break;
      }
    });
  }

  /// Show row detail dialog
  void _showRowDetailDialog(Map<String, dynamic> rowData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(rowData['name']?.toString() ?? 'Row Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: rowData.entries
                .where((e) => e.key != 'avatar')
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
                          Expanded(child: Text(e.value.toString())),
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

  /// Update merged groups (group by department)
  void _updateMergedGroups() {
    if (!_settings.mergedRowsEnabled || _data.isEmpty) {
      _mergedGroups = [];
      return;
    }

    final Map<String, List<Map<String, dynamic>>> groupedByDept = {};

    for (var row in _data) {
      final dept = row['department']?.toString() ?? 'Unknown';
      groupedByDept.putIfAbsent(dept, () => []);
      groupedByDept[dept]!.add(row);
    }

    _mergedGroups = groupedByDept.entries.map((entry) {
      final department = entry.key;
      final rows = entry.value;
      final rowKeys = rows.map((r) => r['id'] as String).toList();

      return MergedRowGroup(
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
                    '${_formatNumber(_data.length)} rows',
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
      color: Colors.white,
      child: FlutterTablePlus(
        columns: _columns,
        data: _data,
        sortColumnKey: _currentSortColumn,
        sortDirection: _currentSortDirection,
        sortCycleOrder: _settings.sortCycleOrder,
        onSort: _settings.sortingEnabled ? _handleSort : null,
        onColumnReorder:
            _settings.columnReorderEnabled ? _handleColumnReorder : null,
        isSelectable: true,
        selectionMode: _settings.selectionMode,
        selectedRows: _selectedRows,
        onRowSelectionChanged: _handleRowSelection,
        onCheckboxChanged: _handleRowSelection,
        onSelectAll: (selectAll) {
          setState(() {
            if (selectAll) {
              _selectedRows = _data.map((row) => row['id'] as String).toSet();
            } else {
              _selectedRows = {};
            }
          });
        },
        isEditable: _settings.editingEnabled,
        onCellChanged: _handleCellChanged,
        onRowSecondaryTapDown: _handleRowSecondaryTapDown,
        calculateRowHeight: _settings.dynamicRowHeight
            ? (rowIndex, rowData) {
                final position = rowData['position']?.toString() ?? '';
                // Taller rows for longer position titles
                return position.length > 20 ? 70.0 : null;
              }
            : null,
        dimRowKey: _settings.dimInactiveRows ? 'isActive' : null,
        invertDimRow: true,
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
        hoverButtonBuilder: (rowId, rowData) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _hoverActionButton(
              icon: Icons.visibility,
              color: Colors.blue,
              tooltip: 'View',
              onPressed: () => _showRowDetailDialog(rowData),
            ),
            _hoverActionButton(
              icon: Icons.edit,
              color: Colors.orange,
              tooltip: 'Edit',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Edit "${rowData['name']}" — enable editing in settings to edit cells directly'),
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
                  _data.removeWhere((row) => row['id'].toString() == rowId);
                  _selectedRows.remove(rowId);
                  if (_settings.mergedRowsEnabled) _updateMergedGroups();
                });
              },
            ),
          ],
        ),
        hoverButtonPosition: HoverButtonPosition.right,
        mergedGroups: _settings.mergedRowsEnabled ? _mergedGroups : [],
        theme: _buildTheme(),
      ),
    );
  }

  TablePlusTheme _buildTheme() {
    return TablePlusTheme(
      headerTheme: TablePlusHeaderTheme(
        backgroundColor: Colors.blue.shade50,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade800,
          fontSize: _settings.fontSize,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _settings.horizontalPadding,
          vertical: _settings.verticalPadding,
        ),
      ),
      bodyTheme: TablePlusBodyTheme(
        backgroundColor: Colors.white,
        alternateRowColor: _settings.showAlternateRows
            ? Colors.blue.shade50.withValues(alpha: 0.3)
            : null,
        textStyle: TextStyle(
          fontSize: _settings.fontSize,
          color: Colors.black87,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _settings.horizontalPadding,
          vertical: _settings.verticalPadding,
        ),
        dividerColor:
            _settings.showDividers ? Colors.grey.shade300 : Colors.transparent,
        showHorizontalDividers: _settings.showDividers,
        showVerticalDividers: _settings.showDividers,
        selectedRowColor: Colors.blue.shade100.withValues(alpha: 0.6),
        rowHeight: _settings.rowHeight,
      ),
      editableTheme: TablePlusEditableTheme(
        editingCellColor: Colors.yellow.shade100,
        editingBorderColor: Colors.orange.shade400,
        editingBorderWidth: 2.0,
      ),
    );
  }

  Color _getPerformanceColor(double performance) {
    if (performance >= 0.9) {
      return Colors.green.shade600;
    } else if (performance >= 0.75) {
      return Colors.blue.shade600;
    } else if (performance >= 0.6) {
      return Colors.orange.shade600;
    } else {
      return Colors.red.shade600;
    }
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
