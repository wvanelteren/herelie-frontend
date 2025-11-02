import '../../domain/entities/purchase_plan.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
import '../datasources/purchase_plan_local_data_source.dart';

class PurchasePlanRepositoryImpl implements PurchasePlanRepository {
  final PurchasePlanLocalDataSource local;

  PurchasePlanRepositoryImpl({required this.local});

  @override
  Future<void> save(PurchasePlan plan) => local.upsertPlan(plan);

  @override
  Future<PurchasePlan?> getByRecipeId(String recipeId) =>
      local.getByRecipeId(recipeId);

  @override
  Future<void> deleteByRecipeId(String recipeId) =>
      local.deleteByRecipeId(recipeId);
}
