import 'package:equatable/equatable.dart';
import 'ingredient.dart';

class Recipe extends Equatable {
  final String id; // job_id
  final String title;
  final int servings;
  final List<Ingredient> ingredients;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.servings,
    required this.ingredients,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    servings,
    ingredients,
    createdAt,
  ];
}
