/// Theme configuration for hover buttons in table rows.
class TablePlusHoverButtonTheme {
  /// Creates a [TablePlusHoverButtonTheme] with the specified styling properties.
  const TablePlusHoverButtonTheme({
    this.horizontalOffset = 8.0,
  });

  /// The horizontal offset from the row edge for left/right positioned buttons.
  /// This controls how far the buttons are positioned from the left or right edge of the row.
  final double horizontalOffset;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHoverButtonTheme copyWith({
    double? horizontalOffset,
  }) {
    return TablePlusHoverButtonTheme(
      horizontalOffset: horizontalOffset ?? this.horizontalOffset,
    );
  }

  /// Default hover button theme.
  static const TablePlusHoverButtonTheme defaultTheme =
      TablePlusHoverButtonTheme();
}
