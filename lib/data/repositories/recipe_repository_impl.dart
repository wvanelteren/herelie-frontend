import '../../domain/entities/ingredient.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/pp_ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
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
  final PurchasePlanRepository purchasePlans;

  RecipeRepositoryImpl({
    required this.remote,
    required this.optimizerRemote,
    required this.local,
    required this.purchasePlans,
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
    );
    final purchasePlan = _buildPurchasePlan(
      parser: parserResponse,
      optimizer: optimizerResponse,
    );

    await local.upsertRecipe(recipe);
    if (purchasePlan != null) {
      await purchasePlans.save(purchasePlan);
    } else {
      await purchasePlans.deleteByRecipeId(recipe.id);
    }
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
            ingredient.normalizedQuantity?.amount != null &&
            ingredient.normalizedQuantity?.unit != null)
        .map((ingredient) {
          final normalized = ingredient.normalizedQuantity!;
          return OptimizerDemand(
            ingredientId: ingredient.id!,
            ingredientName: ingredient.name,
            foundationId: ingredient.foundationId!,
            requested: RequestedQuantity(
              amount: normalized.amount!,
              unit: normalized.unit!,
            ),
          );
        })
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
  }) {
    return Recipe(
      id: parser.jobId,
      title: parser.recipe.title,
      servings: parser.recipe.servings,
      ingredients: ingredients,
      createdAt: DateTime.now(),
    );
  }

  PurchasePlan? _buildPurchasePlan({
    required ProcessResponse parser,
    ApiOptimizerResponse? optimizer,
  }) {
    final solution = optimizer?.solutions.isNotEmpty == true
        ? optimizer!.solutions.first
        : null;

    if (solution == null) return null;

    final items = <PurchasePlanIngredient>[];
    for (final plan in solution.purchasePlan) {
      if (plan.packs.isEmpty) continue;
      final firstPack = plan.packs.first;
      final fallbackTitle = firstPack.skuId ??
          (plan.ingredientIds.isNotEmpty
              ? plan.ingredientIds.first
              : 'Onbekend product');
      items.add(
        PurchasePlanIngredient(
          title: fallbackTitle,
          costEur: plan.totalCostEur,
          ingredientIds: plan.ingredientIds,
          amount: plan.fulfilled?.amount ?? plan.requested?.amount,
          unit: plan.fulfilled?.unit ?? plan.requested?.unit,
          packCount: plan.totalPackCount,
        ),
      );
    }

    if (items.isEmpty) return null;

    return PurchasePlan(
      id: parser.jobId,
      recipeId: parser.jobId,
      totalCostEur: solution.totalCostEur,
      items: items,
      createdAt: DateTime.now(),
    );
  }
}
