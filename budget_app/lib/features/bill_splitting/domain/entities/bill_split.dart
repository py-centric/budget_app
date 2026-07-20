import 'package:equatable/equatable.dart';

class PersonSplit extends Equatable {
  final String name;
  final double amount;
  final bool isPaid;

  const PersonSplit({
    required this.name,
    required this.amount,
    this.isPaid = false,
  });

  factory PersonSplit.fromMap(Map<String, dynamic> map) {
    return PersonSplit(
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      isPaid: map['is_paid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'is_paid': isPaid,
    };
  }

  PersonSplit copyWith({
    String? name,
    double? amount,
    bool? isPaid,
  }) {
    return PersonSplit(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  List<Object?> get props => [name, amount, isPaid];
}

class BillSplit extends Equatable {
  final String id;
  final String? transactionId;
  final String description;
  final double totalAmount;
  final List<PersonSplit> splits;
  final DateTime createdAt;

  const BillSplit({
    required this.id,
    this.transactionId,
    required this.description,
    required this.totalAmount,
    required this.splits,
    required this.createdAt,
  });

  double get totalSplit => splits.fold(0, (sum, s) => sum + s.amount);
  double get remaining => totalAmount - totalSplit;

  factory BillSplit.fromMap(Map<String, dynamic> map) {
    return BillSplit(
      id: map['id'] as String,
      transactionId: map['transaction_id'] as String?,
      description: map['description'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      splits: (map['splits'] as List<dynamic>? ?? [])
          .map((s) => PersonSplit.fromMap(s as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'description': description,
      'total_amount': totalAmount,
      'splits': splits.map((s) => s.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  BillSplit copyWith({
    String? id,
    String? transactionId,
    String? description,
    double? totalAmount,
    List<PersonSplit>? splits,
    DateTime? createdAt,
  }) {
    return BillSplit(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      splits: splits ?? this.splits,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, transactionId, description, totalAmount, splits, createdAt];
}
