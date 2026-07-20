import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachments_repository.dart';
import '../../../budget/data/datasources/local_database.dart';

class AttachmentsRepositoryImpl implements AttachmentsRepository {
  final LocalDatabase _localDatabase;

  AttachmentsRepositoryImpl(this._localDatabase);

  @override
  Future<List<Attachment>> getAttachmentsForTransaction(String transactionId, String transactionType) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'attachments',
      where: 'transaction_id = ? AND transaction_type = ?',
      whereArgs: [transactionId, transactionType],
      orderBy: 'created_at DESC',
    );
    return maps.map(Attachment.fromMap).toList();
  }

  @override
  Future<Attachment> addAttachment(Attachment attachment) async {
    final db = await _localDatabase.database;
    await db.insert('attachments', attachment.toMap());
    return attachment;
  }

  @override
  Future<void> deleteAttachment(String id) async {
    final db = await _localDatabase.database;
    await db.delete('attachments', where: 'id = ?', whereArgs: [id]);
  }
}
