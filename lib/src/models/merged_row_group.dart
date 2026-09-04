import 'package:flutter/material.dart';

/// Configuration for how a specific cell should be merged within a group.
class MergeCellConfig {
  /// Creates a [MergeCellConfig] with the specified settings.
  const MergeCellConfig({
    required this.shouldMerge,
    this.spanningRowIndex = 0,
    this.mergedContent,
    this.isEditable = false,
  });

  /// Whether this column should be merged for this group.
  /// If false, each row in the group will show its individual cell content.
  final bool shouldMerge;

  /// Which member of the group the merged cell reads its content from.
  ///
  /// **A position in [MergedRowGroup.rowKeys] — the list you wrote — and not a
  /// position among the rows as `data` happens to order them.** Written in
  /// `data` order the two are the same thing, which is why the distinction only
  /// shows up when they are not: with `data: ['a', 'b']` and
  /// `rowKeys: ['b', 'a']`, `spanningRowIndex: 1` is `'a'`.
  ///
  /// Settled in #173, and the reason is that `data` order is yours to change.
  /// Resolving among the rendered rows instead would move a merged cell's
  /// content every time you sorted the list, from a configuration you had not
  /// touched. It is also not what the index is for: a merged cell is drawn once
  /// across the whole group, so *where* is already answered and the only
  /// question left is *whose value* — which your own list is the direct way to
  /// name.
  ///
  /// This is deliberately **not** the rule #135 and #151 applied to a group's
  /// anchor, tail and hover target. Those answer how far the group reaches, so
  /// they must come from what `data` holds; this answers what it shows.
  ///
  /// Out of range clamps to the last member rather than throwing, and an index
  /// naming a row `data` does not hold falls forward to the first member that
  /// is present — both with one debug warning. See
  /// [MergedRowGroup.resolveSpanningRowKey].
  ///
  /// Other rows in the group have empty cells for this column. Defaults to 0.
  final int spanningRowIndex;

  /// Custom widget content to display in the merged cell.
  /// If null, the content from the row at [spanningRowIndex] will be used.
  final Widget? mergedContent;

  /// Whether this merged cell should be editable.
  /// Only applies to merged cells without custom [mergedContent].
  /// If [mergedContent] is provided, this field is ignored.
  final bool isEditable;
}

/// Represents a group of rows that should be merged together for specific columns.
class MergedRowGroup<T> {
  /// Creates a [MergedRowGroup] with the specified configuration.
  const MergedRowGroup({
    required this.groupId,
    required this.rowKeys,
    required this.mergeConfig,
    this.isExpanded = false,
    this.summaryBuilder,
  });

  /// Unique identifier for this merge group.
  /// Used for selection and editing operations.
  final String groupId;

  /// List of row keys that belong to this group.
  /// These keys refer to the unique identifiers of rows in the data list.
  final List<String> rowKeys;

  /// Configuration for how each column should be merged within this group.
  /// Key: column key, Value: merge configuration for that column.
  final Map<String, MergeCellConfig> mergeConfig;

  /// Whether this group shows its summary row.
  ///
  /// **Caller state, and so is the control that changes it.** The package
  /// draws no expand/collapse affordance anywhere — put one in the merged
  /// cell's `mergedContent` and wire it to your own `setState`, the way
  /// `example/lib/recipes/merged_rows_recipe.dart` does. A group is an
  /// immutable value you rebuild, so the state has to live where the data
  /// does. **Rebuild the enclosing list too** — assigning a new group back as
  /// `groups[0] = newGroup` keeps the list identical and is not seen; see
  /// `FlutterTablePlus.mergedGroups`.
  ///
  /// Note that "expanded" *adds* the summary row; it does not hide the
  /// member rows, which is the opposite of what the word suggests and the
  /// one place this API's vocabulary will mislead you.
  ///
  /// Until 2.17.0 this was gated behind a second flag, `isExpandable`, and
  /// a doc-comment promising an icon the package has never drawn. Both are
  /// gone: the flag was an extra `&&` in front of this one, and the icon
  /// was never going to arrive without taking the merged cell's layout
  /// away from the caller.
  final bool isExpanded;

  /// Builder function to create summary content for a specific column.
  /// Returns a Widget to display in the summary row cell for the given column key.
  /// If null or returns null for a column, the summary cell will be empty.
  final Widget? Function(String columnKey)? summaryBuilder;

  /// Returns the number of rows in this group.
  int get rowCount => rowKeys.length;

  /// Returns true if the specified column should be merged for this group.
  bool shouldMergeColumn(String columnKey) {
    return mergeConfig[columnKey]?.shouldMerge ?? false;
  }

  /// Returns the row index where the merged content should be displayed for the specified column.
  int getSpanningRowIndex(String columnKey) {
    return mergeConfig[columnKey]?.spanningRowIndex ?? 0;
  }

  /// The key at [MergeCellConfig.spanningRowIndex] in [rowKeys], clamped.
  ///
  /// An index past the end returns the **last** member rather than throwing.
  /// It used to throw a `RangeError`, and it was called from inside
  /// `_buildMergedCell` — so a caller who wrote `spanningRowIndex: 5` against
  /// three keys got an exception out of a widget build, which is a red screen
  /// in release rather than a caught error (#173).
  ///
  /// **This one does not consult `data`**, so a key it returns may name a row
  /// that is not there. The widget path calls [resolveSpanningRowKey] instead,
  /// which is the whole answer; this stays for callers who want the raw
  /// positional read, and its signature is unchanged.
  ///
  /// An **empty** [rowKeys] still throws, because there is no key to return and
  /// no sensible one to invent. Nothing in this package reaches it in that
  /// state: [resolveSpanningRowKey] returns null instead.
  String getSpanningRowKey(String columnKey) =>
      rowKeys[_clampedSpanIndex(columnKey)];

  /// [MergeCellConfig.spanningRowIndex] brought inside [rowKeys]'s bounds.
  ///
  /// Shared by [getSpanningRowKey] and [resolveSpanningRowKey] so the two
  /// cannot disagree — resolving the key and then asking `rowKeys.indexOf` for
  /// its position would answer differently the moment a group lists the same
  /// key twice, and a group is a caller's list with nothing validating it.
  ///
  /// Returns the unclamped value for an empty [rowKeys], leaving the index
  /// operation to throw as it always has.
  int _clampedSpanIndex(String columnKey) {
    final requested = getSpanningRowIndex(columnKey);
    if (rowKeys.isEmpty) return requested;
    final index = requested.clamp(0, rowKeys.length - 1);
    assert(requested == index ||
        _warnOnce(
            '$groupId|$columnKey|range',
            'spanningRowIndex $requested is past the end of rowKeys '
                '(${rowKeys.length}) for group "$groupId" column "$columnKey". '
                'Clamped to $index.'));
    return index;
  }

  /// The key the merged cell for [columnKey] actually reads its content from.
  ///
  /// Two steps, and the order is the contract:
  ///
  /// 1. [MergeCellConfig.spanningRowIndex] is a position in [rowKeys], clamped
  ///    to the last member if it is past the end.
  /// 2. If the key at that position names a row [allData] does not hold, the
  ///    walk continues **forward through [rowKeys], wrapping once**, to the
  ///    first member that is present.
  ///
  /// Returns null only when the group has no present member at all, which is
  /// the one case where an empty merged cell is the right answer rather than a
  /// value that went missing.
  ///
  /// Step 2 exists because the alternative is silent. Before #173, `rowKeys:
  /// ['a', 'ghost']` with `spanningRowIndex: 1` resolved to `'ghost'`, found
  /// nothing, and rendered an empty cell — so the value of `'a'` simply left
  /// the screen with no exception and no banner. Note that this is a *fallback*
  /// and not a re-reading of the index: the index is still positional, and this
  /// only runs when the position it names has nothing behind it.
  String? resolveSpanningRowKey(
    String columnKey,
    List<T> allData,
    String Function(T) rowId,
  ) {
    if (rowKeys.isEmpty) return null;
    final startIndex = _clampedSpanIndex(columnKey);
    final start = rowKeys[startIndex];

    for (var offset = 0; offset < rowKeys.length; offset++) {
      final key = rowKeys[(startIndex + offset) % rowKeys.length];
      if (getRowData(allData, key, rowId) == null) continue;
      assert(offset == 0 ||
          _warnOnce(
              '$groupId|$columnKey|absent',
              'spanningRowIndex names "$start" for group "$groupId" column '
                  '"$columnKey", which data does not hold. Using "$key".'));
      return key;
    }

    assert(_warnOnce(
        '$groupId|$columnKey|none',
        'group "$groupId" has no member that data holds, so its merged cell '
            'for column "$columnKey" is empty.'));
    return null;
  }

  /// Returns the row data for a specific row key from the provided data list.
  T? getRowData(List<T> allData, String rowKey, String Function(T) rowId) {
    try {
      return allData.firstWhere((row) => rowId(row) == rowKey);
    } catch (e) {
      return null;
    }
  }

  /// Returns all row data for this group from the provided data list.
  List<T> getAllRowData(List<T> allData, String Function(T) rowId) {
    return rowKeys
        .map((rowKey) => getRowData(allData, rowKey, rowId))
        .where((data) => data != null)
        .cast<T>()
        .toList();
  }

  /// Returns custom merged content for the specified column, if any.
  Widget? getMergedContent(String columnKey) {
    return mergeConfig[columnKey]?.mergedContent;
  }

  /// Returns true if the merged cell for the specified column is editable.
  /// Only merged cells without custom content can be editable.
  bool isMergedCellEditable(String columnKey) {
    final config = mergeConfig[columnKey];
    if (config == null || !config.shouldMerge || config.mergedContent != null) {
      return false;
    }
    return config.isEditable;
  }

  /// Returns the effective row count including summary row if expanded.
  int get effectiveRowCount => rowCount + (isExpanded ? 1 : 0);
}

/// The (group, column, kind) triples already warned about.
///
/// Written only from inside an `assert`, so a release build never touches it —
/// and read the same way, which is why it is a bare top-level rather than
/// something guarded by `kDebugMode` at each use.
///
/// Warning **once** rather than per build is the point: these fire from inside
/// `build`, so an unguarded `debugPrint` would produce one line per frame and
/// be indistinguishable from noise. Same shape as the inline-callback
/// diagnostic added in #161, which prints once per table for the same reason.
final Set<String> _warnedSpans = <String>{};

bool _warnOnce(String key, String message) {
  if (_warnedSpans.add(key)) {
    debugPrint('⚠️ FlutterTablePlus: $message');
  }
  return true;
}
