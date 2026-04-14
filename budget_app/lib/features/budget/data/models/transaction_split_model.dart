import '../../domain/entities/transaction_split.dart';

class TransactionSplitModel extends TransactionSplit {
  const TransactionSplitModel({
    required super.id,
    required super.parentTransactionId,
    required super.parentTransactionType,
    required super.categoryId,
    required super.amount,
    super.note,
    required super.createdAt,
  });

  factory TransactionSplitModel.fromEntity(TransactionSplit entity) {
    return TransactionSplitModel(
      id: entity.id,
      parentTransactionId: entity.parentTransactionId,
      parentTransactionType: entity.parentTransactionType,
      categoryId: entity.categoryId,
      amount: entity.amount,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }

  factory TransactionSplitModel.fromMap(Map<String, dynamic> map) {
    return TransactionSplitModel(
      id: map['id'] as String,
      parentTransactionId: map['parent_transaction_id'] as String,
      parentTransactionType: map['parent_transaction_type'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_transaction_id': parentTransactionId,
      'parent_transaction_type': parentTransactionType,
      'category_id': categoryId,
      'amount': amount,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TransactionSplit toEntity() {
    return TransactionSplit(
      id: id,
      parentTransactionId: parentTransactionId,
      parentTransactionType: parentTransactionType,
      categoryId: categoryId,
      amount: amount,
      note: note,
      createdAt: createdAt,
    );
  }
}
