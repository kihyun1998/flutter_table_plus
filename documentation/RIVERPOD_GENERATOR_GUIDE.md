# Integrating with Riverpod (Code Generator)

This guide demonstrates how to efficiently manage the state of `FlutterTablePlus` using the Riverpod code generator. We will cover both class-based notifiers (`@riverpod class`) for managing state logic and function-based providers (`@riverpod`) for deriving and memoizing state.

This approach ensures optimal performance by minimizing widget rebuilds.

## 1. Add Dependencies

First, add the necessary Riverpod packages to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  build_runner: ^2.4.10
  riverpod_generator: ^2.4.2
```

## 2. Define the State Model

Create a model class to hold all the state related to the table. Using a single state object makes it easy to manage and extend.

**`table_state.dart`**
```dart
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_state.freezed.dart';

@freezed
class TableState with _$TableState {
  const factory TableState({
    // Original, unsorted data
    @Default([]) List<Map<String, dynamic>> allEmployees,
    
    // Sorting state
    String? sortColumnKey,
    @Default(SortDirection.none) SortDirection sortDirection,
    
    // Selection state
    @Default({}) Set<String> selectedRowIds,
    
    // UI options
    @Default(true) bool showVerticalDividers,
    @Default(false) bool isSelectable,
    
    // Loading/Error state
    @Default(true) bool isLoading,
    String? error,
  }) = _TableState;
}
```
*We use `freezed` for a robust, immutable state class, but a simple class with a `copyWith` method also works.*

## 3. Create the State Notifier (`@riverpod class`)

The Notifier is a class that contains all the business logic for mutating the state. It's the central place for handling user interactions like sorting and selection.

**`employee_table_notifier.dart`**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_table_plus_example/data/sample_data.dart'; // Your data source
import 'table_state.dart';

part 'employee_table_notifier.g.dart';

@riverpod
class EmployeeTableNotifier extends _$EmployeeTableNotifier {
  @override
  TableState build() {
    // Load initial data
    _fetchEmployees();
    return const TableState();
  }

  Future<void> _fetchEmployees() async {
    // In a real app, you would fetch data from an API
    state = state.copyWith(
      allEmployees: SampleData.employeeData,
      isLoading: false,
    );
  }

  /// Handles sorting logic
  void handleSort(String columnKey) {
    SortDirection newDirection;
    if (state.sortColumnKey == columnKey) {
      // Cycle through sort directions
      newDirection = switch (state.sortDirection) {
        SortDirection.none => SortDirection.ascending,
        SortDirection.ascending => SortDirection.descending,
        SortDirection.descending => SortDirection.none,
      };
    } else {
      newDirection = SortDirection.ascending;
    }

    state = state.copyWith(
      sortColumnKey: newDirection == SortDirection.none ? null : columnKey,
      sortDirection: newDirection,
    );
  }

  /// Toggles row selection
  void selectRow(String rowId, bool isSelected) {
    final newSelectedIds = Set<String>.from(state.selectedRowIds);
    if (isSelected) {
      newSelectedIds.add(rowId);
    } else {
      newSelectedIds.remove(rowId);
    }
    state = state.copyWith(selectedRowIds: newSelectedIds);
  }

  /// Selects or deselects all rows
  void selectAllRows(bool select) {
    if (select) {
      final allIds = state.allEmployees.map((e) => e['id'].toString()).toSet();
      state = state.copyWith(selectedRowIds: allIds);
    } else {
      state = state.copyWith(selectedRowIds: {});
    }
  }
  
  // --- Other UI-related methods ---
  
  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectable: !state.isSelectable,
      // Clear selections when disabling selection mode
      selectedRowIds: state.isSelectable ? {} : state.selectedRowIds,
    );
  }
}
```

## 4. Create Derived State Providers (`@riverpod`)

Derived state providers are pure functions that compute values based on other providers. Riverpod automatically caches (memoizes) their results, so the computation only runs when the dependencies change. This is perfect for expensive operations like sorting.

**`employee_table_providers.dart`**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'employee_table_notifier.dart';

part 'employee_table_providers.g.dart';

/// Provides the sorted list of employees.
/// This provider only recomputes when the original data or sort conditions change.
@riverpod
List<Map<String, dynamic>> sortedEmployees(SortedEmployeesRef ref) {
  final allEmployees = ref.watch(employeeTableNotifierProvider.select((s) => s.allEmployees));
  final sortColumn = ref.watch(employeeTableNotifierProvider.select((s) => s.sortColumnKey));
  final sortDirection = ref.watch(employeeTableNotifierProvider.select((s) => s.sortDirection));

  if (sortColumn == null || sortDirection == SortDirection.none) {
    return allEmployees;
  }

  final sortedList = List<Map<String, dynamic>>.from(allEmployees);
  sortedList.sort((a, b) {
    final aValue = a[sortColumn];
    final bValue = b[sortColumn];
    
    // Add your comparison logic here...
    final comparison = (aValue ?? '').toString().compareTo((bValue ?? '').toString());
    
    return sortDirection == SortDirection.ascending ? comparison : -comparison;
  });

  return sortedList;
}

/// Provides the names of selected employees.
/// This is another example of derived state.
@riverpod
List<String> selectedEmployeeNames(SelectedEmployeeNamesRef ref) {
  final allEmployees = ref.watch(employeeTableNotifierProvider.select((s) => s.allEmployees));
  final selectedIds = ref.watch(employeeTableNotifierProvider.select((s) => s.selectedRowIds));

  return allEmployees
      .where((e) => selectedIds.contains(e['id'].toString()))
      .map((e) => e['name'].toString())
      .toList();
}
```
*Using `.select` ensures that these providers only rebuild when the specific properties they depend on change, further optimizing performance.*

## 5. Connect to the UI

Now, connect the providers to your UI. Use `ref.watch` to get state and `ref.read` to call methods in the notifier.

**`table_page.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'employee_table_notifier.dart';
import 'employee_table_providers.dart';

class EmployeeTablePage extends ConsumerWidget {
  const EmployeeTablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state and derived providers
    final tableState = ref.watch(employeeTableNotifierProvider);
    final sortedData = ref.watch(sortedEmployeesProvider);
    final notifier = ref.read(employeeTableNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Table Example'),
        actions: [
          IconButton(
            icon: Icon(tableState.isSelectable ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: () => notifier.toggleSelectionMode(),
          ),
        ],
      ),
      body: FlutterTablePlus(
        columns: _buildColumns(), // Define your columns
        data: sortedData,
        
        // Connect state properties
        isSelectable: tableState.isSelectable,
        selectedRows: tableState.selectedRowIds,
        sortColumnKey: tableState.sortColumnKey,
        sortDirection: tableState.sortDirection,
        
        // Connect notifier methods to callbacks
        onSort: (columnKey, _) => notifier.handleSort(columnKey),
        onRowSelectionChanged: (rowId, isSelected) => notifier.selectRow(rowId, isSelected),
        onSelectAll: (select) => notifier.selectAllRows(select),
      ),
    );
  }
  
  Map<String, TablePlusColumn> _buildColumns() {
    // Use TableColumnsBuilder to define your columns...
    return TableColumnsBuilder()
        .addColumn('id', const TablePlusColumn(key: 'id', label: 'ID', order: 0, sortable: true))
        .addColumn('name', const TablePlusColumn(key: 'name', label: 'Name', order: 0, sortable: true))
        .build();
  }
}
```

By structuring your code this way, you achieve a highly efficient and maintainable integration between `flutter_table_plus` and Riverpod.
