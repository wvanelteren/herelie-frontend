import '../entities/purchase_plan.dart';
import '../entities/recipe.dart';

abstract class PurchasePlanRepository {
  Future<void> save(PurchasePlan plan);
  Future<PurchasePlan?> getByRecipeAndServings(String recipeId, int servings);
  Future<PurchasePlan?> generateForServings({
    required Recipe recipe,
    required int servings,
  });
  Future<void> deleteByRecipeId(String recipeId);
  Future<PurchasePlan?> generateCombinedPlan({required List<Recipe> recipes});
  Future<PurchasePlan?> getShoppingListPlan();
  Future<void> deleteShoppingListPlan();
}
