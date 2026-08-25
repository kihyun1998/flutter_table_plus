/// Turning a [Recipe] into a shell destination: a stage, and a knob pane.
library;

import 'package:flutter/material.dart';

import '../../pages/playground/models/playground_settings.dart';
import '../../pages/playground/widgets/feature_detail_pane.dart';
import '../recipe_catalog.dart';
import '../shell_destination.dart';

/// The state a recipe's stage and its knob pane both need.
///
/// **This is the adapter, and it is the only place the two vocabularies meet.**
/// The knob pane speaks [PlaygroundSettings], because that is what the existing
/// controls are written against and reusing them is worth far more than a
/// second set of sliders. The recipe speaks plain parameters, because a file
/// that takes a fifty-eight-field settings object is not something anyone can
/// paste. Neither side is bent to fit the other; the translation lives here, in
/// new code, and `pages/playground/` is untouched by it.
class RecipeDemo extends ChangeNotifier {
  RecipeDemo(this.recipe);

  final Recipe recipe;

  PlaygroundSettings _settings = const PlaygroundSettings();
  PlaygroundSettings get settings => _settings;
  set settings(PlaygroundSettings value) {
    if (identical(_settings, value)) return;
    _settings = value;
    notifyListeners();
  }
}

/// The stage half — the recipe itself, and nothing around it.
class RecipeStage extends StatelessWidget {
  const RecipeStage({super.key, required this.demo});

  final RecipeDemo demo;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demo,
      builder: (context, _) => demo.recipe.build(demo.settings),
    );
  }
}

/// The knob half — the feature's own detail pane, unchanged.
///
/// [FeatureDetailPane] already draws exactly one feature's switch and options
/// and nothing else, already renders its cited interactions, and is already
/// held to that by `test/feature_detail_test.dart`. Writing a second pane here
/// would mean maintaining two answers to the same question.
///
/// It takes `onGenerateData` because the `data` feature draws a generate
/// button. No recipe is for `data` — `test/recipe_seam_test.dart` insists on
/// that — so the callback below is unreachable rather than merely unused, and
/// the reuse is honest.
class RecipeKnobs extends StatelessWidget {
  const RecipeKnobs({super.key, required this.demo});

  final RecipeDemo demo;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demo,
      builder: (context, _) => FeatureDetailPane(
        settings: demo.settings,
        feature: demo.recipe.feature,
        onSettingsChanged: (value) => demo.settings = value,
        onGenerateData: () {},
      ),
    );
  }
}

/// Every recipe in the catalogue, as menu destinations.
///
/// The caller owns the [RecipeDemo]s so they outlive a rebuild — a notifier
/// created inside `build` would reset the selection on every keystroke.
List<StageDestination> recipeDestinations(Map<String, RecipeDemo> demos) => [
      for (final recipe in recipeCatalog)
        StageDestination(
          id: 'recipe/${recipe.featureId}',
          label: recipe.feature.title,
          category: ShellCategory.recipes,
          stage: (context) => RecipeStage(demo: demos[recipe.featureId]!),
          knobs: (context) => RecipeKnobs(demo: demos[recipe.featureId]!),
        ),
    ];
