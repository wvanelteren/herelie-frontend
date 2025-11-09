import 'package:equatable/equatable.dart';

import '../../../domain/entities/purchase_plan.dart';
import '../../../domain/entities/recipe.dart';

class ShoppingListState extends Equatable {
  static const Object _sentinel = Object();
  final Map<String, Recipe> selectedRecipes;
  final Set<String> pendingRecipeIds;
  final PurchasePlan? combinedPlan;
  final bool isGenerating;
  final String? error;

  const ShoppingListState({
    this.selectedRecipes = const <String, Recipe>{},
    this.pendingRecipeIds = const <String>{},
    this.combinedPlan,
    this.isGenerating = false,
    this.error,
  });

  ShoppingListState copyWith({
    Map<String, Recipe>? selectedRecipes,
    Set<String>? pendingRecipeIds,
    Object? combinedPlan = _sentinel,
    bool? isGenerating,
    Object? error = _sentinel,
  }) {
    return ShoppingListState(
      selectedRecipes: selectedRecipes ?? this.selectedRecipes,
      pendingRecipeIds: pendingRecipeIds ?? this.pendingRecipeIds,
      combinedPlan: identical(combinedPlan, _sentinel)
          ? this.combinedPlan
          : combinedPlan as PurchasePlan?,
      isGenerating: isGenerating ?? this.isGenerating,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  bool isSelected(String recipeId) => selectedRecipes.containsKey(recipeId);

  bool get hasSelection => selectedRecipes.isNotEmpty;

  @override
  List<Object?> get props => [
    selectedRecipes,
    pendingRecipeIds,
    combinedPlan,
    isGenerating,
    error,
  ];
}
