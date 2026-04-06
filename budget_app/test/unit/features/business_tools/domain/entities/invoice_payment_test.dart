import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_payment.dart';

void main() {
  group('InvoicePayment', () {
    test('should create InvoicePayment with all fields', () {
      final payment = InvoicePayment(
        id: '1',
        invoiceId: 'inv-1',
        amount: 500.0,
        date: DateTime(2024, 1, 15),
        method: 'Bank Transfer',
      );

      expect(payment.id, '1');
      expect(payment.invoiceId, 'inv-1');
      expect(payment.amount, 500.0);
      expect(payment.date, DateTime(2024, 1, 15));
      expect(payment.method, 'Bank Transfer');
    });

    test('props should contain all fields', () {
      final payment = InvoicePayment(
        id: '1',
        invoiceId: 'inv-1',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        method: 'Cash',
      );

      expect(payment.props, [
        '1',
        'inv-1',
        100.0,
        DateTime(2024, 1, 1),
        'Cash',
      ]);
    });

    test('two payments with same values should be equal', () {
      final payment1 = InvoicePayment(
        id: '1',
        invoiceId: 'inv-1',
        amount: 200.0,
        date: DateTime(2024, 2, 1),
        method: 'Check',
      );

      final payment2 = InvoicePayment(
        id: '1',
        invoiceId: 'inv-1',
        amount: 200.0,
        date: DateTime(2024, 2, 1),
        method: 'Check',
      );

      expect(payment1, equals(payment2));
    });

    test('two payments with different values should not be equal', () {
      final payment1 = InvoicePayment(
        id: '1',
        invoiceId: 'inv-1',
        amount: 200.0,
        date: DateTime(2024, 2, 1),
        method: 'Check',
      );

      final payment2 = InvoicePayment(
        id: '2',
        invoiceId: 'inv-1',
        amount: 200.0,
        date: DateTime(2024, 2, 1),
        method: 'Check',
      );

      expect(payment1, isNot(equals(payment2)));
    });
  });
}
