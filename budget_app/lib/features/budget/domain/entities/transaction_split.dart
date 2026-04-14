import 'package:equatable/equatable.dart';

class TransactionSplit extends Equatable {
  final String id;
  final String parentTransactionId;
  final String parentTransactionType;
  final String categoryId;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const TransactionSplit({
    required this.id,
    required this.parentTransactionId,
    required this.parentTransactionType,
    required this.categoryId,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  TransactionSplit copyWith({
    String? id,
    String? parentTransactionId,
    String? parentTransactionType,
    String? categoryId,
    double? amount,
    String? note,
    DateTime? createdAt,
  }) {
    return TransactionSplit(
      id: id ?? this.id,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      parentTransactionType:
          parentTransactionType ?? this.parentTransactionType,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    parentTransactionId,
    parentTransactionType,
    categoryId,
    amount,
    note,
    createdAt,
  ];
}
