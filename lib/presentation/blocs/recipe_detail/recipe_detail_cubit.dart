import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/purchase_plan_repository.dart';
import 'recipe_detail_state.dart';

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final PurchasePlanRepository _purchasePlans;

  RecipeDetailCubit({
    required Recipe recipe,
    required PurchasePlanRepository purchasePlans,
  })  : _purchasePlans = purchasePlans,
        super(
          RecipeDetailState(
            recipe: recipe,
            servings: recipe.servings > 0 ? recipe.servings : 1,
            scaledIngredients: _scaleIngredients(
              recipe,
              recipe.servings > 0 ? recipe.servings : 1,
            ),
            isLoadingPlan: true,
          ),
        ) {
    _loadPlan();
  }

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

  Future<void> refreshPlan() => _loadPlan();

  Future<void> _loadPlan() async {
    emit(state.copyWith(isLoadingPlan: true, planLoadFailed: false));
    try {
      final plan = await _purchasePlans.getByRecipeId(state.recipe.id);
      emit(
        state.copyWith(
          purchasePlan: plan,
          clearPurchasePlan: plan == null,
          isLoadingPlan: false,
          planLoadFailed: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          clearPurchasePlan: true,
          isLoadingPlan: false,
          planLoadFailed: true,
        ),
      );
    }
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
