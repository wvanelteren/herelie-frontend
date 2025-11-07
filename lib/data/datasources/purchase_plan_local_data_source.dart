import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../../core/db/app_database.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/pp_ingredient.dart';

class PurchasePlanLocalDataSource {
  final AppDatabase _database;
  PurchasePlanLocalDataSource(this._database);

  Future<void> upsertPlan(PurchasePlan plan) async {
    final db = _database.db;
    await db.transaction((txn) async {
      final existing = await txn.query(
        'purchase_plans',
        where: 'recipe_id = ? AND servings = ?',
        whereArgs: [plan.recipeId, plan.servings],
      );

      for (final row in existing) {
        final existingId = row['id'] as String;
        await txn.delete(
          'purchase_plan_items',
          where: 'purchase_plan_id = ?',
          whereArgs: [existingId],
        );
      }

      await txn.delete(
        'purchase_plans',
        where: 'recipe_id = ? AND servings = ?',
        whereArgs: [plan.recipeId, plan.servings],
      );

      await txn.insert('purchase_plans', {
        'id': plan.id,
        'recipe_id': plan.recipeId,
        'servings': plan.servings,
        'total_cost_eur': plan.totalCostEur,
        'created_at': plan.createdAt.millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete(
        'purchase_plan_items',
        where: 'purchase_plan_id = ?',
        whereArgs: [plan.id],
      );

      for (final item in plan.items) {
        await txn.insert('purchase_plan_items', {
          'purchase_plan_id': plan.id,
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

  Future<PurchasePlan?> getByRecipeAndServings(
    String recipeId,
    int servings,
  ) async {
    final db = _database.db;
    final planRows = await db.query(
      'purchase_plans',
      where: 'recipe_id = ? AND servings = ?',
      whereArgs: [recipeId, servings],
      limit: 1,
    );
    if (planRows.isEmpty) return null;

    final planRow = planRows.first;
    final planId = planRow['id'] as String;
    final itemRows = await db.query(
      'purchase_plan_items',
      where: 'purchase_plan_id = ?',
      whereArgs: [planId],
    );

    final items = itemRows
        .map((row) {
          final ingredientIdsRaw = row['ingredient_ids'] as String? ?? '[]';
          final ingredientIds = List<String>.from(
            (jsonDecode(ingredientIdsRaw) as List).map((e) => e.toString()),
          );
          return PurchasePlanIngredient(
            title: row['title'] as String,
            unit: row['unit'] as String?,
            amount: (row['amount'] as num?)?.toDouble(),
            packCount: (row['pack_count'] as num?)?.toInt(),
            ingredientIds: ingredientIds,
            costEur: (row['cost_eur'] as num).toDouble(),
          );
        })
        .toList(growable: false);

    return PurchasePlan(
      id: planId,
      recipeId: recipeId,
      servings: servings,
      totalCostEur: (planRow['total_cost_eur'] as num).toDouble(),
      items: items,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (planRow['created_at'] as num).toInt(),
      ),
    );
  }

  Future<void> deleteByRecipeId(String recipeId) async {
    final db = _database.db;
    await db.transaction((txn) async {
      final plans = await txn.query(
        'purchase_plans',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );
      for (final plan in plans) {
        final planId = plan['id'] as String;
        await txn.delete(
          'purchase_plan_items',
          where: 'purchase_plan_id = ?',
          whereArgs: [planId],
        );
      }
      await txn.delete(
        'purchase_plans',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );
    });
  }

  Future<void> deleteByRecipeAndServings(String recipeId, int servings) async {
    final db = _database.db;
    await db.transaction((txn) async {
      final plans = await txn.query(
        'purchase_plans',
        where: 'recipe_id = ? AND servings = ?',
        whereArgs: [recipeId, servings],
      );
      for (final plan in plans) {
        final planId = plan['id'] as String;
        await txn.delete(
          'purchase_plan_items',
          where: 'purchase_plan_id = ?',
          whereArgs: [planId],
        );
      }
      await txn.delete(
        'purchase_plans',
        where: 'recipe_id = ? AND servings = ?',
        whereArgs: [recipeId, servings],
      );
    });
  }
}
