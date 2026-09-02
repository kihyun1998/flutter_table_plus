import 'package:flutter/material.dart';

import 'shell/shell_page.dart';
import 'theme/example_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeController = ExampleThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The scope sits above MaterialApp so the controller outlives any route,
    // and the builder sits inside so a change of mode rebuilds the app rather
    // than only the page that asked for it.
    return ExampleThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) => MaterialApp(
          title: 'FlutterTablePlus Examples',
          debugShowCheckedModeBanner: false,
          theme: exampleTheme(Brightness.light),
          darkTheme: exampleTheme(Brightness.dark),
          themeMode: _themeController.mode,
          home: const ShellPage(),
        ),
      ),
    );
  }
}
