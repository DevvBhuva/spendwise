import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'money_manager.db');

    return await openDatabase(
      path,
      version: 2, // ⬅️ bumped version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ================================
  // ON CREATE (Fresh Install)
  // ================================
  Future<void> _onCreate(Database db, int version) async {
    // Accounts
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');

    // Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color INTEGER,
        icon INTEGER
      )
    ''');

    // Transactions (UPDATED)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER,
        account_id INTEGER,
        from_account_id INTEGER,
        to_account_id INTEGER,
        note TEXT,
        date INTEGER NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id),
        FOREIGN KEY(account_id) REFERENCES accounts(id),
        FOREIGN KEY(from_account_id) REFERENCES accounts(id),
        FOREIGN KEY(to_account_id) REFERENCES accounts(id)
      )
    ''');

    await _insertDefaultCategories(db);
  }

  // ================================
  // ON UPGRADE (Existing Users)
  // ================================
  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add transfer support safely
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN from_account_id INTEGER');
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN to_account_id INTEGER');
    }
  }

  // ================================
  // DEFAULT CATEGORIES
  // ================================
  Future<void> _insertDefaultCategories(Database db) async {
    await db.insert('categories', {
      'name': 'Food',
      'type': 'expense',
      'color': 0xFFE57373,
      'icon': 0xe56c,
    });

    await db.insert('categories', {
      'name': 'Movie',
      'type': 'expense',
      'color': 0xFF64B5F6,
      'icon': 0xe40f,
    });

    await db.insert('categories', {
      'name': 'Travel',
      'type': 'expense',
      'color': 0xFF81C784,
      'icon': 0xe071,
    });

    await db.insert('categories', {
      'name': 'Salary',
      'type': 'income',
      'color': 0xFFFFD54F,
      'icon': 0xe227,
    });
  }
}
