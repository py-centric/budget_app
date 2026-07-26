import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/models/feature_flag.dart';
import 'package:budget_app/core/feature_flags/config/default_feature_mapping.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Cross-Edition Database Safety Integration Tests', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE income_entries (
              id TEXT PRIMARY KEY,
              title TEXT,
              amount REAL
            )
          ''');
          await db.execute('''
            CREATE TABLE invoices (
              id TEXT PRIMARY KEY,
              client_name TEXT,
              total_amount REAL
            )
          ''');
        },
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Data insertion in Business mode remains accessible when switching to Personal mode', () async {
      // 1. Simulate Business Edition active
      final businessFlags = DefaultFeatureMapping.resolveFlags(ReleaseEdition.business);
      expect(businessFlags[FeatureFlag.invoicingPayables], isTrue);

      // Insert invoice entry
      await db.insert('invoices', {
        'id': 'inv_101',
        'client_name': 'Acme Corp',
        'total_amount': 1500.0,
      });

      // 2. Switch active edition to Personal Mode
      final personalFlags = DefaultFeatureMapping.resolveFlags(ReleaseEdition.personal);
      expect(personalFlags[FeatureFlag.invoicingPayables], isFalse);

      // Verify DB table and records remain preserved and uncorrupted
      final invoices = await db.query('invoices');
      expect(invoices.length, equals(1));
      expect(invoices.first['client_name'], equals('Acme Corp'));
      expect(invoices.first['total_amount'], equals(1500.0));

      // 3. Switch back to Combined Mode
      final combinedFlags = DefaultFeatureMapping.resolveFlags(ReleaseEdition.combined);
      expect(combinedFlags[FeatureFlag.invoicingPayables], isTrue);
      expect(combinedFlags[FeatureFlag.personalBudgets], isTrue);
    });
  });
}
