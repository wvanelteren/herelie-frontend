import 'package:equatable/equatable.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/recipe.dart';

class RecipeDetailState extends Equatable {
  final Recipe recipe;
  final int servings;
  final List<Ingredient> scaledIngredients;

  const RecipeDetailState({
    required this.recipe,
    required this.servings,
    required this.scaledIngredients,
  });

  double get multiplier {
    final baseServings = recipe.servings;
    if (baseServings <= 0) return 1;
    return servings / baseServings;
  }

  bool get canDecrease => servings > 1;

  RecipeDetailState copyWith({
    int? servings,
    List<Ingredient>? scaledIngredients,
  }) => RecipeDetailState(
    recipe: recipe,
    servings: servings ?? this.servings,
    scaledIngredients: scaledIngredients ?? this.scaledIngredients,
  );

  @override
  List<Object?> get props => [recipe, servings, scaledIngredients];
}
