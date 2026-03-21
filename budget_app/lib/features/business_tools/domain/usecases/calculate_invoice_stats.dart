import '../entities/invoice.dart';
import '../entities/received_invoice.dart';
import '../entities/invoice_summary.dart';

class CalculateInvoiceStats {
  CalculateInvoiceStats._();

  static InvoiceSummary execute({
    required List<Invoice> outgoingInvoices,
    required List<ReceivedInvoice> receivedInvoices,
  }) {
    double totalReceivables = outgoingInvoices.fold(0, (sum, inv) => sum + inv.balanceDue);
    double totalPayables = receivedInvoices.fold(0, (sum, inv) => sum + inv.balanceDue);

    int paidCount = 0;
    int unpaidCount = 0;
    int partialCount = 0;

    // Count outgoing statuses
    for (var inv in outgoingInvoices) {
      if (inv.status == InvoiceStatus.paid) {
        paidCount++;
      } else if (inv.status == InvoiceStatus.draft) {
        unpaidCount++;
      } else if (inv.balanceDue < inv.grandTotal && inv.balanceDue > 0) {
        partialCount++;
      } else {
        unpaidCount++; // Assuming sent but not paid is unpaid
      }
    }

    // Count received statuses
    for (var inv in receivedInvoices) {
      if (inv.status == ReceivedInvoiceStatus.paid) {
        paidCount++;
      } else if (inv.status == ReceivedInvoiceStatus.partial) {
        partialCount++;
      } else {
        unpaidCount++;
      }
    }

    return InvoiceSummary(
      totalReceivables: totalReceivables,
      totalPayables: totalPayables,
      paidCount: paidCount,
      unpaidCount: unpaidCount,
      partialCount: partialCount,
    );
  }
}
