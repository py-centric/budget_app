import 'base_dao.dart';

class CreditCardDao extends BaseDao {
  CreditCardDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAllCreditCards() async {
    final database = await db;
    return await database.query('credit_cards', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getCreditCardById(String id) async {
    final database = await db;
    final maps = await database.query('credit_cards', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> addCreditCard(Map<String, dynamic> card) async {
    final database = await db;
    await database.insert('credit_cards', card);
  }

  Future<void> updateCreditCard(Map<String, dynamic> card) async {
    final database = await db;
    await database.update(
      'credit_cards',
      card,
      where: 'id = ?',
      whereArgs: [card['id']],
    );
  }

  Future<void> deleteCreditCard(String id) async {
    final database = await db;
    await database.delete('credit_cards', where: 'id = ?', whereArgs: [id]);
  }
}
