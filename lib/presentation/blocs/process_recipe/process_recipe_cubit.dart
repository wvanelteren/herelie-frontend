import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/recipe_repository.dart';
import 'process_recipe_state.dart';

class ProcessRecipeCubit extends Cubit<ProcessRecipeState> {
  final RecipeRepository repository;
  ProcessRecipeCubit(this.repository) : super(const ProcessRecipeState());

  Future<void> process(String text) async {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(status: ProcessStatus.loading, error: null));
    try {
      final recipe = await repository.processRecipeText(text.trim());
      emit(state.copyWith(status: ProcessStatus.success, recipe: recipe));
    } catch (e) {
      emit(state.copyWith(status: ProcessStatus.failure, error: e.toString()));
    }
  }

  void reset() => emit(const ProcessRecipeState());
}