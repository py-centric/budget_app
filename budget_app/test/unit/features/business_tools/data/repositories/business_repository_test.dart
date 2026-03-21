import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/business_tools/data/repositories/business_repository_impl.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';
import 'package:budget_app/features/business_tools/data/models/client_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:budget_app/features/business_tools/domain/entities/received_invoice.dart';
import 'package:budget_app/features/business_tools/data/models/received_invoice_model.dart';

class MockLocalDatabase extends Mock implements LocalDatabase {}
class MockDatabase extends Mock implements Database {}

void main() {
  late BusinessRepositoryImpl repository;
  late MockLocalDatabase mockLocalDatabase;
  late MockDatabase mockDb;

  setUp(() {
    mockLocalDatabase = MockLocalDatabase();
    mockDb = MockDatabase();
    when(() => mockLocalDatabase.database).thenAnswer((_) async => mockDb);
    repository = BusinessRepositoryImpl(mockLocalDatabase);
  });

  group('Client CRUD', () {
    final tClient = Client(
      id: '1',
      name: 'Test Client',
      address: '123 Test St',
      taxId: 'TAX123',
    );
    final tClientModel = ClientModel.fromEntity(tClient);

    test('should get clients from database', () async {
      when(() => mockDb.query('clients')).thenAnswer((_) async => [tClientModel.toMap()]);

      final result = await repository.getClients();

      expect(result.first.id, equals(tClient.id));
      expect(result.first.name, equals(tClient.name));
      verify(() => mockDb.query('clients')).called(1);
    });

    test('should insert client if not exists', () async {
      when(() => mockDb.query('clients', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => []);
      when(() => mockDb.insert('clients', tClientModel.toMap())).thenAnswer((_) async => 1);

      await repository.saveClient(tClient);

      verify(() => mockDb.insert('clients', tClientModel.toMap())).called(1);
    });

    test('should update client if exists', () async {
      when(() => mockDb.query('clients', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [tClientModel.toMap()]);
      when(() => mockDb.update('clients', tClientModel.toMap(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => 1);

      await repository.saveClient(tClient);

      verify(() => mockDb.update('clients', tClientModel.toMap(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).called(1);
    });

    test('should delete client', () async {
      when(() => mockDb.delete('clients', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => 1);

      await repository.deleteClient('1');

      verify(() => mockDb.delete('clients', where: 'id = ?', whereArgs: ['1'])).called(1);
    });
  });

  group('Received Invoice CRUD', () {
    final tReceivedInvoice = ReceivedInvoice(
      id: '1',
      vendorName: 'Test Vendor',
      date: DateTime(2023, 1, 1),
      amount: 100,
      taxAmount: 20,
      status: ReceivedInvoiceStatus.unpaid,
      balanceDue: 100,
    );
    final tReceivedInvoiceModel = ReceivedInvoiceModel.fromEntity(tReceivedInvoice);

    test('should get received invoices from database', () async {
      when(() => mockDb.query('received_invoices', orderBy: any(named: 'orderBy')))
          .thenAnswer((_) async => [tReceivedInvoiceModel.toMap()]);

      final result = await repository.getReceivedInvoices();

      expect(result.first.id, equals(tReceivedInvoice.id));
      expect(result.first.vendorName, equals(tReceivedInvoice.vendorName));
    });

    test('should save received invoice', () async {
      when(() => mockDb.query('received_invoices', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => []);
      when(() => mockDb.insert('received_invoices', tReceivedInvoiceModel.toMap())).thenAnswer((_) async => 1);

      await repository.saveReceivedInvoice(tReceivedInvoice);

      verify(() => mockDb.insert('received_invoices', tReceivedInvoiceModel.toMap())).called(1);
    });

    test('should delete received invoice', () async {
      when(() => mockDb.delete('received_invoices', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => 1);

      await repository.deleteReceivedInvoice('1');

      verify(() => mockDb.delete('received_invoices', where: 'id = ?', whereArgs: ['1'])).called(1);
    });
  });
}
