import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        'kolleksiya.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kolleksiya.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT DEFAULT '',
        price REAL DEFAULT 0.0,
        photo_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Barcha elementlarni olish
  Future<List<CollectionItem>> getAllItems() async {
    final db = await database;
    final maps = await db.query('items', orderBy: 'created_at DESC');
    return maps.map((m) => CollectionItem.fromMap(m)).toList();
  }

  // Kategoriya bo'yicha elementlarni olish
  Future<List<CollectionItem>> getItemsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => CollectionItem.fromMap(m)).toList();
  }

  // Qidirish
  Future<List<CollectionItem>> searchItems(String query) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => CollectionItem.fromMap(m)).toList();
  }

  // Element qo'shish
  Future<int> insertItem(CollectionItem item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  // Element yangilash
  Future<int> updateItem(CollectionItem item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Element o'chirish
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistika - kategoriya bo'yicha soni
  Future<Map<String, int>> getCategoryCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM items GROUP BY category',
    );
    return {for (var row in result) row['category'] as String: row['count'] as int};
  }

  // Statistika - kategoriya bo'yicha qiymati
  Future<Map<String, double>> getCategoryValue() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, SUM(price) as total FROM items GROUP BY category',
    );
    return {
      for (var row in result)
        row['category'] as String: (row['total'] as num?)?.toDouble() ?? 0.0
    };
  }
}
