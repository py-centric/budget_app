import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/export/domain/entities/export_format.dart';
import 'package:budget_app/features/export/domain/entities/export_period.dart';
import 'package:budget_app/features/export/domain/entities/export_configuration.dart';

void main() {
  group('ExportFormat', () {
    test('displayName returns correct values', () {
      expect(ExportFormat.csv.displayName, 'CSV');
      expect(ExportFormat.pdf.displayName, 'PDF');
      expect(ExportFormat.excel.displayName, 'Excel');
    });

    test('extension returns correct values', () {
      expect(ExportFormat.csv.extension, 'csv');
      expect(ExportFormat.pdf.extension, 'pdf');
      expect(ExportFormat.excel.extension, 'xlsx');
    });

    test('all values are accessible', () {
      expect(ExportFormat.values.length, 3);
      expect(ExportFormat.values, contains(ExportFormat.csv));
      expect(ExportFormat.values, contains(ExportFormat.pdf));
      expect(ExportFormat.values, contains(ExportFormat.excel));
    });
  });

  group('ExportPeriod', () {
    test('displayName returns correct values', () {
      expect(ExportPeriod.currentMonth.displayName, 'Current Month');
      expect(ExportPeriod.customRange.displayName, 'Custom Range');
      expect(ExportPeriod.allTime.displayName, 'All Time');
    });

    test('all values are accessible', () {
      expect(ExportPeriod.values.length, 3);
      expect(ExportPeriod.values, contains(ExportPeriod.currentMonth));
      expect(ExportPeriod.values, contains(ExportPeriod.customRange));
      expect(ExportPeriod.values, contains(ExportPeriod.allTime));
    });
  });

  group('ExportConfiguration', () {
    test('creates with required parameters', () {
      const config = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      expect(config.period, ExportPeriod.currentMonth);
      expect(config.format, ExportFormat.csv);
      expect(config.startDate, null);
      expect(config.endDate, null);
    });

    test('creates with all parameters', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      final config = ExportConfiguration(
        period: ExportPeriod.customRange,
        format: ExportFormat.pdf,
        startDate: startDate,
        endDate: endDate,
      );

      expect(config.period, ExportPeriod.customRange);
      expect(config.format, ExportFormat.pdf);
      expect(config.startDate, startDate);
      expect(config.endDate, endDate);
    });

    test('copyWith creates new instance with updated values', () {
      const original = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      final updated = original.copyWith(
        format: ExportFormat.excel,
        period: ExportPeriod.allTime,
      );

      expect(updated.period, ExportPeriod.allTime);
      expect(updated.format, ExportFormat.excel);
      expect(original.period, ExportPeriod.currentMonth);
      expect(original.format, ExportFormat.csv);
    });

    test('copyWith preserves null dates', () {
      const config = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      final updated = config.copyWith(format: ExportFormat.pdf);

      expect(updated.startDate, null);
      expect(updated.endDate, null);
    });

    test('equality works correctly', () {
      const config1 = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );
      const config2 = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );
      const config3 = ExportConfiguration(
        period: ExportPeriod.allTime,
        format: ExportFormat.csv,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('props includes all fields', () {
      const config = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      expect(config.props.length, 4);
    });
  });
}
