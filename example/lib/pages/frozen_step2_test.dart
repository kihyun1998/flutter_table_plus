import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class FrozenStep2Test extends StatelessWidget {
  const FrozenStep2Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2단계: 컬럼 분리 로직 테스트'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '2단계 테스트: 컬럼 분리 로직',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 테스트 케이스 1: 선택 기능 없음
              _buildTestCase1(),
              const SizedBox(height: 16),

              // 테스트 케이스 2: 선택 기능 있음
              _buildTestCase2(),
              const SizedBox(height: 16),

              // 테스트 케이스 3: 혼합 컬럼
              _buildTestCase3(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCase1() {
    final columns = {
      'name': TablePlusColumn(
        key: 'name',
        label: 'Name',
        order: 1,
        frozen: true,
      ),
      'email': TablePlusColumn(
        key: 'email',
        label: 'Email',
        order: 2,
        frozen: false,
      ),
      'phone': TablePlusColumn(
        key: 'phone',
        label: 'Phone',
        order: 3,
        frozen: false,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('테스트 케이스 1: 선택 기능 없음',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: FlutterTablePlus(
                columns: columns,
                data: const [
                  {
                    'name': 'John',
                    'email': 'john@example.com',
                    'phone': '123-456-7890'
                  },
                  {
                    'name': 'Jane',
                    'email': 'jane@example.com',
                    'phone': '098-765-4321'
                  },
                ],
                isSelectable: false,
              ),
            ),
            const SizedBox(height: 8),
            const Text('예상: name이 frozen, email과 phone이 scrollable'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCase2() {
    final columns = {
      'name': TablePlusColumn(
        key: 'name',
        label: 'Name',
        order: 1,
        frozen: true,
      ),
      'email': TablePlusColumn(
        key: 'email',
        label: 'Email',
        order: 2,
        frozen: false,
      ),
      'phone': TablePlusColumn(
        key: 'phone',
        label: 'Phone',
        order: 3,
        frozen: false,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('테스트 케이스 2: 선택 기능 있음',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: FlutterTablePlus(
                columns: columns,
                data: const [
                  {
                    'id': '1',
                    'name': 'John',
                    'email': 'john@example.com',
                    'phone': '123-456-7890'
                  },
                  {
                    'id': '2',
                    'name': 'Jane',
                    'email': 'jane@example.com',
                    'phone': '098-765-4321'
                  },
                ],
                isSelectable: true,
                selectedRows: const {'1'},
                onRowSelectionChanged: (rowId, isSelected) {
                  print('Row $rowId selection changed: $isSelected');
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
                '예상: selection column과 name이 frozen, email과 phone이 scrollable'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCase3() {
    final columns = {
      'id': TablePlusColumn(
        key: 'id',
        label: 'ID',
        order: 1,
        frozen: true,
      ),
      'name': TablePlusColumn(
        key: 'name',
        label: 'Name',
        order: 2,
        frozen: true,
      ),
      'email': TablePlusColumn(
        key: 'email',
        label: 'Email',
        order: 3,
        frozen: false,
      ),
      'phone': TablePlusColumn(
        key: 'phone',
        label: 'Phone',
        order: 4,
        frozen: false,
      ),
      'address': TablePlusColumn(
        key: 'address',
        label: 'Address',
        order: 5,
        frozen: false,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('테스트 케이스 3: 혼합 컬럼 (긴 테이블)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: FlutterTablePlus(
                columns: columns,
                data: const [
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
                ],
                isSelectable: false,
              ),
            ),
            const SizedBox(height: 8),
            const Text('예상: ID와 Name이 frozen, Email/Phone/Address가 scrollable'),
          ],
        ),
      ),
    );
  }
}
