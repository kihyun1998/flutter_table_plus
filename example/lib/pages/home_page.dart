import 'package:flutter/material.dart';

import 'playground/playground_page.dart';

/// Lists the demos this example ships, so a reader after one feature does not
/// have to find it inside a page that shows them all.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlutterTablePlus Examples')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Playground'),
            // The test font measures every glyph as a square of the font size,
            // so this line is far wider under test than on screen. Let it
            // ellipsize rather than overflow.
            subtitle: const Text(
              'Every feature at once, with a knob for each',
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PlaygroundPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
