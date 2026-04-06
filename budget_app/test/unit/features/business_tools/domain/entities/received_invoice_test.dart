import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/received_invoice.dart';

void main() {
  group('ReceivedInvoice', () {
    test('should create ReceivedInvoice with required fields', () {
      final invoice = ReceivedInvoice(
        id: '1',
        vendorName: 'Test Vendor',
        date: DateTime(2024, 1, 15),
        amount: 1000.0,
        taxAmount: 200.0,
        status: ReceivedInvoiceStatus.unpaid,
        balanceDue: 1200.0,
      );

      expect(invoice.id, '1');
      expect(invoice.vendorName, 'Test Vendor');
      expect(invoice.invoiceNumber, isNull);
      expect(invoice.date, DateTime(2024, 1, 15));
      expect(invoice.dueDate, isNull);
      expect(invoice.amount, 1000.0);
      expect(invoice.taxAmount, 200.0);
      expect(invoice.status, ReceivedInvoiceStatus.unpaid);
      expect(invoice.balanceDue, 1200.0);
      expect(invoice.notes, isNull);
    });

    test('should create ReceivedInvoice with all fields', () {
      final invoice = ReceivedInvoice(
        id: '1',
        vendorName: 'Test Vendor',
        invoiceNumber: 'INV-001',
        date: DateTime(2024, 1, 15),
        dueDate: DateTime(2024, 2, 15),
        amount: 1000.0,
        taxAmount: 200.0,
        status: ReceivedInvoiceStatus.paid,
        balanceDue: 0.0,
        notes: 'Test notes',
      );

      expect(invoice.id, '1');
      expect(invoice.vendorName, 'Test Vendor');
      expect(invoice.invoiceNumber, 'INV-001');
      expect(invoice.dueDate, DateTime(2024, 2, 15));
      expect(invoice.status, ReceivedInvoiceStatus.paid);
      expect(invoice.notes, 'Test notes');
    });

    test('copyWith should create a copy with updated fields', () {
      final original = ReceivedInvoice(
        id: '1',
        vendorName: 'Original Vendor',
        date: DateTime(2024, 1, 1),
        amount: 500.0,
        taxAmount: 100.0,
        status: ReceivedInvoiceStatus.unpaid,
        balanceDue: 600.0,
      );

      final copied = original.copyWith(
        vendorName: 'New Vendor',
        status: ReceivedInvoiceStatus.paid,
        balanceDue: 0.0,
      );

      expect(copied.id, '1');
      expect(copied.vendorName, 'New Vendor');
      expect(copied.amount, 500.0);
      expect(copied.status, ReceivedInvoiceStatus.paid);
      expect(copied.balanceDue, 0.0);
    });

    test('props should contain all fields', () {
      final invoice = ReceivedInvoice(
        id: '1',
        vendorName: 'Test Vendor',
        invoiceNumber: 'INV-001',
        date: DateTime(2024, 1, 15),
        dueDate: DateTime(2024, 2, 15),
        amount: 1000.0,
        taxAmount: 200.0,
        status: ReceivedInvoiceStatus.partial,
        balanceDue: 600.0,
        notes: 'Notes',
      );

      expect(invoice.props, [
        '1',
        'Test Vendor',
        'INV-001',
        DateTime(2024, 1, 15),
        DateTime(2024, 2, 15),
        1000.0,
        200.0,
        ReceivedInvoiceStatus.partial,
        600.0,
        'Notes',
      ]);
    });

    test('two invoices with same values should be equal', () {
      final invoice1 = ReceivedInvoice(
        id: '1',
        vendorName: 'Vendor',
        date: DateTime(2024, 1, 1),
        amount: 100.0,
        taxAmount: 20.0,
        status: ReceivedInvoiceStatus.unpaid,
        balanceDue: 120.0,
      );

      final invoice2 = ReceivedInvoice(
        id: '1',
        vendorName: 'Vendor',
        date: DateTime(2024, 1, 1),
        amount: 100.0,
        taxAmount: 20.0,
        status: ReceivedInvoiceStatus.unpaid,
        balanceDue: 120.0,
      );

      expect(invoice1, equals(invoice2));
    });
  });
}
