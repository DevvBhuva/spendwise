import '../db/app_database.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final _db = AppDatabase.instance;

  /* ================= INSERT ================= */

  Future<void> insertTransaction(TransactionModel tx) async {
    final database = await _db.database;

    await database.insert(
      'transactions',
      tx.toMap(),
    );
  }

  /* ================= GET ALL ================= */

  Future<List<TransactionModel>> getAllTransactions() async {
    final database = await _db.database;

    final result = await database.query(
      'transactions',
      orderBy: 'date DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  /* ================= FILTER BY MONTH ================= */

  Future<List<TransactionModel>> getByMonth(int year, int month) async {
    final database = await _db.database;

    final start =
        DateTime(year, month, 1).millisecondsSinceEpoch;
    final end =
        DateTime(year, month + 1, 1).millisecondsSinceEpoch;

    final result = await database.query(
      'transactions',
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  /* ================= DELETE ================= */

  Future<void> deleteTransaction(int id) async {
    final database = await _db.database;

    await database.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /* ================= BACKUP SUPPORT ================= */

  /// Used while restoring JSON backup
  Future<void> insertFromMap(Map<String, dynamic> map) async {
    final database = await _db.database;
    await database.insert('transactions', map);
  }

  /// Used before restoring backup
  Future<void> clearAllTransactions() async {
    final database = await _db.database;
    await database.delete('transactions');
  }
}
