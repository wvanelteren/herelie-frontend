import 'package:equatable/equatable.dart';
import '../../../domain/entities/recipe.dart';

enum ListStatus { initial, loading, success, failure }

class RecipeListState extends Equatable {
  final ListStatus status;
  final List<Recipe> recipes;
  final String? error;

  const RecipeListState({
    this.status = ListStatus.initial,
    this.recipes = const [],
    this.error,
  });

  RecipeListState copyWith({
    ListStatus? status,
    List<Recipe>? recipes,
    String? error,
  }) =>
      RecipeListState(
        status: status ?? this.status,
        recipes: recipes ?? this.recipes,
        error: error,
      );

  @override
  List<Object?> get props => [status, recipes, error];
}