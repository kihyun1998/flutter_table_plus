import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import 'app/chrome_font.dart';
import 'app/destinations.dart';

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
          theme: exampleTheme(Brightness.light, chromeFont: exampleChromeFont),
          darkTheme: exampleTheme(Brightness.dark, chromeFont: exampleChromeFont),
          themeMode: _themeController.mode,
          // Deliberately a second literal rather than one constant shared with
          // `MaterialApp.title` above. They are different surfaces — the OS
          // task switcher and the bar on screen — that agree today and are
          // allowed to diverge; one const would assert they must always match,
          // which nothing here has established.
          home: ShellPage(
            title: 'FlutterTablePlus Examples',
            createDestinations: TablePlusDestinations.new,
          ),
        ),
      ),
    );
  }
}
