import '../../domain/entities/loan_payment.dart';

class LoanPaymentModel {
  static LoanPayment fromMap(Map<String, dynamic> map) {
    return LoanPayment(
      id: map['id'] as String,
      loanId: map['loan_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['payment_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  static Map<String, dynamic> toMap(LoanPayment payment) {
    return {
      'id': payment.id,
      'loan_id': payment.loanId,
      'amount': payment.amount,
      'payment_date': payment.paymentDate.toIso8601String(),
      'created_at': payment.createdAt.toIso8601String(),
    };
  }
}
