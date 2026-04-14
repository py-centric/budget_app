import '../../domain/entities/category_limit.dart';
import '../../domain/repositories/category_limit_repository.dart';
import '../datasources/local_database.dart';
import '../models/category_limit_model.dart';

class CategoryLimitRepositoryImpl implements CategoryLimitRepository {
  final LocalDatabase _database;

  CategoryLimitRepositoryImpl(this._database);

  @override
  Future<List<CategoryLimit>> getLimitsForBudget(String budgetId) async {
    final db = await _database.database;
    final maps = await db.query(
      'category_limits',
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
    return maps.map((map) => CategoryLimitModel.fromMap(map)).toList();
  }

  @override
  Future<CategoryLimit?> getLimitForCategory(
    String categoryId,
    String budgetId,
  ) async {
    final db = await _database.database;
    final maps = await db.query(
      'category_limits',
      where: 'category_id = ? AND budget_id = ?',
      whereArgs: [categoryId, budgetId],
    );
    if (maps.isEmpty) return null;
    return CategoryLimitModel.fromMap(maps.first);
  }

  @override
  Future<void> saveLimit(CategoryLimit limit, String budgetId) async {
    final db = await _database.database;
    final model = CategoryLimitModel.fromEntity(limit);
    final map = model.toMap();
    map['budget_id'] = budgetId;

    final existing = await db.query(
      'category_limits',
      where: 'category_id = ? AND budget_id = ?',
      whereArgs: [limit.categoryId, budgetId],
    );

    if (existing.isEmpty) {
      await db.insert('category_limits', map);
    } else {
      await db.update(
        'category_limits',
        map,
        where: 'id = ?',
        whereArgs: [limit.id],
      );
    }
  }

  @override
  Future<void> deleteLimit(String limitId) async {
    final db = await _database.database;
    await db.delete('category_limits', where: 'id = ?', whereArgs: [limitId]);
  }

  @override
  Future<double> getSpentAmountForCategory(
    String categoryId,
    int year,
    int month,
  ) async {
    final db = await _database.database;

    final incomeResult = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM income_entries
      WHERE category_id = ? AND period_year = ? AND period_month = ? AND is_potential = 0
    ''',
      [categoryId, year, month],
    );

    final expenseResult = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM expense_entries
      WHERE category_id = ? AND period_year = ? AND period_month = ? AND is_potential = 0
    ''',
      [categoryId, year, month],
    );

    final incomeTotal =
        (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final expenseTotal =
        (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return expenseTotal - incomeTotal;
  }
}
