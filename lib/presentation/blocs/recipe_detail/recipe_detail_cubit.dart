import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/recipe.dart';
import 'recipe_detail_state.dart';

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  RecipeDetailCubit(Recipe recipe)
    : super(
        RecipeDetailState(
          recipe: recipe,
          servings: recipe.servings > 0 ? recipe.servings : 1,
          scaledIngredients: _scaleIngredients(
            recipe,
            recipe.servings > 0 ? recipe.servings : 1,
          ),
        ),
      );

  void increaseServings() {
    final nextServings = state.servings + 1;
    _updateServings(nextServings);
  }

  void decreaseServings() {
    if (!state.canDecrease) return;
    final nextServings = state.servings - 1;
    _updateServings(nextServings);
  }

  void _updateServings(int servings) {
    if (servings < 1) return;
    final scaled = _scaleIngredients(state.recipe, servings);
    emit(state.copyWith(servings: servings, scaledIngredients: scaled));
  }

  static List<Ingredient> _scaleIngredients(Recipe recipe, int targetServings) {
    final baseServings = recipe.servings;
    if (baseServings <= 0) {
      return List<Ingredient>.from(recipe.ingredients, growable: false);
    }
    final multiplier = targetServings / baseServings;
    return recipe.ingredients
        .map((ingredient) => ingredient.scale(multiplier))
        .toList(growable: false);
  }
}
