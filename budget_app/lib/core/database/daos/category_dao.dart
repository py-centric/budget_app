import 'base_dao.dart';

class CategoryDao extends BaseDao {
  CategoryDao(super.getDb);

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final database = await db;
    return await database.insert('categories', category);
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    final database = await db;
    return await database.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(String id) async {
    final database = await db;
    return await database.transaction((txn) async {
      // Null out category_id references in expense_entries and income_entries
      // to avoid foreign key violations before deleting the category.
      await txn.update(
        'expense_entries',
        {'category_id': null},
        where: 'category_id = ?',
        whereArgs: [id],
      );
      await txn.update(
        'income_entries',
        {'category_id': null},
        where: 'category_id = ?',
        whereArgs: [id],
      );
      // Also null out references in transaction_splits and savings_goals
      await txn.update(
        'transaction_splits',
        {'category_id': null},
        where: 'category_id = ?',
        whereArgs: [id],
      );
      await txn.update(
        'savings_goals',
        {'linked_category_id': null},
        where: 'linked_category_id = ?',
        whereArgs: [id],
      );
      // Delete category_limits that reference this category
      await txn.delete(
        'category_limits',
        where: 'category_id = ?',
        whereArgs: [id],
      );
      return await txn.delete('categories', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> reassignCategory(String oldId, String newId) async {
    final database = await db;
    return await database.transaction((txn) async {
      await txn.update(
        'income_entries',
        {'category_id': newId},
        where: 'category_id = ?',
        whereArgs: [oldId],
      );
      await txn.update(
        'expense_entries',
        {'category_id': newId},
        where: 'category_id = ?',
        whereArgs: [oldId],
      );
      return await txn.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [oldId],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final database = await db;
    return await database.query('categories');
  }

  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final database = await db;
    return await database.query('categories', where: 'type = ?', whereArgs: [type]);
  }
}
