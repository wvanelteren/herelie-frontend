import 'package:equatable/equatable.dart';
import 'ingredient.dart';
import 'pp_ingredient.dart';

class Recipe extends Equatable {
  final String id; // job_id
  final String title;
  final int servings;
  final double totalCostEur;
  final List<Ingredient> ingredients;
  final List<PurchasePlanIngredient> purchasePlanIngredients;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.servings,
    required this.totalCostEur,
    required this.ingredients,
    required this.purchasePlanIngredients,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    servings,
    totalCostEur,
    ingredients,
    purchasePlanIngredients,
    createdAt,
  ];
}
