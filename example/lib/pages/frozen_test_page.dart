import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class FrozenTestPage extends StatelessWidget {
  const FrozenTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1단계: Frozen 속성 테스트'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1단계 테스트: frozen 속성 추가 확인',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 테스트 케이스들
            _buildTestCase('기본 컬럼 (frozen: false)', false),
            const SizedBox(height: 8),
            _buildTestCase('Frozen 컬럼 (frozen: true)', true),
            const SizedBox(height: 16),
            
            // copyWith 테스트
            _buildCopyWithTest(),
            const SizedBox(height: 16),
            
            // TableColumnsBuilder 테스트  
            _buildBuilderTest(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCase(String title, bool frozen) {
    final column = TablePlusColumn(
      key: 'test',
      label: 'Test Column',
      order: 1,
      frozen: frozen,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('frozen: ${column.frozen}'),
            Icon(
              column.frozen ? Icons.lock : Icons.lock_open,
              color: column.frozen ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyWithTest() {
    final originalColumn = TablePlusColumn(
      key: 'original',
      label: 'Original',
      order: 1,
      frozen: false,
    );

    final copiedColumn = originalColumn.copyWith(frozen: true);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('copyWith 테스트', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Original frozen: ${originalColumn.frozen}'),
            Text('Copied frozen: ${copiedColumn.frozen}'),
            Text('테스트 결과: ${copiedColumn.frozen == true ? '성공' : '실패'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBuilderTest() {
    try {
      final columns = TableColumnsBuilder()
          .addColumn('id', TablePlusColumn(
            key: 'id', 
            label: 'ID', 
            order: 0,
            frozen: true,
          ))
          .addColumn('name', TablePlusColumn(
            key: 'name', 
            label: 'Name', 
            order: 0,
            frozen: false,
          ))
          .build();

      final idColumn = columns['id']!;
      final nameColumn = columns['name']!;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TableColumnsBuilder 테스트', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('ID 컬럼 frozen: ${idColumn.frozen}'),
              Text('Name 컬럼 frozen: ${nameColumn.frozen}'),
              Text('테스트 결과: ${idColumn.frozen == true && nameColumn.frozen == false ? '성공' : '실패'}'),
            ],
          ),
        ),
      );
    } catch (e) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TableColumnsBuilder 테스트', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('에러: $e', style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    }
  }
}