import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/loans/data/models/loan_payment_model.dart';
import 'package:budget_app/features/loans/domain/entities/loan_payment.dart';

void main() {
  group('LoanPaymentModel', () {
    test('should create LoanPayment fromMap', () {
      final map = {
        'id': '1',
        'loan_id': 'loan-1',
        'amount': 100.0,
        'payment_date': '2024-02-01T00:00:00.000',
        'created_at': '2024-02-01T00:00:00.000',
      };

      final payment = LoanPaymentModel.fromMap(map);

      expect(payment.id, '1');
      expect(payment.loanId, 'loan-1');
      expect(payment.amount, 100.0);
      expect(payment.paymentDate, DateTime(2024, 2, 1));
    });

    test('should handle decimal amounts', () {
      final map = {
        'id': '1',
        'loan_id': 'loan-1',
        'amount': 99.99,
        'payment_date': '2024-01-01T00:00:00.000',
        'created_at': '2024-01-01T00:00:00.000',
      };

      final payment = LoanPaymentModel.fromMap(map);

      expect(payment.amount, 99.99);
    });

    test('toMap should return correct map', () {
      final payment = LoanPayment(
        id: '1',
        loanId: 'loan-1',
        amount: 250.0,
        paymentDate: DateTime(2024, 3, 15),
        createdAt: DateTime(2024, 3, 15),
      );

      final map = LoanPaymentModel.toMap(payment);

      expect(map['id'], '1');
      expect(map['loan_id'], 'loan-1');
      expect(map['amount'], 250.0);
    });
  });
}
