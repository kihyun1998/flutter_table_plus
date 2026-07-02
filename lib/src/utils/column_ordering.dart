import '../models/table_column.dart';
import '../models/theme/checkbox_theme.dart';

/// The synthetic selection column injected at the front when selection is on.
const String _selectionColumnKey = '__selection__';

/// The columns to render, in display order.
///
/// Pure extraction of the table's column-ordering rule (previously in the widget
/// State):
/// 1. sort [columns] by [TablePlusColumn.order],
/// 2. drop columns where `visible` is false,
/// 3. when [isSelectable] and [TablePlusCheckboxTheme.showCheckboxColumn],
///    prepend a synthetic fixed-width selection column.
List<TablePlusColumn<T>> orderVisibleColumns<T>({
  required Map<String, TablePlusColumn<T>> columns,
  required bool isSelectable,
  required TablePlusCheckboxTheme checkboxTheme,
}) {
  final ordered = columns.entries.toList()
    ..sort((a, b) => a.value.order.compareTo(b.value.order));

  final visible = ordered
      .where((entry) => entry.value.visible)
      .map((entry) => entry.value)
      .toList();

  if (isSelectable && checkboxTheme.showCheckboxColumn) {
    final width = checkboxTheme.checkboxColumnWidth;
    visible.insert(
      0,
      TablePlusColumn<T>(
        key: _selectionColumnKey,
        label: '',
        order: -1,
        valueAccessor: (_) => null,
        width: width,
        minWidth: width,
        maxWidth: width,
        sortable: false,
      ),
    );
  }

  return visible;
}
