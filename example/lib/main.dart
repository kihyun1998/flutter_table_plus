import 'package:flutter/material.dart';

import 'pages/table_example_page.dart';
import 'pages/simple_merged_example.dart';
import 'pages/complex_merged_example.dart';
import 'pages/selectable_merged_example.dart';
import 'pages/editable_merged_example.dart';
import 'pages/sortable_example.dart';
import 'pages/dynamic_height_example.dart';
import 'pages/frozen_test_page.dart';
import 'pages/frozen_step2_test.dart';

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
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.green),
                title: const Text('1단계: Frozen 속성 테스트'),
                subtitle: const Text('frozen 속성 추가 확인'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FrozenTestPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.splitscreen, color: Colors.blue),
                title: const Text('2단계: 컬럼 분리 로직 테스트'),
                subtitle: const Text('frozen/scrollable 컬럼 분리 확인'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FrozenStep2Test(),
                    ),
                  );
                },
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
                title: const Text('Simple Merged Table'),
                subtitle: const Text('2 rows merged in Department column'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleMergedExample(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.table_rows),
                title: const Text('Complex Merged Table'),
                subtitle: const Text(
                    'Multiple columns, custom content, multiple groups'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComplexMergedExample(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Selectable Merged Table'),
                subtitle:
                    const Text('Selection functionality with merged rows'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectableMergedExample(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editable Merged Table'),
                subtitle: const Text('Cell editing with merged rows'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditableMergedExample(),
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
                subtitle: const Text('TextOverflow.visible with dynamic heights'),
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
          ],
        ),
      ),
    );
  }
}
