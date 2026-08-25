import 'package:flutter/material.dart';

import '../models/feature_switches.dart';
import '../models/playground_settings.dart';
import '../models/settings_spec.dart';
import 'feature_search.dart';

/// The twenty features, in a column of their own.
///
/// Sixty-eight controls used to stand here. Each row now answers two questions —
/// is this on, and how much is inside it — and defers the rest to the pane that
/// shows the feature you pick.
///
/// Four features own no switch. Rows, Zoom, Rows and text and Row ink are
/// headings over settings that are always live, and a dot beside them would
/// offer to turn off something that cannot be turned off.
///
/// A search narrows this list rather than a column of controls, because the
/// setting someone is hunting almost always belongs to a feature they have not
/// opened. Under each surviving name it says which setting matched, so
/// `Handle Indent` can be found to live under Column resizing without opening
/// anything.
class FeatureListPane extends StatefulWidget {
  const FeatureListPane({
    super.key,
    required this.settings,
    required this.selectedFeatureId,
    required this.onSettingsChanged,
    required this.onFeatureSelected,
  });

  final PlaygroundSettings settings;
  final String? selectedFeatureId;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final ValueChanged<String> onFeatureSelected;

  @override
  State<FeatureListPane> createState() => _FeatureListPaneState();
}

class _FeatureListPaneState extends State<FeatureListPane> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text;
    final matches = searchFeatures(query, widget.settings);
    final searching = query.trim().isNotEmpty;

    return Container(
      width: 220,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: searching
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => setState(_search.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                // While a search runs the groups say nothing: the list is no
                // longer the description's shape, it is the query's.
                if (searching)
                  for (final match in matches) _entry(match)
                else
                  for (final group in settingsSpec) ...[
                    _groupHeading(group.title),
                    for (final feature in group.features)
                      _entry(matches
                          .firstWhere((m) => m.feature.id == feature.id)),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupHeading(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _entry(FeatureMatch match) {
    final feature = match.feature;
    final switchId = feature.switchId;
    final on =
        switchId != null && featureSwitches[switchId]!.read(widget.settings);

    return KeyedSubtree(
      key: ValueKey('feature-${feature.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            dense: true,
            selected: feature.id == widget.selectedFeatureId,
            contentPadding: const EdgeInsets.only(left: 4, right: 12),
            // The name selects. Selecting is not enabling — a reader must be
            // able to look at a feature that is off, and see what it would
            // offer.
            onTap: () => widget.onFeatureSelected(feature.id),
            leading: switchId == null
                ? const SizedBox(width: 40)
                : _Dot(
                    key: ValueKey('feature-dot-${feature.id}'),
                    on: on,
                    onTap: () => widget.onSettingsChanged(
                      featureSwitches[switchId]!.write(widget.settings, !on),
                    ),
                  ),
            title: Text(
              feature.title,
              // The list is narrow and the widget-test font draws every glyph
              // as a square of the font size, so a name that fits on screen
              // overflows there. Let it ellipsize.
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            trailing: feature.options.isEmpty
                ? null
                : Text(
                    '${feature.options.length}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          if (match.matchedLabels.isNotEmpty) _matched(match),
        ],
      ),
    );
  }

  /// The settings that matched, under the feature holding them.
  ///
  /// A match inside a feature that is off is still a match. Answering with
  /// silence would leave the reader unable to tell whether the setting does not
  /// exist or merely cannot be used, so it says which switch to throw.
  Widget _matched(FeatureMatch match) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final label in match.matchedLabels)
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
            ),
          if (!match.isOn)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Turn on ${match.feature.title} to use it',
                style: TextStyle(fontSize: 10, color: Colors.orange.shade800),
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({super.key, required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Icon(
          on ? Icons.circle : Icons.circle_outlined,
          size: 14,
          color: on
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
