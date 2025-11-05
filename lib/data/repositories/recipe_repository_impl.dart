import '../../domain/entities/ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../datasources/recipe_remote_data_source.dart';
import '../models/api/process_response.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remote;
  final RecipeLocalDataSource local;
  final PurchasePlanRepository purchasePlans;

  RecipeRepositoryImpl({
    required this.remote,
    required this.local,
    required this.purchasePlans,
  });

  @override
  Future<Recipe> processRecipeText(String text) async {
    final parserResponse = await remote.processText(text);
    final ingredients = _mapParsedIngredients(parserResponse);

    final recipe = _buildRecipe(
      parser: parserResponse,
      ingredients: ingredients,
    );

    await local.upsertRecipe(recipe);
    return recipe;
  }

  @override
  Future<List<Recipe>> getAllRecipes() => local.getAllRecipes();

  @override
  Future<Recipe?> getById(String id) => local.getById(id);

  List<Ingredient> _mapParsedIngredients(ProcessResponse response) {
    return response.recipe.ingredients
        .map(
          (ingredient) => Ingredient(
            id: ingredient.ingredientId,
            name: ingredient.name,
            foundationId: ingredient.foundationId,
            foundationName: ingredient.foundationName,
            normalizedQuantity: IngredientQuantity(
              amount: ingredient.normalizedQuantity?.amount,
              unit: ingredient.normalizedQuantity?.unit,
            ),
            originalQuantity: IngredientQuantity(
              amount: ingredient.originalQuantity?.amount,
              unit: ingredient.originalQuantity?.unit,
            ),
          ),
        )
        .toList(growable: false);
  }

  Recipe _buildRecipe({
    required ProcessResponse parser,
    required List<Ingredient> ingredients,
  }) {
    return Recipe(
      id: parser.jobId,
      title: parser.recipe.title,
      servings: parser.recipe.servings,
      ingredients: ingredients,
      createdAt: DateTime.now(),
    );
  }
}
