import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/backup/data/services/backup_service_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeDateTime extends Fake implements DateTime {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(DateTime.now());
  });

  group('BackupServiceImpl', () {
    late BackupServiceImpl service;

    setUp(() {
      service = BackupServiceImpl();
    });

    group('getDatabasePath', () {
      test('returns a path string', () async {
        final path = await service.getDatabasePath();

        expect(path, isA<String>());
        expect(path, contains('budget.db'));
      });
    });

    group('validateBackup', () {
      test('returns false for non-existent file', () async {
        final result = await service.validateBackup('/nonexistent/path.db');

        expect(result, false);
      });

      test('returns false for invalid file', () async {
        final result = await service.validateBackup(
          'test/integration/potential_transactions_test.dart',
        );

        expect(result, false);
      });
    });

    group('shareBackup', () {
      test('method exists and is callable', () {
        // Verify method exists - actual sharing requires platform setup
        expect(service.shareBackup, isA<Function>());
      });
    });
  });
}
