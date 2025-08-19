import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Example demonstrating how to support TextOverflow.visible with dynamic row heights
/// using the new calculateRowHeight callback.
class DynamicHeightExample extends StatefulWidget {
  const DynamicHeightExample({super.key});

  @override
  State<DynamicHeightExample> createState() => _DynamicHeightExampleState();
}

class _DynamicHeightExampleState extends State<DynamicHeightExample> {
  // Sample data with varying text lengths
  List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'name': 'John Doe',
      'description': 'This is a short description.',
      'status': 'Active',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'description':
          'This is a much longer description that will wrap to multiple lines when TextOverflow.visible is used. It contains a lot of text to demonstrate the dynamic height calculation feature.',
      'status': 'Inactive',
    },
    {
      'id': '3',
      'name': 'Bob Johnson',
      'description':
          'Medium length description that might need one or two lines depending on the column width and font size.',
      'status': 'Active',
    },
    {
      'id': '4',
      'name': 'Alice Brown',
      'description':
          'Another very long description with multiple sentences. This demonstrates how the table can handle varying content lengths gracefully. The row height will adjust automatically based on the content, providing a better user experience.',
      'status': 'Pending',
    },
    {
      'id': '5',
      'name': 'Charlie Wilson',
      'description': 'Short text.',
      'status': 'Active',
    },
    {
      'id': '6',
      'name': 'Diana Prince',
      'description':
          'This is an extremely long description that contains multiple paragraphs worth of text. It demonstrates how the dynamic height calculation works with very long content. The text will continue to wrap and expand the row as needed. This is the first paragraph. And here is the second paragraph with even more content to make the description longer and test the vertical expansion feature thoroughly.',
      'status': 'Active',
    },
    {
      'id': '7',
      'name': 'Edward Clark',
      'description': 'Standard length description for testing purposes.',
      'status': 'Inactive',
    },
    {
      'id': '8',
      'name': 'Fiona Davis',
      'description': 'Brief.',
      'status': 'Pending',
    },
    {
      'id': '9',
      'name': 'George Miller',
      'description':
          'This description has a moderate amount of text that should wrap to about two or three lines depending on the available space and font settings.',
      'status': 'Active',
    },
    {
      'id': '10',
      'name': 'Helen Garcia',
      'description':
          'Another extremely detailed description that spans multiple lines. This one includes various technical details, specifications, and comprehensive information about the subject matter. It demonstrates the flexibility of the dynamic height system and how it handles extensive text content without compromising the user interface.',
      'status': 'Inactive',
    },
    {
      'id': '11',
      'name': 'Ivan Rodriguez',
      'description': 'Minimal text.',
      'status': 'Active',
    },
    {
      'id': '12',
      'name': 'Julia Martinez',
      'description':
          'This is a comprehensive description that includes detailed information about various aspects of the topic. It covers multiple points and provides extensive coverage of the subject matter at hand.',
      'status': 'Pending',
    },
    {
      'id': '13',
      'name': 'Kevin Lee',
      'description': 'Quick note.',
      'status': 'Active',
    },
    {
      'id': '14',
      'name': 'Linda Wang',
      'description':
          'A thorough and detailed explanation that encompasses various elements and provides comprehensive coverage of the topic. This description demonstrates how the system handles substantial amounts of text content while maintaining proper formatting and readability.',
      'status': 'Inactive',
    },
    {
      'id': '15',
      'name': 'Michael Johnson',
      'description':
          'Standard description with normal length content that fits comfortably within typical display parameters.',
      'status': 'Active',
    },
    {
      'id': '16',
      'name': 'Nancy Chen',
      'description': 'Tiny.',
      'status': 'Pending',
    },
    {
      'id': '17',
      'name': 'Oliver Thompson',
      'description':
          'This extensive description provides comprehensive details about various aspects and includes multiple components of information. It serves as an excellent example of how the dynamic height feature adapts to accommodate longer text content while preserving the overall table structure and user experience.',
      'status': 'Active',
    },
    {
      'id': '18',
      'name': 'Patricia White',
      'description': 'Regular length content for demonstration.',
      'status': 'Inactive',
    },
    {
      'id': '19',
      'name': 'Quincy Adams',
      'description': 'Brief description.',
      'status': 'Pending',
    },
    {
      'id': '20',
      'name': 'Rachel Green',
      'description':
          'This is a substantial description that contains multiple sentences and covers various topics in detail. It demonstrates the dynamic height calculation system\'s ability to handle extensive text content while maintaining proper formatting and ensuring optimal user experience across different content lengths.',
      'status': 'Active',
    },
    {
      'id': '21',
      'name': 'Samuel Davis',
      'description': 'Another example of varying content length for testing.',
      'status': 'Inactive',
    },
    {
      'id': '22',
      'name': 'Tina Brown',
      'description': 'Compact text.',
      'status': 'Active',
    },
    {
      'id': '23',
      'name': 'Victor Hugo',
      'description':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
      'status': 'Pending',
    },
    {
      'id': '24',
      'name': 'Wendy Wilson',
      'description': 'Simple text entry.',
      'status': 'Active',
    },
    {
      'id': '25',
      'name': 'Xavier Smith',
      'description':
          'This comprehensive example showcases the full capabilities of the dynamic height system with extensive content that spans multiple lines and demonstrates various aspects of text rendering and height calculation functionality.',
      'status': 'Inactive',
    },
  ];

  late List<TablePlusColumn> columns;
  late List<double> columnWidths;

  // Selection state
  Set<String> selectedRows = {};

  // Sorting state
  String? sortColumnKey;
  SortDirection sortDirection = SortDirection.none;

  // Editing state
  bool isEditingEnabled = false;

  @override
  void initState() {
    super.initState();

    // Define columns with TextOverflow.visible for description
    columns = [
      TablePlusColumn(
        key: 'id',
        label: 'ID',
        width: 80,
        order: 0,
        sortable: true,
        textOverflow: TextOverflow.ellipsis,
      ),
      TablePlusColumn(
        key: 'name',
        label: 'Name',
        width: 120,
        order: 1,
        sortable: true,
        editable: true,
        textOverflow: TextOverflow.ellipsis,
      ),
      TablePlusColumn(
        key: 'description',
        label: 'Description',
        width: 300,
        order: 2,
        sortable: true,
        editable: true,
        textOverflow: TextOverflow.visible, // This will expand vertically
      ),
      TablePlusColumn(
        key: 'status',
        label: 'Status',
        width: 100,
        order: 3,
        sortable: true,
        editable: true,
        textOverflow: TextOverflow.ellipsis,
      ),
    ];

    // Calculate column widths (in a real app, you might get these from the table's state)
    columnWidths = columns.map((col) => col.width).toList();
  }

  /// Handle row selection changes
  void _handleRowSelectionChanged(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedRows.add(rowId);
      } else {
        selectedRows.remove(rowId);
      }
    });
  }

  /// Handle select all
  void _handleSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        selectedRows = data.map((row) => row['id'].toString()).toSet();
      } else {
        selectedRows.clear();
      }
    });
  }

  /// Handle column sorting
  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      sortColumnKey = columnKey;
      sortDirection = direction;

      if (direction == SortDirection.none) {
        // Reset to original order - you might want to store original order
        // For now, we'll sort by ID
        data.sort((a, b) => a['id'].toString().compareTo(b['id'].toString()));
      } else {
        data.sort((a, b) {
          dynamic aValue = a[columnKey];
          dynamic bValue = b[columnKey];

          // Handle null values
          if (aValue == null && bValue == null) {
            return 0;
          }
          if (aValue == null) {
            return direction == SortDirection.ascending ? -1 : 1;
          }
          if (bValue == null) {
            return direction == SortDirection.ascending ? 1 : -1;
          }
          // Convert to strings for comparison
          String aStr = aValue.toString().toLowerCase();
          String bStr = bValue.toString().toLowerCase();

          int result = aStr.compareTo(bStr);
          return direction == SortDirection.ascending ? result : -result;
        });
      }
    });
  }

  /// Handle cell value changes
  void _handleCellChanged(
    String columnKey,
    int rowIndex,
    dynamic oldValue,
    dynamic newValue,
  ) {
    setState(() {
      data[rowIndex][columnKey] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 14, color: Color(0xFF212121));
    const theme = TablePlusTheme(
      bodyTheme: TablePlusBodyTheme(
        rowHeight: 48, // This is the fallback/minimum height
        textStyle: textStyle,
        padding: EdgeInsets.symmetric(horizontal: 64.0, vertical: 8.0),
        showHorizontalDividers: true,
        showVerticalDividers: true,
      ),
      selectionTheme: TablePlusSelectionTheme(
        selectedRowColor: Color(0xFFE3F2FD),
        checkboxColor: Color(0xFF1976D2),
      ),
      editableTheme: TablePlusEditableTheme(
        editingCellColor: Color(0xFFFFF3E0),
        editingBorderColor: Color(0xFFFF9800),
        editingBorderWidth: 2.0,
        editingTextStyle: TextStyle(
          fontSize: 14,
          color: Color(0xFF212121),
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Height Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TextOverflow.visible Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This example shows how to use the calculateRowHeight callback to support '
              'TextOverflow.visible. Notice how the Description column expands vertically '
              'to show all content, while other columns remain fixed height.\n\n'
              'Selected rows: ${selectedRows.length}/25',
              style: TextStyle(
                color: selectedRows.isNotEmpty ? Colors.blue.shade700 : null,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditingEnabled = !isEditingEnabled;
                      if (isEditingEnabled) {
                        // Clear selection when entering edit mode
                        selectedRows.clear();
                      }
                    });
                  },
                  icon: Icon(isEditingEnabled ? Icons.check : Icons.edit),
                  label: Text(
                      isEditingEnabled ? 'Exit Edit Mode' : 'Enter Edit Mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isEditingEnabled ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                if (isEditingEnabled)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '💡 Click cells to edit (Name, Description, Status)',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 700, // Fixed height for better visibility
              child: FlutterTablePlus(
                columns: Map.fromEntries(
                  columns.map((col) => MapEntry(col.key, col)),
                ),
                data: data,
                // Selection features (disabled in edit mode)
                isSelectable: !isEditingEnabled,
                selectionMode: SelectionMode.multiple,
                selectedRows: selectedRows,
                onRowSelectionChanged: _handleRowSelectionChanged,
                onSelectAll: _handleSelectAll,
                // Sorting features
                sortColumnKey: sortColumnKey,
                sortDirection: sortDirection,
                onSort: _handleSort,
                // Editing features
                isEditable: isEditingEnabled,
                onCellChanged: _handleCellChanged,
                // Use the helper utility to calculate row heights with theme padding
                calculateRowHeight:
                    TableRowHeightCalculator.createHeightCalculator(
                  columns: columns,
                  columnWidths: columnWidths,
                  defaultTextStyle: textStyle,
                  cellPadding: theme.bodyTheme.padding,
                  minHeight: 48.0,
                ),
                theme: theme,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features demonstrated:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '✓ Dynamic row heights with TextOverflow.visible\n'
                    '✓ Row selection with checkboxes\n'
                    '✓ Column sorting (click headers)\n'
                    '✓ Cell editing (Name, Description, Status)\n'
                    '✓ Proper scrollbar calculation\n'
                    '✓ 25 rows with varying content lengths\n\n'
                    'Try: Sort columns, select rows, edit cells, scroll to see all features!',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
