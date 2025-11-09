import 'package:uuid/uuid.dart';

import '../../core/constants/storage_keys.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
import '../datasources/optimizer_remote_data_source.dart';
import '../datasources/purchase_plan_local_data_source.dart';
import '../datasources/shopping_list_plan_local_data_source.dart';
import '../models/api/optimizer_request.dart';

class PurchasePlanRepositoryImpl implements PurchasePlanRepository {
  final PurchasePlanLocalDataSource local;
  final ShoppingListPlanLocalDataSource shoppingListLocal;
  final OptimizerRemoteDataSource optimizerRemote;

  PurchasePlanRepositoryImpl({
    required this.local,
    required this.shoppingListLocal,
    required this.optimizerRemote,
  });

  @override
  Future<void> save(PurchasePlan plan) => local.upsertPlan(plan);

  @override
  Future<PurchasePlan?> getByRecipeAndServings(String recipeId, int servings) =>
      local.getByRecipeAndServings(recipeId, servings);

  @override
  Future<PurchasePlan?> generateForServings({
    required Recipe recipe,
    required int servings,
  }) async {
    final scaledIngredients = _scaleIngredients(recipe, servings);
    final request = _buildOptimizerRequest(
      recipeId: recipe.id,
      servings: servings,
      ingredients: scaledIngredients,
    );

    if (request == null) {
      await local.deleteByRecipeAndServings(recipe.id, servings);
      return null;
    }

    final response = await optimizerRemote.optimize(request);
    final plan = PurchasePlan.generateForRecipe(
      recipeId: recipe.id,
      servings: servings,
      response: response,
    );

    if (plan != null) {
      await local.upsertPlan(plan);
    } else {
      await local.deleteByRecipeAndServings(recipe.id, servings);
    }

    return plan;
  }

  @override
  Future<void> deleteByRecipeId(String recipeId) =>
      local.deleteByRecipeId(recipeId);

  @override
  Future<PurchasePlan?> generateCombinedPlan({
    required List<Recipe> recipes,
  }) async {
    final request = _buildCombinedOptimizerRequest(recipes);
    if (request == null) {
      await shoppingListLocal.clear();
      return null;
    }

    final response = await optimizerRemote.optimize(request);
    final plan = PurchasePlan.generateForRecipe(
      recipeId: shoppingListRecipeId,
      servings: recipes.length,
      response: response,
    );

    if (plan != null) {
      await shoppingListLocal.upsert(plan);
    } else {
      await shoppingListLocal.clear();
    }

    return plan;
  }

  @override
  Future<PurchasePlan?> getShoppingListPlan() => shoppingListLocal.getPlan();

  @override
  Future<void> deleteShoppingListPlan() => shoppingListLocal.clear();

  OptimizerRequest? _buildOptimizerRequest({
    required String recipeId,
    required int servings,
    required List<Ingredient> ingredients,
  }) {
    final demands = ingredients
        .where(
          (ingredient) =>
              ingredient.id != null &&
              ingredient.foundationId != null &&
              ingredient.normalizedQuantity?.amount != null &&
              ingredient.normalizedQuantity?.unit != null,
        )
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

    final jobId = const Uuid().v4();
    return OptimizerRequest(
      jobId: jobId,
      initiatedAt: DateTime.now().toUtc(),
      request: OptimizerRequestPayload(demands: demands),
    );
  }

  OptimizerRequest? _buildCombinedOptimizerRequest(List<Recipe> recipes) {
    final aggregated = <String, _AggregatedDemand>{};
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        final normalized = ingredient.normalizedQuantity;
        final ingredientId = ingredient.id;
        final foundationId = ingredient.foundationId;
        if (normalized?.amount == null ||
            normalized?.unit == null ||
            ingredientId == null ||
            foundationId == null) {
          continue;
        }
        final amount = normalized!.amount!;
        final unit = normalized.unit!;
        final existing = aggregated[foundationId];
        if (existing == null) {
          aggregated[foundationId] = _AggregatedDemand(
            ingredientId: ingredientId,
            ingredientName: ingredient.name,
            foundationId: foundationId,
            unit: unit,
            amount: amount,
          );
        } else {
          if (existing.unit != unit) {
            throw _AggregationException(
              'Ingredient ${ingredient.name} gebruikt een andere eenheid '
              '($unit vs ${existing.unit}).',
            );
          }
          existing.amount += amount;
        }
      }
    }

    if (aggregated.isEmpty) return null;

    final demands = aggregated.values
        .map(
          (agg) => OptimizerDemand(
            ingredientId: agg.ingredientId,
            ingredientName: agg.ingredientName,
            foundationId: agg.foundationId,
            requested: RequestedQuantity(amount: agg.amount, unit: agg.unit),
          ),
        )
        .toList(growable: false);

    final jobId = const Uuid().v4();
    return OptimizerRequest(
      jobId: jobId,
      initiatedAt: DateTime.now().toUtc(),
      request: OptimizerRequestPayload(demands: demands),
    );
  }

  List<Ingredient> _scaleIngredients(Recipe recipe, int targetServings) {
    final baseServings = recipe.servings > 0 ? recipe.servings : 1;
    final safeTarget = targetServings > 0 ? targetServings : 1;
    if (baseServings == safeTarget) {
      return List<Ingredient>.from(recipe.ingredients, growable: false);
    }
    final multiplier = safeTarget / baseServings;
    return recipe.ingredients
        .map((ingredient) => ingredient.scale(multiplier))
        .toList(growable: false);
  }
}

class _AggregatedDemand {
  final String ingredientId;
  final String ingredientName;
  final String foundationId;
  final String unit;
  double amount;

  _AggregatedDemand({
    required this.ingredientId,
    required this.ingredientName,
    required this.foundationId,
    required this.unit,
    required this.amount,
  });
}

class _AggregationException implements Exception {
  final String message;
  _AggregationException(this.message);

  @override
  String toString() => message;
}
