import 'package:equatable/equatable.dart';

import '../../../domain/entities/purchase_plan.dart';

class ShoppingListState extends Equatable {
  final List<PurchasePlan> plans;
  final Set<String> pendingRecipeIds;
  final Map<String, String> recipeTitles;
  final String? error;

  const ShoppingListState({
    this.plans = const [],
    this.pendingRecipeIds = const <String>{},
    this.recipeTitles = const <String, String>{},
    this.error,
  });

  ShoppingListState copyWith({
    List<PurchasePlan>? plans,
    Set<String>? pendingRecipeIds,
    Map<String, String>? recipeTitles,
    String? error,
  }) {
    return ShoppingListState(
      plans: plans ?? this.plans,
      pendingRecipeIds: pendingRecipeIds ?? this.pendingRecipeIds,
      recipeTitles: recipeTitles ?? this.recipeTitles,
      error: error,
    );
  }

  bool containsRecipe(String recipeId) =>
      plans.any((plan) => plan.recipeId == recipeId);

  String recipeTitle(String recipeId) =>
      recipeTitles[recipeId] ?? 'Recept';

  @override
  List<Object?> get props => [plans, pendingRecipeIds, recipeTitles, error];
}
