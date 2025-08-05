import 'package:flutter/material.dart';

/// Documentation and examples section for the table example
class ExampleDocumentation extends StatelessWidget {
  const ExampleDocumentation({
    super.key,
    required this.showVerticalDividers,
    required this.isSelectable,
    required this.isEditable,
  });

  final bool showVerticalDividers;
  final bool isSelectable;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Features info
        Text(
          'Features demonstrated:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        _buildFeaturesList(),

        if (isSelectable) ...[
          const SizedBox(height: 8),
          _buildSelectionFeatures(),
        ],

        if (isEditable) ...[
          const SizedBox(height: 8),
          _buildEditingFeatures(),
        ],

        const SizedBox(height: 16),

        // Controls info
        Text(
          'Interactive Controls:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        _buildControlsList(),

        const SizedBox(height: 16),

        // API Usage Example
        Text(
          'Code Example:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        _buildCodeExample(),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• Map-based column management with TableColumnsBuilder'),
        const Text('• Automatic order assignment and conflict prevention'),
        const Text('• Custom cell builders (Salary formatting, Status badges)'),
        const Text('• Alternating row colors and responsive layout'),
        const Text('• Synchronized horizontal and vertical scrolling'),
        const Text('• Hover-based scrollbar visibility'),
        const Text('• Column width management with min/max constraints'),
        Text(
          '• Customizable table borders (${showVerticalDividers ? "Grid" : "Horizontal only"})',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.purple),
        ),
        const Text(
          '• Column reordering via drag and drop',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const Text(
          '• Column sorting (click header to sort: ↑ ↓ clear)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const Text(
          '• Cell editing mode (even custom cells!)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildSelectionFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Selection Features:',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        Text(
          '• Individual row selection with checkboxes',
          style: TextStyle(color: Colors.blue),
        ),
        Text(
          '• Tap anywhere on row to toggle selection',
          style: TextStyle(color: Colors.blue),
        ),
        Text(
          '• Select all/none with header checkbox',
          style: TextStyle(color: Colors.blue),
        ),
        Text(
          '• Intuitive select-all behavior (any selected → clear all)',
          style: TextStyle(color: Colors.blue),
        ),
        Text(
          '• Custom selection actions and callbacks',
          style: TextStyle(color: Colors.blue),
        ),
        Text(
          '• Selection state management by parent widget',
          style: TextStyle(color: Colors.blue),
        ),
        Text(
          '• Single and Multiple selection modes',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEditingFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Editing Features:',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        Text(
          '• Click on ANY editable cell to start editing',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Custom cells (Salary, Status) also editable!',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        Text(
          '• Salary: Enter numbers (e.g., 80000)',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Status: Enter "true/false" or "active/inactive"',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Age: Enter numbers only',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Beautifully styled inline text fields',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Vertically centered text with rounded borders',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Press Enter or click away to save changes',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Press Escape to cancel editing',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Smart data conversion (string → number/boolean)',
          style: TextStyle(color: Colors.orange),
        ),
        Text(
          '• Row selection disabled in editing mode',
          style: TextStyle(color: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildControlsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• 🔄 Reset column order to default'),
        const Text('• 🔀 Clear sort (reset to original order)'),
        const Text(
            '• 🔲 Toggle vertical dividers (Grid vs Horizontal-only design)'),
        const Text('• ✏️ Toggle editing mode (Cell editing with text fields)'),
        const Text(
            '• ☑️ Toggle selection mode (Row selection with checkboxes)'),
        const Text('• 🔘 Toggle single/multiple selection mode'),
        const Text('• 🖱️ Drag column headers to reorder'),
        const Text('• 🔤 Click sortable column headers to sort'),
        if (isSelectable) ...[
          const Text('• 🧹 Clear all selections'),
          const Text('• 👥 Select only active employees'),
          const Text('• ℹ️ Show selected employee details'),
        ],
      ],
    );
  }

  Widget _buildCodeExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '''final columns = TableColumnsBuilder()
  .addColumn('name', TablePlusColumn(
    sortable: true,
    editable: true, // Enable cell editing
    ...
  ))
  .addColumn('salary', TablePlusColumn(
    editable: true, // Custom cells can also be edited!
    cellBuilder: customSalaryBuilder, // Shows formatted in view mode
    // In edit mode: shows raw number for editing
    ...
  ))
  .build();

FlutterTablePlus(
  columns: columns,
  data: data,
  isSelectable: true,
  selectionMode: SelectionMode.single, // Single selection mode
  isEditable: true, // Enable editing mode
  theme: TablePlusTheme(
    editableTheme: TablePlusEditableTheme(
      textAlignVertical: TextAlignVertical.center, // Vertical center
      editingBorderRadius: BorderRadius.circular(6.0), // Rounded
      filled: true, // Fill background
    ),
  ),
  onCellChanged: (columnKey, rowIndex, oldValue, newValue) {
    // Handle data type conversion
    dynamic convertedValue = newValue;
    if (columnKey == 'salary') {
      convertedValue = int.tryParse(newValue) ?? oldValue;
    } else if (columnKey == 'active') {
      convertedValue = newValue.toLowerCase() == 'true' ||
                     newValue.toLowerCase() == 'active';
    }
    
    // Update your data
    setState(() {
      data[rowIndex][columnKey] = convertedValue;
    });
  },
  onRowSelectionChanged: (rowId, isSelected) {
    // Handle selection changes
    setState(() {
      if (selectionMode == SelectionMode.single) {
        selectedRows.clear(); // Clear other selections
        if (isSelected) selectedRows.add(rowId);
      } else {
        // Multiple selection mode
        isSelected ? selectedRows.add(rowId) : selectedRows.remove(rowId);
      }
    });
  },
);''',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}
