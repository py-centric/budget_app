import '../../domain/entities/tag.dart';
import '../../domain/repositories/tags_repository.dart';
import '../../../budget/data/datasources/local_database.dart';

class TagsRepositoryImpl implements TagsRepository {
  final LocalDatabase _localDatabase;

  TagsRepositoryImpl(this._localDatabase);

  @override
  Future<List<Tag>> getAllTags() async {
    final db = await _localDatabase.database;
    final maps = await db.query('tags', orderBy: 'name ASC');
    return maps.map(Tag.fromMap).toList();
  }

  @override
  Future<Tag?> getTagById(String id) async {
    final db = await _localDatabase.database;
    final maps = await db.query('tags', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Tag.fromMap(maps.first);
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    final db = await _localDatabase.database;
    await db.insert('tags', tag.toMap());
    return tag;
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final db = await _localDatabase.database;
    await db.update('tags', tag.toMap(), where: 'id = ?', whereArgs: [tag.id]);
  }

  @override
  Future<void> deleteTag(String id) async {
    final db = await _localDatabase.database;
    await db.delete('transaction_tags', where: 'tag_id = ?', whereArgs: [id]);
    await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<String>> getTagIdsForTransaction(String transactionId, String transactionType) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'transaction_tags',
      columns: ['tag_id'],
      where: 'transaction_id = ? AND transaction_type = ?',
      whereArgs: [transactionId, transactionType],
    );
    return maps.map((m) => m['tag_id'] as String).toList();
  }

  @override
  Future<void> tagTransaction(String transactionId, String transactionType, String tagId) async {
    final db = await _localDatabase.database;
    await db.insert('transaction_tags', {
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'tag_id': tagId,
    });
  }

  @override
  Future<void> untagTransaction(String transactionId, String transactionType, String tagId) async {
    final db = await _localDatabase.database;
    await db.delete(
      'transaction_tags',
      where: 'transaction_id = ? AND transaction_type = ? AND tag_id = ?',
      whereArgs: [transactionId, transactionType, tagId],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionsByTag(String tagId) async {
    final db = await _localDatabase.database;
    return await db.rawQuery('''
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
