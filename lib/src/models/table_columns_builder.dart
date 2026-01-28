import 'table_column.dart';

/// A builder class for creating ordered table columns with automatic order management.
///
/// This builder prevents order conflicts by automatically assigning sequential orders
/// and handling insertions by shifting existing column orders as needed.
///
/// Example usage:
/// ```dart
/// final columns = TableColumnsBuilder<Employee>()
///   ..addColumn('id', TablePlusColumn<Employee>(key: 'id', label: 'ID', order: 0, valueAccessor: (e) => e.id))
///   ..addColumn('name', TablePlusColumn<Employee>(key: 'name', label: 'Name', order: 0, valueAccessor: (e) => e.name));
/// ```
class TableColumnsBuilder<T> {
  final Map<String, TablePlusColumn<T>> _columns = {};
  int _nextOrder = 1;

  /// Adds a column to the end of the table with automatically assigned order.
  ///
  /// The [column]'s order value will be ignored and replaced with the next available order.
  ///
  /// Returns this builder for method chaining.
  TableColumnsBuilder<T> addColumn(String key, TablePlusColumn<T> column) {
    if (_columns.containsKey(key)) {
      throw ArgumentError('Column with key "$key" already exists');
    }

    _columns[key] = column.copyWith(order: _nextOrder++);
    return this;
  }

  /// Inserts a column at the specified order position.
  ///
  /// All existing columns with order >= [targetOrder] will be shifted by +1.
  /// The [column]'s order value will be ignored and replaced with [targetOrder].
  ///
  /// Returns this builder for method chaining.
  TableColumnsBuilder<T> insertColumn(
      String key, TablePlusColumn<T> column, int targetOrder) {
    if (_columns.containsKey(key)) {
      throw ArgumentError('Column with key "$key" already exists');
    }

    if (targetOrder < 1) {
      throw ArgumentError(
          'Order must be >= 1 (order 0 and negative values are reserved)');
    }

    // Shift existing columns that have order >= targetOrder
    _shiftOrdersFrom(targetOrder);

    // Insert the new column at the target order
    _columns[key] = column.copyWith(order: targetOrder);

    // Update _nextOrder if necessary
    _nextOrder = _getMaxOrder() + 1;

    return this;
  }

  /// Removes a column by key.
  ///
  /// Returns this builder for method chaining.
  TableColumnsBuilder<T> removeColumn(String key) {
    if (!_columns.containsKey(key)) {
      throw ArgumentError('Column with key "$key" does not exist');
    }

    final removedOrder = _columns[key]!.order;
    _columns.remove(key);

    // Shift down columns that had order > removedOrder
    _shiftOrdersDown(removedOrder);

    // Update _nextOrder
    _nextOrder = _getMaxOrder() + 1;

    return this;
  }

  /// Reorders an existing column to a new position.
  ///
  /// Returns this builder for method chaining.
  TableColumnsBuilder<T> reorderColumn(String key, int newOrder) {
    if (!_columns.containsKey(key)) {
      throw ArgumentError('Column with key "$key" does not exist');
    }

    if (newOrder < 1) {
      throw ArgumentError(
          'Order must be >= 1 (order 0 and negative values are reserved)');
    }

    final currentColumn = _columns[key]!;
    final currentOrder = currentColumn.order;

    if (currentOrder == newOrder) {
      return this; // No change needed
    }

    // Remove the column temporarily
    _columns.remove(key);

    // Adjust orders based on movement direction
    if (newOrder < currentOrder) {
      // Moving up: shift down columns in range [newOrder, currentOrder)
      for (final entry in _columns.entries) {
        final order = entry.value.order;
        if (order >= newOrder && order < currentOrder) {
          _columns[entry.key] = entry.value.copyWith(order: order + 1);
        }
      }
    } else {
      // Moving down: shift up columns in range (currentOrder, newOrder]
      for (final entry in _columns.entries) {
        final order = entry.value.order;
        if (order > currentOrder && order <= newOrder) {
          _columns[entry.key] = entry.value.copyWith(order: order - 1);
        }
      }
    }

    // Re-insert the column at new position
    _columns[key] = currentColumn.copyWith(order: newOrder);

    return this;
  }

  /// Returns the current number of columns.
  int get length => _columns.length;

  /// Returns true if the builder is empty.
  bool get isEmpty => _columns.isEmpty;

  /// Returns true if the builder is not empty.
  bool get isNotEmpty => _columns.isNotEmpty;

  /// Returns true if a column with the given key exists.
  bool containsKey(String key) => _columns.containsKey(key);

  /// Builds and returns an unmodifiable map of columns.
  ///
  /// ⚠️ After calling build(), this builder should not be used again.
  Map<String, TablePlusColumn<T>> build() {
    _validateOrders();
    return Map.unmodifiable(_columns);
  }

  /// Shifts all columns with order >= fromOrder by +1.
  void _shiftOrdersFrom(int fromOrder) {
    for (final entry in _columns.entries) {
      if (entry.value.order >= fromOrder) {
        _columns[entry.key] = entry.value.copyWith(
          order: entry.value.order + 1,
        );
      }
    }
  }

  /// Shifts all columns with order > fromOrder by -1.
  void _shiftOrdersDown(int fromOrder) {
    for (final entry in _columns.entries) {
      if (entry.value.order > fromOrder) {
        _columns[entry.key] = entry.value.copyWith(
          order: entry.value.order - 1,
        );
      }
    }
  }

  /// Returns the maximum order value, or 0 if no columns exist.
  int _getMaxOrder() {
    if (_columns.isEmpty) return 0;
    return _columns.values.map((c) => c.order).reduce((a, b) => a > b ? a : b);
  }

  /// Validates that all orders are unique and sequential starting from 1.
  void _validateOrders() {
    if (_columns.isEmpty) return;

    final orders = _columns.values.map((c) => c.order).toList();
    orders.sort();

    // Check for duplicates
    final uniqueOrders = orders.toSet();
    if (orders.length != uniqueOrders.length) {
      throw StateError('Internal error: Duplicate orders found in builder');
    }

    // Check for proper sequence (should start from 1 and be consecutive)
    for (int i = 0; i < orders.length; i++) {
      if (orders[i] != i + 1) {
        throw StateError(
            'Internal error: Orders are not consecutive starting from 1');
      }
    }
  }
}
