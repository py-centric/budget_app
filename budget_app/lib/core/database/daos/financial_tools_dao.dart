import 'base_dao.dart';

class FinancialToolsDao extends BaseDao {
  FinancialToolsDao(super.getDb);

  Future<int> insertSavedCalculation(Map<String, dynamic> calculation) async {
    final database = await db;
    return await database.insert('saved_calculations', calculation);
  }

  Future<List<Map<String, dynamic>>> getSavedCalculations() async {
    final database = await db;
    return await database.query('saved_calculations', orderBy: 'created_at DESC');
  }

  Future<int> deleteSavedCalculation(String id) async {
    final database = await db;
    return await database.delete(
      'saved_calculations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
