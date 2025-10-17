import 'package:equatable/equatable.dart';
import '../../../domain/entities/recipe.dart';

enum ProcessStatus { initial, loading, success, failure }

class ProcessRecipeState extends Equatable {
  final ProcessStatus status;
  final Recipe? recipe;
  final String? error;

  const ProcessRecipeState({
    this.status = ProcessStatus.initial,
    this.recipe,
    this.error,
  });

  ProcessRecipeState copyWith({
    ProcessStatus? status,
    Recipe? recipe,
    String? error,
  }) =>
      ProcessRecipeState(
        status: status ?? this.status,
        recipe: recipe ?? this.recipe,
        error: error,
      );

  @override
  List<Object?> get props => [status, recipe, error];
}