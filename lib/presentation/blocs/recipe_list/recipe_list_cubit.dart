import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/recipe_repository.dart';
import 'recipe_list_state.dart';

class RecipeListCubit extends Cubit<RecipeListState> {
  final RecipeRepository repository;
  RecipeListCubit(this.repository) : super(const RecipeListState());

  Future<void> load() async {
    emit(state.copyWith(status: ListStatus.loading));
    try {
      final list = await repository.getAllRecipes();
      emit(state.copyWith(status: ListStatus.success, recipes: list));
    } catch (e) {
      emit(state.copyWith(status: ListStatus.failure, error: e.toString()));
    }
  }
}