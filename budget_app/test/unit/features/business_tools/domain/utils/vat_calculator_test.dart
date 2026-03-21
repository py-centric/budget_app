import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';
import 'package:budget_app/features/business_tools/domain/utils/vat_calculator.dart';

void main() {
  group('VatCalculator', () {
    test('should correctly group and sum VAT totals', () {
      final items = [
        const InvoiceItem(
          id: '1',
          invoiceId: 'inv1',
          description: 'Item 1',
          quantity: 2,
          rate: 100,
          taxRate: 20,
          total: 200,
        ),
        const InvoiceItem(
          id: '2',
          invoiceId: 'inv1',
          description: 'Item 2',
          quantity: 1,
          rate: 50,
          taxRate: 20,
          total: 50,
        ),
        const InvoiceItem(
          id: '3',
          invoiceId: 'inv1',
          description: 'Item 3',
          quantity: 1,
          rate: 100,
          taxRate: 5,
          total: 100,
        ),
      ];

      final summary = VatCalculator.calculateSummary(items);

      expect(summary.length, 2);
      
      // 20% group: Net = 200 + 50 = 250, VAT = 40 + 10 = 50, Gross = 300
      final vat20 = summary.firstWhere((s) => s.rate == 20);
      expect(vat20.netAmount, 250);
      expect(vat20.vatAmount, 50);
      expect(vat20.grossAmount, 300);

      // 5% group: Net = 100, VAT = 5, Gross = 105
      final vat5 = summary.firstWhere((s) => s.rate == 5);
      expect(vat5.netAmount, 100);
      expect(vat5.vatAmount, 5);
      expect(vat5.grossAmount, 105);
    });

    test('should return empty list if no items', () {
      final summary = VatCalculator.calculateSummary([]);
      expect(summary, isEmpty);
    });
  });
}
