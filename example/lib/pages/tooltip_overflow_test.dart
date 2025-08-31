import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Test page for onlyTextOverflow tooltip behavior
class TooltipOverflowTestPage extends StatefulWidget {
  const TooltipOverflowTestPage({super.key});

  @override
  State<TooltipOverflowTestPage> createState() => _TooltipOverflowTestPageState();
}

class _TooltipOverflowTestPageState extends State<TooltipOverflowTestPage> {
  final Map<String, TablePlusColumn> _columns = {
    'short': TablePlusColumn(
      key: 'short',
      label: 'Short Content',
      order: 0,
      width: 150,
      textOverflow: TextOverflow.ellipsis,
      tooltipBehavior: TooltipBehavior.onlyTextOverflow,
    ),
    'long': TablePlusColumn(
      key: 'long',
      label: 'Long Content That Should Overflow',
      order: 1,
      width: 150,
      textOverflow: TextOverflow.ellipsis,
      tooltipBehavior: TooltipBehavior.onlyTextOverflow,
      headerTooltipBehavior: TooltipBehavior.onlyTextOverflow,
    ),
    'always': TablePlusColumn(
      key: 'always',
      label: 'Always Shows Tooltip',
      order: 2,
      width: 150,
      textOverflow: TextOverflow.ellipsis,
      tooltipBehavior: TooltipBehavior.always,
    ),
    'never': TablePlusColumn(
      key: 'never',
      label: 'Never Shows Tooltip Even When Very Long Text',
      order: 3,
      width: 150,
      textOverflow: TextOverflow.ellipsis,
      tooltipBehavior: TooltipBehavior.never,
    ),
  };

  final List<Map<String, dynamic>> _data = [
    {
      'id': 1,
      'short': 'Short text',
      'long': 'This is a very long text that should definitely overflow and trigger the onlyTextOverflow tooltip behavior',
      'always': 'Short',
      'never': 'This text is long but will never show tooltip due to never behavior',
    },
    {
      'id': 2,
      'short': 'OK',
      'long': 'Another very long text content that exceeds the column width and should show tooltip only when it actually overflows',
      'always': 'Also short',
      'never': 'Long text that will be cut off but no tooltip will appear',
    },
    {
      'id': 3,
      'short': 'Good',
      'long': 'Short',
      'always': 'Test',
      'never': 'Test',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tooltip Overflow Test'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tooltip Behavior Test',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Short Content: Only shows tooltip when text overflows'),
                    Text('• Long Content: Only shows tooltip when text overflows (header too)'),
                    Text('• Always Shows: Always shows tooltip regardless of overflow'),
                    Text('• Never Shows: Never shows tooltip even when text overflows'),
                    SizedBox(height: 8),
                    Text(
                      'Hover over cells and headers to test tooltip behavior!',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FlutterTablePlus(
                  columns: _columns,
                  data: _data,
                  theme: const TablePlusTheme(
                    headerTheme: TablePlusHeaderTheme(
                      backgroundColor: Color(0xFFE3F2FD),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                        fontSize: 14,
                      ),
                      height: 48,
                    ),
                    bodyTheme: TablePlusBodyTheme(
                      textStyle: TextStyle(fontSize: 14),
                      rowHeight: 56,
                      alternateRowColor: Color(0xFFF8F9FA),
                    ),
                    tooltipTheme: TablePlusTooltipTheme(
                      enabled: true,
                      textStyle: TextStyle(fontSize: 12, color: Colors.white),
                      decoration: BoxDecoration(
                        color: Color(0xFF424242),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
}