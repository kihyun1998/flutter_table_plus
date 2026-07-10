import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// One row of the anchor demo. The value is long on purpose: a text tooltip's
/// hover target is the `Text` itself, so a short value leaves the child's
/// centre and the cursor a few pixels apart and both anchors look alike.
class TooltipAnchorRow {
  const TooltipAnchorRow({required this.id, required this.value});

  final String id;
  final String value;
}

/// Where header tooltips anchor, as this demo offers it.
///
/// [followCells] passes `null` through, leaving `TablePlusTheme
/// .headerTooltipTheme` unset so the table falls back to `tooltipTheme`. It is
/// the default because a demo that never walks the fallback would not show it
/// working. The other two hand the header a theme of its own, which is the only
/// way to anchor a header differently from the cells beneath it.
enum HeaderAnchorChoice { followCells, child, pointer }

/// The theme the demo builds from its two anchor choices.
///
/// Free of `BuildContext` and of widget state, so what the controls select can
/// be asserted directly against what the table receives.
TablePlusTheme buildAnchorDemoTheme({
  TooltipAnchor cellAnchor = TooltipAnchor.child,
  HeaderAnchorChoice headerAnchor = HeaderAnchorChoice.followCells,
}) {
  final cellTooltip = TablePlusTooltipTheme(anchor: cellAnchor);

  return TablePlusTheme(
    tooltipTheme: cellTooltip,
    headerTooltipTheme: switch (headerAnchor) {
      HeaderAnchorChoice.followCells => null,
      HeaderAnchorChoice.child =>
        cellTooltip.copyWith(anchor: TooltipAnchor.child),
      HeaderAnchorChoice.pointer =>
        cellTooltip.copyWith(anchor: TooltipAnchor.pointer),
    },
    rowTooltipTheme: const TablePlusTooltipTheme(
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0,
    ),
  );
}

const _rows = [
  TooltipAnchorRow(
    id: '1',
    value: 'a value long enough that the column has to cut it short',
  ),
  TooltipAnchorRow(
    id: '2',
    value: 'another value the column cannot possibly show in full',
  ),
  TooltipAnchorRow(
    id: '3',
    value: 'a third that also runs past the edge of its cell',
  ),
];

class TooltipAnchorPage extends StatefulWidget {
  const TooltipAnchorPage({super.key});

  @override
  State<TooltipAnchorPage> createState() => _TooltipAnchorPageState();
}

class _TooltipAnchorPageState extends State<TooltipAnchorPage> {
  TooltipAnchor _cellAnchor = TooltipAnchor.child;
  HeaderAnchorChoice _headerAnchor = HeaderAnchorChoice.followCells;

  Map<String, TablePlusColumn<TooltipAnchorRow>> get _columns =>
      TableColumnsBuilder<TooltipAnchorRow>()
          .addColumn(
            'value',
            TablePlusColumn<TooltipAnchorRow>(
              key: 'value',
              label: 'A heading long enough to be cut short as well',
              order: 0,
              width: 260,
              maxWidth: 260,
              valueAccessor: (row) => row.value,
              // Both tooltips only appear once their text is truncated, which
              // is also the only state in which the two anchors are far enough
              // apart to tell apart.
              tooltipBehavior: TooltipBehavior.onlyTextOverflow,
              headerTooltipBehavior: TooltipBehavior.onlyTextOverflow,
            ),
          )
          .addColumn(
            'id',
            TablePlusColumn<TooltipAnchorRow>(
              key: 'id',
              label: '#',
              order: 1,
              width: 80,
              valueAccessor: (row) => row.id,
            ),
          )
          .build();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tooltip anchors')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _AnchorChoice<TooltipAnchor>(
                      label: 'Cell anchor',
                      value: _cellAnchor,
                      values: TooltipAnchor.values,
                      nameOf: (a) => a.name,
                      onChanged: (a) => setState(() => _cellAnchor = a),
                    ),
                    _AnchorChoice<HeaderAnchorChoice>(
                      label: 'Header anchor',
                      value: _headerAnchor,
                      values: HeaderAnchorChoice.values,
                      nameOf: (a) => switch (a) {
                        HeaderAnchorChoice.followCells => 'follow cells',
                        HeaderAnchorChoice.child => 'child',
                        HeaderAnchorChoice.pointer => 'pointer',
                      },
                      onChanged: (a) => setState(() => _headerAnchor = a),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _Note(
                  'Hover the truncated value, then its heading. `child` puts '
                  'the tooltip at the middle of what you hovered; `pointer` '
                  'puts it beside the cursor.',
                ),
                const _Note(
                  'Leave the header on `follow cells` and it takes the cell '
                  'anchor — that is the theme falling back, not a copy.',
                ),
                const _Note(
                  'The row card ignores both. A row is as wide as the table\'s '
                  'content, so anchoring to it would aim at a point that can '
                  'be off screen; it always anchors at the pointer.',
                ),
                const _Note(
                  'Alignment changes meaning with the anchor. Against a point '
                  'there are no target edges to line up with, so it picks '
                  'which of the tooltip\'s own edges lands on the cursor.',
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterTablePlus<TooltipAnchorRow>(
              columns: _columns,
              data: _rows,
              rowId: (row) => row.id,
              theme: buildAnchorDemoTheme(
                cellAnchor: _cellAnchor,
                headerAnchor: _headerAnchor,
              ),
              rowTooltipBuilder: (context, row) => Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Row ${row.id}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled set of radio choices, laid out so a long label wraps instead of
/// overflowing — the test font makes every glyph a square of the font size.
class _AnchorChoice<T> extends StatelessWidget {
  const _AnchorChoice({
    required this.label,
    required this.value,
    required this.values,
    required this.nameOf,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) nameOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        Wrap(
          spacing: 8,
          children: [
            for (final v in values)
              ChoiceChip(
                label: Text(nameOf(v)),
                selected: v == value,
                onSelected: (picked) => picked ? onChanged(v) : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
