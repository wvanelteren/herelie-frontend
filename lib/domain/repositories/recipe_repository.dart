import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<Recipe> processRecipeText(String text);
  Future<List<Recipe>> getAllRecipes();
  Future<Recipe?> getById(String id);
}