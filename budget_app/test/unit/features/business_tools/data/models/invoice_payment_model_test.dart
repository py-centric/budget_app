import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/data/models/invoice_payment_model.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_payment.dart';

void main() {
  group('InvoicePaymentModel', () {
    test('should create InvoicePaymentModel with required fields', () {
      final model = InvoicePaymentModel(
        id: '1',
        invoiceId: 'inv-1',
        amount: 500.0,
        date: DateTime(2024, 1, 15),
        method: 'Bank Transfer',
      );

      expect(model.id, '1');
      expect(model.invoiceId, 'inv-1');
      expect(model.amount, 500.0);
      expect(model.method, 'Bank Transfer');
    });

    test('should create InvoicePaymentModel fromMap', () {
      final map = {
        'id': '1',
        'invoice_id': 'inv-1',
        'amount': 250.0,
        'date': '2024-01-15T00:00:00.000',
        'method': 'Cash',
      };

      final model = InvoicePaymentModel.fromMap(map);

      expect(model.id, '1');
      expect(model.amount, 250.0);
      expect(model.method, 'Cash');
    });

    test('toMap should return correct map', () {
      final model = InvoicePaymentModel(
        id: '1',
        invoiceId: 'inv-1',
        amount: 750.0,
        date: DateTime(2024, 2, 1),
        method: 'Check',
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['amount'], 750.0);
      expect(map['method'], 'Check');
    });

    test('fromEntity should create model from entity', () {
      final entity = InvoicePayment(
        id: '1',
        invoiceId: 'inv-1',
        amount: 1000.0,
        date: DateTime(2024, 3, 1),
        method: 'Wire Transfer',
      );

      final model = InvoicePaymentModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.amount, 1000.0);
      expect(model.method, 'Wire Transfer');
    });

    test('InvoicePaymentModel should be a subtype of InvoicePayment', () {
      final model = InvoicePaymentModel(
        id: '1',
        invoiceId: 'inv-1',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        method: 'Cash',
      );

      expect(model, isA<InvoicePayment>());
    });
  });
}
