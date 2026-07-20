import '../entities/attachment.dart';

abstract class AttachmentsRepository {
  Future<List<Attachment>> getAttachmentsForTransaction(String transactionId, String transactionType);
  Future<Attachment> addAttachment(Attachment attachment);
  Future<void> deleteAttachment(String id);
}
