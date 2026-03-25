import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/export/data/services/export_service_impl.dart';
import 'package:budget_app/features/export/domain/entities/export_configuration.dart';
import 'package:budget_app/features/export/domain/entities/export_format.dart';
import 'package:budget_app/features/export/domain/entities/export_period.dart';

class MockExportServiceImpl extends Mock {}

void main() {
  group('ExportServiceImpl', () {
    setUp(() {
      ExportServiceImpl(
        fetchTransactions: (_) async => [],
        fetchSummary: (_) async => {
          'totalIncome': 100.0,
          'totalExpenses': 50.0,
          'balance': 50.0,
        },
      );
    });

    test('getTransactions returns data from fetchTransactions', () async {
      final transactions = [
        {
          'date': '2024-01-01',
          'amount': 100.0,
          'category': 'Food',
          'description': 'Test',
        },
      ];
      final testService = ExportServiceImpl(
        fetchTransactions: (_) async => transactions,
        fetchSummary: (_) async => {},
      );

      final result = await testService.getTransactions(
        const ExportConfiguration(
          period: ExportPeriod.currentMonth,
          format: ExportFormat.csv,
        ),
      );

      expect(result, transactions);
    });

    test('getSummary returns data from fetchSummary', () async {
      final summary = {
        'totalIncome': 200.0,
        'totalExpenses': 100.0,
        'balance': 100.0,
      };
      final testService = ExportServiceImpl(
        fetchTransactions: (_) async => [],
        fetchSummary: (_) async => summary,
      );

      final result = await testService.getSummary(
        const ExportConfiguration(
          period: ExportPeriod.currentMonth,
          format: ExportFormat.csv,
        ),
      );

      expect(result, summary);
    });
  });
}
