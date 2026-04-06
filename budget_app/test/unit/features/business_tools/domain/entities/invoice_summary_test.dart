import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_summary.dart';

void main() {
  group('InvoiceSummary', () {
    test('should create InvoiceSummary with all fields', () {
      const summary = InvoiceSummary(
        totalReceivables: 10000.0,
        totalPayables: 5000.0,
        paidCount: 10,
        unpaidCount: 5,
        partialCount: 2,
      );

      expect(summary.totalReceivables, 10000.0);
      expect(summary.totalPayables, 5000.0);
      expect(summary.paidCount, 10);
      expect(summary.unpaidCount, 5);
      expect(summary.partialCount, 2);
    });

    test('props should contain all fields', () {
      const summary = InvoiceSummary(
        totalReceivables: 5000.0,
        totalPayables: 2500.0,
        paidCount: 5,
        unpaidCount: 3,
        partialCount: 1,
      );

      expect(summary.props, [5000.0, 2500.0, 5, 3, 1]);
    });

    test('two summaries with same values should be equal', () {
      const summary1 = InvoiceSummary(
        totalReceivables: 1000.0,
        totalPayables: 500.0,
        paidCount: 2,
        unpaidCount: 1,
        partialCount: 0,
      );

      const summary2 = InvoiceSummary(
        totalReceivables: 1000.0,
        totalPayables: 500.0,
        paidCount: 2,
        unpaidCount: 1,
        partialCount: 0,
      );

      expect(summary1, equals(summary2));
    });

    test('two summaries with different values should not be equal', () {
      const summary1 = InvoiceSummary(
        totalReceivables: 1000.0,
        totalPayables: 500.0,
        paidCount: 2,
        unpaidCount: 1,
        partialCount: 0,
      );

      const summary2 = InvoiceSummary(
        totalReceivables: 2000.0,
        totalPayables: 500.0,
        paidCount: 2,
        unpaidCount: 1,
        partialCount: 0,
      );

      expect(summary1, isNot(equals(summary2)));
    });
  });
}
