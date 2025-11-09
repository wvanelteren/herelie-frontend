import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/purchase_plan_repository.dart';
import 'shopping_list_state.dart';

class ShoppingListCubit extends Cubit<ShoppingListState> {
  final PurchasePlanRepository purchasePlans;

  ShoppingListCubit({required this.purchasePlans})
    : super(const ShoppingListState());

  Future<void> toggleRecipe(Recipe recipe) async {
    final recipeId = recipe.id;
    if (state.pendingRecipeIds.contains(recipeId)) return;

    _setPending(recipeId, true);
    try {
      final updatedSelections = Map<String, Recipe>.from(state.selectedRecipes);
      if (updatedSelections.containsKey(recipeId)) {
        updatedSelections.remove(recipeId);
      } else {
        updatedSelections[recipeId] = recipe;
      }

      await purchasePlans.deleteShoppingListPlan();

      emit(
        state.copyWith(
          selectedRecipes: updatedSelections,
          pendingRecipeIds: _updatedPending(recipeId, add: false),
          combinedPlan: null,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          pendingRecipeIds: _updatedPending(recipeId, add: false),
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> removeRecipeById(String recipeId) async {
    final recipe = state.selectedRecipes[recipeId];
    if (recipe == null) return;
    await toggleRecipe(recipe);
  }

  Future<void> generateCombinedPlan({bool force = false}) async {
    if (state.selectedRecipes.isEmpty) {
      await purchasePlans.deleteShoppingListPlan();
      emit(
        state.copyWith(combinedPlan: null, isGenerating: false, error: null),
      );
      return;
    }

    if (state.isGenerating) return;
    if (!force && state.combinedPlan != null) return;

    emit(state.copyWith(isGenerating: true, error: null));
    try {
      final recipes = state.selectedRecipes.values.toList(growable: false);
      final plan = await purchasePlans.generateCombinedPlan(recipes: recipes);
      emit(
        state.copyWith(
          combinedPlan: plan,
          isGenerating: false,
          error: plan == null
              ? 'Geen aankoopplan beschikbaar voor deze selectie.'
              : null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isGenerating: false, error: e.toString()));
    }
  }

  Future<void> clear() async {
    await purchasePlans.deleteShoppingListPlan();
    emit(const ShoppingListState());
  }

  void _setPending(String recipeId, bool pending) {
    emit(
      state.copyWith(pendingRecipeIds: _updatedPending(recipeId, add: pending)),
    );
  }

  Set<String> _updatedPending(String recipeId, {required bool add}) {
    final updated = Set<String>.from(state.pendingRecipeIds);
    if (add) {
      updated.add(recipeId);
    } else {
      updated.remove(recipeId);
    }
    return updated;
  }
}
