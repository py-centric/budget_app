import 'package:budget_app/features/accounts/domain/entities/transfer.dart';

class TransferModel extends Transfer {
  const TransferModel({
    required super.id,
    required super.fromAccountId,
    required super.toAccountId,
    required super.amount,
    required super.date,
    super.note,
    required super.createdAt,
  });

  factory TransferModel.fromMap(Map<String, dynamic> map) {
    return TransferModel(
      id: map['id'] as String,
      fromAccountId: map['from_account_id'] as String,
      toAccountId: map['to_account_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TransferModel.fromEntity(Transfer transfer) {
    return TransferModel(
      id: transfer.id,
      fromAccountId: transfer.fromAccountId,
      toAccountId: transfer.toAccountId,
      amount: transfer.amount,
      date: transfer.date,
      note: transfer.note,
      createdAt: transfer.createdAt,
    );
  }
}
