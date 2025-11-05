import 'package:uuid/uuid.dart';

import '../../domain/entities/ingredient.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
import '../datasources/optimizer_remote_data_source.dart';
import '../datasources/purchase_plan_local_data_source.dart';
import '../models/api/optimizer_request.dart';

class PurchasePlanRepositoryImpl implements PurchasePlanRepository {
  final PurchasePlanLocalDataSource local;
  final OptimizerRemoteDataSource optimizerRemote;

  PurchasePlanRepositoryImpl({
    required this.local,
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
