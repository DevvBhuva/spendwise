import '../../core/database/app_database.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<int> create(CategoryModel category) async {
    final db = await _db.database;
    return db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getByType(String type) async {
    final db = await _db.database;
    final result =
        await db.query('categories', where: 'type = ?', whereArgs: [type]);
    return result.map(CategoryModel.fromMap).toList();
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
