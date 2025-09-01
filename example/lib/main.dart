import 'package:flutter/material.dart';

import 'pages/comprehensive_demo/comprehensive_table_demo.dart';
import 'pages/table_example_page.dart';
import 'pages/comprehensive_merged_example.dart';
import 'pages/sortable_example.dart';
import 'pages/dynamic_height_example.dart';
import 'pages/expandable_summary_example.dart';
import 'pages/hover_button_demo.dart';
import 'pages/tooltip_overflow_test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Table Plus Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Table Plus Examples'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const Icon(Icons.auto_awesome,
                    color: Colors.blue, size: 28),
                title: const Text(
                  'Comprehensive Table Demo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                    '🚀 NEW! All features in one place - Progressive demo'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComprehensiveTableDemo(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Individual Feature Demos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Basic Table Example'),
                subtitle: const Text('Standard table with all features'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TableExamplePage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.merge_type),
                title: const Text('Comprehensive Merged Table'),
                subtitle: const Text(
                    'All features: sorting, editing, selection, reordering, theming'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComprehensiveMergedExample(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('Sortable Table'),
                subtitle: const Text(
                    'Table with sorting functionality and 10 sample records'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SortableExample(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.height),
                title: const Text('Dynamic Height Table'),
                subtitle:
                    const Text('TextOverflow.visible with dynamic heights'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DynamicHeightExample(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.expand_more, color: Colors.purple),
                title: const Text('Expandable Summary Example'),
                subtitle:
                    const Text('Merged rows with expandable summary totals'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpandableSummaryExample(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.touch_app, color: Colors.orange),
                title: const Text('Hover Button Demo'),
                subtitle: const Text('Row hover with action buttons - NEW!'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HoverButtonDemo(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.green),
                title: const Text('Tooltip Overflow Test'),
                subtitle: const Text(
                    'Smart tooltip behavior - onlyTextOverflow - NEW!'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TooltipOverflowTestPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
