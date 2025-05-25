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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
      dateTime TEXT NOT NULL,
      total REAL NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id)
    )
    ''');
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

  Future<int> insertOrder(int userId, String orderNumber, double total) async {
    final db = await database;
    final dateTime = DateTime.now().toIso8601String();
    return await db.insert('orders', {
      'userId': userId,
      'orderNumber': orderNumber,
      'dateTime': dateTime,
      'total': total
    });
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query('orders', orderBy: 'dateTime DESC');
  }
}