import '../entities/tag.dart';

abstract class TagsRepository {
  Future<List<Tag>> getAllTags();
  Future<Tag?> getTagById(String id);
  Future<Tag> createTag(Tag tag);
  Future<void> updateTag(Tag tag);
  Future<void> deleteTag(String id);
  Future<List<String>> getTagIdsForTransaction(String transactionId, String transactionType);
  Future<void> tagTransaction(String transactionId, String transactionType, String tagId);
  Future<void> untagTransaction(String transactionId, String transactionType, String tagId);
  Future<List<Map<String, dynamic>>> getTransactionsByTag(String tagId);
}
