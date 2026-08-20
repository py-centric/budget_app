import 'base_dao.dart';

class InvoiceDao extends BaseDao {
  InvoiceDao(super.getDb);

  // Company Profiles
  Future<int> insertCompanyProfile(Map<String, dynamic> profile) async {
    final database = await db;
    return await database.insert('company_profiles', profile);
  }

  Future<int> updateCompanyProfile(Map<String, dynamic> profile) async {
    final database = await db;
    return await database.update(
      'company_profiles',
      profile,
      where: 'id = ?',
      whereArgs: [profile['id']],
    );
  }

  Future<int> deleteCompanyProfile(String id) async {
    final database = await db;
    return await database.delete('company_profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCompanyProfiles() async {
    final database = await db;
    return await database.query('company_profiles');
  }

  // Invoices
  Future<int> insertInvoice(Map<String, dynamic> invoice) async {
    final database = await db;
    return await database.insert('invoices', invoice);
  }

  Future<int> updateInvoice(Map<String, dynamic> invoice) async {
    final database = await db;
    return await database.update(
      'invoices',
      invoice,
      where: 'id = ?',
      whereArgs: [invoice['id']],
    );
  }

  Future<int> deleteInvoice(String id) async {
    final database = await db;
    return await database.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    final database = await db;
    return await database.query('invoices', orderBy: 'date DESC');
  }

  // Invoice Items
  Future<int> insertInvoiceItem(Map<String, dynamic> item) async {
    final database = await db;
    return await database.insert('invoice_items', item);
  }

  Future<void> deleteInvoiceItems(String invoiceId) async {
    final database = await db;
    await database.delete(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
  }

  Future<List<Map<String, dynamic>>> getInvoiceItems(String invoiceId) async {
    final database = await db;
    return await database.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
  }

  // Invoice Payments
  Future<int> insertInvoicePayment(Map<String, dynamic> payment) async {
    final database = await db;
    return await database.insert('invoice_payments', payment);
  }

  Future<List<Map<String, dynamic>>> getInvoicePayments(String invoiceId) async {
    final database = await db;
    return await database.query(
      'invoice_payments',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
      orderBy: 'date DESC',
    );
  }

  // Clients
  Future<List<Map<String, dynamic>>> getClients() async {
    final database = await db;
    return await database.query('clients');
  }

  Future<void> saveClient(Map<String, dynamic> client) async {
    final database = await db;
    final existing = await database.query(
      'clients',
      where: 'id = ?',
      whereArgs: [client['id']],
    );
    if (existing.isNotEmpty) {
      await database.update(
        'clients',
        client,
        where: 'id = ?',
        whereArgs: [client['id']],
      );
    } else {
      await database.insert('clients', client);
    }
  }

  Future<void> deleteClient(String id) async {
    final database = await db;
    await database.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  // Received Invoices
  Future<List<Map<String, dynamic>>> getReceivedInvoices() async {
    final database = await db;
    return await database.query('received_invoices', orderBy: 'date DESC');
  }

  Future<void> saveReceivedInvoice(Map<String, dynamic> invoice) async {
    final database = await db;
    final existing = await database.query(
      'received_invoices',
      where: 'id = ?',
      whereArgs: [invoice['id']],
    );
    if (existing.isNotEmpty) {
      await database.update(
        'received_invoices',
        invoice,
        where: 'id = ?',
        whereArgs: [invoice['id']],
      );
    } else {
      await database.insert('received_invoices', invoice);
    }
  }

  Future<void> deleteReceivedInvoice(String id) async {
    final database = await db;
    await database.delete('received_invoices', where: 'id = ?', whereArgs: [id]);
  }
}
