import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'recipes.db';
  static const _dbVersion = 5;

  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        // Zorg dat foreign keys werken.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        await _dropSchema(db);
        await _createSchema(db);
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
          CREATE TABLE recipes(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            servings INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
    await db.execute('''
          CREATE TABLE ingredients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            recipe_id TEXT NOT NULL,
            ingredient_id TEXT,
            name TEXT NOT NULL,
            foundation_id TEXT,
            foundation_name TEXT,
            normalized_amount REAL,
            normalized_unit TEXT,
            original_amount REAL,
            original_unit TEXT,
            FOREIGN KEY(recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
          )
        ''');
    await db.execute('''
          CREATE TABLE purchase_plans(
            id TEXT PRIMARY KEY,
            recipe_id TEXT NOT NULL,
            servings INTEGER NOT NULL,
            total_cost_eur REAL NOT NULL,
            created_at INTEGER NOT NULL,
            UNIQUE(recipe_id, servings),
            FOREIGN KEY(recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
          )
        ''');
    await db.execute('''
          CREATE TABLE purchase_plan_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            purchase_plan_id TEXT NOT NULL,
            title TEXT NOT NULL,
            unit TEXT,
            amount REAL,
            pack_count INTEGER,
            ingredient_ids TEXT NOT NULL,
            cost_eur REAL NOT NULL,
            FOREIGN KEY(purchase_plan_id) REFERENCES purchase_plans(id) ON DELETE CASCADE
          )
        ''');
    await db.execute('''
          CREATE TABLE shopping_list_plan(
            id TEXT PRIMARY KEY,
            servings INTEGER NOT NULL,
            total_cost_eur REAL NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
    await db.execute('''
          CREATE TABLE shopping_list_plan_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plan_id TEXT NOT NULL,
            title TEXT NOT NULL,
            unit TEXT,
            amount REAL,
            pack_count INTEGER,
            ingredient_ids TEXT NOT NULL,
            cost_eur REAL NOT NULL,
            FOREIGN KEY(plan_id) REFERENCES shopping_list_plan(id) ON DELETE CASCADE
          )
        ''');
  }

  Future<void> _dropSchema(Database db) async {
    await db.execute('DROP TABLE IF EXISTS shopping_list_plan_items');
    await db.execute('DROP TABLE IF EXISTS shopping_list_plan');
    await db.execute('DROP TABLE IF EXISTS purchase_plan_items');
    await db.execute('DROP TABLE IF EXISTS purchase_plans');
    await db.execute('DROP TABLE IF EXISTS ingredients');
    await db.execute('DROP TABLE IF EXISTS recipes');
  }

  Future<void> close() async {
    await _db?.close();
  }
}
