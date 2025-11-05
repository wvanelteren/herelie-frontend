import 'package:equatable/equatable.dart';

import '../../data/models/api/optimizer_response.dart';
import 'pp_ingredient.dart';

class PurchasePlan extends Equatable {
  final String id;
  final String recipeId;
  final int servings;
  final double totalCostEur;
  final List<PurchasePlanIngredient> items;
  final DateTime createdAt;

  const PurchasePlan({
    required this.id,
    required this.recipeId,
    required this.servings,
    required this.totalCostEur,
    required this.items,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        recipeId,
        servings,
        totalCostEur,
        items,
        createdAt,
      ];

  static PurchasePlan? generateForRecipe({
    required String recipeId,
    required int servings,
    required ApiOptimizerResponse response,
  }) {
    final solution =
        response.solutions.isNotEmpty ? response.solutions.first : null;
    if (solution == null) return null;

    final items = <PurchasePlanIngredient>[];
    for (final plan in solution.purchasePlan) {
      if (plan.packs.isEmpty) continue;
      final firstPack = plan.packs.first;
      final fallbackTitle = firstPack.skuName ?? 'Onbekend product';
      items.add(
        PurchasePlanIngredient(
          title: fallbackTitle,
          costEur: plan.totalCostEur,
          ingredientIds: plan.ingredientIds,
          amount: plan.fulfilled?.amount ?? plan.requested?.amount,
          unit: plan.fulfilled?.unit ?? plan.requested?.unit,
          packCount: plan.totalPackCount,
        ),
      );
    }

    if (items.isEmpty) return null;

    return PurchasePlan(
      id: response.jobId,
      recipeId: recipeId,
      servings: servings,
      totalCostEur: solution.totalCostEur,
      items: items,
      createdAt: response.completedAt,
    );
  }
}
