import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class DynamicHeightExample extends StatefulWidget {
  const DynamicHeightExample({super.key});

  @override
  State<DynamicHeightExample> createState() => _DynamicHeightExampleState();
}

class _DynamicHeightExampleState extends State<DynamicHeightExample> {
  // Height mode toggle
  RowHeightMode _currentHeightMode = RowHeightMode.dynamic;
  double _minRowHeight = 48.0;

  // Sample data with varying text lengths to test height calculation
  List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'name': 'Alice Johnson',
      'department': 'Engineering',
      'description': 'Short description.',
      'notes': 'Basic note',
      'status': 'Active'
    },
    {
      'id': '2',
      'name':
          'Bob Smith with a very long name that should wrap to multiple lines when displayed',
      'department': 'Marketing',
      'description':
          'This is a much longer description that contains multiple sentences and should demonstrate how the dynamic height calculation works when content exceeds the normal row height. It includes detailed information about the employee\'s role and responsibilities.',
      'notes':
          'Extended notes with multiple lines of content to test height calculation',
      'status': 'Active'
    },
    {
      'id': '3',
      'name': 'Charlie Brown',
      'department': 'Engineering',
      'description':
          'Medium length description that spans across a couple of lines but not too many.',
      'notes': 'Some notes here',
      'status': 'Inactive'
    },
    {
      'id': '4',
      'name': 'Diana Prince',
      'department': 'HR',
      'description':
          'Another very long description that demonstrates the dynamic height feature. This description includes multiple sentences with detailed information about the employee, their background, current projects, and future goals within the organization.',
      'notes':
          'Comprehensive notes covering various aspects of the employee including performance reviews, training records, and development plans for the upcoming quarter.',
      'status': 'Active'
    },
    {
      'id': '5',
      'name': 'Ethan Hunt',
      'department': 'Security',
      'description': 'Brief desc.',
      'notes': 'Quick note',
      'status': 'Active'
    },
    {
      'id': '6',
      'name': 'Fiona Green',
      'department': 'Finance',
      'description':
          'Standard length description with normal content that fits within typical row height expectations.',
      'notes': 'Regular notes without excessive content',
      'status': 'Active'
    },
  ];

  // Merged groups for testing height calculation in merged rows
  List<MergedRowGroup> get mergedGroups => [
        // Engineering Department Group - includes both short and long content
        MergedRowGroup(
          groupId: 'engineering_group',
          rowKeys: ['1', '3'], // Alice (short) and Charlie (medium)
          mergeConfig: {
            'department': MergeCellConfig(
              shouldMerge: true,
              spanningRowIndex: 0,
              mergedContent: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.computer, color: Colors.blue.shade600, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Engineering',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    // Column configuration with different text overflow settings
    final Map<String, TablePlusColumn> columns = {
      'id': TablePlusColumn(
        key: 'id',
        label: 'ID',
        order: 0,
        width: 60,
        textOverflow: TextOverflow.ellipsis, // Fixed height
      ),
      'name': TablePlusColumn(
        key: 'name',
        label: 'Name',
        order: 1,
        width: 150,
        textOverflow: TextOverflow.visible, // Dynamic height
      ),
      'department': TablePlusColumn(
        key: 'department',
        label: 'Department',
        order: 2,
        width: 120,
        textOverflow: TextOverflow.ellipsis, // Fixed height
      ),
      'description': TablePlusColumn(
        key: 'description',
        label: 'Description',
        order: 3,
        width: 200,
        textOverflow: TextOverflow.visible, // Dynamic height
      ),
      'notes': TablePlusColumn(
        key: 'notes',
        label: 'Notes',
        order: 4,
        width: 180,
        textOverflow: TextOverflow.visible, // Dynamic height
      ),
      'status': TablePlusColumn(
        key: 'status',
        label: 'Status',
        order: 5,
        width: 80,
        textOverflow: TextOverflow.ellipsis, // Fixed height
        cellBuilder: (context, rowData) {
          final status = rowData['status'] as String;
          final isActive = status == 'Active';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Height Testing'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        actions: [
          // Height mode toggle button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: SegmentedButton<RowHeightMode>(
                segments: const [
                  ButtonSegment(
                    value: RowHeightMode.uniform,
                    label: Text('Uniform'),
                    icon: Icon(Icons.view_headline),
                  ),
                  ButtonSegment(
                    value: RowHeightMode.dynamic,
                    label: Text('Dynamic'),
                    icon: Icon(Icons.view_stream),
                  ),
                ],
                selected: {_currentHeightMode},
                onSelectionChanged: (Set<RowHeightMode> selection) {
                  setState(() {
                    _currentHeightMode = selection.first;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.purple.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Dynamic Height Testing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Mode: ${_currentHeightMode.name.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This example demonstrates the difference between uniform and dynamic row height modes. '
                    'Toggle between modes using the buttons in the app bar.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• UNIFORM: All rows have the same height (based on the tallest row)',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const Text(
                    '• DYNAMIC: Each row height adapts to its content',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Height settings
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Height Settings',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Min Row Height: '),
                        Text(
                          '${_minRowHeight.toInt()}px',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Slider(
                            value: _minRowHeight,
                            min: 32.0,
                            max: 80.0,
                            divisions: 12,
                            label: '${_minRowHeight.toInt()}px',
                            onChanged: (value) {
                              setState(() {
                                _minRowHeight = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Column overflow information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Column Text Overflow Settings',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        '• Name, Description, Notes: TextOverflow.visible (affects height)',
                        style: TextStyle(fontSize: 12)),
                    const Text(
                        '• ID, Department, Status: TextOverflow.ellipsis (fixed height)',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Table section
            Container(
              height: 600,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlutterTablePlus(
                columns: columns,
                data: data,
                rowIdKey: 'id',
                mergedGroups: mergedGroups,
                rowHeightMode: _currentHeightMode,
                minRowHeight: _minRowHeight,
                theme: TablePlusTheme(
                  headerTheme: TablePlusHeaderTheme(
                    backgroundColor: Colors.grey.shade100,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    height: 50,
                    showBottomDivider: true,
                    dividerColor: Colors.grey.shade300,
                  ),
                  bodyTheme: TablePlusBodyTheme(
                    alternateRowColor: Colors.blue.shade50,
                    rowHeight: _minRowHeight,
                    textStyle: const TextStyle(fontSize: 13),
                    dividerColor: Colors.grey.shade200,
                    showHorizontalDividers: true,
                    showVerticalDividers: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Feature explanation
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Scenarios',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildTestScenario(
                      'Row 1 (Alice)',
                      'Short content - should use minimum height',
                      Icons.short_text,
                      Colors.green,
                    ),
                    _buildTestScenario(
                      'Row 2 (Bob)',
                      'Very long content - should expand significantly',
                      Icons.subject,
                      Colors.orange,
                    ),
                    _buildTestScenario(
                      'Rows 1 & 3 (Merged)',
                      'Engineering group - height based on tallest member',
                      Icons.merge_type,
                      Colors.blue,
                    ),
                    _buildTestScenario(
                      'Row 4 (Diana)',
                      'Long description and notes - multiple line expansion',
                      Icons.notes,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestScenario(
      String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
