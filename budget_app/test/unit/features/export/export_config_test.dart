import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/export/domain/entities/export_configuration.dart';
import 'package:budget_app/features/export/domain/entities/export_format.dart';
import 'package:budget_app/features/export/domain/entities/export_period.dart';

class MockFile extends Mock implements File {}

class MockDirectory extends Mock implements Directory {}

void main() {
  group('ExportFormat', () {
    test('csv has correct display name', () {
      expect(ExportFormat.csv.displayName, 'CSV');
    });

    test('pdf has correct display name', () {
      expect(ExportFormat.pdf.displayName, 'PDF');
    });

    test('excel has correct display name', () {
      expect(ExportFormat.excel.displayName, 'Excel');
    });

    test('csv has correct extension', () {
      expect(ExportFormat.csv.extension, 'csv');
    });

    test('pdf has correct extension', () {
      expect(ExportFormat.pdf.extension, 'pdf');
    });

    test('excel has correct extension', () {
      expect(ExportFormat.excel.extension, 'xlsx');
    });

    test('all formats are available', () {
      expect(ExportFormat.values.length, 3);
    });
  });

  group('ExportPeriod', () {
    test('currentMonth has correct display name', () {
      expect(ExportPeriod.currentMonth.displayName, 'Current Month');
    });

    test('customRange has correct display name', () {
      expect(ExportPeriod.customRange.displayName, 'Custom Range');
    });

    test('allTime has correct display name', () {
      expect(ExportPeriod.allTime.displayName, 'All Time');
    });

    test('all periods are available', () {
      expect(ExportPeriod.values.length, 3);
    });
  });

  group('ExportConfiguration', () {
    test('creates with required parameters only', () {
      const config = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      expect(config.period, ExportPeriod.currentMonth);
      expect(config.format, ExportFormat.csv);
      expect(config.startDate, isNull);
      expect(config.endDate, isNull);
    });

    test('creates with all parameters', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      final config = ExportConfiguration(
        period: ExportPeriod.customRange,
        format: ExportFormat.excel,
        startDate: startDate,
        endDate: endDate,
      );

      expect(config.period, ExportPeriod.customRange);
      expect(config.format, ExportFormat.excel);
      expect(config.startDate, startDate);
      expect(config.endDate, endDate);
    });

    test('copyWith updates period', () {
      const config = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      final updated = config.copyWith(period: ExportPeriod.allTime);

      expect(updated.period, ExportPeriod.allTime);
      expect(updated.format, ExportFormat.csv);
    });

    test('copyWith updates format', () {
      const config = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      final updated = config.copyWith(format: ExportFormat.pdf);

      expect(updated.format, ExportFormat.pdf);
      expect(updated.period, ExportPeriod.currentMonth);
    });

    test('copyWith preserves dates', () {
      final startDate = DateTime(2024, 1, 1);
      final config = ExportConfiguration(
        period: ExportPeriod.customRange,
        format: ExportFormat.csv,
        startDate: startDate,
      );

      final updated = config.copyWith(format: ExportFormat.excel);

      expect(updated.startDate, startDate);
      expect(updated.endDate, isNull);
    });

    test('equality compares all fields', () {
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

    test('props contains all fields', () {
      const config = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      expect(config.props.length, 4);
    });
  });
}
