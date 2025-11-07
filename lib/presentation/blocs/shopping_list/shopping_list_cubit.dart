import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/purchase_plan.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/purchase_plan_repository.dart';
import 'shopping_list_state.dart';

class ShoppingListCubit extends Cubit<ShoppingListState> {
  final PurchasePlanRepository purchasePlans;

  ShoppingListCubit({required this.purchasePlans})
      : super(const ShoppingListState());

  Future<void> addRecipe(Recipe recipe) async {
    final recipeId = recipe.id;
    if (state.pendingRecipeIds.contains(recipeId) ||
        state.containsRecipe(recipeId)) {
      return;
    }

    _setPending(recipeId, true);
    try {
      final plan = await _loadPlanForRecipe(recipe);
      if (plan != null) {
        final updatedPlans = List<PurchasePlan>.from(state.plans)..add(plan);
        emit(
          state.copyWith(
            plans: updatedPlans,
            pendingRecipeIds: _updatedPending(recipeId, add: false),
            recipeTitles: _updatedTitles(recipeId, recipe.title),
            error: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            pendingRecipeIds: _updatedPending(recipeId, add: false),
            error: 'Geen aankoopplan beschikbaar voor dit recept.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          pendingRecipeIds: _updatedPending(recipeId, add: false),
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> removeRecipe(String recipeId) async {
    if (state.pendingRecipeIds.contains(recipeId)) return;
    if (!state.containsRecipe(recipeId)) return;

    final updatedPlans =
        state.plans.where((plan) => plan.recipeId != recipeId).toList();
    emit(
      state.copyWith(
        plans: updatedPlans,
        recipeTitles: _removeTitle(recipeId),
        error: null,
      ),
    );
  }

  Future<void> toggleRecipe(Recipe recipe) async {
    if (state.containsRecipe(recipe.id)) {
      await removeRecipe(recipe.id);
    } else {
      await addRecipe(recipe);
    }
  }

  Future<void> clear() async {
    emit(const ShoppingListState());
  }

  Future<PurchasePlan?> _loadPlanForRecipe(Recipe recipe) async {
    final servings = recipe.servings > 0 ? recipe.servings : 1;
    final existing =
        await purchasePlans.getByRecipeAndServings(recipe.id, servings);
    if (existing != null) return existing;
    return purchasePlans.generateForServings(
      recipe: recipe,
      servings: servings,
    );
  }

  void _setPending(String recipeId, bool pending) {
    emit(
      state.copyWith(
        pendingRecipeIds: _updatedPending(recipeId, add: pending),
      ),
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

  Map<String, String> _updatedTitles(String recipeId, String recipeTitle) {
    final updated = Map<String, String>.from(state.recipeTitles);
    updated[recipeId] = recipeTitle;
    return updated;
  }

  Map<String, String> _removeTitle(String recipeId) {
    if (!state.recipeTitles.containsKey(recipeId)) return state.recipeTitles;
    final updated = Map<String, String>.from(state.recipeTitles);
    updated.remove(recipeId);
    return updated;
  }
}
