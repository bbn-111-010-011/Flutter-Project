import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cart_item.dart';

class CartDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cart.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE cart_items (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            image TEXT NOT NULL,
            quantity INTEGER NOT NULL
          )
          ''',
        );
      },
    );
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final result = await db.query('cart_items');

    return result.map((map) => CartItem.fromMap(map)).toList();
  }

  Future<void> addItem(CartItem item) async {
    final db = await database;

    final existingItems = await db.query(
      'cart_items',
      where: 'id = ?',
      whereArgs: [item.id],
    );

    if (existingItems.isNotEmpty) {
      final existingItem = CartItem.fromMap(existingItems.first);

      await db.update(
        'cart_items',
        {
          'quantity': existingItem.quantity + 1,
        },
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } else {
      await db.insert(
        'cart_items',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> removeItem(int id) async {
    final db = await database;

    await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }
}