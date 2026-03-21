import 'package:budget_app/features/business_tools/domain/entities/company_profile.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_payment.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';
import 'package:budget_app/features/business_tools/domain/entities/received_invoice.dart';

abstract class BusinessRepository {
  // Profiles
  Future<List<CompanyProfile>> getProfiles();
  Future<void> saveProfile(CompanyProfile profile);
  Future<void> deleteProfile(String id);

  // Clients
  Future<List<Client>> getClients();
  Future<void> saveClient(Client client);
  Future<void> deleteClient(String id);

  // Invoices
  Future<List<Invoice>> getInvoices();
  Future<Invoice?> getInvoice(String id);
  Future<void> saveInvoice(Invoice invoice, List<InvoiceItem> items);
  Future<void> deleteInvoice(String id);

  // Received Invoices (Payables)
  Future<List<ReceivedInvoice>> getReceivedInvoices();
  Future<void> saveReceivedInvoice(ReceivedInvoice invoice);
  Future<void> deleteReceivedInvoice(String id);

  // Items
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId);

  // Payments
  Future<List<InvoicePayment>> getInvoicePayments(String invoiceId);
  Future<void> savePayment(InvoicePayment payment);
}
