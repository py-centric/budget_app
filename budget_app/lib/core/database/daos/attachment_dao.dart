import 'base_dao.dart';

class AttachmentDao extends BaseDao {
  AttachmentDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAttachmentsForTransaction(
    String transactionId,
    String transactionType,
  ) async {
    final database = await db;
    return await database.query(
      'attachments',
      where: 'transaction_id = ? AND transaction_type = ?',
      whereArgs: [transactionId, transactionType],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> addAttachment(Map<String, dynamic> attachment) async {
    final database = await db;
    await database.insert('attachments', attachment);
  }

  Future<void> deleteAttachment(String id) async {
    final database = await db;
    await database.delete('attachments', where: 'id = ?', whereArgs: [id]);
  }
}
