import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';

void main() {
  group('Invoice', () {
    test('should create Invoice with required fields', () {
      final invoice = Invoice(
        id: '1',
        profileId: 'profile-1',
        invoiceNumber: 'INV-001',
        date: DateTime(2024, 1, 15),
        clientName: 'Test Client',
        clientDetails: '123 Client St',
        status: InvoiceStatus.draft,
        subTotal: 1000.0,
        taxTotal: 200.0,
        grandTotal: 1200.0,
        balanceDue: 1200.0,
      );

      expect(invoice.id, '1');
      expect(invoice.profileId, 'profile-1');
      expect(invoice.invoiceNumber, 'INV-001');
      expect(invoice.clientName, 'Test Client');
      expect(invoice.status, InvoiceStatus.draft);
      expect(invoice.subTotal, 1000.0);
      expect(invoice.taxTotal, 200.0);
      expect(invoice.grandTotal, 1200.0);
      expect(invoice.notes, isNull);
      expect(invoice.bankName, isNull);
    });

    test('should create Invoice with all fields', () {
      final invoice = Invoice(
        id: '1',
        profileId: 'profile-1',
        invoiceNumber: 'INV-001',
        date: DateTime(2024, 1, 15),
        clientName: 'Test Client',
        clientDetails: '123 Client St',
        status: InvoiceStatus.paid,
        subTotal: 1000.0,
        taxTotal: 200.0,
        grandTotal: 1200.0,
        balanceDue: 0.0,
        notes: 'Thank you for your business',
        bankName: 'Test Bank',
        bankIban: 'GB82WEST12345698765432',
        bankBic: 'WESTGB22',
        bankHolder: 'Test Company',
        clientId: 'client-1',
      );

      expect(invoice.status, InvoiceStatus.paid);
      expect(invoice.balanceDue, 0.0);
      expect(invoice.notes, 'Thank you for your business');
      expect(invoice.bankName, 'Test Bank');
      expect(invoice.bankIban, 'GB82WEST12345698765432');
      expect(invoice.bankBic, 'WESTGB22');
      expect(invoice.bankHolder, 'Test Company');
      expect(invoice.clientId, 'client-1');
    });

    test('copyWith should create a copy with updated fields', () {
      final original = Invoice(
        id: '1',
        profileId: 'profile-1',
        invoiceNumber: 'INV-001',
        date: DateTime(2024, 1, 1),
        clientName: 'Original Client',
        clientDetails: 'Original Details',
        status: InvoiceStatus.draft,
        subTotal: 500.0,
        taxTotal: 100.0,
        grandTotal: 600.0,
        balanceDue: 600.0,
      );

      final copied = original.copyWith(
        status: InvoiceStatus.sent,
        clientName: 'New Client',
        balanceDue: 300.0,
      );

      expect(copied.id, '1');
      expect(copied.status, InvoiceStatus.sent);
      expect(copied.clientName, 'New Client');
      expect(copied.balanceDue, 300.0);
      expect(copied.subTotal, 500.0);
    });

    test('InvoiceStatus enum should have correct values', () {
      expect(InvoiceStatus.values.length, 3);
      expect(InvoiceStatus.draft.index, 0);
      expect(InvoiceStatus.sent.index, 1);
      expect(InvoiceStatus.paid.index, 2);
    });

    test('two invoices with same values should be equal', () {
      final invoice1 = Invoice(
        id: '1',
        profileId: 'profile-1',
        invoiceNumber: 'INV-001',
        date: DateTime(2024, 1, 1),
        clientName: 'Test Client',
        clientDetails: 'Test Details',
        status: InvoiceStatus.draft,
        subTotal: 100.0,
        taxTotal: 20.0,
        grandTotal: 120.0,
        balanceDue: 120.0,
      );

      final invoice2 = Invoice(
        id: '1',
        profileId: 'profile-1',
        invoiceNumber: 'INV-001',
        date: DateTime(2024, 1, 1),
        clientName: 'Test Client',
        clientDetails: 'Test Details',
        status: InvoiceStatus.draft,
        subTotal: 100.0,
        taxTotal: 20.0,
        grandTotal: 120.0,
        balanceDue: 120.0,
      );

      expect(invoice1, equals(invoice2));
    });

    test('two invoices with different values should not be equal', () {
      final invoice1 = Invoice(
        id: '1',
        profileId: 'profile-1',
        invoiceNumber: 'INV-001',
        date: DateTime(2024, 1, 1),
        clientName: 'Client A',
        clientDetails: 'Details A',
        status: InvoiceStatus.draft,
        subTotal: 100.0,
        taxTotal: 20.0,
        grandTotal: 120.0,
        balanceDue: 120.0,
      );

      final invoice2 = Invoice(
        id: '2',
        profileId: 'profile-1',
        invoiceNumber: 'INV-002',
        date: DateTime(2024, 1, 1),
        clientName: 'Client B',
        clientDetails: 'Details B',
        status: InvoiceStatus.paid,
        subTotal: 200.0,
        taxTotal: 40.0,
        grandTotal: 240.0,
        balanceDue: 0.0,
      );

      expect(invoice1, isNot(equals(invoice2)));
    });
  });
}
