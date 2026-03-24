import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/backup/data/services/backup_service_impl.dart';
import 'package:budget_app/features/backup/domain/entities/import_result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('BackupServiceImpl', () {
    late BackupServiceImpl service;

    setUp(() {
      service = BackupServiceImpl();
    });

    test('getDatabasePath returns valid path', () async {
      final path = await service.getDatabasePath();

      expect(path, isNotEmpty);
      expect(path, endsWith('budget.db'));
    });

    test('validateBackup returns false for non-existent file', () async {
      final result = await service.validateBackup(
        '/path/that/does/not/exist.db',
      );
      expect(result, false);
    });

    test('validateBackup checks for SQLite header', () async {
      // Create a non-SQLite file
      final tempDir = Directory.systemTemp;
      final testFile = File(
        '${tempDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await testFile.writeAsString('This is not a database');

      final result = await service.validateBackup(testFile.path);

      expect(result, false);

      // Cleanup
      await testFile.delete();
    });

    test('validateBackup accepts valid SQLite file', () async {
      // Create a file with SQLite header
      final tempDir = Directory.systemTemp;
      final testFile = File(
        '${tempDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.db',
      );
      // SQLite format 3 header
      await testFile.writeAsBytes([
        0x53,
        0x51,
        0x4c,
        0x69,
        0x74,
        0x65,
        0x20,
        0x66,
        0x6f,
        0x72,
        0x6d,
        0x61,
        0x74,
        0x20,
        0x33,
        0x00,
      ]);

      final result = await service.validateBackup(testFile.path);

      expect(result, true);

      // Cleanup
      await testFile.delete();
    });

    test('shareBackup method is callable', () {
      expect(service.shareBackup, isA<Function>());
    });

    test('exportDatabase throws for non-existent database', () async {
      // The actual database may not exist in test environment
      // This tests the error handling path - either file not found or plugin error is acceptable
      try {
        await service.exportDatabase();
        fail('Expected an exception to be thrown');
      } catch (e) {
        // Either "not found" error or plugin error (if path_provider not mocked) is acceptable
        expect(
          e.toString().contains('not found') ||
              e.toString().contains('MissingPluginException'),
          true,
        );
      }
    });

    test('importDatabase handles missing file', () async {
      final result = await service.importDatabase('/nonexistent/backup.db');

      expect(result.success, false);
      expect(result.errorMessage, contains('not found'));
    });

    test('importDatabase validates file first', () async {
      final tempDir = Directory.systemTemp;
      final testFile = File(
        '${tempDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await testFile.writeAsString('Not a valid database');

      final result = await service.importDatabase(testFile.path);

      expect(result.success, false);
      expect(result.errorMessage, contains('Invalid'));

      // Cleanup
      await testFile.delete();
    });

    test('ImportResult.failure creates error result', () {
      final result = ImportResult.failure('Test error');

      expect(result.success, false);
      expect(result.errorMessage, 'Test error');
      expect(result.tablesImported, 0);
      expect(result.recordsImported, 0);
    });

    test('ImportResult success creates success result', () {
      const result = ImportResult(
        success: true,
        tablesImported: 5,
        recordsImported: 100,
      );

      expect(result.success, true);
      expect(result.tablesImported, 5);
      expect(result.recordsImported, 100);
    });
  });
}
