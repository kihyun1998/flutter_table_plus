import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Example demonstrating expandable summary row functionality for merged groups.
/// This shows a product package management scenario where packages contain
/// multiple products and we want to show calculated totals.
class ExpandableSummaryExample extends StatefulWidget {
  const ExpandableSummaryExample({super.key});

  @override
  State<ExpandableSummaryExample> createState() =>
      _ExpandableSummaryExampleState();
}

class _ExpandableSummaryExampleState extends State<ExpandableSummaryExample> {
  // State for managing expand/collapse of merged groups
  Map<String, bool> expandedStates = {
    'AB-001': false,
    'CD-002': true, // Start with this one expanded
    'EF-003': false,
    'GH-004': false,
    'IJ-005': false,
    'KL-006': false,
    'MN-007': false,
    'OP-008': false,
  };

  // State for managing row selection
  Set<String> selectedRows = {};

  // State for managing sort
  String? currentSortColumn;
  SortDirection? currentSortDirection;

  // State for managing editing
  bool isEditing = false;

  // State for managing column order (using Map like comprehensive example)
  late Map<String, TablePlusColumn> _columns;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
  }

  void _initializeColumns() {
    _columns = {
      'package': TablePlusColumn(
        key: 'package',
        label: 'Package ID',
        order: 0,
        width: 120,
        textOverflow: TextOverflow.ellipsis,
        tooltipBehavior: TooltipBehavior.onOverflowOnly,
        editable: true,
        hintText: 'Enter package ID',
      ),
      'product': TablePlusColumn(
        key: 'product',
        label: 'Product Name',
        order: 1,
        width: 150,
        textOverflow: TextOverflow.visible,
        tooltipBehavior: TooltipBehavior.never,
        sortable: true,
        editable: true,
        hintText: 'Enter product name',
      ),
      'price': TablePlusColumn(
        key: 'price',
        label: 'Unit Price',
        order: 2,
        width: 100,
        textAlign: TextAlign.right,
        sortable: true,
        editable: true,
        hintText: 'Enter price',
        cellBuilder: (context, rowData) {
          final price = rowData['price'] as int;
          return Text(
            '¥${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
            textAlign: TextAlign.right,
          );
        },
      ),
      'quantity': TablePlusColumn(
        key: 'quantity',
        label: 'Quantity',
        order: 3,
        width: 80,
        textAlign: TextAlign.center,
        sortable: true,
        editable: true,
        hintText: 'Enter quantity',
      ),
      'total': TablePlusColumn(
        key: 'total',
        label: 'Item Total',
        order: 4,
        width: 120,
        textAlign: TextAlign.right,
        sortable: true,
        cellBuilder: (context, rowData) {
          final price = rowData['price'] as int;
          final quantity = rowData['quantity'] as int;
          final total = price * quantity;
          return Text(
            '¥${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
            textAlign: TextAlign.right,
          );
        },
      ),
    };
  }

  // Sample data - Product packages with individual items
  List<Map<String, dynamic>> data = [
    // AB Package
    {
      'id': '1',
      'package': 'AB-001',
      'product':
          'Premium High-Quality Product A with Extended Warranty and Advanced Features',
      'price': 10000,
      'quantity': 5
    },
    {
      'id': '2',
      'package': 'AB-001',
      'product': 'Product B',
      'price': 15000,
      'quantity': 5
    },
    // CD Package
    {
      'id': '3',
      'package': 'CD-002',
      'product': 'Product C',
      'price': 8000,
      'quantity': 3
    },
    {
      'id': '4',
      'package': 'CD-002',
      'product': 'Product D',
      'price': 12000,
      'quantity': 3
    },
    // EF Package
    {
      'id': '5',
      'package': 'EF-003',
      'product':
          'Ultra-Advanced Product E with Cutting-Edge Technology, Multiple Configuration Options, and Comprehensive Support Package',
      'price': 20000,
      'quantity': 2
    },
    {
      'id': '6',
      'package': 'EF-003',
      'product': 'Product F',
      'price': 25000,
      'quantity': 2
    },
    // GH Package
    {
      'id': '7',
      'package': 'GH-004',
      'product': 'Product G',
      'price': 18000,
      'quantity': 4
    },
    {
      'id': '8',
      'package': 'GH-004',
      'product': 'Product H',
      'price': 22000,
      'quantity': 4
    },
    // IJ Package
    {
      'id': '9',
      'package': 'IJ-005',
      'product': 'Product I',
      'price': 14000,
      'quantity': 6
    },
    {
      'id': '10',
      'package': 'IJ-005',
      'product': 'Product J',
      'price': 16000,
      'quantity': 6
    },
    // KL Package
    {
      'id': '11',
      'package': 'KL-006',
      'product': 'Product K',
      'price': 30000,
      'quantity': 1
    },
    {
      'id': '12',
      'package': 'KL-006',
      'product': 'Product L',
      'price': 35000,
      'quantity': 1
    },
    // MN Package
    {
      'id': '13',
      'package': 'MN-007',
      'product': 'Product M',
      'price': 12000,
      'quantity': 8
    },
    {
      'id': '14',
      'package': 'MN-007',
      'product': 'Product N',
      'price': 18000,
      'quantity': 8
    },
    // OP Package
    {
      'id': '15',
      'package': 'OP-008',
      'product': 'Product O',
      'price': 24000,
      'quantity': 3
    },
    {
      'id': '16',
      'package': 'OP-008',
      'product': 'Product P',
      'price': 26000,
      'quantity': 3
    },
  ];

  // Sort function
  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      currentSortColumn = columnKey;
      currentSortDirection = direction;

      // Reset to none means restore original order
      if (direction == SortDirection.none) {
        // Restore original data order
        _restoreOriginalOrder();
      } else {
        // Apply sorting
        data.sort((a, b) {
          dynamic valueA, valueB;

          // Special handling for calculated 'total' column
          if (columnKey == 'total') {
            valueA = (a['price'] as int) * (a['quantity'] as int);
            valueB = (b['price'] as int) * (b['quantity'] as int);
          } else {
            valueA = a[columnKey];
            valueB = b[columnKey];
          }

          int comparison;
          if (valueA is String && valueB is String) {
            comparison = valueA.toLowerCase().compareTo(valueB.toLowerCase());
          } else if (valueA is num && valueB is num) {
            comparison = valueA.compareTo(valueB);
          } else {
            comparison = valueA.toString().compareTo(valueB.toString());
          }

          // Apply sort direction
          return direction == SortDirection.ascending
              ? comparison
              : -comparison;
        });
      }
    });
  }

  void _restoreOriginalOrder() {
    // Restore to original order (can be enhanced to store original order)
    data.sort((a, b) => int.parse(a['id']).compareTo(int.parse(b['id'])));
  }

  // Handle cell value changes
  void _handleCellChanged(
      String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    setState(() {
      if (newValue != null && rowIndex < data.length) {
        // Handle different data types
        switch (columnKey) {
          case 'price':
          case 'quantity':
            // Try to parse as number
            if (newValue is String) {
              final numValue = int.tryParse(newValue);
              if (numValue != null) {
                data[rowIndex][columnKey] = numValue;
              }
            } else if (newValue is num) {
              data[rowIndex][columnKey] = newValue.toInt();
            }
            break;
          default:
            // String value
            data[rowIndex][columnKey] = newValue.toString();
        }
      }
    });
  }

  // Handle merged cell value changes
  void _handleMergedCellChanged(
      String groupId, String columnKey, dynamic newValue) {
    setState(() {
      // Find all rows in the merged group and update the spanning row
      for (var i = 0; i < data.length; i++) {
        if (data[i]['package'] == groupId) {
          // Update the first row in the group (spanning row)
          if (columnKey == 'package') {
            data[i][columnKey] = newValue;
          }
          break;
        }
      }
    });
  }

  // Handle column reorder
  void _handleColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      // Convert column map to ordered list
      final columnEntries = _columns.entries.toList()
        ..sort((a, b) => a.value.order.compareTo(b.value.order));

      // Reorder the list
      final item = columnEntries.removeAt(oldIndex);
      columnEntries.insert(newIndex, item);

      // Update orders
      for (int i = 0; i < columnEntries.length; i++) {
        final key = columnEntries[i].key;
        _columns[key] = _columns[key]!.copyWith(order: i);
      }
    });
  }

  // Old manual height calculation - replaced with TableRowHeightCalculator
  // double _calculateRowHeight(int rowIndex, Map<String, dynamic> rowData) {
  //   // This was inaccurate because it only considered text length,
  //   // not actual text rendering, font size, column width, or theme padding
  //   ...
  // }

  // Helper function to calculate package totals
  int calculatePackageTotal(List<String> rowKeys) {
    int total = 0;
    for (final rowKey in rowKeys) {
      final rowData = data.firstWhere((row) => row['id'] == rowKey);
      total += (rowData['price'] as int) * (rowData['quantity'] as int);
    }
    return total;
  }

  // Dynamic merged row groups based on current data order
  List<MergedRowGroup> get mergedGroups {
    final Map<String, List<String>> packageGroups = {};

    // Group row IDs by package based on current data order
    for (final row in data) {
      final packageId = row['package'] as String;
      final id = row['id'] as String;
      packageGroups.putIfAbsent(packageId, () => []).add(id);
    }

    final groups = <MergedRowGroup>[];

    // Create merged groups for each package
    for (final entry in packageGroups.entries) {
      final packageId = entry.key;
      final rowKeys = entry.value;

      groups.add(MergedRowGroup(
        groupId: packageId,
        rowKeys: rowKeys,
        isExpandable: true,
        isExpanded: expandedStates[packageId] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total':
              '¥${calculatePackageTotal(rowKeys).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '${rowKeys.length} sets',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
            isEditable: true,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ));
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    // Using dynamic mergedGroups getter now
    const textStyle = TextStyle(fontSize: 14, color: Color(0xFF212121));
    const theme = TablePlusTheme(
      headerTheme: TablePlusHeaderTheme(
        backgroundColor: Color(0xFFE1BEE7), // Colors.purple.shade50 equivalent
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A148C), // Colors.purple.shade700 equivalent
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      bodyTheme: TablePlusBodyTheme(
        alternateRowColor: Color(0xFFFAFAFA), // Colors.grey.shade50 equivalent
        summaryRowBackgroundColor: Color(0xFFE8F5E8), // Colors.green.shade50 equivalent
        textStyle: textStyle,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      selectionTheme: TablePlusSelectionTheme(
        checkboxColor: Color(0xFF6A1B9A), // Colors.purple.shade600 equivalent
        selectedRowColor: Color(0xFFE1BEE7), // Colors.purple.shade100 equivalent with alpha
      ),
    );

    // Get columns for height calculation
    final columns = _columns.entries.toList()
      ..sort((a, b) => a.value.order.compareTo(b.value.order));
    final columnList = columns.map((e) => e.value).toList();
    final columnWidths = columnList.map((col) => col.width).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprehensive Features Demo'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comprehensive Feature Demo: All Table Features Combined',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🔍 SORTING: Click column headers to sort (Product, Price, Quantity, Total)\n'
                      '✏️ EDITING: Double-click cells to edit (Package ID, Product, Price, Quantity)\n'
                      '🔄 REORDERING: Drag column headers to reorder\n'
                      '📏 DYNAMIC HEIGHT: Long product names auto-expand row height\n'
                      '📋 MERGED ROWS: Package ID and Quantity columns are merged\n'
                      '🎯 EXPANDABLE: Click expand icon (▶/▼) to show/hide package totals\n'
                      '✅ SELECTION: Select entire packages with checkboxes\n'
                      '📊 SUMMARY: Green background summary rows show calculated totals',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildStatusChip('AB-001',
                            expandedStates['AB-001'] ?? false, Colors.blue),
                        _buildStatusChip('CD-002',
                            expandedStates['CD-002'] ?? false, Colors.green),
                        _buildStatusChip('EF-003',
                            expandedStates['EF-003'] ?? false, Colors.orange),
                        Text(
                          '... and 5 more packages',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    if (selectedRows.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade300),
                        ),
                        child: Text(
                          '📦 Selected: ${selectedRows.join(', ')} (${selectedRows.length} package${selectedRows.length > 1 ? 's' : ''})',
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FlutterTablePlus(
                    columns: _columns,
                    data: data,
                    mergedGroups: mergedGroups,
                    isSelectable: true,
                    selectionMode: SelectionMode.multiple,
                    selectedRows: selectedRows,
                    onSort: _handleSort,
                    sortColumnKey: currentSortColumn,
                    sortDirection: currentSortDirection ?? SortDirection.none,
                    isEditable: true,
                    onCellChanged: _handleCellChanged,
                    onMergedCellChanged: _handleMergedCellChanged,
                    onColumnReorder: _handleColumnReorder,
                    // Use proper height calculation with theme padding
                    calculateRowHeight: TableRowHeightCalculator.createHeightCalculator(
                      columns: columnList,
                      columnWidths: columnWidths,
                      defaultTextStyle: textStyle,
                      cellPadding: theme.bodyTheme.padding,
                      minHeight: 48.0,
                    ),
                    onRowSelectionChanged: (rowId, isSelected) {
                      setState(() {
                        if (isSelected) {
                          selectedRows.add(rowId);
                        } else {
                          selectedRows.remove(rowId);
                        }
                      });
                    },
                    onSelectAll: (selectAll) {
                      setState(() {
                        if (selectAll) {
                          // Select all package group IDs
                          selectedRows.addAll([
                            'AB-001',
                            'CD-002',
                            'EF-003',
                            'GH-004',
                            'IJ-005',
                            'KL-006',
                            'MN-007',
                            'OP-008'
                          ]);
                        } else {
                          selectedRows.clear();
                        }
                      });
                    }, // Dynamic row height calculation for merged rows

                    onMergedRowExpandToggle: (groupId) {
                      setState(() {
                        expandedStates[groupId] =
                            !(expandedStates[groupId] ?? false);
                      });
                    },
                    theme: theme,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
      String packageId, bool isExpanded, MaterialColor color) {
    return Chip(
      label: Text(
        '$packageId ${isExpanded ? '(expanded)' : '(collapsed)'}',
        style: TextStyle(
          color: color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color.shade100,
      side: BorderSide(color: color.shade300),
    );
  }
}
