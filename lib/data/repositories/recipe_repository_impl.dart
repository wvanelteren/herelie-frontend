import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../datasources/recipe_remote_data_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remote;
  final RecipeLocalDataSource local;

  RecipeRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Recipe> processRecipeText(String text) async {
    final response = await remote.processText(text);
    final entity = response.toEntity();
    await local.upsertRecipe(entity);
    return entity;
  }

  @override
  Future<List<Recipe>> getAllRecipes() => local.getAllRecipes();

  @override
  Future<Recipe?> getById(String id) => local.getById(id);
}