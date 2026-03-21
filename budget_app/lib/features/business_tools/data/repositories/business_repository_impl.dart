import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import 'package:budget_app/features/business_tools/data/models/company_profile_model.dart';
import 'package:budget_app/features/business_tools/data/models/invoice_item_model.dart';
import 'package:budget_app/features/business_tools/data/models/invoice_model.dart';
import 'package:budget_app/features/business_tools/data/models/invoice_payment_model.dart';
import 'package:budget_app/features/business_tools/domain/entities/company_profile.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_payment.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';
import 'package:budget_app/features/business_tools/domain/repositories/business_repository.dart';
import 'package:budget_app/features/business_tools/data/models/client_model.dart';
import 'package:budget_app/features/business_tools/domain/entities/received_invoice.dart';
import 'package:budget_app/features/business_tools/data/models/received_invoice_model.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final LocalDatabase _localDatabase;

  BusinessRepositoryImpl(this._localDatabase);

  @override
  Future<List<CompanyProfile>> getProfiles() async {
    final maps = await _localDatabase.getCompanyProfiles();
    return maps.map((map) => CompanyProfileModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveProfile(CompanyProfile profile) async {
    final model = CompanyProfileModel.fromEntity(profile);
    final existing = await _localDatabase.getCompanyProfiles();
    if (existing.any((e) => e['id'] == model.id)) {
      await _localDatabase.updateCompanyProfile(model.toMap());
    } else {
      await _localDatabase.insertCompanyProfile(model.toMap());
    }
  }

  @override
  Future<void> deleteProfile(String id) async {
    await _localDatabase.deleteCompanyProfile(id);
  }

  @override
  Future<List<Client>> getClients() async {
    final db = await _localDatabase.database;
    final maps = await db.query('clients');
    return maps.map((map) => ClientModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveClient(Client client) async {
    final db = await _localDatabase.database;
    final model = ClientModel.fromEntity(client);
    final existing = await db.query('clients', where: 'id = ?', whereArgs: [model.id]);
    if (existing.isNotEmpty) {
      await db.update('clients', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
    } else {
      await db.insert('clients', model.toMap());
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    final db = await _localDatabase.database;
    await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Invoice>> getInvoices() async {
    final maps = await _localDatabase.getInvoices();
    return maps.map((map) => InvoiceModel.fromMap(map)).toList();
  }

  @override
  Future<Invoice?> getInvoice(String id) async {
    final maps = await _localDatabase.getInvoices();
    final map = maps.firstWhere((e) => e['id'] == id, orElse: () => {});
    if (map.isEmpty) return null;
    return InvoiceModel.fromMap(map);
  }

  @override
  Future<void> saveInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final invoiceModel = InvoiceModel.fromEntity(invoice);
    final existing = await _localDatabase.getInvoices();
    
    if (existing.any((e) => e['id'] == invoiceModel.id)) {
      await _localDatabase.updateInvoice(invoiceModel.toMap());
    } else {
      await _localDatabase.insertInvoice(invoiceModel.toMap());
    }

    // Replace items
    await _localDatabase.deleteInvoiceItems(invoice.id);
    for (var item in items) {
      final itemModel = InvoiceItemModel.fromEntity(item);
      await _localDatabase.insertInvoiceItem(itemModel.toMap());
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _localDatabase.deleteInvoice(id);
  }

  @override
  Future<List<ReceivedInvoice>> getReceivedInvoices() async {
    final db = await _localDatabase.database;
    final maps = await db.query('received_invoices', orderBy: 'date DESC');
    return maps.map((map) => ReceivedInvoiceModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveReceivedInvoice(ReceivedInvoice invoice) async {
    final db = await _localDatabase.database;
    final model = ReceivedInvoiceModel.fromEntity(invoice);
    final existing = await db.query('received_invoices', where: 'id = ?', whereArgs: [model.id]);
    if (existing.isNotEmpty) {
      await db.update('received_invoices', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
    } else {
      await db.insert('received_invoices', model.toMap());
    }
  }

  @override
  Future<void> deleteReceivedInvoice(String id) async {
    final db = await _localDatabase.database;
    await db.delete('received_invoices', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    final maps = await _localDatabase.getInvoiceItems(invoiceId);
    return maps.map((map) => InvoiceItemModel.fromMap(map)).toList();
  }

  @override
  Future<List<InvoicePayment>> getInvoicePayments(String invoiceId) async {
    final maps = await _localDatabase.getInvoicePayments(invoiceId);
    return maps.map((map) => InvoicePaymentModel.fromMap(map)).toList();
  }

  @override
  Future<void> savePayment(InvoicePayment payment) async {
    final model = InvoicePaymentModel.fromEntity(payment);
    await _localDatabase.insertInvoicePayment(model.toMap());
    
    // Update invoice balance and status
    final invoice = await getInvoice(payment.invoiceId);
    if (invoice != null) {
      final payments = await getInvoicePayments(payment.invoiceId);
      final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
      final newBalance = invoice.grandTotal - totalPaid;
      
      final updatedInvoice = invoice.copyWith(
        balanceDue: newBalance,
        status: newBalance <= 0 ? InvoiceStatus.paid : invoice.status,
      );
      
      final items = await getInvoiceItems(payment.invoiceId);
      await saveInvoice(updatedInvoice, items);
    }
  }
}
