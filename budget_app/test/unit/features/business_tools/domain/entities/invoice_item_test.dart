import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';

void main() {
  group('InvoiceItem', () {
    test('should create InvoiceItem with all fields', () {
      const item = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Consulting Services',
        quantity: 10.0,
        rate: 100.0,
        taxRate: 20.0,
        total: 1200.0,
      );

      expect(item.id, '1');
      expect(item.invoiceId, 'inv-1');
      expect(item.description, 'Consulting Services');
      expect(item.quantity, 10.0);
      expect(item.rate, 100.0);
      expect(item.taxRate, 20.0);
      expect(item.total, 1200.0);
    });

    test('copyWith should create a copy with updated fields', () {
      const original = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Original Item',
        quantity: 1.0,
        rate: 100.0,
        taxRate: 20.0,
        total: 120.0,
      );

      final copied = original.copyWith(
        description: 'Updated Item',
        quantity: 2.0,
      );

      expect(copied.id, '1');
      expect(copied.description, 'Updated Item');
      expect(copied.quantity, 2.0);
      expect(copied.rate, 100.0);
    });

    test('props should contain all fields', () {
      const item = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Test Item',
        quantity: 5.0,
        rate: 50.0,
        taxRate: 10.0,
        total: 275.0,
      );

      expect(item.props, ['1', 'inv-1', 'Test Item', 5.0, 50.0, 10.0, 275.0]);
    });

    test('two items with same values should be equal', () {
      const item1 = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Test Item',
        quantity: 1.0,
        rate: 100.0,
        taxRate: 20.0,
        total: 120.0,
      );

      const item2 = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Test Item',
        quantity: 1.0,
        rate: 100.0,
        taxRate: 20.0,
        total: 120.0,
      );

      expect(item1, equals(item2));
    });
  });
}
