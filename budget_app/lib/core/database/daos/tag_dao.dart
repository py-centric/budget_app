import 'base_dao.dart';

class TagDao extends BaseDao {
  TagDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAllTags() async {
    final database = await db;
    return await database.query('tags', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getTagById(String id) async {
    final database = await db;
    final maps = await database.query('tags', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> createTag(Map<String, dynamic> tag) async {
    final database = await db;
    await database.insert('tags', tag);
  }

  Future<void> updateTag(Map<String, dynamic> tag) async {
    final database = await db;
    await database.update('tags', tag, where: 'id = ?', whereArgs: [tag['id']]);
  }

  Future<void> deleteTag(String id) async {
    final database = await db;
    await database.delete('transaction_tags', where: 'tag_id = ?', whereArgs: [id]);
    await database.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getTagIdsForTransaction(
    String transactionId,
    String transactionType,
  ) async {
    final database = await db;
    final maps = await database.query(
      'transaction_tags',
      columns: ['tag_id'],
      where: 'transaction_id = ? AND transaction_type = ?',
      whereArgs: [transactionId, transactionType],
    );
    return maps.map((m) => m['tag_id'] as String).toList();
  }

  Future<void> tagTransaction(
    String transactionId,
    String transactionType,
    String tagId,
  ) async {
    final database = await db;
    await database.insert('transaction_tags', {
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'tag_id': tagId,
    });
  }

  Future<void> untagTransaction(
    String transactionId,
    String transactionType,
    String tagId,
  ) async {
    final database = await db;
    await database.delete(
      'transaction_tags',
      where: 'transaction_id = ? AND transaction_type = ? AND tag_id = ?',
      whereArgs: [transactionId, transactionType, tagId],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsByTag(String tagId) async {
    final database = await db;
    return await database.rawQuery('''
      SELECT tt.*, 
             CASE tt.transaction_type 
               WHEN 'expense' THEN e.description
               WHEN 'income' THEN i.description
             END as description,
             CASE tt.transaction_type
               WHEN 'expense' THEN e.amount
               WHEN 'income' THEN i.amount
             END as amount,
             CASE tt.transaction_type
               WHEN 'expense' THEN e.date
               WHEN 'income' THEN i.date
             END as date
      FROM transaction_tags tt
      LEFT JOIN expense_entries e ON tt.transaction_id = e.id AND tt.transaction_type = 'expense'
      LEFT JOIN income_entries i ON tt.transaction_id = i.id AND tt.transaction_type = 'income'
      WHERE tt.tag_id = ?
      ORDER BY date DESC
    ''', [tagId]);
  }
}
