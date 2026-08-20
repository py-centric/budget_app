import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';

class EmergencyFundDao extends BaseDao {
  EmergencyFundDao(super.getDb);

  Future<int> insertEmergencyExpense(Map<String, dynamic> expense) async {
    final database = await db;
    return await database.insert('emergency_expenses', expense);
  }

  Future<int> updateEmergencyExpense(Map<String, dynamic> expense) async {
    final database = await db;
    return await database.update(
      'emergency_expenses',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }

  Future<int> deleteEmergencyExpense(String id) async {
    final database = await db;
    return await database.delete(
      'emergency_expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getEmergencyExpenses() async {
    final database = await db;
    return await database.query('emergency_expenses', orderBy: 'sort_order ASC');
  }

  Future<double> getAverageSpendingForLastMonths(int count) async {
    final database = await db;
    final periods = await database.rawQuery(
      '''
      SELECT DISTINCT period_year, period_month 
      FROM expense_entries 
      ORDER BY period_year DESC, period_month DESC 
      LIMIT ?
    ''',
      [count],
    );

    if (periods.isEmpty) return 0.0;

    double total = 0.0;
    for (var period in periods) {
      final year = period['period_year'];
      final month = period['period_month'];
      final sumResult = await database.rawQuery(
        '''
        SELECT SUM(amount) as total 
        FROM expense_entries 
        WHERE period_year = ? AND period_month = ? AND is_potential = 0
      ''',
        [year, month],
      );
      total += (sumResult.first['total'] as num?)?.toDouble() ?? 0.0;
    }

    return total / periods.length;
  }

  Future<void> setMetadata(String key, String value) async {
    final database = await db;
    await database.insert('metadata', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getMetadata(String key) async {
    final database = await db;
    final result = await database.query(
      'metadata',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }
}
