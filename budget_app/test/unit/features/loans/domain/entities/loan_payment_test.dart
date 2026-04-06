import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/loans/domain/entities/loan_payment.dart';

void main() {
  group('LoanPayment', () {
    test('should create LoanPayment with all fields', () {
      final payment = LoanPayment(
        id: '1',
        loanId: 'loan-1',
        amount: 100.0,
        paymentDate: DateTime(2024, 2, 1),
        createdAt: DateTime(2024, 2, 1),
      );

      expect(payment.id, '1');
      expect(payment.loanId, 'loan-1');
      expect(payment.amount, 100.0);
      expect(payment.paymentDate, DateTime(2024, 2, 1));
    });

    test('copyWith should create a copy with updated fields', () {
      final original = LoanPayment(
        id: '1',
        loanId: 'loan-1',
        amount: 100.0,
        paymentDate: DateTime(2024, 2, 1),
        createdAt: DateTime(2024, 2, 1),
      );

      final copied = original.copyWith(
        amount: 200.0,
        paymentDate: DateTime(2024, 3, 1),
      );

      expect(copied.id, '1');
      expect(copied.loanId, 'loan-1');
      expect(copied.amount, 200.0);
      expect(copied.paymentDate, DateTime(2024, 3, 1));
    });

    test('two payments with same values should be equal', () {
      final payment1 = LoanPayment(
        id: '1',
        loanId: 'loan-1',
        amount: 50.0,
        paymentDate: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      final payment2 = LoanPayment(
        id: '1',
        loanId: 'loan-1',
        amount: 50.0,
        paymentDate: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      expect(payment1, equals(payment2));
      expect(payment1.hashCode, equals(payment2.hashCode));
    });

    test('two payments with different values should not be equal', () {
      final payment1 = LoanPayment(
        id: '1',
        loanId: 'loan-1',
        amount: 50.0,
        paymentDate: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      final payment2 = LoanPayment(
        id: '2',
        loanId: 'loan-1',
        amount: 50.0,
        paymentDate: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      expect(payment1, isNot(equals(payment2)));
    });
  });
}
