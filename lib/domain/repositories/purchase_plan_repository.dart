import '../entities/purchase_plan.dart';

abstract class PurchasePlanRepository {
  Future<void> save(PurchasePlan plan);
  Future<PurchasePlan?> getByRecipeId(String recipeId);
  Future<void> deleteByRecipeId(String recipeId);
}
