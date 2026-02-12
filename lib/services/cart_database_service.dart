import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wealth_bridge_impex/models/cart_item_model.dart';

class CartDatabaseService {
  CartDatabaseService._();
  static final CartDatabaseService instance = CartDatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cart_database.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        slabId INTEGER NOT NULL,
        slab TEXT NOT NULL,
        price REAL NOT NULL,
        qty REAL NOT NULL,
        amount REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ---------------- CRUD ----------------

  /// Get all cart items
  Future<List<CartItemModel>> getCartItems() async {
    final db = await database;
    final result = await db.query('cart_items', orderBy: 'createdAt DESC');

    return result.map((e) => CartItemModel.fromMap(e)).toList();
  }

  /// Insert OR update slab (important)
  Future<void> insertOrUpdate(CartItemModel item) async {
    final db = await database;

    final existing = await db.query(
      'cart_items',
      where: 'slabId = ?',
      whereArgs: [item.slabId],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      final existingItem = CartItemModel.fromMap(existing.first);
      final updated = existingItem.copyWith(qty: existingItem.qty + item.qty);

      await db.update(
        'cart_items',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [existingItem.id],
      );
    } else {
      await db.insert(
        'cart_items',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Update quantity directly
  Future<void> updateQty(int id, double qty, double price) async {
    final db = await database;

    await db.update(
      'cart_items',
      {'qty': qty, 'amount': qty * price},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Remove single item
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear cart (optional)
  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
