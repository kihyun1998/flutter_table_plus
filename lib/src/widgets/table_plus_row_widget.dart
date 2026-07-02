import 'package:flutter/material.dart';

import '../models/hover_button_position.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/hover_button_theme.dart' show TablePlusHoverButtonTheme;
import 'row_hover_button.dart';
import 'row_interaction_shell.dart';

/// Abstract base class for table row widgets.
///
/// Allows different row implementations (normal rows, merged rows) to share a
/// consistent interface for the `ListView` builder — and, via
/// [TablePlusRowStateBase], a single shared build skeleton. Subclasses only
/// override the parts that genuinely differ (the cell content and the hover
/// data); everything about interaction wiring is expressed once here in terms
/// of [selectionId].
abstract class TablePlusRowWidget<T> extends StatefulWidget {
  const TablePlusRowWidget({super.key});

  /// The number of rows this widget effectively represents in the UI.
  /// - Normal row: 1
  /// - Merged row: 1 (visually one row, though it spans multiple data rows)
  int get effectiveRowCount;

  /// The original data indices that this row widget represents.
  /// - Normal row: [rowIndex]
  /// - Merged row: [index1, index2, index3, ...] for all merged rows
  List<int> get originalDataIndices;

  /// The height this row should occupy.
  /// Can be calculated or fixed depending on the implementation.
  double? get calculatedHeight;

  /// Whether this row represents the last row in the table.
  /// Used for styling purposes (borders, etc.).
  bool get isLastRow;

  /// The background color for this row.
  /// Can vary based on selection state, alternating colors, etc.
  Color get backgroundColor;

  /// Whether the table is in cell-editing mode (row selection is suppressed).
  bool get isEditable;

  /// Whether row selection is enabled.
  bool get isSelectable;

  /// The identifier this row toggles when tapped for selection: the row id for
  /// a normal row, the group id for a merged row. `null` when the row has no
  /// stable id (selection is then a no-op).
  String? get selectionId;

  /// Invoked with [selectionId] to toggle this row's selection.
  void Function(String id) get onRowSelectionChanged;

  /// The body theme in effect for this row.
  TablePlusBodyTheme get theme;

  /// Whether this row is currently selected.
  bool get isSelected;

  /// Whether this row is dimmed (affects effective interaction colors).
  bool get isDim;

  /// Builder for this row's custom hover button, or null when none.
  Widget? Function(String id, T data)? get hoverButtonBuilder;

  /// Where the hover button is positioned.
  HoverButtonPosition get hoverButtonPosition;

  /// Theme for the hover button, or null for defaults.
  TablePlusHoverButtonTheme? get hoverButtonTheme;

  /// Invoked (with [selectionId]) when the row is double-tapped.
  void Function(String id)? get onRowDoubleTap;

  /// Invoked (with [selectionId]) when the row is right-clicked.
  void Function(String id, TapDownDetails details, RenderBox renderBox,
      bool isSelected)? get onRowSecondaryTapDown;

  /// Shared row-tap selection gating for every row type. A tap selects only
  /// when selection is enabled, the table is not editing, and the row has an
  /// id — otherwise it is a no-op.
  void handleSelectionTap() {
    if (isEditable || !isSelectable) return;
    final id = selectionId;
    if (id == null) return;
    onRowSelectionChanged(id);
  }

  /// Whether the row wraps its content in a selection ink well. True only when
  /// selection is enabled, the table is not editing, and the row has an id.
  /// This same predicate drives the transparent-selection decoration.
  bool get enableSelectionInk =>
      isSelectable && !isEditable && selectionId != null;
}

/// Shared base [State] holding the row build skeleton (the template method).
///
/// Owns the hover flag and wires the [RowInteractionShell] once — computing the
/// hover overlay, tap/double-tap/secondary-tap routing (all keyed off
/// [TablePlusRowWidget.selectionId]) and the effective interaction colors.
/// Subclasses fill exactly two hooks: [buildRowContent] (the height-sized
/// container of cells) and [hoverData] (the value fed to the hover builder).
abstract class TablePlusRowStateBase<W extends TablePlusRowWidget<T>, T>
    extends State<W> {
  bool _isHovered = false;

  /// Builds the row's inner content — the height-sized [Container] of cells.
  @protected
  Widget buildRowContent(BuildContext context);

  /// The data object passed to [TablePlusRowWidget.hoverButtonBuilder], or null.
  @protected
  T? get hoverData;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final rowContent = buildRowContent(context);

    final hoverButtons = buildRowHoverButton<T>(
      isHovered: _isHovered,
      builder: widget.hoverButtonBuilder,
      id: widget.selectionId,
      data: hoverData,
      position: widget.hoverButtonPosition,
      horizontalOffset: widget.hoverButtonTheme?.horizontalOffset ?? 8.0,
    );

    final id = widget.selectionId;

    // Tap-to-select (and the selection ink visual) only in non-edit mode; row
    // gestures (double-tap / secondary-tap) are available whenever a handler is
    // provided, even while editing — so the layer must wrap the row for either.
    final tapSelect = widget.enableSelectionInk;
    final wantsRowGesture = id != null &&
        (widget.onRowDoubleTap != null || widget.onRowSecondaryTapDown != null);

    return RowInteractionShell(
      rowContent: rowContent,
      hoverButtons: hoverButtons,
      onHoverChanged: (v) => setState(() => _isHovered = v),
      enableInteractionLayer: tapSelect || wantsRowGesture,
      inkKey: ValueKey(id),
      onTap: tapSelect ? widget.handleSelectionTap : null,
      onDoubleTap: () => widget.onRowDoubleTap?.call(id!),
      onSecondaryTapDown: (details, renderBox) => widget.onRowSecondaryTapDown
          ?.call(id!, details, renderBox, widget.isSelected),
      doubleClickTime: theme.doubleClickTime,
      backgroundColor: widget.backgroundColor,
      // Selection ink colors only when tap-selecting; edit-mode row gestures
      // shouldn't paint a selection splash.
      hoverColor: tapSelect
          ? theme.getEffectiveHoverColor(widget.isSelected, widget.isDim)
          : null,
      splashColor: tapSelect
          ? theme.getEffectiveSplashColor(widget.isSelected, widget.isDim)
          : null,
      highlightColor: tapSelect
          ? theme.getEffectiveHighlightColor(widget.isSelected, widget.isDim)
          : null,
    );
  }
}
