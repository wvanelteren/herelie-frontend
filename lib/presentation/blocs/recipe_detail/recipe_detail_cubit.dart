import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/purchase_plan.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/purchase_plan_repository.dart';
import 'recipe_detail_state.dart';

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final PurchasePlanRepository _purchasePlans;
  int _activeRequestId = 0;

  RecipeDetailCubit({
    required Recipe recipe,
    required PurchasePlanRepository purchasePlans,
  }) : _purchasePlans = purchasePlans,
       super(
         RecipeDetailState(
           recipe: recipe,
           servings: recipe.servings > 0 ? recipe.servings : 1,
           scaledIngredients: _scaleIngredients(
             recipe,
             recipe.servings > 0 ? recipe.servings : 1,
           ),
           isLoadingPlan: false,
         ),
       ) {
    _loadPlanForCurrentServings();
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
    emit(
      state.copyWith(
        servings: servings,
        scaledIngredients: scaled,
        planLoadFailed: false,
        isLoadingPlan: false,
        clearPurchasePlan: true,
      ),
    );
    _loadPlanForCurrentServings();
  }

  Future<void> refreshPlan() => loadProductsIfNeeded(forceRefresh: true);

  Future<void> loadProductsIfNeeded({bool forceRefresh = false}) async {
    await _loadPlanForCurrentServings(forceRefresh: forceRefresh);
  }

  Future<void> _loadPlanForCurrentServings({bool forceRefresh = false}) async {
    if (state.isLoadingPlan) return;
    if (!forceRefresh && state.purchasePlan != null && !state.planLoadFailed) {
      return;
    }
    final recipeId = state.recipe.id;
    final servings = state.servings;
    PurchasePlan? cached;

    try {
      cached = await _purchasePlans.getByRecipeAndServings(recipeId, servings);
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          clearPurchasePlan: true,
          isLoadingPlan: false,
          planLoadFailed: true,
        ),
      );
      return;
    }

    if (isClosed || state.servings != servings) return;

    if (cached != null && !forceRefresh) {
      emit(
        state.copyWith(
          purchasePlan: cached,
          isLoadingPlan: false,
          planLoadFailed: false,
        ),
      );
      return;
    }

    final requestId = ++_activeRequestId;
    emit(
      state.copyWith(
        clearPurchasePlan: true,
        isLoadingPlan: true,
        planLoadFailed: false,
      ),
    );

    try {
      final plan = await _purchasePlans.generateForServings(
        recipe: state.recipe,
        servings: servings,
      );
      if (_activeRequestId != requestId || isClosed || state.servings != servings) {
        return;
      }
      emit(
        state.copyWith(
          purchasePlan: plan,
          isLoadingPlan: false,
          planLoadFailed: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
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
