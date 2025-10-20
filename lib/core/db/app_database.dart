import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'recipes.db';
  static const _dbVersion = 1;

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
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            servings INTEGER NOT NULL,
            total_cost REAL NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE ingredients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            recipe_id TEXT NOT NULL,
            ingredient_id TEXT,
            name TEXT NOT NULL,
            unit TEXT,
            amount REAL,
            FOREIGN KEY(recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE pp_ingredientitems(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            recipe_id TEXT NOT NULL,
            title TEXT NOT NULL,
            unit TEXT,
            amount REAL,
            pack_count INTEGER,
            ingredient_ids TEXT NOT NULL,
            pp_ingredient_cost_eur REAL NOT NULL,
            FOREIGN KEY(recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
  }
}
