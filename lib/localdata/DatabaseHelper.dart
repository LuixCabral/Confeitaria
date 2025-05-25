import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('confeitaria.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT NOT NULL
    )
    ''');
    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      orderNumber TEXT NOT NULL,
      orderCode TEXT NOT NULL,
      status TEXT NOT NULL,
      dateTime TEXT NOT NULL,
      address TEXT NOT NULL,
      total REAL NOT NULL,
      name TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id)
    )
    ''');
    await db.execute('''
    CREATE TABLE order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId INTEGER NOT NULL,
      productId INTEGER NOT NULL,
      name TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      imagePath TEXT,
      category TEXT,
      FOREIGN KEY (orderId) REFERENCES orders (id)
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE orders ADD COLUMN name TEXT NOT NULL DEFAULT ''
      ''');
      await db.execute('''
      ALTER TABLE orders ADD COLUMN orderStatus TEXT NOT NULL DEFAULT 'preparing'
      ''');
      await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        imagePath TEXT,
        category TEXT,
        FOREIGN KEY (orderId) REFERENCES orders (id)
      )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
      ALTER TABLE orders ADD COLUMN orderCode TEXT NOT NULL DEFAULT ''
      ''');
      await db.execute('''
      ALTER TABLE orders ADD COLUMN status TEXT NOT NULL DEFAULT 'preparing'
      ''');
      await db.execute('''
      ALTER TABLE orders ADD COLUMN address TEXT NOT NULL DEFAULT ''
      ''');
      await db.execute('''
      ALTER TABLE orders RENAME COLUMN orderStatus TO oldOrderStatus
      ''');
    }
  }

  Future<int> insertUser(String name, String phone) async {
    final db = await database;
    return await db.insert('users', {'name': name, 'phone': phone},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUser() async {
    final db = await database;
    return await db.query('users', limit: 1);
  }

  Future<int> updateUser(String name, String phone) async {
    final db = await database;
    return await db.update('users', {'name': name, 'phone': phone},
        where: 'id = ?', whereArgs: [1]); // Assuming single user for now
  }

  Future<int> insertOrder({
    required int userId,
    required String orderNumber,
    required String orderCode,
    required String status,
    required String dateTime,
    required String address,
    required double total,
    required String name,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;
    final orderMap = {
      'userId': userId,
      'orderNumber': orderNumber,
      'orderCode': orderCode,
      'status': status,
      'dateTime': dateTime,
      'address': address,
      'total': total,
      'name': name,
    };
    final orderId = await db.insert('orders', orderMap);

    // Inserir itens do pedido
    for (var item in items) {
      await db.insert('order_items', {
        'orderId': orderId,
        'productId': item['id'],
        'name': item['name'],
        'quantity': item['quantity'],
        'price': item['price'],
        'imagePath': item['imagePath'] ?? '',
        'category': item['category'] ?? '',
      });
    }

    return orderId;
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query('orders', orderBy: 'dateTime DESC');
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await database;
    return await db.query('order_items', where: 'orderId = ?', whereArgs: [orderId], orderBy: 'id ASC');
  }
}