import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/export/domain/entities/export_configuration.dart';
import 'package:budget_app/features/export/domain/entities/export_format.dart';
import 'package:budget_app/features/export/domain/entities/export_period.dart';
import 'package:budget_app/features/export/data/services/export_service_impl.dart';

class MockDirectory extends Mock implements Directory {}

void main() {
  final testTransactions = [
    {
      'date': '2024-01-01',
      'amount': 100.0,
      'category': 'Food',
      'description': 'Groceries',
    },
    {
      'date': '2024-01-15',
      'amount': 50.0,
      'category': 'Transport',
      'description': 'Bus fare',
    },
  ];

  final testSummary = {
    'totalIncome': 1000.0,
    'totalExpenses': 500.0,
    'balance': 500.0,
  };

  group('ExportServiceImpl CSV generation', () {
    setUp(() async {
      ExportServiceImpl(
        fetchTransactions: (_) async => testTransactions,
        fetchSummary: (_) async => testSummary,
      );
    });

    test(
      'generateCsv returns file path',
      () async {
        // This test requires path_provider which isn't available in unit tests without mocking
        // Skipping for now - can be tested via integration tests
      },
      skip: 'Requires path_provider plugin - tested via integration tests',
    );

    test(
      'generateCsv creates valid CSV content',
      () async {
        // This test requires path_provider which isn't available in unit tests without mocking
        // Skipping for now - can be tested via integration tests
      },
      skip: 'Requires path_provider plugin - tested via integration tests',
    );
  });

  group('ExportServiceImpl getTransactions', () {
    test('fetches transactions via callback', () async {
      final service = ExportServiceImpl(
        fetchTransactions: (config) async => testTransactions,
        fetchSummary: (config) async => testSummary,
      );

      final result = await service.getTransactions(
        const ExportConfiguration(
          period: ExportPeriod.currentMonth,
          format: ExportFormat.csv,
        ),
      );

      expect(result.length, 2);
      expect(result[0]['category'], 'Food');
    });

    test('fetches summary via callback', () async {
      final service = ExportServiceImpl(
        fetchTransactions: (_) async => [],
        fetchSummary: (config) async => testSummary,
      );

      final result = await service.getSummary(
        const ExportConfiguration(
          period: ExportPeriod.currentMonth,
          format: ExportFormat.csv,
        ),
      );

      expect(result['totalIncome'], 1000.0);
      expect(result['totalExpenses'], 500.0);
    });
  });

  group('ExportServiceImpl file operations', () {
    test('deleteFile removes file', () async {
      final service = ExportServiceImpl(
        fetchTransactions: (_) async => [],
        fetchSummary: (_) async => {},
      );

      // Create a temp file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/test_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await tempFile.writeAsString('test');

      // Delete it
      await service.deleteFile(tempFile.path);

      // Verify it's deleted
      expect(await File(tempFile.path).exists(), false);
    });

    test('deleteFile handles non-existent file', () async {
      final service = ExportServiceImpl(
        fetchTransactions: (_) async => [],
        fetchSummary: (_) async => {},
      );

      // Should not throw
      await service.deleteFile('/nonexistent/file.csv');
    });
  });
}
