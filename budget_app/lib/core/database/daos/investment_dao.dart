import 'base_dao.dart';

class InvestmentDao extends BaseDao {
  InvestmentDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAllInvestments() async {
    final database = await db;
    return await database.query('investments', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getInvestmentById(String id) async {
    final database = await db;
    final maps = await database.query('investments', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> addInvestment(Map<String, dynamic> investment) async {
    final database = await db;
    await database.insert('investments', investment);
  }

  Future<void> updateInvestment(Map<String, dynamic> investment) async {
    final database = await db;
    await database.update(
      'investments',
      investment,
      where: 'id = ?',
      whereArgs: [investment['id']],
    );
  }

  Future<void> deleteInvestment(String id) async {
    final database = await db;
    await database.delete('investments', where: 'id = ?', whereArgs: [id]);
  }
}
