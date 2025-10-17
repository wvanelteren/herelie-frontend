import 'package:equatable/equatable.dart';
import 'ingredient.dart';
import 'line_item.dart';

class Recipe extends Equatable {
  final String id;            // job_id
  final String title;
  final int servings;
  final double totalCostEur;
  final List<Ingredient> ingredients;
  final List<LineItem> lineItems;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.servings,
    required this.totalCostEur,
    required this.ingredients,
    required this.lineItems,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, title, servings, totalCostEur, ingredients, lineItems, createdAt];
}