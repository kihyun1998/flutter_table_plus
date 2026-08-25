import 'package:flutter/material.dart';

import '../theme/theme_mode_button.dart';
import 'playground/playground_page.dart';
import 'viewport_lab/viewport_lab_page.dart';
import 'tooltip_anchor/tooltip_anchor_page.dart';

/// Lists the demos this example ships, so a reader after one feature does not
/// have to find it inside a page that shows them all.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterTablePlus Examples'),
        actions: const [ThemeModeButton()],
      ),
      body: ListView(
        children: [
          _DemoTile(
            icon: Icons.tune,
            title: 'Playground',
            summary: 'Every feature at once, with a knob for each',
            open: () => const PlaygroundPage(),
          ),
          _DemoTile(
            icon: Icons.aspect_ratio,
            title: 'Viewport lab',
            summary: 'The same table at desktop, tablet and phone widths',
            open: () => const ViewportLabPage(),
          ),
          _DemoTile(
            icon: Icons.my_location,
            title: 'Tooltip anchors',
            summary: 'Where a tooltip sits: beside the cell, or beside the '
                'cursor',
            open: () => const TooltipAnchorPage(),
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({
    required this.icon,
    required this.title,
    required this.summary,
    required this.open,
  });

  final IconData icon;
  final String title;
  final String summary;
  final Widget Function() open;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      // The test font measures every glyph as a square of the font size, so a
      // summary is far wider under test than on screen. Let it ellipsize
      // rather than overflow.
      subtitle: Text(summary, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => open()),
      ),
    );
  }
}
