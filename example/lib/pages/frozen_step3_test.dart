import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class FrozenStep3Test extends StatelessWidget {
  const FrozenStep3Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3단계: Row 기반 레이아웃 테스트'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '3단계 테스트: Row 기반 레이아웃 구조',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // 기본 freeze 테스트
              _buildBasicFreezeTest(),
              const SizedBox(height: 16),
              
              // 선택 기능과 freeze 테스트
              _buildSelectionFreezeTest(),
              const SizedBox(height: 16),
              
              // 긴 테이블 스크롤 테스트
              _buildLongTableTest(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicFreezeTest() {
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
        label: 'Email',
        order: 3,
        frozen: false,
        width: 300, // 더 넓게
      ),
      'phone': TablePlusColumn(
        key: 'phone',
        label: 'Phone',
        order: 4,
        frozen: false,
        width: 200, // 더 넓게
      ),
      'address': TablePlusColumn(
        key: 'address',
        label: 'Address',
        order: 5,
        frozen: false,
        width: 400, // 더 넓게
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('기본 Freeze 테스트', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('ID와 Name이 고정, 나머지는 스크롤 가능해야 함'),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: FlutterTablePlus(
                columns: columns,
                data: _generateSampleData(),
                isSelectable: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionFreezeTest() {
    final columns = {
      'name': TablePlusColumn(
        key: 'name',
        label: 'Name',
        order: 1,
        frozen: true,
        width: 120,
      ),
      'email': TablePlusColumn(
        key: 'email',
        label: 'Email',
        order: 2,
        frozen: false,
        width: 200,
      ),
      'phone': TablePlusColumn(
        key: 'phone',
        label: 'Phone',
        order: 3,
        frozen: false,
        width: 150,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selection + Freeze 테스트', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('선택 컬럼과 Name이 고정, Email/Phone이 스크롤 가능'),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: FlutterTablePlus(
                columns: columns,
                data: _generateSampleData(),
                isSelectable: true,
                selectedRows: const {'1', '3'},
                onRowSelectionChanged: (rowId, isSelected) {
                  print('Row $rowId selection: $isSelected');
                },
                onSelectAll: (selectAll) {
                  print('Select all: $selectAll');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLongTableTest() {
    final columns = {
      'id': TablePlusColumn(
        key: 'id',
        label: 'ID',
        order: 1,
        frozen: true,
        width: 50,
      ),
      'col1': TablePlusColumn(
        key: 'col1',
        label: 'Column 1',
        order: 2,
        frozen: false,
        width: 100,
      ),
      'col2': TablePlusColumn(
        key: 'col2',
        label: 'Column 2',
        order: 3,
        frozen: false,
        width: 100,
      ),
      'col3': TablePlusColumn(
        key: 'col3',
        label: 'Column 3',
        order: 4,
        frozen: false,
        width: 100,
      ),
      'col4': TablePlusColumn(
        key: 'col4',
        label: 'Column 4',
        order: 5,
        frozen: false,
        width: 100,
      ),
      'col5': TablePlusColumn(
        key: 'col5',
        label: 'Column 5',
        order: 6,
        frozen: false,
        width: 100,
      ),
      'col6': TablePlusColumn(
        key: 'col6',
        label: 'Column 6',
        order: 7,
        frozen: false,
        width: 100,
      ),
    };

    final wideData = List.generate(10, (index) => {
      'id': '${index + 1}',
      'col1': 'Data ${index + 1}-1',
      'col2': 'Data ${index + 1}-2',
      'col3': 'Data ${index + 1}-3',
      'col4': 'Data ${index + 1}-4',
      'col5': 'Data ${index + 1}-5',
      'col6': 'Data ${index + 1}-6',
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('가로 스크롤 테스트', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('ID는 고정, 나머지 컬럼들은 가로 스크롤로 확인'),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: FlutterTablePlus(
                columns: columns,
                data: wideData,
                isSelectable: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateSampleData() {
    return [
      {
        'id': '1',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '123-456-7890',
        'address': '123 Main Street, Springfield, IL 62701',
      },
      {
        'id': '2',
        'name': 'Jane Smith',
        'email': 'jane.smith@example.com',
        'phone': '098-765-4321',
        'address': '456 Oak Avenue, Springfield, IL 62702',
      },
      {
        'id': '3',
        'name': 'Bob Johnson',
        'email': 'bob.johnson@example.com',
        'phone': '555-123-4567',
        'address': '789 Pine Road, Springfield, IL 62703',
      },
      {
        'id': '4',
        'name': 'Alice Brown',
        'email': 'alice.brown@example.com',
        'phone': '777-888-9999',
        'address': '321 Elm Street, Springfield, IL 62704',
      },
      {
        'id': '5',
        'name': 'Charlie Wilson',
        'email': 'charlie.wilson@example.com',
        'phone': '111-222-3333',
        'address': '654 Maple Drive, Springfield, IL 62705',
      },
    ];
  }
}