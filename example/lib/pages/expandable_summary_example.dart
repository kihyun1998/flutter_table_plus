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

  @override
  Widget build(BuildContext context) {
    // Sample data - Product packages with individual items
    final List<Map<String, dynamic>> data = [
      // AB Package
      {
        'id': '1',
        'package': 'AB-001',
        'product': 'Product A',
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
        'product': 'Product E',
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

    // Define table columns
    final Map<String, TablePlusColumn> columns = {
      'package': TablePlusColumn(
        key: 'package',
        label: 'Package ID',
        order: 0,
        width: 120,
        textOverflow: TextOverflow.ellipsis,
        tooltipBehavior: TooltipBehavior.onOverflowOnly,
      ),
      'product': TablePlusColumn(
        key: 'product',
        label: 'Product Name',
        order: 1,
        width: 150,
        textOverflow: TextOverflow.ellipsis,
        tooltipBehavior: TooltipBehavior.onOverflowOnly,
      ),
      'price': TablePlusColumn(
        key: 'price',
        label: 'Unit Price',
        order: 2,
        width: 100,
        textAlign: TextAlign.right,
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
      ),
      'total': TablePlusColumn(
        key: 'total',
        label: 'Item Total',
        order: 4,
        width: 120,
        textAlign: TextAlign.right,
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

    // Helper function to calculate package totals
    int calculatePackageTotal(List<String> rowKeys) {
      int total = 0;
      for (final rowKey in rowKeys) {
        final rowData = data.firstWhere((row) => row['id'] == rowKey);
        total += (rowData['price'] as int) * (rowData['quantity'] as int);
      }
      return total;
    }

    // Merged groups configuration - merge by package
    final List<MergedRowGroup> mergedGroups = [
      // AB Package
      MergedRowGroup(
        groupId: 'AB-001',
        rowKeys: ['1', '2'],
        isExpandable: true,
        isExpanded: expandedStates['AB-001'] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total': '¥${calculatePackageTotal([
                '1',
                '2'
              ]).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '5 sets',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ),

      // CD Package
      MergedRowGroup(
        groupId: 'CD-002',
        rowKeys: ['3', '4'],
        isExpandable: true,
        isExpanded: expandedStates['CD-002'] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total': '¥${calculatePackageTotal([
                '3',
                '4'
              ]).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '3 sets',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ),

      // EF Package
      MergedRowGroup(
        groupId: 'EF-003',
        rowKeys: ['5', '6'],
        isExpandable: true,
        isExpanded: expandedStates['EF-003'] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total': '¥${calculatePackageTotal([
                '5',
                '6'
              ]).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '2 sets',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ),

      // GH Package
      MergedRowGroup(
        groupId: 'GH-004',
        rowKeys: ['7', '8'],
        isExpandable: true,
        isExpanded: expandedStates['GH-004'] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total': '¥${calculatePackageTotal([
                '7',
                '8'
              ]).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '4 sets',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ),

      // IJ Package
      MergedRowGroup(
        groupId: 'IJ-005',
        rowKeys: ['9', '10'],
        isExpandable: true,
        isExpanded: expandedStates['IJ-005'] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total': '¥${calculatePackageTotal([
                '9',
                '10'
              ]).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '6 sets',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ),

      // KL Package
      MergedRowGroup(
        groupId: 'KL-006',
        rowKeys: ['11', '12'],
        isExpandable: true,
        isExpanded: expandedStates['KL-006'] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total': '¥${calculatePackageTotal([
                '11',
                '12'
              ]).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '1 set',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ),

      // MN Package
      MergedRowGroup(
        groupId: 'MN-007',
        rowKeys: ['13', '14'],
        isExpandable: true,
        isExpanded: expandedStates['MN-007'] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total': '¥${calculatePackageTotal([
                '13',
                '14'
              ]).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '8 sets',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ),

      // OP Package
      MergedRowGroup(
        groupId: 'OP-008',
        rowKeys: ['15', '16'],
        isExpandable: true,
        isExpanded: expandedStates['OP-008'] ?? false,
        summaryRowData: {
          'product': '📊 Package Total',
          'total': '¥${calculatePackageTotal([
                '15',
                '16'
              ]).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
          'quantity': '3 sets',
        },
        mergeConfig: {
          'package': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
          'quantity': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0,
          ),
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable Summary Example'),
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
                      'Product Package Management',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• 8 Product packages (AB~OP) containing multiple items\n'
                      '• Package ID and Quantity columns are merged\n'
                      '• Click the expand icon (▶/▼) to show/hide package totals\n'
                      '• Summary rows show calculated package totals\n'
                      '• Select entire packages with checkboxes (merged row selection)\n'
                      '• Vertical scroll to see all packages!',
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
                    columns: columns,
                    data: data,
                    mergedGroups: mergedGroups,
                    isSelectable: true,
                    selectionMode: SelectionMode.multiple,
                    selectedRows: selectedRows,
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
                          selectedRows.addAll(['AB-001', 'CD-002', 'EF-003', 'GH-004', 'IJ-005', 'KL-006', 'MN-007', 'OP-008']);
                        } else {
                          selectedRows.clear();
                        }
                      });
                    },
                    onMergedRowExpandToggle: (groupId) {
                      setState(() {
                        expandedStates[groupId] =
                            !(expandedStates[groupId] ?? false);
                      });
                    },
                    theme: TablePlusTheme(
                      headerTheme: TablePlusHeaderTheme(
                        backgroundColor: Colors.purple.shade50,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      bodyTheme: TablePlusBodyTheme(
                        alternateRowColor: Colors.grey.shade50,
                      ),
                      selectionTheme: TablePlusSelectionTheme(
                        checkboxColor: Colors.purple.shade600,
                        selectedRowColor:
                            Colors.purple.shade100.withValues(alpha: 0.3),
                        // hoverColor: Colors.purple.shade50.withValues(alpha: 0.5),
                      ),
                    ),
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
