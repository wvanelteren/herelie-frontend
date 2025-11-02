import 'package:equatable/equatable.dart';

import 'pp_ingredient.dart';

class PurchasePlan extends Equatable {
  final String id;
  final String recipeId;
  final double totalCostEur;
  final List<PurchasePlanIngredient> items;
  final DateTime createdAt;

  const PurchasePlan({
    required this.id,
    required this.recipeId,
    required this.totalCostEur,
    required this.items,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, recipeId, totalCostEur, items, createdAt];
}
