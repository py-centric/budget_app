import 'package:flutter/foundation.dart';

@immutable
class LoanPayment {
  final String id;
  final String loanId;
  final double amount;
  final DateTime paymentDate;
  final DateTime createdAt;

  const LoanPayment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    required this.createdAt,
  });

  LoanPayment copyWith({
    String? id,
    String? loanId,
    double? amount,
    DateTime? paymentDate,
    DateTime? createdAt,
  }) {
    return LoanPayment(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoanPayment &&
        other.id == id &&
        other.loanId == loanId &&
        other.amount == amount &&
        other.paymentDate == paymentDate &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, loanId, amount, paymentDate, createdAt);
  }
}
