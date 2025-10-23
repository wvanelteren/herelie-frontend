import '../../domain/entities/ingredient.dart';
import '../../domain/entities/pp_ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/optimizer_remote_data_source.dart';
import '../datasources/recipe_local_data_source.dart';
import '../datasources/recipe_remote_data_source.dart';
import '../models/api/optimizer_request.dart';
import '../models/api/optimizer_response.dart';
import '../models/api/process_response.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remote;
  final OptimizerRemoteDataSource optimizerRemote;
  final RecipeLocalDataSource local;

  RecipeRepositoryImpl({
    required this.remote,
    required this.optimizerRemote,
    required this.local,
  });

  @override
  Future<Recipe> processRecipeText(String text) async {
    final parserResponse = await remote.processText(text);
    final ingredients = _mapParsedIngredients(parserResponse);

    ApiOptimizerResponse? optimizerResponse;
    final optimizerRequest = _buildOptimizerRequest(
      parserResponse,
      ingredients,
    );

    if (optimizerRequest != null) {
      optimizerResponse = await optimizerRemote.optimize(optimizerRequest);
    }

    final recipe = _buildRecipe(
      parser: parserResponse,
      ingredients: ingredients,
      optimizer: optimizerResponse,
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

  OptimizerRequest? _buildOptimizerRequest(
    ProcessResponse parserResponse,
    List<Ingredient> ingredients,
  ) {
    final demands = ingredients
        .where((ingredient) =>
            ingredient.id != null &&
            ingredient.foundationId != null &&
            ingredient.amount != null &&
            ingredient.unit != null)
        .map(
          (ingredient) => OptimizerDemand(
            ingredientId: ingredient.id!,
            ingredientName: ingredient.name,
            foundationId: ingredient.foundationId!,
            requested: RequestedQuantity(
              amount: ingredient.amount!,
              unit: ingredient.unit!,
            ),
          ),
        )
        .toList(growable: false);

    if (demands.isEmpty) return null;

    return OptimizerRequest(
      jobId: parserResponse.jobId,
      initiatedAt: DateTime.now().toUtc(),
      request: OptimizerRequestPayload(demands: demands),
    );
  }

  Recipe _buildRecipe({
    required ProcessResponse parser,
    required List<Ingredient> ingredients,
    ApiOptimizerResponse? optimizer,
  }) {
    final solution = optimizer?.solutions.isNotEmpty == true
        ? optimizer!.solutions.first
        : null;

    final purchasePlan = <PurchasePlanIngredient>[];
    if (solution != null) {
      for (final plan in solution.purchasePlan) {
        if (plan.packs.isEmpty) continue;
        final firstPack = plan.packs.first;
        final fallbackTitle = firstPack.skuId ??
            (plan.ingredientIds.isNotEmpty
                ? plan.ingredientIds.first
                : 'Onbekend product');
        purchasePlan.add(
          PurchasePlanIngredient(
            title: fallbackTitle,
            ppIngredientCostEur: plan.totalCostEur,
            ingredientIds: plan.ingredientIds,
            amount: plan.fulfilled?.amount ?? plan.requested?.amount,
            unit: plan.fulfilled?.unit ?? plan.requested?.unit,
            packCount: plan.totalPackCount,
          ),
        );
      }
    }

    return Recipe(
      id: parser.jobId,
      title: parser.recipe.title,
      servings: parser.recipe.servings,
      totalCostEur: solution?.totalCostEur ?? 0,
      ingredients: ingredients,
      purchasePlanIngredients: purchasePlan,
      createdAt: DateTime.now(),
    );
  }
}
