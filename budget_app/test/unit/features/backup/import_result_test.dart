import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/backup/domain/entities/import_result.dart';

void main() {
  group('ImportResult', () {
    test('creates success result with default values', () {
      const result = ImportResult(success: true);

      expect(result.success, true);
      expect(result.tablesImported, 0);
      expect(result.recordsImported, 0);
      expect(result.errorMessage, null);
    });

    test('creates success result with custom values', () {
      const result = ImportResult(
        success: true,
        tablesImported: 5,
        recordsImported: 100,
      );

      expect(result.success, true);
      expect(result.tablesImported, 5);
      expect(result.recordsImported, 100);
    });

    test('creates failure result with error message', () {
      final result = ImportResult.failure('Database corrupted');

      expect(result.success, false);
      expect(result.errorMessage, 'Database corrupted');
    });

    test('failure result has default zero values', () {
      final result = ImportResult.failure('Error');

      expect(result.tablesImported, 0);
      expect(result.recordsImported, 0);
    });

    test('equality works correctly', () {
      const result1 = ImportResult(success: true, tablesImported: 5);
      const result2 = ImportResult(success: true, tablesImported: 5);
      const result3 = ImportResult(success: false, tablesImported: 5);

      expect(result1, equals(result2));
      expect(result1, isNot(equals(result3)));
    });
  });
}
