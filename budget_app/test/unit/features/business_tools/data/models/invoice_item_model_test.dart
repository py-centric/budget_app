import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/data/models/invoice_item_model.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';

void main() {
  group('InvoiceItemModel', () {
    test('should create InvoiceItemModel with required fields', () {
      const model = InvoiceItemModel(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Consulting Services',
        quantity: 10.0,
        rate: 100.0,
        taxRate: 20.0,
        total: 1200.0,
      );

      expect(model.id, '1');
      expect(model.invoiceId, 'inv-1');
      expect(model.description, 'Consulting Services');
      expect(model.quantity, 10.0);
      expect(model.rate, 100.0);
    });

    test('should create InvoiceItemModel fromMap', () {
      final map = {
        'id': '1',
        'invoice_id': 'inv-1',
        'description': 'Test Item',
        'quantity': 5.0,
        'rate': 50.0,
        'tax_rate': 10.0,
        'total': 275.0,
      };

      final model = InvoiceItemModel.fromMap(map);

      expect(model.id, '1');
      expect(model.quantity, 5.0);
      expect(model.total, 275.0);
    });

    test('toMap should return correct map', () {
      const model = InvoiceItemModel(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Test',
        quantity: 2.0,
        rate: 75.0,
        taxRate: 15.0,
        total: 172.5,
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['quantity'], 2.0);
      expect(map['rate'], 75.0);
      expect(map['total'], 172.5);
    });

    test('fromEntity should create model from entity', () {
      const entity = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Entity Item',
        quantity: 3.0,
        rate: 200.0,
        taxRate: 25.0,
        total: 750.0,
      );

      final model = InvoiceItemModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.quantity, 3.0);
      expect(model.total, 750.0);
    });

    test('InvoiceItemModel should be a subtype of InvoiceItem', () {
      const model = InvoiceItemModel(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Test',
        quantity: 1.0,
        rate: 100.0,
        taxRate: 20.0,
        total: 120.0,
      );

      expect(model, isA<InvoiceItem>());
    });
  });
}
