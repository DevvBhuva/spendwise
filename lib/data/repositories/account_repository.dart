import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/account_model.dart';

class AccountRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<int> create(AccountModel account) async {
    final db = await _db.database;
    return db.insert('accounts', account.toMap());
  }

  Future<List<AccountModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('accounts');
    return result.map(AccountModel.fromMap).toList();
  }

  Future<double> getTotalBalance() async {
    final db = await _db.database;
    final result =
        await db.rawQuery('SELECT SUM(balance) as total FROM accounts');
    return result.first['total'] as double? ?? 0.0;
  }

  Future<void> update(AccountModel account) async {
    final db = await _db.database;
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
