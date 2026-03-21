import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';
import 'package:budget_app/features/business_tools/domain/entities/received_invoice.dart';
import 'package:budget_app/features/business_tools/domain/usecases/calculate_invoice_stats.dart';

void main() {
  group('CalculateInvoiceStats', () {
    test('should correctly calculate summary from outgoing and received invoices', () {
      final outgoing = [
        Invoice(
          id: '1',
          profileId: 'p1',
          invoiceNumber: 'INV1',
          date: DateTime.now(),
          clientName: 'C1',
          clientDetails: 'D1',
          status: InvoiceStatus.paid,
          subTotal: 100,
          taxTotal: 20,
          grandTotal: 120,
          balanceDue: 0,
        ),
        Invoice(
          id: '2',
          profileId: 'p1',
          invoiceNumber: 'INV2',
          date: DateTime.now(),
          clientName: 'C2',
          clientDetails: 'D2',
          status: InvoiceStatus.draft,
          subTotal: 200,
          taxTotal: 40,
          grandTotal: 240,
          balanceDue: 240,
        ),
      ];

      final received = [
        ReceivedInvoice(
          id: '3',
          vendorName: 'V1',
          date: DateTime.now(),
          amount: 50,
          taxAmount: 10,
          status: ReceivedInvoiceStatus.partial,
          balanceDue: 30,
        ),
      ];

      final summary = CalculateInvoiceStats.execute(
        outgoingInvoices: outgoing,
        receivedInvoices: received,
      );

      expect(summary.totalReceivables, 240);
      expect(summary.totalPayables, 30);
      expect(summary.paidCount, 1);
      expect(summary.unpaidCount, 1);
      expect(summary.partialCount, 1);
    });
  });
}
