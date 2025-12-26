import '../../core/database/app_database.dart';
import '../models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';

class TransactionRepository {
  final AppDatabase _db = AppDatabase.instance;

  // ================================
  // CREATE TRANSACTION (income/expense)
  // ================================
  Future<void> create(TransactionModel transaction) async {
    final db = await _db.database;

    await db.transaction((txn) async {
      // 1️⃣ Insert transaction
      await txn.insert(
        'transactions',
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2️⃣ Calculate balance change
      final double delta =
          transaction.type == 'income'
              ? transaction.amount
              : -transaction.amount;

      // 3️⃣ Update account balance
      await txn.rawUpdate(
        '''
        UPDATE accounts
        SET balance = balance + ?
        WHERE id = ?
        ''',
        [delta, transaction.accountId],
      );
    });
  }

  // ================================
  // GET ALL TRANSACTIONS
  // ================================
  Future<List<TransactionModel>> getAll() async {
    final db = await _db.database;
    final result =
        await db.query('transactions', orderBy: 'date DESC');
    return result.map(TransactionModel.fromMap).toList();
  }

  // ================================
  // TOTAL INCOME
  // ================================
  Future<double> totalIncome() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='income'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ================================
  // TOTAL EXPENSE
  // ================================
  Future<double> totalExpense() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='expense'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ================================
  // CATEGORY-WISE EXPENSE (Pie Chart Base)
  // ================================
  Future<List<Map<String, dynamic>>> categoryWiseTotals() async {
    final db = await _db.database;
    return db.rawQuery('''
      SELECT c.name, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = 'expense'
      GROUP BY c.id
    ''');
  }

  // ================================
  // FILTER BY DATE
  // ================================
  Future<List<TransactionModel>> filterByDate(
    int startDate,
    int endDate,
  ) async {
    final db = await _db.database;
    final result = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return result.map(TransactionModel.fromMap).toList();
  }

  // ================================
  // FILTER BY ACCOUNT
  // ================================
  Future<List<TransactionModel>> filterByAccount(int accountId) async {
    final db = await _db.database;
    final result = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return result.map(TransactionModel.fromMap).toList();
  }

  // ================================
  // DELETE TRANSACTION (balance-safe)
  // ================================
  Future<void> delete(TransactionModel transaction) async {
    final db = await _db.database;

    await db.transaction((txn) async {
      // 1️⃣ Reverse balance impact
      final double delta =
          transaction.type == 'income'
              ? -transaction.amount
              : transaction.amount;

      await txn.rawUpdate(
        '''
        UPDATE accounts
        SET balance = balance + ?
        WHERE id = ?
        ''',
        [delta, transaction.accountId],
      );

      // 2️⃣ Delete transaction
      await txn.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    });
  }

  // ================================
  // TRANSFER BETWEEN ACCOUNTS
  // ================================
  Future<void> transfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required int date,
  }) async {
    final db = await _db.database;

    await db.transaction((txn) async {
      // 1️⃣ Insert transfer transaction
      await txn.insert('transactions', {
        'type': 'transfer',
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount,
        'date': date,
      });

      // 2️⃣ Debit source account
      await txn.rawUpdate(
        'UPDATE accounts SET balance = balance - ? WHERE id = ?',
        [amount, fromAccountId],
      );

      // 3️⃣ Credit destination account
      await txn.rawUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        [amount, toAccountId],
      );
    });
  }
}
