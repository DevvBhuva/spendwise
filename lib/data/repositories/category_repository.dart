import '../models/category_model.dart';
import '../db/app_database.dart';

class CategoryRepository {
  final _db = AppDatabase.instance;

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _db.database;
    final result = await db.query('categories');
    return result.map(CategoryModel.fromMap).toList();
  }

  Future<void> insertCategory(CategoryModel category) async {
    final db = await _db.database;
    await db.insert('categories', category.toMap());
  }

  Future<void> deleteCategory(int id) async {
    final db = await _db.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
