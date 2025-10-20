import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../core/db/app_database.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/pp_ingredient.dart';
import '../../domain/entities/recipe.dart';

class RecipeLocalDataSource {
  final AppDatabase _database;
  RecipeLocalDataSource(this._database);

  Future<void> upsertRecipe(Recipe recipe) async {
    final db = _database.db;
    await db.transaction((txn) async {
      await txn.insert('recipes', {
        'id': recipe.id,
        'title': recipe.title,
        'servings': recipe.servings,
        'total_cost': recipe.totalCostEur,
        'created_at': recipe.createdAt.millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete(
        'ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipe.id],
      );
      await txn.delete(
        'pp_ingredientitems',
        where: 'recipe_id = ?',
        whereArgs: [recipe.id],
      );

      // Insert ingredients
      for (final ing in recipe.ingredients) {
        await txn.insert('ingredients', {
          'recipe_id': recipe.id,
          'ingredient_id': ing.id,
          'name': ing.name,
          'unit': ing.unit,
          'amount': ing.amount,
        });
      }

      // Insert ingredient purchase plan items
      for (final li in recipe.purchasePlanIngredients) {
        await txn.insert('pp_ingredientitems', {
          'recipe_id': recipe.id,
          'title': li.title,
          'unit': li.unit,
          'amount': li.amount,
          'pack_count': li.packCount,
          'ingredient_ids': jsonEncode(li.ingredientIds),
          'pp_ingredient_cost_eur': li.ppIngredientCostEur,
        });
      }
    });
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = _database.db;
    final rows = await db.query('recipes', orderBy: 'created_at DESC');

    final ids = rows.map((r) => r['id'] as String).toList();
    final List<Map<String, Object?>> ingRows = ids.isEmpty
        ? []
        : await db.query(
            'ingredients',
            where: 'recipe_id IN (${List.filled(ids.length, '?').join(',')})',
            whereArgs: ids,
          );
    final List<Map<String, Object?>> liRows = ids.isEmpty
        ? []
        : await db.query(
            'pp_ingredientitems',
            where: 'recipe_id IN (${List.filled(ids.length, '?').join(',')})',
            whereArgs: ids,
          );

    Map<String, List<Ingredient>> ingMap = {};
    for (final r in ingRows) {
      final id = r['recipe_id'] as String;
      ingMap.putIfAbsent(id, () => []);
      ingMap[id]!.add(
        Ingredient(
          id: r['ingredient_id'] as String?,
          name: (r['name'] as String),
          unit: r['unit'] as String?,
          amount: (r['amount'] as num?)?.toDouble(),
        ),
      );
    }

    Map<String, List<PurchasePlanIngredient>> liMap = {};
    for (final r in liRows) {
      final id = r['recipe_id'] as String;
      liMap.putIfAbsent(id, () => []);
      final ingredientIdsRaw = r['ingredient_ids'] as String?;
      final ingredientIds = ingredientIdsRaw == null || ingredientIdsRaw.isEmpty
          ? const <String>[]
          : List<String>.from(
              (jsonDecode(ingredientIdsRaw) as List).map((e) => e.toString()),
            );
      liMap[id]!.add(
        PurchasePlanIngredient(
          title: (r['title'] as String),
          unit: r['unit'] as String?,
          amount: (r['amount'] as num?)?.toDouble(),
          ppIngredientCostEur: (r['pp_ingredient_cost_eur'] as num).toDouble(),
          packCount: (r['pack_count'] as num?)?.toInt(),
          ingredientIds: ingredientIds,
        ),
      );
    }

    return rows.map((r) {
      final id = r['id'] as String;
      return Recipe(
        id: id,
        title: r['title'] as String,
        servings: (r['servings'] as num).toInt(),
        totalCostEur: (r['total_cost'] as num).toDouble(),
        ingredients: ingMap[id] ?? const [],
        purchasePlanIngredients: liMap[id] ?? const [],
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (r['created_at'] as num).toInt(),
        ),
      );
    }).toList();
  }

  Future<Recipe?> getById(String id) async {
    final db = _database.db;
    final rows = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final recipe = (await getAllRecipes()).firstWhere((e) => e.id == id);
    return recipe;
  }
}
