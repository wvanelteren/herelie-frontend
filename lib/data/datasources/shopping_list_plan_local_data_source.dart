import 'dart:convert';

import '../../core/constants/storage_keys.dart';
import '../../core/db/app_database.dart';
import '../../domain/entities/pp_ingredient.dart';
import '../../domain/entities/purchase_plan.dart';

class ShoppingListPlanLocalDataSource {
  final AppDatabase _database;
  ShoppingListPlanLocalDataSource(this._database);

  Future<void> upsert(PurchasePlan plan) async {
    final db = _database.db;
    await db.transaction((txn) async {
      await txn.delete('shopping_list_plan_items');
      await txn.delete('shopping_list_plan');

      await txn.insert('shopping_list_plan', {
        'id': plan.id,
        'servings': plan.servings,
        'total_cost_eur': plan.totalCostEur,
        'created_at': plan.createdAt.millisecondsSinceEpoch,
      });

      for (final item in plan.items) {
        await txn.insert('shopping_list_plan_items', {
          'plan_id': plan.id,
          'title': item.title,
          'unit': item.unit,
          'amount': item.amount,
          'pack_count': item.packCount,
          'ingredient_ids': jsonEncode(item.ingredientIds),
          'cost_eur': item.costEur,
        });
      }
    });
  }

  Future<PurchasePlan?> getPlan() async {
    final db = _database.db;
    final rows = await db.query('shopping_list_plan', limit: 1);
    if (rows.isEmpty) return null;
    return _mapPlanFromRow(rows.first);
  }

  Future<void> clear() async {
    final db = _database.db;
    await db.transaction((txn) async {
      await txn.delete('shopping_list_plan_items');
      await txn.delete('shopping_list_plan');
    });
  }

  Future<PurchasePlan> _mapPlanFromRow(Map<String, Object?> row) async {
    final db = _database.db;
    final planId = row['id'] as String;
    final itemRows = await db.query(
      'shopping_list_plan_items',
      where: 'plan_id = ?',
      whereArgs: [planId],
    );

    final items = itemRows
        .map((item) {
          final ingredientIdsRaw = item['ingredient_ids'] as String? ?? '[]';
          final ingredientIds = List<String>.from(
            (jsonDecode(ingredientIdsRaw) as List).map((e) => e.toString()),
          );
          return PurchasePlanIngredient(
            title: item['title'] as String,
            unit: item['unit'] as String?,
            amount: (item['amount'] as num?)?.toDouble(),
            packCount: (item['pack_count'] as num?)?.toInt(),
            ingredientIds: ingredientIds,
            costEur: (item['cost_eur'] as num).toDouble(),
          );
        })
        .toList(growable: false);

    return PurchasePlan(
      id: planId,
      recipeId: shoppingListRecipeId,
      servings: (row['servings'] as num).toInt(),
      totalCostEur: (row['total_cost_eur'] as num).toDouble(),
      items: items,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (row['created_at'] as num).toInt(),
      ),
    );
  }
}
