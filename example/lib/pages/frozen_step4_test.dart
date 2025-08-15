import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class FrozenStep4Test extends StatelessWidget {
  const FrozenStep4Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4단계: 수직 스크롤 동기화 테스트'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '4단계 테스트: 수직 스크롤 동기화',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // 긴 테이블로 수직 스크롤 테스트
              _buildLongVerticalScrollTest(),
              const SizedBox(height: 16),
              
              // 동적 높이 + freeze 테스트
              _buildDynamicHeightTest(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLongVerticalScrollTest() {
    final columns = {
      'id': TablePlusColumn(
        key: 'id',
        label: 'ID',
        order: 1,
        frozen: true,
        width: 60,
      ),
      'name': TablePlusColumn(
        key: 'name',
        label: 'Name',
        order: 2,
        frozen: true,
        width: 120,
      ),
      'email': TablePlusColumn(
        key: 'email',
        label: 'Email Address',
        order: 3,
        frozen: false,
        width: 250,
      ),
      'phone': TablePlusColumn(
        key: 'phone',
        label: 'Phone Number',
        order: 4,
        frozen: false,
        width: 150,
      ),
      'department': TablePlusColumn(
        key: 'department',
        label: 'Department',
        order: 5,
        frozen: false,
        width: 200,
      ),
      'address': TablePlusColumn(
        key: 'address',
        label: 'Full Address',
        order: 6,
        frozen: false,
        width: 300,
      ),
    };

    // 많은 데이터 생성 (수직 스크롤이 필요하도록)
    final longData = List.generate(50, (index) => {
      'id': '${index + 1}',
      'name': 'Person ${index + 1}',
      'email': 'person${index + 1}@company.com',
      'phone': '555-${(index + 1).toString().padLeft(4, '0')}',
      'department': ['Engineering', 'Marketing', 'Sales', 'HR', 'Finance'][index % 5],
      'address': '${index + 1} Main Street, City ${(index % 10) + 1}, State ${(index % 5) + 1}',
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('수직 스크롤 동기화 테스트', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('50개 행 - frozen/scrollable 영역이 함께 스크롤되어야 함'),
            const SizedBox(height: 8),
            SizedBox(
              height: 400,
              child: FlutterTablePlus(
                columns: columns,
                data: longData,
                isSelectable: true,
                selectedRows: {'1', '5', '10'},
                onRowSelectionChanged: (rowId, isSelected) {
                  print('Row $rowId selection: $isSelected');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicHeightTest() {
    final columns = {
      'id': TablePlusColumn(
        key: 'id',
        label: 'ID',
        order: 1,
        frozen: true,
        width: 60,
      ),
      'title': TablePlusColumn(
        key: 'title',
        label: 'Title',
        order: 2,
        frozen: true,
        width: 120,
      ),
      'description': TablePlusColumn(
        key: 'description',
        label: 'Description',
        order: 3,
        frozen: false,
        width: 400,
        textOverflow: TextOverflow.visible,
      ),
      'category': TablePlusColumn(
        key: 'category',
        label: 'Category',
        order: 4,
        frozen: false,
        width: 150,
      ),
    };

    final dynamicData = [
      {
        'id': '1',
        'title': 'Short',
        'description': 'Simple task',
        'category': 'Quick',
      },
      {
        'id': '2',
        'title': 'Medium',
        'description': 'This is a medium-length description that should wrap to multiple lines to test the dynamic height feature',
        'category': 'Normal',
      },
      {
        'id': '3',
        'title': 'Long',
        'description': 'This is a very long description that should definitely wrap to multiple lines to demonstrate how the dynamic height calculation works with the freeze column feature. It should be quite long to ensure proper testing.',
        'category': 'Complex',
      },
      {
        'id': '4',
        'title': 'Short',
        'description': 'Another simple task',
        'category': 'Quick',
      },
      {
        'id': '5',
        'title': 'Variable',
        'description': 'This description has a variable length that might wrap to two or three lines depending on the available width and font size settings.',
        'category': 'Variable',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('동적 높이 + Freeze 테스트', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('다양한 높이의 행들이 양쪽 영역에서 동일하게 표시되어야 함'),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: FlutterTablePlus(
                columns: columns,
                data: dynamicData,
                isSelectable: false,
                calculateRowHeight: (index, rowData) {
                  // 설명 텍스트 길이에 따라 동적 높이 계산
                  final description = rowData['description']?.toString() ?? '';
                  final baseHeight = 48.0;
                  final extraHeight = (description.length / 50).ceil() * 20.0;
                  return baseHeight + extraHeight;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}